<#
.SYNOPSIS
  Builds the combined Dalamud plugin index (pluginmaster.json) from the plugins listed in plugins.json.
.DESCRIPTION
  For every configured repository this reads its **newest published release**, takes the plugin
  manifest out of the released zip, and pins the download links to exactly that release. Nothing is
  built, repackaged or re-released here: the index only points at artefacts that already exist.

  Reading the manifest out of the zip is what makes adding a plugin a one-line change: the source
  repository needs no workflow, no extra asset and no knowledge that this index exists. Any Dalamud
  plugin that publishes its packaged zip as a release asset can be listed.

  **A plugin that cannot be refreshed keeps its previous entry.** Failing to reach a repository is
  not evidence that the plugin is gone, and dropping it would uninstall it from every user's plugin
  list. The run is still reported as failed so the cause gets looked at, but the index never loses a
  plugin because GitHub had a bad minute.
.PARAMETER Config
  The list of source repositories.
.PARAMETER Output
  The generated index. Its previous content is the fallback described above.
.PARAMETER Token
  A GitHub token, only used to raise the API rate limit. Public releases need no authentication.
#>
param(
    [string]$Config = "plugins.json",
    [string]$Output = "pluginmaster.json",
    [string]$Token = $env:GH_TOKEN
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$headers = @{
    "Accept"     = "application/vnd.github+json"
    "User-Agent" = "miralsoft-dalamud-index"
}
if (-not [string]::IsNullOrWhiteSpace($Token)) {
    $headers["Authorization"] = "Bearer $Token"
}

# ---------------------------------------------------------------------------------------------
# The previous index, keyed by the repository its entry was built from. The key is taken from the
# download link because this script is what wrote it. The manifest's own RepoUrl is authored by the
# plugin and may point somewhere else entirely.
# ---------------------------------------------------------------------------------------------
function Get-RepoFromLink {
    param([string]$Link)
    if ([string]::IsNullOrWhiteSpace($Link)) { return $null }
    if ($Link -match "^https://github\.com/([^/]+/[^/]+)/releases/") { return $Matches[1].ToLowerInvariant() }
    return $null
}

# Every ConvertFrom-Json result is assigned to a variable *before* being wrapped in @(). Wrapping the
# call directly - @(ConvertFrom-Json ...) - collects its pipeline output, and Windows PowerShell 5.1
# emits a JSON array as one object rather than enumerating it: the wrap then yields a single element
# containing the whole array, and a loop over two plugins runs once with both fused together. A list
# of one hides this perfectly, which is exactly how it would have reached production.
$previous = @{}
if (Test-Path $Output) {
    try {
        $parsedPrevious = ConvertFrom-Json -InputObject (Get-Content $Output -Raw)
        foreach ($entry in @($parsedPrevious)) {
            $key = Get-RepoFromLink $entry.DownloadLinkInstall
            if ($key) { $previous[$key] = $entry }
        }
        Write-Host "Previous index: $($previous.Count) entry/entries available as fallback."
    }
    catch {
        Write-Warning "Previous index unreadable ($($_.Exception.Message)); continuing without a fallback."
    }
}

if (-not (Test-Path $Config)) { throw "Configuration '$Config' not found." }
$parsedConfig = ConvertFrom-Json -InputObject (Get-Content $Config -Raw)
$configured = @($parsedConfig)
if ($configured.Count -eq 0) { throw "'$Config' lists no plugins; refusing to write an empty index." }

# ---------------------------------------------------------------------------------------------
# Resolve one repository into an index entry.
# ---------------------------------------------------------------------------------------------
function Resolve-Plugin {
    param([string]$Repo, [string]$AssetName, [bool]$AcceptsFeedback)

    $release = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo/releases/latest" -Headers $headers
    $assets = @($release.assets)
    if ($assets.Count -eq 0) { throw "release '$($release.tag_name)' has no assets" }

    if ($AssetName) {
        $asset = $assets | Where-Object { $_.name -eq $AssetName } | Select-Object -First 1
        if (-not $asset) { throw "release '$($release.tag_name)' has no asset named '$AssetName'" }
    }
    else {
        $zips = @($assets | Where-Object { $_.name -like "*.zip" })
        if ($zips.Count -eq 0) { throw "release '$($release.tag_name)' has no .zip asset" }
        # "latest.zip" is what DalamudPackager emits by default; otherwise take the only zip there is.
        $asset = $zips | Where-Object { $_.name -eq "latest.zip" } | Select-Object -First 1
        if (-not $asset) {
            if ($zips.Count -gt 1) {
                throw "release '$($release.tag_name)' has $($zips.Count) zip assets; set 'asset' in plugins.json"
            }
            $asset = $zips[0]
        }
    }

    $work = Join-Path ([System.IO.Path]::GetTempPath()) ("idx-" + [System.Guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Path $work -Force | Out-Null
    try {
        $zipPath = Join-Path $work "plugin.zip"
        Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $zipPath -Headers $headers
        $unpacked = Join-Path $work "unpacked"
        Expand-Archive -Path $zipPath -DestinationPath $unpacked -Force

        # DalamudPackager writes <InternalName>.json next to the DLL. Pick the one that actually looks
        # like a plugin manifest rather than trusting a file name we would have to guess.
        $manifest = $null
        foreach ($candidate in Get-ChildItem -Path $unpacked -Filter "*.json" -File) {
            try { $parsed = Get-Content $candidate.FullName -Raw | ConvertFrom-Json } catch { continue }
            if ($parsed.PSObject.Properties.Name -contains "InternalName" -and
                $parsed.PSObject.Properties.Name -contains "AssemblyVersion") {
                $manifest = $parsed
                break
            }
        }
        if (-not $manifest) { throw "no plugin manifest found inside '$($asset.name)'" }

        # Pinned to this release, never to /latest/: "latest" means the newest release in the whole
        # repository, so as soon as another plugin publishes, a /latest/ link would hand out the wrong
        # zip. The tag is the only thing that keeps pointing at what this entry describes.
        $download = $asset.browser_download_url
        $manifest | Add-Member -NotePropertyName DownloadLinkInstall -NotePropertyValue $download -Force
        $manifest | Add-Member -NotePropertyName DownloadLinkUpdate  -NotePropertyValue $download -Force
        $manifest | Add-Member -NotePropertyName DownloadLinkTesting -NotePropertyValue $download -Force
        $manifest | Add-Member -NotePropertyName AcceptsFeedback     -NotePropertyValue $AcceptsFeedback -Force

        return [pscustomobject]@{
            Entry   = $manifest
            Tag     = $release.tag_name
            Version = $manifest.AssemblyVersion
            Name    = $manifest.InternalName
        }
    }
    finally {
        Remove-Item -Recurse -Force $work -ErrorAction SilentlyContinue
    }
}

# ---------------------------------------------------------------------------------------------
# Walk the configured plugins.
# ---------------------------------------------------------------------------------------------
$entries = @()
$failures = @()

foreach ($item in $configured) {
    $repo = $item.repo
    if ([string]::IsNullOrWhiteSpace($repo)) { throw "an entry in '$Config' has no 'repo' field." }

    $assetName = $null
    if ($item.PSObject.Properties.Name -contains "asset") { $assetName = $item.asset }

    $acceptsFeedback = $true
    if ($item.PSObject.Properties.Name -contains "acceptsFeedback") { $acceptsFeedback = [bool]$item.acceptsFeedback }

    try {
        $resolved = Resolve-Plugin -Repo $repo -AssetName $assetName -AcceptsFeedback $acceptsFeedback
        $entries += $resolved.Entry
        Write-Host "  ok   $repo -> $($resolved.Name) $($resolved.Version) (tag $($resolved.Tag))"
    }
    catch {
        $key = $repo.ToLowerInvariant()
        $reason = $_.Exception.Message
        if ($previous.ContainsKey($key)) {
            $entries += $previous[$key]
            $failures += "$repo ($reason) - previous entry kept"
            Write-Host "::warning::$repo could not be refreshed ($reason); keeping its previous entry."
        }
        else {
            $failures += "$repo ($reason) - NOT in the index"
            Write-Host "::error::$repo could not be resolved ($reason) and has no previous entry; it is missing from the index."
        }
    }
}

if ($entries.Count -eq 0) { throw "Nothing could be resolved; refusing to overwrite the index with an empty array." }

# Dalamud requires a JSON array and rejects a leading BOM. PowerShell 5.1 collapses a one-element
# array to a bare object, so the wrapping is done by hand to work on 5.1 and pwsh 7+ alike.
$json = @($entries) | ConvertTo-Json -Depth 12
if ($json.TrimStart().StartsWith("{")) {
    $json = "[" + [Environment]::NewLine + $json + [Environment]::NewLine + "]"
}
[System.IO.File]::WriteAllText(
    (Join-Path (Get-Location) $Output),
    $json,
    (New-Object System.Text.UTF8Encoding($false)))

Write-Host ""
Write-Host "Wrote $Output with $($entries.Count) entry/entries."

if ($failures.Count -gt 0) {
    Write-Host ""
    Write-Host "$($failures.Count) plugin(s) did not refresh:"
    $failures | ForEach-Object { Write-Host "  - $_" }
    if ($env:GITHUB_OUTPUT) { "failed=true" | Out-File -FilePath $env:GITHUB_OUTPUT -Append -Encoding utf8 }
}
elseif ($env:GITHUB_OUTPUT) {
    "failed=false" | Out-File -FilePath $env:GITHUB_OUTPUT -Append -Encoding utf8
}

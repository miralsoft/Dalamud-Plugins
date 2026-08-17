<#
.SYNOPSIS
  Runs the gates CI runs, in one command (R-18).
.DESCRIPTION
  Fast local feedback, never the guarantee: the server-side workflow in
  .github/workflows/content-checks.yml is the binding half (M-09, R-17), and it reads the same
  two keys out of .miralsoft-enforcement so the two can never disagree about what is covered.

  Every detector is tried against something it must match and something it must not before any
  of them is trusted (R-20). A check whose only observable outcome is silence cannot be told
  apart from a check that does nothing, and this layer has produced exactly that failure before.

  After the content gates it builds the index into a throwaway file, so a change to plugins.json
  can be read before it is pushed. The real pluginmaster.json is never touched here (X-01).
.PARAMETER SkipBuild
  Run only the content gates. Useful when GitHub is unreachable or the run should stay offline.
#>
param(
    [switch]$SkipBuild
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

$emDash = [string][char]0x2014
$failures = @()

function Write-Section {
    param([string]$Title)
    Write-Host ""
    Write-Host "== $Title"
}

# ---------------------------------------------------------------------------------------------
# The configuration both halves read.
# ---------------------------------------------------------------------------------------------
Write-Section "Enforcement configuration"

$configPath = Join-Path $root ".miralsoft-enforcement"
if (-not (Test-Path $configPath)) {
    throw "No .miralsoft-enforcement at the repository root. The hooks and CI both read it."
}

$config = @{}
foreach ($line in (Get-Content $configPath)) {
    if ($line -match '^\s*#') { continue }
    if ($line -match '^\s*$') { continue }
    $split = $line -split '=', 2
    if ($split.Count -eq 2) { $config[$split[0].Trim()] = $split[1].Trim() }
}

$globs = @()
$excludes = @()
if ($config.ContainsKey("CONTENT_GLOBS")) { $globs = @($config["CONTENT_GLOBS"] -split '\s+' | Where-Object { $_ }) }
if ($config.ContainsKey("CONTENT_EXCLUDE")) { $excludes = @($config["CONTENT_EXCLUDE"] -split '\s+' | Where-Object { $_ }) }

if ($globs.Count -eq 0) { throw "CONTENT_GLOBS is empty, so nothing would be checked (I-02)." }

Write-Host "  globs:    $($globs -join ' ')"
Write-Host "  excludes: $(if ($excludes.Count) { $excludes -join ' ' } else { 'none' })"

# ---------------------------------------------------------------------------------------------
# R-20. Prove each detector fires on a planted case and stays quiet on a clean one.
# The secret probes are assembled from pieces, because a line that looks like a secret is one
# as far as the scan is concerned, and this file is scanned like any other.
# ---------------------------------------------------------------------------------------------
Write-Section "The detectors can fail (R-20)"

$secretPatterns = @(
    'BEGIN [A-Z ]*PRIVATE KEY',
    ('(' + 'api[_-]?key|secret|token' + ')["'' ]*[:=]["'' ]*[A-Za-z0-9_-]{16,}')
)

$probes = @(
    @{ Name = "em-dash";     Text = "planted $emDash here";                                        Pattern = [regex]::Escape($emDash); Expect = $true },
    @{ Name = "em-dash";     Text = "a clean line";                                                Pattern = [regex]::Escape($emDash); Expect = $false },
    @{ Name = "private key"; Text = ('-----' + 'BEGIN' + ' RSA PRIVATE KEY' + '-----');            Pattern = $secretPatterns[0];       Expect = $true },
    @{ Name = "api key";     Text = ('api' + '_key = "' + 'abcdefghij1234567890"');                Pattern = $secretPatterns[1];       Expect = $true },
    @{ Name = "api key";     Text = "the api key is mentioned in ordinary prose";                  Pattern = $secretPatterns[1];       Expect = $false }
)

foreach ($probe in $probes) {
    $hit = [regex]::IsMatch($probe.Text, $probe.Pattern, [Text.RegularExpressions.RegexOptions]::IgnoreCase)
    if ($hit -ne $probe.Expect) {
        $what = if ($probe.Expect) { "is dead" } else { "matches anything" }
        $failures += "detector '$($probe.Name)' $what"
        Write-Host "  FAIL  $($probe.Name): $what"
    }
}

if ($failures.Count -gt 0) {
    Write-Host ""
    Write-Host "The checks below cannot be trusted, including a pass."
    $failures | ForEach-Object { Write-Host "  - $_" }
    exit 1
}
Write-Host "  Every detector fires on a planted case and stays quiet on a clean one."

# ---------------------------------------------------------------------------------------------
# R-03, R-19. The identity this project declares.
# ---------------------------------------------------------------------------------------------
Write-Section "Committer identity (R-03, R-19)"

$name = (git config user.name)
$email = (git config user.email)
$expectedName = $config["OWNER_NAME"]
$expectedEmail = $config["OWNER_EMAIL"]

if ($name -ne $expectedName -or $email -ne $expectedEmail) {
    $failures += "identity is '$name <$email>', expected '$expectedName <$expectedEmail>'"
    Write-Host "  FAIL  $name <$email>"
}
else {
    Write-Host "  $name <$email>"
}

# ---------------------------------------------------------------------------------------------
# The tracked files, filtered the way the hook and CI filter them. PowerShell's -like treats *
# as spanning a slash, which is the same behaviour as the shell's case, so docs/*.md reaches
# every depth and an exclusion is the only way to take a path out.
#
# The assignment before @() is deliberate: on Windows PowerShell 5.1, wrapping a command in @()
# collects its pipeline output, and a single result then hides inside a one-element list.
# ---------------------------------------------------------------------------------------------
$tracked = git ls-files
$files = @($tracked)

function Test-AnyGlob {
    param([string]$Path, [string[]]$Patterns)
    foreach ($pattern in $Patterns) {
        if ($Path -like $pattern) { return $true }
    }
    return $false
}

$checked = @($files | Where-Object {
        (Test-AnyGlob -Path $_ -Patterns $globs) -and -not (Test-AnyGlob -Path $_ -Patterns $excludes)
    })

# ---------------------------------------------------------------------------------------------
# I-02.
# ---------------------------------------------------------------------------------------------
Write-Section "No em-dash in prose (I-02)"

$emDashHits = @()
foreach ($file in $checked) {
    if (-not (Test-Path $file)) { continue }
    $content = [System.IO.File]::ReadAllText((Join-Path $root $file))
    if ($content.Contains($emDash)) { $emDashHits += $file }
}

if ($emDashHits.Count -gt 0) {
    foreach ($hit in $emDashHits) { Write-Host "  FAIL  $hit" }
    Write-Host "  Use commas, parentheses, or separate sentences."
    $failures += "$($emDashHits.Count) file(s) contain em-dash characters"
}
else {
    Write-Host "  None in $($checked.Count) checked file(s)."
}

# ---------------------------------------------------------------------------------------------
# R-10, S-02. Over the tracked files, because there is no staging area to read here.
# ---------------------------------------------------------------------------------------------
Write-Section "No secrets (R-10, S-02)"

$secretHits = @()
foreach ($file in $files) {
    if (-not (Test-Path $file)) { continue }
    $content = [System.IO.File]::ReadAllText((Join-Path $root $file))
    foreach ($pattern in $secretPatterns) {
        if ([regex]::IsMatch($content, $pattern, [Text.RegularExpressions.RegexOptions]::IgnoreCase)) {
            $secretHits += "$file ($pattern)"
            break
        }
    }
}

if ($secretHits.Count -gt 0) {
    foreach ($hit in $secretHits) { Write-Host "  FAIL  $hit" }
    $failures += "$($secretHits.Count) file(s) match a secret pattern"
}
else {
    Write-Host "  None in $($files.Count) tracked file(s)."
}

# ---------------------------------------------------------------------------------------------
# The project's own gate: does the list still resolve, and to what?
# ---------------------------------------------------------------------------------------------
if (-not $SkipBuild) {
    Write-Section "The index still builds (X-02)"

    $throwaway = Join-Path $root "pluginmaster.check.json"
    try {
        & (Join-Path $PSScriptRoot "build-index.ps1") -Output "pluginmaster.check.json" | Out-Host

        $parsedCheck = ConvertFrom-Json -InputObject (Get-Content $throwaway -Raw)
        $entries = @($parsedCheck)

        $bytes = [System.IO.File]::ReadAllBytes($throwaway)
        if ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
            $failures += "the generated index starts with a BOM, which Dalamud rejects"
            Write-Host "  FAIL  BOM at the start of the file"
        }
        if ([char]$bytes[0] -ne '[') {
            $failures += "the generated index does not start with '[', so it is not a JSON array"
            Write-Host "  FAIL  does not start with '['"
        }

        foreach ($entry in $entries) {
            $link = $entry.DownloadLinkInstall
            $pinned = $link -notmatch "/releases/latest/"
            if (-not $pinned) {
                $failures += "$($entry.InternalName) has an unpinned download link"
            }
            Write-Host ("  {0,-24} v{1,-10} api={2}  pinned={3}" -f $entry.InternalName, $entry.AssemblyVersion, $entry.DalamudApiLevel, $pinned)
        }
        Write-Host "  Read the names above. A green build only says something resolved (X-02)."
    }
    finally {
        Remove-Item $throwaway -Force -ErrorAction SilentlyContinue
    }
}

# ---------------------------------------------------------------------------------------------
Write-Host ""
if ($failures.Count -gt 0) {
    Write-Host "FAILED:"
    $failures | ForEach-Object { Write-Host "  - $_" }
    exit 1
}
Write-Host "All gates passed."

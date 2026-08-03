# How the index works

Internal description of this repository. The [README](../README.md) is the one written for users.

## What this is

Dalamud lets you add your own plugin sources — *custom plugin repositories*. Technically such a
source is nothing but **a URL that serves a JSON file**. That file is a **JSON array**; every element
describes one plugin with its name, version, description, icon and a download link to the packaged
zip. Dalamud shows each entry as an installable plugin.

This repository is exactly that list — **a directory, not a plugin**. It contains no plugin source
code, builds nothing and publishes no releases. Every plugin stays a repository of its own with
releases of its own; what lives here are only references to files that **already exist** over there.

## The chain of addresses

```
https://xivarsenal.app/plugins.json
        └── serves ────► raw.githubusercontent.com/miralsoft/Dalamud-Plugins/main/pluginmaster.json
                                └── points ────► at the releases of the individual plugin repos
```

`https://xivarsenal.app/plugin.json` (singular) serves the same file and **stays alive
permanently**. It is the address the first users entered, and they will never hear that anything
changed. The plural one is what gets documented from now on.

The domain sits in front on purpose: the address belongs to us, not to GitHub. Should this repository
ever be renamed, moved or replaced, only the target behind the domain changes — no user ever has to
touch anything again. That is why the domain is the official address and this repository is
replaceable.

## The files

| File | Meaning |
| --- | --- |
| `plugins.json` | **The only hand-maintained file.** The list of source repositories. |
| `scripts/build-index.ps1` | Builds the index from it. |
| `.github/workflows/index.yml` | Runs the script hourly, on demand, and on changes. |
| `pluginmaster.json` | **Generated — never edit by hand.** This is what Dalamud reads. |
| `README.md` | For users: an introduction to the plugins. |
| `docs/` | For us: this document and the guide to adding a plugin. |

## The process

For every repository in `plugins.json`:

1. Its **newest published release** is fetched through the GitHub API.
2. That release's zip is downloaded and the plugin manifest inside it is read out — name, version,
   description, `DalamudApiLevel`, icon, tags: everything Dalamud shows the player.
3. The download links are pinned to **exactly that release**.
4. Everything is assembled into an array and committed.

Reading the manifest out of the zip is the decisive trick: **the source repository has to do
nothing.** No workflow, no extra file, no knowledge that this index exists. Any Dalamud plugin that
attaches its packaged zip as a release asset can be listed.

## Rules that must not be broken

Every violation makes plugins disappear from the list for **all** users, or stop installing.

1. **Never change `pluginmaster.json` by hand.** It is generated; a hand edit is gone on the next run
   — or stays and is wrong.
2. **Never change the public address.** Users have entered it.
3. **The file has to stay a JSON array** (`[ … ]`), even with exactly one entry. Dalamud rejects a
   bare object.
4. **No BOM** at the start of the file — Dalamud's parser rejects it. In PowerShell that means
   `[System.IO.File]::WriteAllText` with `UTF8Encoding($false)`; `Set-Content -Encoding utf8` and
   `Out-File -Encoding utf8` produce a BOM on Windows PowerShell 5.1.
5. **Download links point at a fixed tag, never at `/releases/latest/`.** "Latest" means "the newest
   release in the entire repository" — harmless while a single plugin lives there, wrong from the
   second one onwards. The script gets this right; please do not "simplify" it.
6. **A plugin that cannot be reached keeps its previous entry.** See below.
7. **Source repositories have to be public.** Dalamud downloads without signing in; a private
   repository would give users a 404.
8. **No plugin code in this repository.**

## Why a failure deletes nothing

If a repository cannot be read, the script carries over its **previous entry**. In the code this
looks like sloppy error handling and is the exact opposite: being unable to read something is no
evidence that it is gone. If the entry disappeared, Dalamud would drop the plugin from the list for
**every** user — over one bad minute at GitHub.

The run still goes red so that somebody takes a look. If nothing at all resolves, the file is left
untouched rather than being overwritten with an empty list.

**Please do not "clean up" this logic.**

## Testing

In the root directory:

```powershell
./scripts/build-index.ps1
```

Then check: does the file start with `[`? Does every entry have `InternalName`, `AssemblyVersion`,
`DalamudApiLevel` and a download link with a tag in it?

**A trap that has already sprung once:** on Windows PowerShell 5.1, `@( ConvertFrom-Json … )`
collects the *pipeline output*, and 5.1 passes a JSON array through as **one** object — the brackets
turn that into a single-element list, and a loop over two plugins runs once with both of them fused
together. With exactly one plugin this never shows. That is why the script always assigns first and
then writes `@($variable)`. When testing, always check with **at least two** entries.

## What users see where

A common misunderstanding: **what Dalamud shows in game does not come from this repository's
README.** Name, punchline, description, icon and tags are read by Dalamud from the manifest that
every plugin brings along inside its own zip.

- To make a plugin introduce itself better **in game** → that belongs in the manifest of the
  respective plugin repository.
- The README here is aimed at **people on GitHub**. A typo in it breaks nothing.

# Dalamud-Plugins

The custom Dalamud repository for miralsoft's plugins. One address, all plugins.

```
https://xivarsenal.app/plugin.json
```

Paste that into Dalamud under `/xlsettings` → *Experimental* → *Custom Plugin Repositories*, press
`+`, then *Save*. Every plugin listed here then appears in `/xlplugins`.

## What this repository is

It holds no plugin code and builds nothing. It is an **index**: [`pluginmaster.json`](pluginmaster.json)
is a list of entries, each pointing at a release that already exists in that plugin's own repository.
Publishing a plugin stays entirely a matter of that plugin's repository — releasing there is all it
takes, and nothing is ever repackaged or re-released here.

`https://xivarsenal.app/plugin.json` serves this file. The address belongs to the domain rather than
to any repository, so where the index lives can change later without anyone having to re-enter
anything.

## Adding a plugin

Add one line to [`plugins.json`](plugins.json):

```json
[
  { "repo": "miralsoft/Dalamud-Eorzea-Arsenal" },
  { "repo": "miralsoft/Your-New-Plugin" }
]
```

That is the whole job. The source repository needs no workflow, no extra file and no knowledge that
this index exists — the index reads the plugin manifest out of the released zip. Pushing the change
rebuilds the index immediately; otherwise it rebuilds hourly.

Two requirements on the plugin being added:

- **The repository must be public.** Dalamud downloads the zip without credentials, so a private
  repository would give your users a 404.
- **Its newest release must have the packaged zip attached** — what DalamudPackager produces, which
  contains the plugin's manifest. `latest.zip` is picked up automatically.

Optional per entry:

| Field | Meaning |
| --- | --- |
| `asset` | The asset to use, when a release attaches more than one zip. |
| `acceptsFeedback` | Whether Dalamud offers the feedback button. Defaults to `true`. |

## How a release reaches your users

1. You publish a release in the plugin's own repository, as usual.
2. Within the hour the index reads that repository's **newest** release, takes the manifest out of
   the zip and writes an entry pinned to that exact tag.
3. `https://xivarsenal.app/plugin.json` serves the updated list; Dalamud offers the update.

The download links deliberately point at a **specific tag**, never at `/releases/latest/`. "Latest"
means the newest release in a repository as a whole — fine while a repository holds one plugin, and
wrong the moment it does not.

## When a plugin cannot be read

A repository that cannot be reached **keeps its previous entry**. Failing to read something is not
evidence that it is gone, and dropping an entry would remove the plugin from every user's list. The
run is still marked failed so the cause gets looked at, but no plugin disappears because GitHub had a
bad minute. If nothing at all can be resolved, the index is left untouched rather than overwritten
with an empty list.

## Running it by hand

*Actions* → *Index* → *Run workflow*. Locally:

```powershell
./scripts/build-index.ps1
```

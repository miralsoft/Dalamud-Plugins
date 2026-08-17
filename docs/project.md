# Project: FFXIV Plugin Index

Purpose: the identity card of the project. Who it is, what it is, which rules apply to it.

## Identity

- **Name:** FFXIV Plugin Index
- **Slug:** ffxiv-plugin-index
- **Owner:** Sanaka (GitHub `miralsoft`)
- **Summary:** The aggregate Dalamud plugin index for the FFXIV plugins of miralsoft. It holds one
  hand-maintained list of source repositories and builds from it the JSON array that players
  subscribe to in their client. It contains no plugin code, builds nothing, and publishes no
  releases of its own.
- **Kind:** external (M-12). Its documentation lives here in `docs/`, it carries the entrypoint
  from `entrypoints/for-project-repos/` at its root, and nothing is written back to the foundation.
- **Committer identity:** `Sanaka` (R-03, R-19). These are private projects, not business ones. The
  email is `20637644+miralsoft@users.noreply.github.com`. `.miralsoft-enforcement` matches this.

## Declared languages, frameworks, and active profiles

- **Framework:** Dalamud. Activates `rules/frameworks/dalamud.md`, whose section "Building and
  shipping a plugin" defines the chain this repository is one part of.
- **Languages:** the only code here is one PowerShell script and two GitHub Actions workflows.
  `rules/languages/` carries no PowerShell profile, so none is activated. M-13 obliges writing that
  profile in the foundation before the code, which cannot be done from here (M-18). Recorded in
  `open-points.md` as belonging to the foundation repository.

## Targeted foundation version

3.1.0 (M-06). Reviewed at every release of this repository, which in practice means whenever a
plugin is added or removed (M-17).

## Code repositories

- **`miralsoft/Dalamud-Plugins`** (this one): the list, the build script, the generated index, and
  the README that introduces every listed plugin.

The listed plugin repositories are separate projects with their own documentation and their own
lifetimes. This repository only references their releases:

- `miralsoft/Dalamud-Eorzea-Arsenal`
- `miralsoft/Dalamud-Fate-Compass`
- `miralsoft/Dalamud-Gearbook`

## Hosting and deploy summary

Nothing is deployed. The generated `pluginmaster.json` is served from the repository's `main`
branch through `raw.githubusercontent.com`, and the public address on `xivarsenal.app` serves that
file through. The address itself belongs to the website project and is maintained there, not here.

## High-level architecture summary

A scheduled workflow reads `plugins.json`, fetches the newest published release of every listed
repository, takes the plugin manifest out of the released zip, pins the download links to that
release, and commits the resulting JSON array as `pluginmaster.json`. A repository that cannot be
read keeps its previous entry. The full picture is in `architecture.md` and, for day-to-day work,
in `how-the-index-works.md`.

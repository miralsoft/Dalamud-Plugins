# Architecture: FFXIV Plugin Index

Purpose: the technical architecture of the project, and the contract this repository holds up
towards the plugin repositories and towards the website.

## Overview

Three parties, none of which knows much about the others:

```
plugin repositories            this repository                the website
(source, releases)   ────►     (list, build, index)   ────►   (public address)
                                                                    │
                                                                    ▼
                                                              Dalamud client
```

A plugin repository publishes a release with its packaged zip. This repository reads that release,
takes the manifest out of the zip, and writes one JSON array. The website serves that array under
the address players paste into their client.

The direction matters: everything flows one way. A plugin repository needs no workflow, no extra
file, and no knowledge that this index exists. That is what makes listing a plugin a one-line
change.

## Components

### `plugins.json`

The only hand-maintained file. A JSON array of objects with `repo` and, optionally, `asset` and
`acceptsFeedback`. Adding or removing a line is the only deliberate way an entry appears or
disappears.

### `scripts/build-index.ps1`

Resolves every listed repository into an index entry and writes `pluginmaster.json`. Three
properties of it are load-bearing and are explained where they live, in
`how-the-index-works.md`: the file stays a JSON array, it is written without a BOM, and a
repository that cannot be read keeps its previous entry rather than vanishing (D-06).

### `scripts/check.ps1`

One command that runs the gates CI runs (R-18): the content checks from `.miralsoft-enforcement`,
then a throwaway index build so a change to the list is verified before it is pushed.

### `.github/workflows/index.yml`

Runs the build hourly at `:17`, on demand, and on any push that changes `plugins.json`, the build
script, or itself. It commits `pluginmaster.json` back to `main` and fails afterwards if a plugin
could not be refreshed, so the file is still published while the red run asks somebody to look.

### `.github/workflows/content-checks.yml`

The server-side half of the git hooks (R-17), copied from the foundation.

### `pluginmaster.json`

Generated. Never edited by hand, and excluded from the em-dash check because its prose is quoted
from the plugin manifests (see `decisions.md`).

## Contract between components

**What this repository expects from a plugin repository** (framework profile, "Before the very
first release"): it is public, it has at least one published release that is neither draft nor
pre-release, and the packaged zip is attached to it. Nothing else.

**What a plugin repository can expect from this one:** its entry is built from the manifest inside
its newest release, unchanged, so every field the packager produced carries through, including the
API level that decides whether the plugin is visible at all. Two fields are set by this repository
rather than taken from the manifest: the three download links, and `AcceptsFeedback`. The second of
those overwrites the manifest and is a known wart, see `open-points.md`.

**What the website expects:** a JSON array at
`raw.githubusercontent.com/miralsoft/Dalamud-Plugins/main/pluginmaster.json`. The routes in front of
it belong to the website project. This repository never changes them and cannot.

**Ownership boundary:** the entry for a plugin, its description, and its icon address belong to the
plugin repository, because they come out of its manifest. Wanting different text in the client is
a change over there, never here (M-18).

## Deploy and update mechanism

Nothing is deployed anywhere. A change reaches players along this path, with the two waits named:

1. A commit lands on `main` here, or the hourly schedule fires at `:17`.
2. The workflow rebuilds `pluginmaster.json` and commits it to `main`.
3. `raw.githubusercontent.com` serves the new file.
4. The public address serves it after its ten-minute cache expires.
5. The Dalamud client picks it up on its next refresh.

The full procedure, including how to skip the wait, is in `release.md`.

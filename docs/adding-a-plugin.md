# Adding a plugin

Short version: **one line in `plugins.json`, one section in the README.** Everything else happens on
its own. Background in [how the index works](how-the-index-works.md).

## What the plugin has to bring

Three things have to be true before it can be listed:

1. **The repository is public.** Dalamud downloads without signing in; private would give users a
   404.
2. **There is at least one published release** (no draft, no pre-release).
3. **The packaged zip is attached to that release** — the one DalamudPackager produces, the one that
   contains the plugin manifest. If it is called `latest.zip`, it is found automatically.

Nothing more is needed. In particular the plugin repository needs **no** workflow, no extra file and
no knowledge that this index exists.

## Step 1 — list it

In `plugins.json`:

```json
[
  { "repo": "miralsoft/Dalamud-Eorzea-Arsenal" },
  { "repo": "miralsoft/New-Plugin" }
]
```

Optional per entry:

| Field | Meaning |
| --- | --- |
| `asset` | Which attachment to use, in case a release has several zips. |
| `acceptsFeedback` | Whether Dalamud offers the feedback button. Defaults to `true`. |

Watch out for `acceptsFeedback`: the index writes that field into every entry, overwriting whatever
the plugin's own manifest says, and without the field it writes `true`. So a plugin that opts out in
its manifest has that opt-out silently undone unless the opt-out is repeated here. Check the
manifest's `AcceptsFeedback` before listing a plugin and match it.

## Step 2 — introduce it

In the [README](../README.md), add a section following the pattern of the existing one: a heading
with the name, one bold sentence saying what the plugin does, a handful of bullet points, and the
links to the plugin repository and, if there is one, to its website.

The README is the **user-facing page**, and it is **written in English** — that is the language most
of the players who find this repository read. It does not explain how this directory works; that is
what these documents are for.

Keep in mind that what Dalamud shows **in game** comes from the plugin's manifest, not from this
README. If the description reads badly in game, the fix belongs in the plugin repository.

## Step 3 — check

Pushing to `main` starts the index workflow immediately (it reacts to changes in `plugins.json`).
After that:

- Under *Actions* → *Index*, the run has to be **green**. Red means at least one plugin could not be
  resolved — the cause is in the log of the *Build index* step.
- In `pluginmaster.json`, the new plugin has to appear with `InternalName`, `AssemblyVersion`,
  `DalamudApiLevel` and a download link that contains a **tag** (not `latest`).

Testing locally beforehand works too:

```powershell
./scripts/build-index.ps1
```

## Common causes when it does not work

| Message | Cause |
| --- | --- |
| `404` | Repository private, name misspelled, or there is no release yet. |
| `release '…' has no assets` | The release has no attachments — the zip is missing. |
| `no plugin manifest found inside …` | There is no manifest file inside the zip; most likely it was not packed with DalamudPackager. |
| `has N zip assets` | Several zips on the release — name the intended one via `asset`. |

## Removing a plugin again

Delete its line from `plugins.json`. On the next run the entry disappears from the index — and with
it **from the plugin list of every user**. That is the only way an entry vanishes on purpose; a
failure while fetching explicitly does not do this.

## About the address

The documented address, the one to hand out from here on:

```
https://xivarsenal.app/plugins.json
```

`https://xivarsenal.app/plugin.json` (singular) serves the very same file and **must stay alive
permanently**. It is what the first users entered; switching it off would take the plugins out of
their list, and they would never learn why. Never remove it, and do not bother documenting it either
— it simply keeps working.

Should a third route ever be added, "live" needs checking the response body, not just the status
code: the website is a single-page app, so an unknown path answers **`200 OK` with the HTML shell**,
which makes a plain `curl -sI` look like a success. Compare the content type instead:

```bash
curl -s -o /dev/null -w '%{http_code} %{content_type}\n' https://xivarsenal.app/plugins.json
```

`application/json` means the route is there; `text/html` means it is not, whatever the status code
says.

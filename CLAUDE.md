# Working on this repository

This is a Dalamud plugin **index** — a directory pointing at the releases of the individual plugin
repositories. It holds no plugin code, builds nothing and publishes no releases of its own. All
plugins are meant to be installable from **one single address**, so that users never have to add a
new source per plugin.

Read these before changing anything:

| File | What it covers |
| --- | --- |
| `docs/how-the-index-works.md` | Structure, the chain of addresses, the rules that must not be broken, testing |
| `docs/adding-a-plugin.md` | The step-by-step guide, including prerequisites and failure modes |
| `plugins.json` | The only hand-maintained file |

`README.md` is the **user-facing page**: what is here, what it does, how to get it — in that order.
It says nothing about how the directory works internally; that belongs in `docs/`.

## Conventions

- **Talk to the operator in German. Everything written into this repository is English**, file names
  included. The README is read by players, most of whom read English.
- **Conventional commits** (`feat:`, `fix:`, `docs:`, `chore:`).
- Git identity: `Sanaka <20637644+miralsoft@users.noreply.github.com>`.
- **Never name an AI as an author or co-author.** No `Co-Authored-By` lines, no "generated with"
  footers — not in commits, not in pull requests, not in files. This is an explicit rule of the
  operator's.
- `main` is the only branch; small changes may go there directly.

## Three things not to do

The full list is in `docs/how-the-index-works.md`. These three tend to get broken with the best of
intentions:

1. **Editing `pluginmaster.json` by hand.** It is generated. A hand edit is gone on the next run — or
   stays and is wrong.
2. **"Cleaning up" the error handling in the build script.** A repository that cannot be reached
   keeps its previous entry on purpose. Being unable to read something is not evidence that it is
   gone, and dropping the entry would remove the plugin from *every* user's list over one bad minute
   at GitHub.
3. **Changing or retiring a public address.** Users entered it and will never hear that it changed.

## After a change to plugins.json

Pushing to `main` starts the *Index* workflow. Before reporting anything as done:

1. The run under *Actions* → *Index* is **green**.
2. `pluginmaster.json` carries the entry with `InternalName`, `AssemblyVersion`, `DalamudApiLevel`
   and a download link containing a **tag**, not `latest`.
3. `https://xivarsenal.app/plugins.json` actually serves it. Check the **content type**, not the
   status code — see below. The site caches for ten minutes, so allow for that.

A green run alone proves little: the script resolves whatever the release contains. If a plugin was
renamed but its newest release is still the build from before the rename, the run succeeds and
writes the old `InternalName`. Read the resolved name in the log, not just the colour.

Testing locally first is cheap and catches this:

```powershell
./scripts/build-index.ps1 -Output "pluginmaster.test.json"
```

Build into a *test* file so the real index stays untouched, check what it produced, then delete it.

## Two traps that have already sprung

**The website is a single-page app.** It answers unknown paths with `200 OK` and the HTML shell, so a
plain `curl -sI` reports success for a route that does not exist. Compare the content type instead —
`application/json` means it is there, `text/html` means it is not:

```bash
curl -s -o /dev/null -w '%{http_code} %{content_type}\n' https://xivarsenal.app/plugins.json
```

**Windows PowerShell 5.1 fuses JSON arrays.** `@( ConvertFrom-Json … )` wrapped directly collects
*pipeline output*, and 5.1 passes an array through as one object — a loop over three plugins then
runs once with all three merged. Always assign first, then wrap: `$p = ConvertFrom-Json …; @($p)`.
This applies to throwaway verification commands just as much as to the script.

## This environment

The GitHub CLI is **not** authenticated here; `git push` works through the Windows credential
manager. The workflow therefore cannot be dispatched from here — to rebuild the index without
waiting for the hourly run (`:17`), ask the operator to press *Run workflow* under *Actions* →
*Index*.

The public route itself lives on the website and is maintained by a different agent in a separate
project. It is not part of this repository.

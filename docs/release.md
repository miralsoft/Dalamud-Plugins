# Release procedure: FFXIV Plugin Index

Purpose: the chain from the act that starts a release to the moment somebody can install it,
written to be followed rather than remembered (D-01). This repository publishes no releases of its
own; what it releases is the index, and a release here means a plugin appearing, changing, or
disappearing in the list.

## What the plugin repository has to have done first

Before a plugin can be listed at all (framework profile, "Before the very first release"):

- the repository is public;
- it has at least one published release, neither draft nor pre-release;
- the packaged zip is attached to that release, under `latest.zip` or named through `asset`.

Nothing else. No workflow, no extra file, no knowledge of this index.

## Adding, changing, or removing a plugin

1. Edit `plugins.json`. One line per repository. Check the plugin manifest's `AcceptsFeedback` and
   repeat it here if it is `false`, otherwise the index overwrites it with `true`.
2. For a new plugin, add its section to the README as well. Both steps, always: a listing nobody can
   read about reaches only the people who already knew (D-08).
3. Run `./scripts/check.ps1`. It runs the content gates and builds the index into a throwaway file,
   so the resolved names and versions can be read before anything is pushed.
4. Commit and push to `main`. The push starts the *Index* workflow, because it watches
   `plugins.json`.

## Confirming it

A green run is the automation's statement about itself and is not the confirmation (D-07). Check
the result:

1. **The run is green** under *Actions* → *Index*. Red means at least one plugin could not be
   refreshed, and the cause is in the log of the *Build index* step. Do not simply run it again.
2. **The log names what was resolved.** Read the `InternalName` and the version, not just the
   colour. A plugin whose newest release predates a rename resolves cleanly under its old name
   (X-02).
3. **`pluginmaster.json` carries the entry** with `InternalName`, `AssemblyVersion`,
   `DalamudApiLevel`, and a download link containing a tag rather than `latest`.
4. **The public address serves it.** Check the content type, never the status code: the site is a
   single-page app and answers unknown paths with `200` and an HTML shell (D-16).

   ```bash
   curl -s -o /dev/null -w '%{http_code} %{content_type}\n' https://xivarsenal.app/plugins.json
   ```

## The two delays, with their durations

Both are normal. Undocumented they read as a fault and send somebody hunting one that does not
exist (D-02).

- **The index rebuild: up to one hour.** The workflow is scheduled at `:17` past the hour. A push
  that changes `plugins.json` starts it at once, but a release published in a *plugin* repository
  does not, because that repository does not know this one exists. That is the wait this delay is
  really about.

  **It can be skipped:** press *Run workflow* under *Actions* → *Index*. This is permitted even
  though the workflow belongs to this repository's own automation, because the scheduled run reaches
  the same state on its own within the hour, so pressing it only moves the moment rather than
  changing anything (M-18). Triggering it with inputs would be a different act and is not done.

- **The public address cache: ten minutes.** `Cache-Control: public, max-age=600` in front of the
  raw file. Nothing here can shorten it. It simply passes.

After both, the Dalamud client still picks the change up on its own next refresh.

## Removing a plugin

Deleting a line from `plugins.json` removes the plugin from the list of **every** user at the next
run. It is the only way an entry disappears on purpose, and a failed fetch explicitly does not do it
(D-06). Treat it as the deliberate act it is.

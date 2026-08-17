# Status: FFXIV Plugin Index

Purpose: the current state of the project. The shared handover channel between sessions and between
different AIs. Update this at the end of every working session (M-08, R-02).

## Overall

The index is live and healthy. Three plugins are listed, both public addresses serve the current
file, and the last *Index* run was green. As of 2026-08-17 the repository has been brought under the
MIRAL Soft foundation as an external project (M-12) at foundation version 3.1.0, which it had never
been before.

## Index

- **Done:** `plugins.json` lists Eorzea Arsenal, Fate Compass, and Gearbook. Every entry carries a
  download link pinned to its release tag. Both `https://xivarsenal.app/plugins.json` and the
  singular legacy address answer `application/json` with all three entries. The versions are not
  written down here on purpose: they move with every plugin release, and `./scripts/check.ps1`
  prints the current ones (C-12).
- **Next:** watch the scheduled run at `:17`. See the note below.

### One red run on 2026-08-17, investigated and closed

The push at 17:43:04 and the hourly schedule at 17:43:06 started two *Index* runs two seconds
apart on the same commit. The push run was green. The scheduled one (run 32051576238) reported
failure in its last step, "Fail if a plugin did not refresh", while "Build index" and "Commit if
changed" both succeeded. So one repository could not be refreshed and kept its previous entry,
which is the D-06 path working as designed.

What was checked: the published `pluginmaster.json` carries all three plugins at their newest
releases with pinned links, the public address serves the same, a local build resolves all three,
and the change to `build-index.ps1` in that commit was comment text only. The seven scheduled runs
before it were green.

**Confirmed from the build log** (a working, authenticated GitHub CLI became available in the
session after this was first written): `miralsoft/Dalamud-Eorzea-Arsenal` and
`miralsoft/Dalamud-Fate-Compass` both resolved normally in this run. `miralsoft/Dalamud-Gearbook`
did not; the log names the exact cause, `Response status code does not indicate success: 500
(Internal Server Error)`, from the GitHub API itself, not from the plugin repository or the
script. The owner's read on the day: GitHub was having broader issues at the time, which fits a
transient 500 rather than anything specific to Gearbook. This confirms the inference this entry
originally carried as unverified.

Deliberately not re-run: the output was already correct, so a re-run would have proven nothing the
next scheduled run did not prove for free. It came back green on schedule.

## Foundation adoption

- **Done:** entrypoint replaced with the foundation template (it had been a hand-written rulebook,
  which M-11 and M-12 forbid), seven project files created from `projects/_template/`,
  `.miralsoft-enforcement` written with `OWNER_NAME=Sanaka`, hooks installed, content checks
  mirrored in CI, `scripts/check.ps1` added for R-18, release procedure written for D-01 and D-02,
  and the 42 em-dashes removed from the prose (I-02).
- **Next:** the two items in `open-points.md` that belong to the foundation repository. Neither can
  be closed from here (M-18).

## Handover notes

- An authenticated GitHub CLI (`gh`) is available in this environment as of 2026-08-17 (account
  `miralsoft`, scopes include `workflow`), which was not true earlier the same day. Run logs and
  workflow state can be read directly (`gh run list`, `gh run view --log-failed`); this closed the
  red-run investigation above. Whether it can also dispatch a workflow run has not been tried yet.
- Communication with the owner is in German. Everything written into this repository is English.
- The public routes on `xivarsenal.app` belong to the website project and are maintained there. This
  repository never changes them.

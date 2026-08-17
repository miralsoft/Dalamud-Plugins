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

### One red run on 2026-08-17, investigated and left alone

The push at 17:43:04 and the hourly schedule at 17:43:06 started two *Index* runs two seconds
apart on the same commit. The push run was green. The scheduled one reported failure in its last
step, "Fail if a plugin did not refresh", while "Build index" and "Commit if changed" both
succeeded. So one repository could not be refreshed and kept its previous entry, which is the
D-06 path working as designed.

What was checked: the published `pluginmaster.json` carries all three plugins at their newest
releases with pinned links, the public address serves the same, a local build resolves all three,
and the change to `build-index.ps1` in that commit was comment text only. The seven scheduled runs
before it were green.

What could not be checked: which plugin failed and why. The Actions log endpoint answers 403
without an authenticated GitHub CLI, and there is none in the working environment. The reading
that fits the evidence is a transient fetch during the second of two runs seconds apart, but that
is inference, not the log.

Deliberately not re-run: the output is already correct, so a re-run would prove nothing that the
next scheduled run does not prove for free. If `:17` goes red again, it is not transient and the
log has to be read by somebody who can authenticate.

## Foundation adoption

- **Done:** entrypoint replaced with the foundation template (it had been a hand-written rulebook,
  which M-11 and M-12 forbid), seven project files created from `projects/_template/`,
  `.miralsoft-enforcement` written with `OWNER_NAME=Sanaka`, hooks installed, content checks
  mirrored in CI, `scripts/check.ps1` added for R-18, release procedure written for D-01 and D-02,
  and the 42 em-dashes removed from the prose (I-02).
- **Next:** the two items in `open-points.md` that belong to the foundation repository. Neither can
  be closed from here (M-18).

## Handover notes

- The environment this was worked in has no authenticated GitHub CLI. `git push` works through the
  Windows credential manager, but the workflow cannot be dispatched from a session; ask the owner to
  press *Run workflow*, or wait for `:17`.
- Communication with the owner is in German. Everything written into this repository is English.
- The public routes on `xivarsenal.app` belong to the website project and are maintained there. This
  repository never changes them.

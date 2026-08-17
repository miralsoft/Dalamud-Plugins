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
- **Next:** nothing pending. The next change is whatever plugin is added or updated.

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

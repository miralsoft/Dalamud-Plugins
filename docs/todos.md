# To-dos: FFXIV Plugin Index

Purpose: the project to-do list. Checkable items, grouped per code component where applicable.

## Foundation adoption

- [x] Carry the entrypoint from `entrypoints/for-project-repos/` at the root (M-12).
- [x] Create the seven project files from `projects/_template/` (M-02, M-03).
- [x] Configure `.miralsoft-enforcement` and install the hooks (R-08, R-19).
- [x] Mirror the hooks in CI (R-17).
- [x] Remove every em-dash from the prose written here (I-02).
- [x] Provide one command that runs the gates (R-18).
- [x] Write down why this repository cannot protect `main` (D-05, R-16).
- [x] Write the release procedure with both delays and their durations (D-01, D-02).

## Build script

- [ ] Cover the previous-entry fallback with a test (T-01, T-02). It is the one piece of logic here
      whose failure is invisible and expensive, and it has never been exercised on purpose. Blocked
      on the missing PowerShell profile, which is what would name the runner (T-04, M-13). See
      `open-points.md`.
- [ ] Decide whether `AcceptsFeedback` should defer to the manifest instead of being overwritten,
      then either change the script or write the current behaviour down as intended. See
      `open-points.md`.

## Index

- [ ] Resolve the download-link deviation recorded in `decisions.md`, which needs a change in the
      foundation and therefore cannot be closed from here (M-18).

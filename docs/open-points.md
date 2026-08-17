# Open points: FFXIV Plugin Index

Purpose: open questions and unresolved items, grouped per component. Distinct from `todos.md`
(planned work): these are things still to be decided or clarified.

## Belongs to the foundation repository, not to this one

Written down here because a decision made here has a consequence there, and reaching into that
repository is forbidden (M-18). Somebody working in the foundation picks these up.

- **No PowerShell profile exists in `rules/languages/`.** The only code here is
  `scripts/build-index.ps1` plus a check script. M-13 says declaring a language whose profile does
  not exist obliges writing that profile first, and without it C-03 has no linter to point at and
  T-04 has no runner to name. The gap looks like compliance, because every rule that could be
  followed was followed. Until it exists, this project declares no language profile and says so in
  `project.md`.

- **The download-link deviation may not be permissible in the form it was recorded.** See
  `decisions.md`, D-2026-08-17-02. M-14 lets a project depart from a blueprint entry by recording
  it; the rule departed from here sits in a framework profile, and M-01 with M-04 calls a
  contradiction invalid rather than recordable. Either the profile grows a case for an index whose
  entries are regenerated in full on every run, or this repository switches to the redirect. Both
  are outside what a session in this repository can settle alone.

## Build script

- **`AcceptsFeedback` is overwritten rather than inherited.** The script writes the field into every
  entry, defaulting to `true`, so a plugin that opts out in its own manifest has the opt-out undone
  unless `plugins.json` repeats it. Proposal, untried: let the manifest win and treat the field in
  `plugins.json` as an override that only applies when present. Nobody has implemented or tested
  this, and the error handling in that script is deliberate, so it is not a change to make in
  passing.

- **The fallback path has never been exercised on purpose.** When a repository cannot be read, its
  previous entry is carried forward (D-06). That is the most consequential branch in the script and
  the only one whose failure is silent: it would look exactly like a normal run. Testing it needs a
  runner, which needs the profile above.

## Process

- **`main` cannot be protected here, and R-16 asks for pull requests once a product is public.** The
  index workflow commits to `main` by design, so the protection a plugin repository carries is not
  available. The reason is written down in `how-the-index-works.md`, which is what D-05 requires of
  the repository with the weaker rule. What is not decided is whether the hand-maintained files
  (`plugins.json`, the README, these documents) should nevertheless go through pull requests, which
  would be possible without touching the workflow's own pushes.

# FFXIV Plugin Index

<!--
Copied from: miralsoft-foundation-docs, entrypoints/for-project-repos/CLAUDE.md
Foundation version: 3.1.0
Copied on: 2026-08-17
(M-19. Re-copy this file when the declared foundation version in docs/project.md is raised.)
-->

You are working on the `FFXIV Plugin Index`, the aggregate Dalamud plugin index that lists every
FFXIV plugin of miralsoft and builds the list players subscribe to. This file is a signpost, not a
rulebook. The rules are not in this repository; they are in the MIRAL Soft foundation, and they are
read from there rather than copied here.

## The foundation

This project is **external** in the sense of M-12: its documentation lives here in `docs/`, and
nothing is ever written back to the foundation. The foundation is read-only for this repository.

Clone it once, next to nothing else, and pull it at the start of every working session:

```sh
git clone https://github.com/MIRAL-Soft/miralsoft-foundation-docs.git .foundation-docs
cd .foundation-docs && git pull
```

Keep the clone out of this repository through the clone's own exclude file, not through
`.gitignore`:

```sh
echo '.foundation-docs/' >> .git/info/exclude
```

`.git/info/exclude` rather than `.gitignore` on purpose: the exclude file is never committed, so
the arrangement stays a local convenience and does not become a line in a repository that has
nothing to do with it.

## Read in this order, before doing anything

From `.foundation-docs/`:

1. `rules/_meta.md`, the constitution.
2. Every file in `rules/`. They are short.
3. The profiles this project declares in its `docs/project.md`: `rules/frameworks/dalamud.md`. Its
   section "Building and shipping a plugin" is the one that describes this repository's role in the
   chain, so it is not the optional one. This project declares no language profile, and
   `docs/open-points.md` says why.
4. `blueprints/dalamud-plugin.md`. It describes the plugin repositories rather than this one, but
   its section 14 states what they build so that this index works, which is the other half of the
   contract this repository has to hold up.

Then from this repository, in `docs/`:

5. The project memory first: `status.md`, `decisions.md`, `todos.md`, `open-points.md`. This is how
   the previous session hands over, and it is the only handover there is (M-08, I-07).
6. `project.md`, `architecture.md`, `rules-project.md`.

The two working documents, `how-the-index-works.md` and `adding-a-plugin.md`, come after those.

## Enforcement

Install the hooks from the foundation into this clone. They are not part of any repository, so a
fresh clone needs them again:

```sh
cp .foundation-docs/enforcement/hooks/commit-msg .git/hooks/commit-msg
cp .foundation-docs/enforcement/hooks/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/commit-msg .git/hooks/pre-commit
```

`.miralsoft-enforcement` at this repository's root configures them: the committer identity this
project uses (R-03, R-19) and the file patterns checked for em-dashes (I-02). Every check the hooks
perform also runs in CI (R-17), because a hook lives in a clone and gets forgotten.

`./scripts/check.ps1` runs the same gates in one command (R-18).

If a hook blocks a commit, fix the cause. Do not bypass it (R-08).

## While working

- Global rules are binding and read-only. This project may tighten them in `docs/rules-project.md`,
  never weaken or contradict them (M-01, M-04).
- This project is bound by the foundation version it declares in `docs/project.md` (M-17). A rule
  added to the foundation later does not bind it until that declaration is raised. Review the
  declaration whenever a release is cut: read the foundation changelog from the declared version
  onward, then either raise it and do the work, or leave it and record why.
- Update `docs/status.md` at the end of every working session, and append to `docs/decisions.md`
  when something is decided, including the paths that were rejected and why (M-08, M-15).
- An AI is never named as author or co-author, anywhere (R-09, I-06).

No rules are duplicated here. Follow the documents above.

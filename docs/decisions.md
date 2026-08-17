# Decisions: FFXIV Plugin Index

Purpose: append-only decision log. Never edit or delete past decisions, only add new ones. A later
decision may supersede an earlier one, but the history stays (M-08). Rejected paths are recorded
with the reason, not only the path that was taken (M-15).

Each entry: date, decision, short rationale.

## Log

- (2026-08-03) The README is the user-facing page, in English only, with no developer section and no
  link to `docs/`. Rationale: the people who arrive here want the plugin list, not an explanation of
  the machinery, and most of them read English. **Rejected:** a bilingual page, either as two files
  with a language switch or as alternating sections. Two versions drift apart, and alternating
  sections make every reader wade through the half they cannot use. **Rejected:** keeping a small
  footer link to `docs/`; the owner wanted the page free of it, and the documents are reachable
  through the file listing anyway.

- (2026-08-03) The documented public address is `https://xivarsenal.app/plugins.json`. The singular
  `plugin.json` keeps answering the same file permanently and is never handed out. Rationale: the
  first users entered the singular one and would watch their plugin list empty without being told
  why. This is D-15 applied; the plural address was verified live by content type before the change,
  not by status code.

- (2026-08-03) `acceptsFeedback` is repeated in `plugins.json` for Fate Compass. Rationale: its
  manifest sets `AcceptsFeedback: false`, and the index overwrites that field with `true` unless the
  list says otherwise, so without the repetition the plugin's own opt-out is silently undone.
  Whether the script should defer to the manifest instead is open, see `open-points.md`.

- (2026-08-03) Fate Helper was renamed to Fate Compass and the index entry followed. Rationale: the
  official Dalamud repository already ships `FATEhelper`, and Dalamud compares internal names without
  regard to case, so the entry was refused for every user. Worth keeping in mind: pointing the list
  at the renamed repository was not enough. Its newest release was still the build from before the
  rename, so the index resolved cleanly and wrote the old `InternalName` under a green run. The fix
  only took effect once a release carrying the new name was published. This is what X-02 exists for.

- (2026-08-17) The project adopts the MIRAL Soft foundation as an **external** project (M-12) at
  foundation version 3.1.0. Rationale: the sibling plugin repositories already work this way, and
  this repository had been built outside it, which is how a standing owner preference (I-02) came to
  be violated 42 times in files nobody was checking. **Rejected:** adopting only the enforcement and
  leaving the project files out. The hooks would then be the only thing carrying the arrangement,
  and the handover between sessions would keep happening in vendor-specific memory, which I-07
  exists to prevent.

- (2026-08-17) `pluginmaster.json` is listed in `CONTENT_EXCLUDE` and is not checked for em-dashes.
  Rationale: it is generated from the manifests inside the plugin releases, so its prose is quoted
  from elsewhere, which I-02 excepts. Editing it here would falsify what a plugin says about itself
  and would be overwritten by the next run. Where a description needs different wording, the change
  belongs in the plugin repository. **Rejected:** narrowing `CONTENT_GLOBS` to exclude JSON
  altogether, which would also stop checking `plugins.json`, a file that is written by hand here.

- (2026-08-17) **D-2026-08-17-02.** Download links stay pinned to a fixed release tag, which departs
  from `rules/frameworks/dalamud.md`, "Download links point at the 'latest release' redirect, not at
  a tagged path, so the address never changes between releases." Owner decision.

  Answering the reason the profile states: a stable address buys nothing here, because no one holds
  these links. They exist only inside the generated index, which is rewritten in full on every run,
  so the address changing between releases is invisible. What the pinned tag buys is that an entry
  says which release it was built from. That is what made the stale Fate Compass entry legible on
  sight rather than after a download, and it is the evidence X-02 asks a reader to check.

  **Rejected:** switching to the redirect as the profile asks. It was recommended, because the
  original local rationale (that "latest" is ambiguous across several plugins in one repository)
  does not hold when every plugin has its own repository. The owner weighed it and kept the pinned
  links.

  **Unresolved, and deliberately not papered over:** M-14 provides for departing from a *blueprint*
  entry by recording it here. This is a *framework profile*, and M-01 with M-04 says a project rule
  contradicting a global rule is invalid rather than merely recorded. So this entry may not be
  sufficient to make the deviation legitimate. Closing it needs either a change in the foundation,
  which cannot be made from this repository (M-18), or the switch here. Carried in
  `open-points.md`.

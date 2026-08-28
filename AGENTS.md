# Hangeul Puzzle agent guide

This file applies to the entire repository. Read it before changing code, data, UI, tests, or release metadata.

## Start here

1. Read [`README.md`](README.md) for build and test commands.
2. Read [`docs/AGENT_HANDOFF.md`](docs/AGENT_HANDOFF.md) for architecture, data contracts, UI invariants, history, and known debt.
3. For versioning, signing, upload, or review work, read [`docs/RELEASE_RUNBOOK.md`](docs/RELEASE_RUNBOOK.md) in full before changing external state.
4. Inspect `git status`, the current branch, and its upstream. Preserve unrelated user changes.
5. Treat dated GitHub and App Store snapshots as history. Re-query live state before acting.

## Non-negotiable project constraints

- Preserve the existing visual design. The two-syllable puzzle screen is the reference layout for two- and three-syllable puzzles. Do not change colors, type sizes, spacing, component sizes, wording, or interaction styling unless the task explicitly asks for that exact change.
- Keep normal two- and three-syllable, 12-candidate puzzles on the centered layout. Retain the scroll fallback for longer words or nonstandard candidate counts.
- The bundled dataset contract is currently 1,500 unique words: 1,000 two-syllable and 500 three-syllable entries. JSON keys are exactly `id`, `word`, `english`, and `pron`.
- IDs are identifiers, not array indices. ID `115` is intentionally absent and the current maximum ID is `1501`; do not renumber records just to make IDs contiguous.
- UI regression fixtures are word ID `1` (`우리`) and ID `1002` (`가습기`). Preserve them or update the corresponding UI tests in the same scoped change.
- Puzzle correctness is multiset-based. A shared candidate grid must contain the maximum required multiplicity of each jamo across any one syllable, not the total multiplicity across the full word.
- Never commit App Store private keys, credentials, provisioning material, IPA/archive output, personal review contact details, or machine-specific secret paths. Use Keychain and placeholders in documentation.
- `agent/release-1.0.7` is historical preservation only. It is superseded by the released 1.0.8 code and must not be merged or cherry-picked into `main`.

## Validation expectations

- Swift changes: run strict `swift-format`, an unsigned Simulator build, and the relevant unit/UI tests.
- Puzzle generation or data changes: run the complete bundled-dataset solvability test, not only a sample.
- Puzzle layout changes: run the two-versus-three-syllable UI regression test and inspect its screenshots.
- Documentation-only changes: at minimum run `git diff --check`, verify referenced repository paths, and scan the diff for credentials or local absolute paths.
- CI is the canonical clean-environment check. It runs on both pushes and pull requests, so duplicate workflow runs are expected.

## Git and review conventions

- Keep commits grouped by function. Version/build bumps are separate from functional changes.
- Prior pull requests used the sections `Outline`, `Work Contents`, and `Trouble Point`, with nested `Trouble Situation` and `Trouble Shooting` sections where relevant.
- Prior feature pull requests were opened ready for review, without labels, and merged with ordinary merge commits after CI passed.
- Do not create tags unless explicitly requested; this repository currently has no Git tags or GitHub Releases.

## Release guardrails

- App Store Connect app ID: `1634394239`
- Bundle ID: `edu.coin.Hangeul`
- Apple Developer team ID used for releases: `5N5TS7Y4MA`
- As of 2026-08-28, version 1.0.8 build 3 is approved and available for distribution. The next upload must use a new version/build combination, normally 1.0.9 or later and build 4 or later after checking live state.
- The project intentionally does not pin `DEVELOPMENT_TEAM`; provide it during archive or select the correct team in Xcode.
- Retain `ITSAppUsesNonExemptEncryption = NO` only while the app continues not to use non-exempt encryption.
- With `asc` 0.38.1, `asc validate` can fail on a valid released version because the API omits `ageRatingDeclaration`. Handle only that exact known failure as a CLI compatibility issue, verify every other release field separately, and always confirm the final submission state.

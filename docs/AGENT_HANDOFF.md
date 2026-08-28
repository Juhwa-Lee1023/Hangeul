# Hangeul Puzzle agent handoff

Last audited: 2026-08-28 (Asia/Seoul)

This is the durable context for future maintainers and coding agents. It records the architecture, invariants, testing strategy, historical decisions, and repository state that were established while refactoring the original hard-coded puzzle implementation, expanding the dataset, and fixing the three-syllable layout. Live GitHub and App Store state can change; re-query it before taking an external action.

## 1. Product and scope

Hangeul Puzzle is a SwiftUI iPhone app originally recognized as a WWDC 2022 Swift Student Challenge winner. It teaches Hangul by asking the player to select the compatibility-jamo tiles that compose each syllable in a Korean word.

The app is intentionally small and local-first:

- No backend, user account, analytics SDK, or network connection is required to play.
- Words and meanings come from the bundled `Assets/data.json` file.
- Puzzle candidates and answers are generated algorithmically at runtime.
- Korean pronunciation uses `AVSpeechSynthesizer`; feedback effects are bundled audio files.
- There are no Swift Package Manager or CocoaPods dependencies.

The strongest product constraint from the owner is: **do not redesign the app**. When a three-syllable layout bug was fixed, the existing two-syllable screen was used as the visual reference and its colors, sizes, spacing, fonts, and button design were deliberately preserved.

## 2. Implementation history and current baseline

The original project stored puzzle-specific logic in a hard-coded form. The completed work split generation, session state, data loading, UI, and audio into separately testable responsibilities.

| Change | Pull request | Key commit(s) | Result |
|---|---:|---|---|
| Algorithmic puzzle generation and session refactor | [#9](https://github.com/Juhwa-Lee1023/Hangeul/pull/9) | `3758370`, `9688bea`, merge `70e57e1` | Runtime Hangul decomposition, repository validation, reusable puzzles, CI |
| Dataset expansion and full solvability verification | [#10](https://github.com/Juhwa-Lee1023/Hangeul/pull/10) | `4bc5a6f`, merge `5b58f37` | 1,500 words: 1,000 two-syllable + 500 three-syllable; exhaustive test |
| Three-syllable layout aligned to two-syllable design | [#11](https://github.com/Juhwa-Lee1023/Hangeul/pull/11) | `ae59dfb`, `681f998`, merge `0813f68` | Shared centered layout, frame-comparison UI regression, version 1.0.8 (3) |

The implementation baseline before these handoff documents was `main` at `0813f685d0bd6430bfdb550052c833e9cc2230aa`. Clone or fetch `origin/main`; do not use an old laptop branch as the source of truth.

The local-only release branch `agent/release-1.0.7` was preserved on the remote during handoff because it contained one otherwise-unpublished historical commit, `a42fca7`. Its 1.0.7 (2) settings are fully superseded by 1.0.8 (3). It is an archive only and must never be merged or cherry-picked into `main`.

## 3. Architecture map

```text
HangeulApp
└── RootView
    ├── GameSession ──loads──> WordRepository ──decodes──> Assets/data.json
    │      └──creates──> HangulPuzzle ──uses──> HangulDecomposer
    ├── AudioService ──> AVSpeechSynthesizer + bundled effects
    └── route
        ├── welcome   ──> WelcomeView
        ├── playing   ──> PuzzleView + PuzzleComponents
        ├── completed ──> ClearView ──sheet──> LettersView
        └── failure   ──> ErrorStateView
```

### Key files

| Path | Responsibility |
|---|---|
| [`Hangeul/HangeulApp.swift`](../Hangeul/HangeulApp.swift) | Application entry point; presents `RootView` |
| [`Hangeul/RootView.swift`](../Hangeul/RootView.swift) | Creates `GameSession` and `AudioService`; maps route state to screens |
| [`Hangeul/GameSession.swift`](../Hangeul/GameSession.swift) | Loads words, selects rounds, owns route/current puzzle/completed puzzles |
| [`Hangeul/HangulPuzzle.swift`](../Hangeul/HangulPuzzle.swift) | Word model, Unicode decomposition, candidate generation, answer checking |
| [`Hangeul/WordRepository.swift`](../Hangeul/WordRepository.swift) | Bundle JSON loading and dataset validation |
| [`Hangeul/PuzzleView.swift`](../Hangeul/PuzzleView.swift) | Per-puzzle selection state and player actions |
| [`Hangeul/PuzzleComponents.swift`](../Hangeul/PuzzleComponents.swift) | Shared word card, progress row, candidate and action components, error view |
| [`Hangeul/AudioService.swift`](../Hangeul/AudioService.swift) | Korean TTS and local sound-effect playback |
| [`Hangeul/ClearView.swift`](../Hangeul/ClearView.swift) | Completion layout, solved-word display, restart, Letters sheet |
| [`Hangeul/LettersView.swift`](../Hangeul/LettersView.swift) | Hangul letter reference sheet |
| [`Assets/data.json`](../Assets/data.json) | Bundled puzzle words and English metadata |
| [`HangeulTests`](../HangeulTests) | Decomposition, generation, repository, session, and exhaustive data tests |
| [`HangeulUITests`](../HangeulUITests) | End-to-end gameplay and two/three-syllable layout regression tests |
| [`.github/workflows/ci.yml`](../.github/workflows/ci.yml) | Strict formatting, build, full tests, coverage artifact |

## 4. Game lifecycle

`RootView` holds one `GameSession` and one `AudioService` for the app view hierarchy. `GameSession.route` determines the current screen:

1. Initialization calls `WordRepository.load()` unless tests inject words directly.
2. A successful load enters `.welcome`; a load/validation error enters `.failure(message)`.
3. `startGame()` removes duplicate spellings defensively, selects up to the requested round count, builds a `HangulPuzzle` for each word, and enters `.playing`.
4. Production selection shuffles words. Deterministic selection sorts by ID for UI tests.
5. `PuzzleView` owns transient selection/progress state for one puzzle.
6. `completeCurrentPuzzle()` appends the current puzzle, moves to the next one, or enters `.completed`.
7. Restart builds a fresh session sequence without leaving stale indices visible to the completion screen.

The default session is five rounds. If fewer valid words are injected in a test, the round count is capped rather than indexing past the array.

### UI-test launch arguments

- `--ui-testing` enables deterministic word ordering.
- `--ui-testing-word-id=<id>` selects one exact fixture **only when** `--ui-testing` is also present.
- Without `--ui-testing`, the ID argument is intentionally ignored so a production-like launch cannot be silently pinned to a test word.

## 5. Hangul decomposition and puzzle rules

### Supported input

`HangulDecomposer` supports modern precomposed Hangul syllables only: Unicode `U+AC00...U+D7A3`. Each character must consist of one scalar in that range. Empty words and decomposed jamo/non-Hangul characters are rejected.

The Unicode offset is split using the standard 19 initial consonants, 21 medial vowels, and 28 final positions (empty plus 27 non-empty finals):

```text
offset       = scalar - 0xAC00
initialIndex = offset / (21 × 28)
medialIndex  = (offset % (21 × 28)) / 28
finalIndex   = offset % 28
```

The result uses compatibility jamo strings such as `ㄱ`, `ㅏ`, and `ㄴ`, matching the existing tile design.

### Shared candidate grid

One candidate grid is shared across every syllable in a word. The default grid contains 12 positions.

The subtle requirement is multiplicity. For every jamo value, generation keeps the **maximum count required by any one syllable**, not the sum over all syllables. For example, if two different syllables each need one `ㄱ`, the player can reuse the same on-screen `ㄱ` position when advancing between syllables. If one syllable needs a repeated value, enough duplicate positions must exist for that syllable.

Generation then:

1. Decomposes all syllables.
2. Builds the maximum-per-syllable required multiset in stable jamo order.
3. Fills to at least the requested candidate count with distractors.
4. Excludes every answer jamo value from the distractor pool.
5. Prefers distinct distractors, reusing them only if an unusually large grid exhausts the full pool.
6. Shuffles candidates.

Production uses `SystemRandomNumberGenerator`. Tests can inject a seeded generator for reproducibility.

### Correctness

Answers are compared as multisets of jamo values, not tile-position identity. This makes separate candidate positions containing the same jamo interchangeable. Index-based checking rejects:

- An invalid syllable index.
- Any out-of-range candidate index.
- Repeating the same candidate position twice.
- A selection with the wrong value multiplicity.

Do not replace this with a `Set` equality check: sets lose repeated-jamo counts.

## 6. Dataset contract

`Assets/data.json` is a top-level array. Every entry must decode to exactly these maintained fields:

```json
{
  "id": 1,
  "word": "우리",
  "english": "We",
  "pron": "uri"
}
```

Current audited shape:

| Property | Value |
|---|---:|
| Records | 1,500 |
| Two-syllable words | 1,000 |
| Three-syllable words | 500 |
| Minimum ID | 1 |
| Maximum ID | 1,501 |
| Deliberately missing ID | 115 |
| Two-syllable UI fixture | ID 1, `우리` |
| Three-syllable UI fixture | ID 1002, `가습기` |

`WordRepository` rejects:

- An absent `data.json` resource.
- An empty array.
- Duplicate IDs.
- Duplicate Korean spellings.
- Empty or whitespace-only `word`, `english`, or `pron` values.
- Any word that cannot be decomposed by `HangulDecomposer`.

Important maintenance rules:

- Treat IDs as opaque stable identifiers. Never use `id - 1` as an array index.
- Do not fill the ID 115 gap or renumber the dataset merely for aesthetics; fixtures and history depend on stable IDs.
- Preserve unique Korean spelling even when English meanings or romanizations are similar.
- Update exact-count/distribution tests deliberately if product scope changes.
- Run the exhaustive generation-and-solution test after every dataset or jamo-rule edit.

## 7. UI and design invariants

### Layout behavior

`PuzzleView.usesOriginalLayout` is true when:

- The word has two or three syllables; and
- The grid has the default 12 candidates.

That path renders the established centered `VStack` without wrapping the whole puzzle in a vertical `ScrollView`. Longer words or nonstandard candidate counts keep a vertical scroll fallback.

`SyllableProgressRow` similarly uses a normal centered `HStack` for up to three syllables. Four or more syllables use a horizontal `ScrollView` and auto-scroll the current syllable into view.

This split is intentional. Before PR #11, three-syllable content took both scroll paths and appeared substantially higher than the two-syllable screen. On the iPhone 17 Pro regression environment, the word-card origin was approximately y=62 for three syllables versus y=104.33 for two syllables. After the fix, the tested frames match.

### Existing visual system

- Colors come from asset names `background`, `button`, `buttontext`, `plus`, and `clean` through `AppColors`.
- Most sizing is proportional to `UIScreen.main.bounds`, preserving the original implementation.
- Candidate rows contain four positions, and normal candidate tiles use `screenHeight × 0.09` square frames.
- `WordCard` uses a large word size, `minimumScaleFactor(0.35)`, tightening, and at most two lines.
- The regression fixture `가습기` is required to stay on one line in the tested layout.
- The app targets iPhone portrait, not iPad or landscape.

When fixing layout, prefer tightening the conditional layout path and adding frame assertions over changing design constants. Any true redesign should be a separately approved task with updated screenshots/tests.

### Puzzle interaction state

`PuzzleView` tracks:

- Current syllable index.
- Solved syllable indices.
- Selected candidate indices.
- Mismatch alert visibility.
- Whether the full word is complete.

`CONFIRM` checks the current syllable. A mismatch clears selection, plays the error effect, and shows the alert. A correct syllable advances; a completed word reveals its meaning and changes actions to listen/`NEXT`. Completed grids display every candidate whose value belongs to the word's answer set and block further tile interaction.

### Stable accessibility identifiers

UI tests and future automation rely on identifiers including:

- `start-game`, `restart-game`, `completion-card`
- `word-audio`, `word-meaning`, `puzzle-instruction`
- `candidate-0` through the last candidate index
- `action-clean`, `action-listen`
- `confirm-selection`, `next-puzzle`
- `solved-word-<id>` on completion cards
- `syllable-<section>-<index>` in `LettersView`

Puzzle progress buttons are located by their dynamic accessibility labels (`Current syllable ...`, `Solved syllable ...`, or `Pending syllable ...`) rather than a dedicated identifier.

Treat identifier changes as test/API changes; update automation in the same commit.

## 8. Audio behavior

`AudioService` owns its `AVSpeechSynthesizer` for the lifetime of the service. Do not move it back to a function-local variable: an older implementation allowed the synthesizer to be released before speech completed on iOS 16.

- TTS language: `ko-KR`.
- Before speaking new text, current speech is stopped.
- Repeating the same text within three seconds uses the intentionally slow rate `0.1`; otherwise the normal configured rate is used.
- Effects map to bundled resource names: success → clear sound, error → dding sound, next → next sound.
- Missing voices/effects fail gracefully and log only in DEBUG builds.

There is no dedicated success-effect call in the current per-syllable confirmation path; verify intended audio behavior before changing it.

## 9. Completion screen

`ClearView` receives completed puzzles. It displays them in reverse completion order: the newest solved word receives the prominent first position and earlier words are arranged in paired rows. It also presents:

- A restart action.
- A Letters reference sheet.
- Audio actions for solved words.

Be careful about resetting session arrays during route transitions. An older iOS 16.1 crash occurred when restart emptied the original puzzle array while a completion view still accessed an old index. The current state model and tests avoid this; do not reintroduce force indexing during reset.

## 10. Tests and CI

### Unit/integration coverage

[`HangeulTests/HangulPuzzleTests.swift`](../HangeulTests/HangulPuzzleTests.swift) covers:

- Unicode decomposition with and without final consonants.
- Empty/unsupported input errors.
- Candidate size, distractor exclusions, duplicate multiplicity, and seeded generation.
- Multiset correctness, interchangeable duplicate-valued positions, and invalid index rejection.
- Three-syllable generation.

[`HangeulTests/HangeulTests.swift`](../HangeulTests/HangeulTests.swift) covers:

- JSON key/schema expectations and repository failures.
- Exact 1,500/1,000/500 data counts.
- 12 candidates for every bundled word.
- Exhaustive solvability: every one of the 1,500 words and all 3,500 syllables are solved using distinct matching tile indices and verified through `isCorrect`.
- Five-round selection, round capping, completion, restart, reload, and failure behavior.

### UI coverage

[`HangeulUITests/HangeulUITests.swift`](../HangeulUITests/HangeulUITests.swift) covers:

- Deterministic five-round completion using IDs 1–5 (`우리`, `사랑`, `웃음`, `안녕`, `한글`).
- Candidate selection cleanup and mismatch behavior.
- Two-versus-three-syllable frame comparison using IDs 1 and 1002.
- Equal frames for the word card, instruction, all 12 candidate tiles, and actions.
- Progress tile sizes, vertical position, centering, spacing, and non-overlap.
- Screenshot attachments for visual regression evidence.
- Welcome-screen launch behavior.

The full local run associated with PR #11 reported 29 passing tests. Do not hard-code that number into new automation because the suite can grow.

### CI contract

The workflow runs on every push and pull request using `macos-latest`, with a 30-minute timeout:

1. Strict recursive `swift-format` lint.
2. Dynamic selection and boot of the latest available iPhone Simulator; no fixed device name/runtime.
3. Unsigned generic Simulator build.
4. Full test run with code coverage.
5. Upload of `.xcresult` and JSON coverage artifacts for 14 days, even on failure when artifacts exist.

Runner temporary paths are assigned at step scope. A previous CI failure came from evaluating `${{ runner.temp }}` too early at job scope; do not move these paths back without verifying expression timing.

The 2026-08-28 handoff run [#33149380807](https://github.com/Juhwa-Lee1023/Hangeul/actions/runs/33149380807) passed format, build, the complete test suite, coverage export, and artifact upload. GitHub emitted a non-blocking maintenance warning that `actions/checkout@v4` and `actions/upload-artifact@v4` still target Node.js 20 and were being forced onto Node.js 24. Re-check for supported newer action majors and upgrade them in a separately verified CI-maintenance change; do not suppress the warning or blindly change action versions.

Local CoreSimulator has occasionally stalled or failed to install the test app. First retry with a clean booted available iPhone and wait for `simctl bootstatus -b`. If the host simulator remains unreliable, GitHub CI is the clean-environment authority rather than a reason to weaken tests.

Build, test, and format commands are maintained in [`README.md`](../README.md).

## 11. GitHub workflow and conventions

Repository: [Juhwa-Lee1023/Hangeul](https://github.com/Juhwa-Lee1023/Hangeul)

- Default branch: `main`.
- No Git tags or GitHub Releases existed at the handoff audit.
- PRs #9, #10, and #11 are merged; there were no open PRs at audit time.
- Existing feature branches remain on the remote. Their content is already merged; do not create duplicate PRs.
- The ignored root `.DS_Store` is local noise and must not be committed.

Preferred commit boundaries:

- Functional implementation.
- Tests coupled to that function when inseparable, or a dedicated test commit when it tells a clearer story.
- Dataset expansion/maintenance.
- Version and build-number bump.
- Documentation/runbook changes.

Prior PR descriptions used this structure:

```markdown
## Outline

## Work Contents

## Trouble Point

### 1. ...

- **Trouble Situation**
- **Trouble Shooting**
```

The owner previously requested ready-for-review PRs with no labels. The repository's recent PRs used normal merge commits after CI passed. Re-check the exact request each time; do not infer permission to open, merge, tag, or release from a code-only task.

New machines need fresh GitHub authentication and Git author configuration. Credentials were stored in the old macOS keyring and are not part of the repository.

## 12. App Store handoff summary

Detailed commands and safety checks live in [`RELEASE_RUNBOOK.md`](RELEASE_RUNBOOK.md).

Audited 2026-08-28:

- App Store Connect app ID `1634394239`; bundle `edu.coin.Hangeul`.
- Version 1.0.8, build 3 is `VALID` and approved.
- App Store state is `READY_FOR_SALE`; version state is `READY_FOR_DISTRIBUTION`.
- Submission is complete and no review is in flight.
- English (U.S.) release notes describe the three-syllable layout fix.
- Ten inherited screenshots were complete: five 5.5-inch and five 6.5-inch iPhone screenshots.
- The project sets version 1.0.8/build 3 in both app configurations and declares `ITSAppUsesNonExemptEncryption = NO`.
- `DEVELOPMENT_TEAM` is intentionally not persisted in the project; releases have used team `5N5TS7Y4MA` through archive arguments/automatic signing.

The App Store snapshot is evidence, not a future instruction. Query live state before selecting the next version/build or starting a submission.

## 13. Known debt and deliberately untouched behavior

These issues were noticed but intentionally left out of layout/data work to avoid unrequested design or copy changes:

- `Pick all the Lettes for This Box.` contains `Lettes`.
- The mismatch alert button says `RETRUN`.
- Some welcome-screen English grammar could be improved.
- `PuzzleView.roundNumber` and `totalRounds` are passed in but not displayed or otherwise used.
- Layout constants depend on global `UIScreen` dimensions rather than `GeometryReader`/size classes.
- Four-or-more-syllable and non-12-candidate modes have fallbacks but are not part of the current 1,500-word product dataset.
- App Store phased-release reporting was inconsistent in `asc` 0.38.1: the aggregate status claimed it was configured while the dedicated query returned no object. Verify in the web console before relying on either result.

Copy fixes, responsive redesign, round indicators, longer-word product support, and accessibility refinements should be separately scoped changes with deliberate test/baseline updates.

## 14. Historical bug lessons

- Keep the TTS synthesizer alive as a service property so iOS does not end speech early.
- Avoid stale indices when resetting game arrays during screen transitions.
- Prefer `indices.contains`, `first`, and optional current state to force indexing; the project has prior index-error fixes.
- Do not pin a particular Simulator model/runtime in CI.
- Do not evaluate runner temporary directories in an expression scope where they are unavailable.
- A passing sample puzzle is not sufficient evidence for a data change; the exhaustive solvability test exists because candidate multiplicity failures can be word-specific.
- For a layout fix, compare two- and three-syllable frames rather than only checking that elements exist.

## 15. New-machine continuation checklist

1. Clone the GitHub repository and switch to an up-to-date `origin/main`.
2. Configure Git author details and authenticate GitHub CLI again.
3. Install the latest stable Xcode suitable for the project; open once to accept licenses/components.
4. Run strict formatting, Simulator build, and the complete test suite from the README.
5. Confirm the 1,500-record dataset and two/three-syllable tests pass before modifying data generation.
6. If release work is needed, provision a valid App Store Connect API key in the new machine's System Keychain; do not copy secret material into the repository.
7. Confirm Xcode automatic signing for team `5N5TS7Y4MA` and query live App Store status.
8. Read the release runbook fully before incrementing versions, uploading, or submitting.

At the end of any future task, update these documents when an invariant, fixture, workflow, release tool, or operational fact materially changes.

# Hangeul Puzzle App Store release runbook

Last verified with local tooling: 2026-08-28 (Asia/Seoul)

This runbook is for versioning, archiving, uploading, and submitting Hangeul Puzzle. Read the entire document before changing App Store Connect. Commands were verified against `asc` 0.38.1; it is an unofficial CLI and its syntax/API behavior can change, so check `asc --version` and command help on the machine performing the release.

## 1. Application identity and audited state

| Field | Value |
|---|---|
| App | Hangeul Puzzle |
| App Store Connect app ID | `1634394239` |
| Bundle ID | `edu.coin.Hangeul` |
| Apple Developer team ID | `5N5TS7Y4MA` |
| Platform | iOS, iPhone, portrait |
| Minimum OS | iOS 14.0 |
| Public page | [App Store](https://apps.apple.com/kr/app/hangeul-puzzle/id1634394239) |
| App Store Connect | [App page](https://appstoreconnect.apple.com/apps/1634394239) |
| TestFlight | [iOS builds](https://appstoreconnect.apple.com/apps/1634394239/testflight/ios) |
| Review | [Review page](https://appstoreconnect.apple.com/apps/1634394239/appstore/review) |

Audited live state on 2026-08-28:

- Version 1.0.8, build 3.
- Build ID `e070b000-330e-4666-9576-f25534c0d85f`, processing state `VALID`.
- App Store version ID `57be8270-25b7-472f-8b2e-288a2b2ed864`.
- Submission ID `4f96aa29-e9e7-4e02-b49e-9f24a202c02c`, state `COMPLETE`.
- App status `READY_FOR_SALE`; version status `READY_FOR_DISTRIBUTION`.
- No submission in flight and no reported blocker; aggregate release health was green.
- Locale `en-US`; release note: `Fixed the three-syllable puzzle layout to match the two-syllable puzzle design.`
- Ten complete screenshots: five `APP_IPHONE_55` and five `APP_IPHONE_65`.
- Project build settings also say 1.0.8/build 3 and `ITSAppUsesNonExemptEncryption = NO`.

This snapshot will become stale. Do not reuse its version/build decision without a live query. The normal next values would be version 1.0.9 or later and build 4 or later, but App Store Connect is authoritative.

The historical `agent/release-1.0.7` branch exists only to preserve an old local commit. Version 1.0.8 has superseded it. Never release, merge, or cherry-pick from that branch.

## 2. Secrets and authentication

### Never store these in Git

- App Store Connect `.p8` private keys or their contents.
- API credentials in `.env`, `.asc/config.json`, shell scripts, documentation, or command transcripts committed to the repository.
- Distribution certificates, provisioning profiles, `.ipa`, `.xcarchive`, or exported signing material.
- App Review personal contact details or demo-account credentials.
- Machine-specific private-key paths.

The repository `.gitignore` excludes common build/archive output, but ignore rules are only a backup. Inspect every staged file before committing.

### New-machine authentication

Obtain a valid App Store Connect API key through a secure channel. If the old private key cannot be securely transferred, create a new key under App Store Connect → Users and Access → Integrations. A private key may only be downloadable once. Verify the new key before revoking an old one.

Store credentials in the macOS System Keychain rather than a repo-local config:

```sh
asc auth login \
  --name "<profile-name>" \
  --key-id "<key-id>" \
  --issuer-id "<issuer-id>" \
  --private-key "$ASC_PRIVATE_KEY_PATH" \
  --network

asc auth status --validate
asc auth doctor
```

Do not use `--local` for this repository. Do not use `asc auth doctor --fix --confirm` during diagnosis unless a specific state change has been reviewed and approved.

For GitHub on a new machine, separately configure the Git author and run `gh auth login`; credentials from the retired laptop are not in this repository.

## 3. Release preflight

### Confirm source control

Start from a clean, current default branch. Create a release branch when a code/version change will be reviewed through a PR.

```sh
git fetch origin --prune
git switch main
git pull --ff-only origin main
git status --short --branch
```

Confirm all intended functional PRs are merged and CI passed. Do not archive an unreviewed working tree or an already-merged feature branch.

### Confirm external state before choosing numbers

```sh
asc --version
asc auth status --validate
asc status \
  --app 1634394239 \
  --include app,builds,appstore,submission,review,links \
  --output json \
  --pretty

asc builds list \
  --app 1634394239 \
  --processing-state all \
  --sort=-uploadedDate \
  --limit 20 \
  --output table
```

Check for:

- Any in-flight review or incomplete previous submission.
- The latest used marketing version and build number.
- Builds still processing or failed.
- A version already created with the proposed version string.
- Agreements, compliance, metadata, screenshot, or review blockers.

Do not cancel or replace a submission just because an older note says it was waiting. The 1.0.7 and 1.0.8 submissions are already complete.

### Select and commit the version

Update both Debug and Release app-target occurrences in `Hangeul.xcodeproj/project.pbxproj`:

- `MARKETING_VERSION`
- `CURRENT_PROJECT_VERSION`

Keep `ITSAppUsesNonExemptEncryption = NO` only if the app still uses no non-exempt encryption. Keep the version/build bump in its own commit, separate from the functional fix.

Verify the effective settings rather than trusting a text edit:

```sh
xcodebuild \
  -project Hangeul.xcodeproj \
  -scheme Hangeul \
  -configuration Release \
  -showBuildSettings | \
  rg 'PRODUCT_BUNDLE_IDENTIFIER|MARKETING_VERSION|CURRENT_PROJECT_VERSION|IPHONEOS_DEPLOYMENT_TARGET|CODE_SIGN_STYLE|DEVELOPMENT_TEAM'
```

The project intentionally does not persist `DEVELOPMENT_TEAM`. Select the correct team in Xcode or pass `DEVELOPMENT_TEAM=5N5TS7Y4MA` to archive.

## 4. Quality gate before archive

Run the commands maintained in [`README.md`](../README.md):

1. Strict recursive Swift formatting check.
2. Unsigned generic iOS Simulator build.
3. Full unit and UI test suite with coverage on an available iPhone Simulator.
4. `git diff --check` and a review of every staged file.

For any puzzle data/generation change, confirm the exhaustive 1,500-word solvability test ran. For layout changes, confirm the ID 1 versus ID 1002 UI regression and its screenshots.

Also manually smoke-test on a supported iPhone Simulator or device:

- Welcome → start.
- Two-syllable selection, mismatch, clean, confirm, and audio.
- Three-syllable layout and progress.
- Five-round completion, Letters sheet, and restart.
- Korean TTS and all effect files.

CI is required evidence, but audio and final visual appearance still deserve a manual check.

## 5. Archive

Use a newly created, explicit temporary directory. Do not reuse an archive from another commit or release.

```sh
RELEASE_DIR="$(mktemp -d /tmp/HangeulRelease.XXXXXX)"
ARCHIVE_PATH="$RELEASE_DIR/Hangeul.xcarchive"
EXPORT_PATH="$RELEASE_DIR/export"

xcodebuild \
  -project Hangeul.xcodeproj \
  -scheme Hangeul \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath "$ARCHIVE_PATH" \
  -derivedDataPath "$RELEASE_DIR/ArchiveDerivedData" \
  -allowProvisioningUpdates \
  -authenticationKeyPath "$ASC_PRIVATE_KEY_PATH" \
  -authenticationKeyID "$ASC_KEY_ID" \
  -authenticationKeyIssuerID "$ASC_ISSUER_ID" \
  DEVELOPMENT_TEAM='5N5TS7Y4MA' \
  archive
```

The authenticated archive path above matches the previously successful release approach. If the machine is correctly signed into the Apple Developer account in Xcode, automatic provisioning may work without the three `-authenticationKey...` arguments; do not mix approaches without understanding which credentials Xcode is using.

### Verify the archive

Inspect the archived app, not only the project file:

```sh
APP_PATH="$ARCHIVE_PATH/Products/Applications/Hangeul.app"

plutil -p "$APP_PATH/Info.plist"
codesign -dvv "$APP_PATH"
jq length "$APP_PATH/data.json"
test -x "$APP_PATH/Hangeul"
```

Confirm:

- `CFBundleIdentifier` is `edu.coin.Hangeul`.
- `CFBundleShortVersionString` and `CFBundleVersion` exactly match the committed values.
- `MinimumOSVersion` remains expected.
- `ITSAppUsesNonExemptEncryption` is false when appropriate.
- `codesign` reports team identifier `5N5TS7Y4MA`.
- `data.json` is present and contains 1,500 records.
- The executable and expected audio/assets are present.

Stop if any value differs. Do not rely on App Store upload tooling to silently repair version or signing metadata.

## 6. Export the IPA

Create an `ExportOptions.plist` outside the repository with these values:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>destination</key>
    <string>export</string>
    <key>manageAppVersionAndBuildNumber</key>
    <false/>
    <key>method</key>
    <string>app-store-connect</string>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>teamID</key>
    <string>5N5TS7Y4MA</string>
    <key>uploadSymbols</key>
    <true/>
</dict>
</plist>
```

`manageAppVersionAndBuildNumber=false` is important. The default can allow Xcode to change the uploaded build number so it no longer matches Git.

Export with the same authentication mode used for archive:

```sh
xcodebuild \
  -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportPath "$EXPORT_PATH" \
  -exportOptionsPlist "$RELEASE_DIR/ExportOptions.plist" \
  -allowProvisioningUpdates \
  -authenticationKeyPath "$ASC_PRIVATE_KEY_PATH" \
  -authenticationKeyID "$ASC_KEY_ID" \
  -authenticationKeyIssuerID "$ASC_ISSUER_ID"
```

Expand the IPA into another exact temporary directory and repeat the bundle/version/build/data/executable checks on `Payload/Hangeul.app`. Keep the archive, IPA, and verification logs only long enough to finish and diagnose the release. Move them to a controlled private archive or trash them after verifying the exact path; never add them to Git.

## 7. Upload and wait for processing

Set non-secret release values for the current run:

```sh
ASC_APP_ID=1634394239
NEW_VERSION="<new-marketing-version>"
NEW_BUILD="<new-build-number>"
IPA_PATH="$EXPORT_PATH/Hangeul.ipa"
```

Upload only after the IPA inspection passes:

```sh
asc builds upload \
  --app "$ASC_APP_ID" \
  --ipa "$IPA_PATH" \
  --version "$NEW_VERSION" \
  --build-number "$NEW_BUILD" \
  --platform IOS \
  --wait \
  --poll-interval 30s \
  --output json \
  --pretty
```

Query the exact processed build and require `VALID`:

```sh
asc builds list \
  --app "$ASC_APP_ID" \
  --version "$NEW_VERSION" \
  --build-number "$NEW_BUILD" \
  --processing-state VALID \
  --output json \
  --pretty
```

Do not create or submit an App Store version while the build is `PROCESSING`, `FAILED`, or `INVALID`.

## 8. Create the App Store version and metadata

Use the previous public version as a metadata source, but exclude `whatsNew` so stale release notes are not copied:

```sh
VERSION_JSON="$(asc versions create \
  --app "$ASC_APP_ID" \
  --version "$NEW_VERSION" \
  --platform IOS \
  --release-type AFTER_APPROVAL \
  --copy-metadata-from "<previous-public-version>" \
  --exclude-fields whatsNew \
  --output json)"

VERSION_ID="$(printf '%s' "$VERSION_JSON" | jq -er '.data.id')"
```

Update the `en-US` release notes with a short user-facing summary of the actual change:

```sh
asc localizations update \
  --version "$VERSION_ID" \
  --locale en-US \
  --whats-new "<release notes>" \
  --output json \
  --pretty
```

Retrieve App Review contact values from an approved secure source and create or update review details. Do not paste personal contact information into this repository. No demo account is required because the app has no login.

Confirm localization and screenshots:

```sh
asc localizations list \
  --version "$VERSION_ID" \
  --locale en-US \
  --output json \
  --pretty

asc screenshots list \
  --version-localization "<localization-id>" \
  --output json \
  --pretty
```

Do not assume screenshots copied successfully. Verify their state and device families. The 1.0.8 reference set had five 5.5-inch and five 6.5-inch iPhone images; replace or supplement them if current App Store requirements or the product UI have changed.

## 9. Attach, validate, and submit

Resolve the exact build ID from the `VALID` build response, then attach it:

```sh
asc versions attach-build \
  --version-id "$VERSION_ID" \
  --build "$BUILD_ID" \
  --output json \
  --pretty
```

### `asc validate` 0.38.1 compatibility issue

In the audited environment, `asc validate` failed even for the already approved 1.0.7 version with:

```text
failed to fetch age rating declaration: relationship 'ageRatingDeclaration' does not exist
```

This exact message appears to be an `asc`/App Store API compatibility problem, not evidence that the app lacks a valid age rating. It must not be the sole release gate. Still run validation when useful, and treat every other error as actionable:

```sh
asc validate \
  --app "$ASC_APP_ID" \
  --version "$NEW_VERSION" \
  --platform IOS \
  --strict
```

If and only if the exact known age-rating relationship error occurs, separately verify in App Store Connect that:

- The build is `VALID` and attached to the intended version.
- Release notes/localization are correct.
- Screenshots are complete.
- App Review details are complete.
- Age rating, privacy, compliance, pricing/availability, agreements, and other blockers are satisfied.
- `asc status` reports no unrelated blockers.

Submit using the exact version and build IDs:

```sh
asc submit create \
  --app "$ASC_APP_ID" \
  --version-id "$VERSION_ID" \
  --build "$BUILD_ID" \
  --confirm \
  --output json \
  --pretty
```

Immediately verify:

```sh
asc status \
  --app "$ASC_APP_ID" \
  --include app,builds,appstore,submission,review,links \
  --output json \
  --pretty
```

A successful new submission should show an in-flight review, the intended version/build, a review item, and an appropriate state such as `WAITING_FOR_REVIEW`. Never report completion based only on a successful command exit.

### Explicit submission fallback

An earlier release attempt created a submission shell without fully submitting its version item. If `asc submit create --confirm` returns but status does not show an in-flight review, inspect existing submissions/items first. Do not create duplicates. When no suitable submission/item exists, the explicit flow is:

```sh
asc review submissions-create \
  --app "$ASC_APP_ID" \
  --platform IOS \
  --output json \
  --pretty

asc review items-add \
  --submission "$SUBMISSION_ID" \
  --item-type appStoreVersions \
  --item-id "$VERSION_ID" \
  --output json \
  --pretty

asc review submissions-items-ids \
  --id "$SUBMISSION_ID" \
  --output json \
  --pretty

asc review submissions-submit \
  --id "$SUBMISSION_ID" \
  --confirm \
  --output json \
  --pretty
```

Re-run `asc status` and verify the web console. Do not cancel a submission unless the task explicitly authorizes it and a read-only query confirms the exact target and replacement plan.

## 10. After submission and approval

- Record the Git commit, version, build, build ID, version ID, submission ID, release note, and submission time in this runbook or a new release note without adding credentials/PII.
- Monitor with `asc status`; unchanged waiting state is normal.
- When approved, confirm `COMPLETE`, `READY_FOR_DISTRIBUTION`/`READY_FOR_SALE`, and `inFlight=false` as appropriate.
- Verify the public App Store page actually serves the intended version.
- Confirm release mode (automatic after approval, manual, scheduled, or phased) in the web console. In `asc` 0.38.1, aggregate phased-release reporting was inconsistent with the dedicated endpoint during the 1.0.8 audit.
- Keep the version bump commit in `main`; do not create a Git tag unless explicitly requested.

## 11. Known release and host pitfalls

- The project does not store `DEVELOPMENT_TEAM`; archive without an explicit team or configured Xcode account can fail signing.
- Old development provisioning profiles observed during the audit were invalid, and a matching local distribution identity was not assumed. Prefer fresh automatic/cloud-managed signing on the new machine over copying unrelated old certificates.
- Export can silently manage version/build unless `manageAppVersionAndBuildNumber=false` is set.
- Local CoreSimulator can be unstable. Use dynamic device selection and `simctl bootstatus -b`; do not weaken CI because one host is unhealthy.
- `asc publish appstore --submit --confirm` bundles many external mutations. For the first release on a new machine, use the explicit stages above so every checkpoint can be inspected.
- A completed prior submission cannot and need not be canceled to publish a new version.

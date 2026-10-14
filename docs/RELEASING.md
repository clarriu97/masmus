# Testing gates and releases

Every change goes through three gates. The fast, deterministic ones run on
every pull request. The end-to-end flows run on this Mac before merging and on
GitHub after merging, every night and for every release.

| When | What runs | Where | Blocks |
|---|---|---|---|
| Every push (pre-push hook) | format, analyze, unit/widget/layout-matrix tests, goldens | this Mac, `tool/ci.sh` | the push |
| Every pull request | `analyze`, `test` (with coverage), `goldens` | GitHub | the merge (required checks) |
| Before merging | all of the above + release builds (Android app bundle with R8, iOS without signing) + e2e on the small and large iPhone simulators and an Android emulator | this Mac, `tool/ci.sh all` | the merge (`local-e2e` required check) |
| After every merge | release builds | GitHub, workflow **Builds** | nothing: a red run is fixed in the next PR |
| After every merge, nightly, on demand | e2e on iPhone small and large, Android API 24 (small) and 35 (large), and a smoke test of the Android release build on API 35 | GitHub, workflow **E2E** | nothing: a red run is fixed in the next PR |
| Every `v*` tag | tag = pubspec version, all checks, goldens, release builds, e2e on the 4 CI devices | GitHub, workflow **Release** | the release |

## Why the e2e flows don't run on pull requests

Unit, widget, matrix and golden tests don't use devices, so they give the
same result every time. The e2e flows do, and on GitHub's shared machines the
simulator or emulator sometimes fails to attach to the app before the first
test runs ("The log reader failed unexpectedly", "Failed to start Dart
Development Service"), which says nothing about the code. `tool/ci.sh`
retries such a run once (a failure after a test has run is never retried).
Keeping the e2e flows off pull requests takes that noise, and many minutes,
off every merge, while the local gate still guarantees they passed.

## The `local-e2e` gate

`master` only accepts a pull request whose head commit carries the commit
status `local-e2e`, and only `tool/ci.sh all` reports it:

1. Commit and push the branch.
2. Run `tool/ci.sh all`. It runs every check, both release builds and the e2e
   flows on the small and large iPhone simulators and on an Android emulator
   (it starts the first AVD whose name contains `masmus` or `1rm` if none is
   running, and shuts down whatever it started).
3. If everything passes **and** there are no uncommitted changes, it records
   the pass for that commit and reports `local-e2e ✓` on GitHub with the
   devices it ran on. If the commit wasn't pushed yet, push it and run
   `tool/ci.sh report`.

The status is tied to the exact commit. Any new commit, including updating the
branch with `master` (required before merging), needs a new `tool/ci.sh all`.

## The Android release smoke test

`flutter test` only runs debug builds and `flutter drive` refuses release
mode, so the release build (AOT + R8) gets `tool/ci.sh smoke-android-release`
instead: a fresh install, «Nueva partida», «Empezar partida», one move (a
match is saved from its first move), the app killed and opened again, and
«Continuar» on the start screen. It fails on a crash or a missing plugin in
the log. That covers what R8 breaks first: plugins (file storage, audio,
links) and the app starting at all. CI runs it on API 35 after every merge.

## Releasing a version

1. Bump `version:` in `pubspec.yaml` (`1.2.3+45`: name + build number, which
   must always grow) and the same values in `lib/ui/about/about_screen.dart`
   (`appVersion`, `appBuild`, shown in Acerca de; a test fails if they
   differ) in a pull request, and merge it through the gates above.
2. Check the latest **Builds** and **E2E** runs on `master` are green.
3. Tag the merge commit and push the tag:
   ```bash
   git tag v1.2.3 && git push origin v1.2.3
   ```
4. The **Release** workflow must go green. Its last job uploads the signed
   bundle and the store listing to Google Play's **internal testing** track
   (workflow **Google Play**). If it doesn't go green, fix it in a pull
   request and release the next patch version; never move a published tag.
5. Promote the version in Play Console (closed testing, then production)
   once it has been tried on the internal track.
6. By hand, on a real iPhone (and an Android phone when available), with the
   release build: a fresh install and an update over the previous version
   with a match in progress; text at 200 % and bold; sound and vibration on
   and off, and the phone's silent switch; and one pass over every screen
   and a whole hand with VoiceOver (and TalkBack): every card, seña, score
   and button is announced with a name that makes sense, and the table
   tells each thing as it is shown.
7. The site `masmus.larri.dev` with `/privacy/` and `/terms/`, and the
   mailbox `info.masmus@larri.dev`, answer: «Acerca de» and the stores link to
   them (#44).

## Debug symbols

Release builds obfuscate the Dart code and write its debug symbols to
`build/debug-info/` instead of shipping them (`tool/ci.sh`). Keep the
symbols of every version released: without them a crash's stack trace can't
be read. The **Google Play** workflow keeps them as the artifact
`debug-symbols-android-<commit>` for 90 days; download and keep those of each
release. To read a trace:

```bash
flutter symbolize -i trace.txt -d build/debug-info/app.android-arm64.symbols
```

## Android release signing and the Play upload

Release bundles are signed with the upload key; Google Play re-signs them
with the app signing key it keeps (Play App Signing), so a lost upload key
can be replaced by asking Play for a new one.

- **Locally**: `android/key.properties` (git-ignored) points at
  `~/keys/masmus-upload-keystore.jks` (PKCS12, alias `upload`, one password
  for the store and the key). Without that file release builds fall back to
  the debug key, fine for local and CI builds but refused by Google Play.
  The keystore and its `key.properties` are backed up by the owner.
- **In CI**: the **Google Play** workflow rebuilds the keystore and
  `key.properties` from the secrets `ANDROID_UPLOAD_KEYSTORE_BASE64` and
  `ANDROID_UPLOAD_KEYSTORE_PASSWORD`, builds with `tool/ci.sh build-android`
  and uploads with fastlane's `upload_to_play_store`, authenticated by the
  service account `play-publisher@larridev-play.iam.gserviceaccount.com`
  (secret `PLAY_SERVICE_ACCOUNT_JSON`; Google Cloud project `larridev-play`).
  It can also be run by hand from the Actions tab, choosing the track and
  whether the release is a draft (required while the app has never been
  published).
- Each upload needs a build number (`+N` in `pubspec.yaml`) higher than any
  uploaded before.

## When a run on master fails

Open the run and look at which device and which step failed:

- **"e2e infrastructure failure … on attempt 2"**: the device failed to attach
  twice in a row. Re-run the job; if it keeps happening, look at the runner
  image or the Flutter version.
- **A failing test** (❌ with a test name): a real regression that slipped past
  the local gate, most likely Android-only if the Mac had no emulator. Fix it
  in the next pull request with a test that reproduces it.

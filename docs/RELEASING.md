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
4. The **Release** workflow must go green. If it doesn't, fix it in a pull
   request and release the next patch version; never move a published tag.
5. By hand, on a real iPhone (and an Android phone when available), with the
   release build: a fresh install and an update over the previous version
   with a match in progress; text at 200 % and bold; sound and vibration on
   and off, and the phone's silent switch; and one pass over every screen
   and a whole hand with VoiceOver (and TalkBack): every card, seña, score
   and button is announced with a name that makes sense, and the table
   tells each thing as it is shown.
6. The site `masmus.larri.dev` with `/privacy/` and `/terms/`, and the
   mailbox `info.masmus@larri.dev`, answer: «Acerca de» and the stores link to
   them (#44).

## Android release signing

Release builds are signed with the upload key named in `android/key.properties`
(git-ignored, like the keystore). Without that file they fall back to the debug
key, which is fine for local and CI builds but rejected by Google Play. Set it
up once, before the first Play upload (#42), and keep both files in a
password manager backup:

```bash
keytool -genkey -v -keystore ~/masmus-upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

`android/key.properties`:

```properties
storeFile=/Users/<you>/masmus-upload-keystore.jks
storePassword=<password>
keyAlias=upload
keyPassword=<password>
```

## When a run on master fails

Open the run and look at which device and which step failed:

- **"e2e infrastructure failure … on attempt 2"**: the device failed to attach
  twice in a row. Re-run the job; if it keeps happening, look at the runner
  image or the Flutter version.
- **A failing test** (❌ with a test name): a real regression that slipped past
  the local gate, most likely Android-only if the Mac had no emulator. Fix it
  in the next pull request with a test that reproduces it.

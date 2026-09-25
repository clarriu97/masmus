#!/usr/bin/env bash
# The checks CI runs, runnable locally with the same commands.
#
#   tool/ci.sh                 lint + unit/widget tests: what every PR runs   ~1 min
#   tool/ci.sh all             the above + release builds (Android, iOS)      ~5 min
#                              run it before merging changes to dependencies
#                              or native config (android/, ios/)
#
#   tool/ci.sh lint            format and analyze
#   tool/ci.sh unit            unit and widget tests (COVERAGE=1 adds coverage)
#   tool/ci.sh build-android   release app bundle
#   tool/ci.sh build-ios       release iOS build without code signing
set -euo pipefail

cd "$(dirname "$0")/.."

ANDROID_HOME=${ANDROID_HOME:-$HOME/Library/Android/sdk}

step() { printf '\n\033[1;33m▶ %s\033[0m\n' "$*"; }

lint() {
  step "format"
  dart format --output=none --set-exit-if-changed .
  step "analyze"
  flutter analyze
}

# Random test order surfaces tests that depend on each other; a failing run
# prints the seed to reproduce it with --test-randomize-ordering-seed=<seed>.
unit() {
  step "unit and widget tests"
  flutter test --test-randomize-ordering-seed=random ${COVERAGE:+--coverage}
  if [[ -n "${COVERAGE:-}" ]]; then coverage_summary; fi
}

coverage_summary() {
  awk -F: '
    /^LF:/ { found += $2 }
    /^LH:/ { hit += $2 }
    END { printf "Line coverage: %.1f %% (%d of %d lines)\n", 100 * hit / found, hit, found }
  ' coverage/lcov.info
}

build_android() {
  step "release app bundle"
  flutter build appbundle --release
}

build_ios() {
  step "release iOS build (no code signing)"
  flutter build ios --release --no-codesign
}

checks() {
  lint
  unit
}

all() {
  checks
  if [[ -d "$ANDROID_HOME" ]]; then
    build_android
  else
    echo "⚠︎ Android release build skipped: no Android SDK. CI builds it on master."
  fi
  if [[ "$(uname)" == Darwin ]]; then
    build_ios
  else
    echo "⚠︎ iOS release build skipped: not on macOS. CI builds it on master."
  fi
}

case "${1:-}" in
  "") checks ;;
  all) all ;;
  lint) lint ;;
  unit) unit ;;
  build-android) build_android ;;
  build-ios) build_ios ;;
  *) sed -n '2,12p' "$0"; exit 1 ;;
esac

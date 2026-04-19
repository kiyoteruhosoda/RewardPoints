#!/usr/bin/env bash
# Generate the shared debug keystore used by every dev and CI runner.
#
# Why this exists:
#   By default, Android signs debug APKs with ~/.android/debug.keystore,
#   which is generated per machine.  Installing an APK from one machine
#   on top of a build from another machine fails with
#   INSTALL_FAILED_UPDATE_INCOMPATIBLE because the signatures differ.
#   Committing a shared debug.keystore is the standard workaround.
#
# Security note:
#   The password "android" and alias "androiddebugkey" are the Android
#   SDK defaults.  A debug keystore is NOT a secret — it only signs
#   debug-build APKs that are never distributed.  Do not use these
#   values for release signing.
#
# Usage:
#   bash scripts/generate_debug_keystore.sh
#   git add android/app/debug.keystore
#   git commit -m "chore(android): pin shared debug keystore"

set -euo pipefail

KEYSTORE="android/app/debug.keystore"

if [[ ! -f pubspec.yaml ]]; then
    echo "error: run this script from the repository root" >&2
    exit 1
fi

if [[ -f "$KEYSTORE" ]]; then
    echo "error: $KEYSTORE already exists — delete it first if you truly want to regenerate" >&2
    exit 1
fi

keytool -genkeypair \
    -keystore "$KEYSTORE" \
    -storepass android \
    -keypass android \
    -alias androiddebugkey \
    -dname "CN=Android Debug,O=Android,C=US" \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10950

echo ""
echo "Generated $KEYSTORE"
echo "Commit it so every dev and CI runner signs debug builds with the same key:"
echo "  git add $KEYSTORE"
echo "  git commit -m 'chore(android): pin shared debug keystore'"

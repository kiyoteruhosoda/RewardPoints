#!/usr/bin/env bash
# Rename the flutterbase template in one shot.
#
# Usage:
#   scripts/rename_app.sh <new_dart_name> <new_android_package>
#
# Example:
#   scripts/rename_app.sh my_cool_app com.mycompany.coolapp
#
# What this script touches:
#   - pubspec.yaml            (name: field only)
#   - lib/**, test/**, integration_test/**  (package:flutterbase/... imports)
#   - android/app/build.gradle (namespace, applicationId)
#   - android/app/src/main/kotlin/...  (MainActivity package + directory layout)
#
# What this script does NOT touch — edit these by hand:
#   - pubspec.yaml `description` and `version`
#   - AndroidManifest.xml `android:label`
#   - lib/shared/config/app_config.dart (appName, fontFamily, etc.)
#   - README.md
#   - assets/icon/app_icon.png + app_icon_foreground.png
#   - flutter_launcher_icons: adaptive_icon_background colour in pubspec.yaml
#   - android/app/src/main/res/values/colors.xml (ic_launcher_background)
#   - android/app/debug.keystore (run scripts/generate_debug_keystore.sh once)
#   - android/gradle.properties (optional: app.archivesBaseName override)
#
# Assumptions:
#   - GNU sed (on macOS install via `brew install gnu-sed` then call as `gsed`
#     and set SED=gsed, or adjust the sed -i flags below).
#   - Working tree is clean before running.
#   - Run from the repository root.

set -euo pipefail

SED="${SED:-sed}"

die() { echo "error: $*" >&2; exit 1; }

# ─── Argument parsing ─────────────────────────────────────────────────────
if [[ $# -ne 2 ]]; then
    echo "usage: scripts/rename_app.sh <new_dart_name> <new_android_package>" >&2
    exit 2
fi

NEW_DART_NAME="$1"
NEW_ANDROID_PKG="$2"

# Dart package names: lowercase letters, digits, underscores; must start with letter.
if ! [[ "$NEW_DART_NAME" =~ ^[a-z][a-z0-9_]*$ ]]; then
    die "'$NEW_DART_NAME' is not a valid Dart package name (lowercase, digits, underscores; start with letter)"
fi

# Android package: at least two dot-separated segments, each [a-z][a-z0-9_]*.
if ! [[ "$NEW_ANDROID_PKG" =~ ^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$ ]]; then
    die "'$NEW_ANDROID_PKG' is not a valid Android package identifier (e.g. com.example.app)"
fi

# ─── Pre-flight ───────────────────────────────────────────────────────────
if [[ ! -f pubspec.yaml ]]; then
    die "pubspec.yaml not found — run this script from the repository root"
fi

if ! git diff --quiet || ! git diff --cached --quiet; then
    die "working tree is dirty — commit or stash changes before running"
fi

OLD_DART_NAME="$(awk '/^name:/ {print $2; exit}' pubspec.yaml)"
# Matches: def appNamespace = "com.example.rewardpoints"
OLD_ANDROID_PKG="$(awk -F'"' '/^def appNamespace/ {print $2; exit}' android/app/build.gradle)"

[[ -n "$OLD_DART_NAME"   ]] || die "could not read current Dart package name from pubspec.yaml"
[[ -n "$OLD_ANDROID_PKG" ]] || die "could not read current Android namespace from android/app/build.gradle"

echo "Renaming Dart package:    $OLD_DART_NAME -> $NEW_DART_NAME"
echo "Renaming Android package: $OLD_ANDROID_PKG -> $NEW_ANDROID_PKG"

OLD_KOTLIN_DIR="android/app/src/main/kotlin/$(echo "$OLD_ANDROID_PKG" | tr '.' '/')"
NEW_KOTLIN_DIR="android/app/src/main/kotlin/$(echo "$NEW_ANDROID_PKG" | tr '.' '/')"

[[ -d "$OLD_KOTLIN_DIR" ]] || die "expected Kotlin source at '$OLD_KOTLIN_DIR' but it does not exist"

# ─── 1. pubspec.yaml: name: field ─────────────────────────────────────────
$SED -i.bak "1s|^name: $OLD_DART_NAME$|name: $NEW_DART_NAME|" pubspec.yaml

# ─── 2. Dart import cascade ──────────────────────────────────────────────
# Rewrite every `package:<old>/...` reference in lib/, test/, integration_test/.
find lib test integration_test -type f -name '*.dart' -print0 \
    | xargs -0 $SED -i.bak "s|package:${OLD_DART_NAME}/|package:${NEW_DART_NAME}/|g"

# ─── 3. android/app/build.gradle: appNamespace + appApplicationId ────────
$SED -i.bak \
    -e "s|^def appNamespace     = \"$OLD_ANDROID_PKG\"|def appNamespace     = \"$NEW_ANDROID_PKG\"|" \
    -e "s|^def appApplicationId = \"$OLD_ANDROID_PKG\"|def appApplicationId = \"$NEW_ANDROID_PKG\"|" \
    android/app/build.gradle

# ─── 4. Move Kotlin source tree ──────────────────────────────────────────
mkdir -p "$(dirname "$NEW_KOTLIN_DIR")"
if [[ "$NEW_KOTLIN_DIR" == "$OLD_KOTLIN_DIR/"* ]]; then
    TEMP_KOTLIN_DIR="$(mktemp -d)"
    trap 'rm -rf "$TEMP_KOTLIN_DIR"' EXIT ERR
    cp -r "$OLD_KOTLIN_DIR/." "$TEMP_KOTLIN_DIR/"
    git rm -r --quiet "$OLD_KOTLIN_DIR"
    mkdir -p "$NEW_KOTLIN_DIR"
    cp -r "$TEMP_KOTLIN_DIR/." "$NEW_KOTLIN_DIR/"
    git add "$NEW_KOTLIN_DIR"
    rm -rf "$TEMP_KOTLIN_DIR"
    trap - EXIT ERR
else
    git mv "$OLD_KOTLIN_DIR" "$NEW_KOTLIN_DIR"
fi

# ─── 5. Rewrite MainActivity.kt package line ─────────────────────────────
MAIN_ACTIVITY="$NEW_KOTLIN_DIR/MainActivity.kt"
[[ -f "$MAIN_ACTIVITY" ]] || die "expected $MAIN_ACTIVITY after move"
$SED -i.bak "1s|^package $OLD_ANDROID_PKG$|package $NEW_ANDROID_PKG|" "$MAIN_ACTIVITY"

# ─── 6. Clean up .bak files ──────────────────────────────────────────────
rm -f pubspec.yaml.bak android/app/build.gradle.bak
find lib test integration_test "$NEW_KOTLIN_DIR" \
    -name '*.bak' -type f -delete 2>/dev/null || true

# ─── 7. Sanity check ─────────────────────────────────────────────────────
LEAKED="$(grep -rl "package:${OLD_DART_NAME}" lib test integration_test 2>/dev/null || true)"
if [[ -n "$LEAKED" ]]; then
    echo "warning: residual package:${OLD_DART_NAME} imports remain in:" >&2
    echo "$LEAKED" >&2
fi

cat <<MSG

rename complete.

next steps (manual):
  1. edit lib/shared/config/app_config.dart
       - appName, appDescription, appTagline, homeSubtitle, homeCardTitle,
         designSystemLabel/Name/Url/License, fontFamily (if swapping fonts)
  2. edit pubspec.yaml
       - description:
       - version:
       - flutter_launcher_icons.adaptive_icon_background (if brand colour changed)
       - fonts.family (if swapping fonts — must match AppConfig.fontFamily)
  3. edit android/app/src/main/AndroidManifest.xml
       - android:label
  4. replace assets/icon/app_icon.png, then run:
       dart run flutter_launcher_icons
     remember to update the brand colour in
     android/app/src/main/res/values/colors.xml (ic_launcher_background)
     to match pubspec.yaml > flutter_launcher_icons.adaptive_icon_background
  5. (once per fork) pin a shared debug keystore:
       bash scripts/generate_debug_keystore.sh
       git add android/app/debug.keystore
  6. update README.md line 1
  7. run: flutter clean && flutter pub get && dart analyze && flutter test

MSG

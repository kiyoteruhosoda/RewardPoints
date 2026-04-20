# Android signing

Lines up the local and CI signing story so APK updates install cleanly.

## Why install fails on "update"

Android refuses to replace an installed APK whose signing key differs from the
new one. If you installed a CI-built release APK (signed with the keystore
seeded from `KEYSTORE_BASE64`) and then try to install a locally-built APK with
no `key.properties`, the build falls back to the debug key and Android rejects
the update with a generic "App not installed" message.

Two defences already in the repo:

- `android/app/build.gradle` gives the **debug** build type
  `applicationIdSuffix ".debug"` so debug and release APKs install side-by-side
  as separate packages (`com.nolumia.rewardpoints.debug` vs
  `com.nolumia.rewardpoints`). They no longer collide.
- CI (`.github/workflows/build.yml`) decodes `KEYSTORE_BASE64` to
  `android/app/release.keystore` and writes `android/key.properties` before
  `flutter build apk --release`.
- `android/app/build.gradle` now **fails fast** when a release task runs
  without `android/key.properties`, instead of silently signing with a debug
  key. This prevents shipping an APK that installs with "App not installed"
  on top of an existing release app.

For a local release APK that updates the CI-built app cleanly, reuse the same
keystore.

## Local release signing setup

1. Obtain the release keystore (same one CI uses). Place it at
   `android/app/release.keystore`. This file is git-ignored.
2. Create `android/key.properties` (also git-ignored):

   ```
   storeFile=../app/release.keystore
   storePassword=<store password>
   keyAlias=<key alias>
   keyPassword=<key password>
   ```

3. Build with an incrementing `versionCode`:

   ```
   flutter build apk --release --build-number=$(git rev-list --count HEAD)
   ```

   `--build-number` overrides the `+N` suffix in `pubspec.yaml:version`, so the
   `versionCode` always moves forward with commits.

Without `key.properties`, release builds are blocked with an explicit error.

## Generating a keystore (one-off)

```
keytool -genkey -v \
  -keystore android/app/release.keystore \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias rewardpoints
```

Save the passwords and upload a base64 of the `.keystore` to the
`KEYSTORE_BASE64` GitHub secret together with `KEY_ALIAS`, `KEY_PASSWORD`, and
`STORE_PASSWORD`.

## Uninstall-first scenarios

- Switching from a pre-`.debug`-suffix debug install: uninstall the old debug
  app once. Newer debug builds land under the `.debug` package.
- Switching signing keys for an already-released app: users must uninstall
  first; there is no in-place recovery.

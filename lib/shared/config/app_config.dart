/// Single source of truth for per-app identity values that live in Dart.
///
/// When forking the template for a new app, edit the values in this file
/// and follow `docs/CUSTOMISATION.md` for the surfaces that cannot be
/// centralised here (bundle IDs, launcher icons, font binaries).
class AppConfig {
  AppConfig._();

  // ─── Identity ─────────────────────────────────────────────────────
  static const String appName = 'RewardPoints';
  static const String appDescription = 'デジタル庁デザインシステムを使ったポイント管理アプリ';
  static const String appTagline = 'DADS Design System';

  // ─── Typography ───────────────────────────────────────────────────
  static const String fontFamily = 'NotoSansJP';

  // ─── Design system attribution (About + LicenseRegistry) ──────────
  static const String designSystemLabel = 'DADS v2.10.3';
  static const String designSystemName = 'Digital Agency Design System (DADS)';
  static const String designSystemUrl = 'https://design.digital.go.jp/';
  static const String designSystemLicense = 'CC BY 4.0';
}

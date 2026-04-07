/// デジタル庁デザインシステム スペーシングトークン
/// 4pxグリッドに基づくスペーシング
class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;
  static const double xxxxl = 64.0;

  // Semantic aliases
  static const double componentPadding = lg;
  static const double sectionGap = xl;
  static const double pageMargin = lg;
  static const double listItemGap = sm;
  static const double iconGap = xs;

  // Minimum tap target
  static const double minTapTarget = 48.0;

  // Icon sizes (Material standard)
  static const double iconSm = 16.0;
  static const double iconMd = 20.0;
  static const double iconLg = 24.0;
  static const double iconXl = 32.0;

  // Component sizes
  static const double splashIconContainer = 96.0;
  static const double aboutIconContainer = 80.0;
  static const double splashIconSize = 48.0;
  static const double aboutIconSize = 40.0;
  static const double levelBadgeSize = 20.0;
}

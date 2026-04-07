/// Theme preference as a pure Dart value — no Flutter dependency.
///
/// The Presentation layer maps this to Flutter's [ThemeMode].
enum AppThemeMode {
  /// Always use the light theme.
  light,

  /// Always use the dark theme.
  dark,

  /// Follow the device system setting.
  system,
}

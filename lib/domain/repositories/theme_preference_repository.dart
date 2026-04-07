import 'package:flutterbase/shared/value_objects/app_theme_mode.dart';

/// Persists and retrieves the user's theme preference.
///
/// Implementations live in `infrastructure/repositories/`.
abstract interface class ThemePreferenceRepository {
  /// Returns the currently saved theme preference.
  /// Returns [AppThemeMode.light] if nothing has been saved yet.
  AppThemeMode get();

  /// Persists [mode] as the user's preferred theme.
  Future<void> save(AppThemeMode mode);
}

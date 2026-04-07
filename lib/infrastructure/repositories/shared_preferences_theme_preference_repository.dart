import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutterbase/domain/repositories/theme_preference_repository.dart';
import 'package:flutterbase/shared/value_objects/app_theme_mode.dart';

/// Stores the theme preference in [SharedPreferences].
final class SharedPreferencesThemePreferenceRepository
    implements ThemePreferenceRepository {
  const SharedPreferencesThemePreferenceRepository(this._prefs);

  static const String _key = 'theme_mode';

  final SharedPreferences _prefs;

  @override
  AppThemeMode get() {
    final saved = _prefs.getString(_key);
    return switch (saved) {
      'dark' => AppThemeMode.dark,
      'system' => AppThemeMode.system,
      _ => AppThemeMode.light, // default
    };
  }

  @override
  Future<void> save(AppThemeMode mode) async {
    await _prefs.setString(_key, mode.name);
  }
}

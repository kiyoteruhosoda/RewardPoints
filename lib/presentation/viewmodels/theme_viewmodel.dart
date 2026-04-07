import 'package:flutter/material.dart';
import 'package:flutterbase/app/di/service_locator.dart';
import 'package:flutterbase/application/usecases/theme/get_theme_preference_usecase.dart';
import 'package:flutterbase/application/usecases/theme/set_theme_preference_usecase.dart';
import 'package:flutterbase/shared/logging/app_logger.dart';
import 'package:flutterbase/shared/value_objects/app_theme_mode.dart';

/// Manages the app-wide [ThemeMode] and persists the user's choice via
/// [GetThemePreferenceUseCase] / [SetThemePreferenceUseCase].
class ThemeViewModel extends ChangeNotifier {
  ThemeViewModel(
    this._getThemePreference,
    this._setThemePreference,
  ) {
    _themeMode = _toFlutterMode(_getThemePreference.execute());
    sl<AppLogger>().debug('[ThemeViewModel] init — themeMode: ${_themeMode.name}');
  }

  final GetThemePreferenceUseCase _getThemePreference;
  final SetThemePreferenceUseCase _setThemePreference;

  late ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    sl<AppLogger>().debug('[ThemeViewModel] setThemeMode: ${mode.name}');
    _themeMode = mode;
    await _setThemePreference.execute(_toAppMode(mode));
    notifyListeners();
  }

  // ── Mapping helpers ────────────────────────────────────────────────────

  ThemeMode _toFlutterMode(AppThemeMode mode) => switch (mode) {
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
        AppThemeMode.system => ThemeMode.system,
      };

  AppThemeMode _toAppMode(ThemeMode mode) => switch (mode) {
        ThemeMode.light => AppThemeMode.light,
        ThemeMode.dark => AppThemeMode.dark,
        ThemeMode.system => AppThemeMode.system,
      };
}

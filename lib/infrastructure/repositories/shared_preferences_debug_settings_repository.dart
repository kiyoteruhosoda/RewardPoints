import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutterbase/domain/repositories/debug_settings_repository.dart';
import 'package:flutterbase/shared/logging/log_level.dart';

/// [DebugSettingsRepository] backed by [SharedPreferences].
final class SharedPreferencesDebugSettingsRepository
    implements DebugSettingsRepository {
  SharedPreferencesDebugSettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const String _keyDebugMode = 'debug_mode_enabled';
  static const String _keyLogLevel = 'min_log_level';

  @override
  bool getDebugModeEnabled() => _prefs.getBool(_keyDebugMode) ?? true;

  @override
  LogLevel getMinLogLevel() {
    final saved = _prefs.getString(_keyLogLevel);
    return LogLevel.values.firstWhere(
      (l) => l.name == saved,
      orElse: () => LogLevel.debug,
    );
  }

  @override
  Future<void> saveDebugModeEnabled(bool enabled) =>
      _prefs.setBool(_keyDebugMode, enabled);

  @override
  Future<void> saveMinLogLevel(LogLevel level) =>
      _prefs.setString(_keyLogLevel, level.name);
}

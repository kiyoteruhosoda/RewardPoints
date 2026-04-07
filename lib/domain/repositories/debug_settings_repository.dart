import 'package:flutterbase/shared/logging/log_level.dart';

/// Persists developer/debug preferences.
abstract interface class DebugSettingsRepository {
  /// Returns whether debug mode is currently enabled (default: true).
  bool getDebugModeEnabled();

  /// Returns the minimum log level to record (default: [LogLevel.debug]).
  LogLevel getMinLogLevel();

  Future<void> saveDebugModeEnabled(bool enabled);
  Future<void> saveMinLogLevel(LogLevel level);
}

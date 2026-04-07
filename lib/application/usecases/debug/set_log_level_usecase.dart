import 'package:flutterbase/domain/repositories/debug_settings_repository.dart';
import 'package:flutterbase/shared/logging/app_logger.dart';
import 'package:flutterbase/shared/logging/log_level.dart';

/// Persists the minimum log level and applies it to the active [AppLogger].
final class SetLogLevelUseCase {
  const SetLogLevelUseCase(this._repository, this._logger);

  final DebugSettingsRepository _repository;
  final AppLogger _logger;

  Future<void> execute(LogLevel level) async {
    await _repository.saveMinLogLevel(level);
    _logger.setMinLevel(level);
  }
}

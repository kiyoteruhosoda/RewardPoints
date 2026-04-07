import 'package:flutterbase/domain/repositories/debug_settings_repository.dart';

/// Persists the debug-mode enabled flag.
final class SetDebugModeUseCase {
  const SetDebugModeUseCase(this._repository);

  final DebugSettingsRepository _repository;

  Future<void> execute(bool enabled) =>
      _repository.saveDebugModeEnabled(enabled);
}

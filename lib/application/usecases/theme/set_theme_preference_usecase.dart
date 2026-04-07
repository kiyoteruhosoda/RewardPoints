import 'package:flutterbase/domain/repositories/theme_preference_repository.dart';
import 'package:flutterbase/shared/value_objects/app_theme_mode.dart';

/// Persists the user's theme preference.
final class SetThemePreferenceUseCase {
  const SetThemePreferenceUseCase(this._repository);

  final ThemePreferenceRepository _repository;

  Future<void> execute(AppThemeMode mode) => _repository.save(mode);
}

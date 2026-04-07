import 'package:flutterbase/domain/repositories/theme_preference_repository.dart';
import 'package:flutterbase/shared/value_objects/app_theme_mode.dart';

/// Returns the user's currently saved theme preference.
final class GetThemePreferenceUseCase {
  const GetThemePreferenceUseCase(this._repository);

  final ThemePreferenceRepository _repository;

  AppThemeMode execute() => _repository.get();
}

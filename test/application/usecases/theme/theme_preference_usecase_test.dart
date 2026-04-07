import 'package:flutter_test/flutter_test.dart';
import 'package:flutterbase/application/usecases/theme/get_theme_preference_usecase.dart';
import 'package:flutterbase/application/usecases/theme/set_theme_preference_usecase.dart';
import 'package:flutterbase/domain/repositories/theme_preference_repository.dart';
import 'package:flutterbase/shared/value_objects/app_theme_mode.dart';

// ─── Fake repository ──────────────────────────────────────────────────────────

class _FakeThemePreferenceRepository implements ThemePreferenceRepository {
  AppThemeMode _mode = AppThemeMode.light;

  @override
  AppThemeMode get() => _mode;

  @override
  Future<void> save(AppThemeMode mode) async => _mode = mode;
}

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  late _FakeThemePreferenceRepository repo;
  late GetThemePreferenceUseCase getUseCase;
  late SetThemePreferenceUseCase setUseCase;

  setUp(() {
    repo = _FakeThemePreferenceRepository();
    getUseCase = GetThemePreferenceUseCase(repo);
    setUseCase = SetThemePreferenceUseCase(repo);
  });

  group('GetThemePreferenceUseCase', () {
    test('returns light by default', () {
      expect(getUseCase.execute(), equals(AppThemeMode.light));
    });

    test('returns whatever the repository returns', () async {
      await repo.save(AppThemeMode.dark);
      expect(getUseCase.execute(), equals(AppThemeMode.dark));
    });
  });

  group('SetThemePreferenceUseCase', () {
    test('persists light mode', () async {
      await setUseCase.execute(AppThemeMode.light);
      expect(repo.get(), equals(AppThemeMode.light));
    });

    test('persists dark mode', () async {
      await setUseCase.execute(AppThemeMode.dark);
      expect(repo.get(), equals(AppThemeMode.dark));
    });

    test('persists system mode', () async {
      await setUseCase.execute(AppThemeMode.system);
      expect(repo.get(), equals(AppThemeMode.system));
    });
  });

  group('Get + Set round-trip', () {
    for (final mode in AppThemeMode.values) {
      test('round-trips $mode', () async {
        await setUseCase.execute(mode);
        expect(getUseCase.execute(), equals(mode));
      });
    }
  });
}

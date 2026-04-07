import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutterbase/infrastructure/repositories/shared_preferences_theme_preference_repository.dart';
import 'package:flutterbase/shared/value_objects/app_theme_mode.dart';

void main() {
  late SharedPreferences prefs;
  late SharedPreferencesThemePreferenceRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repo = SharedPreferencesThemePreferenceRepository(prefs);
  });

  group('SharedPreferencesThemePreferenceRepository', () {
    test('returns light by default when nothing is stored', () {
      expect(repo.get(), equals(AppThemeMode.light));
    });

    test('saves and restores light mode', () async {
      await repo.save(AppThemeMode.light);
      final repo2 = SharedPreferencesThemePreferenceRepository(prefs);
      expect(repo2.get(), equals(AppThemeMode.light));
    });

    test('saves and restores dark mode', () async {
      await repo.save(AppThemeMode.dark);
      final repo2 = SharedPreferencesThemePreferenceRepository(prefs);
      expect(repo2.get(), equals(AppThemeMode.dark));
    });

    test('saves and restores system mode', () async {
      await repo.save(AppThemeMode.system);
      final repo2 = SharedPreferencesThemePreferenceRepository(prefs);
      // P1 fix: system mode must survive an app restart
      expect(repo2.get(), equals(AppThemeMode.system));
    });

    test('unknown stored value falls back to light', () async {
      await prefs.setString('theme_mode', 'corrupted');
      final repo2 = SharedPreferencesThemePreferenceRepository(prefs);
      expect(repo2.get(), equals(AppThemeMode.light));
    });

    test('all AppThemeMode values round-trip correctly', () async {
      for (final mode in AppThemeMode.values) {
        await repo.save(mode);
        final repo2 = SharedPreferencesThemePreferenceRepository(prefs);
        expect(repo2.get(), equals(mode), reason: 'mode=$mode failed round-trip');
      }
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterbase/application/usecases/theme/get_theme_preference_usecase.dart';
import 'package:flutterbase/application/usecases/theme/set_theme_preference_usecase.dart';
import 'package:flutterbase/domain/repositories/theme_preference_repository.dart';
import 'package:flutterbase/presentation/viewmodels/theme_viewmodel.dart';
import 'package:flutterbase/shared/value_objects/app_theme_mode.dart';

// ─── Fake repository ──────────────────────────────────────────────────────────

class _FakeThemePreferenceRepository implements ThemePreferenceRepository {
  _FakeThemePreferenceRepository([this._mode = AppThemeMode.light]);
  AppThemeMode _mode;

  @override
  AppThemeMode get() => _mode;

  @override
  Future<void> save(AppThemeMode mode) async => _mode = mode;
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

ThemeViewModel _makeViewModel([AppThemeMode initial = AppThemeMode.light]) {
  final repo = _FakeThemePreferenceRepository(initial);
  return ThemeViewModel(
    GetThemePreferenceUseCase(repo),
    SetThemePreferenceUseCase(repo),
  );
}

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  group('ThemeViewModel', () {
    test('defaults to light mode when no preference is saved', () {
      expect(_makeViewModel().themeMode, equals(ThemeMode.light));
    });

    test('reads dark mode from repository on construction', () {
      expect(
        _makeViewModel(AppThemeMode.dark).themeMode,
        equals(ThemeMode.dark),
      );
    });

    test('reads system mode from repository on construction', () {
      expect(
        _makeViewModel(AppThemeMode.system).themeMode,
        equals(ThemeMode.system),
      );
    });

    test('setThemeMode persists to repository', () async {
      final repo = _FakeThemePreferenceRepository();
      final vm = ThemeViewModel(
        GetThemePreferenceUseCase(repo),
        SetThemePreferenceUseCase(repo),
      );
      await vm.setThemeMode(ThemeMode.dark);
      expect(repo.get(), equals(AppThemeMode.dark));
    });

    test('setThemeMode updates themeMode property', () async {
      final vm = _makeViewModel();
      await vm.setThemeMode(ThemeMode.dark);
      expect(vm.themeMode, equals(ThemeMode.dark));
    });

    test('setThemeMode notifies listeners on change', () async {
      final vm = _makeViewModel();
      var notified = false;
      vm.addListener(() => notified = true);

      await vm.setThemeMode(ThemeMode.dark);
      expect(notified, isTrue);
    });

    test('setThemeMode does not notify when same mode is set', () async {
      final vm = _makeViewModel(AppThemeMode.light);
      var notified = false;
      vm.addListener(() => notified = true);

      await vm.setThemeMode(ThemeMode.light);
      expect(notified, isFalse);
    });

    test('can cycle through all three modes', () async {
      final vm = _makeViewModel();
      await vm.setThemeMode(ThemeMode.dark);
      expect(vm.themeMode, equals(ThemeMode.dark));

      await vm.setThemeMode(ThemeMode.system);
      expect(vm.themeMode, equals(ThemeMode.system));

      await vm.setThemeMode(ThemeMode.light);
      expect(vm.themeMode, equals(ThemeMode.light));
    });

    test('system mode round-trips through repository correctly', () async {
      final repo = _FakeThemePreferenceRepository();
      final vm = ThemeViewModel(
        GetThemePreferenceUseCase(repo),
        SetThemePreferenceUseCase(repo),
      );
      await vm.setThemeMode(ThemeMode.system);

      // Reconstruct a new VM from the same repo to simulate app restart
      final vm2 = ThemeViewModel(
        GetThemePreferenceUseCase(repo),
        SetThemePreferenceUseCase(repo),
      );
      expect(vm2.themeMode, equals(ThemeMode.system));
    });
  });
}

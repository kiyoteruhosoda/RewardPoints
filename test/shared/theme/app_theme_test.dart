import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterbase/shared/theme/app_theme.dart';
import 'package:flutterbase/shared/theme/app_colors.dart';

void main() {
  group('AppTheme.light', () {
    late ThemeData theme;
    setUpAll(() => theme = AppTheme.light);

    test('brightness is light', () {
      expect(theme.brightness, equals(Brightness.light));
    });

    test('scaffold background is white', () {
      expect(theme.scaffoldBackgroundColor, equals(AppColors.bgBase));
    });

    test('useMaterial3 is true', () {
      expect(theme.useMaterial3, isTrue);
    });

    test('font family is NotoSansJP', () {
      expect(theme.textTheme.bodyMedium!.fontFamily, equals('NotoSansJP'));
    });

    test('text theme body colors are dark (for light mode)', () {
      // In light mode, body text should be dark
      final bodyColor = theme.textTheme.bodyMedium!.color!;
      // Dark text on white background — luminance should be low
      expect(bodyColor.computeLuminance(), lessThan(0.5));
    });

    test('colorScheme primary is not null', () {
      expect(theme.colorScheme.primary, isNotNull);
    });

    test('colorScheme surface equals bgBase', () {
      expect(theme.colorScheme.surface, equals(AppColors.bgBase));
    });
  });

  group('AppTheme.dark', () {
    late ThemeData theme;
    setUpAll(() => theme = AppTheme.dark);

    test('brightness is dark', () {
      expect(theme.brightness, equals(Brightness.dark));
    });

    test('scaffold background is dark', () {
      expect(theme.scaffoldBackgroundColor, equals(AppColors.darkBgBase));
    });

    test('useMaterial3 is true', () {
      expect(theme.useMaterial3, isTrue);
    });

    test('text theme body text is white (for dark mode)', () {
      final bodyColor = theme.textTheme.bodyMedium!.color!;
      // White text on dark background — luminance should be high
      expect(bodyColor.computeLuminance(), greaterThan(0.5));
    });

    test('colorScheme surface equals darkBgBase', () {
      expect(theme.colorScheme.surface, equals(AppColors.darkBgBase));
    });

    test('dark primary color is lighter than light primary', () {
      final lightPrimary = AppTheme.light.colorScheme.primary;
      final darkPrimary = AppTheme.dark.colorScheme.primary;
      expect(
        darkPrimary.computeLuminance(),
        greaterThan(lightPrimary.computeLuminance()),
      );
    });
  });

  group('AppTheme — text styles have no hardcoded colors', () {
    test('AppTextStyles constants do not carry a color', () {
      // After the dark-mode fix, AppTextStyles should not specify colors.
      // The color must come from the theme's textTheme, not the constant.
      // We verify this indirectly: the light and dark themes should produce
      // different body text colors.
      final lightBody = AppTheme.light.textTheme.bodyMedium!.color!;
      final darkBody = AppTheme.dark.textTheme.bodyMedium!.color!;
      expect(lightBody, isNot(equals(darkBody)));
    });
  });

  group('AppTheme — component themes', () {
    test('elevated button has zero elevation', () {
      final style = AppTheme.light.elevatedButtonTheme.style!;
      final elevation = style.elevation?.resolve({});
      expect(elevation, equals(0));
    });

    test('card has zero elevation', () {
      expect(AppTheme.light.cardTheme.elevation, equals(0));
    });

    test('divider thickness is 1', () {
      expect(AppTheme.light.dividerTheme.thickness, equals(1));
    });

    test('navigation bar background matches scaffold in light mode', () {
      expect(
        AppTheme.light.navigationBarTheme.backgroundColor,
        equals(AppColors.bgBase),
      );
    });

    test('navigation bar background matches scaffold in dark mode', () {
      expect(
        AppTheme.dark.navigationBarTheme.backgroundColor,
        equals(AppColors.darkBgBase),
      );
    });
  });
}

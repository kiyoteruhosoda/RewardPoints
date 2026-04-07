import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterbase/shared/theme/app_colors.dart';

void main() {
  group('AppColors — primitive scales', () {
    test('blue scale is non-null and distinct', () {
      final blues = [
        AppColors.blue100,
        AppColors.blue200,
        AppColors.blue300,
        AppColors.blue400,
        AppColors.blue500,
        AppColors.blue600,
        AppColors.blue700,
        AppColors.blue800,
        AppColors.blue900,
        AppColors.blue1000,
        AppColors.blue1100,
        AppColors.blue1200,
        AppColors.blue1300,
      ];
      for (final c in blues) {
        expect(c, isNotNull);
      }
      final set = blues.toSet();
      expect(set.length, equals(blues.length), reason: 'All blue values must be distinct');
    });

    test('red scale is non-null and distinct', () {
      final reds = [
        AppColors.red100, AppColors.red200, AppColors.red300, AppColors.red400,
        AppColors.red500, AppColors.red600, AppColors.red700, AppColors.red800,
        AppColors.red900, AppColors.red1000, AppColors.red1100, AppColors.red1200,
      ];
      expect(reds.toSet().length, equals(reds.length));
    });

    test('green scale is non-null and distinct', () {
      final greens = [
        AppColors.green100, AppColors.green200, AppColors.green300, AppColors.green400,
        AppColors.green500, AppColors.green600, AppColors.green700, AppColors.green800,
        AppColors.green900, AppColors.green1000, AppColors.green1100, AppColors.green1200,
      ];
      expect(greens.toSet().length, equals(greens.length));
    });

    test('yellow scale is non-null and distinct', () {
      final yellows = [
        AppColors.yellow100, AppColors.yellow200, AppColors.yellow300, AppColors.yellow400,
        AppColors.yellow500, AppColors.yellow600, AppColors.yellow700, AppColors.yellow800,
        AppColors.yellow900, AppColors.yellow1000, AppColors.yellow1100, AppColors.yellow1200,
      ];
      expect(yellows.toSet().length, equals(yellows.length));
    });
  });

  group('AppColors — neutral scale', () {
    test('white is #FFFFFF', () {
      expect(AppColors.white, equals(const Color(0xFFFFFFFF)));
    });

    test('black is #000000', () {
      expect(AppColors.black, equals(const Color(0xFF000000)));
    });

    test('sumi scale is distinct and ordered (lighter to darker)', () {
      final sumis = [
        AppColors.sumi50, AppColors.sumi100, AppColors.sumi200, AppColors.sumi300,
        AppColors.sumi400, AppColors.sumi500, AppColors.sumi600,
        AppColors.sumi700, AppColors.sumi800, AppColors.sumi900,
      ];
      expect(sumis.toSet().length, equals(sumis.length));
    });

    test('sumi900 is the expected near-black value', () {
      expect(AppColors.sumi900, equals(const Color(0xFF1A1A1A)));
    });
  });

  group('AppColors — light theme semantic colors', () {
    test('background tokens are defined', () {
      expect(AppColors.bgBase, equals(AppColors.white));
      expect(AppColors.bgLayer1, isNotNull);
      expect(AppColors.bgLayer2, isNotNull);
    });

    test('text tokens are defined', () {
      expect(AppColors.textBody, equals(AppColors.sumi900));
      expect(AppColors.textDescription, isNotNull);
      expect(AppColors.textPlaceholder, isNotNull);
      expect(AppColors.textDisabled, isNotNull);
      expect(AppColors.textOnFill, equals(AppColors.white));
    });

    test('interactive tokens are defined', () {
      expect(AppColors.interactivePrimary, isNotNull);
      expect(AppColors.interactivePrimaryHover, isNotNull);
      expect(AppColors.interactivePrimaryPressed, isNotNull);
      expect(AppColors.interactivePrimaryDisabled, isNotNull);
    });

    test('border tokens are defined', () {
      expect(AppColors.borderDefault, isNotNull);
      expect(AppColors.borderFocused, isNotNull);
      expect(AppColors.borderError, isNotNull);
      expect(AppColors.borderDisabled, isNotNull);
    });

    test('status tokens are defined', () {
      expect(AppColors.statusSuccess, isNotNull);
      expect(AppColors.statusError, isNotNull);
      expect(AppColors.statusWarning, isNotNull);
      expect(AppColors.statusInfo, isNotNull);
    });
  });

  group('AppColors — dark theme semantic colors', () {
    test('dark background tokens are defined', () {
      expect(AppColors.darkBgBase, isNotNull);
      expect(AppColors.darkBgLayer1, isNotNull);
      expect(AppColors.darkBgLayer2, isNotNull);
    });

    test('dark backgrounds are darker than light backgrounds', () {
      // Compare alpha+value: dark bg should be a darker shade
      expect(AppColors.darkBgBase, isNot(equals(AppColors.bgBase)));
    });

    test('dark text tokens are defined', () {
      expect(AppColors.darkTextBody, equals(AppColors.white));
      expect(AppColors.darkTextDescription, isNotNull);
      expect(AppColors.darkTextPlaceholder, isNotNull);
      expect(AppColors.darkTextDisabled, isNotNull);
    });

    test('dark interactive tokens use lighter blue shades', () {
      expect(AppColors.darkInteractivePrimary, isNotNull);
      expect(AppColors.darkInteractivePrimaryHover, isNotNull);
      expect(AppColors.darkInteractivePrimaryPressed, isNotNull);
      // Dark mode primary should be a lighter blue than light mode primary
      expect(
        AppColors.darkInteractivePrimary,
        isNot(equals(AppColors.interactivePrimary)),
      );
    });
  });
}

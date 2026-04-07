// Legacy location — tests moved to test/shared/theme/app_colors_test.dart
// Kept here to avoid breaking existing CI runs.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterbase/shared/theme/app_colors.dart';

void main() {
  group('AppColors (legacy test location)', () {
    test('blue scale colors are not null', () {
      expect(AppColors.blue100, isNotNull);
      expect(AppColors.blue800, isNotNull);
      expect(AppColors.blue1300, isNotNull);
    });

    test('blue scale has distinct colors', () {
      expect(AppColors.blue100 == AppColors.blue800, isFalse);
      expect(AppColors.blue800 == AppColors.blue1300, isFalse);
    });

    test('sumi scale includes white and black', () {
      expect(AppColors.white, equals(const Color(0xFFFFFFFF)));
      expect(AppColors.black, equals(const Color(0xFF000000)));
    });

    test('sumi900 matches expected dark color', () {
      expect(AppColors.sumi900, equals(const Color(0xFF1A1A1A)));
    });

    test('semantic colors are defined', () {
      expect(AppColors.interactivePrimary, isNotNull);
      expect(AppColors.textBody, isNotNull);
      expect(AppColors.borderDefault, isNotNull);
      expect(AppColors.statusError, isNotNull);
    });

    test('dark theme semantic colors are defined', () {
      expect(AppColors.darkBgBase, isNotNull);
      expect(AppColors.darkTextBody, isNotNull);
      expect(AppColors.darkInteractivePrimary, isNotNull);
    });
  });
}

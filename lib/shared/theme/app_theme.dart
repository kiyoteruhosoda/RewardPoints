import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

/// デジタル庁デザインシステム準拠のアプリテーマ
class AppTheme {
  AppTheme._();

  static ThemeData get light => _buildTheme(brightness: Brightness.light);
  static ThemeData get dark => _buildTheme(brightness: Brightness.dark);

  static ThemeData _buildTheme({required Brightness brightness}) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = isDark ? _darkColorScheme : _lightColorScheme;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      fontFamily: 'NotoSansJP',
      textTheme: _buildTextTheme(isDark: isDark),
      appBarTheme: _buildAppBarTheme(isDark: isDark),
      elevatedButtonTheme: _buildElevatedButtonTheme(isDark: isDark),
      outlinedButtonTheme: _buildOutlinedButtonTheme(isDark: isDark),
      textButtonTheme: _buildTextButtonTheme(isDark: isDark),
      inputDecorationTheme: _buildInputDecorationTheme(isDark: isDark),
      cardTheme: _buildCardTheme(isDark: isDark),
      dividerTheme: _buildDividerTheme(isDark: isDark),
      drawerTheme: _buildDrawerTheme(isDark: isDark),
      navigationBarTheme: _buildNavigationBarTheme(isDark: isDark),
      snackBarTheme: _buildSnackBarTheme(isDark: isDark),
      scaffoldBackgroundColor:
          isDark ? AppColors.darkBgBase : AppColors.bgBase,
    );
  }

  // ─── Color Schemes ─────────────────────────────────────────────────
  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.interactivePrimary,
    onPrimary: AppColors.textOnFill,
    primaryContainer: AppColors.blue100,
    onPrimaryContainer: AppColors.blue1300,
    secondary: AppColors.sumi700,
    onSecondary: AppColors.textOnFill,
    secondaryContainer: AppColors.sumi100,
    onSecondaryContainer: AppColors.sumi900,
    tertiary: AppColors.green600,
    onTertiary: AppColors.textOnFill,
    tertiaryContainer: AppColors.green100,
    onTertiaryContainer: AppColors.green1200,
    error: AppColors.statusError,
    onError: AppColors.textOnFill,
    errorContainer: AppColors.statusErrorBg,
    onErrorContainer: AppColors.red1200,
    surface: AppColors.bgBase,
    onSurface: AppColors.textBody,
    surfaceContainerHighest: AppColors.sumi100,
    onSurfaceVariant: AppColors.textDescription,
    outline: AppColors.borderDefault,
    outlineVariant: AppColors.sumi100,
    shadow: AppColors.black,
    scrim: AppColors.black,
    inverseSurface: AppColors.sumi900,
    onInverseSurface: AppColors.white,
    inversePrimary: AppColors.blue400,
  );

  static const ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.darkInteractivePrimary,
    onPrimary: AppColors.sumi900,
    primaryContainer: AppColors.blue1000,
    onPrimaryContainer: AppColors.blue200,
    secondary: AppColors.sumi300,
    onSecondary: AppColors.sumi900,
    secondaryContainer: AppColors.sumi700,
    onSecondaryContainer: AppColors.sumi100,
    tertiary: AppColors.green400,
    onTertiary: AppColors.sumi900,
    tertiaryContainer: AppColors.green1000,
    onTertiaryContainer: AppColors.green200,
    error: AppColors.red500,
    onError: AppColors.sumi900,
    errorContainer: AppColors.red1200,
    onErrorContainer: AppColors.red200,
    surface: AppColors.darkBgBase,
    onSurface: AppColors.darkTextBody,
    surfaceContainerHighest: AppColors.sumi700,
    onSurfaceVariant: AppColors.darkTextDescription,
    outline: AppColors.darkBorderDefault,
    outlineVariant: AppColors.sumi700,
    shadow: AppColors.black,
    scrim: AppColors.black,
    inverseSurface: AppColors.sumi100,
    onInverseSurface: AppColors.sumi900,
    inversePrimary: AppColors.blue800,
  );

  // ─── Component Themes ──────────────────────────────────────────────
  static TextTheme _buildTextTheme({required bool isDark}) {
    final baseColor =
        isDark ? AppColors.darkTextBody : AppColors.textBody;
    return TextTheme(
      displayLarge:
          AppTextStyles.displayLarge.copyWith(color: baseColor),
      displayMedium:
          AppTextStyles.displayMedium.copyWith(color: baseColor),
      displaySmall:
          AppTextStyles.displaySmall.copyWith(color: baseColor),
      headlineLarge:
          AppTextStyles.headlineLarge.copyWith(color: baseColor),
      headlineMedium:
          AppTextStyles.headlineMedium.copyWith(color: baseColor),
      headlineSmall:
          AppTextStyles.headlineSmall.copyWith(color: baseColor),
      titleLarge:
          AppTextStyles.titleLarge.copyWith(color: baseColor),
      titleMedium:
          AppTextStyles.titleMedium.copyWith(color: baseColor),
      titleSmall:
          AppTextStyles.titleSmall.copyWith(color: baseColor),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: baseColor),
      bodyMedium:
          AppTextStyles.bodyMedium.copyWith(color: baseColor),
      bodySmall: AppTextStyles.bodySmall.copyWith(
        color: isDark
            ? AppColors.darkTextDescription
            : AppColors.textDescription,
      ),
      labelLarge:
          AppTextStyles.labelLarge.copyWith(color: baseColor),
      labelMedium:
          AppTextStyles.labelMedium.copyWith(color: baseColor),
      labelSmall:
          AppTextStyles.labelSmall.copyWith(color: baseColor),
    );
  }

  static AppBarTheme _buildAppBarTheme({required bool isDark}) {
    return AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor:
          isDark ? AppColors.darkBgBase : AppColors.bgBase,
      foregroundColor:
          isDark ? AppColors.darkTextBody : AppColors.textBody,
      titleTextStyle: AppTextStyles.titleLarge.copyWith(
        color: isDark ? AppColors.darkTextBody : AppColors.textBody,
      ),
      centerTitle: true,
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme(
      {required bool isDark}) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: isDark
            ? AppColors.darkInteractivePrimary
            : AppColors.interactivePrimary,
        foregroundColor: isDark ? AppColors.sumi900 : AppColors.white,
        disabledBackgroundColor: isDark
            ? AppColors.sumi700
            : AppColors.interactivePrimaryDisabled,
        disabledForegroundColor: AppColors.textDisabled,
        minimumSize: const Size(0, AppSpacing.minTapTarget),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.md,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.smBorder,
        ),
        textStyle: AppTextStyles.labelLarge,
        elevation: 0,
      ),
    );
  }

  static OutlinedButtonThemeData _buildOutlinedButtonTheme(
      {required bool isDark}) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: isDark
            ? AppColors.darkInteractivePrimary
            : AppColors.interactivePrimary,
        side: BorderSide(
          color: isDark
              ? AppColors.darkInteractivePrimary
              : AppColors.interactivePrimary,
        ),
        minimumSize: const Size(0, AppSpacing.minTapTarget),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.md,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.smBorder,
        ),
        textStyle: AppTextStyles.labelLarge,
      ),
    );
  }

  static TextButtonThemeData _buildTextButtonTheme(
      {required bool isDark}) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: isDark
            ? AppColors.darkInteractivePrimary
            : AppColors.interactivePrimary,
        minimumSize: const Size(0, AppSpacing.minTapTarget),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        textStyle: AppTextStyles.labelLarge,
      ),
    );
  }

  static InputDecorationTheme _buildInputDecorationTheme(
      {required bool isDark}) {
    return InputDecorationTheme(
      filled: true,
      fillColor:
          isDark ? AppColors.darkBgLayer1 : AppColors.bgLayer1,
      border: OutlineInputBorder(
        borderRadius: AppRadius.smBorder,
        borderSide: BorderSide(
          color: isDark
              ? AppColors.darkBorderDefault
              : AppColors.borderDefault,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.smBorder,
        borderSide: BorderSide(
          color: isDark
              ? AppColors.darkBorderDefault
              : AppColors.borderDefault,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.smBorder,
        borderSide: BorderSide(
          color: isDark
              ? AppColors.darkBorderFocused
              : AppColors.borderFocused,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppRadius.smBorder,
        borderSide: BorderSide(
          color: isDark
              ? AppColors.darkBorderError
              : AppColors.borderError,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppRadius.smBorder,
        borderSide: BorderSide(
          color: isDark
              ? AppColors.darkBorderError
              : AppColors.borderError,
          width: 2,
        ),
      ),
      labelStyle: AppTextStyles.bodyMedium.copyWith(
        color: isDark
            ? AppColors.darkTextDescription
            : AppColors.textDescription,
      ),
      hintStyle: AppTextStyles.bodyMedium.copyWith(
        color: isDark
            ? AppColors.darkTextPlaceholder
            : AppColors.textPlaceholder,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
    );
  }

  static CardTheme _buildCardTheme({required bool isDark}) {
    return CardTheme(
      elevation: 0,
      color: isDark ? AppColors.darkBgLayer1 : AppColors.bgBase,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.lgBorder,
        side: BorderSide(
          color: isDark
              ? AppColors.darkBorderDefault
              : AppColors.borderDefault,
        ),
      ),
      margin: EdgeInsets.zero,
    );
  }

  static DividerThemeData _buildDividerTheme({required bool isDark}) {
    return DividerThemeData(
      color: isDark ? AppColors.darkBorderDefault : AppColors.borderDefault,
      thickness: 1,
      space: 0,
    );
  }

  static DrawerThemeData _buildDrawerTheme({required bool isDark}) {
    return DrawerThemeData(
      backgroundColor:
          isDark ? AppColors.darkBgBase : AppColors.bgBase,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(AppRadius.none),
          bottomRight: Radius.circular(AppRadius.none),
        ),
      ),
    );
  }

  static NavigationBarThemeData _buildNavigationBarTheme(
      {required bool isDark}) {
    return NavigationBarThemeData(
      backgroundColor:
          isDark ? AppColors.darkBgBase : AppColors.bgBase,
      indicatorColor: Colors.transparent,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(
            color: isDark
                ? AppColors.darkInteractivePrimary
                : AppColors.interactivePrimary,
          );
        }
        return IconThemeData(
          color: isDark
              ? AppColors.darkTextDescription
              : AppColors.textDescription,
        );
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppTextStyles.labelSmall.copyWith(
            color: isDark
                ? AppColors.darkInteractivePrimary
                : AppColors.interactivePrimary,
          );
        }
        return AppTextStyles.labelSmall.copyWith(
          color: isDark
              ? AppColors.darkTextDescription
              : AppColors.textDescription,
        );
      }),
    );
  }

  static SnackBarThemeData _buildSnackBarTheme({required bool isDark}) {
    return SnackBarThemeData(
      backgroundColor: isDark ? AppColors.sumi100 : AppColors.sumi800,
      contentTextStyle: AppTextStyles.bodyMedium.copyWith(
        color: isDark ? AppColors.sumi900 : AppColors.white,
      ),
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.smBorder,
      ),
    );
  }
}


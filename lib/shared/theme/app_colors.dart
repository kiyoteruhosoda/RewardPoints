import 'package:flutter/material.dart';

/// デジタル庁デザインシステム カラートークン
/// https://design.digital.go.jp/dads/foundations/color/
class AppColors {
  AppColors._();

  // ─── Primitive: Blue ───────────────────────────────────────────────
  static const Color blue100 = Color(0xFFE8F1FE);
  static const Color blue200 = Color(0xFFD9E6FF);
  static const Color blue300 = Color(0xFFC5D7FB);
  static const Color blue400 = Color(0xFF9DB7F9);
  static const Color blue500 = Color(0xFF7096F8);
  static const Color blue600 = Color(0xFF4979F5);
  static const Color blue700 = Color(0xFF3460FB);
  static const Color blue800 = Color(0xFF264AF4);
  static const Color blue900 = Color(0xFF0031D8);
  static const Color blue1000 = Color(0xFF0017C1);
  static const Color blue1100 = Color(0xFF00118F);
  static const Color blue1200 = Color(0xFF000071);
  static const Color blue1300 = Color(0xFF000060);

  // ─── Primitive: Red ────────────────────────────────────────────────
  static const Color red100 = Color(0xFFFDEEEE);
  static const Color red200 = Color(0xFFFAD7D7);
  static const Color red300 = Color(0xFFF9BFBF);
  static const Color red400 = Color(0xFFF78888);
  static const Color red500 = Color(0xFFF45151);
  static const Color red600 = Color(0xFFF03030);
  static const Color red700 = Color(0xFFFA0000);
  static const Color red800 = Color(0xFFEC0000);
  static const Color red900 = Color(0xFFCE0000);
  static const Color red1000 = Color(0xFFAD0000);
  static const Color red1100 = Color(0xFF850000);
  static const Color red1200 = Color(0xFF620000);

  // ─── Primitive: Green ──────────────────────────────────────────────
  static const Color green100 = Color(0xFFE6F5EC);
  static const Color green200 = Color(0xFFC2E5D1);
  static const Color green300 = Color(0xFF9BD4B6);
  static const Color green400 = Color(0xFF5CBB8A);
  static const Color green500 = Color(0xFF34A36E);
  static const Color green600 = Color(0xFF259D63);
  static const Color green700 = Color(0xFF1D8B56);
  static const Color green800 = Color(0xFF197A4B);
  static const Color green900 = Color(0xFF115A36);
  static const Color green1000 = Color(0xFF0C3F26);
  static const Color green1100 = Color(0xFF08351F);
  static const Color green1200 = Color(0xFF032213);

  // ─── Primitive: Yellow ─────────────────────────────────────────────
  static const Color yellow100 = Color(0xFFFBF5E0);
  static const Color yellow200 = Color(0xFFFFF0B3);
  static const Color yellow300 = Color(0xFFFAE67A);
  static const Color yellow400 = Color(0xFFF5D830);
  static const Color yellow500 = Color(0xFFE0C400);
  static const Color yellow600 = Color(0xFFCDAF00);
  static const Color yellow700 = Color(0xFFB78F00);
  static const Color yellow800 = Color(0xFFAA8400);
  static const Color yellow900 = Color(0xFF927200);
  static const Color yellow1000 = Color(0xFF7A5F00);
  static const Color yellow1100 = Color(0xFF6E5600);
  static const Color yellow1200 = Color(0xFF604B00);

  // ─── Primitive: Orange ─────────────────────────────────────────────
  static const Color orange100 = Color(0xFFFFEEE2);
  static const Color orange600 = Color(0xFFFB5B01);
  static const Color orange800 = Color(0xFFC74700);

  // ─── Neutral: Sumi (SolidGray) ─────────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  static const Color sumi50 = Color(0xFFF2F2F2);
  static const Color sumi100 = Color(0xFFE6E6E6);
  static const Color sumi200 = Color(0xFFCCCCCC);
  static const Color sumi300 = Color(0xFFB3B3B3);
  static const Color sumi400 = Color(0xFF999999);
  static const Color sumi420 = Color(0xFF949494);
  static const Color sumi500 = Color(0xFF7F7F7F);
  static const Color sumi536 = Color(0xFF767676);
  static const Color sumi600 = Color(0xFF666666);
  static const Color sumi700 = Color(0xFF4D4D4D);
  static const Color sumi800 = Color(0xFF333333);
  static const Color sumi900 = Color(0xFF1A1A1A);

  // ─── Semantic: Light Theme ─────────────────────────────────────────
  // Background
  static const Color bgBase = white;
  static const Color bgLayer1 = sumi50;
  static const Color bgLayer2 = Color(0xFFE8F1FE); // blue100

  // Text
  static const Color textBody = sumi900;
  static const Color textDescription = sumi700;
  static const Color textPlaceholder = sumi400;
  static const Color textDisabled = sumi300;
  static const Color textOnFill = white;
  static const Color textLink = blue900;
  static const Color textLinkVisited = Color(0xFF6B21A8); // purple

  // Interactive / Primary
  static const Color interactivePrimary = blue800;
  static const Color interactivePrimaryHover = blue900;
  static const Color interactivePrimaryPressed = blue1000;
  static const Color interactivePrimaryDisabled = sumi200;

  // Border
  static const Color borderDefault = sumi200;
  static const Color borderFocused = blue800;
  static const Color borderError = red800;
  static const Color borderDisabled = sumi100;

  // Status
  static const Color statusSuccess = green600;
  static const Color statusSuccessBg = green100;
  static const Color statusError = red800;
  static const Color statusErrorBg = red100;
  static const Color statusWarning = yellow700;
  static const Color statusWarningBg = yellow100;
  static const Color statusInfo = blue800;
  static const Color statusInfoBg = blue100;

  // ─── Semantic: Dark Theme ──────────────────────────────────────────
  static const Color darkBgBase = sumi900;
  static const Color darkBgLayer1 = sumi800;
  static const Color darkBgLayer2 = sumi700;

  static const Color darkTextBody = white;
  static const Color darkTextDescription = sumi200;
  static const Color darkTextPlaceholder = sumi500;
  static const Color darkTextDisabled = sumi600;

  static const Color darkInteractivePrimary = blue400;
  static const Color darkInteractivePrimaryHover = blue300;
  static const Color darkInteractivePrimaryPressed = blue200;

  static const Color darkBorderDefault = sumi700;
  static const Color darkBorderFocused = blue400;
  static const Color darkBorderError = red500;
}

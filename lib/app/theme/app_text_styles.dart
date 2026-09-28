import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

/// Geepay POS design tokens: type scale (plan §2.2).
///
/// Inter for UI text, DM Sans for headings and numbers. Sizes are whole
/// numbers and line heights sit on a 4pt rhythm. Every style defaults to
/// [AppColors.textPrimary]; recolour with `copyWith(color: ...)`.
/// Weights are limited to 400 / 500 / 600 / 700.
///
/// Never change `fontWeight` with `copyWith`: each Google Fonts style is
/// bound to the font file for its weight, so a different weight is faked
/// by the engine. Add a style here instead.
abstract final class AppTextStyles {
  static TextStyle _dmSans(
    double size,
    double lineHeight,
    FontWeight weight, {
    double trackingEm = 0,
    bool tabular = false,
  }) {
    return GoogleFonts.dmSans(
      fontSize: size,
      height: lineHeight / size,
      fontWeight: weight,
      letterSpacing: trackingEm * size,
      color: AppColors.textPrimary,
      fontFeatures: tabular ? const [FontFeature.tabularFigures()] : null,
    );
  }

  static TextStyle _inter(
    double size,
    double lineHeight,
    FontWeight weight, {
    double trackingEm = 0,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      height: lineHeight / size,
      fontWeight: weight,
      letterSpacing: trackingEm * size,
      color: AppColors.textPrimary,
    );
  }

  /// 32/40 DM Sans 700, tabular. Hero amount.
  static final TextStyle display = _dmSans(
    32,
    40,
    FontWeight.w700,
    trackingEm: -0.02,
    tabular: true,
  );

  /// 24/32 DM Sans 700. Auth screen titles, result headline.
  static final TextStyle title1 = _dmSans(
    24,
    32,
    FontWeight.w700,
    trackingEm: -0.01,
  );

  /// 20/28 DM Sans 700. Large page titles, greeting name.
  static final TextStyle title2 = _dmSans(
    20,
    28,
    FontWeight.w700,
    trackingEm: -0.01,
  );

  /// 18/24 DM Sans 700. App bar titles.
  static final TextStyle title3 = _dmSans(18, 24, FontWeight.w700);

  /// 16/24 DM Sans 700. Section and widget titles.
  static final TextStyle headline = _dmSans(16, 24, FontWeight.w700);

  /// 16/24 Inter 400. Input text, primary copy.
  static final TextStyle bodyLg = _inter(16, 24, FontWeight.w400);

  /// 14/20 Inter 400. Body copy, descriptions.
  static final TextStyle body = _inter(14, 20, FontWeight.w400);

  /// 14/20 Inter 600. List row titles, values.
  static final TextStyle bodyStrong = _inter(14, 20, FontWeight.w600);

  /// 13/16 Inter 600. Form labels, chip text, small buttons.
  static final TextStyle label = _inter(13, 16, FontWeight.w600);

  /// 13/16 Inter 700. Avatar initials.
  static final TextStyle labelStrong = _inter(13, 16, FontWeight.w700);

  /// 12/16 Inter 400. Metadata, helper text, timestamps.
  static final TextStyle caption = _inter(12, 16, FontWeight.w400);

  /// 12/16 Inter 600. Active navigation labels.
  static final TextStyle captionStrong = _inter(12, 16, FontWeight.w600);

  /// 11/16 Inter 700, +0.06em. Section labels and status pills. Callers
  /// pass upper-cased text.
  static final TextStyle overline = _inter(
    11,
    16,
    FontWeight.w700,
    trackingEm: 0.06,
  );

  /// 15/20 Inter 600. Large and medium buttons.
  static final TextStyle button = _inter(15, 20, FontWeight.w600);

  /// Number sizes for [gpNum] and `MoneyText`.
  static const double numDisplay = 32;
  static const double numLg = 24;
  static const double numMd = 18;
  static const double numBase = 16;
  static const double numSm = 14;

  /// `.gp-num`: DM Sans with tabular figures for every monetary / numeric
  /// value. Prefer the `MoneyText` widget for amounts.
  static TextStyle gpNum({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w600,
    Color? color,
  }) {
    return GoogleFonts.dmSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? AppColors.textPrimary,
      letterSpacing: -0.01 * fontSize,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  /// Material [TextTheme] mapped onto the scale above, so stock Material
  /// widgets (dialogs, list tiles, buttons) pick up the same styles.
  static TextTheme get textTheme => TextTheme(
    displaySmall: display,
    headlineMedium: title1,
    headlineSmall: title2,
    titleLarge: title3,
    titleMedium: headline,
    titleSmall: bodyStrong,
    bodyLarge: bodyLg,
    bodyMedium: body,
    bodySmall: caption.copyWith(color: AppColors.textTertiary),
    labelLarge: button,
    labelMedium: label,
    labelSmall: overline,
  );
}

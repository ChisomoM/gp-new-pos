import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Geepay POS design tokens — numeric/monetary text treatment.
///
/// Deviation from the design system's default (JetBrains Mono): numbers
/// looked "weird" in mono and were switched to DM Sans with tabular figures.
abstract class AppTextStyles {
  /// `.gp-num` equivalent — use for every monetary/numeric value rendered.
  static TextStyle gpNum({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w600,
    Color? color,
  }) {
    return GoogleFonts.dmSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: -0.01 * fontSize,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }
}

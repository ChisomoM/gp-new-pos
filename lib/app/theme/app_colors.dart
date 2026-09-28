import 'package:flutter/material.dart';

/// Geepay POS design tokens — colors.
///
/// Source of truth: the Geepay Design System
/// (see `geepay-pos-design-spec.md` §1 in the repo root).
abstract class AppColors {
  // Brand
  static const Color gpCobalt = Color(0xFF383D92);
  static const Color gpSky = Color(0xFF00AFEB);
  static const Color gpNavy = Color(0xFF080C30);

  // Surfaces
  static const Color surfacePage = Color(0xFFF9FAFB);
  static const Color surfaceWhite = Color(0xFFFFFFFF);

  // Semantic — success
  static const Color successIcon = Color(0xFF10B981);
  static const Color successText = Color(0xFF065F46);
  static const Color successFill = Color(0xFFD1FAE5);

  // Semantic — warning
  static const Color warningText = Color(0xFFA15C00);
  static const Color warningFill = Color(0xFFFFF4D6);

  // Semantic — danger
  static const Color dangerIcon = Color(0xFFE11D2E);
  static const Color dangerText = Color(0xFF991B1B);
  static const Color dangerFill = Color(0xFFFDE8E8);
  static const Color dangerFillAlt = Color(0xFFFEE2E2);

  // Semantic — info
  static const Color infoText = Color(0xFF383D92);
  static const Color infoFill = Color(0xFFECECF8);

  // Neutral text
  static const Color textPrimary = Color(0xFF141A34);
  static const Color textSecondary = Color(0xFF272F4A);
  static const Color textTertiary = Color(0xFF70788F);
  static const Color textMuted = Color(0xFF9AA0B8);

  // Borders / dividers
  static const Color borderLight = Color(0xFFEEF0F5);
  static const Color borderMedium = Color(0xFFDDE0EB);
  static const Color divider = Color(0xFFF3F4F6);
}

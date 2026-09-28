import 'package:flutter/material.dart';

/// Geepay POS design tokens: colors.
///
/// Source of truth: the Geepay Design System (see
/// `geepay-pos-design-spec.md` §1 and `docs/ui-ux-polish-plan.md` §2.3).
/// Widgets never use raw `Color(0x...)` literals; add a token here instead.
abstract final class AppColors {
  // Brand
  static const Color gpCobalt = Color(0xFF383D92);
  static const Color gpSky = Color(0xFF00AFEB);
  static const Color gpNavy = Color(0xFF080C30);

  /// Middle stop of the brand gradient.
  static const Color gpAzure = Color(0xFF2B6FC2);

  // Surfaces
  static const Color surfacePage = Color(0xFFF9FAFB);
  static const Color surfaceWhite = Color(0xFFFFFFFF);

  /// Quiet fill for icon buttons, skeleton highlights and pressed rows.
  static const Color surfaceSubtle = Color(0xFFF7F8FA);

  // Semantic: success
  static const Color successIcon = Color(0xFF10B981);
  static const Color successText = Color(0xFF065F46);
  static const Color successFill = Color(0xFFD1FAE5);

  // Semantic: warning
  static const Color warningIcon = Color(0xFFD97706);
  static const Color warningText = Color(0xFFA15C00);
  static const Color warningFill = Color(0xFFFFF4D6);

  // Semantic: danger
  static const Color dangerIcon = Color(0xFFE11D2E);
  static const Color dangerText = Color(0xFF991B1B);
  static const Color dangerFill = Color(0xFFFDE8E8);
  static const Color dangerFillAlt = Color(0xFFFEE2E2);

  // Semantic: info
  static const Color infoText = Color(0xFF383D92);
  static const Color infoFill = Color(0xFFECECF8);

  // Neutral text
  static const Color textPrimary = Color(0xFF141A34);
  static const Color textSecondary = Color(0xFF272F4A);

  /// Darkened from #70788F so it passes WCAG AA (4.5:1) on white.
  static const Color textTertiary = Color(0xFF646C84);

  /// Placeholders, disabled text and decorative icons only. Fails AA for
  /// body text, so never use it for information the user needs to read.
  static const Color textMuted = Color(0xFF9AA0B8);

  // Selection (chips, choice cards)
  static const Color selectedText = Color(0xFF141644);
  static const Color unselectedText = Color(0xFF3D4560);

  // Borders / dividers
  static const Color borderLight = Color(0xFFEEF0F5);
  static const Color borderMedium = Color(0xFFDDE0EB);
  static const Color borderSubtle = Color(0xFFF0F1F5);
  static const Color divider = Color(0xFFF3F4F6);

  // States
  static const Color disabledFill = Color(0xFFB9BDD6);
  static const Color focusRing = Color(0x66383D92); // cobalt @ 40%
  static const Color pressedOverlay = Color(0x14383D92); // cobalt @ 8%
  static const Color hoverOverlay = Color(0x0A383D92); // cobalt @ 4%

  // Text and strokes on brand gradients
  static const Color onBrandHigh = Color(0xFFFFFFFF);
  static const Color onBrandMid = Color(0xC2FFFFFF); // white @ 76%
  static const Color onBrandLow = Color(0x99FFFFFF); // white @ 60%
  static const Color onBrandStroke = Color(0x29FFFFFF); // white @ 16%
  static const Color onBrandFill = Color(0x14FFFFFF); // white @ 8%
  static const Color successOnBrand = Color(0xFF6EE7B7);
  static const Color dangerOnBrand = Color(0xFFFCA5A5);

  // Mobile money channels. Deliberately non-semantic hues so a channel
  // avatar never reads as a success / pending / failed status.
  static const Color channelMtnText = Color(0xFF00729A);
  static const Color channelMtnFill = Color(0xFFE0F5FD);
  static const Color channelAirtelText = Color(0xFF6B3FC9);
  static const Color channelAirtelFill = Color(0xFFF1EBFD);
  static const Color channelZamtelText = Color(0xFF383D92);
  static const Color channelZamtelFill = Color(0xFFECECF8);

  // Skeletons
  static const Color skeletonBase = Color(0xFFEEF0F5);
  static const Color skeletonHighlight = Color(0xFFF7F8FA);

  /// Tooltip / inverse surface.
  static const Color inverseSurface = Color(0xFF141A34);
}

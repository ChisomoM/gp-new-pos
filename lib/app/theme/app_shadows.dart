import 'package:flutter/painting.dart';

/// Geepay POS design tokens: elevation (plan §2.5).
///
/// A surface gets either a border (level 0, "flat") or one of these
/// shadows, never both. Shadows are navy tinted, never black.
abstract final class AppShadows {
  /// Level 1: cards resting on the grey page background.
  /// `0 1px 3px rgba(8,12,48,0.06), 0 4px 16px rgba(8,12,48,0.05)`
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color.fromRGBO(8, 12, 48, 0.06),
      offset: Offset(0, 1),
      blurRadius: 3,
    ),
    BoxShadow(
      color: Color.fromRGBO(8, 12, 48, 0.05),
      offset: Offset(0, 4),
      blurRadius: 16,
    ),
  ];

  /// Level 2: floating cards over a hero, sticky bottom action bars.
  static const List<BoxShadow> raised = [
    BoxShadow(
      color: Color.fromRGBO(8, 12, 48, 0.06),
      offset: Offset(0, 2),
      blurRadius: 8,
    ),
    BoxShadow(
      color: Color.fromRGBO(8, 12, 48, 0.08),
      offset: Offset(0, 8),
      blurRadius: 24,
    ),
  ];

  /// Level 3: dialogs, sheets, toasts, menus.
  static const List<BoxShadow> overlay = [
    BoxShadow(
      color: Color.fromRGBO(8, 12, 48, 0.10),
      offset: Offset(0, 8),
      blurRadius: 24,
    ),
    BoxShadow(
      color: Color.fromRGBO(8, 12, 48, 0.14),
      offset: Offset(0, 24),
      blurRadius: 48,
    ),
  ];

  /// Upward shadow for bars pinned to the bottom edge.
  static const List<BoxShadow> bottomBar = [
    BoxShadow(
      color: Color.fromRGBO(8, 12, 48, 0.06),
      offset: Offset(0, -4),
      blurRadius: 16,
    ),
  ];

  /// Brand glow: the primary gradient button only.
  /// `0 4px 16px rgba(0,175,235,0.30), 0 1px 3px rgba(56,61,146,0.20)`
  static const List<BoxShadow> brandGlow = [
    BoxShadow(
      color: Color.fromRGBO(0, 175, 235, 0.30),
      offset: Offset(0, 4),
      blurRadius: 16,
    ),
    BoxShadow(
      color: Color.fromRGBO(56, 61, 146, 0.20),
      offset: Offset(0, 1),
      blurRadius: 3,
    ),
  ];
}

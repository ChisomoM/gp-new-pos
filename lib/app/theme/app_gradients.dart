import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/app_colors.dart';

/// Geepay POS design tokens — gradients and elevation shadows.
///
/// CSS `linear-gradient(<deg>, ...)` angles are converted to Flutter
/// begin/end [Alignment]s by projecting the angle's direction vector onto
/// the box (0deg = up, 90deg = right, clockwise) — a plain corner-to-corner
/// alignment (topLeft → bottomRight) is always 135deg, which visibly leans
/// the wrong way for anything else, so the exact angle is reproduced here
/// instead.
abstract class AppGradients {
  /// Primary gradient — gradient CTA buttons.
  /// `linear-gradient(115deg, #383d92 0%, #2b6fc2 48%, #00afeb 100%)`
  static const LinearGradient primary = LinearGradient(
    begin: Alignment(-1, -0.4663),
    end: Alignment(1, 0.4663),
    colors: [
      AppColors.gpCobalt,
      Color(0xFF2B6FC2),
      AppColors.gpSky,
    ],
    stops: [0, 0.48, 1],
  );

  /// Hero background gradient — splash, setup header, login hero, dashboard
  /// header, settings header.
  ///
  /// Uses the exact same colors/angle as [primary] (the gradient CTA
  /// button) — the two are meant to read as one consistent brand gradient
  /// treatment, not two different blues, per direct feedback that hero
  /// sections should "follow" the button's gradient.
  static const LinearGradient hero = primary;

  /// Card resting shadow.
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

  /// Gradient button shadow.
  /// `0 4px 16px rgba(0,175,235,0.30), 0 1px 3px rgba(56,61,146,0.20)`
  static const List<BoxShadow> gradientButton = [
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

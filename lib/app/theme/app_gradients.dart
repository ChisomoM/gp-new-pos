import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/app_colors.dart';

/// Geepay POS design tokens: gradients. Shadows live in `AppShadows`.
///
/// CSS `linear-gradient(<deg>, ...)` angles are converted to Flutter
/// begin/end [Alignment]s by projecting the angle's direction vector onto
/// the box (0deg = up, 90deg = right, clockwise). A plain corner-to-corner
/// alignment (topLeft to bottomRight) is always 135deg, which visibly leans
/// the wrong way for anything else, so the exact angle is reproduced here.
abstract final class AppGradients {
  /// Primary gradient: primary buttons.
  /// `linear-gradient(115deg, #383d92 0%, #2b6fc2 48%, #00afeb 100%)`
  static const LinearGradient primary = LinearGradient(
    begin: Alignment(-1, -0.4663),
    end: Alignment(1, 0.4663),
    colors: [AppColors.gpCobalt, AppColors.gpAzure, AppColors.gpSky],
    stops: [0, 0.48, 1],
  );

  /// Hero background gradient: splash, setup header, login hero,
  /// dashboard header.
  ///
  /// Same colours and angle as [primary] so hero sections and the primary
  /// button read as one brand gradient treatment.
  static const LinearGradient hero = primary;
}

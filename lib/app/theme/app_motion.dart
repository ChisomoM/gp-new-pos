import 'package:flutter/widgets.dart';

/// Geepay POS design tokens: motion (plan §4).
///
/// Every animation uses one of these durations and curves. Read durations
/// through [AppMotion.of] so they collapse to zero when the platform asks
/// for reduced motion.
abstract final class AppMotion {
  /// Press feedback.
  static const Duration instant = Duration(milliseconds: 100);

  /// Colour / border changes, chip selection, focus.
  static const Duration fast = Duration(milliseconds: 150);

  /// Tab cross-fade, dropdowns, expand / collapse, toasts.
  static const Duration base = Duration(milliseconds: 200);

  /// Page transitions, sheets, dialogs.
  static const Duration slow = Duration(milliseconds: 300);

  /// Success moments, number count-up.
  static const Duration emphasis = Duration(milliseconds: 500);

  /// Delay between items in a staggered list entrance.
  static const Duration stagger = Duration(milliseconds: 30);

  /// Shimmer sweep for skeletons.
  static const Duration shimmer = Duration(milliseconds: 1200);

  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve standard = Curves.easeInOutCubic;
  static const Curve emphasized = Curves.easeOutBack;

  /// Scale applied to buttons and cards while pressed.
  static const double pressScale = 0.98;

  /// Whether the platform asked for reduced motion.
  static bool reduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  /// [duration], or [Duration.zero] when reduced motion is on.
  static Duration of(BuildContext context, Duration duration) =>
      reduced(context) ? Duration.zero : duration;
}

import 'package:flutter/widgets.dart';

/// Geepay POS design tokens: corner radius (plan §2.4).
///
/// Nested corners use `outer - padding`, so a tile inset 4px inside a
/// [lg] card uses [md].
abstract final class AppRadius {
  /// Small badges inside rows, tooltips.
  static const double xs = 6;

  /// Checkboxes, small icon buttons.
  static const double sm = 8;

  /// Buttons, inputs, chips, icon tiles, toasts.
  static const double md = 12;

  /// Cards and list groups.
  static const double lg = 16;

  /// Bottom sheets, dialogs, hero bottom edge.
  static const double xl = 24;

  /// Pills and avatars.
  static const double full = 999;

  static const BorderRadius brXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius brSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius brMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius brLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius brXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius brFull = BorderRadius.all(Radius.circular(full));
}

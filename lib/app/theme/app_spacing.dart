/// Geepay POS design tokens: spacing on a 4pt grid.
///
/// See `docs/ui-ux-polish-plan.md` §2.1. Hairlines (1px borders) are the
/// only values allowed outside this scale.
abstract final class AppSpace {
  static const double x0 = 0;
  static const double x1 = 4;
  static const double x2 = 8;
  static const double x3 = 12;
  static const double x4 = 16;
  static const double x5 = 20;
  static const double x6 = 24;
  static const double x8 = 32;
  static const double x10 = 40;
  static const double x12 = 48;
  static const double x16 = 64;

  /// Horizontal page margin.
  static const double gutter = x5;

  /// Padding inside cards.
  static const double card = x4;

  /// Gap between sections on a page.
  static const double section = x6;

  /// Gap between a label and its control.
  static const double label = x2;

  /// Gap between stacked form fields.
  static const double field = x4;

  /// Gap between a heading and its content.
  static const double heading = x3;
}

/// Component dimensions (plan §2.7).
abstract final class AppSize {
  /// Minimum hit area for anything tappable.
  static const double touchTarget = 48;

  static const double buttonLg = 52;
  static const double buttonMd = 44;
  static const double buttonSm = 36;

  static const double input = 52;
  static const double chip = 36;

  /// Visual size of an icon button (its hit area is [touchTarget]).
  static const double iconButton = 40;

  /// Avatars and icon tiles.
  static const double avatar = 40;

  static const double listRow = 64;
  static const double listRowCompact = 56;

  static const double appBar = 56;
  static const double navBar = 64;

  /// Max content width on tablets and landscape POS terminals.
  static const double maxContentWidth = 560;
}

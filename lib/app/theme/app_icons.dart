import 'package:flutter/widgets.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

/// Geepay POS icon system (plan §2.6).
///
/// Iconsax only, and every icon goes through this class so screens never
/// import `iconsax_flutter` directly and a glyph can be swapped in one
/// place.
///
/// Note on `iconsax_flutter` 1.0.1 naming: the plain names
/// (`Iconsax.home`) are the filled **Bold** glyphs and the `_copy` names
/// (`Iconsax.home_copy`) are the **Linear** outline glyphs. Linear is the
/// default style; Bold is reserved for active / selected states.
abstract final class AppIcons {
  // Navigation
  static const IconData back = Iconsax.arrow_left_2_copy; // chevron <
  static const IconData chevronRight = Iconsax.arrow_right_3_copy; // >
  static const IconData chevronDown = Iconsax.arrow_down_1_copy;
  static const IconData chevronUp = Iconsax.arrow_up_2_copy;
  static const IconData close = Iconsax.close_circle_copy;

  // Bottom navigation (linear / bold pairs)
  static const IconData home = Iconsax.home_copy;
  static const IconData homeActive = Iconsax.home;
  static const IconData history = Iconsax.clock_copy;
  static const IconData historyActive = Iconsax.clock;
  static const IconData settings = Iconsax.setting_2_copy;
  static const IconData settingsActive = Iconsax.setting_2;

  // Money and transactions
  /// Collect / request a payment (money coming in).
  static const IconData receive = Iconsax.money_recive_copy;
  static const IconData summary = Iconsax.chart_2_copy;
  static const IconData receipt = Iconsax.receipt_2_copy;
  static const IconData wallet = Iconsax.empty_wallet_copy;
  static const IconData calendar = Iconsax.calendar_copy;

  // Status
  static const IconData success = Iconsax.tick_circle_copy;
  static const IconData successFilled = Iconsax.tick_circle;
  static const IconData failed = Iconsax.close_circle_copy;
  static const IconData failedFilled = Iconsax.close_circle;
  static const IconData pending = Iconsax.timer_1_copy;
  static const IconData info = Iconsax.info_circle_copy;
  static const IconData warning = Iconsax.danger_copy;

  // Actions
  static const IconData printer = Iconsax.printer_copy;
  static const IconData share = Iconsax.export_1_copy;
  static const IconData export = Iconsax.document_download_copy;
  static const IconData copy = Iconsax.copy_copy;
  static const IconData refresh = Iconsax.refresh_circle_copy;
  static const IconData logout = Iconsax.logout_copy;
  static const IconData check = Iconsax.tick_square_copy;
  static const IconData eye = Iconsax.eye_copy;
  static const IconData eyeSlash = Iconsax.eye_slash_copy;

  // Objects
  static const IconData phone = Iconsax.call_copy;
  static const IconData device = Iconsax.mobile_copy;
  static const IconData bluetooth = Iconsax.bluetooth_copy;
  static const IconData business = Iconsax.building_copy;
  static const IconData lock = Iconsax.lock_1_copy;
  static const IconData security = Iconsax.shield_tick_copy;
  static const IconData notification = Iconsax.notification_copy;
  static const IconData comingSoon = Iconsax.timer_1_copy;

  // Payment Link
  static const IconData qrCode = Iconsax.scan_barcode_copy;
  static const IconData link = Iconsax.link_copy;
}

/// Icon sizes (plan §2.6).
abstract final class AppIconSize {
  /// Inline with caption / label text.
  static const double sm = 16;

  /// Controls, list rows, buttons.
  static const double md = 20;

  /// Navigation bar, app bar actions.
  static const double lg = 24;

  /// Feature icons in 56 to 64px circles (empty and result states).
  static const double xl = 32;
}

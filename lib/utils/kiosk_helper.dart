import 'dart:developer';

import 'package:auth_repo/auth_repo.dart';
import 'package:flutter/services.dart';
import 'package:geepay_pos/utils/constants.dart';
import 'package:geepay_pos/widgets/widgets.dart';

/// Bridge to this device's native kiosk-lock implementation, via the
/// `geepay_pos/kiosk` `MethodChannel` set up in `MainActivity.kt`'s
/// `setupKioskChannel`. Native-side, this always applies plain Android
/// screen pinning as a baseline and layers Topwise/Trendit vendor hardening
/// on top where available -- see `KioskHelper.kt`.
class KioskHelper {
  static const _platform = MethodChannel('geepay_pos/kiosk');

  /// Engages the kiosk lock. Called automatically on every app launch (see
  /// `SplashCubit`) and right after device registration (see
  /// `SetupCubit`). Native side reports back which vendor hardware was
  /// detected and whether each individual call succeeded (see
  /// `KioskHelper.kt`'s `enterKiosk`) -- that report is persisted via
  /// [authRepo] (so the kiosk-exit dialog can show "locked since ..."
  /// later) and surfaced immediately as a snackbar. A failure to reach the
  /// native side at all is only logged -- this runs silently in the
  /// background before the user sees anything.
  static Future<void> enterKiosk(AuthRepo authRepo) async {
    try {
      final result = await _platform.invokeMethod<Map<Object?, Object?>>(
        'enterKiosk',
      );
      final calls = (result?['calls'] as List?)
          ?.map((call) => (call as Map).cast<String, Object?>())
          .toList();
      if (calls == null || calls.isEmpty) return;

      final vendor = _primaryVendor(calls);
      final passed = calls.where((c) => c['success'] == true).length;
      final summary = '$passed/${calls.length} checks passed';
      await authRepo.setKioskStatus(vendor: vendor, summary: summary);

      final message = vendor == 'baseline'
          ? 'Kiosk mode activated (baseline lock only, no vendor hardware '
                'detected) — $summary'
          : 'Kiosk mode activated on ${_displayVendor(vendor)} — $summary';
      log(message, name: 'KioskHelper');
      final messenger = scaffoldMessengerKey.currentState;
      if (messenger != null) {
        showToastOn(
          messenger,
          message: message,
          tone: passed == calls.length ? ToastTone.success : ToastTone.error,
        );
      }
    } on Object catch (e) {
      // Catches both Exception (e.g. a MissingPluginException on a
      // platform/test harness with no native handler for this channel) and
      // Error (e.g. the Flutter services binding not being initialized yet,
      // as in a plain unit test): this runs unconditionally on every
      // launch and must never block app startup.
      log('Failed to enter kiosk mode: $e', name: 'KioskHelper');
    }
  }

  /// `"topwise"` and `"trendit"` entries mean that vendor's hardware was
  /// detected (regardless of whether its individual calls succeeded);
  /// `"baseline"` means neither vendor's SDK resolved on this device (e.g.
  /// an emulator), so only plain Android screen pinning applied.
  static String _primaryVendor(List<Map<String, Object?>> calls) {
    final vendors = calls.map((c) => c['vendor']).toSet();
    if (vendors.contains('topwise')) return 'topwise';
    if (vendors.contains('trendit')) return 'trendit';
    return 'baseline';
  }

  static String _displayVendor(String vendor) => switch (vendor) {
    'topwise' => 'Topwise',
    'trendit' => 'Trendit',
    _ => vendor,
  };

  /// Whether the kiosk lock is currently engaged, per the OS itself (not a
  /// cached flag). Used by the Settings screen's tap gesture to decide
  /// whether to show the PIN-exit dialog or just re-lock immediately.
  /// Defaults to `true` on any channel failure, matching today's behavior
  /// (show the PIN dialog) rather than silently re-locking.
  static Future<bool> isKioskActive() async {
    try {
      final active = await _platform.invokeMethod<bool>('isKioskActive');
      return active ?? true;
    } on Object catch (e) {
      log('Failed to check kiosk state: $e', name: 'KioskHelper');
      return true;
    }
  }

  /// Releases the kiosk lock. Only ever called after an admin has entered
  /// the correct exit PIN, so (unlike [enterKiosk]) this surfaces a toast --
  /// it's a direct, visible admin action.
  static Future<void> exitKiosk() async {
    try {
      await _platform.invokeMethod('exitKiosk');
      _showSuccess('Kiosk mode disabled');
    } on PlatformException catch (e) {
      _showError('Failed to exit kiosk mode: $e');
    }
  }

  static void _showSuccess(String message) {
    log(message, name: 'KioskHelper');
    final messenger = scaffoldMessengerKey.currentState;
    if (messenger != null) {
      showToastOn(messenger, message: message, tone: ToastTone.success);
    }
  }

  static void _showError(String message) {
    log(message, name: 'KioskHelper');
    final messenger = scaffoldMessengerKey.currentState;
    if (messenger != null) {
      showToastOn(messenger, message: message, tone: ToastTone.error);
    }
  }
}

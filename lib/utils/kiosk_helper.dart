import 'dart:developer';

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
  /// `SetupCubit`), so failures are only logged -- this runs silently in
  /// the background before the user sees anything.
  static Future<void> enterKiosk() async {
    try {
      await _platform.invokeMethod('enterKiosk');
    } on Object catch (e) {
      // Catches both Exception (e.g. a MissingPluginException on a
      // platform/test harness with no native handler for this channel) and
      // Error (e.g. the Flutter services binding not being initialized yet,
      // as in a plain unit test): this runs unconditionally on every
      // launch and must never block app startup.
      log('Failed to enter kiosk mode: $e', name: 'KioskHelper');
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

import 'package:flutter/services.dart';
import 'package:geepay_pos/utils/constants.dart';
import 'package:geepay_pos/utils/enums.dart';
import 'package:geepay_pos/widgets/widgets.dart';

/// Bridge to the device's built-in thermal printer (Trendit / Topwise POS
/// hardware), via a native Android `MethodChannel`. Only functions on
/// terminals whose native printer SDK is wired up on the Android side —
/// see `MainActivity.kt`'s `setupPrintChannel`. On any other device (or
/// until that native SDK integration is completed) every call resolves to
/// an "unavailable" error, which callers should treat as "fall back to the
/// Bluetooth backend" via [PrinterDispatch].
class PrintHelper {
  static const _platform = MethodChannel('geepay_pos/print');

  static Future<void> printReceipt(Map<String, String> receiptDetails) async {
    try {
      await _platform.invokeMethod('printReceipt', receiptDetails);
      _showSuccess('Receipt printed successfully');
    } on PlatformException catch (e) {
      _showError('Failed to print receipt: $e');
    }
  }

  static Future<void> printZescoReceipt(
    Map<String, String> receiptDetails,
  ) async {
    try {
      await _platform.invokeMethod('printZesco', receiptDetails);
      _showSuccess('Zesco receipt printed successfully');
    } on PlatformException catch (e) {
      _showError('Failed to print Zesco receipt: $e');
    }
  }

  static Future<void> printDailySummary(
    List<Map<String, String>> transactions,
  ) async {
    try {
      await _platform.invokeMethod('printDailySummary', transactions);
      _showSuccess('Summary printed');
    } on PlatformException catch (e) {
      _showError('Failed to print summary: $e');
    }
  }

  static void _showSuccess(String message) {
    final messenger = scaffoldMessengerKey.currentState;
    if (messenger != null) {
      showAppSnackBar(messenger, message: message, type: MessageType.success);
    }
  }

  static void _showError(String message) {
    final messenger = scaffoldMessengerKey.currentState;
    if (messenger != null) {
      showAppSnackBar(messenger, message: message, type: MessageType.error);
    }
  }
}

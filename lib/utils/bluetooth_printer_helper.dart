import 'dart:developer';

import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geepay_pos/app/theme/app_logos.dart';
import 'package:geepay_pos/utils/constants.dart';
import 'package:geepay_pos/utils/printer_preference.dart';
import 'package:geepay_pos/widgets/widgets.dart';
import 'package:image/image.dart' as img;
import 'package:permission_client/permission_client.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

/// External Bluetooth ESC/POS thermal printer backend. Mirrors the field
/// layout of the native built-in-printer receipts (see the Trendit/Topwise
/// integration notes), translated into ESC/POS commands instead of native
/// SDK calls. Pure Dart/Flutter plugin — no native Android code required.
class BluetoothPrinterHelper {
  static const _permissionClient = PermissionClient();
  static CapabilityProfile? _profile;
  static const _dividerWidth = 32;

  static Future<bool> ensureBluetoothPermission() async {
    final granted = await PrintBluetoothThermal.isPermissionBluetoothGranted;
    if (granted) return true;
    final status = await _permissionClient.requestBluetoothConnect();
    return status.isGranted;
  }

  static Future<List<BluetoothInfo>> getPairedDevices() async {
    final granted = await ensureBluetoothPermission();
    if (!granted) return [];
    return PrintBluetoothThermal.pairedBluetooths;
  }

  static Future<bool> connect(String macAddress) async {
    final granted = await ensureBluetoothPermission();
    if (!granted) return false;
    return PrintBluetoothThermal.connect(macPrinterAddress: macAddress);
  }

  static Future<bool> isConnected() {
    return PrintBluetoothThermal.connectionStatus;
  }

  static Future<void> printReceipt(Map<String, dynamic> receiptDetails) async {
    final generator = await _buildGenerator();
    if (generator == null) return;

    final isReprint = receiptDetails['isReprint']?.toString() == 'true';
    final reprintCount = int.tryParse('${receiptDetails['reprintCount']}') ?? 1;

    var bytes = <int>[];
    bytes += _line(
      generator,
      receiptDetails['businessName'],
      align: PosAlign.center,
      bold: true,
      size: PosTextSize.size2,
    );
    bytes += _line(
      generator,
      receiptDetails['branchName'],
      align: PosAlign.center,
    );
    bytes += generator.feed(1);
    bytes += _line(generator, 'Cashier: ${_field(receiptDetails, 'username')}');
    bytes += _line(generator, 'Amount: ${_field(receiptDetails, 'amount')}');
    bytes += _line(generator, 'Phone: ${_field(receiptDetails, 'phone')}');
    bytes += _line(
      generator,
      'Payment Channel: ${_field(receiptDetails, 'paymentChannel')}',
    );
    bytes += _line(
      generator,
      'Transaction ID: ${_field(receiptDetails, 'transactionId')}',
    );
    bytes += _line(generator, 'Date: ${_field(receiptDetails, 'date')}');
    bytes += _line(generator, 'Status: ${_field(receiptDetails, 'status')}');
    bytes += generator.feed(1);
    if (isReprint) {
      bytes += _line(generator, '*** REPRINT COPY ***', align: PosAlign.center);
      bytes += _line(
        generator,
        'Printed $reprintCount time(s)',
        align: PosAlign.center,
      );
      bytes += generator.feed(1);
    }
    bytes += _divider(generator);
    bytes += _line(
      generator,
      'Thank you for your purchase!',
      align: PosAlign.center,
    );
    bytes += generator.feed(1);
    bytes += await _logo(generator);
    bytes += generator.feed(2);
    bytes += generator.cut();

    await _send(
      bytes,
      'Receipt printed successfully',
      'Failed to print receipt',
    );
  }

  static Future<void> printZescoReceipt(
    Map<String, dynamic> receiptDetails,
  ) async {
    final generator = await _buildGenerator();
    if (generator == null) return;

    var bytes = <int>[];
    bytes += _line(
      generator,
      receiptDetails['businessName'],
      align: PosAlign.center,
      bold: true,
      size: PosTextSize.size2,
    );
    bytes += _line(
      generator,
      receiptDetails['branchName'],
      align: PosAlign.center,
    );
    bytes += generator.feed(1);
    bytes += _line(generator, 'Cashier: ${_field(receiptDetails, 'username')}');
    bytes += _line(
      generator,
      'Customer Name: ${_field(receiptDetails, 'customerName')}',
    );
    bytes += _line(generator, 'Address: ${_field(receiptDetails, 'address')}');
    bytes += _line(generator, 'Token: ${_field(receiptDetails, 'token')}');
    bytes += _line(
      generator,
      'Meter Number: ${_field(receiptDetails, 'meterNumber')}',
    );
    bytes += _line(
      generator,
      'Number of Units: ${_field(receiptDetails, 'numberOfUnits')}',
    );
    bytes += _line(
      generator,
      'Kwh Amount: ${_field(receiptDetails, 'kwhAmount')}',
    );
    bytes += _line(
      generator,
      'Amount Paid: ${_field(receiptDetails, 'amountPaid')}',
    );
    bytes += _line(generator, 'VAT: ${_field(receiptDetails, 'vat')}');
    bytes += _line(
      generator,
      'Voucher Serial: ${_field(receiptDetails, 'serialNumber')}',
    );
    bytes += _line(
      generator,
      'Transaction Date: ${_field(receiptDetails, 'date')}',
    );
    bytes += _divider(generator);
    bytes += generator.feed(1);
    bytes += _line(
      generator,
      'Thank you for your purchase!',
      align: PosAlign.center,
    );
    bytes += generator.feed(1);
    bytes += await _logo(generator);
    bytes += generator.feed(2);
    bytes += generator.cut();

    await _send(
      bytes,
      'Zesco receipt printed successfully',
      'Failed to print Zesco receipt',
    );
  }

  static Future<void> printDailySummary(
    List<Map<String, dynamic>> transactions,
  ) async {
    final generator = await _buildGenerator();
    if (generator == null) return;

    var successCount = 0;
    var failedCount = 0;
    var totalCount = 0;
    var totalAmount = 0.0;

    var bytes = <int>[];
    bytes += _line(
      generator,
      'Daily Transaction Summary',
      align: PosAlign.center,
      bold: true,
    );
    bytes += generator.feed(1);

    for (final txn in transactions) {
      totalCount++;
      bytes += _line(generator, 'Business: ${_field(txn, 'businessName')}');
      bytes += _line(generator, 'Cashier: ${_field(txn, 'cashier')}');
      bytes += _line(generator, 'ID: ${_field(txn, 'transactionId')}');
      bytes += _line(generator, 'Amount: K${_field(txn, 'amount')}');
      bytes += _line(generator, 'Network: ${_field(txn, 'network')}');
      bytes += _line(generator, 'Status: ${_field(txn, 'status')}');
      bytes += _line(generator, 'Date: ${_field(txn, 'date')}');
      bytes += _divider(generator);
      bytes += generator.feed(1);

      final status = _field(txn, 'status').toLowerCase();
      if (status == 'successful') {
        totalAmount += double.tryParse(_field(txn, 'amount')) ?? 0;
        successCount++;
      } else if (status == 'failed') {
        failedCount++;
      }
    }

    bytes += _line(generator, '--- Summary Totals ---');
    bytes += generator.feed(1);
    bytes += _line(generator, 'Total Transactions: $totalCount');
    bytes += _line(generator, 'Successful Transactions: $successCount');
    bytes += _line(generator, 'Failed Transactions: $failedCount');
    bytes += _line(
      generator,
      'Total Amount(Successful): ZMW ${totalAmount.toStringAsFixed(2)}',
    );
    bytes += generator.feed(1);
    bytes += _line(generator, 'Thank you!', align: PosAlign.center);
    bytes += generator.feed(2);
    bytes += generator.cut();

    await _send(bytes, 'Summary printed', 'Could not print summary');
  }

  static String _field(Map<String, dynamic> data, String key) {
    return data[key]?.toString() ?? '';
  }

  static Future<Generator?> _buildGenerator() async {
    try {
      _profile ??= await CapabilityProfile.load();
      return Generator(PaperSize.mm58, _profile!);
    } catch (e) {
      _showError('Failed to prepare printer: $e');
      return null;
    }
  }

  static List<int> _line(
    Generator generator,
    dynamic text, {
    PosAlign align = PosAlign.left,
    bool bold = false,
    PosTextSize size = PosTextSize.size1,
  }) {
    return generator.text(
      text?.toString() ?? '',
      styles: PosStyles(align: align, bold: bold, height: size, width: size),
    );
  }

  static List<int> _divider(Generator generator) {
    return generator.text(
      '-' * _dividerWidth,
      styles: const PosStyles(align: PosAlign.center),
    );
  }

  static Future<List<int>> _logo(Generator generator) async {
    try {
      final data = await rootBundle.load(AppLogos.gMark);
      final decoded = img.decodePng(data.buffer.asUint8List());
      if (decoded == null) return [];
      return generator.imageRaster(decoded);
    } catch (_) {
      return [];
    }
  }

  static Future<void> _send(
    List<int> bytes,
    String successMessage,
    String failureMessage,
  ) async {
    try {
      final address = await PrinterPreference.getBluetoothAddress();
      if (address == null || address.isEmpty) {
        _showError(
          'No Bluetooth printer selected. Set one in Printer Settings.',
        );
        return;
      }

      var connected = await PrintBluetoothThermal.connectionStatus;
      if (!connected) {
        connected = await connect(address);
      }
      if (!connected) {
        _showError('Could not connect to Bluetooth printer.');
        return;
      }

      final success = await PrintBluetoothThermal.writeBytes(bytes);
      if (success) {
        _showSuccess(successMessage);
      } else {
        _showError(failureMessage);
      }
    } catch (e) {
      _showError('$failureMessage: $e');
    }
  }

  static void _showSuccess(String message) {
    log(message, name: 'BluetoothPrinterHelper');
    final messenger = scaffoldMessengerKey.currentState;
    if (messenger != null) {
      showToastOn(messenger, message: message, tone: ToastTone.success);
    }
  }

  static void _showError(String message) {
    log(message, name: 'BluetoothPrinterHelper');
    final messenger = scaffoldMessengerKey.currentState;
    if (messenger != null) {
      showToastOn(messenger, message: message, tone: ToastTone.error);
    }
  }
}

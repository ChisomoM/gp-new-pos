import 'dart:io';
import 'dart:typed_data';

import 'package:excel/excel.dart' as xls;
import 'package:geepay_pos/models/transaction.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

/// Generates and shares PDF / Excel exports for the Transaction History
/// list and the Cashier Summary totals.
///
/// Only "essential" fields are included per row — date, customer, channel,
/// amount and status — never the raw transaction ID/reference, which is
/// operational detail rather than something a printed/exported record
/// needs to carry.
abstract final class TransactionExport {
  static final _rowDateFormat = DateFormat('MMM d, y h:mm a');
  static final _generatedAtFormat = DateFormat('MMM d, y h:mm a');

  static const _headers = ['Date', 'Customer', 'Channel', 'Amount', 'Status'];

  static List<List<String>> _rows(List<Transaction> transactions) {
    return [
      for (final tx in transactions)
        [
          tx.processedAt == null ? '-' : _rowDateFormat.format(tx.processedAt!),
          tx.phoneNumber,
          tx.channelLabel,
          '${tx.currency} ${tx.amount.toStringAsFixed(2)}',
          _statusLabel(tx.status),
        ],
    ];
  }

  static String _statusLabel(String status) {
    final s = status.toLowerCase();
    if (s == 'successful' || s == 'success') return 'Successful';
    if (s == 'failed' || s == 'failure') return 'Failed';
    return 'Pending';
  }

  /// Exports a list of transactions (Transaction History) as a PDF table.
  static Future<void> transactionsToPdf({
    required String title,
    required List<Transaction> transactions,
  }) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        build: (context) => [
          _pdfHeader(title),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headers: _headers,
            data: _rows(transactions),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
            ),
            cellStyle: const pw.TextStyle(fontSize: 9),
            headerDecoration: const pw.BoxDecoration(
              color: PdfColors.grey300,
            ),
            cellAlignment: pw.Alignment.centerLeft,
            cellPadding: const pw.EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 6,
            ),
          ),
        ],
      ),
    );
    await _share(await doc.save(), _fileName(title, 'pdf'));
  }

  /// Exports a list of transactions (Transaction History) as an Excel
  /// spreadsheet.
  static Future<void> transactionsToExcel({
    required String title,
    required List<Transaction> transactions,
  }) async {
    final workbook = xls.Excel.createExcel();
    final sheet = workbook['Sheet1'];
    sheet.appendRow([for (final h in _headers) xls.TextCellValue(h)]);
    for (final row in _rows(transactions)) {
      sheet.appendRow([for (final cell in row) xls.TextCellValue(cell)]);
    }
    final bytes = workbook.save();
    if (bytes == null) return;
    await _share(Uint8List.fromList(bytes), _fileName(title, 'xlsx'));
  }

  /// Exports the Cashier Summary totals as a one-page PDF.
  static Future<void> summaryToPdf({
    required String title,
    required SummaryExportData summary,
  }) async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _pdfHeader(title),
            pw.SizedBox(height: 16),
            pw.TableHelper.fromTextArray(
              headers: const ['Metric', 'Value'],
              data: summary.rows,
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
              ),
              cellStyle: const pw.TextStyle(fontSize: 10),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
              cellAlignment: pw.Alignment.centerLeft,
            ),
          ],
        ),
      ),
    );
    await _share(await doc.save(), _fileName(title, 'pdf'));
  }

  /// Exports the Cashier Summary totals as an Excel spreadsheet.
  static Future<void> summaryToExcel({
    required String title,
    required SummaryExportData summary,
  }) async {
    final workbook = xls.Excel.createExcel();
    final sheet = workbook['Sheet1'];
    sheet.appendRow([xls.TextCellValue('Metric'), xls.TextCellValue('Value')]);
    for (final row in summary.rows) {
      sheet.appendRow([for (final cell in row) xls.TextCellValue(cell)]);
    }
    final bytes = workbook.save();
    if (bytes == null) return;
    await _share(Uint8List.fromList(bytes), _fileName(title, 'xlsx'));
  }

  static pw.Widget _pdfHeader(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Generated ${_generatedAtFormat.format(DateTime.now())}',
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
        ),
      ],
    );
  }

  static String _fileName(String title, String extension) {
    final safeTitle = title.trim().replaceAll(RegExp('[^A-Za-z0-9]+'), '_');
    final stamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    return '${safeTitle}_$stamp.$extension';
  }

  static Future<void> _share(Uint8List bytes, String filename) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
  }
}

/// Essential totals for a Cashier Summary export — the same figures shown
/// on screen, not a row-by-row transaction dump (that's what the
/// Transaction History export is for).
class SummaryExportData {
  const SummaryExportData({
    required this.periodLabel,
    required this.filterLabel,
    required this.currency,
    required this.totalAmount,
    required this.transactionCount,
    this.successfulAmount,
    this.successfulCount,
    this.failedAmount,
    this.failedCount,
  });

  final String periodLabel;
  final String filterLabel;
  final String currency;
  final double totalAmount;
  final int transactionCount;
  final double? successfulAmount;
  final int? successfulCount;
  final double? failedAmount;
  final int? failedCount;

  bool get hasBreakdown => successfulAmount != null;

  List<List<String>> get rows => [
    ['Period', periodLabel],
    ['Status filter', filterLabel],
    ['Total amount', '$currency ${totalAmount.toStringAsFixed(2)}'],
    ['Total transactions', '$transactionCount'],
    if (hasBreakdown) ...[
      [
        'Successful amount',
        '$currency ${successfulAmount!.toStringAsFixed(2)} ($successfulCount)',
      ],
      [
        'Failed amount',
        '$currency ${failedAmount!.toStringAsFixed(2)} ($failedCount)',
      ],
    ],
  ];
}

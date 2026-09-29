import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/design_system.dart';
import 'package:geepay_pos/widgets/widgets.dart';

enum _ExportFormat { pdf, excel }

/// Shows the "Export" bottom sheet (PDF / Excel) and runs the matching
/// generator. Used by Transaction History and Cashier Summary.
Future<void> showExportSheet(
  BuildContext context, {
  required Future<void> Function() onPdf,
  required Future<void> Function() onExcel,
}) async {
  final format = await showAppSheet<_ExportFormat>(
    context,
    title: 'Export',
    subtitle: 'Choose a file format to save or share.',
    child: ListGroup(
      children: [
        AppListTile(
          leading: const AppIconTile(icon: AppIcons.receipt),
          title: 'PDF document',
          subtitle: 'Best for viewing and printing',
          onTap: () => Navigator.of(context).pop(_ExportFormat.pdf),
        ),
        AppListTile(
          leading: const AppIconTile(icon: AppIcons.summary),
          title: 'Excel spreadsheet',
          subtitle: 'Best for further analysis',
          onTap: () => Navigator.of(context).pop(_ExportFormat.excel),
        ),
      ],
    ),
  );
  if (format == null || !context.mounted) return;

  try {
    await (format == _ExportFormat.pdf ? onPdf() : onExcel());
  } on Object {
    // File generation, disk or share-sheet failure - surfaced below rather
    // than left to crash the screen.
    if (context.mounted) {
      showToast(
        context,
        message: "Couldn't export the file. Try again.",
        tone: ToastTone.error,
      );
    }
  }
}

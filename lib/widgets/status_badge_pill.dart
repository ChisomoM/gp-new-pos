import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/app_colors.dart';

/// Solid pill status badge (SUCCESS/FAILED/PENDING), per the design spec's
/// component patterns: `font-size:10px; font-weight:700;
/// letter-spacing:0.03em; border-radius:999px; padding:2px 8px`.
class StatusBadgePill extends StatelessWidget {
  const StatusBadgePill({required this.status, super.key});

  /// A transaction status string, e.g. `successful`, `failed`, `pending`.
  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, fg, bg) = switch (status.toLowerCase()) {
      'successful' || 'success' => (
        'SUCCESS',
        AppColors.successText,
        AppColors.successFill,
      ),
      'failed' || 'failure' => (
        'FAILED',
        AppColors.dangerText,
        AppColors.dangerFill,
      ),
      _ => ('PENDING', AppColors.warningText, AppColors.warningFill),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
          color: fg,
        ),
      ),
    );
  }
}

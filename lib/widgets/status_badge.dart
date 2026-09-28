import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/design_system.dart';

enum BadgeTone { success, warning, danger, info, neutral }

/// Pill badge (plan §3). One component for transaction status and every
/// other status label (UP TO DATE, CONNECTED, DETECTED...).
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    required this.label,
    this.tone = BadgeTone.neutral,
    this.showDot = false,
    super.key,
  });

  /// Badge for a transaction status string such as `successful`,
  /// `failed` or `pending`.
  factory StatusBadge.transaction(String status, {Key? key}) {
    final (label, tone) = switch (status.toLowerCase()) {
      'successful' || 'success' => ('Success', BadgeTone.success),
      'failed' || 'failure' => ('Failed', BadgeTone.danger),
      _ => ('Pending', BadgeTone.warning),
    };
    return StatusBadge(label: label, tone: tone, key: key);
  }

  final String label;
  final BadgeTone tone;

  /// Leading 6px dot in the tone's strong colour.
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final (fg, bg, dot) = switch (tone) {
      BadgeTone.success => (
        AppColors.successText,
        AppColors.successFill,
        AppColors.successIcon,
      ),
      BadgeTone.warning => (
        AppColors.warningText,
        AppColors.warningFill,
        AppColors.warningIcon,
      ),
      BadgeTone.danger => (
        AppColors.dangerText,
        AppColors.dangerFill,
        AppColors.dangerIcon,
      ),
      BadgeTone.info => (
        AppColors.infoText,
        AppColors.infoFill,
        AppColors.gpCobalt,
      ),
      BadgeTone.neutral => (
        AppColors.textSecondary,
        AppColors.surfaceSubtle,
        AppColors.textMuted,
      ),
    };
    return Container(
      // 2px vertical padding + 16px line height = a 20px pill.
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.x2,
        vertical: 2,
      ),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.brFull),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
            ),
            const SizedBox(width: AppSpace.x1),
          ],
          Text(
            label.toUpperCase(),
            style: AppTextStyles.overline.copyWith(color: fg),
          ),
        ],
      ),
    );
  }
}

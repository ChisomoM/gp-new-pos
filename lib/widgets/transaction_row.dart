import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/app_colors.dart';
import 'package:geepay_pos/app/theme/app_text_styles.dart';
import 'package:geepay_pos/widgets/status_badge_pill.dart';

/// Transaction row per the design spec's component patterns: circular
/// initial avatar (colored by channel), phone number + channel/type
/// caption, right-aligned `.gp-num` amount + status badge pill.
class TransactionRow extends StatelessWidget {
  const TransactionRow({
    required this.title,
    required this.subtitle,
    required this.amountLabel,
    required this.status,
    required this.avatarLetter,
    this.onTap,
    super.key,
  });

  final String title;
  final String subtitle;
  final String amountLabel;
  final String status;
  final String avatarLetter;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (fg, bg) = switch (avatarLetter.toUpperCase()) {
      'M' => (AppColors.warningText, AppColors.warningFill),
      'Z' => (const Color(0xFF00953B), const Color(0xFFE3FBE9)),
      _ => (AppColors.dangerIcon, AppColors.dangerFill),
    };
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          border: Border.all(color: AppColors.borderLight),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: Text(
                avatarLetter,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(amountLabel, style: AppTextStyles.gpNum(fontSize: 13)),
                const SizedBox(height: 3),
                StatusBadgePill(status: status),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

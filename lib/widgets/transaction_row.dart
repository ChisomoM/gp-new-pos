import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/design_system.dart';
import 'package:geepay_pos/widgets/list_group.dart';
import 'package:geepay_pos/widgets/money_text.dart';
import 'package:geepay_pos/widgets/pressable.dart';
import 'package:geepay_pos/widgets/status_badge.dart';

/// Transaction row: channel initial avatar, phone number and caption,
/// right-aligned amount and status badge.
///
/// Avatars use channel colours that are deliberately unlike the status
/// colours, so an Airtel row never looks "failed" before the badge is read.
class TransactionRow extends StatelessWidget {
  const TransactionRow({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.status,
    required this.avatarLetter,
    this.currency = 'ZMW',
    this.onTap,
    super.key,
  });

  final String title;
  final String subtitle;
  final num amount;
  final String currency;
  final String status;
  final String avatarLetter;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (fg, bg) = switch (avatarLetter.toUpperCase()) {
      'M' => (AppColors.channelMtnText, AppColors.channelMtnFill),
      'A' => (AppColors.channelAirtelText, AppColors.channelAirtelFill),
      'Z' => (AppColors.channelZamtelText, AppColors.channelZamtelFill),
      _ => (AppColors.textSecondary, AppColors.surfaceSubtle),
    };
    return Pressable(
      onTap: onTap,
      pressScale: 0.99,
      borderRadius: AppRadius.brLg,
      color: AppColors.surfaceWhite,
      border: Border.all(color: AppColors.borderLight),
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.x3),
        child: Row(
          children: [
            AppAvatar(initial: avatarLetter, color: fg, background: bg),
            const SizedBox(width: AppSpace.x3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyStrong,
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpace.x2),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                MoneyText(amount, currency: currency),
                const SizedBox(height: AppSpace.x1),
                StatusBadge.transaction(status),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

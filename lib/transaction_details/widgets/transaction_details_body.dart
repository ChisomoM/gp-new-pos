import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/app_colors.dart';
import 'package:geepay_pos/app/theme/app_text_styles.dart';
import 'package:geepay_pos/transaction_details/cubit/cubit.dart';
import 'package:geepay_pos/widgets/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';

class TransactionDetailsBody extends StatelessWidget {
  const TransactionDetailsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionDetailsCubit, TransactionDetailsState>(
      builder: (context, state) {
        return Column(
          children: [
            const BackHeader(title: 'Transaction details'),
            Expanded(child: _Content(state: state)),
            if (state.status == TransactionDetailsStatus.success)
              _Footer(transactionId: state.transaction!.lookupId),
          ],
        );
      },
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.state});

  final TransactionDetailsState state;

  @override
  Widget build(BuildContext context) {
    if (state.status == TransactionDetailsStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == TransactionDetailsStatus.failure) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            state.errorMessage ?? 'Unable to load this transaction',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppColors.dangerIcon),
          ),
        ),
      );
    }

    final tx = state.transaction!;
    final isSuccess = tx.isSuccessful;
    final isFailed = tx.isFailed;
    final bannerBg = isSuccess
        ? AppColors.successFill
        : isFailed
        ? AppColors.dangerFillAlt
        : AppColors.warningFill;
    final bannerColor = isSuccess
        ? AppColors.successText
        : isFailed
        ? AppColors.dangerText
        : AppColors.warningText;
    final headline = isSuccess
        ? 'Payment successful'
        : isFailed
        ? 'Payment failed'
        : 'Payment pending';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: bannerBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceWhite,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSuccess
                        ? Iconsax.tick_circle
                        : isFailed
                        ? Iconsax.close_circle
                        : Iconsax.clock,
                    size: 22,
                    color: bannerColor,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      headline,
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: bannerColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${tx.currency} ${tx.amount.toStringAsFixed(2)}',
                      style: AppTextStyles.gpNum(
                        fontSize: 22,
                        color: bannerColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              border: Border.all(color: AppColors.borderLight),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _Row(label: 'Phone number', value: tx.phoneNumber),
                const _RowDivider(),
                _Row(label: 'Payment channel', value: tx.channelLabel),
                const _RowDivider(),
                _Row(label: 'Transaction ID', value: tx.lookupId),
                const _RowDivider(),
                const _Row(
                  label: 'Transaction type',
                  value: 'Mobile money collection',
                ),
                const _RowDivider(),
                _Row(
                  label: 'Date',
                  value: tx.processedAt == null
                      ? '—'
                      : DateFormat('MMM d, y, h:mm a').format(tx.processedAt!),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.textTertiary),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, color: AppColors.divider);
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.transactionId});

  final String transactionId;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surfaceWhite,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
          child: Row(
            children: [
              SizedBox(
                width: 52,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    side: const BorderSide(color: AppColors.borderMedium),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sharing receipts is coming soon'),
                      ),
                    );
                  },
                  child: const Icon(
                    Iconsax.share,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GradientButton(
                  label: 'Print receipt',
                  icon: Iconsax.printer,
                  onPressed: () {
                    // TODO(anyone): wire to a working printer integration —
                    // the printer helper files under lib/utils/ don't
                    // compile yet (missing packages).
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Printing is coming soon'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

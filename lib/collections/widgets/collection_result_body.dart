import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/app_colors.dart';
import 'package:geepay_pos/app/theme/app_text_styles.dart';
import 'package:geepay_pos/auth/auth_bloc.dart';
import 'package:geepay_pos/collections/cubit/cubit.dart';
import 'package:geepay_pos/utils/bluetooth_printer_helper.dart';
import 'package:geepay_pos/utils/print_helper.dart';
import 'package:geepay_pos/utils/printer_dispatch.dart';
import 'package:geepay_pos/widgets/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';

class CollectionResultBody extends StatelessWidget {
  const CollectionResultBody({super.key});

  Future<void> _printReceipt(
    BuildContext context,
    CollectionsState state,
  ) async {
    final tx = state.resultTransaction;
    final isSuccess = state.isSuccessful ?? false;
    final cashierName = context.read<AuthBloc>().state.user.name ?? '';
    final amount = (tx?.amount ?? state.amount?.toDouble() ?? 0)
        .toStringAsFixed(2);
    final date = (tx?.processedAt ?? DateTime.now()).toIso8601String();
    final receiptDetails = <String, dynamic>{
      'businessName': 'Geepay',
      'branchName': '',
      'username': cashierName.isEmpty ? 'Cashier' : cashierName,
      'amount': amount,
      'phone': tx?.phoneNumber ?? state.phoneNumber,
      'paymentChannel': tx?.channelLabel ?? 'Mobile Money',
      'transactionId': tx?.lookupId ?? state.transactionRef ?? '—',
      'date': date,
      'status': isSuccess ? 'successful' : 'failed',
      'isReprint': 'false',
      'reprintCount': '1',
    };

    await PrinterDispatch.run(
      printBuiltin: () => PrintHelper.printReceipt(
        receiptDetails.map((key, value) => MapEntry(key, value.toString())),
      ),
      printBluetooth: () => BluetoothPrinterHelper.printReceipt(receiptDetails),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CollectionsCubit, CollectionsState>(
      builder: (context, state) {
        final isSuccess = state.isSuccessful ?? false;
        final tx = state.resultTransaction;
        final amount = (tx?.amount ?? state.amount?.toDouble() ?? 0)
            .toStringAsFixed(2);
        final iconBg = isSuccess
            ? AppColors.successFill
            : AppColors.dangerFillAlt;
        final iconColor = isSuccess
            ? AppColors.successIcon
            : const Color(0xFFEF4444);
        final headline = isSuccess ? 'Payment received' : 'Payment failed';
        final captionColor = isSuccess
            ? AppColors.successText
            : AppColors.dangerText;
        final caption = isSuccess
            ? 'Confirmed by the customer'
            : 'The customer did not approve in time';
        final date = tx?.processedAt ?? DateTime.now();

        return Column(
          children: [
            BackHeader(
              title: 'Result',
              onBack: () => Navigator.of(
                context,
              ).popUntil(ModalRoute.withName('/dashboard')),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                child: Column(
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: iconBg,
                        shape: BoxShape.circle,
                      ),
                      child: Container(
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
                              : Iconsax.close_circle,
                          size: 22,
                          color: iconColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      headline,
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 21,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ZMW $amount',
                      style: AppTextStyles.gpNum(
                        fontSize: 30,
                        color: const Color(0xFF0C1040),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'from ${tx?.phoneNumber ?? state.phoneNumber}',
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      caption,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: captionColor,
                      ),
                    ),
                    const SizedBox(height: 26),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        border: Border.all(color: AppColors.borderLight),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _DetailRow(
                            label: 'Transaction ID',
                            value: tx?.lookupId ?? state.transactionRef ?? '—',
                          ),
                          const _DetailDivider(),
                          const _DetailRow(
                            label: 'Transaction type',
                            value: 'Mobile money collection',
                          ),
                          const _DetailDivider(),
                          _DetailRow(
                            label: 'Date',
                            value: DateFormat(
                              'MMM d, y, h:mm a',
                            ).format(date),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            DecoratedBox(
              decoration: const BoxDecoration(
                color: AppColors.surfaceWhite,
                border: Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
                  child: Column(
                    children: [
                      if (!isSuccess) ...[
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 15,
                              ),
                              side: const BorderSide(
                                color: AppColors.borderMedium,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              context.read<CollectionsCubit>().reset();
                              Navigator.of(
                                context,
                              ).popUntil(ModalRoute.withName('/collections'));
                            },
                            child: const Text(
                              'Try again',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            side: const BorderSide(
                              color: AppColors.borderMedium,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => _printReceipt(context, state),
                          icon: const Icon(
                            Iconsax.printer,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                          label: const Text(
                            'Print receipt',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      GradientButton(
                        label: 'Done',
                        onPressed: () => Navigator.of(
                          context,
                        ).popUntil(ModalRoute.withName('/dashboard')),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
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
                fontSize: 13,
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

class _DetailDivider extends StatelessWidget {
  const _DetailDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, color: AppColors.divider);
  }
}

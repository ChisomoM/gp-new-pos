import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/design_system.dart';
import 'package:geepay_pos/auth/auth_bloc.dart';
import 'package:geepay_pos/models/transaction.dart';
import 'package:geepay_pos/transaction_details/cubit/cubit.dart';
import 'package:geepay_pos/utils/bluetooth_printer_helper.dart';
import 'package:geepay_pos/utils/print_helper.dart';
import 'package:geepay_pos/utils/printer_dispatch.dart';
import 'package:geepay_pos/widgets/widgets.dart';
import 'package:intl/intl.dart';

class TransactionDetailsBody extends StatelessWidget {
  const TransactionDetailsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionDetailsCubit, TransactionDetailsState>(
      builder: (context, state) {
        return Column(
          children: [
            const AppHeader(title: 'Transaction details'),
            Expanded(
              child: AnimatedSwitcher(
                duration: AppMotion.of(context, AppMotion.base),
                child: _Content(key: ValueKey(state.status), state: state),
              ),
            ),
            if (state.status == TransactionDetailsStatus.success)
              _Footer(transaction: state.transaction!),
          ],
        );
      },
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.state, super.key});

  final TransactionDetailsState state;

  @override
  Widget build(BuildContext context) {
    if (state.status == TransactionDetailsStatus.loading) {
      return const _DetailsSkeleton();
    }
    if (state.status == TransactionDetailsStatus.failure) {
      return Center(
        child: SingleChildScrollView(
          child: ErrorState(
            title: "Couldn't load this transaction",
            message: state.errorMessage,
            onRetry: () => context.read<TransactionDetailsCubit>().load(),
          ),
        ),
      );
    }

    final tx = state.transaction!;
    final isSuccess = tx.isSuccessful;
    final isFailed = tx.isFailed;
    final (bannerBg, bannerColor, icon, headline) = isSuccess
        ? (
            AppColors.successFill,
            AppColors.successText,
            AppIcons.success,
            'Payment successful',
          )
        : isFailed
        ? (
            AppColors.dangerFillAlt,
            AppColors.dangerText,
            AppIcons.failed,
            'Payment failed',
          )
        : (
            AppColors.warningFill,
            AppColors.warningText,
            AppIcons.pending,
            'Payment pending',
          );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpace.gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpace.x4),
            decoration: BoxDecoration(
              color: bannerBg,
              borderRadius: AppRadius.brLg,
            ),
            child: Row(
              children: [
                Container(
                  width: AppSize.avatar,
                  height: AppSize.avatar,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceWhite,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: AppIconSize.md, color: bannerColor),
                ),
                const SizedBox(width: AppSpace.x3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        headline,
                        style: AppTextStyles.headline.copyWith(
                          color: bannerColor,
                        ),
                      ),
                      MoneyText(
                        tx.amount,
                        currency: tx.currency,
                        fontSize: AppTextStyles.numLg,
                        fontWeight: FontWeight.w700,
                        color: bannerColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.x4),
          KeyValueList(
            items: [
              KeyValueItem('Phone number', tx.phoneNumber),
              KeyValueItem('Payment channel', tx.channelLabel),
              KeyValueItem('Transaction ID', tx.lookupId, copyable: true),
              const KeyValueItem(
                'Transaction type',
                'Mobile money collection',
              ),
              KeyValueItem(
                'Date',
                tx.processedAt == null
                    ? '-'
                    : DateFormat('MMM d, y, h:mm a').format(tx.processedAt!),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailsSkeleton extends StatelessWidget {
  const _DetailsSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppSpace.gutter),
      child: Skeleton(
        child: Column(
          children: [
            SkeletonBox(
              width: double.infinity,
              height: 72,
              borderRadius: AppRadius.brLg,
            ),
            SizedBox(height: AppSpace.x4),
            SkeletonBox(
              width: double.infinity,
              height: 240,
              borderRadius: AppRadius.brLg,
            ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.transaction});

  final Transaction transaction;

  Future<void> _printReceipt(BuildContext context) async {
    final tx = transaction;
    final cashierName = context.read<AuthBloc>().state.user.name ?? '';
    final receiptDetails = <String, dynamic>{
      'businessName': 'Geepay',
      'branchName': '',
      'username': cashierName.isEmpty ? 'Cashier' : cashierName,
      'amount': tx.amount.toStringAsFixed(2),
      'phone': tx.phoneNumber,
      'paymentChannel': tx.channelLabel,
      'transactionId': tx.lookupId,
      'date': (tx.processedAt ?? DateTime.now()).toIso8601String(),
      'status': tx.isSuccessful ? 'successful' : 'failed',
      'isReprint': 'true',
      'reprintCount': '1',
    };

    log(
      'Print receipt requested for transaction ${tx.lookupId} '
      '(reprint, status: ${receiptDetails['status']})',
      name: 'TransactionDetails.print',
    );
    await PrinterDispatch.run(
      printBuiltin: () => PrintHelper.printReceipt(
        receiptDetails.map((key, value) => MapEntry(key, value.toString())),
      ),
      printBluetooth: () => BluetoothPrinterHelper.printReceipt(receiptDetails),
    );
  }

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
          padding: const EdgeInsets.fromLTRB(
            AppSpace.gutter,
            AppSpace.x3,
            AppSpace.gutter,
            AppSpace.x4,
          ),
          child: Row(
            children: [
              AppIconButton(
                icon: AppIcons.share,
                tooltip: 'Share receipt',
                variant: AppIconButtonVariant.outline,
                size: AppSize.buttonLg,
                onPressed: () => showToast(
                  context,
                  message: 'Sharing receipts is coming soon',
                ),
              ),
              const SizedBox(width: AppSpace.x3),
              Expanded(
                child: AppButton(
                  label: 'Print receipt',
                  icon: AppIcons.printer,
                  onPressed: () => _printReceipt(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

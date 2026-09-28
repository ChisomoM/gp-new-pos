import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/design_system.dart';
import 'package:geepay_pos/auth/auth_bloc.dart';
import 'package:geepay_pos/collections/cubit/cubit.dart';
import 'package:geepay_pos/utils/bluetooth_printer_helper.dart';
import 'package:geepay_pos/utils/print_helper.dart';
import 'package:geepay_pos/utils/printer_dispatch.dart';
import 'package:geepay_pos/widgets/widgets.dart';
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
        final amount = tx?.amount ?? state.amount ?? 0;
        final (iconBg, iconColor, icon) = isSuccess
            ? (
                AppColors.successFill,
                AppColors.successIcon,
                AppIcons.successFilled,
              )
            : (
                AppColors.dangerFillAlt,
                AppColors.dangerIcon,
                AppIcons.failedFilled,
              );
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
            AppHeader(
              title: 'Result',
              onBack: () => Navigator.of(
                context,
              ).popUntil(ModalRoute.withName('/dashboard')),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpace.x6,
                  AppSpace.x8,
                  AppSpace.x6,
                  AppSpace.x4,
                ),
                child: Column(
                  children: [
                    Container(
                      width: AppSpace.x16,
                      height: AppSpace.x16,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: iconBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: AppIconSize.xl, color: iconColor),
                    ),
                    const SizedBox(height: AppSpace.x4),
                    Text(headline, style: AppTextStyles.title1),
                    const SizedBox(height: AppSpace.x2),
                    MoneyText(
                      amount,
                      fontSize: AppTextStyles.numDisplay,
                      fontWeight: FontWeight.w700,
                      muteDecimals: true,
                    ),
                    const SizedBox(height: AppSpace.x1),
                    Text(
                      'from ${tx?.phoneNumber ?? state.phoneNumber}',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: AppSpace.x3),
                    Text(
                      caption,
                      style: AppTextStyles.label.copyWith(color: captionColor),
                    ),
                    const SizedBox(height: AppSpace.x6),
                    KeyValueList(
                      items: [
                        KeyValueItem(
                          'Transaction ID',
                          tx?.lookupId ?? state.transactionRef ?? '-',
                          copyable:
                              (tx?.lookupId ?? state.transactionRef) != null,
                        ),
                        const KeyValueItem(
                          'Transaction type',
                          'Mobile money collection',
                        ),
                        KeyValueItem(
                          'Date',
                          DateFormat('MMM d, y, h:mm a').format(date),
                        ),
                      ],
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
                  padding: const EdgeInsets.fromLTRB(
                    AppSpace.gutter,
                    AppSpace.x3,
                    AppSpace.gutter,
                    AppSpace.x4,
                  ),
                  child: Column(
                    children: [
                      if (!isSuccess) ...[
                        AppButton(
                          label: 'Try again',
                          onPressed: () {
                            context.read<CollectionsCubit>().reset();
                            Navigator.of(
                              context,
                            ).popUntil(ModalRoute.withName('/collections'));
                          },
                        ),
                        const SizedBox(height: AppSpace.x3),
                      ],
                      AppButton.secondary(
                        label: 'Print receipt',
                        icon: AppIcons.printer,
                        onPressed: () => _printReceipt(context, state),
                      ),
                      const SizedBox(height: AppSpace.x3),
                      if (isSuccess)
                        AppButton(
                          label: 'Done',
                          onPressed: () => Navigator.of(
                            context,
                          ).popUntil(ModalRoute.withName('/dashboard')),
                        )
                      else
                        AppButton.secondary(
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

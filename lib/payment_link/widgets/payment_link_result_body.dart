import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/design_system.dart';
import 'package:geepay_pos/auth/auth_bloc.dart';
import 'package:geepay_pos/payment_link/cubit/cubit.dart';
import 'package:geepay_pos/utils/bluetooth_printer_helper.dart';
import 'package:geepay_pos/utils/print_helper.dart';
import 'package:geepay_pos/utils/printer_dispatch.dart';
import 'package:geepay_pos/widgets/widgets.dart';
import 'package:intl/intl.dart';

class PaymentLinkResultBody extends StatelessWidget {
  const PaymentLinkResultBody({super.key});

  Future<void> _printReceipt(
    BuildContext context,
    PaymentLinkState state,
  ) async {
    final cashierName = context.read<AuthBloc>().state.user.name ?? '';
    final receiptDetails = <String, dynamic>{
      'businessName': 'Geepay',
      'branchName': '',
      'username': cashierName.isEmpty ? 'Cashier' : cashierName,
      'amount': (state.amount ?? 0).toStringAsFixed(2),
      'phone': '—',
      'paymentChannel': 'Payment link',
      'transactionId': state.token ?? '—',
      'date': DateTime.now().toIso8601String(),
      'status': state.isPaid ? 'successful' : 'failed',
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
    return BlocBuilder<PaymentLinkCubit, PaymentLinkState>(
      builder: (context, state) {
        final isPaid = state.isPaid;
        final (iconBg, iconColor, icon) = isPaid
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
        final headline = switch (state.status) {
          'paid' => 'Payment received',
          'cancelled' => 'Link cancelled',
          'expired' => 'Link expired',
          _ => 'Payment failed',
        };
        final captionColor = isPaid
            ? AppColors.successText
            : AppColors.dangerText;
        final caption = switch (state.status) {
          'paid' => 'Confirmed by the customer',
          'cancelled' => 'The link was cancelled before payment',
          'expired' => 'The customer did not pay in time',
          _ => 'The payment could not be completed',
        };

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
                      state.amount ?? 0,
                      fontSize: AppTextStyles.numDisplay,
                      fontWeight: FontWeight.w700,
                      muteDecimals: true,
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
                          'Session token',
                          state.token ?? '-',
                          copyable: state.token != null,
                        ),
                        const KeyValueItem(
                          'Transaction type',
                          'Payment link',
                        ),
                        KeyValueItem(
                          'Date',
                          DateFormat('MMM d, y, h:mm a').format(DateTime.now()),
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
                      if (!isPaid) ...[
                        AppButton(
                          label: 'Create another link',
                          onPressed: () {
                            context.read<PaymentLinkCubit>().reset();
                            Navigator.of(
                              context,
                            ).popUntil(ModalRoute.withName('/payment-link'));
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
                      if (isPaid)
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

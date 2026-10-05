import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/design_system.dart';
import 'package:geepay_pos/payment_link/cubit/cubit.dart';
import 'package:geepay_pos/widgets/widgets.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class PaymentLinkQrBody extends StatelessWidget {
  const PaymentLinkQrBody({super.key});

  (String, BadgeTone) _statusDisplay(String? status) {
    return switch (status) {
      'processing' => ('Customer is paying', BadgeTone.info),
      _ => ('Waiting for customer', BadgeTone.warning),
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentLinkCubit, PaymentLinkState>(
      builder: (context, state) {
        final checkoutUrl = state.checkoutUrl ?? '';
        final (statusLabel, statusTone) = _statusDisplay(state.status);
        return Column(
          children: [
            const AppHeader(title: 'Scan to pay'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpace.gutter,
                  AppSpace.x6,
                  AppSpace.gutter,
                  AppSpace.x4,
                ),
                child: Column(
                  children: [
                    MoneyText(
                      state.amount ?? 0,
                      fontSize: AppTextStyles.numDisplay,
                      fontWeight: FontWeight.w700,
                      muteDecimals: true,
                      animate: true,
                    ),
                    const SizedBox(height: AppSpace.x2),
                    StatusBadge(
                      label: statusLabel,
                      tone: statusTone,
                      showDot: true,
                    ),
                    const SizedBox(height: AppSpace.x6),
                    AppCard(
                      elevation: AppCardElevation.raised,
                      padding: const EdgeInsets.all(AppSpace.x6),
                      child: checkoutUrl.isEmpty
                          ? const SizedBox(
                              width: 220,
                              height: 220,
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : QrImageView(
                              data: checkoutUrl,
                              size: 220,
                              backgroundColor: AppColors.surfaceWhite,
                            ),
                    ),
                    const SizedBox(height: AppSpace.x4),
                    Text(
                      'Ask the customer to scan this code with their phone '
                      'camera to open the payment page.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: AppSpace.x6),
                    KeyValueList(
                      items: [
                        KeyValueItem(
                          'Payment link',
                          checkoutUrl,
                          copyable: checkoutUrl.isNotEmpty,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpace.x3),
                    AppButton.secondary(
                      label: 'Share link',
                      icon: AppIcons.share,
                      onPressed: checkoutUrl.isEmpty
                          ? null
                          : () => SharePlus.instance.share(
                              ShareParams(text: checkoutUrl),
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
                  padding: const EdgeInsets.fromLTRB(
                    AppSpace.gutter,
                    AppSpace.x3,
                    AppSpace.gutter,
                    AppSpace.x4,
                  ),
                  child: AppButton.secondary(
                    label: 'Cancel',
                    onPressed: () {
                      context.read<PaymentLinkCubit>().cancel();
                      Navigator.of(context).pop();
                    },
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

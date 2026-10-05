import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/design_system.dart';
import 'package:geepay_pos/payment_link/cubit/cubit.dart';
import 'package:geepay_pos/widgets/widgets.dart';

class PaymentLinkBody extends StatefulWidget {
  const PaymentLinkBody({super.key});

  @override
  State<PaymentLinkBody> createState() => _PaymentLinkBodyState();
}

class _PaymentLinkBodyState extends State<PaymentLinkBody> {
  static const _amounts = [20, 50, 100, 200];

  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentLinkCubit, PaymentLinkState>(
      builder: (context, state) {
        final cubit = context.read<PaymentLinkCubit>();
        return Column(
          children: [
            const AppHeader(title: 'Payment link'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpace.gutter,
                  AppSpace.x6,
                  AppSpace.gutter,
                  AppSpace.x4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Generate a QR code the customer scans to pay on '
                      'their own phone.',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: AppSpace.section),
                    AppTextField(
                      label: 'Amount',
                      controller: _amountController,
                      hintText: '0.00',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: cubit.setAmount,
                      prefixText: 'ZMW  ',
                      prefixStyle: AppTextStyles.gpNum(
                        fontSize: AppTextStyles.numBase,
                        color: AppColors.textTertiary,
                      ),
                      textStyle: AppTextStyles.gpNum(
                        fontSize: AppTextStyles.numLg,
                      ),
                      hintStyle: AppTextStyles.gpNum(
                        fontSize: AppTextStyles.numLg,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpace.x2),
                    Row(
                      children: [
                        for (final chip in _amounts) ...[
                          if (chip != _amounts.first)
                            const SizedBox(width: AppSpace.x2),
                          Expanded(
                            child: AppChoiceChip(
                              label: 'K$chip',
                              pill: false,
                              selected: state.amount == chip,
                              onTap: () {
                                cubit.pickAmount(chip);
                                _amountController.text = chip.toStringAsFixed(
                                  2,
                                );
                                _amountController.selection =
                                    TextSelection.collapsed(
                                      offset: _amountController.text.length,
                                    );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpace.section),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpace.card),
                      decoration: const BoxDecoration(
                        color: AppColors.infoFill,
                        borderRadius: AppRadius.brLg,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LINK AMOUNT',
                            style: AppTextStyles.overline.copyWith(
                              color: AppColors.gpCobalt,
                            ),
                          ),
                          const SizedBox(height: AppSpace.x1),
                          MoneyText(
                            state.amount ?? 0,
                            fontSize: AppTextStyles.numLg,
                            fontWeight: FontWeight.w700,
                            color: AppColors.selectedText,
                            animate: true,
                          ),
                          const SizedBox(height: AppSpace.x1),
                          Text(
                            'Valid for 60 minutes once created',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.unselectedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedSize(
                      duration: AppMotion.of(context, AppMotion.fast),
                      alignment: Alignment.topLeft,
                      child: (state.errorMessage?.isNotEmpty ?? false)
                          ? Padding(
                              padding: const EdgeInsets.only(
                                top: AppSpace.x3,
                              ),
                              child: Text(
                                state.errorMessage!,
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.dangerText,
                                ),
                              ),
                            )
                          : const SizedBox(width: double.infinity),
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
                      AppButton(
                        label: 'Generate QR code',
                        icon: AppIcons.qrCode,
                        isLoading: state.isSubmitting,
                        onPressed: state.isSubmitting ? null : cubit.submit,
                      ),
                      const SizedBox(height: AppSpace.x3),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            AppIcons.lock,
                            size: AppIconSize.sm,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: AppSpace.x1),
                          Flexible(
                            child: Text(
                              'Payments are processed securely by Geepay',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ),
                        ],
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

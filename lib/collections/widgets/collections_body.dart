import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/app_colors.dart';
import 'package:geepay_pos/app/theme/app_text_styles.dart';
import 'package:geepay_pos/collections/cubit/cubit.dart';
import 'package:geepay_pos/widgets/widgets.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class CollectionsBody extends StatefulWidget {
  const CollectionsBody({super.key});

  @override
  State<CollectionsBody> createState() => _CollectionsBodyState();
}

class _CollectionsBodyState extends State<CollectionsBody> {
  static const _amounts = [20, 50, 100, 200];

  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CollectionsCubit, CollectionsState>(
      builder: (context, state) {
        final cubit = context.read<CollectionsCubit>();
        final amountLabel = state.amount == null
            ? '0.00'
            : state.amount!.toStringAsFixed(2);
        return Column(
          children: [
            const BackHeader(title: 'New collection'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Customer phone number',
                      style: _labelStyle,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      keyboardType: TextInputType.phone,
                      onChanged: cubit.setPhoneNumber,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'e.g. 0973 042 237',
                        prefixIcon: const Icon(
                          Iconsax.call,
                          size: 18,
                          color: AppColors.textMuted,
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceWhite,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        border: _border(AppColors.borderMedium),
                        enabledBorder: _border(AppColors.borderMedium),
                        focusedBorder: _border(AppColors.gpCobalt),
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text('Amount', style: _labelStyle),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: cubit.setAmount,
                      style: AppTextStyles.gpNum(
                        fontSize: 22,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: '0.00',
                        hintStyle: AppTextStyles.gpNum(
                          fontSize: 22,
                          color: AppColors.textMuted,
                        ),
                        prefixText: 'ZMW  ',
                        prefixStyle: AppTextStyles.gpNum(
                          fontSize: 15,
                          color: AppColors.textTertiary,
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceWhite,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: _border(AppColors.borderMedium),
                        enabledBorder: _border(AppColors.borderMedium),
                        focusedBorder: _border(AppColors.gpCobalt),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        for (final chip in _amounts) ...[
                          if (chip != _amounts.first) const SizedBox(width: 8),
                          Expanded(
                            child: _AmountChip(
                              amount: chip,
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
                    const SizedBox(height: 22),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.infoFill,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "YOU'RE REQUESTING",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.gpCobalt,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'ZMW $amountLabel',
                            style: AppTextStyles.gpNum(
                              fontSize: 22,
                              color: const Color(0xFF141644),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Sent as a mobile money request',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF3D4560),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (state.errorMessage?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 14),
                      Text(
                        state.errorMessage!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.dangerIcon,
                        ),
                      ),
                    ],
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
                      GradientButton(
                        label: 'Request payment',
                        icon: Iconsax.send_2,
                        isLoading: state.isSubmitting,
                        onPressed: state.isSubmitting ? null : cubit.submit,
                      ),
                      const SizedBox(height: 12),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Iconsax.lock_1,
                            size: 13,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 6),
                          const Flexible(
                            child: Text(
                              'Payments are processed securely by Geepay',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textMuted,
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

const _labelStyle = TextStyle(
  fontSize: 13,
  fontWeight: FontWeight.w600,
  color: AppColors.textSecondary,
);

OutlineInputBorder _border(Color color) => OutlineInputBorder(
  borderRadius: BorderRadius.circular(12),
  borderSide: BorderSide(color: color, width: 1.5),
);

class _AmountChip extends StatelessWidget {
  const _AmountChip({
    required this.amount,
    required this.selected,
    required this.onTap,
  });

  final int amount;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.infoFill : AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.gpCobalt : AppColors.borderLight,
            width: 1.5,
          ),
        ),
        child: Text(
          'K$amount',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: selected ? const Color(0xFF141644) : const Color(0xFF3D4560),
          ),
        ),
      ),
    );
  }
}

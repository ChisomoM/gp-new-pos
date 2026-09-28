import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/design_system.dart';
import 'package:geepay_pos/setup/cubit/cubit.dart';
import 'package:geepay_pos/widgets/widgets.dart';

class SetupBody extends StatefulWidget {
  const SetupBody({super.key});

  @override
  State<SetupBody> createState() => _SetupBodyState();
}

class _SetupBodyState extends State<SetupBody> {
  final _businessName = TextEditingController();
  final _businessEmail = TextEditingController();
  final _businessPhone = TextEditingController();

  @override
  void dispose() {
    _businessName.dispose();
    _businessEmail.dispose();
    _businessPhone.dispose();
    super.dispose();
  }

  void _submit(SetupCubit cubit) {
    cubit.submit(
      businessName: _businessName.text,
      businessEmail: _businessEmail.text,
      businessPhone: _businessPhone.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SetupCubit, SetupState>(
      builder: (context, state) {
        final deviceCode = state.deviceId == null
            ? '-'
            : 'GP-POS-${state.deviceId!.substring(0, 6).toUpperCase()}';
        return Column(
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(
                gradient: AppGradients.hero,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(AppRadius.xl),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpace.gutter,
                    AppSpace.x8,
                    AppSpace.gutter,
                    AppSpace.x6,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(AppLogos.wordmarkWhite, width: 135),
                      const SizedBox(height: AppSpace.x6),
                      Text(
                        'Set up this device',
                        style: AppTextStyles.title1.copyWith(
                          color: AppColors.onBrandHigh,
                        ),
                      ),
                      const SizedBox(height: AppSpace.x1),
                      Text(
                        "Register this terminal to your business so it's "
                        'ready to accept payments.',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.onBrandMid,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
                    AppTextField(
                      label: 'Business name',
                      controller: _businessName,
                      hintText: 'e.g. Kashikite Traders',
                    ),
                    const SizedBox(height: AppSpace.field),
                    AppTextField(
                      label: 'Business email',
                      controller: _businessEmail,
                      hintText: 'you@business.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: AppSpace.field),
                    AppTextField(
                      label: 'Business phone',
                      controller: _businessPhone,
                      hintText: '0973 042 237',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: AppSpace.field),
                    AppCard(
                      child: Row(
                        children: [
                          const AppIconTile(icon: AppIcons.device),
                          const SizedBox(width: AppSpace.x3),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Device ID',
                                  style: AppTextStyles.bodyStrong,
                                ),
                                Text(
                                  deviceCode,
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (state.deviceId != null)
                            const StatusBadge(
                              label: 'Detected',
                              tone: BadgeTone.success,
                              showDot: true,
                            ),
                        ],
                      ),
                    ),
                    if (state.status == SetupStatus.failure &&
                        state.errorMessage != null) ...[
                      const SizedBox(height: AppSpace.x3),
                      Text(
                        state.errorMessage!,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.dangerText,
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
                border: Border(
                  top: BorderSide(color: AppColors.divider),
                ),
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
                  child: AppButton(
                    label: 'Complete setup',
                    isLoading: state.isSubmitting,
                    onPressed: state.deviceId == null
                        ? null
                        : () => _submit(context.read<SetupCubit>()),
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

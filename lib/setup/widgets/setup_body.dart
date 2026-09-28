import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/app_colors.dart';
import 'package:geepay_pos/app/theme/app_gradients.dart';
import 'package:geepay_pos/app/theme/app_logos.dart';
import 'package:geepay_pos/setup/cubit/cubit.dart';
import 'package:geepay_pos/widgets/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

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
            ? '—'
            : 'GP-POS-${state.deviceId!.substring(0, 6).toUpperCase()}';
        return Column(
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(
                gradient: AppGradients.hero,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 26),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(AppLogos.wordmarkWhite, width: 135),
                      const SizedBox(height: 24),
                      Text(
                        'Set up this device',
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Register this terminal to your business so it's "
                        'ready to accept payments.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: Color.fromRGBO(255, 255, 255, 0.68),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(
                      label: 'Business name',
                      controller: _businessName,
                      hintText: 'e.g. Kashikite Traders',
                    ),
                    const SizedBox(height: 18),
                    AppTextField(
                      label: 'Business email',
                      controller: _businessEmail,
                      hintText: 'you@business.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 18),
                    AppTextField(
                      label: 'Business phone',
                      controller: _businessPhone,
                      hintText: '0973 042 237',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.infoFill,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Iconsax.mobile,
                              size: 17,
                              color: AppColors.gpCobalt,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Device ID',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  deviceCode,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Row(
                            children: [
                              Icon(
                                Iconsax.tick_circle,
                                size: 13,
                                color: AppColors.successIcon,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Detected',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F7A56),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (state.status == SetupStatus.failure &&
                        state.errorMessage != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        state.errorMessage!,
                        style: const TextStyle(
                          fontSize: 14,
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
                border: Border(
                  top: BorderSide(color: AppColors.divider),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
                  child: GradientButton(
                    label: 'Complete setup',
                    icon: Iconsax.arrow_right_3,
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

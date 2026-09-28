import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/design_system.dart';
import 'package:geepay_pos/login/cubit/cubit.dart';
import 'package:geepay_pos/widgets/widgets.dart';

/// {@template login_body}
/// Body of the LoginPage: hero header + sign-in form, per the Login mockup.
/// {@endtemplate}
class LoginBody extends StatefulWidget {
  /// {@macro login_body}
  const LoginBody({super.key});

  @override
  State<LoginBody> createState() => _LoginBodyState();
}

class _LoginBodyState extends State<LoginBody> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _otp = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _otp.dispose();
    super.dispose();
  }

  void _submit(LoginCubit cubit) {
    cubit.submit(email: _email.text, password: _password.text);
  }

  void _submitOtp(LoginCubit cubit) {
    cubit.submitOtp(_otp.text);
  }

  List<Widget> _loginStepChildren(BuildContext context, LoginState state) {
    return [
      Text('Welcome back', style: AppTextStyles.title1),
      const SizedBox(height: AppSpace.x1),
      Text(
        'Log in to continue to your Merchant Portal',
        style: AppTextStyles.body.copyWith(color: AppColors.textTertiary),
      ),
      const SizedBox(height: AppSpace.x6),
      AppTextField(
        label: 'Email address',
        controller: _email,
        hintText: 'you@business.com',
        keyboardType: TextInputType.emailAddress,
        fillColor: AppColors.surfacePage,
        textInputAction: TextInputAction.next,
        enabled: !state.isSubmitting,
      ),
      const SizedBox(height: AppSpace.field),
      AppPasswordField(
        controller: _password,
        fillColor: AppColors.surfacePage,
        enabled: !state.isSubmitting,
        onSubmitted: (_) => _submit(context.read<LoginCubit>()),
      ),
      if (state.status == LoginStatus.failure &&
          state.errorMessage != null) ...[
        const SizedBox(height: AppSpace.x3),
        Text(
          state.errorMessage!,
          style: AppTextStyles.body.copyWith(color: AppColors.dangerText),
        ),
      ],
      const SizedBox(height: AppSpace.x6),
      AppButton(
        label: 'Log in',
        isLoading: state.isSubmitting,
        onPressed: () => _submit(context.read<LoginCubit>()),
      ),
    ];
  }

  List<Widget> _otpStepChildren(BuildContext context, LoginState state) {
    return [
      Text("Verify it's you", style: AppTextStyles.title1),
      const SizedBox(height: AppSpace.x1),
      Text(
        'Enter the 6-digit code we emailed to ${state.email}',
        style: AppTextStyles.body.copyWith(color: AppColors.textTertiary),
      ),
      const SizedBox(height: AppSpace.x6),
      AppTextField(
        label: 'Verification code',
        controller: _otp,
        hintText: '123456',
        keyboardType: TextInputType.number,
        fillColor: AppColors.surfacePage,
        textInputAction: TextInputAction.done,
        enabled: !state.isOtpSubmitting,
      ),
      if (state.errorMessage != null && state.errorMessage!.isNotEmpty) ...[
        const SizedBox(height: AppSpace.x3),
        Text(
          state.errorMessage!,
          style: AppTextStyles.body.copyWith(color: AppColors.dangerText),
        ),
      ],
      const SizedBox(height: AppSpace.x6),
      AppButton(
        label: 'Verify',
        isLoading: state.isOtpSubmitting,
        onPressed: () => _submitOtp(context.read<LoginCubit>()),
      ),
      const SizedBox(height: AppSpace.x3),
      Center(
        child: AppButton.tertiary(
          label: 'Back to login',
          onPressed: state.isOtpSubmitting
              ? null
              : () {
                  _otp.clear();
                  context.read<LoginCubit>().cancelOtp();
                },
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        return SizedBox.expand(
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 260,
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpace.x8),
                  decoration: const BoxDecoration(gradient: AppGradients.hero),
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(AppLogos.wordmarkWhite, width: 190),
                        const SizedBox(height: AppSpace.x4),
                        Text(
                          'Secure access to the Merchant Portal',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.onBrandMid,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 232,
                left: 0,
                right: 0,
                bottom: 0,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppRadius.xl),
                    ),
                    boxShadow: AppShadows.bottomBar,
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpace.x6,
                      AppSpace.x8,
                      AppSpace.x6,
                      AppSpace.x6,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (state.isAwaitingOtp)
                          ..._otpStepChildren(context, state)
                        else
                          ..._loginStepChildren(context, state),
                        const SizedBox(height: AppSpace.x6),
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
                                'Protected by Geepay Security Engine',
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
          ),
        );
      },
    );
  }
}

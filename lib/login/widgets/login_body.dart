import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/app_colors.dart';
import 'package:geepay_pos/app/theme/app_gradients.dart';
import 'package:geepay_pos/app/theme/app_logos.dart';
import 'package:geepay_pos/login/cubit/cubit.dart';
import 'package:geepay_pos/widgets/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

/// {@template login_body}
/// Body of the LoginPage — hero header + sign-in form, per the Login mockup.
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
      Text(
        'Welcome back',
        style: GoogleFonts.dmSans(
          fontWeight: FontWeight.w700,
          fontSize: 24,
          color: const Color(0xFF0C1040),
        ),
      ),
      const SizedBox(height: 4),
      const Text(
        'Log in to continue to your Merchant Portal',
        style: TextStyle(fontSize: 14, color: AppColors.textTertiary),
      ),
      const SizedBox(height: 20),
      AppTextField(
        label: 'Email address',
        controller: _email,
        hintText: 'you@business.com',
        keyboardType: TextInputType.emailAddress,
        fillColor: AppColors.surfacePage,
        textInputAction: TextInputAction.next,
        enabled: !state.isSubmitting,
      ),
      const SizedBox(height: 14),
      AppPasswordField(
        controller: _password,
        fillColor: AppColors.surfacePage,
        enabled: !state.isSubmitting,
        onSubmitted: (_) => _submit(context.read<LoginCubit>()),
      ),
      if (state.status == LoginStatus.failure &&
          state.errorMessage != null) ...[
        const SizedBox(height: 10),
        Text(
          state.errorMessage!,
          style: const TextStyle(fontSize: 14, color: AppColors.dangerIcon),
        ),
      ],
      const SizedBox(height: 20),
      GradientButton(
        label: 'Log in',
        icon: Iconsax.arrow_right_3,
        isLoading: state.isSubmitting,
        onPressed: () => _submit(context.read<LoginCubit>()),
      ),
    ];
  }

  List<Widget> _otpStepChildren(BuildContext context, LoginState state) {
    return [
      Text(
        "Verify it's you",
        style: GoogleFonts.dmSans(
          fontWeight: FontWeight.w700,
          fontSize: 24,
          color: const Color(0xFF0C1040),
        ),
      ),
      const SizedBox(height: 4),
      Text(
        'Enter the 6-digit code we emailed to ${state.email}',
        style: const TextStyle(fontSize: 14, color: AppColors.textTertiary),
      ),
      const SizedBox(height: 20),
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
        const SizedBox(height: 10),
        Text(
          state.errorMessage!,
          style: const TextStyle(fontSize: 14, color: AppColors.dangerIcon),
        ),
      ],
      const SizedBox(height: 20),
      GradientButton(
        label: 'Verify',
        icon: Iconsax.tick_circle,
        isLoading: state.isOtpSubmitting,
        onPressed: () => _submitOtp(context.read<LoginCubit>()),
      ),
      const SizedBox(height: 14),
      Center(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: state.isOtpSubmitting
                ? null
                : () {
                    _otp.clear();
                    context.read<LoginCubit>().cancelOtp();
                  },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Text(
                'Back to login',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gpCobalt,
                ),
              ),
            ),
          ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.gpCobalt,   Color(0xFF2B6FC2),
                  AppColors.gpSky,], stops: [0.25,0.75 ,1] ,    begin: Alignment(-1, -0.4663),
    end: Alignment(1, 0.4663),)),
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(AppLogos.wordmarkWhite, width: 190),
                        const SizedBox(height: 16),
                        const Text(
                          'Secure access to the Merchant Portal',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: Color.fromRGBO(255, 255, 255, 0.72),
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
                      top: Radius.circular(28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(8, 12, 48, 0.06),
                        blurRadius: 24,
                        offset: Offset(0, -8),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 34, 24, 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (state.isAwaitingOtp)
                          ..._otpStepChildren(context, state)
                        else
                          ..._loginStepChildren(context, state),
                        const SizedBox(height: 24),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Iconsax.lock_1,
                              size: 14,
                              color: AppColors.textMuted,
                            ),
                            SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Protected by Geepay Security Engine',
                                style: TextStyle(
                                  fontSize: 12,
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
          ),
        );
      },
    );
  }
}

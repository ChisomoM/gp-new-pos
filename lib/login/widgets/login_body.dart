import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit(LoginCubit cubit) {
    TextInput.finishAutofillContext();
    unawaited(cubit.submit(email: _email.text, password: _password.text));
  }

  Widget _loginStep(BuildContext context, LoginState state) {
    final cubit = context.read<LoginCubit>();
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
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
            autofillHints: const [AutofillHints.email, AutofillHints.username],
            enabled: !state.isSubmitting,
            errorText: state.emailError,
            onChanged: (_) => cubit.fieldChanged(),
          ),
          const SizedBox(height: AppSpace.field),
          AppPasswordField(
            controller: _password,
            fillColor: AppColors.surfacePage,
            enabled: !state.isSubmitting,
            errorText: state.passwordError,
            onChanged: (_) => cubit.fieldChanged(),
            onSubmitted: (_) => _submit(cubit),
          ),
          AnimatedAlert(
            message: state.status == LoginStatus.failure
                ? state.errorMessage
                : null,
          ),
          const SizedBox(height: AppSpace.x6),
          AppButton(
            label: 'Log in',
            isLoading: state.isSubmitting,
            onPressed: () => _submit(cubit),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: SizedBox.expand(
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 260,
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpace.x8,
                    ),
                    decoration: const BoxDecoration(
                      gradient: AppGradients.hero,
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: AppMotion.of(context, AppMotion.emphasis),
                            curve: AppMotion.enter,
                            builder: (context, t, child) => Opacity(
                              opacity: t,
                              child: Transform.translate(
                                offset: Offset(0, AppSpace.x2 * (1 - t)),
                                child: child,
                              ),
                            ),
                            child: Image.asset(
                              AppLogos.wordmarkWhite,
                              width: 190,
                              semanticLabel: 'Geepay',
                            ),
                          ),
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
                          _loginStep(context, state),
                          const SizedBox(height: AppSpace.x6),
                          KioskTapGesture(
                            child: Row(
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
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

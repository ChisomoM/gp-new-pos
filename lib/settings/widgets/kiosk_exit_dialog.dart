import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/design_system.dart';
import 'package:geepay_pos/utils/kiosk_helper.dart';
import 'package:geepay_pos/widgets/widgets.dart';

/// Shown by the hidden tap gesture on the Settings screen's app-version row.
/// Verifies [expectedPin] against what's entered, and on a match calls
/// [KioskHelper.exitKiosk] -- a temporary, session-scoped unlock; the lock
/// re-engages automatically the next time the app launches (see
/// `SplashCubit`), so there is no separate "re-enable kiosk" action.
Future<void> showKioskExitDialog(
  BuildContext context, {
  required String expectedPin,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: AppColors.gpNavy.withValues(alpha: 0.4),
    transitionDuration: AppMotion.of(context, AppMotion.slow),
    pageBuilder: (context, _, _) => _KioskExitDialog(expectedPin: expectedPin),
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: AppMotion.enter,
        reverseCurve: AppMotion.exit,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _KioskExitDialog extends StatefulWidget {
  const _KioskExitDialog({required this.expectedPin});

  final String expectedPin;

  @override
  State<_KioskExitDialog> createState() => _KioskExitDialogState();
}

class _KioskExitDialogState extends State<_KioskExitDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_controller.text == widget.expectedPin) {
      Navigator.pop(context);
      unawaited(KioskHelper.exitKiosk());
    } else {
      setState(() => _error = 'Incorrect PIN');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(AppSpace.x6),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: AppRadius.brXl,
            boxShadow: AppShadows.overlay,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpace.x6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Exit kiosk mode',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.title3,
                ),
                const SizedBox(height: AppSpace.x2),
                Text(
                  'Enter the admin PIN to unlock this terminal.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: AppSpace.x4),
                AppTextField(
                  controller: _controller,
                  obscureText: true,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  errorText: _error,
                  onSubmitted: (_) => _submit(),
                  onChanged: (_) {
                    if (_error != null) setState(() => _error = null);
                  },
                ),
                const SizedBox(height: AppSpace.x6),
                Row(
                  children: [
                    Expanded(
                      child: AppButton.secondary(
                        label: 'Cancel',
                        size: AppButtonSize.md,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: AppSpace.x3),
                    Expanded(
                      child: AppButton(
                        label: 'Unlock',
                        size: AppButtonSize.md,
                        onPressed: _submit,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

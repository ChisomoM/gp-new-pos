import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geepay_pos/app/theme/design_system.dart';

enum ToastTone { info, success, warning, error }

/// Shows a toast (plan §3) from a [BuildContext].
void showToast(
  BuildContext context, {
  required String message,
  String? title,
  ToastTone tone = ToastTone.info,
  Duration? duration,
  VoidCallback? onClosed,
}) {
  if (!context.mounted) return;
  showToastOn(
    ScaffoldMessenger.of(context),
    message: message,
    title: title,
    tone: tone,
    duration: duration,
    onClosed: onClosed,
  );
}

/// Shows a toast on a [ScaffoldMessengerState], for code without a
/// widget context (printer helpers use the global messenger key).
void showToastOn(
  ScaffoldMessengerState messenger, {
  required String message,
  String? title,
  ToastTone tone = ToastTone.info,
  Duration? duration,
  VoidCallback? onClosed,
}) {
  switch (tone) {
    case ToastTone.success:
      unawaited(HapticFeedback.lightImpact());
    case ToastTone.error:
    case ToastTone.warning:
      unawaited(HapticFeedback.mediumImpact());
    case ToastTone.info:
      break;
  }
  messenger.hideCurrentSnackBar();
  final controller = messenger.showSnackBar(
    SnackBar(
      content: AppToast(message: message, title: title, tone: tone),
      duration:
          duration ??
          (tone == ToastTone.success
              ? const Duration(seconds: 2)
              : const Duration(seconds: 4)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      padding: EdgeInsets.zero,
      behavior: SnackBarBehavior.floating,
      dismissDirection: DismissDirection.down,
    ),
  );
  if (onClosed != null) unawaited(controller.closed.then((_) => onClosed()));
}

/// The toast card: white surface, overlay shadow, semantic icon, optional
/// title and message.
class AppToast extends StatelessWidget {
  const AppToast({
    required this.message,
    this.title,
    this.tone = ToastTone.info,
    super.key,
  });

  final String message;
  final String? title;
  final ToastTone tone;

  @override
  Widget build(BuildContext context) {
    final (icon, fg, bg) = switch (tone) {
      ToastTone.success => (
        AppIcons.success,
        AppColors.successIcon,
        AppColors.successFill,
      ),
      ToastTone.error => (
        AppIcons.failed,
        AppColors.dangerIcon,
        AppColors.dangerFill,
      ),
      ToastTone.warning => (
        AppIcons.warning,
        AppColors.warningIcon,
        AppColors.warningFill,
      ),
      ToastTone.info => (AppIcons.info, AppColors.gpCobalt, AppColors.infoFill),
    };
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpace.x3),
        decoration: const BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: AppRadius.brMd,
          boxShadow: AppShadows.overlay,
        ),
        child: Row(
          children: [
            Container(
              width: AppSpace.x8,
              height: AppSpace.x8,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: Icon(icon, size: AppIconSize.md, color: fg),
            ),
            const SizedBox(width: AppSpace.x3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title != null)
                    Text(title!, style: AppTextStyles.bodyStrong),
                  Text(
                    message,
                    style: AppTextStyles.body.copyWith(
                      color: title == null
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

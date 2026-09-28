import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/design_system.dart';
import 'package:geepay_pos/widgets/status_badge.dart';

/// Inline alert (plan §3): a tinted banner with a semantic icon, for
/// messages that belong to a form or section, such as a failed login.
/// Use a toast for app-level, transient feedback instead.
class AppAlert extends StatelessWidget {
  const AppAlert({
    required this.message,
    this.title,
    this.tone = BadgeTone.danger,
    super.key,
  });

  final String message;
  final String? title;
  final BadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final (icon, iconColor, textColor, fill) = switch (tone) {
      BadgeTone.success => (
        AppIcons.success,
        AppColors.successIcon,
        AppColors.successText,
        AppColors.successFill,
      ),
      BadgeTone.warning => (
        AppIcons.warning,
        AppColors.warningIcon,
        AppColors.warningText,
        AppColors.warningFill,
      ),
      BadgeTone.danger => (
        AppIcons.warning,
        AppColors.dangerIcon,
        AppColors.dangerText,
        AppColors.dangerFill,
      ),
      BadgeTone.info || BadgeTone.neutral => (
        AppIcons.info,
        AppColors.gpCobalt,
        AppColors.infoText,
        AppColors.infoFill,
      ),
    };
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpace.x3),
        decoration: BoxDecoration(color: fill, borderRadius: AppRadius.brMd),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: AppIconSize.md, color: iconColor),
            const SizedBox(width: AppSpace.x2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null)
                    Text(
                      title!,
                      style: AppTextStyles.bodyStrong.copyWith(
                        color: textColor,
                      ),
                    ),
                  Text(
                    message,
                    style: AppTextStyles.body.copyWith(color: textColor),
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

/// Reserves no space when [message] is empty and slides an [AppAlert] in
/// (with [spacing] above it) when a message arrives.
class AnimatedAlert extends StatelessWidget {
  const AnimatedAlert({
    required this.message,
    this.tone = BadgeTone.danger,
    this.spacing = AppSpace.x4,
    super.key,
  });

  final String? message;
  final BadgeTone tone;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final text = message;
    final visible = text != null && text.isNotEmpty;
    return AnimatedSize(
      duration: AppMotion.of(context, AppMotion.base),
      curve: AppMotion.enter,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: AppMotion.of(context, AppMotion.fast),
        child: visible
            ? Padding(
                key: ValueKey(text),
                padding: EdgeInsets.only(top: spacing),
                child: AppAlert(message: text, tone: tone),
              )
            : const SizedBox(width: double.infinity),
      ),
    );
  }
}

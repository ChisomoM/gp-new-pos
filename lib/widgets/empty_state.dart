import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/design_system.dart';
import 'package:geepay_pos/widgets/app_button.dart';
import 'package:geepay_pos/widgets/status_badge.dart';

/// Empty state (plan §3): a 64px icon circle, headline, supporting text
/// and an optional action. Fades and scales in so it never pops.
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    this.message,
    this.action,
    this.badge,
    this.iconColor = AppColors.gpCobalt,
    this.iconBackground = AppColors.infoFill,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? message;

  /// Usually an [AppButton].
  final Widget? action;

  /// Optional pill above the title, e.g. "Coming soon".
  final StatusBadge? badge;
  final Color iconColor;
  final Color iconBackground;

  @override
  Widget build(BuildContext context) {
    return _EntranceFade(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.x6,
          vertical: AppSpace.x8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AppSpace.x16,
              height: AppSpace.x16,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: iconBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: AppIconSize.xl, color: iconColor),
            ),
            const SizedBox(height: AppSpace.x4),
            if (badge != null) ...[
              badge!,
              const SizedBox(height: AppSpace.x2),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.headline,
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpace.x1),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: AppSpace.x6),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Error state with a retry action (plan §3).
class ErrorState extends StatelessWidget {
  const ErrorState({
    this.message,
    this.onRetry,
    this.title = "Couldn't load this",
    super.key,
  });

  final String? message;
  final VoidCallback? onRetry;
  final String title;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: AppIcons.warning,
      iconColor: AppColors.dangerIcon,
      iconBackground: AppColors.dangerFill,
      title: title,
      message: (message == null || message!.isEmpty)
          ? 'Check your connection and try again.'
          : message,
      action: onRetry == null
          ? null
          : AppButton.secondary(
              label: 'Try again',
              icon: AppIcons.refresh,
              size: AppButtonSize.md,
              expand: false,
              onPressed: onRetry,
            ),
    );
  }
}

class _EntranceFade extends StatelessWidget {
  const _EntranceFade({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppMotion.of(context, AppMotion.base),
      curve: AppMotion.enter,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.scale(scale: 0.96 + 0.04 * t, child: child),
      ),
      child: child,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/design_system.dart';

/// Shows a bottom sheet (plan §3): radius 24 top corners, a drag handle,
/// optional title, and slide-up motion on the slow token.
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required Widget child,
  String? title,
  String? subtitle,
  bool isScrollControlled = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useSafeArea: true,
    barrierColor: AppColors.gpNavy.withValues(alpha: 0.4),
    sheetAnimationStyle: AnimationStyle(
      duration: AppMotion.of(context, AppMotion.slow),
      reverseDuration: AppMotion.of(context, AppMotion.base),
      curve: AppMotion.enter,
    ),
    builder: (context) =>
        AppSheet(title: title, subtitle: subtitle, child: child),
  );
}

/// Bottom sheet body: drag handle, optional title / subtitle, content.
class AppSheet extends StatelessWidget {
  const AppSheet({required this.child, this.title, this.subtitle, super.key});

  final Widget child;
  final String? title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpace.gutter,
        right: AppSpace.gutter,
        bottom:
            MediaQuery.viewInsetsOf(context).bottom +
            MediaQuery.paddingOf(context).bottom +
            AppSpace.x4,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: AppSpace.x1,
              margin: const EdgeInsets.symmetric(vertical: AppSpace.x3),
              decoration: const BoxDecoration(
                color: AppColors.borderMedium,
                borderRadius: AppRadius.brFull,
              ),
            ),
          ),
          if (title != null) ...[
            Text(title!, style: AppTextStyles.title3),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpace.x1),
              Text(
                subtitle!,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
            const SizedBox(height: AppSpace.x4),
          ],
          Flexible(child: child),
        ],
      ),
    );
  }
}

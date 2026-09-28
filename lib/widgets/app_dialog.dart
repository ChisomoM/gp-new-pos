import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/design_system.dart';
import 'package:geepay_pos/utils/enums.dart';
import 'package:geepay_pos/widgets/app_button.dart';

class DialogOption {
  DialogOption({required this.text, this.value, this.selected = false});

  final dynamic value;
  final String text;
  final bool selected;
}

/// Shows the app dialog (plan §3): radius 24, fades and scales in from
/// 96%. Returns `true` when confirmed, `false` when cancelled.
///
/// [destructive] styles the confirm button for irreversible actions.
Future<dynamic> showAppDialog(
  BuildContext context, {
  required String title,
  required String message,
  String yesText = 'Yes',
  String noText = 'No',
  DialogType dialogType = DialogType.yesNo,
  VoidCallback? onConfirm,
  List<DialogOption> options = const [],
  void Function(dynamic)? onSelect,
  bool barrierDismissible = true,
  bool destructive = false,
  IconData? icon,
}) {
  return showGeneralDialog<dynamic>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: AppColors.gpNavy.withValues(alpha: 0.4),
    transitionDuration: AppMotion.of(context, AppMotion.slow),
    pageBuilder: (context, _, _) => AppDialog(
      title: title,
      message: message,
      yesText: yesText,
      noText: noText,
      dialogType: dialogType,
      onConfirm: onConfirm,
      onSelect: onSelect,
      options: options,
      destructive: destructive,
      icon: icon,
    ),
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

class AppDialog extends StatelessWidget {
  const AppDialog({
    required this.title,
    required this.message,
    this.yesText = 'Yes',
    this.noText = 'No',
    this.dialogType = DialogType.yesNo,
    this.onConfirm,
    this.onSelect,
    this.options = const [],
    this.destructive = false,
    this.icon,
    super.key,
  });

  final String title;
  final String message;
  final String yesText;
  final String noText;
  final DialogType dialogType;
  final VoidCallback? onConfirm;
  final void Function(dynamic)? onSelect;
  final List<DialogOption> options;
  final bool destructive;
  final IconData? icon;

  void _confirm(BuildContext context) {
    Navigator.pop(context, true);
    onConfirm?.call();
  }

  @override
  Widget build(BuildContext context) {
    final confirm = destructive
        ? AppButton.destructive(
            label: yesText,
            size: AppButtonSize.md,
            onPressed: () => _confirm(context),
          )
        : AppButton(
            label: yesText,
            size: AppButtonSize.md,
            onPressed: () => _confirm(context),
          );

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
                if (icon != null) ...[
                  Center(
                    child: Container(
                      width: AppSpace.x12,
                      height: AppSpace.x12,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: destructive
                            ? AppColors.dangerFill
                            : AppColors.infoFill,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        size: AppIconSize.lg,
                        color: destructive
                            ? AppColors.dangerIcon
                            : AppColors.gpCobalt,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpace.x4),
                ],
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.title3,
                ),
                const SizedBox(height: AppSpace.x2),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: AppSpace.x6),
                switch (dialogType) {
                  DialogType.yesNo => Row(
                    children: [
                      Expanded(
                        child: AppButton.secondary(
                          label: noText,
                          size: AppButtonSize.md,
                          onPressed: () => Navigator.pop(context, false),
                        ),
                      ),
                      const SizedBox(width: AppSpace.x3),
                      Expanded(child: confirm),
                    ],
                  ),
                  DialogType.info => confirm,
                  DialogType.select => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final option in options) ...[
                        if (option != options.first)
                          const SizedBox(height: AppSpace.x2),
                        _SelectOption(
                          option: option,
                          onTap: () {
                            Navigator.pop(context, true);
                            onSelect?.call(option.value);
                          },
                        ),
                      ],
                    ],
                  ),
                },
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectOption extends StatelessWidget {
  const _SelectOption({required this.option, required this.onTap});

  final DialogOption option;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return option.selected
        ? AppButton(
            label: option.text,
            icon: AppIcons.success,
            size: AppButtonSize.md,
            onPressed: onTap,
          )
        : AppButton.secondary(
            label: option.text,
            size: AppButtonSize.md,
            onPressed: onTap,
          );
  }
}

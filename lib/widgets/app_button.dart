import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/design_system.dart';
import 'package:geepay_pos/widgets/pressable.dart';

enum AppButtonVariant {
  /// Brand gradient with glow. One per screen.
  primary,

  /// White with a neutral border.
  secondary,

  /// Text only, cobalt.
  tertiary,

  /// Soft red, for irreversible actions such as logging out.
  destructive,
}

enum AppButtonSize {
  /// 52px. Screen-level actions.
  lg,

  /// 44px. Dialogs, inline actions.
  md,

  /// 36px. Compact actions inside rows and headers.
  sm,
}

/// The app's only button (plan §3). Replaces `GradientButton`, the old
/// `AppButton` / `PrimaryButton` and one-off `OutlinedButton` styles.
///
/// Loading cross-fades the label to a spinner while keeping the button's
/// width, and ignores taps.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.lg,
    this.icon,
    this.isLoading = false,
    this.expand = true,
    super.key,
  });

  const AppButton.secondary({
    required this.label,
    this.onPressed,
    this.size = AppButtonSize.lg,
    this.icon,
    this.isLoading = false,
    this.expand = true,
    super.key,
  }) : variant = AppButtonVariant.secondary;

  const AppButton.tertiary({
    required this.label,
    this.onPressed,
    this.size = AppButtonSize.sm,
    this.icon,
    this.isLoading = false,
    this.expand = false,
    super.key,
  }) : variant = AppButtonVariant.tertiary;

  const AppButton.destructive({
    required this.label,
    this.onPressed,
    this.size = AppButtonSize.lg,
    this.icon,
    this.isLoading = false,
    this.expand = true,
    super.key,
  }) : variant = AppButtonVariant.destructive;

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;

  /// Optional leading icon. Only use one when it adds meaning (print,
  /// share); forward actions such as "Continue" get none.
  final IconData? icon;
  final bool isLoading;

  /// Fill the available width.
  final bool expand;

  double get _height => switch (size) {
    AppButtonSize.lg => AppSize.buttonLg,
    AppButtonSize.md => AppSize.buttonMd,
    AppButtonSize.sm => AppSize.buttonSm,
  };

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    final isPrimary = variant == AppButtonVariant.primary;

    final foreground = switch (variant) {
      AppButtonVariant.primary => AppColors.onBrandHigh,
      AppButtonVariant.secondary => AppColors.textSecondary,
      AppButtonVariant.tertiary => AppColors.gpCobalt,
      AppButtonVariant.destructive => AppColors.dangerText,
    };
    final background = switch (variant) {
      AppButtonVariant.primary => enabled ? null : AppColors.disabledFill,
      AppButtonVariant.secondary => AppColors.surfaceWhite,
      AppButtonVariant.tertiary => Colors.transparent,
      AppButtonVariant.destructive => AppColors.dangerFill,
    };
    final border = switch (variant) {
      AppButtonVariant.secondary => Border.all(color: AppColors.borderMedium),
      AppButtonVariant.destructive => Border.all(
        color: AppColors.dangerFillAlt,
      ),
      _ => null,
    };

    final textStyle =
        (size == AppButtonSize.sm ? AppTextStyles.label : AppTextStyles.button)
            .copyWith(color: foreground);
    final iconSize = size == AppButtonSize.sm ? AppIconSize.sm : AppIconSize.md;

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: iconSize, color: foreground),
          const SizedBox(width: AppSpace.x2),
        ],
        // Full-width buttons ellipsize a long label; hugging buttons size
        // to it.
        if (expand)
          Flexible(
            child: Text(
              label,
              style: textStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          )
        else
          Text(label, style: textStyle, maxLines: 1),
      ],
    );

    final duration = AppMotion.of(context, AppMotion.fast);
    final button = Pressable(
      onTap: enabled ? onPressed : null,
      haptic: isPrimary ? PressHaptic.light : PressHaptic.none,
      gradient: isPrimary && enabled ? AppGradients.primary : null,
      color: background,
      border: border,
      boxShadow: isPrimary && enabled ? AppShadows.brandGlow : null,
      splashColor: isPrimary ? AppColors.onBrandStroke : null,
      child: SizedBox(
        height: _height,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size == AppButtonSize.sm ? AppSpace.x3 : AppSpace.x5,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedOpacity(
                opacity: isLoading ? 0 : 1,
                duration: duration,
                child: content,
              ),
              AnimatedOpacity(
                opacity: isLoading ? 1 : 0,
                duration: duration,
                child: SizedBox.square(
                  dimension: iconSize,
                  child: isLoading
                      ? CircularProgressIndicator(
                          strokeWidth: 2,
                          color: foreground,
                        )
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: isLoading ? '$label, loading' : null,
      excludeSemantics: isLoading,
      child: AnimatedOpacity(
        // Primary shows a dedicated disabled fill; other variants fade.
        opacity: enabled || isPrimary || isLoading ? 1 : 0.4,
        duration: duration,
        child: expand
            ? SizedBox(width: double.infinity, child: button)
            : button,
      ),
    );
  }
}

enum AppIconButtonVariant {
  /// Quiet grey fill. Header back buttons.
  subtle,

  /// White with a neutral border. Next to secondary buttons.
  outline,

  /// No fill.
  ghost,

  /// Translucent white, on brand gradients.
  onBrand,
}

/// Icon-only button: 40px visual inside a 48px hit area (plan §2.7).
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.variant = AppIconButtonVariant.subtle,
    this.size = AppSize.iconButton,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  /// Accessible label, also shown on long press.
  final String tooltip;
  final AppIconButtonVariant variant;

  /// Visual size. The hit area is never smaller than 48px.
  final double size;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = switch (variant) {
      AppIconButtonVariant.subtle => (
        AppColors.surfaceSubtle,
        AppColors.textSecondary,
        null,
      ),
      AppIconButtonVariant.outline => (
        AppColors.surfaceWhite,
        AppColors.textSecondary,
        Border.all(color: AppColors.borderMedium),
      ),
      AppIconButtonVariant.ghost => (
        Colors.transparent,
        AppColors.textSecondary,
        null,
      ),
      AppIconButtonVariant.onBrand => (
        AppColors.onBrandFill,
        AppColors.onBrandHigh,
        Border.all(color: AppColors.onBrandStroke),
      ),
    };
    final hitSize = size < AppSize.touchTarget ? AppSize.touchTarget : size;
    return Tooltip(
      message: tooltip,
      triggerMode: TooltipTriggerMode.longPress,
      child: Semantics(
        button: true,
        enabled: onPressed != null,
        label: tooltip,
        onTap: onPressed,
        excludeSemantics: true,
        // The transparent ring around the visual button still counts as
        // a tap, so the hit area is 48px even though the button is 40px.
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: onPressed,
          child: SizedBox.square(
            dimension: hitSize,
            child: Center(
              child: Pressable(
                onTap: onPressed,
                color: bg,
                border: border,
                pressScale: 0.94,
                child: SizedBox.square(
                  dimension: size,
                  child: Icon(icon, size: AppIconSize.md, color: fg),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

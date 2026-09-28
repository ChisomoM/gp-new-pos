import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/design_system.dart';
import 'package:geepay_pos/widgets/app_button.dart';

/// Screen header (plan §3): 56px, white, bottom divider, 18px title and a
/// chevron back button with a 48px hit area. [AppHeader.large] is the
/// variant for bottom-navigation tabs: a 20px title and no back button.
/// Replaces `BackHeader` and the Printer settings copy.
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({
    required this.title,
    this.onBack,
    this.actions = const [],
    this.showBack,
    super.key,
  }) : large = false;

  const AppHeader.large({
    required this.title,
    this.actions = const [],
    super.key,
  }) : large = true,
       onBack = null,
       showBack = false;

  final String title;

  /// Custom back behaviour. Defaults to popping the route.
  final VoidCallback? onBack;
  final List<Widget> actions;

  /// Forces the back button on or off. By default it shows when [onBack]
  /// is set or the route can pop.
  final bool? showBack;
  final bool large;

  @override
  Size get preferredSize => const Size.fromHeight(AppSize.appBar);

  @override
  Widget build(BuildContext context) {
    final canGoBack =
        showBack ?? (onBack != null || Navigator.of(context).canPop());
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surfaceWhite,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: AppSize.appBar,
          child: Row(
            children: [
              if (canGoBack) ...[
                const SizedBox(width: AppSpace.x3),
                AppIconButton(
                  icon: AppIcons.back,
                  tooltip: 'Back',
                  onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                ),
                const SizedBox(width: AppSpace.x2),
              ] else
                const SizedBox(width: AppSpace.gutter),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: large ? AppTextStyles.title2 : AppTextStyles.title3,
                  ),
                ),
              ),
              ...actions,
              SizedBox(
                width: actions.isEmpty ? AppSpace.gutter : AppSpace.x3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Section title with an optional trailing action (plan §3).
///
/// [overline] renders a small upper-case label, used above grouped
/// settings rows; otherwise a 16px headline.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
    this.overline = false,
    this.actionLoading = false,
    super.key,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool overline;
  final bool actionLoading;

  @override
  Widget build(BuildContext context) {
    final titleWidget = Semantics(
      header: true,
      child: Text(
        overline ? title.toUpperCase() : title,
        style: overline
            ? AppTextStyles.overline.copyWith(color: AppColors.textTertiary)
            : AppTextStyles.headline,
      ),
    );
    return Padding(
      padding: EdgeInsets.only(left: overline ? AppSpace.x1 : 0),
      child: Row(
        children: [
          Expanded(child: titleWidget),
          if (actionLabel != null)
            _SectionAction(
              label: actionLabel!,
              onTap: onAction,
              loading: actionLoading,
            ),
        ],
      ),
    );
  }
}

class _SectionAction extends StatelessWidget {
  const _SectionAction({
    required this.label,
    required this.onTap,
    required this.loading,
  });

  final String label;
  final VoidCallback? onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    // A negative right margin keeps the text optically aligned with the
    // content edge while the tap target keeps its padding.
    return Transform.translate(
      offset: const Offset(AppSpace.x2, 0),
      child: TextButton(
        onPressed: loading ? null : onTap,
        style: TextButton.styleFrom(
          minimumSize: const Size(AppSize.touchTarget, AppSize.buttonSm),
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.x2),
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            const SizedBox(width: AppSpace.x1),
            if (loading)
              const SizedBox.square(
                dimension: AppIconSize.sm,
                child: CircularProgressIndicator(strokeWidth: 1.5),
              )
            else
              const Icon(AppIcons.chevronRight, size: AppIconSize.sm),
          ],
        ),
      ),
    );
  }
}

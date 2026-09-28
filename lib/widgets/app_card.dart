import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/design_system.dart';
import 'package:geepay_pos/widgets/pressable.dart';

/// Card elevation (plan §2.5). A card gets a border or a shadow, not both.
enum AppCardElevation {
  /// 1px border, no shadow. Cards on white or dense lists.
  flat,

  /// Resting shadow. Cards on the grey page background.
  card,

  /// Stronger shadow. Floating over a hero.
  raised,
}

/// Surface container (plan §3): radius 16, padding 16. Optionally
/// tappable and selectable (radio-style choice cards).
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpace.card),
    this.elevation = AppCardElevation.flat,
    this.color = AppColors.surfaceWhite,
    this.onTap,
    this.selected = false,
    this.borderRadius = AppRadius.brLg,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final AppCardElevation elevation;
  final Color color;
  final VoidCallback? onTap;

  /// Selected choice card: info fill and a cobalt border.
  final bool selected;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final border = selected
        ? Border.all(color: AppColors.gpCobalt, width: 1.5)
        : elevation == AppCardElevation.flat
        ? Border.all(color: AppColors.borderLight)
        : null;
    final shadow = selected
        ? null
        : switch (elevation) {
            AppCardElevation.flat => null,
            AppCardElevation.card => AppShadows.card,
            AppCardElevation.raised => AppShadows.raised,
          };
    return Pressable(
      onTap: onTap,
      pressScale: onTap == null ? 1 : 0.99,
      haptic: onTap == null ? PressHaptic.none : PressHaptic.selection,
      borderRadius: borderRadius,
      color: selected ? AppColors.infoFill : color,
      border: border,
      boxShadow: shadow,
      child: Padding(padding: padding, child: child),
    );
  }
}

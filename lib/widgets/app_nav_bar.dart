import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geepay_pos/app/theme/design_system.dart';

/// One destination in [AppNavBar].
class AppNavItem {
  const AppNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  /// Linear glyph for the inactive state.
  final IconData icon;

  /// Bold glyph for the active state.
  final IconData activeIcon;
  final String label;
}

/// Bottom navigation (plan §3): 64px, linear icons that swap to bold when
/// active, a pill indicator that fades in behind the active icon, 12px
/// labels and a selection haptic.
class AppNavBar extends StatelessWidget {
  const AppNavBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final List<AppNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surfaceWhite,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppSize.navBar,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _NavButton(
                    item: items[i],
                    selected: i == currentIndex,
                    onTap: () {
                      if (i != currentIndex) {
                        unawaited(HapticFeedback.selectionClick());
                      }
                      onTap(i);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final AppNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final duration = AppMotion.of(context, AppMotion.base);
    final color = selected ? AppColors.gpCobalt : AppColors.textTertiary;
    return Semantics(
      selected: selected,
      button: true,
      label: item.label,
      onTap: onTap,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        highlightShape: BoxShape.rectangle,
        containedInkWell: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: duration,
              curve: AppMotion.enter,
              width: selected ? 56 : AppSpace.x8,
              height: AppSpace.x8,
              decoration: BoxDecoration(
                color: selected ? AppColors.infoFill : Colors.transparent,
                borderRadius: AppRadius.brFull,
              ),
              child: AnimatedSwitcher(
                duration: duration,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(
                      begin: 0.85,
                      end: 1,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: Icon(
                  selected ? item.activeIcon : item.icon,
                  key: ValueKey(selected),
                  size: AppIconSize.lg,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: AppSpace.x1),
            AnimatedDefaultTextStyle(
              duration: duration,
              style:
                  (selected
                          ? AppTextStyles.captionStrong
                          : AppTextStyles.caption)
                      .copyWith(color: color),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/design_system.dart';
import 'package:geepay_pos/widgets/list_group.dart';

/// Single white card with internal 1px vertical dividers: the design
/// spec's "grouped toolbar card", used for Dashboard quick actions.
///
/// The card clips its children so each action's ripple stays inside the
/// rounded corners.
class GroupedToolbarCard extends StatelessWidget {
  const GroupedToolbarCard({required this.items, super.key});

  final List<GroupedToolbarItem> items;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      if (i > 0) {
        children.add(
          Container(
            width: 1,
            margin: const EdgeInsets.symmetric(vertical: AppSpace.x4),
            color: AppColors.borderSubtle,
          ),
        );
      }
      children.add(Expanded(child: items[i]));
    }
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: AppRadius.brLg,
        boxShadow: AppShadows.card,
      ),
      child: ClipRRect(
        borderRadius: AppRadius.brLg,
        child: Material(
          type: MaterialType.transparency,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}

class GroupedToolbarItem extends StatelessWidget {
  const GroupedToolbarItem({
    required this.icon,
    required this.label,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      onTap: onTap,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.x2,
            vertical: AppSpace.x4,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIconTile(icon: icon),
              const SizedBox(height: AppSpace.x2),
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

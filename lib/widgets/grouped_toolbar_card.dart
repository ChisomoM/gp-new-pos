import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/app_colors.dart';
import 'package:geepay_pos/app/theme/app_gradients.dart';

/// Single white radius-2xl card with internal 1px vertical dividers —
/// design spec's "grouped toolbar card" pattern, used for Dashboard quick
/// actions.
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
            margin: const EdgeInsets.symmetric(vertical: 14),
            color: const Color(0xFFF0F1F5),
          ),
        );
      }
      children.add(Expanded(child: items[i]));
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppGradients.card,
      ),
      child: Row(children: children),
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
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 16, 6, 14),
        child: Column(
          children: [
            Icon(icon, size: 19, color: AppColors.gpCobalt),
            const SizedBox(height: 7),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

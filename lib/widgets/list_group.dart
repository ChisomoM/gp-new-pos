import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/design_system.dart';
import 'package:geepay_pos/widgets/app_card.dart';
import 'package:geepay_pos/widgets/pressable.dart';

/// Rows grouped in one card with inset dividers (plan §2.8), instead of a
/// separately bordered card per row.
class ListGroup extends StatelessWidget {
  const ListGroup({
    required this.children,
    this.elevation = AppCardElevation.card,
    this.dividerIndent = AppSpace.x4 + AppSize.avatar + AppSpace.x3,
    super.key,
  });

  final List<Widget> children;
  final AppCardElevation elevation;

  /// Where dividers start: at the text, not under the leading icon. Use
  /// [AppSpace.x4] for rows without a leading widget.
  final double dividerIndent;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      elevation: elevation,
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) Divider(indent: dividerIndent),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// Row inside a [ListGroup] (plan §3): leading icon tile or avatar, title,
/// optional subtitle, and a trailing value, badge or chevron.
class AppListTile extends StatelessWidget {
  const AppListTile({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.showChevron,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  /// Defaults to showing a chevron when the row is tappable and has no
  /// [trailing] widget.
  final bool? showChevron;

  @override
  Widget build(BuildContext context) {
    final chevron = showChevron ?? (onTap != null && trailing == null);
    return Pressable(
      onTap: onTap,
      pressScale: 1,
      borderRadius: BorderRadius.zero,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: subtitle == null
              ? AppSize.listRowCompact
              : AppSize.listRow,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.x4,
            vertical: AppSpace.x3,
          ),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: AppSpace.x3),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyStrong,
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppSpace.x3),
                trailing!,
              ],
              if (chevron) ...[
                const SizedBox(width: AppSpace.x2),
                const Icon(
                  AppIcons.chevronRight,
                  size: AppIconSize.sm,
                  color: AppColors.textMuted,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 40px rounded-square icon container (plan §2.6).
class AppIconTile extends StatelessWidget {
  const AppIconTile({
    required this.icon,
    this.color = AppColors.gpCobalt,
    this.background = AppColors.infoFill,
    this.size = AppSize.avatar,
    super.key,
  });

  final IconData icon;
  final Color color;
  final Color background;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.of(context, AppMotion.fast),
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.brMd,
      ),
      child: Icon(icon, size: AppIconSize.md, color: color),
    );
  }
}

/// 40px circular initial avatar.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    required this.initial,
    this.color = AppColors.gpCobalt,
    this.background = AppColors.infoFill,
    this.size = AppSize.avatar,
    super.key,
  });

  final String initial;
  final Color color;
  final Color background;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Text(
        initial,
        style: AppTextStyles.labelStrong.copyWith(color: color),
      ),
    );
  }
}

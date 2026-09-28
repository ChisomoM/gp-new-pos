import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/design_system.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer wrapper for loading placeholders (plan §3). Shapes inside
/// should mirror the real layout. The sweep is off when reduced motion is
/// requested.
class Skeleton extends StatelessWidget {
  const Skeleton({required this.child, this.onBrand = false, super.key});

  final Widget child;

  /// Translucent white variant for use on the brand gradient.
  final bool onBrand;

  @override
  Widget build(BuildContext context) {
    final base = onBrand ? AppColors.onBrandStroke : AppColors.skeletonBase;
    final highlight = onBrand
        ? AppColors.onBrandLow.withValues(alpha: 0.35)
        : AppColors.skeletonHighlight;
    return Semantics(
      label: 'Loading',
      child: ExcludeSemantics(
        child: _SkeletonColor(
          color: base,
          child: AppMotion.reduced(context)
              ? child
              : Shimmer.fromColors(
                  baseColor: base,
                  highlightColor: highlight,
                  period: AppMotion.shimmer,
                  child: child,
                ),
        ),
      ),
    );
  }
}

class _SkeletonColor extends InheritedWidget {
  const _SkeletonColor({required this.color, required super.child});

  final Color color;

  static Color of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_SkeletonColor>()?.color ??
      AppColors.skeletonBase;

  @override
  bool updateShouldNotify(_SkeletonColor oldWidget) => color != oldWidget.color;
}

/// A single placeholder block. Use inside a [Skeleton].
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    this.width,
    this.height = AppSpace.x3,
    this.borderRadius = AppRadius.brXs,
    this.circle = false,
    super.key,
  });

  final double? width;
  final double height;
  final BorderRadius borderRadius;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: circle ? height : width,
      height: height,
      decoration: BoxDecoration(
        color: _SkeletonColor.of(context),
        borderRadius: circle ? null : borderRadius,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
      ),
    );
  }
}

/// Placeholder matching `TransactionRow`. The white card sits outside
/// the shimmer, which would otherwise paint over it.
class SkeletonTransactionRow extends StatelessWidget {
  const SkeletonTransactionRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpace.x3),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        border: Border.all(color: AppColors.borderLight),
        borderRadius: AppRadius.brLg,
      ),
      child: const Skeleton(
        child: Row(
          children: [
            SkeletonBox(height: AppSize.avatar, circle: true),
            SizedBox(width: AppSpace.x3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 120),
                  SizedBox(height: AppSpace.x2),
                  SkeletonBox(width: 80, height: 10),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SkeletonBox(width: 72),
                SizedBox(height: AppSpace.x2),
                SkeletonBox(
                  width: 56,
                  height: AppSpace.x4,
                  borderRadius: AppRadius.brFull,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A column of [SkeletonTransactionRow]s.
class SkeletonTransactionList extends StatelessWidget {
  const SkeletonTransactionList({this.count = 5, super.key});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) const SizedBox(height: AppSpace.x2),
          const SkeletonTransactionRow(),
        ],
      ],
    );
  }
}

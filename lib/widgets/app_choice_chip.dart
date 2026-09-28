import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/design_system.dart';
import 'package:geepay_pos/widgets/pressable.dart';

/// Selectable chip (plan §3): history filters (pill) and amount presets
/// (rounded). 36px tall; selection animates fill, border and text colour.
class AppChoiceChip extends StatelessWidget {
  const AppChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.pill = true,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  /// Fully rounded (filters). `false` uses the medium radius (presets).
  final bool pill;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: Pressable(
        onTap: onTap,
        haptic: PressHaptic.selection,
        pressScale: 0.96,
        borderRadius: pill ? AppRadius.brFull : AppRadius.brMd,
        color: selected ? AppColors.infoFill : AppColors.surfaceWhite,
        border: Border.all(
          color: selected ? AppColors.gpCobalt : AppColors.borderLight,
          width: 1.5,
        ),
        child: Container(
          height: AppSize.chip,
          padding: EdgeInsets.symmetric(
            horizontal: pill ? AppSpace.x4 : AppSpace.x3,
          ),
          // widthFactor keeps the chip hugging its label when the parent
          // allows any width (Wrap, Row), and it still fills a tight slot
          // (Expanded amount presets).
          child: Center(
            widthFactor: 1,
            child: AnimatedDefaultTextStyle(
              duration: AppMotion.of(context, AppMotion.fast),
              style: AppTextStyles.label.copyWith(
                color: selected
                    ? AppColors.selectedText
                    : AppColors.unselectedText,
              ),
              child: Text(label, maxLines: 1),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geepay_pos/app/theme/design_system.dart';
import 'package:geepay_pos/widgets/app_card.dart';
import 'package:geepay_pos/widgets/pressable.dart';

/// One row of a [KeyValueList].
class KeyValueItem {
  const KeyValueItem(this.label, this.value, {this.copyable = false});

  final String label;
  final String value;

  /// Tap to copy the value (IDs, references).
  final bool copyable;
}

/// Label / value rows in one card (plan §3): the label in tertiary text,
/// the value right-aligned. Replaces the three private copies in details,
/// result and printer settings.
class KeyValueList extends StatelessWidget {
  const KeyValueList({
    required this.items,
    this.elevation = AppCardElevation.flat,
    super.key,
  });

  final List<KeyValueItem> items;
  final AppCardElevation elevation;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      elevation: elevation,
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const Divider(indent: AppSpace.x4),
            _KeyValueRow(item: items[i]),
          ],
        ],
      ),
    );
  }
}

class _KeyValueRow extends StatefulWidget {
  const _KeyValueRow({required this.item});

  final KeyValueItem item;

  @override
  State<_KeyValueRow> createState() => _KeyValueRowState();
}

class _KeyValueRowState extends State<_KeyValueRow> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.item.value));
    await HapticFeedback.lightImpact();
    if (!mounted) return;
    setState(() => _copied = true);
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final valueStyle = AppTextStyles.bodyStrong.copyWith(
      color: AppColors.textSecondary,
    );
    final row = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.x4,
        vertical: AppSpace.x3,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.label,
            style: AppTextStyles.body.copyWith(color: AppColors.textTertiary),
          ),
          const SizedBox(width: AppSpace.x3),
          Expanded(
            child: AnimatedSwitcher(
              duration: AppMotion.of(context, AppMotion.fast),
              layoutBuilder: (current, previous) => Stack(
                alignment: Alignment.centerRight,
                children: [...previous, ?current],
              ),
              child: _copied
                  ? Text(
                      'Copied',
                      key: const ValueKey('copied'),
                      textAlign: TextAlign.right,
                      style: valueStyle.copyWith(color: AppColors.successText),
                    )
                  : Text(
                      item.value,
                      key: const ValueKey('value'),
                      textAlign: TextAlign.right,
                      style: valueStyle,
                    ),
            ),
          ),
          if (item.copyable) ...[
            const SizedBox(width: AppSpace.x2),
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(
                AppIcons.copy,
                size: AppIconSize.sm,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
    if (!item.copyable) return row;
    return Semantics(
      button: true,
      hint: 'Copy ${item.label}',
      child: Pressable(
        onTap: _copy,
        pressScale: 1,
        borderRadius: BorderRadius.zero,
        child: row,
      ),
    );
  }
}

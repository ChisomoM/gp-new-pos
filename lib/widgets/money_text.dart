import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/design_system.dart';
import 'package:intl/intl.dart';

/// Formatting for monetary values. Every amount in the app goes through
/// here so separators and decimals are consistent.
abstract final class Money {
  static final NumberFormat _format = NumberFormat('#,##0.00', 'en_US');

  /// `12450` → `12,450.00`.
  static String format(num amount) => _format.format(amount);

  /// `12450, 'ZMW'` → `ZMW 12,450.00`.
  static String withCurrency(num amount, {String currency = 'ZMW'}) =>
      '$currency ${format(amount)}';
}

/// Renders an amount (plan §2.2): DM Sans tabular figures, thousands
/// separators, the currency code one step smaller and muted, optional
/// muted decimals for large figures, and an optional count-up when the
/// value changes.
class MoneyText extends StatelessWidget {
  const MoneyText(
    this.amount, {
    this.currency = 'ZMW',
    this.fontSize = AppTextStyles.numSm,
    this.fontWeight = FontWeight.w600,
    this.color = AppColors.textPrimary,
    this.mutedColor,
    this.muteDecimals = false,
    this.animate = false,
    this.textAlign,
    super.key,
  });

  final num amount;

  /// Pass `null` to hide the currency code.
  final String? currency;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;

  /// Colour for the currency code (and decimals when [muteDecimals]).
  /// Defaults to tertiary text, or [color] at 70% on custom colours.
  final Color? mutedColor;
  final bool muteDecimals;

  /// Count up from the previous value when [amount] changes.
  final bool animate;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    if (!animate) return _build(amount.toDouble());
    return TweenAnimationBuilder<double>(
      tween: Tween(end: amount.toDouble()),
      duration: AppMotion.of(context, AppMotion.emphasis),
      curve: AppMotion.enter,
      builder: (context, value, _) => _build(value),
    );
  }

  Widget _build(double value) {
    final formatted = Money.format(value);
    final dot = formatted.lastIndexOf('.');
    final whole = formatted.substring(0, dot);
    final decimals = formatted.substring(dot);
    final muted =
        mutedColor ??
        (color == AppColors.textPrimary
            ? AppColors.textTertiary
            : color.withValues(alpha: 0.7));
    final base = AppTextStyles.gpNum(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
    final small = base.copyWith(
      fontSize: fontSize >= 24 ? fontSize * 0.5 : fontSize * 0.85,
      color: muted,
    );
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          if (currency != null) TextSpan(text: '$currency ', style: small),
          TextSpan(text: whole),
          TextSpan(
            text: decimals,
            style: muteDecimals
                ? base.copyWith(fontSize: fontSize * 0.7, color: muted)
                : null,
          ),
        ],
      ),
      textAlign: textAlign,
      maxLines: 1,
      semanticsLabel: '${currency ?? ''} $formatted'.trim(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geepay_pos/app/theme/design_system.dart';

/// Labeled text input (plan §3): label 8px above, 52px field with a 1.5px
/// border that animates to cobalt on focus, and helper / error text 4px
/// below that slides in instead of popping.
///
/// Covers plain text, phone, amount (via [textStyle] + [prefixText]) and
/// password ([obscureText]) fields.
class AppTextField extends StatefulWidget {
  const AppTextField({
    this.label,
    this.controller,
    this.hintText,
    this.helperText,
    this.errorText,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.fillColor = AppColors.surfaceWhite,
    this.prefixIcon,
    this.prefixText,
    this.textStyle,
    this.hintStyle,
    this.prefixStyle,
    this.obscureText = false,
    this.autofocus = false,
    this.inputFormatters,
    this.focusNode,
    this.labelTrailing,
    super.key,
  });

  final String? label;
  final TextEditingController? controller;
  final String? hintText;
  final String? helperText;

  /// Shown under the field and turns the border red. `null` or empty
  /// clears it.
  final String? errorText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final Color fillColor;
  final IconData? prefixIcon;
  final String? prefixText;

  /// Overrides the input text style, e.g. `AppTextStyles.gpNum` for amounts.
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final TextStyle? prefixStyle;

  /// Password field: hides the text and adds a show / hide toggle.
  final bool obscureText;
  final bool autofocus;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;

  /// Optional widget on the right of the label row.
  final Widget? labelTrailing;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured = widget.obscureText;

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: AppRadius.brMd,
    borderSide: BorderSide(color: color, width: 1.5),
  );

  @override
  Widget build(BuildContext context) {
    final error = widget.errorText;
    final hasError = error != null && error.isNotEmpty;
    final message = hasError ? error : widget.helperText;
    final idleBorder = hasError ? AppColors.dangerIcon : AppColors.borderMedium;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.label!,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              ?widget.labelTrailing,
            ],
          ),
          const SizedBox(height: AppSpace.label),
        ],
        TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          enabled: widget.enabled,
          autofocus: widget.autofocus,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          inputFormatters: widget.inputFormatters,
          obscureText: _obscured,
          style: widget.textStyle ?? AppTextStyles.bodyLg,
          cursorColor: AppColors.gpCobalt,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: widget.hintStyle,
            fillColor: widget.enabled
                ? widget.fillColor
                : AppColors.surfaceSubtle,
            prefixIcon: widget.prefixIcon == null
                ? null
                : Icon(widget.prefixIcon, size: AppIconSize.md),
            prefixText: widget.prefixText,
            prefixStyle:
                widget.prefixStyle ??
                AppTextStyles.bodyLg.copyWith(color: AppColors.textTertiary),
            suffixIcon: widget.obscureText
                ? IconButton(
                    tooltip: _obscured ? 'Show password' : 'Hide password',
                    onPressed: () => setState(() => _obscured = !_obscured),
                    icon: AnimatedSwitcher(
                      duration: AppMotion.of(context, AppMotion.fast),
                      child: Icon(
                        _obscured ? AppIcons.eye : AppIcons.eyeSlash,
                        key: ValueKey(_obscured),
                        size: AppIconSize.md,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  )
                : null,
            border: _border(idleBorder),
            enabledBorder: _border(idleBorder),
            focusedBorder: _border(
              hasError ? AppColors.dangerIcon : AppColors.gpCobalt,
            ),
            disabledBorder: _border(AppColors.borderLight),
          ),
        ),
        AnimatedSize(
          duration: AppMotion.of(context, AppMotion.fast),
          curve: AppMotion.enter,
          alignment: Alignment.topLeft,
          child: AnimatedSwitcher(
            duration: AppMotion.of(context, AppMotion.fast),
            child: message == null || message.isEmpty
                ? const SizedBox(width: double.infinity)
                : Padding(
                    key: ValueKey('$hasError$message'),
                    padding: const EdgeInsets.only(top: AppSpace.x1),
                    child: Text(
                      message,
                      style: AppTextStyles.caption.copyWith(
                        color: hasError
                            ? AppColors.dangerText
                            : AppColors.textTertiary,
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

/// Password field: an [AppTextField] with a show / hide toggle.
class AppPasswordField extends StatelessWidget {
  const AppPasswordField({
    required this.controller,
    this.label = 'Password',
    this.errorText,
    this.enabled = true,
    this.fillColor = AppColors.surfaceWhite,
    this.onSubmitted,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String? errorText;
  final bool enabled;
  final Color fillColor;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      controller: controller,
      hintText: '••••••••',
      errorText: errorText,
      enabled: enabled,
      fillColor: fillColor,
      onSubmitted: onSubmitted,
      textInputAction: TextInputAction.done,
      obscureText: true,
    );
  }
}

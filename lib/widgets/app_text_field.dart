import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/app_colors.dart';
import 'package:geepay_pos/utils/utils.dart';

OutlineInputBorder _fieldBorder(Color color) => OutlineInputBorder(
  borderRadius: BorderRadius.circular(kAppCornerRadius),
  borderSide: BorderSide(color: color, width: 1.5),
);

const _labelStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w600,
  color: AppColors.textSecondary,
);

const _inputStyle = TextStyle(fontSize: 15, color: AppColors.textPrimary);

/// Labeled text input matching the Setup/Login mockups: label above,
/// 1.5px bordered radius-xl field, focus ring in gp-cobalt.
class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.label,
    this.controller,
    this.hintText,
    this.keyboardType,
    this.fillColor = AppColors.surfaceWhite,
    this.errorText,
    this.enabled = true,
    this.textInputAction,
    this.onChanged,
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final String? hintText;
  final TextInputType? keyboardType;
  final Color fillColor;
  final String? errorText;
  final bool enabled;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onChanged: onChanged,
          style: _inputStyle,
          decoration: InputDecoration(
            hintText: hintText,
            errorText: errorText,
            filled: true,
            fillColor: fillColor,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: _fieldBorder(AppColors.borderMedium),
            enabledBorder: _fieldBorder(AppColors.borderMedium),
            focusedBorder: _fieldBorder(AppColors.gpCobalt),
            errorBorder: _fieldBorder(AppColors.dangerIcon),
          ),
        ),
      ],
    );
  }
}

/// Password field matching the Login mockup: a "Password" label with an
/// inline Show/Hide text toggle (not an icon), same bordered field style
/// as [AppTextField].
class AppPasswordField extends StatefulWidget {
  const AppPasswordField({
    required this.controller,
    this.errorText,
    this.enabled = true,
    this.fillColor = AppColors.surfaceWhite,
    this.onSubmitted,
    super.key,
  });

  final TextEditingController controller;
  final String? errorText;
  final bool enabled;
  final Color fillColor;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Password', style: _labelStyle),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () => setState(() => _obscure = !_obscure),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  child: Text(
                    _obscure ? 'Show' : 'Hide',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gpCobalt,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscure,
          enabled: widget.enabled,
          onFieldSubmitted: widget.onSubmitted,
          style: _inputStyle,
          decoration: InputDecoration(
            hintText: '••••••••',
            errorText: widget.errorText,
            filled: true,
            fillColor: widget.fillColor,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: _fieldBorder(AppColors.borderMedium),
            enabledBorder: _fieldBorder(AppColors.borderMedium),
            focusedBorder: _fieldBorder(AppColors.gpCobalt),
            errorBorder: _fieldBorder(AppColors.dangerIcon),
          ),
        ),
      ],
    );
  }
}

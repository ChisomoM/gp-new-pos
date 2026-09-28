import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/app_gradients.dart';
import 'package:geepay_pos/utils/utils.dart';

/// Full-width primary CTA button — gradient fill, radius-xl, gradient
/// button shadow. Used by every "complete this step" action (Setup, Login,
/// and future screens per the design spec's component patterns).
class GradientButton extends StatelessWidget {
  const GradientButton({
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(kAppCornerRadius),
          gradient: enabled ? AppGradients.primary : null,
          color: enabled ? null : const Color(0xFFB9BDD6),
          boxShadow: enabled ? AppGradients.gradientButton : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(kAppCornerRadius),
            onTap: enabled ? onPressed : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (icon != null) ...[
                            const SizedBox(width: 8),
                            Icon(icon, size: 17, color: Colors.white),
                          ],
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

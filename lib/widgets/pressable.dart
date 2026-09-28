import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geepay_pos/app/theme/design_system.dart';

/// Haptic feedback a [Pressable] plays on tap.
enum PressHaptic { none, light, selection }

/// The one way to make a decorated surface tappable (plan §2.9).
///
/// Draws the decoration first and the ink on top of it, clipped to the
/// shape, so the ripple is always visible. (`InkWell > Container(color)`
/// paints the ink underneath the colour and shows no feedback.) Adds a
/// subtle press scale and animates colour / border changes.
class Pressable extends StatefulWidget {
  const Pressable({
    required this.child,
    this.onTap,
    this.onLongPress,
    this.borderRadius = AppRadius.brMd,
    this.color,
    this.gradient,
    this.border,
    this.boxShadow,
    this.pressScale = AppMotion.pressScale,
    this.haptic = PressHaptic.none,
    this.splashColor,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final BorderRadius borderRadius;
  final Color? color;
  final Gradient? gradient;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;

  /// Scale while pressed. Use `1` to disable.
  final double pressScale;
  final PressHaptic haptic;
  final Color? splashColor;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _pressed = false;

  void _handleTap() {
    switch (widget.haptic) {
      case PressHaptic.light:
        unawaited(HapticFeedback.lightImpact());
      case PressHaptic.selection:
        unawaited(HapticFeedback.selectionClick());
      case PressHaptic.none:
        break;
    }
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null || widget.onLongPress != null;
    return AnimatedScale(
      scale: _pressed && enabled ? widget.pressScale : 1,
      duration: AppMotion.of(context, AppMotion.instant),
      curve: AppMotion.enter,
      child: AnimatedContainer(
        duration: AppMotion.of(context, AppMotion.fast),
        curve: AppMotion.enter,
        decoration: BoxDecoration(
          color: widget.gradient == null ? widget.color : null,
          gradient: widget.gradient,
          border: widget.border,
          borderRadius: widget.borderRadius,
          boxShadow: widget.boxShadow,
        ),
        child: ClipRRect(
          borderRadius: widget.borderRadius,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: widget.onTap == null ? null : _handleTap,
              onLongPress: widget.onLongPress,
              onHighlightChanged: (value) => setState(() => _pressed = value),
              splashColor: widget.splashColor,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/design_system.dart';

/// Like [IndexedStack], but children are built lazily on first visit and
/// switching cross-fades between them.
///
/// Visited children stay mounted so their state (scroll position, filters)
/// survives switching. Once a child has finished fading out it is taken
/// offstage: no painting, hit testing, semantics or tickers.
class FadeIndexedStack extends StatefulWidget {
  const FadeIndexedStack({
    required this.index,
    required this.itemCount,
    required this.itemBuilder,
    this.background = AppColors.surfacePage,
    super.key,
  });

  final int index;
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;

  /// Painted behind every child so a tab with a transparent body never
  /// shows the tab underneath it.
  final Color background;

  @override
  State<FadeIndexedStack> createState() => _FadeIndexedStackState();
}

class _FadeIndexedStackState extends State<FadeIndexedStack> {
  late final Set<int> _visited = {widget.index};

  @override
  void didUpdateWidget(FadeIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    _visited.add(widget.index);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        for (var i = 0; i < widget.itemCount; i++)
          if (_visited.contains(i))
            _FadeSlot(
              key: ValueKey(i),
              active: i == widget.index,
              child: ColoredBox(
                color: widget.background,
                child: widget.itemBuilder(context, i),
              ),
            )
          else
            const SizedBox.shrink(),
      ],
    );
  }
}

class _FadeSlot extends StatefulWidget {
  const _FadeSlot({required this.active, required this.child, super.key});

  final bool active;
  final Widget child;

  @override
  State<_FadeSlot> createState() => _FadeSlotState();
}

class _FadeSlotState extends State<_FadeSlot> {
  /// True once an inactive slot has finished fading out. Until then its
  /// tickers must keep running, or the fade itself would freeze at full
  /// opacity and leave the old tab painted over the new one.
  late bool _hidden = !widget.active;

  @override
  void didUpdateWidget(_FadeSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active) {
      _hidden = false;
    } else if (oldWidget.active && AppMotion.reduced(context)) {
      // No fade to wait for.
      _hidden = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.active;
    return Offstage(
      offstage: _hidden,
      child: TickerMode(
        enabled: !_hidden,
        child: IgnorePointer(
          ignoring: !active,
          child: ExcludeSemantics(
            excluding: !active,
            child: AnimatedOpacity(
              opacity: active ? 1 : 0,
              duration: AppMotion.of(context, AppMotion.base),
              curve: active ? AppMotion.enter : AppMotion.exit,
              onEnd: () {
                // With reduced motion didUpdateWidget already hid the slot,
                // and this fires during build, so it must not setState.
                if (!widget.active && !_hidden && mounted) {
                  setState(() => _hidden = true);
                }
              },
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

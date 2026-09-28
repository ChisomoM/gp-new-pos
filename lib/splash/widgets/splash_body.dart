import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/design_system.dart';
import 'package:geepay_pos/widgets/app_version.dart';

/// Branded launch screen: the logo mark scales in, the wordmark follows,
/// and a thin progress bar appears only if the session check is slow.
class SplashBody extends StatelessWidget {
  const SplashBody({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppGradients.hero),
      // Fill the screen: Scaffold gives its body loose constraints, and
      // without this the Stack shrinks to the logo column's width.
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          const Positioned(
            top: -120,
            right: -100,
            child: _GlowCircle(size: 320, opacity: 0.28),
          ),
          const Positioned(
            bottom: -100,
            left: -80,
            child: _GlowCircle(size: 260, opacity: 0.16),
          ),
          Positioned(
            bottom: -231,
            right: -169,
            child: Opacity(
              opacity: 0.08,
              child: ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  AppColors.onBrandHigh,
                  BlendMode.srcIn,
                ),
                child: Image.asset(AppLogos.gMark, width: 625, height: 701),
              ),
            ),
          ),
          const _Brand(),
          Positioned(
            bottom: AppSpace.x8,
            child: SafeArea(
              top: false,
              child: DefaultTextStyle(
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.onBrandLow,
                ),
                child: const AppVersion(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Logo mark, wordmark and the delayed progress bar, animated in once.
class _Brand extends StatefulWidget {
  const _Brand();

  @override
  State<_Brand> createState() => _BrandState();
}

class _BrandState extends State<_Brand> with SingleTickerProviderStateMixin {
  /// Show the progress bar only when loading takes longer than this, so a
  /// normal launch never shows a loading state at all.
  static const _progressDelay = Duration(milliseconds: 800);

  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: AppMotion.emphasis + AppMotion.base,
  );
  Timer? _progressTimer;
  bool _showProgress = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_entrance.status == AnimationStatus.dismissed) {
      if (AppMotion.reduced(context)) {
        _entrance.value = 1;
      } else {
        _entrance.forward();
      }
      _progressTimer = Timer(_progressDelay, () {
        if (mounted) setState(() => _showProgress = true);
      });
    }
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The mark scales in first, the wordmark follows a beat later.
    final mark = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0, 0.7, curve: AppMotion.emphasized),
    );
    final word = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.3, 1, curve: AppMotion.enter),
    );
    return Semantics(
      label: 'Geepay',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeTransition(
            opacity: _entrance.drive(CurveTween(curve: const Interval(0, 0.4))),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1).animate(mark),
              child: Image.asset(AppLogos.gMark, width: 56, height: 56),
            ),
          ),
          const SizedBox(height: AppSpace.x4),
          FadeTransition(
            opacity: word,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0, 0.3),
                end: Offset.zero,
              ).animate(word),
              child: Image.asset(AppLogos.wordmarkWhite, width: 170),
            ),
          ),
          const SizedBox(height: AppSpace.x12),
          SizedBox(
            width: 96,
            height: AppSpace.x1,
            child: AnimatedOpacity(
              opacity: _showProgress ? 1 : 0,
              duration: AppMotion.of(context, AppMotion.slow),
              child: _showProgress
                  ? const ClipRRect(
                      borderRadius: AppRadius.brFull,
                      child: LinearProgressIndicator(
                        color: AppColors.onBrandHigh,
                        backgroundColor: AppColors.onBrandStroke,
                        semanticsLabel: 'Loading',
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.gpSky.withValues(alpha: opacity),
            AppColors.gpSky.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}

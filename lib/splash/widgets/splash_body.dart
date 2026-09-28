import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/design_system.dart';
import 'package:geepay_pos/widgets/app_version.dart';

class SplashBody extends StatelessWidget {
  const SplashBody({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppGradients.hero),
      child: Stack(
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
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(AppLogos.gMark, width: 56, height: 56),
              const SizedBox(height: AppSpace.x4),
              Image.asset(AppLogos.wordmarkWhite, width: 170),
              const SizedBox(height: AppSpace.x12),
              const _PulsingDots(),
            ],
          ),
          Positioned(
            bottom: AppSpace.x8,
            child: DefaultTextStyle(
              style: AppTextStyles.caption.copyWith(
                color: AppColors.onBrandLow,
              ),
              child: const AppVersion(),
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

class _PulsingDots extends StatefulWidget {
  const _PulsingDots();

  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.x1),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final t = (_controller.value + i * 0.15) % 1.0;
              final opacity = 0.35 + 0.65 * (0.5 - (t - 0.5).abs()) * 2;
              return Opacity(opacity: opacity.clamp(0.35, 1), child: child);
            },
            child: const _Dot(),
          ),
        );
      }),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSpace.x2,
      height: AppSpace.x2,
      decoration: const BoxDecoration(
        color: AppColors.onBrandHigh,
        shape: BoxShape.circle,
      ),
    );
  }
}

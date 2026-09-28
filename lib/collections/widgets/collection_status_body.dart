import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/design_system.dart';
import 'package:geepay_pos/collections/cubit/cubit.dart';
import 'package:geepay_pos/widgets/widgets.dart';

class CollectionStatusBody extends StatefulWidget {
  const CollectionStatusBody({super.key});

  @override
  State<CollectionStatusBody> createState() => _CollectionStatusBodyState();
}

class _CollectionStatusBodyState extends State<CollectionStatusBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CollectionsCubit, CollectionsState>(
      builder: (context, state) {
        final amount = Money.withCurrency(state.amount ?? 0);
        return Column(
          children: [
            const AppHeader(title: 'Payment request'),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpace.x8),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - AppSpace.x16,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                RotationTransition(
                                  turns: _spin,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.infoFill,
                                        width: 4,
                                      ),
                                    ),
                                    child: CustomPaint(
                                      size: const Size(100, 100),
                                      painter: _ArcPainter(),
                                    ),
                                  ),
                                ),
                                const Icon(
                                  AppIcons.phone,
                                  size: AppIconSize.xl,
                                  color: AppColors.gpCobalt,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpace.x6),
                          Text(
                            'Waiting for confirmation',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.title2,
                          ),
                          const SizedBox(height: AppSpace.x2),
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textTertiary,
                              ),
                              children: [
                                const TextSpan(
                                  text: "We've sent a request to ",
                                ),
                                TextSpan(
                                  text: state.phoneNumber,
                                  style: AppTextStyles.bodyStrong.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const TextSpan(text: ' for '),
                                TextSpan(
                                  text: amount,
                                  style: AppTextStyles.gpNum(
                                    fontSize: AppTextStyles.numSm,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const TextSpan(
                                  text:
                                      '. Ask the customer to approve it on their '
                                      'phone.',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpace.x6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpace.x3,
                              vertical: AppSpace.x2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceWhite,
                              borderRadius: AppRadius.brFull,
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppColors.gpSky,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: AppSpace.x2),
                                Flexible(
                                  child: Text(
                                    'Checking every 10 seconds · up to 5 '
                                    'minutes',
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            DecoratedBox(
              decoration: const BoxDecoration(
                color: AppColors.surfaceWhite,
                border: Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpace.gutter,
                    AppSpace.x3,
                    AppSpace.gutter,
                    AppSpace.x4,
                  ),
                  child: AppButton.secondary(
                    label: 'Cancel request',
                    onPressed: () {
                      context.read<CollectionsCubit>().cancel();
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gpCobalt
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final rect = Rect.fromLTWH(2, 2, size.width - 4, size.height - 4);
    canvas.drawArc(rect, -1.2, 1.6, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

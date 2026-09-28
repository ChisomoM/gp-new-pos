import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geepay_pos/widgets/app_button.dart';

import '../helpers/pump_app.dart';

void main() {
  group('AppButton', () {
    testWidgets('calls onPressed when tapped', (tester) async {
      var taps = 0;
      await tester.pumpApp(AppButton(label: 'Pay', onPressed: () => taps++));
      await tester.tap(find.text('Pay'));
      expect(taps, 1);
    });

    testWidgets('ignores taps and shows a spinner while loading', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpApp(
        AppButton(label: 'Pay', isLoading: true, onPressed: () => taps++),
      );
      await tester.tap(find.byType(AppButton), warnIfMissed: false);
      expect(taps, 0);
      expect(find.byType(CircularProgressIndicator), findsOne);
    });

    testWidgets('keeps its size when switching to loading', (tester) async {
      Future<Size> sizeFor({required bool loading}) async {
        await tester.pumpApp(
          Center(
            child: AppButton(
              label: 'Request payment',
              expand: false,
              isLoading: loading,
              onPressed: () {},
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 300));
        return tester.getSize(find.byType(AppButton));
      }

      final idle = await sizeFor(loading: false);
      final loading = await sizeFor(loading: true);
      expect(loading, idle);
    });

    testWidgets('uses the size tokens for height', (tester) async {
      await tester.pumpApp(
        const Column(
          children: [
            AppButton(label: 'lg'),
            AppButton(label: 'md', size: AppButtonSize.md),
            AppButton(label: 'sm', size: AppButtonSize.sm),
          ],
        ),
      );
      double heightOf(String label) => tester
          .getSize(
            find.ancestor(
              of: find.text(label),
              matching: find.byType(AppButton),
            ),
          )
          .height;
      expect(heightOf('lg'), 52);
      expect(heightOf('md'), 44);
      expect(heightOf('sm'), 36);
    });
  });

  group('AppIconButton', () {
    testWidgets('has a 48px hit area around a 40px button', (tester) async {
      var taps = 0;
      await tester.pumpApp(
        Center(
          child: AppIconButton(
            icon: Icons.share,
            tooltip: 'Share',
            onPressed: () => taps++,
          ),
        ),
      );
      final rect = tester.getRect(find.byType(AppIconButton));
      expect(rect.size, const Size.square(48));
      // Tap in the transparent ring outside the 40px visual button.
      await tester.tapAt(rect.topLeft + const Offset(2, 2));
      expect(taps, 1);
      expect(find.bySemanticsLabel('Share'), findsOne);
    });
  });
}

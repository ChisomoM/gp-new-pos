import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geepay_pos/app/theme/app_colors.dart';
import 'package:geepay_pos/widgets/widgets.dart';

import '../helpers/pump_app.dart';

void main() {
  Widget row(String letter, {VoidCallback? onTap}) => TransactionRow(
    title: '0973042237',
    subtitle: 'Airtel Money · Collection',
    amount: 1250,
    status: 'successful',
    avatarLetter: letter,
    onTap: onTap,
  );

  testWidgets('renders amount, status and title', (tester) async {
    await tester.pumpApp(row('A'));
    expect(find.text('0973042237'), findsOne);
    expect(find.text('ZMW 1,250.00', findRichText: true), findsOne);
    expect(find.text('SUCCESS'), findsOne);
  });

  testWidgets('channel avatars never use status colours', (tester) async {
    final statusColors = {
      AppColors.dangerFill,
      AppColors.dangerFillAlt,
      AppColors.warningFill,
      AppColors.successFill,
    };
    for (final letter in ['A', 'M', 'Z', '?']) {
      await tester.pumpApp(row(letter));
      final avatar = tester.widget<AppAvatar>(find.byType(AppAvatar));
      expect(statusColors, isNot(contains(avatar.background)), reason: letter);
    }
  });

  testWidgets('shows an ink ripple above its background when pressed', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpApp(row('A', onTap: () => taps++));
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(TransactionRow)),
    );
    await tester.pump(const Duration(milliseconds: 100));
    // The ink is painted on a Material that sits inside (above) the row's
    // decorated background, so it is visible.
    final material = find.descendant(
      of: find.byType(Pressable),
      matching: find.byType(Material),
    );
    expect(material, findsOne);
    expect(
      tester.renderObject(material),
      paints..circle(),
    );
    await gesture.up();
    expect(taps, 1);
  });
}

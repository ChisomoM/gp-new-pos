import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geepay_pos/app/theme/app_colors.dart';
import 'package:geepay_pos/widgets/status_badge.dart';

import '../helpers/pump_app.dart';

void main() {
  group('StatusBadge.transaction', () {
    for (final (status, label, tone) in [
      ('successful', 'SUCCESS', BadgeTone.success),
      ('SUCCESS', 'SUCCESS', BadgeTone.success),
      ('failed', 'FAILED', BadgeTone.danger),
      ('failure', 'FAILED', BadgeTone.danger),
      ('pending', 'PENDING', BadgeTone.warning),
      ('processing', 'PENDING', BadgeTone.warning),
    ]) {
      testWidgets('maps "$status" to $label', (tester) async {
        await tester.pumpApp(StatusBadge.transaction(status));
        expect(find.text(label), findsOne);
        final badge = tester.widget<StatusBadge>(find.byType(StatusBadge));
        expect(badge.tone, tone);
      });
    }
  });

  testWidgets('uses semantic fill colours per tone', (tester) async {
    await tester.pumpApp(
      const StatusBadge(label: 'Up to date', tone: BadgeTone.success),
    );
    final container = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(StatusBadge),
            matching: find.byType(Container),
          )
          .first,
    );
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, AppColors.successFill);
  });
}

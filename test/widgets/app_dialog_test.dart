import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geepay_pos/widgets/app_button.dart';
import 'package:geepay_pos/widgets/app_dialog.dart';

import '../helpers/pump_app.dart';

void main() {
  testWidgets('returns true on confirm and false on cancel', (tester) async {
    Object? result;
    await tester.pumpApp(
      Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            result = await showAppDialog(
              context,
              title: 'Log out',
              message: 'Are you sure?',
              yesText: 'Log out',
              noText: 'Cancel',
              destructive: true,
            );
          },
          child: const Text('open'),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Are you sure?'), findsOne);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(result, isFalse);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(AppButton, 'Log out'));
    await tester.pumpAndSettle();
    expect(result, isTrue);
  });
}

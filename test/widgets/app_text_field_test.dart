import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geepay_pos/widgets/app_text_field.dart';

import '../helpers/pump_app.dart';

void main() {
  testWidgets('shows the label and error text', (tester) async {
    await tester.pumpApp(
      const AppTextField(label: 'Email', errorText: 'Enter a valid email'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Email'), findsOne);
    expect(find.text('Enter a valid email'), findsOne);
  });

  testWidgets('password field toggles visibility', (tester) async {
    await tester.pumpApp(
      AppPasswordField(controller: TextEditingController(text: 'secret')),
    );
    bool obscured() =>
        tester.widget<TextField>(find.byType(TextField)).obscureText;

    expect(obscured(), isTrue);
    await tester.tap(find.byTooltip('Show password'));
    await tester.pumpAndSettle();
    expect(obscured(), isFalse);
    await tester.tap(find.byTooltip('Hide password'));
    await tester.pumpAndSettle();
    expect(obscured(), isTrue);
  });
}

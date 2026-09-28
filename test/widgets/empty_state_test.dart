import 'package:flutter_test/flutter_test.dart';
import 'package:geepay_pos/widgets/empty_state.dart';

import '../helpers/pump_app.dart';

void main() {
  testWidgets('ErrorState offers a retry', (tester) async {
    var retries = 0;
    await tester.pumpApp(ErrorState(onRetry: () => retries++));
    await tester.pumpAndSettle();
    expect(find.text("Couldn't load this"), findsOne);
    await tester.tap(find.text('Try again'));
    expect(retries, 1);
  });

  testWidgets('ErrorState hides retry without a callback', (tester) async {
    await tester.pumpApp(const ErrorState(message: 'Offline'));
    await tester.pumpAndSettle();
    expect(find.text('Offline'), findsOne);
    expect(find.text('Try again'), findsNothing);
  });
}

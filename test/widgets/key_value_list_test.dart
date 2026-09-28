import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geepay_pos/widgets/key_value_list.dart';

import '../helpers/pump_app.dart';

void main() {
  testWidgets('copies a copyable value and confirms inline', (tester) async {
    String? clipboard;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          clipboard = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );

    await tester.pumpApp(
      const KeyValueList(
        items: [
          KeyValueItem('Phone number', '0973042237'),
          KeyValueItem('Transaction ID', 'TX-123', copyable: true),
        ],
      ),
    );
    expect(find.text('Phone number'), findsOne);

    await tester.tap(find.text('TX-123'));
    await tester.pump();
    expect(clipboard, 'TX-123');
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Copied'), findsOne);

    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text('Copied'), findsNothing);
    expect(find.text('TX-123'), findsOne);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geepay_pos/widgets/fade_indexed_stack.dart';

import '../helpers/pump_app.dart';

void main() {
  Widget stack(int index) => FadeIndexedStack(
    index: index,
    itemCount: 3,
    itemBuilder: (_, i) => Text('tab $i'),
  );

  testWidgets('builds tabs lazily and keeps visited ones', (tester) async {
    await tester.pumpApp(stack(0));
    expect(find.text('tab 0'), findsOne);
    expect(find.text('tab 1', skipOffstage: false), findsNothing);

    await tester.pumpApp(stack(1));
    await tester.pumpAndSettle();
    expect(find.text('tab 1'), findsOne);
    // Home is kept alive, just offstage.
    expect(find.text('tab 0', skipOffstage: false), findsOne);
  });

  testWidgets('the previous tab is fully hidden after switching', (
    tester,
  ) async {
    // Regression: the outgoing tab's fade used to freeze at full opacity
    // (its tickers were muted immediately), leaving it painted over or
    // under the new tab.
    await tester.pumpApp(stack(0));
    await tester.pumpApp(stack(2));
    await tester.pumpAndSettle();
    expect(find.text('tab 0'), findsNothing); // offstage
    expect(find.text('tab 2'), findsOne);

    await tester.pumpApp(stack(0));
    await tester.pumpAndSettle();
    expect(find.text('tab 2'), findsNothing);
    expect(find.text('tab 0'), findsOne);
  });

  testWidgets('hides the previous tab immediately with reduced motion', (
    tester,
  ) async {
    Widget app(int index) => MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: stack(index),
      ),
    );
    await tester.pumpWidget(app(0));
    await tester.pumpWidget(app(1));
    await tester.pump();
    expect(find.text('tab 0'), findsNothing);
    expect(find.text('tab 1'), findsOne);
  });

  testWidgets('only the active tab receives taps', (tester) async {
    var taps = 0;
    Widget tappable(int index) => FadeIndexedStack(
      index: index,
      itemCount: 2,
      itemBuilder: (_, i) => i == 0
          ? GestureDetector(onTap: () => taps++, child: const Text('home'))
          : const Text('history'),
    );
    await tester.pumpApp(tappable(0));
    await tester.pumpApp(tappable(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('history'));
    expect(taps, 0);
  });
}

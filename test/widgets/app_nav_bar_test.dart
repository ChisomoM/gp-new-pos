import 'package:flutter_test/flutter_test.dart';
import 'package:geepay_pos/app/theme/app_icons.dart';
import 'package:geepay_pos/widgets/app_nav_bar.dart';

import '../helpers/pump_app.dart';

void main() {
  const items = [
    AppNavItem(
      icon: AppIcons.home,
      activeIcon: AppIcons.homeActive,
      label: 'Home',
    ),
    AppNavItem(
      icon: AppIcons.history,
      activeIcon: AppIcons.historyActive,
      label: 'History',
    ),
  ];

  testWidgets('reports taps and marks the active item', (tester) async {
    int? tapped;
    await tester.pumpApp(
      AppNavBar(items: items, currentIndex: 0, onTap: (i) => tapped = i),
    );
    expect(find.byIcon(AppIcons.homeActive), findsOne);
    expect(find.byIcon(AppIcons.history), findsOne);

    await tester.tap(find.text('History'));
    expect(tapped, 1);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Home')),
      matchesSemantics(
        label: 'Home',
        isSelected: true,
        isButton: true,
        hasTapAction: true,
        hasSelectedState: true,
      ),
    );
  });
}

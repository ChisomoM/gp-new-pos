import 'package:flutter_test/flutter_test.dart';
import 'package:geepay_pos/widgets/money_text.dart';

import '../helpers/pump_app.dart';

void main() {
  group('Money', () {
    test('formats with thousands separators and two decimals', () {
      expect(Money.format(12450), '12,450.00');
      expect(Money.format(0), '0.00');
      expect(Money.format(1234567.891), '1,234,567.89');
    });

    test('prefixes the currency code', () {
      expect(Money.withCurrency(20), 'ZMW 20.00');
      expect(Money.withCurrency(5, currency: 'USD'), 'USD 5.00');
    });
  });

  group('MoneyText', () {
    testWidgets('renders the formatted amount', (tester) async {
      await tester.pumpApp(const MoneyText(12450.5));
      expect(find.text('ZMW 12,450.50', findRichText: true), findsOne);
    });
  });
}

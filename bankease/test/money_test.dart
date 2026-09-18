import 'package:flutter_test/flutter_test.dart';

import 'package:bankease/core/utils/money.dart';

void main() {
  group('formatRupees', () {
    test('formats small amounts', () {
      expect(formatRupees(2000), '₹20.00');
      expect(formatRupees(5), '₹0.05');
    });

    test('uses Indian digit grouping', () {
      expect(formatRupees(100000), '₹1,000.00');
      expect(formatRupees(1234567890), '₹1,23,45,678.90');
    });

    test('shows a minus for debits and an optional plus for credits', () {
      expect(formatRupees(-49900), '-₹499.00');
      expect(formatRupees(49900, showSign: true), '+₹499.00');
    });
  });

  group('parseRupeesToPaise', () {
    test('parses whole and decimal rupees', () {
      expect(parseRupeesToPaise('20'), 2000);
      expect(parseRupeesToPaise('49.8'), 4980);
      expect(parseRupeesToPaise('49.85'), 4985);
      expect(parseRupeesToPaise(' 1,000 '), 100000);
    });

    test('rejects invalid input', () {
      expect(parseRupeesToPaise(''), isNull);
      expect(parseRupeesToPaise('abc'), isNull);
      expect(parseRupeesToPaise('1.234'), isNull);
      expect(parseRupeesToPaise('-5'), isNull);
      expect(parseRupeesToPaise('.5'), isNull);
    });
  });
}

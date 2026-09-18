import 'package:flutter_test/flutter_test.dart';

import 'package:bankease/core/utils/validators.dart';

void main() {
  group('Validators.amount', () {
    const balance = 100000; // ₹1,000

    test('requires a value', () {
      expect(Validators.amount('', balancePaise: balance), 'Enter an amount');
      expect(Validators.amount(null, balancePaise: balance), 'Enter an amount');
    });

    test('rejects non-numbers and zero', () {
      expect(
        Validators.amount('abc', balancePaise: balance),
        'Enter a valid amount (up to 2 decimals)',
      );
      expect(
        Validators.amount('0', balancePaise: balance),
        'Amount must be more than ₹0',
      );
    });

    test('enforces balance and per-transfer limit', () {
      expect(
        Validators.amount('2000', balancePaise: balance),
        'Insufficient funds',
      );
      expect(
        Validators.amount('200000', balancePaise: 99999999999),
        startsWith('Maximum per transfer'),
      );
    });

    test('accepts a valid amount', () {
      expect(Validators.amount('500.50', balancePaise: balance), isNull);
    });
  });

  group('Beneficiary validators', () {
    test('IFSC format', () {
      expect(Validators.ifsc('BKEN0001234'), isNull);
      expect(Validators.ifsc('bken0001234'), isNull);
      expect(Validators.ifsc('BKEN1001234'), isNotNull); // 5th char must be 0
      expect(Validators.ifsc('BKE0001234'), isNotNull); // too short
    });

    test('account numbers must match', () {
      expect(Validators.confirmAccountNumber('123456789', '123456789'), isNull);
      expect(
        Validators.confirmAccountNumber('123456780', '123456789'),
        'Account numbers do not match',
      );
    });

    test('name rules', () {
      expect(Validators.beneficiaryName('Ravi Kumar'), isNull);
      expect(Validators.beneficiaryName('Al'), 'Name is too short');
      expect(Validators.beneficiaryName('R@vi'), isNotNull);
    });
  });

  group('Login validators', () {
    test('customer ID and PIN', () {
      expect(Validators.customerId('10012345'), isNull);
      expect(Validators.customerId('123'), 'Customer ID must be 8 digits');
      expect(Validators.pin('1234'), isNull);
      expect(Validators.pin('12a4'), 'PIN must be 4 digits');
    });
  });
}

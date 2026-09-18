import 'package:bankease/features/accounts/domain/account.dart';
import 'package:bankease/features/transactions/domain/txn.dart';
import 'package:bankease/features/transfer/domain/beneficiary.dart';

/// Hard-coded data for Module 2.
/// Module 4 replaces this with a repository that calls the bank API.
abstract final class MockData {
  static const customerName = 'Asha Rao';
  static const customerId = '10012345';

  static String get firstName => customerName.split(' ').first;

  static const List<Account> accounts = [
    Account(
      id: 'BE1001',
      type: AccountType.savings,
      holderName: customerName,
      number: '501000123451001',
      ifsc: 'BKEN0001234',
      branch: 'Bijapur Main',
      balancePaise: 498050, // ₹4,980.50
    ),
    Account(
      id: 'BE2001',
      type: AccountType.current,
      holderName: customerName,
      number: '502000987652001',
      ifsc: 'BKEN0001234',
      branch: 'Bijapur Main',
      balancePaise: 12500000, // ₹1,25,000.00
    ),
  ];

  static Account? accountById(String id) {
    for (final account in accounts) {
      if (account.id == id) return account;
    }
    return null;
  }

  static const List<Beneficiary> beneficiaries = [
    Beneficiary(
      id: 'B1',
      name: 'Ravi Kumar',
      accountNumber: '123456789012',
      ifsc: 'NOVA0004567',
    ),
    Beneficiary(
      id: 'B2',
      name: 'Meera Traders',
      accountNumber: '987654321098',
      ifsc: 'TRUB0001122',
    ),
    Beneficiary(
      id: 'B3',
      name: 'Suresh Patil',
      accountNumber: '456789123456',
      ifsc: 'BKEN0003344',
    ),
  ];

  /// 500 generated transactions so the statement proves ListView.builder works.
  static final List<Txn> transactions = _generateTransactions();

  static List<Txn> transactionsFor(String accountId) =>
      transactions.where((t) => t.accountId == accountId).toList();

  static List<Txn> _generateTransactions() {
    const titles = [
      'Chai stall',
      'Salary credit',
      'Electricity bill',
      'Food delivery order',
      'Mobile recharge',
      'ATM withdrawal',
      'Interest credit',
      'Online shopping - Venkata Satya Narayana Enterprises',
    ];
    const amounts = [-2000, 6500000, -184500, -45600, -29900, -500000, 23400, -129900];
    final start = DateTime(2026, 9, 15, 18, 30);

    return List.generate(500, (i) {
      final k = i % titles.length;
      return Txn(
        id: 'T${10000 + i}',
        accountId: i % 3 == 0 ? 'BE2001' : 'BE1001',
        title: titles[k],
        amountPaise: amounts[k],
        date: start.subtract(Duration(hours: i * 7)),
        mode: amounts[k] < 0 ? 'UPI' : 'NEFT',
      );
    });
  }
}

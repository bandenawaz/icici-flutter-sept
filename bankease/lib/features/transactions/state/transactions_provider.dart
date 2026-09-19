import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bankease/core/data/mock_data.dart';
import 'package:bankease/features/transactions/domain/txn.dart';

/// App state: every transaction, newest first

class TransactionsNotifier extends Notifier<List<Txn>> {
  @override
  List<Txn> build() => MockData.transactions;

  void add(Txn txn) => state = [txn, ...state]; // new list, new item on top
}

final transactionsProvider =
    NotifierProvider<TransactionsNotifier, List<Txn>>(TransactionsNotifier.new);

final accountTransactionsProvider =
    Provider.family<List<Txn>, String>((ref, accountId) {
  return ref
      .watch(transactionsProvider)
      .where((t) => t.accountId == accountId)
      .toList();
});

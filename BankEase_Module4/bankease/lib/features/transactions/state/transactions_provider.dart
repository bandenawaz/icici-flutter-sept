import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bankease/features/transactions/data/transactions_repository.dart';
import 'package:bankease/features/transactions/domain/txn.dart';

/// One request per account. Riverpod caches the result per ID and
/// reloads it when we invalidate the provider after a transfer.
final accountTransactionsProvider =
    FutureProvider.family<List<Txn>, String>((ref, accountId) {
  return ref.watch(transactionsRepositoryProvider).fetchPage(accountId);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bankease/features/accounts/domain/account.dart';
import 'package:bankease/core/data/mock_data.dart';

/// App state: the cusomer's acounts and their balance
class AccountsNotifier extends Notifier<List<Account>> {
  @override
  List<Account> build() =>
      MockData.accounts; // This will be changed and will be loaded from API

  //Takes money out of one account
  /// Return false if the account is unknown or doesn't have enough money
  bool debit(String accountId, int amountPaise) {
    final index = state.indexWhere((acc) => acc.id == accountId);

    if (index == -1) return false;

    final account = state[index];
    if (amountPaise <= 0 || amountPaise > account.balancePaise) return false;

    //Never change the old list. Build a nw one with a new Account inside
    state = [
      for (final acc in state)
        if (acc.id == accountId)
          acc.copyWith(balancePaise: acc.balancePaise - amountPaise)
        else
          acc,
    ];
    return true;
  }
}

final accountProvider =
    NotifierProvider<AccountsNotifier, List<Account>>(AccountsNotifier.new);

/// Derived state: one account, looked up by ID
/// It recalculate automatically whenever accountsProvider changes
final accountByIdProvider = Provider.family<Account?, String>((ref, id) {
  for (final account in ref.watch(accountProvider)) {
    if (account.id == id) return account;
  }
  return null;
});

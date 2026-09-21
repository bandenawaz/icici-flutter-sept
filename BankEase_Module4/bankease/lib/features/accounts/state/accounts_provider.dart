import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bankease/features/accounts/data/accounts_repository.dart';
import 'package:bankease/features/accounts/domain/account.dart';

/// App state, now loaded from the API.
/// AsyncNotifier gives every screen loading, data and error states for free.
class AccountsNotifier extends AsyncNotifier<List<Account>> {
  @override
  Future<List<Account>> build() =>
      ref.watch(accountsRepositoryProvider).fetchAccounts();

  /// Pull to refresh. AsyncValue.guard catches errors into the state
  /// instead of throwing, so the UI can show an error view.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(accountsRepositoryProvider).fetchAccounts(),
    );
  }
}

final accountsProvider =
    AsyncNotifierProvider<AccountsNotifier, List<Account>>(AccountsNotifier.new);

/// Derived: one account by ID, or null while loading / if it doesn't exist.
final accountByIdProvider = Provider.family<Account?, String>((ref, id) {
  final accounts = ref.watch(accountsProvider).valueOrNull ?? const [];
  for (final account in accounts) {
    if (account.id == id) return account;
  }
  return null;
});

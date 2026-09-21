import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bankease/core/widgets/async_error_view.dart';
import 'package:bankease/core/widgets/route_error_screen.dart';
import 'package:bankease/features/accounts/state/accounts_provider.dart';
import 'package:bankease/features/transactions/state/transactions_provider.dart';
import 'package:bankease/features/transactions/widgets/transaction_tile.dart';

class StatementScreen extends ConsumerWidget {
  const StatementScreen({super.key, required this.accountId});

  final String accountId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(accountByIdProvider(accountId));
    if (account == null) {
      return RouteErrorScreen(message: 'Account $accountId was not found.');
    }
    final txns = ref.watch(accountTransactionsProvider(accountId));

    return Scaffold(
      appBar: AppBar(title: Text('Statement · ${account.maskedNumber}')),
      body: txns.when(
        loading: () => const LoadingView(),
        error: (error, _) => AsyncErrorView(
          error: error,
          onRetry: () => ref.invalidate(accountTransactionsProvider(accountId)),
        ),
        data: (items) => RefreshIndicator(
          onRefresh: () async =>
              ref.invalidate(accountTransactionsProvider(accountId)),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  children: [
                    Expanded(child: Text('${items.length} transactions')),
                    Text('Latest first',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (context, i) => const Divider(height: 1),
                  itemBuilder: (context, i) => TransactionTile(txn: items[i]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

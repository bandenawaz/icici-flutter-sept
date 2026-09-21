import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bankease/app/routes.dart';
import 'package:bankease/core/widgets/async_error_view.dart';
import 'package:bankease/core/widgets/section_header.dart';
import 'package:bankease/features/accounts/state/accounts_provider.dart';
import 'package:bankease/features/dashboard/widgets/balance_card.dart';
import 'package:bankease/features/dashboard/widgets/quick_actions.dart';
import 'package:bankease/features/transactions/state/transactions_provider.dart';
import 'package:bankease/features/transactions/widgets/transaction_tile.dart';

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountsProvider);

    // when() forces us to design all three states, not just the happy one.
    return accounts.when(
      loading: () => const LoadingView(),
      error: (error, _) => AsyncErrorView(
        error: error,
        onRetry: () => ref.read(accountsProvider.notifier).refresh(),
      ),
      data: (list) {
        if (list.isEmpty) return const Center(child: Text('No accounts yet'));
        final primary = list.first;
        final recent = ref.watch(accountTransactionsProvider(primary.id));

        return RefreshIndicator(
          onRefresh: () async {
            await ref.read(accountsProvider.notifier).refresh();
            ref.invalidate(accountTransactionsProvider(primary.id));
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              BalanceCard(
                account: primary,
                onTap: () => context.push(AppRoutes.account(primary.id)),
              ),
              const SizedBox(height: 24),
              const SectionHeader(title: 'Quick actions'),
              const SizedBox(height: 8),
              const QuickActions(),
              const SizedBox(height: 16),
              SectionHeader(
                title: 'Recent transactions',
                actionLabel: 'View all',
                onAction: () => context.push(AppRoutes.statement(primary.id)),
              ),
              recent.when(
                loading: () => const LoadingView(),
                error: (error, _) => AsyncErrorView(
                  error: error,
                  onRetry: () =>
                      ref.invalidate(accountTransactionsProvider(primary.id)),
                ),
                data: (txns) => Card(
                  child: Column(
                    children: [
                      for (final txn in txns.take(5)) TransactionTile(txn: txn),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

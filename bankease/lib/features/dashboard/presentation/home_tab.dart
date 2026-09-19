import 'package:bankease/features/accounts/state/account_provider.dart';
import 'package:bankease/features/transactions/state/transactions_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bankease/app/routes.dart';
import 'package:bankease/core/data/mock_data.dart';
import 'package:bankease/core/widgets/section_header.dart';
import 'package:bankease/features/dashboard/widgets/balance_card.dart';
import 'package:bankease/features/dashboard/widgets/quick_actions.dart';
import 'package:bankease/features/transactions/widgets/transaction_tile.dart';

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //watch: "rebuild me when its state changes"
    final primary = ref.watch(accountProvider).first;
    final recent =
        ref.watch(accountTransactionsProvider(primary.id)).take(5).toList();

    // The whole page is one ListView, so nothing inside needs its own scroll.
    return ListView(
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
        Card(
          child: Column(
            children: [
              for (final txn in recent) TransactionTile(txn: txn),
            ],
          ),
        ),
      ],
    );
  }
}

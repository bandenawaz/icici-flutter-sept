import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bankease/app/routes.dart';
import 'package:bankease/core/widgets/info_row.dart';
import 'package:bankease/core/widgets/route_error_screen.dart';
import 'package:bankease/features/accounts/state/accounts_provider.dart';
import 'package:bankease/features/dashboard/widgets/balance_card.dart';

/// Receives only an ID from the URL and looks the account up itself.
class AccountDetailScreen extends ConsumerWidget {
  const AccountDetailScreen({super.key, required this.accountId});

  final String accountId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(accountByIdProvider(accountId));
    if (account == null) {
      return RouteErrorScreen(message: 'Account $accountId was not found.');
    }

    return Scaffold(
      appBar: AppBar(title: Text('${account.type.label} account')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          BalanceCard(account: account),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  InfoRow(label: 'Account holder', value: account.holderName),
                  InfoRow(label: 'Account number', value: account.maskedNumber),
                  InfoRow(label: 'IFSC', value: account.ifsc),
                  InfoRow(label: 'Branch', value: account.branch),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      context.push(AppRoutes.statement(account.id)),
                  icon: const Icon(Icons.receipt_long),
                  label: const Text('Statement'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => context
                      .push(AppRoutes.transfer(fromAccountId: account.id)),
                  icon: const Icon(Icons.send),
                  label: const Text('Transfer'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:bankease/features/accounts/state/account_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bankease/app/routes.dart';
import 'package:bankease/core/utils/date_format.dart';
import 'package:bankease/core/utils/money.dart';
import 'package:bankease/core/widgets/info_row.dart';
import 'package:bankease/features/transfer/domain/transfer_draft.dart';

class TransferSuccessScreen extends ConsumerWidget {
  const TransferSuccessScreen({super.key, required this.receipt});

  final TransferReceipt receipt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final d = receipt.draft;

    //The balance AFTER the transfer, read from shared state
    final balanceNow = ref.watch(accountByIdProvider(d.from.id))?.balancePaise;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Transfer complete')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.check_circle, size: 88, color: Colors.green.shade600),
              const SizedBox(height: 16),
              Text(
                formatRupees(d.amountPaise),
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text('sent to ${d.to.name}', textAlign: TextAlign.center),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      InfoRow(label: 'Reference', value: receipt.referenceId),
                      InfoRow(
                        label: 'Date',
                        value: formatDateTime(receipt.completedAt),
                      ),
                      InfoRow(label: 'From', value: d.from.maskedNumber),
                      if (balanceNow != null)
                        InfoRow(
                            label: "Balance now",
                            value: formatRupees(balanceNow)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Demo only: balances update once we add state management in Module 3.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go(AppRoutes.dashboard),
                child: const Text('Back to dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

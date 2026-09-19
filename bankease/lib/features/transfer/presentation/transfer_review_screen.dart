import 'package:bankease/features/accounts/state/account_provider.dart';
import 'package:bankease/features/transactions/domain/txn.dart';
import 'package:bankease/features/transactions/state/transactions_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bankease/app/routes.dart';
import 'package:bankease/core/utils/money.dart';
import 'package:bankease/core/widgets/info_row.dart';
import 'package:bankease/features/transfer/domain/transfer_draft.dart';

class TransferReviewScreen extends ConsumerStatefulWidget {
  const TransferReviewScreen({super.key, required this.draft});

  final TransferDraft draft;

  @override
  ConsumerState<TransferReviewScreen> createState() =>
      _TransferReviewScreenState();
}

class _TransferReviewScreenState extends ConsumerState<TransferReviewScreen> {
  bool _processing = false;

  Future<void> _confirm() async {
    setState(() => _processing = true);
    await Future<void>.delayed(const Duration(seconds: 1)); // fake bank call
    if (!mounted) return;

    final d = widget.draft;

    //1. Change app state: take the money out
    final ok =
        ref.read(accountProvider.notifier).debit(d.from.id, d.amountPaise);
    if (!ok) {
      setState(() => _processing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insufficent funds')),
      );
      return;
    }

    //2. Record the transaction in the statement
    final now = DateTime.now();
    final receipt = TransferReceipt(
      draft: d,
      referenceId: 'BE${now.millisecondsSinceEpoch}',
      completedAt: now,
    );
    ref.read(transactionsProvider.notifier).add(
          Txn(
              id: receipt.referenceId,
              accountId: d.from.id,
              title: 'To ${d.to.name}',
              amountPaise: -d.amountPaise,
              date: now,
              mode: "IMPS"),
        );
    // 3. navigate: replaces Transfer + Review, so Back can't re-submit the payment.
    context.go(AppRoutes.transferSuccess, extra: receipt);
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.draft;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Review transfer')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          Center(
            child: Text(
              formatRupees(d.amountPaise),
              style: theme.textTheme.headlineLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 4),
          Center(child: Text('to ${d.to.name}')),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  InfoRow(
                    label: 'From',
                    value: '${d.from.type.label} ${d.from.maskedNumber}',
                  ),
                  InfoRow(label: 'To', value: d.to.name),
                  InfoRow(label: 'Account', value: d.to.maskedNumber),
                  InfoRow(label: 'IFSC', value: d.to.ifsc),
                  InfoRow(
                    label: 'Remarks',
                    value: d.remarks.isEmpty ? '—' : d.remarks,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Please check the details. Transfers can't be reversed once confirmed.",
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _processing ? null : _confirm,
            child: _processing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Confirm and pay'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _processing ? null : () => context.pop(),
            child: const Text('Edit details'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bankease/app/routes.dart';
import 'package:bankease/core/utils/money.dart';
import 'package:bankease/core/widgets/info_row.dart';
import 'package:bankease/core/errors/bank_error.dart';
import 'package:bankease/features/accounts/state/accounts_provider.dart';
import 'package:bankease/features/transactions/state/transactions_provider.dart';
import 'package:bankease/features/transfer/data/transfer_repository.dart';
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

  /// Created once for this screen. A retry after a timeout reuses the same
  /// key, so the bank can never process the payment twice.
  final String _idempotencyKey = TransferRepository.newIdempotencyKey();

  Future<void> _confirm() async {
    setState(() => _processing = true);
    try {
      final receipt = await ref.read(transferRepositoryProvider).transfer(
            draft: widget.draft,
            idempotencyKey: _idempotencyKey,
          );

      // The server is the source of truth, so reload what it owns.
      ref.invalidate(accountsProvider);
      ref.invalidate(accountTransactionsProvider(widget.draft.from.id));

      if (!mounted) return;
      context.go(AppRoutes.transferSuccess, extra: receipt);
    } on BankError catch (error) {
      if (!mounted) return;
      setState(() => _processing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    }
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

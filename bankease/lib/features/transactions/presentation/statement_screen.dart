import 'package:flutter/material.dart';

import 'package:bankease/core/data/mock_data.dart';
import 'package:bankease/core/widgets/route_error_screen.dart';
import 'package:bankease/features/transactions/widgets/transaction_tile.dart';

class StatementScreen extends StatelessWidget {
  const StatementScreen({super.key, required this.accountId});

  final String accountId;

  @override
  Widget build(BuildContext context) {
    final account = MockData.accountById(accountId);
    if (account == null) {
      return RouteErrorScreen(message: 'Account $accountId was not found.');
    }
    final txns = MockData.transactionsFor(accountId);

    return Scaffold(
      appBar: AppBar(title: Text('Statement · ${account.maskedNumber}')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Expanded(child: Text('${txns.length} transactions')),
                Text(
                  'Latest first',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          // A ListView inside a Column MUST be wrapped in Expanded,
          // otherwise: "Vertical viewport was given unbounded height".
          Expanded(
            // .separated is .builder plus dividers: only visible rows are built.
            child: ListView.separated(
              itemCount: txns.length,
              separatorBuilder: (context, i) => const Divider(height: 1),
              itemBuilder: (context, i) => TransactionTile(txn: txns[i]),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:bankease/core/utils/date_format.dart';
import 'package:bankease/core/utils/money.dart';
import 'package:bankease/features/transactions/domain/txn.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({super.key, required this.txn});

  final Txn txn;

  @override
  Widget build(BuildContext context) {
    final color = txn.isDebit ? Colors.red.shade700 : Colors.green.shade700;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withAlpha(30),
        child: Icon(
          txn.isDebit ? Icons.north_east : Icons.south_west,
          color: color,
        ),
      ),
      // ellipsis: long merchant names end in "..." instead of overflowing
      title: Text(txn.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text('${formatDateTime(txn.date)} · ${txn.mode}'),
      trailing: Text(
        formatRupees(txn.amountPaise, showSign: true),
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

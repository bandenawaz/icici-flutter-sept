import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:bankease/app/routes.dart';
import 'package:bankease/core/data/mock_data.dart';
import 'package:bankease/core/utils/money.dart';
import 'package:bankease/features/accounts/domain/account.dart';

class AccountsTab extends StatelessWidget {
  const AccountsTab({super.key});

  @override
  Widget build(BuildContext context) {
    const accounts = MockData.accounts;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: accounts.length,
      itemBuilder: (context, i) {
        final account = accounts[i];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              child: Icon(
                account.type == AccountType.savings
                    ? Icons.savings_outlined
                    : Icons.business_center_outlined,
              ),
            ),
            title: Text('${account.type.label} account'),
            subtitle: Text(account.maskedNumber),
            trailing: Text(
              formatRupees(account.balancePaise),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            // push: the user should be able to come back to this list.
            onTap: () => context.push(AppRoutes.account(account.id)),
          ),
        );
      },
    );
  }
}

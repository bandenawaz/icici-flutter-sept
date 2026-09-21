import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bankease/app/routes.dart';
import 'package:bankease/core/utils/money.dart';
import 'package:bankease/core/widgets/async_error_view.dart';
import 'package:bankease/features/accounts/domain/account.dart';
import 'package:bankease/features/accounts/state/accounts_provider.dart';

class AccountsTab extends ConsumerWidget {
  const AccountsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountsProvider);

    return accounts.when(
      loading: () => const LoadingView(),
      error: (error, _) => AsyncErrorView(
        error: error,
        onRetry: () => ref.read(accountsProvider.notifier).refresh(),
      ),
      data: (list) => RefreshIndicator(
        onRefresh: () => ref.read(accountsProvider.notifier).refresh(),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (context, i) {
            final account = list[i];
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
                onTap: () => context.push(AppRoutes.account(account.id)),
              ),
            );
          },
        ),
      ),
    );
  }
}

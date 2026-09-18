import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:bankease/app/routes.dart';
import 'package:bankease/core/data/mock_data.dart';
import 'package:bankease/features/transfer/domain/beneficiary.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(
        Icons.send,
        'Transfer',
        () => context.push(AppRoutes.transfer()),
      ),
      _QuickAction(
        Icons.receipt_long,
        'Statement',
        () => context.push(AppRoutes.statement(MockData.accounts.first.id)),
      ),
      _QuickAction(Icons.person_add_alt, 'Add payee', () => _addPayee(context)),
      _QuickAction(Icons.lightbulb_outline, 'Pay bills', () => _comingSoon(context)),
    ];

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true, // size to its content inside the page ListView
      physics: const NeverScrollableScrollPhysics(), // the page scrolls, not the grid
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 0.8,
      children: [
        for (final action in actions) _QuickActionTile(action: action),
      ],
    );
  }

  Future<void> _addPayee(BuildContext context) async {
    final added = await context.push<Beneficiary>(AppRoutes.addBeneficiary);
    if (added == null || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${added.name} saved. It will show in Transfer once we add '
          'shared state in Module 3.',
        ),
      ),
    );
  }

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bill payments arrive in a later module')),
    );
  }
}

class _QuickAction {
  const _QuickAction(this.icon, this.label, this.onTap);

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.action});

  final _QuickAction action;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: action.onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: scheme.primaryContainer,
            child: Icon(action.icon, color: scheme.onPrimaryContainer),
          ),
          const SizedBox(height: 6),
          Text(
            action.label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}

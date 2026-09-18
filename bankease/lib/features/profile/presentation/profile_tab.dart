import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:bankease/app/routes.dart';
import 'package:bankease/core/data/mock_data.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need your PIN to log in again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    // go: clears the dashboard from the stack so Back can't reveal it.
    if (confirmed == true && context.mounted) context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final initials = MockData.customerName
        .split(' ')
        .map((part) => part[0])
        .take(2)
        .join();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 8),
        Center(
          child: CircleAvatar(
            radius: 40,
            child: Text(initials, style: const TextStyle(fontSize: 28)),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            MockData.customerName,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: 24),
        const Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.badge_outlined),
                title: Text('Customer ID'),
                subtitle: Text(MockData.customerId),
              ),
              Divider(height: 1),
              ListTile(
                leading: Icon(Icons.location_on_outlined),
                title: Text('Home branch'),
                subtitle: Text('Bijapur Main'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        FilledButton.tonalIcon(
          onPressed: () => _confirmLogout(context),
          icon: const Icon(Icons.logout),
          label: const Text('Log out'),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bankease/features/auth/state/session_provider.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
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
    // The router's redirect sends the user to /login.
    if (confirmed == true) await ref.read(sessionProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final name = session?.customerName ?? '';
    final initials =
        name.split(' ').map((part) => part[0]).take(2).join();

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
            name,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: 24),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.badge_outlined),
                title: const Text('Customer ID'),
                subtitle: Text(session?.customerId ?? '-'),
              ),
              const Divider(height: 1),
              const ListTile(
                leading: Icon(Icons.location_on_outlined),
                title: Text('Home branch'),
                subtitle: Text('Bijapur Main'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        FilledButton.tonalIcon(
          onPressed: () => _confirmLogout(context, ref),
          icon: const Icon(Icons.logout),
          label: const Text('Log out'),
        ),
      ],
    );
  }
}

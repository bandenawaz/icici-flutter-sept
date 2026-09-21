import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bankease/core/utils/date_format.dart';
import 'package:bankease/features/auth/state/session_provider.dart';
import 'package:bankease/features/accounts/presentation/accounts_tab.dart';
import 'package:bankease/features/dashboard/presentation/home_tab.dart';
import 'package:bankease/features/payments/presentation/payments_tab.dart';
import 'package:bankease/features/profile/presentation/profile_tab.dart';

/// Shell with four tabs. The selected tab is local (ephemeral) state.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _index = 0;

  static const _titles = ['Home', 'Accounts', 'Payments', 'Profile'];

  @override
  Widget build(BuildContext context) {
    final firstName = ref.watch(sessionProvider)?.firstName ?? '';
    final title = _index == 0
        ? 'Good ${greetingFor(DateTime.now())}, $firstName'
        : _titles[_index];

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      // IndexedStack keeps every tab alive, so scroll positions are kept.
      body: IndexedStack(
        index: _index,
        children: const [
          HomeTab(),
          AccountsTab(),
          PaymentsTab(),
          ProfileTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Accounts',
          ),
          NavigationDestination(
            icon: Icon(Icons.swap_horiz_outlined),
            selectedIcon: Icon(Icons.swap_horiz),
            label: 'Payments',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

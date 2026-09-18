import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:bankease/app/routes.dart';

class PaymentsTab extends StatelessWidget {
  const PaymentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.send),
                title: const Text('Transfer money'),
                subtitle: const Text('To saved beneficiaries'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRoutes.transfer()),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.person_add_alt),
                title: const Text('Add beneficiary'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRoutes.addBeneficiary),
              ),
              const Divider(height: 1),
              const ListTile(
                enabled: false,
                leading: Icon(Icons.lightbulb_outline),
                title: Text('Pay bills'),
                subtitle: Text('Coming in a later module'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

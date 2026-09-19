import 'package:bankease/features/accounts/state/account_provider.dart';
import 'package:bankease/features/transfer/state/beneficiaries_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bankease/app/routes.dart';
import 'package:bankease/core/data/mock_data.dart';
import 'package:bankease/core/utils/money.dart';
import 'package:bankease/core/utils/validators.dart';
import 'package:bankease/features/accounts/domain/account.dart';
import 'package:bankease/features/transfer/domain/beneficiary.dart';
import 'package:bankease/features/transfer/domain/transfer_draft.dart';

class TransferScreen extends ConsumerStatefulWidget {
  const TransferScreen({super.key, this.fromAccountId});

  /// Comes from the query string: /dashboard/transfer?from=BE2001
  final String? fromAccountId;

  @override
  ConsumerState<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _remarksController = TextEditingController();

  // A local copy: beneficiaries added here are visible only on this screen
  // until Module 3 introduces shared state.
  //final List<Beneficiary> _beneficiaries = [...MockData.beneficiaries];

  late String _fromId;
  Beneficiary? _selected;
  bool _showPayeeError = false;

  @override
  void initState() {
    super.initState();
    final requested = widget.fromAccountId;
    _fromId =
        requested != null && ref.read(accountByIdProvider(requested)) != null
            ? requested
            : ref.read(accountProvider).first.id;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  //Account get _from => ref.read(accountByIdProvider(_fromId))!;

  Future<void> _addBeneficiary() async {
    // push<T> returns whatever the next screen passes to context.pop(result).
    final added = await context.push<Beneficiary>(AppRoutes.addBeneficiary);
    if (!mounted || added == null) return; // null = user pressed Back
    setState(() {
      _selected = added;
      _showPayeeError = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${added.name} added and selected')),
    );
  }

  void _review() {
    final formValid = _formKey.currentState!.validate();
    setState(() => _showPayeeError = _selected == null);
    if (!formValid || _selected == null) return;

    final draft = TransferDraft(
      from: ref.read(accountByIdProvider(_fromId))!, //read: event handler
      to: _selected!,
      amountPaise: parseRupeesToPaise(_amountController.text)!,
      remarks: _remarksController.text.trim(),
    );
    // push: the user can come back and edit.
    context.push(AppRoutes.transferReview, extra: draft);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    //watch: rebuild this screen when these changes
    final beneficiaries = ref.watch(beneficiariesProvider);
    final Account from = ref.watch(accountByIdProvider(_fromId))!;

    return Scaffold(
      appBar: AppBar(title: const Text('Transfer money')),
      body: Form(
        key: _formKey,
        // SingleChildScrollView + Column (not ListView) keeps every field
        // alive, so validate() checks all of them even when scrolled away.
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('From account', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: [
                  for (final account in ref.watch(accountProvider))
                    ButtonSegment(
                      value: account.id,
                      label: Text(account.type.label),
                    ),
                ],
                selected: {_fromId},
                onSelectionChanged: (selection) =>
                    setState(() => _fromId = selection.first),
              ),
              const SizedBox(height: 6),
              Text(
                '${from.maskedNumber} · Available ${formatRupees(from.balancePaise)}',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 20),
              Text('Pay to', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              Card(
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (final b in beneficiaries)
                      ListTile(
                        leading: CircleAvatar(child: Text(b.initials)),
                        title: Text(
                          b.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text('${b.maskedNumber} · ${b.ifsc}'),
                        selected: _selected?.id == b.id,
                        trailing: _selected?.id == b.id
                            ? Icon(Icons.check_circle, color: scheme.primary)
                            : const Icon(Icons.radio_button_unchecked),
                        onTap: () => setState(() {
                          _selected = b;
                          _showPayeeError = false;
                        }),
                      ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.person_add_alt),
                      title: const Text('Add new beneficiary'),
                      onTap: _addBeneficiary,
                    ),
                  ],
                ),
              ),
              if (_showPayeeError)
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 6),
                  child: Text(
                    'Select who to pay',
                    style: TextStyle(color: scheme.error, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '₹ ',
                  helperText: 'Up to ₹1,00,000 per transfer',
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) =>
                    Validators.amount(value, balancePaise: from.balancePaise),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _remarksController,
                decoration: const InputDecoration(
                  labelText: 'Remarks (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLength: 30,
                validator: Validators.remarks,
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _review,
                child: const Text('Review transfer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

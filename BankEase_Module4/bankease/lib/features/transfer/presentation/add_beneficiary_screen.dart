import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bankease/core/errors/bank_error.dart';
import 'package:bankease/core/utils/validators.dart';
import 'package:bankease/features/transfer/domain/beneficiary.dart';
import 'package:bankease/features/transfer/state/beneficiaries_provider.dart';

class AddBeneficiaryScreen extends ConsumerStatefulWidget {
  const AddBeneficiaryScreen({super.key});

  @override
  ConsumerState<AddBeneficiaryScreen> createState() =>
      _AddBeneficiaryScreenState();
}

class _AddBeneficiaryScreenState extends ConsumerState<AddBeneficiaryScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  final _nameController = TextEditingController();
  final _accountController = TextEditingController();
  final _confirmController = TextEditingController();
  final _ifscController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _accountController.dispose();
    _confirmController.dispose();
    _ifscController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      // The server saves it and returns the payee with its real id.
      final saved = await ref.read(beneficiariesProvider.notifier).add(
            name: _nameController.text.trim(),
            accountNumber: _accountController.text.trim(),
            ifsc: _ifscController.text.trim().toUpperCase(),
          );
      if (!mounted) return;
      context.pop(saved); // send it back so the caller can select it
    } on BankError catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add beneficiary')),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Beneficiary name',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: Validators.beneficiaryName,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _accountController,
                decoration: const InputDecoration(
                  labelText: 'Account number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 18,
                textInputAction: TextInputAction.next,
                validator: Validators.accountNumber,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _confirmController,
                decoration: const InputDecoration(
                  labelText: 'Re-enter account number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 18,
                textInputAction: TextInputAction.next,
                // Reads the first field through its controller.
                validator: (value) => Validators.confirmAccountNumber(
                  value,
                  _accountController.text,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _ifscController,
                decoration: const InputDecoration(
                  labelText: 'IFSC code',
                  helperText: 'Example: BKEN0001234',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                ],
                maxLength: 11,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _saving ? null : _save(),
                validator: Validators.ifsc,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save beneficiary'),
              ),
              const SizedBox(height: 12),
              Text(
                'In a real bank, a new beneficiary is confirmed with an OTP and '
                'may have a lower limit for the first 24 hours.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

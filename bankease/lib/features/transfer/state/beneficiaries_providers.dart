import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bankease/core/data/mock_data.dart';
import 'package:bankease/features/transfer/domain/beneficiary.dart';

/// APp state: saved payees, shared by the dashboard and the transfer screen.
class BeneficiariesNotifier extends Notifier<List<Beneficiary>> {
  @override
  List<Beneficiary> build() => MockData.beneficiaries;

  ///Returns false if this account number is already saved.
  bool add(Beneficiary beneficiary) {
    final exists =
        state.any((b) => b.accountNumber == beneficiary.accountNumber);

    if (exists) return false;

    state = [...state, beneficiary];
    return true;
  }
}

final beneficiariesProvider =
    NotifierProvider<BeneficiariesNotifier, List<Beneficiary>>(
        BeneficiariesNotifier.new);

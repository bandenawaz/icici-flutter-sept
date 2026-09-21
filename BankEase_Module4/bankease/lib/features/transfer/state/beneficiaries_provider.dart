import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bankease/features/transfer/data/beneficiaries_repository.dart';
import 'package:bankease/features/transfer/domain/beneficiary.dart';

class BeneficiariesNotifier extends AsyncNotifier<List<Beneficiary>> {
  @override
  Future<List<Beneficiary>> build() =>
      ref.watch(beneficiariesRepositoryProvider).fetchAll();

  /// Saves on the server, then puts the saved payee into state.
  /// Throws a BankError (e.g. BENEFICIARY_EXISTS) for the screen to show.
  Future<Beneficiary> add({
    required String name,
    required String accountNumber,
    required String ifsc,
  }) async {
    final created = await ref.read(beneficiariesRepositoryProvider).add(
          name: name,
          accountNumber: accountNumber,
          ifsc: ifsc,
        );
    state = AsyncValue.data([...(state.valueOrNull ?? const []), created]);
    return created;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(beneficiariesRepositoryProvider).fetchAll(),
    );
  }
}

final beneficiariesProvider =
    AsyncNotifierProvider<BeneficiariesNotifier, List<Beneficiary>>(
  BeneficiariesNotifier.new,
);

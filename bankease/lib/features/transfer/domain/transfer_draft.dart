import 'package:bankease/features/accounts/domain/account.dart';
import 'package:bankease/features/transfer/domain/beneficiary.dart';

/// What the user filled in, passed from Transfer to Review.
class TransferDraft {
  const TransferDraft({
    required this.from,
    required this.to,
    required this.amountPaise,
    this.remarks = '',
  });

  final Account from;
  final Beneficiary to;
  final int amountPaise;
  final String remarks;
}

/// What the "bank" returned, passed from Review to Success.
class TransferReceipt {
  const TransferReceipt({
    required this.draft,
    required this.referenceId,
    required this.completedAt,
  });

  final TransferDraft draft;
  final String referenceId;
  final DateTime completedAt;
}

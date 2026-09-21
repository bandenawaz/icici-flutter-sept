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

/// What the BANK returned. The reference id and the new balance come from
/// the server, never from the app.
class TransferReceipt {
  const TransferReceipt({
    required this.draft,
    required this.referenceId,
    required this.completedAt,
    required this.balanceAfterPaise,
  });

  final TransferDraft draft;
  final String referenceId;
  final DateTime completedAt;
  final int balanceAfterPaise;

  factory TransferReceipt.fromJson(Map<String, dynamic> json, TransferDraft draft) =>
      TransferReceipt(
        draft: draft,
        referenceId: json['referenceId'] as String,
        completedAt: DateTime.parse(json['completedAt'] as String).toLocal(),
        balanceAfterPaise: json['balanceAfterPaise'] as int,
      );
}

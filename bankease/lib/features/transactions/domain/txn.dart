class Txn {
  const Txn({
    required this.id,
    required this.accountId,
    required this.title,
    required this.amountPaise,
    required this.date,
    required this.mode,
  });

  final String id;
  final String accountId;
  final String title;
  final int amountPaise; // negative = debit
  final DateTime date;
  final String mode; // UPI, NEFT, IMPS ...

  bool get isDebit => amountPaise < 0;
}

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
  final String mode;

  bool get isDebit => amountPaise < 0;

  factory Txn.fromJson(Map<String, dynamic> json) => Txn(
        id: json['id'] as String,
        accountId: json['accountId'] as String,
        title: json['title'] as String,
        amountPaise: json['amountPaise'] as int,
        // The API sends UTC ISO-8601; toLocal() shows the user their own time.
        date: DateTime.parse(json['at'] as String).toLocal(),
        mode: json['mode'] as String,
      );
}

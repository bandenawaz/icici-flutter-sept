class Beneficiary {
  const Beneficiary({
    required this.id,
    required this.name,
    required this.accountNumber,
    required this.ifsc,
  });

  final String id;
  final String name;
  final String accountNumber;
  final String ifsc;

  String get maskedNumber =>
      'XXXX${accountNumber.substring(accountNumber.length - 4)}';

  /// 'Ravi Kumar' -> 'RK'
  String get initials => name
      .trim()
      .split(RegExp(r'\s+'))
      .take(2)
      .map((part) => part[0].toUpperCase())
      .join();
}

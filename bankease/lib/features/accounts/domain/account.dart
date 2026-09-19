enum AccountType {
  savings('Savings'),
  current('Current');

  const AccountType(this.label);
  final String label;
}

class Account {
  const Account({
    required this.id,
    required this.type,
    required this.holderName,
    required this.number,
    required this.ifsc,
    required this.branch,
    required this.balancePaise,
  });

  final String id;
  final AccountType type;
  final String holderName;
  final String number;
  final String ifsc;
  final String branch;
  final int balancePaise;

  String get maskedNumber => 'XXXX${number.substring(number.length - 4)}';

  /// Returns a NEW Account with a different balance. The original is untouched
  Account copyWith({int? balancePaise}) => Account(
      id: id,
      type: type,
      holderName: holderName,
      number: number,
      ifsc: ifsc,
      branch: branch,
      balancePaise: balancePaise ?? this.balancePaise);
}

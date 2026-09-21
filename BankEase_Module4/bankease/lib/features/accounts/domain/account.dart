enum AccountType {
  savings('Savings'),
  current('Current');

  const AccountType(this.label);
  final String label;

  /// The API sends "SAVINGS" / "CURRENT".
  static AccountType fromApi(String value) =>
      value.toUpperCase() == 'CURRENT' ? AccountType.current : AccountType.savings;
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

  factory Account.fromJson(Map<String, dynamic> json) => Account(
        id: json['id'] as String,
        type: AccountType.fromApi(json['type'] as String),
        holderName: json['holderName'] as String,
        number: json['number'] as String,
        ifsc: json['ifsc'] as String,
        branch: json['branch'] as String,
        balancePaise: json['balancePaise'] as int,
      );
}

class Session {
  final String token;
  final String customerId;
  final String customerName;

  const Session({
    required this.token,
    required this.customerId,
    required this.customerName,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'] as Map<String, dynamic>;

    return Session(
        token: json['token'] as String,
        customerId: json['id'] as String,
        customerName: json['name'] as String);
  }
  String get firstName => customerName.split(' ').first;
}

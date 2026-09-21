class Session {
  const Session({
    required this.token,
    required this.customerId,
    required this.customerName,
  });

  final String token;
  final String customerId;
  final String customerName;

  factory Session.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'] as Map<String, dynamic>;
    return Session(
      token: json['token'] as String,
      customerId: customer['id'] as String,
      customerName: customer['name'] as String,
    );
  }

  String get firstName => customerName.split(' ').first;
}

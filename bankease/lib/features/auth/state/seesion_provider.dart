import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionState {
  const SessionState({
    this.customerId = '',
    this.customerName = '',
    this.isLoggedIn = false,
  });

  final String customerId;
  final String customerName;
  final bool isLoggedIn;

  SessionState copyWith({
    String? customerId,
    String? customerName,
    bool? isLoggedIn,
  }) {
    return SessionState(
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}

/// App state: keeps the logged-in customer identity and auth state.
class SessionNotifier extends Notifier<SessionState> {
  @override
  SessionState build() => const SessionState(); // logged out when app starts

  void login({required String customerId, String? customerName}) {
    state = state.copyWith(
      customerId: customerId,
      customerName: customerName ?? 'Customer $customerId',
      isLoggedIn: true,
    );
  }

  void logout() => state = const SessionState();
}

final sessionProvider =
    NotifierProvider<SessionNotifier, SessionState>(SessionNotifier.new);

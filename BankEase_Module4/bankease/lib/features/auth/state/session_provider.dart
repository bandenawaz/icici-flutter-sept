import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bankease/features/auth/data/auth_repository.dart';
import 'package:bankease/features/auth/domain/session.dart';

/// App state: the current session, or null when logged out.
class SessionNotifier extends Notifier<Session?> {
  @override
  Session? build() => null;

  /// Throws a BankError if the server rejects the login.
  Future<void> login({required String customerId, required String pin}) async {
    final session = await ref
        .read(authRepositoryProvider)
        .login(customerId: customerId, pin: pin);
    state = session;
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    clear();
  }

  /// Used by the 401 interceptor: drop the session without calling the server.
  void clear() => state = null;
}

final sessionProvider =
    NotifierProvider<SessionNotifier, Session?>(SessionNotifier.new);

/// Convenience for the router guard and greetings.
final isLoggedInProvider = Provider<bool>((ref) => ref.watch(sessionProvider) != null);

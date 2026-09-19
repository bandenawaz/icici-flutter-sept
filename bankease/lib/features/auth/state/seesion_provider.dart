import 'package:flutter_riverpod/flutter_riverpod.dart';

/// App state: is the customer logged in?

class SessionNotifier extends Notifier<bool> {
  @override
  bool build() => false; // logged out when the app starts

  void login() => state = true;
  void logout() => state = false;
}

final sessionProvider =
    NotifierProvider<SessionNotifier, bool>(SessionNotifier.new);

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bankease/app/app.dart';

void main() {
  // ProviderScope is the container that stores the state of every provider.
  // It must wrap the whole app, once.
  runApp(const ProviderScope(child: BankEaseApp()));
}

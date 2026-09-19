import 'package:flutter/material.dart';

import 'package:bankease/app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Entry point: Dart starts here, Flutter starts drawing from BankEaseApp.
void main() {
  // ProviderScope is the container that stores th state of every provider
  // It must wrap the entire app
  runApp(const ProviderScope(child: BankEaseApp()));
}

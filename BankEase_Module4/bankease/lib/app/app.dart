import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bankease/app/router.dart';
import 'package:bankease/app/theme.dart';
import 'package:bankease/features/auth/state/session_provider.dart';

class BankEaseApp extends ConsumerStatefulWidget {
  const BankEaseApp({super.key});

  @override
  ConsumerState<BankEaseApp> createState() => _BankEaseAppState();
}

class _BankEaseAppState extends ConsumerState<BankEaseApp> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // Auto-lock: when the app goes to the background, log the user out.
    _lifecycle = AppLifecycleListener(
      onPause: () => ref.read(sessionProvider.notifier).logout(),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // A new router is created on login/logout, so this rebuilds then.
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'BankEase',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}

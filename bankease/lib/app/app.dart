import 'package:bankease/features/auth/state/seesion_provider.dart';
import 'package:flutter/material.dart';

import 'package:bankease/app/router.dart';
import 'package:bankease/app/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BankEaseApp extends ConsumerStatefulWidget {
  const BankEaseApp({super.key});

  @override
  ConsumerState<BankEaseApp> createState() => _BankEaseAppState();
}

class _BankEaseAppState extends ConsumerState<BankEaseApp> {
  late final AppLifecycleListener _appLifecycleListener;
  @override
  void initState() {
    super.initState();
    _appLifecycleListener = AppLifecycleListener(
      onPause: () => ref.read(sessionProvider.notifier).logout(),
    );
  }

  @override
  void dispose() {
    _appLifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //A new router is created on login/logout, so that this rebuilds then
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'BankEase',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}

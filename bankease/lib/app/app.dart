import 'package:flutter/material.dart';

import 'package:bankease/app/router.dart';
import 'package:bankease/app/theme.dart';

class BankEaseApp extends StatelessWidget {
  const BankEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp.router hands navigation over to go_router.
    return MaterialApp.router(
      title: 'BankEase',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}

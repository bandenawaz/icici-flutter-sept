import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bankease/app/app.dart';
import 'package:bankease/features/auth/presentation/login_screen.dart';

void main() {
  testWidgets('App starts on the login screen', (tester) async {
    await tester.pumpWidget(const BankEaseApp());
    await tester.pumpAndSettle();

    expect(find.text('Welcome to BankEase'), findsOneWidget);
  });

  testWidgets('Login shows errors when fields are empty', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pump();

    expect(find.text('Enter your customer ID'), findsOneWidget);
    expect(find.text('Enter your PIN'), findsOneWidget);
  });
}

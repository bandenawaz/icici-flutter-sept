// The problem Module 3 solves. Paste into dartpad.dev (Flutter).
// The balance lives at the top and must be passed down through
// every widget, even ones that never use it.
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Bank()));

class Bank extends StatefulWidget {
  const Bank({super.key});
  @override
  State<Bank> createState() => _BankState();
}

class _BankState extends State<Bank> {
  int balance = 5000;

  void pay(int amount) => setState(() => balance -= amount);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Dashboard(balance: balance, onPay: pay)),
    );
  }
}

// Dashboard doesn't use balance or onPay. It only passes them on.
class Dashboard extends StatelessWidget {
  const Dashboard({super.key, required this.balance, required this.onPay});
  final int balance;
  final void Function(int) onPay;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Balance: ₹$balance', style: const TextStyle(fontSize: 28)),
        PayButton(onPay: onPay),
      ],
    );
  }
}

class PayButton extends StatelessWidget {
  const PayButton({super.key, required this.onPay});
  final void Function(int) onPay;

  @override
  Widget build(BuildContext context) {
    return FilledButton(onPressed: () => onPay(20), child: const Text('Pay ₹20'));
  }
}

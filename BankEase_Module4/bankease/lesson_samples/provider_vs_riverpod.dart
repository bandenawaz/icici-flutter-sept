// Side-by-side comparison (read-only; not part of the app).

// ---------- package:provider (ChangeNotifier) ----------
// class BalanceModel extends ChangeNotifier {
//   int _balance = 5000;
//   int get balance => _balance;
//   void pay(int amount) {
//     _balance -= amount;
//     notifyListeners();               // you must remember to call this
//   }
// }
//
// main: runApp(ChangeNotifierProvider(
//   create: (_) => BalanceModel(), child: const MyApp()));
//
// read in a widget:  context.watch<BalanceModel>().balance
// change it:         context.read<BalanceModel>().pay(20)

// ---------- package:flutter_riverpod (Notifier) ----------
// class BalanceNotifier extends Notifier<int> {
//   @override
//   int build() => 5000;
//   void pay(int amount) => state = state - amount; // assigning notifies
// }
// final balanceProvider =
//     NotifierProvider<BalanceNotifier, int>(BalanceNotifier.new);
//
// main: runApp(const ProviderScope(child: MyApp()));
//
// read in a ConsumerWidget:  ref.watch(balanceProvider)
// change it:                 ref.read(balanceProvider.notifier).pay(20)

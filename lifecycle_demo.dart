
import 'package:flutter/material.dart';

void main(){
  runApp(const MaterialApp(
    home: Host(),
  ));
}

class Host extends StatefulWidget {
  const Host({Key? key}) : super(key: key);

  @override
  State<Host> createState() => _HostState();
}

class _HostState extends State<Host> {

  bool _show = true;
  int _amount = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _show ? BalanceLabel(amount: _amount) : const Text('Removed')),
      ),

      FloatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () => setState(() => _amount+= 100),
            child: const Icon(Icons.add),
          ),

          const SizedBox(width: 8),

          FloatingActionButton(
            onPressed: () => setState(() => _show = !_show),
            child: const Icon(Icons.visibility),
          ),
        ],
      ),
    );
  }
}


class BalanceLabel extends StatefulWidget{

  const BalanceLabel({super.key,required this.amount}) ;

  final int amount;
  @override
  State<BalanceLabel> createState() => _BalanceLabelState(){
    debugPrint('1. createState');
    return _BalanceLabelState();
  }
}

class _BalanceLabelState extends State<BalanceLabel>{
  @override
  void initState() {
    super.initState();
    debugPrint('2. initState');
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint('3. didChangeDependencies');
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('4. build');
    return Text('Balance: ₹${widget.amount}', style: const TextStyle(fontSize: 28));
  }

  @override
  void didUpdateWidget(covariant BalanceLabel oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint('5. didUpdateWidget');
  }

  @override
  void dispose() {
    super.dispose();
    debugPrint('6. dispose');
  }
}
import 'package:flutter/material.dart';

class NoBluetoothMenu extends StatelessWidget {
  final void Function() onRetry;
  const NoBluetoothMenu({required this.onRetry, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bluetooth is disabled"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "MatrixController needs location permissions and bluetooth to be active in order to function properly.",
            textAlign: TextAlign.center,
          ),
          TextButton(onPressed: onRetry, child: Text("Retry"))
        ],
      ),
    );
  }
}

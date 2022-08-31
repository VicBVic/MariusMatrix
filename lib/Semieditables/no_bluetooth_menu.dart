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
            "To have MatrixController function properly, allow access to bluetooth from the button below.",
            textAlign: TextAlign.center,
          ),
          TextButton(onPressed: onRetry, child: Text("Retry"))
        ],
      ),
    );
  }
}

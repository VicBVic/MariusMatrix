import 'package:flutter/material.dart';
import 'package:flutter_application_1/redux/bluetooth_state.dart';
import 'package:flutter_application_1/redux/bluetooth_state_actions.dart';
import 'package:flutter_redux/flutter_redux.dart';
// ignore: depend_on_referenced_packages

class NoBluetoothMenu extends StatelessWidget {
  const NoBluetoothMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<BluetoothAppState>(builder: (context, store) {
      store.dispatch(StartAskForPermissions(context));
      return Scaffold(
        appBar: AppBar(
          title: const Text("Bluetooth is disabled"),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "MatrixController needs location permissions and bluetooth to be active in order to function properly.",
              textAlign: TextAlign.center,
            ),
            TextButton(
                onPressed: () =>
                    store.dispatch(StartAskForPermissions(context)),
                child: const Text("Retry"))
          ],
        ),
      );
    });
  }
}

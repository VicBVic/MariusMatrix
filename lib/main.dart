import 'package:flutter/material.dart';
import 'package:flutter_application_1/error_menus/no_bluetooth_menu.dart';
import 'package:flutter_application_1/redux/bluetooth_reducer.dart';
import 'package:flutter_application_1/redux/bluetooth_state.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'main_widgets/main_scaffold.dart';
import 'package:redux/redux.dart';

import 'redux/bluetooth_state_actions.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Store<BluetoothAppState> store = Store<BluetoothAppState>(
    bluetoothStateReducer,
    initialState: BluetoothAppState(robotConnections: {}),
    middleware: [
      bluetoothStateBondedDevicesMiddleware,
      bluetoothStateAskPermissionsMiddleware,
      bluetoothStateAddBotByDeviceMiddleware
    ],
  );
  store.dispatch(StartBondedDevicesSearch());
  store.dispatch(StartAskForPermissions());
  runApp(MaruisMatrixApp(
    store: store,
  ));
}

class MaruisMatrixApp extends StatelessWidget {
  const MaruisMatrixApp({Key? key, required this.store}) : super(key: key);

  final Store<BluetoothAppState> store;

  @override
  Widget build(BuildContext context) {
    return StoreProvider<BluetoothAppState>(
      store: store,
      child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          //hemeMode: ThemeMode.dark,
          debugShowCheckedModeBanner: false,
          home: StoreBuilder<BluetoothAppState>(builder: (context, store) {
            if (store.state.permissionsAccepted) {
              return const MainScaffold(
                title: "MatrixController",
              );
            } else {
              return NoBluetoothMenu();
            }
          })),
    );
  }
}

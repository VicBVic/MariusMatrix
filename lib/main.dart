import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      bluetoothStateAddBotByDeviceMiddleware,
      bluetoothUpdateBotInfoMiddleware,
    ],
  );
  AwesomeNotifications().initialize(
      // set the icon to null if you want to use the default app icon
      null,
      [
        NotificationChannel(
          channelGroupKey: 'basic_channel_group',
          channelKey: 'alert_channel',
          channelName: 'Alert Notifications',
          channelDescription: 'Notification channel for basic tests',
          defaultColor: Color(0xFF9D50DD),
          ledColor: Colors.white,
          criticalAlerts: true,
          importance: NotificationImportance.Max,
        )
      ],
      // Channel groups are only visual and are not required
      channelGroups: [
        NotificationChannelGroup(
            channelGroupkey: 'basic_channel_group',
            channelGroupName: 'Basic group')
      ],
      debug: true);
  runApp(MaruisMatrixApp(
    store: store,
  ));
}

class MaruisMatrixApp extends StatefulWidget {
  const MaruisMatrixApp({Key? key, required this.store}) : super(key: key);

  final Store<BluetoothAppState> store;

  @override
  State<MaruisMatrixApp> createState() => _MaruisMatrixAppState();
}

class _MaruisMatrixAppState extends State<MaruisMatrixApp> {
  @override
  void initState() {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp]); // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widget.store.dispatch(StartAskForPermissions(context));
    return StoreProvider<BluetoothAppState>(
      store: widget.store,
      child: MaterialApp(
          title: 'MariusController',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          //hemeMode: ThemeMode.Rdark,
          debugShowCheckedModeBanner: false,
          home: StoreBuilder<BluetoothAppState>(builder: (context, store) {
            if (store.state.permissionsAccepted) {
              return const MainScaffold(
                title: "MariusController",
              );
            } else {
              return NoBluetoothMenu();
            }
          })),
    );
  }
}

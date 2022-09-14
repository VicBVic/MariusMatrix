import 'package:flutter_application_1/bluetooth/blue_broadcast_handler.dart';

import 'package:flutter_application_1/redux/bluetooth_state.dart';
import 'package:flutter_application_1/redux/bluetooth_state_actions.dart';
import 'package:flutter_application_1/util/robot_connection.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:redux/redux.dart';

import '../bluetooth/bot_info.dart';

BluetoothAppState bluetoothStateReducer(
    BluetoothAppState state, dynamic action) {
  print("reducer bitch ass mf $action");
  if (action is PermisionsAcceptedAction) {
    state.permissionsAccepted = true;
  }
  if (action is CompleteBotConnectionAction) {
    RobotConnection connection = state.robotConnections.firstWhere(
        (element) => element.device == action.data.device, orElse: () {
      RobotConnection newConnection = RobotConnection(
          RobotConnectionState.discovering,
          device: action.data.device);
      state.robotConnections.add(newConnection);
      return newConnection;
    });
    connection.mergeWith(action.data);
  }

  if (action is ErrorAction) {
    print("Error!");
  }
  if (action is AddBondedDevicesAction) {
    //print("ready to get plowed ${action.devices}");
    state.bondedDevices = action.devices;
  }
  return state;
}

void bluetoothStateBondedDevicesMiddleware(
    Store<BluetoothAppState> store, dynamic action, NextDispatcher next) {
  if (action is StartBondedDevicesSearch) {
    print("bruhfuck");
    BlueBroadcastHandler.instance
        .getBondedDevices()
        .onError((error, stackTrace) {
      print("Bluetooth error!");
      return List.empty();
    }).then((value) async {
      //debug
      await Future.delayed(Duration(milliseconds: 500));
      if (value.isEmpty) {
        store.dispatch(ErrorAction());
      } else {
        store.dispatch(AddBondedDevicesAction(value));
      }
    });
  } else
    next(action);
}

void bluetoothStateAddBotByDeviceMiddleware(
    Store<BluetoothAppState> store, dynamic action, NextDispatcher next) {
  if (action is StartAddBotByDevice) {
    final device = action.device;
    store.dispatch(CompleteBotConnectionAction(
        RobotConnection(RobotConnectionState.connecting, device: device)));
    BlueBroadcastHandler.instance
        .getConnectionToAdress(action.device.address)
        .then((connection) async {
      if (connection == null) throw ("no connection found!");
      store.dispatch(CompleteBotConnectionAction(RobotConnection(
        RobotConnectionState.fetchingInfo,
        device: device,
        connection: connection,
      )));
      BotInfo info = await BlueBroadcastHandler.instance.getBotInfo(connection);
      store.dispatch(CompleteBotConnectionAction(RobotConnection(
        RobotConnectionState.complete,
        device: device,
        botInfo: info,
      )));
    }).onError((error, stackTrace) {
      print("addBotByDevice cuie frate $error $stackTrace");
    });
  } else
    next(action);
}

void bluetoothStateAskPermissionsMiddleware(
    Store<BluetoothAppState> store, dynamic action, NextDispatcher next) {
  if (action is StartAskForPermissions) {
    FlutterBluetoothSerial blue = FlutterBluetoothSerial.instance;
    blue.requestEnable().then((value) async {
      //print("here2");
      bool accepted = (value ?? false) &&
          await Permission.location.request().then((value) {
            if (value.isPermanentlyDenied) {
              print("ErrorAction sent");
              store.dispatch(ErrorAction());
            }
            print(
                "here ${value.isGranted} ${value.isDenied} ${value.isPermanentlyDenied} ${value.isRestricted}");
            return value.isGranted;
          });
      if (accepted) {
        store.dispatch(PermisionsAcceptedAction());
      }
    });
  } else
    next(action);
}

import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/bluetooth/blue_broadcast_handler.dart';
import 'package:flutter_application_1/file_access/file_manager.dart';

import 'package:flutter_application_1/redux/bluetooth_state.dart';
import 'package:flutter_application_1/redux/bluetooth_state_actions.dart';
import 'package:flutter_application_1/robot_menus/loaded_menu.dart';
import 'package:flutter_application_1/util/robot_connection.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:redux/redux.dart';

import '../bluetooth/bot_info.dart';

BluetoothAppState bluetoothStateReducer(
    BluetoothAppState state, dynamic action) {
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
  if (action is DeleteBotConnectionAction) {
    state.robotConnections
        .removeWhere((element) => element.device == action.deviceOfConnection);
    FileManager.instance.updateAdresses(
        state.robotConnections.map((e) => e.device.address).toList());
  }
  return state;
}

void bluetoothStateBondedDevicesMiddleware(
    Store<BluetoothAppState> store, dynamic action, NextDispatcher next) {
  if (action is StartBondedDevicesSearch) {
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
        bluetoothStateAddStoredDevices(store);
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
      bluetoothStateUpdateDevices(store);
    }).onError((error, stackTrace) {});
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
          (await Permission.location.request().then((value) {
            if (value.isPermanentlyDenied) {
              store.dispatch(ErrorAction());
            }
            return value.isGranted;
          })) &&
          (await _getBackgroundPermissions(action.context)) &&
          (await AwesomeNotifications().isNotificationAllowed());
      if (accepted) {
        store.dispatch(PermisionsAcceptedAction());
        store.dispatch(StartBondedDevicesSearch());
      }
    });
  } else
    next(action);
}

Future<bool> _getBackgroundPermissions(context) async {
  const config = FlutterBackgroundAndroidConfig(
    notificationTitle: 'MariusMatrix is running',
    notificationText:
        'Your robots are currently detecting any movement in your residence.',
    //notificationIcon: AndroidResource(name: 'background_icon'),
    notificationImportance: AndroidNotificationImportance.Default,
    enableWifiLock: true,
  );

  bool hasPermissions = await FlutterBackground.hasPermissions;
  if (!hasPermissions) {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text('Permissions needed'),
              content: Text(
                  'Shortly the OS will ask you for permission to execute this app in the background. This is required in order to receive chat messages when the app is not in the foreground.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, 'OK'),
                  child: const Text('OK'),
                ),
              ]);
        });
  }

  hasPermissions = await FlutterBackground.initialize(androidConfig: config);
  return hasPermissions;
}

void bluetoothStateAddStoredDevices(Store<BluetoothAppState> store) {
  FileManager.instance.getBotAdresses().then((value) {
    List<BluetoothDevice> devices = store.state.bondedDevices
        .where((element) => value.contains(element.address))
        .toList();
    for (var device in devices) {
      store.dispatch(StartAddBotByDevice(device));
    }
  });
}

void bluetoothStateUpdateDevices(Store<BluetoothAppState> store) {
  FileManager.instance.updateAdresses(
      store.state.robotConnections.map((e) => e.device.address).toList());
}

void bluetoothUpdateBotInfoMiddleware(
    Store<BluetoothAppState> store, dynamic action, NextDispatcher next) {
  if (action is UpdateBotInfoAction) {
    var robot = store.state.robotConnections
        .firstWhere((element) => element.device == action.device);
    var con = robot.connection;
    var info = CompleteBotInfo.fromBotInfo(robot.botInfo);
    if (con == null || info == null) throw ("Whoops bot incomplete");
    if (info.name != action.data.name) {
      BlueBroadcastHandler.instance
          .printMessage(con, "name:${action.data.name}\n");
    }
    if (info.musicFileName != action.data.musicFileName) {
      var index = musicFileNames[action.data.musicFileName];
      if (index == null) throw ("Bruh music fine not found");
      BlueBroadcastHandler.instance
          .printMessage(con, "currentAlarmIndex:${index}\n");
    }
    if (info.isActive != action.data.isActive) {
      BlueBroadcastHandler.instance
          .printMessage(con, "isActive:${action.data.isActive ? "1" : "0"}\n");
    }
    if (info.isManual != action.data.isManual) {
      BlueBroadcastHandler.instance
          .printMessage(con, "isManual:${action.data.isManual ? "1" : "0"}\n");
    }
    if (info.startTimeMinutes != action.data.startTimeMinutes) {
      BlueBroadcastHandler.instance.printMessage(
          con, "startTimeMinutes:${action.data.startTimeMinutes}\n");
    }
    if (info.endTimeMinutes != action.data.endTimeMinutes) {
      BlueBroadcastHandler.instance
          .printMessage(con, "endTimeMinutes:${action.data.endTimeMinutes}\n");
    }
    store.dispatch(CompleteBotConnectionAction(RobotConnection(robot.state,
        device: action.device,
        botInfo: BotInfo.fromCompleteBotInfo(action.data))));
  } else {
    next(action);
  }
}

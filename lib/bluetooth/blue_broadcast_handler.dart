import 'dart:convert';

import 'package:flutter_application_1/bluetooth/alert_manager.dart';
import 'package:flutter_application_1/bluetooth/connection_to_commands.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BlueBroadcastHandler {
  Map<String, BluetoothConnection> _addressToConnection = {};
  Map<BluetoothConnection, Stream<String>> _connectionToCommandStream = {};

  static final BlueBroadcastHandler instance = BlueBroadcastHandler._internal();

  factory BlueBroadcastHandler() {
    return instance;
  }
  final int maxConnectionRetries = 2;

  Set<BluetoothDevice> bondedDevices = <BluetoothDevice>{};

  Future<BluetoothConnection> getConnectionToAdress(String address,
      {int retries = 0}) async {
    if (retries > 2) throw ("fruie coate");
    BluetoothConnection result =
        await BluetoothConnection.toAddress(address).then(
      (connection) {
        print("connected $address!");
        return connection;
      },
    ).onError((error, stackTrace) async {
      print("cuie frate $address");
      return await getConnectionToAdress(address, retries: retries + 1);
    });
    return result;
  }

  Future<void> addBondedDeviceListener() async {
    await FlutterBluetoothSerial.instance
        .getBondedDevices()
        .then((avalibleDevices) {
      bondedDevices.addAll(avalibleDevices);
    });
    print("blueBroadcastHandler gata tati");
    for (BluetoothDevice b in bondedDevices) {
      print(b.address);
    }
  }

  Future<bool> addAddress(String address) async {
    print("Entered addAdress body");
    if (_addressToConnection.containsKey(address) &&
        _addressToConnection[address]!.isConnected) return true;
    print("Entered addAdress body");

    try {
      _addressToConnection[address] = await getConnectionToAdress(address);
    } catch (e) {
      print(e);
      return false;
    }

    var connection = _addressToConnection[address]!;
    _connectionToCommandStream[connection] =
        bluetoothConnectionReceivedCommands(connection).asBroadcastStream();

    print("connected ${_connectionToCommandStream[connection]}");
    return true;
  }

  Future<Stream<String>> getCommandStream(String address) async {
    await addAddress(address);
    //print("returned stream ${_connectionToCommandStream[]}");
    return _connectionToCommandStream[_addressToConnection[address]]!;
  }

  void printMessage(String address, String message) async {
    await addAddress(address);
    _addressToConnection[address]?.output.add(ascii.encode(message));
  }

  Stream<String> getAlertStream(String address, String name) async* {
    await addAddress(address);

    await for (String command
        in _connectionToCommandStream[_addressToConnection[address]]!) {
      command = command.replaceAll('\n', '');
      command = command.replaceAll('\r', '');
      if (command == "Alert") {
        print("alert found command $command ${command == "Alert"}");
        yield name;
      }
    }
  }

  BlueBroadcastHandler._internal();
}

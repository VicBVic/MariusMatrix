import 'dart:convert';

import 'package:flutter_application_1/util/connection_to_commands.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BlueBroadcastHandler {
  Map<String, BluetoothConnection> _addressToConnection = {};
  Map<BluetoothConnection, Stream<String>> _connectionToCommandStream = {};

  static final BlueBroadcastHandler instance = BlueBroadcastHandler._internal();

  factory BlueBroadcastHandler() {
    return instance;
  }

  Future<void> addAddress(String address) async {
    if (_addressToConnection.containsKey(address)) return;

    await BluetoothConnection.toAddress(address)
        .then(
          (connection) => _addressToConnection[address] = connection,
        )
        .onError((error, stackTrace) async => _addressToConnection[address] =
            await BluetoothConnection.toAddress(address));
    var connection = _addressToConnection[address]!;
    _connectionToCommandStream[connection] =
        bluetoothConnectionReceivedCommands(connection).asBroadcastStream();
    return;
  }

  Stream<String>? getCommandStream(String address) {
    if (_connectionToCommandStream.containsKey(address)) {
      return _connectionToCommandStream[address];
    }
    return null;
  }

  void printMessage(String address, String message) {
    _addressToConnection[address]?.output.add(ascii.encode(message));
  }

  BlueBroadcastHandler._internal();
}

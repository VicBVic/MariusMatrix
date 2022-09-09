import 'dart:convert';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

Stream<String> bluetoothConnectionReceivedCommands(
    BluetoothConnection connection) async* {
  String buffer = "";
  await for (final data in connection.input!.asBroadcastStream()) {
    String received = utf8.decode(data);
    for (var a in received.split('')) {
      buffer += a;
      if (a == '\n') {
        yield buffer;
        buffer = '';
      }
    }
  }
}

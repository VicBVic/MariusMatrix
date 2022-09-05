import 'dart:async';
import 'dart:convert';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'connection_to_commands.dart';

const String detectionString = "r u a bot?\n";
const String validConnectionString = "yes i am bot\n";

Future<bool> isBotTest(BluetoothConnection connection, Duration timeout) async {
  connection.output.add(Uint8List.fromList(ascii.encode(detectionString)));

  print("entered isBotTest body");

  print("added detection message");

  Stream<String> commands =
      bluetoothConnectionReceivedCommands(connection).asBroadcastStream();

  await for (final command in commands) {
    print("found command $command ${command == validConnectionString}");
    if (command == validConnectionString) {
      //commands.drain();
      return true;
    }
  }
  //commands.drain();
  return false;
}

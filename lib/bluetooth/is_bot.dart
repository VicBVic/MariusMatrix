import 'dart:async';
import 'dart:convert';

import 'package:flutter_application_1/bluetooth/blue_broadcast_handler.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'connection_to_commands.dart';

const String detectionString = "r u a bot?\n";
const String validConnectionString = "yes i am bot\n";

Future<bool> isBotTest(String address) async {
  print("entered isBotTest body");
  await BlueBroadcastHandler.instance.addAddress(address);

  BlueBroadcastHandler.instance.printMessage(address, detectionString);
  print("added detection message");

  await for (final command
      in await BlueBroadcastHandler.instance.getCommandStream(address)) {
    print("found command $command ${command == validConnectionString}");
    if (command == validConnectionString) {
      return true;
    }
  }
  return false;
}

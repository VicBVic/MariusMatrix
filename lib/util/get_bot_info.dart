import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_application_1/util/blue_broadcast_handler.dart';
import 'package:flutter_application_1/util/connection_to_commands.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BotInfo {
  bool? isActive;
  String? name;
  BotInfo(this.isActive, this.name);
  void parseString(String arg) {
    arg = arg.replaceAll('\n', '');
    List<String> pair = arg.split(':');
    if (pair.length != 2) return;
    print(
        "caught ${pair.first} ${pair.last} fuck ${(pair.last == "1") ? "yea" : "nay"} yea bitch");
    switch (pair.first) {
      case "isActive":
        isActive = (pair.last == "1");
        break;
      case "name":
        name = (pair.last);
        break;
    }
  }

  BotInfo.empty() {
    isActive = null;
    name = null;
  }
}

const Duration rerequestTime = Duration(seconds: 10);

const String getInfoCommand = "gib me ur info\n";

Future<BotInfo> getAddressInfo(String address) async {
  await BlueBroadcastHandler.instance.addAddress(address);

  BlueBroadcastHandler.instance.printMessage(address, getInfoCommand);

  BotInfo result = BotInfo.empty();

  await for (final command
      in BlueBroadcastHandler.instance.getCommandStream(address)!) {
    result.parseString(command);
    if (result.name != null && result.isActive != null) return result;
  }
  return result;
}

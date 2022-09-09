import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/scheduler.dart';
import 'package:flutter_application_1/Bluetooth/blue_broadcast_handler.dart';
import 'package:flutter_application_1/Bluetooth/connection_to_commands.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BotInfo {
  bool? isActive, isManual;
  String? name, musicFileName;
  int? startTimeMinutes, endTimeMinutes;
  BotInfo(this.isActive, this.name);
  void parseString(String arg) {
    arg = arg.replaceAll('\n', '');
    arg = arg.replaceAll('\r', '');
    List<String> pair = arg.split(':');
    if (pair.length != 2) return;
    print("${pair.first} ${pair.last}");
    switch (pair.first) {
      case "isActive":
        isActive = (pair.last == "1");
        break;
      case "isManual":
        isManual = (pair.last == "1");
        break;
      case "name":
        name = (pair.last);
        break;
      case "musicFileName":
        musicFileName = pair.last;
        break;
      case "startTimeMinutes":
        startTimeMinutes = int.parse(pair.last);
        break;
      case "endTimeMinutes":
        endTimeMinutes = int.parse(pair.last);
        break;
      default:
        print("ce facuesti fraiere");
    }
    print(isComplete());
  }

  BotInfo.empty() {}

  bool isComplete() {
    /*print(
        "${isActive != null} ${isManual != null}${name != null} ${startTimeMinutes != null} ${endTimeMinutes != null} ${musicFileName != null}");*/
    return isActive != null &&
        isManual != null &&
        name != null &&
        startTimeMinutes != null &&
        endTimeMinutes != null &&
        musicFileName != null;
  }
}

const Duration rerequestTime = Duration(seconds: 10);

const String getInfoCommand = "gib me ur info\n";

Future<BotInfo> getAddressInfo(String address) async {
  await BlueBroadcastHandler.instance.addAddress(address);

  BlueBroadcastHandler.instance.printMessage(address, getInfoCommand);

  BotInfo result = BotInfo.empty();

  await for (final command
      in await BlueBroadcastHandler.instance.getCommandStream(address)) {
    result.parseString(command);
    if (result.isComplete()) return result;
  }
  return result;
}

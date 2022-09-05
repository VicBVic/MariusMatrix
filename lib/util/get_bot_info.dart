import 'dart:convert';
import 'dart:typed_data';

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

Future<BotInfo> getConnectionBotInfo(BluetoothConnection connection) async {
  connection.output.add(Uint8List.fromList(ascii.encode(getInfoCommand)));

  Stream<String> commands =
      bluetoothConnectionReceivedCommands(connection).asBroadcastStream();

  BotInfo result = BotInfo.empty();

  await for (final command in commands) {
    result.parseString(command);
    if (result.name != null && result.isActive != null) return result;
  }
  return result;
}

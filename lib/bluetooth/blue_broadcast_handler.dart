import 'dart:async';
import 'dart:convert';

import 'package:async/async.dart';

import 'package:flutter_application_1/bluetooth/alert_manager.dart';
import 'package:flutter_application_1/bluetooth/bot_info.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BlueBroadcastHandler {
  Map<String, BluetoothConnection> _connectionBuffer = {};
  Map<BluetoothConnection, StreamController<String>> _commandStreamBuffer = {};

  static final BlueBroadcastHandler instance = BlueBroadcastHandler._internal();

  factory BlueBroadcastHandler() {
    return instance;
  }
  final int maxConnectionRetries = 2;

  Set<BluetoothDevice> _bondedDevicesBuffer = <BluetoothDevice>{};

  Future<BluetoothConnection?> getConnectionToAdress(String address,
      {int retries = 0}) async {
    if (_connectionBuffer.containsKey(address))
      return _connectionBuffer[address];

    if (retries > 0) throw ("Cannot connect to address $address.");

    CancelableOperation connectOperation = CancelableOperation.fromFuture(
      BluetoothConnection.toAddress(address),
      onCancel: () => null,
    );
    var result = await connectOperation
        .valueOrCancellation()
        .onError((error, stackTrace) async {
      print("cuie frate $address");
      return await getConnectionToAdress(address, retries: retries + 1);
    });
    if (result is BluetoothConnection) {
      print("connected $address!");
      _connectionBuffer[address] = result;
      return result;
    }
    print("not connected to $address!");
    return result;
  }

  Future<List<BluetoothDevice>> getBondedDevices() async {
    await FlutterBluetoothSerial.instance
        .getBondedDevices()
        .then((avalibleDevices) {
      _bondedDevicesBuffer.addAll(avalibleDevices);
    });
    return _bondedDevicesBuffer.toList();
  }

  StreamController<String> getCommandStreamController(
      BluetoothConnection connection) {
    var commandStream = _commandStreamBuffer[connection];

    if (commandStream != null) return commandStream;
    commandStream = StreamController<String>.broadcast();
    commandStream.addStream(_bluetoothConnectionReceivedCommands(connection));
    _commandStreamBuffer[connection] = commandStream;
    return commandStream;
  }

  Stream<String> _bluetoothConnectionReceivedCommands(
      BluetoothConnection connection) async* {
    String buffer = "";
    await for (final data in connection.input!.asBroadcastStream()) {
      String received = utf8.decode(data, allowMalformed: true);
      for (var a in received.split('')) {
        buffer += a;
        if (a == '\n') {
          yield buffer;
          buffer = '';
        }
      }
    }
  }

  void printMessage(BluetoothConnection connection, String message) async {
    connection.output.add(ascii.encode(message));
  }

  Stream<String> getAlertStream(
      BluetoothConnection connection, String name) async* {
    await for (String command
        in getCommandStreamController(connection).stream) {
      command = command.replaceAll('\n', '');
      command = command.replaceAll('\r', '');
      if (command == "Alert") {
        print("alert found command $command ${command == "Alert"}");
        yield name;
      }
    }
  }

  final String detectionString = "r u a bot?\n";
  final String validConnectionString = "yes i am bot\n";

  Future<bool> isBotTest(BluetoothConnection connection) async {
    printMessage(connection, detectionString);

    await for (final command in getCommandStreamController(connection).stream) {
      if (command == validConnectionString) {
        return true;
      }
    }
    return false;
  }

  final String getInfoCommand = "gib me ur info\n";

  Future<BotInfo> getBotInfo(BluetoothConnection connection) async {
    printMessage(connection, getInfoCommand);

    BotInfo result = BotInfo.empty();

    await for (final command in getCommandStreamController(connection).stream) {
      result.parseString(command);
      if (result.isComplete()) return result;
    }
    throw ("Stream finished before comleteing result!");
  }

  BlueBroadcastHandler._internal();
}

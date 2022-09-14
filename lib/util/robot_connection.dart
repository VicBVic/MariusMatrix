import 'package:flutter_application_1/bluetooth/bot_info.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

enum RobotConnectionState {
  idle,
  connecting,
  fetchingInfo,
  complete,
  disconnected,
  discovering,
  error
}

class RobotConnection {
  RobotConnectionState state;
  BotInfo? botInfo;
  BluetoothConnection? connection;
  BluetoothDevice device;
  RobotConnection(this.state,
      {required this.device, this.botInfo, this.connection});
  void mergeWith(RobotConnection data) {
    if (data.device != device) {
      throw ("incorrect data passed to robotConnection!");
    }
    state = data.state;
    botInfo = data.botInfo ?? botInfo;
    connection = data.connection ?? connection;
  }
}

import 'package:flutter_application_1/bluetooth/bot_info.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

enum RobotConnectionState {
  connecting,
  fetchingInfo,
  complete,
  disconnected,
  discovering,
  error
}

class RobotConnection {
  final RobotConnectionState state;
  final BotInfo? botInfo;
  final BluetoothConnection? connection;
  final BluetoothDevice? device;
  RobotConnection(this.state, {this.device, this.botInfo, this.connection});
}

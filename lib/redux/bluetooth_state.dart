import 'package:flutter_application_1/util/robot_connection.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothAppState {
  Set<RobotConnection> robotConnections;
  List<BluetoothDevice> bondedDevices;
  bool permissionsAccepted = false;

  BluetoothAppState(
      {required this.robotConnections, this.bondedDevices = const []});
}

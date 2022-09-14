import 'package:flutter_application_1/util/robot_connection.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothStateAction {}

class AddBondedDevicesAction extends BluetoothStateAction {
  List<BluetoothDevice> devices;
  AddBondedDevicesAction(this.devices);
}

class StartBondedDevicesSearch extends BluetoothStateAction {}

class StartAddBotByDevice extends BluetoothStateAction {
  BluetoothDevice device;
  StartAddBotByDevice(this.device);
}

class ErrorAction extends BluetoothStateAction {}

class StartAskForPermissions extends BluetoothStateAction {}

class PermisionsAcceptedAction extends BluetoothStateAction {}

class CompleteBotConnectionAction extends BluetoothStateAction {
  RobotConnection data;
  CompleteBotConnectionAction(this.data);
}

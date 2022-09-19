import 'package:flutter/material.dart';
import 'package:flutter_application_1/bluetooth/bot_info.dart';
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

class StartAskForPermissions extends BluetoothStateAction {
  BuildContext context;
  StartAskForPermissions(this.context);
}

class PermisionsAcceptedAction extends BluetoothStateAction {}

class CompleteBotConnectionAction extends BluetoothStateAction {
  RobotConnection data;
  CompleteBotConnectionAction(this.data);
}

class DeleteBotConnectionAction extends BluetoothStateAction {
  BluetoothDevice deviceOfConnection;
  DeleteBotConnectionAction(this.deviceOfConnection);
}

class StartAddStoredDevices extends BluetoothStateAction {}

class UpdateBotInfoAction extends BluetoothStateAction {
  BluetoothDevice device;
  CompleteBotInfo data;
  UpdateBotInfoAction(this.device, this.data);
}

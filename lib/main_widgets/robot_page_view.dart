import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/robot_menus/unloaded_menu.dart';
import 'package:flutter_application_1/robot_menus/unloaded_menu.dart';
import 'package:flutter_application_1/file_access/file_manager.dart';
import 'package:flutter_application_1/bluetooth/get_bot_info.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import '../error_menus/no_robots_menu.dart';
import '../robot_menus/robot_menu.dart';

enum _DeviceAvailability {
  no,
  maybe,
  yes,
}

class _DeviceWithAvailability {
  BluetoothDevice device;
  _DeviceAvailability availability;
  int? rssi;

  _DeviceWithAvailability(this.device, this.availability, [this.rssi]);
}

class RobotPageView extends StatefulWidget {
  final void Function(String adress) onAdressForgor;
  final bool checkAvalability;
  final Set<String> wantedAdresses;
  final void Function(int) onChangedScreen;
  final TabController controller;

  const RobotPageView({
    Key? key,
    required this.checkAvalability,
    required this.wantedAdresses,
    required this.onAdressForgor,
    required this.onChangedScreen,
    required this.controller,
  }) : super(key: key);

  @override
  State<RobotPageView> createState() => _RobotPageViewState();
}

class _RobotPageViewState extends State<RobotPageView> {
  List<_DeviceWithAvailability> bondedDevices =
      List<_DeviceWithAvailability>.empty(growable: true);
  List<_DeviceWithAvailability> wantedDevices =
      List<_DeviceWithAvailability>.empty(growable: true);
  StreamSubscription<BluetoothDiscoveryResult>? _streamSubscription;
  bool isDiscovering = false;
  @override
  initState() {
    isDiscovering = widget.checkAvalability;
    if (isDiscovering) {
      _startDiscovery();
    }

    FlutterBluetoothSerial.instance
        .getBondedDevices()
        .then((avalibleDevices) => setState(() {
              bondedDevices = avalibleDevices.map((device) {
                return _DeviceWithAvailability(
                    device,
                    widget.checkAvalability
                        ? _DeviceAvailability.maybe
                        : _DeviceAvailability.no);
              }).toList();
            }));

    _streamSubscription!.onDone(() {
      setState(() {
        isDiscovering = false;
      });
    });
  }

  void _startDiscovery() {
    _streamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((event) {
      final index = bondedDevices.indexWhere(
          (element) => event.device.address == element.device.address);
    });
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nonNullAdresses = widget.wantedAdresses
        .where(
          (element) => element != "",
        )
        .toList();

    if (nonNullAdresses.isEmpty) {
      return NoRobotsMenu();
    }

    return TabBarView(
      controller: widget.controller,
      children: nonNullAdresses.map(
        (adress) {
          int deviceIndex = bondedDevices
              .indexWhere((element) => adress == element.device.address);
          if (deviceIndex >= 0) {
            return RobotMenu(
              device: bondedDevices[deviceIndex].device,
              info: BotInfo(false, bondedDevices[deviceIndex].device.name),
              onForget: widget.onAdressForgor,
            );
          }

          return UnloadedMenu(
            address: adress,
            onForget: widget.onAdressForgor,
            headline: 'Trying to connect to $adress',
          );
        },
      ).toList(),
    );
  }
}

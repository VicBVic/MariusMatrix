import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/Semieditables/disconnected_robot_menu.dart';
import 'package:flutter_application_1/Semieditables/missing_menu.dart';
import 'package:flutter_application_1/file_manager.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'Semieditables/robot_menu.dart';

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

  const RobotPageView({
    Key? key,
    required this.checkAvalability,
    required this.wantedAdresses,
    required this.onAdressForgor,
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
    final controller = PageController(
      initialPage: 0,
      keepPage: true,
    );
    //print(widget.wantedAdresses);

    final nonNullAdresses = widget.wantedAdresses
        .where(
          (element) => element != "",
        )
        .toList();

    if (nonNullAdresses.isEmpty) {
      return MissingMenu();
    }

    return PageView(
      controller: controller,
      children: nonNullAdresses.map(
        (adress) {
          int deviceIndex = bondedDevices
              .indexWhere((element) => adress == element.device.address);
          if (deviceIndex >= 0) {
            return ConnectedRobotMenu(
              device: bondedDevices[deviceIndex].device,
              robotName: bondedDevices[deviceIndex].device.name,
              onForget: widget.onAdressForgor,
            );
          }

          return DisconnectedRobotMenu(
            adress: adress,
            onForget: widget.onAdressForgor,
          );
        },
      ).toList(),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/Semieditables/missing_menu.dart';
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
  final bool checkAvalability;

  const RobotPageView({
    Key? key,
    required this.checkAvalability,
  }) : super(key: key);

  @override
  State<RobotPageView> createState() => _RobotPageViewState();
}

class _RobotPageViewState extends State<RobotPageView> {
  List<_DeviceWithAvailability> bondedDevices =
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
        .then((value) => setState(() {
              bondedDevices = value.map((e) {
                return _DeviceWithAvailability(
                    e,
                    widget.checkAvalability
                        ? _DeviceAvailability.maybe
                        : _DeviceAvailability.yes);
              }).toList();
            }));
  }

  void _startDiscovery() {
    _streamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((event) {
      final index = bondedDevices.indexWhere(
          (element) => event.device.address == element.device.address);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = PageController(
      initialPage: 0,
      keepPage: true,
    );
    if (bondedDevices.isEmpty) {
      return const MissingMenu();
    }
    return PageView.builder(
      controller: controller,
      itemBuilder: (context, index) {
        return ConnectedRobotMenu(
          robotName: bondedDevices[index].device.name ??
              bondedDevices[index].device.address,
          device: bondedDevices[index].device,
        );
      },
      itemCount: bondedDevices.length,
    );
  }
}

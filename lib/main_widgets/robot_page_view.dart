import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/bluetooth/blue_broadcast_handler.dart';
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
  List<String> wantedAdresses = List.empty(growable: true);
  @override
  initState() {
    BlueBroadcastHandler.instance
        .addBondedDeviceListener()
        .then((value) => setState(() {}));
    FileManager.instance.getBotAdresses().then((value) {
      setState(() {
        wantedAdresses.addAll(value);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void retry() async {
    BlueBroadcastHandler.instance
        .addBondedDeviceListener()
        .then((value) => setState(() {}));
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
          BluetoothDevice? deviceOfAdress;
          try {
            deviceOfAdress = BlueBroadcastHandler.instance.bondedDevices
                .firstWhere((element) => adress == element.address);
          } catch (e) {
            print("robotPageView cuie $e");
            deviceOfAdress = null;
          }
          if (deviceOfAdress != null) {
            return RobotMenu(
              device: deviceOfAdress,
              info: BotInfo(false, deviceOfAdress.name),
              onForget: widget.onAdressForgor,
            );
          }

          return UnloadedMenu(
            onRetry: retry,
            address: adress,
            onForget: widget.onAdressForgor,
            headline: 'Trying to find bonded device with adress $adress...',
          );
        },
      ).toList(),
    );
  }
}

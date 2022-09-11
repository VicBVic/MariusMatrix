import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/bluetooth/blue_broadcast_handler.dart';
import 'package:flutter_application_1/robot_menus/unloaded_menu.dart';
import 'package:flutter_application_1/robot_menus/unloaded_menu.dart';
import 'package:flutter_application_1/file_access/file_manager.dart';
import 'package:flutter_application_1/bluetooth/bot_info.dart';
import 'package:flutter_application_1/util/robot_connection.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import '../error_menus/no_robots_menu.dart';
import '../robot_menus/loaded_menu.dart';
import '../robot_menus/__robot_menu.dart';

enum _DeviceAvailability {
  no,
  maybe,
  yes,
}

class RobotPageView extends StatelessWidget {
  final bool checkAvalability;
  final Set<String> wantedAdresses;
  final void Function(int) onChangedScreen;
  final TabController controller;

  const RobotPageView({
    Key? key,
    required this.checkAvalability,
    required this.wantedAdresses,
    required this.onChangedScreen,
    required this.controller,
  }) : super(key: key);

  /*void retry() async {
    BlueBroadcastHandler.instance
        .addBondedDeviceListener()
        .then((value) => setState(() {}));
  }*/
  @override
  Widget build(BuildContext context) {
    final List<RobotConnection> robots = List.empty();
    if (robots.isEmpty) {
      return NoRobotsMenu();
    }

    return TabBarView(
      controller: controller,
      children: robots.map(
        (robot) {
          if (robot.state == RobotConnectionState.complete) {
            return LoadedMenu(
              robotConnection: robot,
            );
          }

          return UnloadedMenu(
            robotConnection: robot,
            headline:
                'Trying to find bonded device with adress ${robot.device?.address ?? "idk"}...',
          );
        },
      ).toList(),
    );
  }
}

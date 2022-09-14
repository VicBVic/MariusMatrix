import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/bluetooth/blue_broadcast_handler.dart';
import 'package:flutter_application_1/redux/bluetooth_state.dart';
import 'package:flutter_application_1/robot_menus/unloaded_menu.dart';
import 'package:flutter_application_1/robot_menus/unloaded_menu.dart';
import 'package:flutter_application_1/file_access/file_manager.dart';
import 'package:flutter_application_1/bluetooth/bot_info.dart';
import 'package:flutter_application_1/util/robot_connection.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_redux/flutter_redux.dart';
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
  final void Function(int) onChangedScreen;
  final TabController controller;

  const RobotPageView({
    Key? key,
    required this.checkAvalability,
    required this.onChangedScreen,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<BluetoothAppState>(builder: (context, store) {
      final List<RobotConnection> robots =
          store.state.robotConnections.toList();
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

            String headline = "";
            switch (robot.state) {
              case RobotConnectionState.connecting:
                headline = "Connecting to ${robot.device.name}";
                break;
              case RobotConnectionState.discovering:
                headline =
                    'Trying to find bonded device with adress ${robot.device.address}...';
                break;
              case RobotConnectionState.fetchingInfo:
                headline = 'Getting info of ${robot.device.address}...';
                break;
              default:
                headline = 'Unexpected state of ${robot.device.address}!';
            }

            return UnloadedMenu(robotConnection: robot, headline: headline);
          },
        ).toList(),
      );
    });
  }
}

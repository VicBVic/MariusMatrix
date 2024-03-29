import 'package:flutter/material.dart';
import 'package:flutter_application_1/redux/bluetooth_state.dart';
import 'package:flutter_application_1/robot_menus/unloaded_menu.dart';
import 'package:flutter_application_1/util/robot_connection.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../error_menus/no_robots_menu.dart';
import '../robot_menus/loaded_menu.dart';

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
        return const NoRobotsMenu();
      }
      return TabBarView(
        controller: controller,
        children: robots.map(
          (robot) {
            Widget menu;
            if (robot.state == RobotConnectionState.complete) {
              menu = LoadedMenu(
                robotConnection: robot,
              );
            } else {
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

              menu = UnloadedMenu(robotConnection: robot, headline: headline);
            }
            return AnimatedSwitcher(
                duration: const Duration(milliseconds: 1000),
                child: menu,
                transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: child,
                    ));
          },
        ).toList(),
      );
    });
  }
}

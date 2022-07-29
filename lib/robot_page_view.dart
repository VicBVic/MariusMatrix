import 'package:flutter/material.dart';
import 'robot_menu.dart';

class RobotPageView extends StatelessWidget {
  const RobotPageView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = PageController(
      initialPage: 0,
      keepPage: true,
    );
    return PageView.builder(
      controller: controller,
      itemBuilder: (context, index) {
        return ConnectedRobotMenu(
          robotName: "Marius$index",
        );
      },
      itemCount: 4,
    );
  }
}

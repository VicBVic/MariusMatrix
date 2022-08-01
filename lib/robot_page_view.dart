import 'package:flutter/material.dart';
import 'Semieditables/robot_menu.dart';

class RobotPageView extends StatefulWidget {
  final int basePageCount;
  const RobotPageView({
    this.basePageCount = 0,
    Key? key,
  }) : super(key: key);

  @override
  State<RobotPageView> createState() => _RobotPageViewState();
}

class _RobotPageViewState extends State<RobotPageView> {
  int pageCount = 0;
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
      itemCount: pageCount + widget.basePageCount,
    );
  }
}

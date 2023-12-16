import 'package:flutter/material.dart';

class NoRobotsMenu extends StatelessWidget {
  const NoRobotsMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Text(
            "No robot connected, make sure your robots are paired with your device and then connect to them using the button below."),
      ),
    );
  }
}

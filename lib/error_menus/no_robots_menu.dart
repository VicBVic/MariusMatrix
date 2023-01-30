import 'package:flutter/material.dart';
import 'package:flutter_application_1/extra_widgets/popup_menu.dart';
import '../extra_widgets/menu_button.dart';

class NoRobotsMenu extends StatelessWidget {
  const NoRobotsMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Text(
            "No robot connected, make sure your robots are paired with your device and then connect to them using the button below."),
      ),
    );
  }
}

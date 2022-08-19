import 'package:flutter/material.dart';
import 'package:flutter_application_1/Editables/popup_menu.dart';
import '../Editables/menu_button.dart';

class MissingMenu extends StatelessWidget {
  const MissingMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child:
            Text("no bot connected, use the button below to add a connection."),
      ),
    );
  }
}

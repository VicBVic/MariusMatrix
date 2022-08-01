import 'package:flutter/material.dart';
import 'package:flutter_application_1/Editables/popup_menu.dart';
import '../Editables/menu_button.dart';

class ConnectedRobotMenu extends StatefulWidget {
  final double displayImageHeight = 300;
  final String? connectionId;
  final String robotPhotoPath = 'assets/arduino_STOCK.png';
  final String? robotName;
  const ConnectedRobotMenu({this.robotName, this.connectionId, Key? key})
      : super(key: key);

  @override
  State<ConnectedRobotMenu> createState() => _ConnectedRobotMenuState();
}

class _ConnectedRobotMenuState extends State<ConnectedRobotMenu> {
  Map stateMenuPopupItems = {
    Text("active"): "active",
    Text("inactive"): "inactive",
  };
  var stateMenuSelectedItem;
  Map activationModeMenuPopupItems = {
    Text("manual"): "manual",
    Text("scheduled"): "scheduled",
  };
  var activationMenuSelectedItem;

  late final b1 = Theme.of(context).textTheme.bodyLarge;
  late final headline = Theme.of(context).textTheme.headline2;

  late final List<Widget> menuItems = [
    Padding(
      padding: const EdgeInsets.all(32.0),
      child: Text(
        'Bot ${widget.robotName ?? "Noname"} is connected',
        style: headline,
        textAlign: TextAlign.center,
      ),
    ),
    Image.asset(
      widget.robotPhotoPath,
      fit: BoxFit.scaleDown,
      height: widget.displayImageHeight,
    ),
    MenuButton(
      onPressed: () {
        makeMenuPopup(
            context: context,
            elements: stateMenuPopupItems,
            currentItem: stateMenuSelectedItem,
            onChanged: (value) {
              setState(() {
                print(stateMenuSelectedItem);
                stateMenuSelectedItem = value;
              });
            });
      },
      child: Text('Status: ${stateMenuSelectedItem ?? " not selected"}',
          style: b1),
    ),
    MenuButton(
      onPressed: () {
        makeMenuPopup(
            context: context,
            elements: activationModeMenuPopupItems,
            currentItem: activationMenuSelectedItem,
            onChanged: (value) {
              setState(() {
                activationMenuSelectedItem = value;
              });
            });
      },
      child: Text(
          'Activation Mode: ${activationMenuSelectedItem ?? " not selected"}',
          style: b1),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        itemBuilder: (BuildContext context, int index) => menuItems[index],
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemCount: menuItems.length);
  }
}

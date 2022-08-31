import 'package:flutter/material.dart';
import 'package:flutter_application_1/Editables/popup_menu.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../Editables/menu_button.dart';

class DisconnectedRobotMenu extends StatefulWidget {
  final double displayImageHeight = 300;
  final String adress;
  final String robotPhotoPath = 'assets/arduino_STOCK.png';
  final String? robotName;
  final void Function(String adress) onForget;
  const DisconnectedRobotMenu(
      {this.robotName, required this.adress, Key? key, required this.onForget})
      : super(key: key);

  @override
  State<DisconnectedRobotMenu> createState() => _DisconnectedRobotMenuState();
}

class _DisconnectedRobotMenuState extends State<DisconnectedRobotMenu>
    with AutomaticKeepAliveClientMixin<DisconnectedRobotMenu> {
  bool isActive = false;
  bool isManual = true;
  TimeOfDay scheduledStart = TimeOfDay(hour: 0, minute: 0);
  TimeOfDay scheduledEnd = TimeOfDay(hour: 0, minute: 0);
  @override
  Widget build(BuildContext context) {
    final b1 = Theme.of(context).textTheme.bodyLarge;
    final b0 = Theme.of(context).textTheme.headlineSmall;
    final headline = Theme.of(context).textTheme.headline2;
    final List<Widget> menuItems = [
      Padding(
        padding: const EdgeInsets.all(32.0),
        child: Text(
          'Trying to connect to adress ${widget.adress}...',
          style: headline,
          textAlign: TextAlign.center,
        ),
      ),
      Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            widget.robotPhotoPath,
            fit: BoxFit.scaleDown,
            height: widget.displayImageHeight,
            colorBlendMode: BlendMode.dstIn,
            color: Color.fromARGB(25, 255, 255, 255),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 64.0),
            child: LoadingAnimationWidget.staggeredDotsWave(
                color: Theme.of(context).primaryColor, size: 200),
          ),
        ],
      ),
      ElevatedButton(
        onPressed: () {
          widget.onForget(widget.adress);
        },
        child: Text("Forget"),
        style: ElevatedButton.styleFrom(primary: Colors.red),
      ),
    ];

    return ListView(
      children: menuItems,
    );
  }

  @override
  bool get wantKeepAlive => true;
}

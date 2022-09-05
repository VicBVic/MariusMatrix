import 'package:flutter/material.dart';
import 'package:flutter_application_1/Editables/popup_menu.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../Editables/menu_button.dart';

class UnloadedMenu extends StatefulWidget {
  final double displayImageHeight = 300;
  final String robotPhotoPath = 'assets/arduino_STOCK.png';
  final String headline;
  final String address;
  final void Function(String adress) onForget;
  const UnloadedMenu(
      {Key? key,
      required this.onForget,
      required this.headline,
      required this.address})
      : super(key: key);

  @override
  State<UnloadedMenu> createState() => _UnloadedMenuState();
}

class _UnloadedMenuState extends State<UnloadedMenu>
    with AutomaticKeepAliveClientMixin<UnloadedMenu> {
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
          widget.headline,
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
          widget.onForget(widget.address);
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

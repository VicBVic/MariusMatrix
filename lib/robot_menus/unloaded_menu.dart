import 'package:flutter/material.dart';
import 'package:flutter_application_1/extra_widgets/popup_menu.dart';
import 'package:flutter_application_1/extra_widgets/yes_no_dialog.dart';
import 'package:flutter_application_1/redux/bluetooth_state.dart';
import 'package:flutter_application_1/util/robot_connection.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../extra_widgets/menu_button.dart';
import '../redux/bluetooth_state_actions.dart';

class UnloadedMenu extends StatefulWidget {
  final double displayImageHeight = 300;
  final String robotPhotoPath = 'assets/arduino_STOCK.png';
  final String headline;
  final RobotConnection robotConnection;
  const UnloadedMenu({
    Key? key,
    required this.headline,
    required this.robotConnection,
  }) : super(key: key);

  @override
  State<UnloadedMenu> createState() => _UnloadedMenuState();
}

class _UnloadedMenuState extends State<UnloadedMenu>
    with AutomaticKeepAliveClientMixin<UnloadedMenu> {
  void forgetAddress(store) {
    showDialog(
        context: context,
        builder: (context) => YesNoDialog(
            title: Text("Really forget it?"),
            response: (response) {
              if (response == true) {
                store.dispatch(
                    DeleteBotConnectionAction(widget.robotConnection.device));
              }
            }));
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<BluetoothAppState>(builder: (context, store) {
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
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 64.0),
            child: LoadingAnimationWidget.discreteCircle(
                color: Theme.of(context).primaryColor, size: 200),
          ),
        ),
        //Divider(),
        Padding(
          padding: const EdgeInsets.fromLTRB(32.0, 64.0, 32.0, 0.0),
          child: ElevatedButton(
            onPressed: () => store
                .dispatch(StartAddBotByDevice(widget.robotConnection.device)),
            child: Text("Retry"),
            style: ElevatedButton.styleFrom(primary: Colors.blue),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(32.0, 0.0, 32.0, 0.0),
          child: ElevatedButton(
            onPressed: () => forgetAddress(store),
            child: Text("Forget"),
            style: ElevatedButton.styleFrom(primary: Colors.red),
          ),
        ),
      ];

      return ListView(
        children: menuItems,
      );
    });
  }

  @override
  bool get wantKeepAlive => true;
}

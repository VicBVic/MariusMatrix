import 'package:flutter/material.dart';
import 'package:flutter_application_1/extra_widgets/yes_no_dialog.dart';
import 'package:flutter_application_1/redux/bluetooth_state.dart';
import 'package:flutter_application_1/util/robot_connection.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
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
    with TickerProviderStateMixin {
  late AnimationController _reloadController;
  void forgetAddress(store) {
    showDialog(
        context: context,
        builder: (context) => YesNoDialog(
            title: const Text("Really forget it?"),
            response: (response) {
              if (response == true) {
                store.dispatch(
                    DeleteBotConnectionAction(widget.robotConnection.device));
              }
            }));
  }

  @override
  void initState() {
    //_reloadController.dispose();
    _reloadController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 3),
        reverseDuration: const Duration(seconds: 3))
      ..repeat();
    super.initState();
  }

  @override
  void dispose() {
    _reloadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<BluetoothAppState>(builder: (context, store) {
      final b1 = Theme.of(context).textTheme.bodyLarge;
      final headline = Theme.of(context).textTheme.displayMedium;

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
            child: RotationTransition(
              turns: CurvedAnimation(
                  parent: _reloadController,
                  curve: Curves.decelerate,
                  reverseCurve: (Curves.decelerate)),
              child: LoadingAnimationWidget.discreteCircle(
                  color: Theme.of(context).primaryColor, size: 200),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "If the problem persists, try unplugging your robot and plugging it back in again.",
            textAlign: TextAlign.center,
            style: b1?.copyWith(color: Colors.black12),
          ),
        ),
        //Divider(),
        Padding(
          padding: const EdgeInsets.fromLTRB(32.0, 64.0, 32.0, 0.0),
          child: ElevatedButton(
            onPressed: () => store
                .dispatch(StartAddBotByDevice(widget.robotConnection.device)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text("Retry"),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(32.0, 0.0, 32.0, 0.0),
          child: ElevatedButton(
            onPressed: () => forgetAddress(store),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Forget"),
          ),
        ),
      ];

      return ListView(
        children: menuItems,
      );
    });
  }

  bool get wantKeepAlive => true;
}

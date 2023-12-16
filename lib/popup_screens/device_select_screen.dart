
import 'package:flutter/material.dart';
import 'package:flutter_application_1/bluetooth/blue_broadcast_handler.dart';
import 'package:flutter_application_1/redux/bluetooth_state.dart';
import 'package:flutter_application_1/redux/bluetooth_state_actions.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:async/async.dart';

class DeviceSelectScreen extends StatefulWidget {
  final Duration connectionTimeLimit;
  final bool checkActivity;
  const DeviceSelectScreen(
      {Key? key,
      required this.checkActivity,
      required this.connectionTimeLimit})
      : super(key: key);

  @override
  State<DeviceSelectScreen> createState() => _DeviceSelectScreenState();
}

class _DeviceSelectScreenState extends State<DeviceSelectScreen>
    with TickerProviderStateMixin {
  late AnimationController _reloadController;
  @override
  void initState() {
    _reloadController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      animationBehavior: AnimationBehavior.preserve,
      reverseDuration: const Duration(seconds: 1),
    );
    // _reloadController.stop();
    super.initState();
  }

  @override
  void dispose() {
    //_reloadController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // _reloadController.stop();
    return StoreBuilder<BluetoothAppState>(builder: ((context, store) {
      store.onChange.listen((event) {
        _reloadController.stop();
      });
      List<BluetoothDevice> devices = store.state.bondedDevices;

      List<Widget> list = devices.map((e) {
        bool used = store.state.robotConnections
            .where((element) => element.device == e)
            .isNotEmpty;

        return ListTile(
            trailing: used ? const Icon(Icons.check) : null,
            title: Text(e.name ?? "Missingno"),
            subtitle: Text(e.address),
            leading: null,
            onTap: used
                ? null
                : () async {
                    CancelableOperation connectOperation =
                        CancelableOperation.fromFuture(BlueBroadcastHandler
                            .instance
                            .getConnectionToAdress(e.address));
                    BluetoothConnection? connection = await showDialog(
                        barrierDismissible: true,
                        context: context,
                        builder: (context) => FutureBuilder(
                              builder: ((context, snapshot) {
                                if (snapshot.hasError) {
                                  return const SimpleDialog(
                                    title: Text("Error when connecting!"),
                                    titlePadding: EdgeInsets.all(16.0),
                                  );
                                }
                                if (snapshot.hasData) {
                                  Navigator.pop(context, snapshot.data);
                                }
                                return SimpleDialog(
                                  title:
                                      const Text("Waiting for connection..."),
                                  titlePadding: const EdgeInsets.all(16.0),
                                  children: [
                                    TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("Cancel"))
                                  ],
                                );
                              }),
                              future: connectOperation.value,
                            ));
                    connectOperation.cancel();
                    if (connection == null) return;
                    CancelableOperation isBotOperation =
                        CancelableOperation.fromFuture(BlueBroadcastHandler
                            .instance
                            .isBotTest(connection));
                    bool? isBot = await showDialog(
                        barrierDismissible: true,
                        context: context,
                        builder: (context) => FutureBuilder(
                              builder: ((context, snapshot) {
                                if (snapshot.hasError) {
                                  return const SimpleDialog(
                                    title: Text(
                                        "Error when checking is device is bot!"),
                                    titlePadding: EdgeInsets.all(16.0),
                                  );
                                }
                                if (snapshot.hasData) {
                                  Navigator.pop(context, snapshot.data);
                                }
                                return SimpleDialog(
                                  title: const Text("Checking if device is bot.."),
                                  titlePadding: const EdgeInsets.all(16.0),
                                  children: [
                                    TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("Cancel"))
                                  ],
                                );
                              }),
                              future: isBotOperation.value,
                            ));
                    isBotOperation.cancel();
                    print("$connection $isBot");
                    if (isBot ?? false) {
                      store.dispatch(StartAddBotByDevice(e));
                      Navigator.pop(context);
                    }
                    //if (connection is BluetoothConnection) {}
                  });
      }).toList();
      return Scaffold(
        appBar: AppBar(
          title: const Text('Choose a device:'),
          actions: [
            RotationTransition(
              turns: CurvedAnimation(
                  parent: _reloadController,
                  curve: Curves.decelerate,
                  reverseCurve: (Curves.decelerate)),
              child: IconButton(
                onPressed: () {
                  _reloadController.reset();
                  _reloadController.repeat();
                  store.dispatch(StartBondedDevicesSearch());
                },
                icon: const Icon(Icons.replay),
              ),
            )
          ],
        ),
        body: ListView(
          children: list,
        ),
      );
    }));
  }
}

class ConnectingToBotDialog extends StatelessWidget {
  final bool isConnected;
  const ConnectingToBotDialog({
    Key? key,
    required this.isConnected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String title = "awaiting response from bot..";
    String buttonTitle = "Cancel";
    if (isConnected) {
      title = "Finished!";
      buttonTitle = "done";
    }
    return SimpleDialog(
      title: Text(title),
      titlePadding: const EdgeInsets.all(32.0),
      children: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(buttonTitle))
      ],
    );
  }
}

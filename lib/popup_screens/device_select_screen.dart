import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/extra_widgets/popup_menu.dart';
import 'package:flutter_application_1/bluetooth/blue_broadcast_handler.dart';
import 'package:flutter_application_1/bluetooth/is_bot.dart';
import '../extra_widgets/menu_button.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class DeviceSelectScreen extends StatefulWidget {
  final Duration connectionTimeLimit;
  final bool checkActivity;
  final Set<String> usedAdresses;
  final void Function(BluetoothDevice) onSelected;
  const DeviceSelectScreen(
      {Key? key,
      required this.checkActivity,
      required this.onSelected,
      required this.usedAdresses,
      required this.connectionTimeLimit})
      : super(key: key);

  @override
  State<DeviceSelectScreen> createState() => _DeviceSelectScreenState();
}

class _DeviceSelectScreenState extends State<DeviceSelectScreen> {
  List<BluetoothDevice> devices = List<BluetoothDevice>.empty(growable: true);

  @override
  void initState() {
    super.initState();

    FlutterBluetoothSerial.instance
        .getBondedDevices()
        .then((value) => setState(() {
              devices = value;
            }));
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> list = devices.map((e) {
      bool used = widget.usedAdresses.contains(e.address);
      return ListTile(
          trailing: used ? const Icon(Icons.check) : null,
          title: Text(e.name ?? "Missingno"),
          leading: null,
          onTap: used
              ? null
              : () async {
                  String snackBarTitle = "Success!";
                  bool failed = false;
                  bool canceled = false;
                  await showDialog(
                      barrierDismissible: true,
                      context: context,
                      builder: (context) => FutureBuilder(
                          future: BlueBroadcastHandler.instance
                              .addAddress(e.address)
                              .onError((error, stackTrace) {
                            print("se mai intampla $error");
                            failed = true;
                            return false;
                          }),
                          builder: (context, snapshot) {
                            print("${snapshot.hasError} ${snapshot.hasData}");
                            if (snapshot.hasError || snapshot.hasData) {
                              Navigator.pop(context);
                            }
                            return SimpleDialog(
                              title: const Text("Waiting for connection..."),
                              titlePadding: EdgeInsets.all(32.0),
                              children: [
                                TextButton(
                                    onPressed: () {
                                      canceled = true;
                                      Navigator.pop(context);
                                    },
                                    child: Text("cancel"))
                              ],
                            );
                          }));
                  if (failed) {
                    snackBarTitle = "Error when connecting!";
                  } else if (canceled) {
                    snackBarTitle = "Canceled connection!";
                  }
                  if (failed || canceled) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(snackBarTitle)));
                    return;
                  }
                  bool isBot = await showDialog(
                      barrierDismissible: true,
                      context: context,
                      builder: (context) => FutureBuilder(
                          future:
                              isBotTest(e.address).onError((error, stackTrace) {
                            print("se mai intampla $error");
                            failed = true;
                            return false;
                          }),
                          builder: (context, snapshot) {
                            if (snapshot.hasError || snapshot.hasData)
                              Navigator.pop(context, snapshot.data ?? false);
                            return SimpleDialog(
                              title: Text("Checking if device is robot..."),
                              titlePadding: const EdgeInsets.all(32.0),
                              children: [
                                TextButton(
                                    onPressed: () {
                                      canceled = true;
                                      Navigator.pop(context, false);
                                    },
                                    child: Text("cancel"))
                              ],
                            );
                          }));

                  if (failed) {
                    snackBarTitle =
                        "Error occured when checking if device is robot!";
                  } else if (canceled) {
                    snackBarTitle = "Canceled detection!";
                  } else if (!isBot) {
                    snackBarTitle = "Device is not bot!";
                  }
                  if (failed || canceled || !isBot) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(snackBarTitle)));
                    return;
                  }
                  Navigator.pop(context);
                  widget.onSelected(e);
                  return;
                });
    }).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose a device:'),
      ),
      body: Column(
        children: list,
      ),
    );
  }
}

class ConnectingToBotDialog extends StatelessWidget {
  final String address;
  Future<bool> isAddressBot;
  ConnectingToBotDialog({
    Key? key,
    required this.address,
    required this.isAddressBot,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: isAddressBot,
        builder: (context, snapshot) {
          String title = "awaiting response from bot..";
          String buttonTitle = "Cancel";
          if (snapshot.connectionState == ConnectionState.done) {
            title = "Finished!";
            buttonTitle = "done";
          }
          return SimpleDialog(
            title: Text(title),
            titlePadding: const EdgeInsets.all(32.0),
            children: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context, snapshot.data);
                  },
                  child: Text(buttonTitle))
            ],
          );
        });
  }
}

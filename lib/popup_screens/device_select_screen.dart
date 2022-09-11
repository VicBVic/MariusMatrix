import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/extra_widgets/popup_menu.dart';
import 'package:flutter_application_1/bluetooth/blue_broadcast_handler.dart';
import 'package:flutter_application_1/util/robot_connection.dart';
import '../extra_widgets/menu_button.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class DeviceSelectScreen extends StatefulWidget {
  final Duration connectionTimeLimit;
  final bool checkActivity;
  final Set<String> usedAdresses;
  const DeviceSelectScreen(
      {Key? key,
      required this.checkActivity,
      required this.usedAdresses,
      required this.connectionTimeLimit})
      : super(key: key);

  @override
  State<DeviceSelectScreen> createState() => _DeviceSelectScreenState();
}

class _DeviceSelectScreenState extends State<DeviceSelectScreen> {
  @override
  void initState() {}

  @override
  Widget build(BuildContext context) {
    List<BluetoothDevice> devices = List<BluetoothDevice>.empty();

    List<Widget> list = devices.map((e) {
      bool used = widget.usedAdresses.contains(e.address);
      return ListTile(
          trailing: used ? const Icon(Icons.check) : null,
          title: Text(e.name ?? "Missingno"),
          subtitle: Text(e.address),
          leading: null,
          onTap: used
              ? null
              : () async => await showDialog(
                  barrierDismissible: true,
                  context: context,
                  builder: (context) => ConnectingToBotDialog(
                        isConnected: false,
                      )));
    }).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose a device:'),
      ),
      body: ListView(
        children: list,
      ),
    );
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

class _DeviceListTile extends StatelessWidget {
  final BluetoothDevice device;
  const _DeviceListTile({required this.device, super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

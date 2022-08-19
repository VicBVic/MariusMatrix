import 'package:flutter/material.dart';
import 'package:flutter_application_1/Editables/popup_menu.dart';
import '../Editables/menu_button.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class DeviceSelectScreen extends StatefulWidget {
  final bool checkActivity;
  final void Function(BluetoothDevice) onSelected;
  const DeviceSelectScreen(
      {Key? key, required this.checkActivity, required this.onSelected})
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
    List<Widget> list = devices
        .map((e) => ListTile(
              title: Text(e.name ?? "Missingno"),
              onTap: () {
                Navigator.pop(context);
                widget.onSelected(e);
              },
            ))
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose a device:'),
      ),
      body: Column(
        children: list,
      ),
    );
  }
}

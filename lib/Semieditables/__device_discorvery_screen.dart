import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/Editables/popup_menu.dart';
import '../Editables/menu_button.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class DeviceDiscoveryScreen extends StatefulWidget {
  final bool start;
  final void Function(BluetoothDevice) onSelected;
  const DeviceDiscoveryScreen(
      {Key? key, required this.start, required this.onSelected})
      : super(key: key);

  @override
  State<DeviceDiscoveryScreen> createState() => _DeviceDiscoveryScreenState();
}

class _DeviceDiscoveryScreenState extends State<DeviceDiscoveryScreen> {
  StreamSubscription<BluetoothDiscoveryResult>? _streamSubscription;
  List<BluetoothDiscoveryResult> results =
      List<BluetoothDiscoveryResult>.empty(growable: true);
  bool isDiscovering = false;

  @override
  void initState() {
    super.initState();

    isDiscovering = widget.start;
    if (isDiscovering) (startDiscovery());
  }

  void restartDiscovery() {
    setState(() {
      isDiscovering = true;
      results.clear();
    });
    startDiscovery();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  void startDiscovery() {
    print(results);
    _streamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((event) {
      if (event.device.type == BluetoothDeviceType.classic)
        setState(() {
          final deviceIndex = results.indexWhere(
              (element) => event.device.address == element.device.address);
          print(deviceIndex);
          if (deviceIndex >= 0)
            results[deviceIndex] = event;
          else {
            results.add(event);
            print("yes added");
          }
        });
    });

    _streamSubscription!.onDone(() {
      setState(() {
        print("dope");
        isDiscovering = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
              isDiscovering ? "Discovering devices..." : "Discovered devices"),
          actions: [
            isDiscovering
                ? FittedBox(
                    child: Container(
                      margin: new EdgeInsets.all(16.0),
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  )
                : IconButton(
                    icon: Icon(Icons.replay),
                    onPressed: restartDiscovery,
                  )
          ]),
      body: Column(
        children: results
            .map(
              (e) => ListTile(
                title: Text(e.device.name ?? e.device.address),
                trailing: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.wifi,
                      color: () {
                        return e.rssi >= -50
                            ? Colors.green
                            : e.rssi >= -60
                                ? Colors.yellow
                                : e.rssi >= -70
                                    ? Colors.orange
                                    : Colors.red;
                      }(),
                    ),
                    Text("${e.rssi.toString()} dBm"),
                  ],
                ),
                leading: const Icon(Icons.devices),
                subtitle: Text(e.device.address),
              ),
            )
            .toList(),
      ),
    );
  }
}

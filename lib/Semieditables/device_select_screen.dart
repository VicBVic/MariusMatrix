import 'package:flutter/material.dart';
import 'package:flutter_application_1/Editables/popup_menu.dart';
import 'package:flutter_application_1/util/is_bot.dart';
import '../Editables/menu_button.dart';
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
        trailing: used ? Icon(Icons.check) : null,
        title: Text(e.name ?? "Missingno"),
        leading: null,
        onTap: used
            ? null
            : () async {
                BluetoothConnection? connection = await showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) => FutureBuilder(
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              Navigator.of(context).pop(snapshot.data);
                            }
                            return SimpleDialog(
                              title: Text("Waiting for connection..."),
                              titlePadding: EdgeInsets.all(32.0),
                              children: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("Cancel"))
                              ],
                            );
                          },
                          future: BluetoothConnection.toAddress(e.address),
                        ));
                if (connection == null) return;
                bool? isBot = await showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return ConnectingToBotDialog(
                        address: e.address,
                        isAddressBot: () async {
                          bool ans = await isBotTest(
                              connection, widget.connectionTimeLimit);
                          print("found $ans");
                          return ans;
                        }(),
                      );
                    });
                connection.dispose();
                if (isBot ?? false) {
                  widget.onSelected(e);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error when connecting!")));
                }
              },
      );
    }).toList();
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
            titlePadding: EdgeInsets.all(32.0),
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

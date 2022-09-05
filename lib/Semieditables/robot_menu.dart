import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/Editables/popup_menu.dart';
import 'package:flutter_application_1/Semieditables/loaded_menu.dart';
import 'package:flutter_application_1/Semieditables/unloaded_menu.dart';
import 'package:flutter_application_1/util/get_bot_info.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import '../Editables/menu_button.dart';

class RobotMenu extends StatefulWidget {
  final void Function(String adress) onForget;
  final double displayImageHeight = 300;
  final BluetoothDevice device;
  final String robotPhotoPath = 'assets/arduino_STOCK.png';
  final BotInfo info;
  const RobotMenu(
      {required this.device, key, required this.onForget, required this.info})
      : super(key: key);

  @override
  State<RobotMenu> createState() => _RobotMenuState();
}

class _RobotMenuState extends State<RobotMenu>
    with AutomaticKeepAliveClientMixin<RobotMenu> {
  BluetoothConnection? botConnection;
  BotInfo? botInfo;
  bool connected = false;

  void updateConnection(BluetoothConnection connection) async {
    print("connection $connection");
    setState(() {
      connected = true;
      botConnection = connection;
    });
    if (connection == null)
      throw ("Falied to connect, disconnected remotely! Maybe cuz an instance of connection was not disposed before, idk");
    BotInfo buffer = await getConnectionBotInfo(connection);
    setState(() {
      botInfo = buffer;
    });
    if (botInfo == null) throw ("Failed to fetch bot info, idk why");
  }

  @override
  void initState() {
    Future getConnection;
    getConnection = BluetoothConnection.toAddress(widget.device.address);
    getConnection.onError((error, stackTrace) {
      print(error);
      setState(() {
        connected = true;
        botConnection = null;
      });
      return BluetoothConnection.toAddress(widget.device.address);
    }).then((connection) => updateConnection(connection));

    getConnection.then((connection) => updateConnection(connection));

    super.initState();
  }

  @override
  void dispose() {
    botConnection?.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String headline = "";
    if (!connected) {
      headline =
          "Connecting to ${widget.device.name ?? widget.device.address}...";
    } else {
      if (botConnection != null) {
        headline =
            "Fetching info from ${widget.device.name ?? widget.device.address}...";
      } else {
        headline =
            "Error connecting to ${widget.device.name ?? widget.device.address}, reloading...";
      }
    }
    if (botInfo == null) {
      return UnloadedMenu(
          onForget: widget.onForget,
          headline: headline,
          address: widget.device.address);
    }
    return LoadedMenu(
        info: botInfo!, onForget: widget.onForget, device: widget.device);
  }

  @override
  bool get wantKeepAlive => true;
}

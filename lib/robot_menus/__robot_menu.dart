/*import 'package:async/async.dart';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/extra_widgets/popup_menu.dart';
import 'package:flutter_application_1/robot_menus/loaded_menu.dart';
import 'package:flutter_application_1/robot_menus/unloaded_menu.dart';
import 'package:flutter_application_1/Bluetooth/blue_broadcast_handler.dart';
import 'package:flutter_application_1/Bluetooth/connection_to_commands.dart';
import 'package:flutter_application_1/bluetooth/bot_info.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import '../extra_widgets/menu_button.dart';

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
  late CancelableOperation connectFetchOperation;
  BotInfo? botInfo;
  bool hasError = false;
  bool connected = false;

  @override
  void initState() {
    super.initState();
    tryConnect();
  }

  void tryConnect() async {
    connectFetchOperation = CancelableOperation.fromFuture(
        connect().then((v) => fetch()),
        onCancel: () => print("robotMenuState gata Vere m-om oprit"));
  }

  void retryConnect() async {
    setState(() {
      connectFetchOperation.cancel();
      connected = false;
      botInfo = null;
      tryConnect();
    });
  }

  Future<void> connect() async {
    await BlueBroadcastHandler.instance.addAddress(widget.device.address);
    setState(() {
      connected = true;
    });
  }

  Future<void> fetch() async {
    BotInfo buffer = await getAddressInfo(widget.device.address);
    setState(() {
      botInfo = buffer;
    });
  }

  @override
  void dispose() {
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
      if (!hasError) {
        headline =
            "Fetching info from ${widget.device.name ?? widget.device.address}...";
      } else {
        headline =
            "Error connecting to ${widget.device.name ?? widget.device.address}, reloading...";
      }
    }
    if (botInfo == null) {
      return UnloadedMenu(
          onRetry: retryConnect,
          onForget: widget.onForget,
          headline: headline,
          address: widget.device.address);
    }
    return LoadedMenu(
        info: botInfo!, onForget: widget.onForget, device: widget.device);
  }

  @override
  bool get wantKeepAlive => true;
}*/

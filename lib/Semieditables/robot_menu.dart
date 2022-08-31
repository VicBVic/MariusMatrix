import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/Editables/popup_menu.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import '../Editables/menu_button.dart';

class ConnectedRobotMenu extends StatefulWidget {
  final void Function(String adress) onForget;
  final double displayImageHeight = 300;
  final BluetoothDevice device;
  final String robotPhotoPath = 'assets/arduino_STOCK.png';
  final String? robotName;
  const ConnectedRobotMenu(
      {this.robotName, required this.device, key, required this.onForget})
      : super(key: key);

  @override
  State<ConnectedRobotMenu> createState() => _ConnectedRobotMenuState();
}

class _ConnectedRobotMenuState extends State<ConnectedRobotMenu>
    with AutomaticKeepAliveClientMixin<ConnectedRobotMenu> {
  bool isActive = false;
  bool isManual = true;
  bool isAudioPlaying = false;
  TimeOfDay scheduledStart = TimeOfDay(hour: 0, minute: 0);
  TimeOfDay scheduledEnd = TimeOfDay(hour: 0, minute: 0);
  String? audioName;
  DeviceFileSource? audioSource;
  @override
  Widget build(BuildContext context) {
    if (!isManual) isActive = false;
    final b1 = Theme.of(context).textTheme.bodyLarge;
    final b0 = Theme.of(context).textTheme.headlineSmall;
    final headline = Theme.of(context).textTheme.headline2;
    final player = AudioPlayer();
    final List<Widget> menuItems = [
      Padding(
        padding: const EdgeInsets.all(32.0),
        child: Text(
          'Bot ${widget.robotName ?? "Noname"} is connected',
          style: headline,
          textAlign: TextAlign.center,
        ),
      ),
      Image.asset(
        widget.robotPhotoPath,
        fit: BoxFit.scaleDown,
        height: widget.displayImageHeight,
      ),
      Divider(),
      ListTile(
        enabled: isManual,
        title: Text(
          "${widget.robotName ?? "Noname"} is currently ${isActive ? "ON" : "OFF"}",
          style: b0?.copyWith(color: (isActive ? Colors.green : Colors.red)),
          //style: b1,
          textAlign: TextAlign.center,
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          child: Container(
            padding: const EdgeInsets.all(32.0),
            child: Text(
              "Turn ${isActive ? "off" : "on"}",
            ),
          ),
          onPressed: !isManual
              ? null
              : () {
                  setState(() {
                    isActive = !isActive;
                  });
                },
          /*style: ElevatedButton.styleFrom(
              primary: isActive ? Colors.green : Colors.red),*/
        ),
      ),
      Divider(),
      SwitchListTile(
        value: isManual,
        title: Text("Activation mode: ${isManual ? "Manual" : "Scheduled"}"),
        onChanged: (value) => setState(() {
          isManual = value;
        }),
      ),
      Divider(),
      ListTile(
        leading: Icon(Icons.arrow_forward_ios),
        title: Text("Scheduled activation time: "),
        trailing: Text(scheduledStart.format(context)),
        enabled: !isManual,
        onTap: () {
          //print("pls animate");
          showTimePicker(
            context: context,
            initialTime: scheduledStart,
          ).then((value) =>
              setState(() => scheduledStart = value ?? scheduledStart));
        },
      ),
      ListTile(
        leading: Icon(Icons.arrow_forward_ios),
        title: Text("Scheduled deactivation time: "),
        trailing: Text(scheduledEnd.format(context)),
        enabled: !isManual,
        onTap: () {
          showTimePicker(
            context: context,
            initialTime: scheduledEnd,
          ).then(
              (value) => setState(() => scheduledEnd = value ?? scheduledEnd));
        },
      ),
      Divider(),
      ListTile(
        title: Text("Current alarm:"),
        subtitle: Text(audioName ?? "Musca.mp3"),
        trailing: ElevatedButton(
          child: Text("Change"),
          onPressed: () async {
            FilePickerResult? result =
                await FilePicker.platform.pickFiles(type: FileType.audio);
            if (result != null) {
              setState(() {
                audioSource = DeviceFileSource(result.paths.first!);
                audioName = result.names.first;
              });
            }
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
            onPressed: () async {
              setState(() {
                isAudioPlaying = !isAudioPlaying;
                isAudioPlaying
                    ? player.play(audioSource!)
                    : player.setVolume(0.0);
              });
            },
            child: Text(isAudioPlaying ? "Stop" : "Test")),
      ),
      Divider(),
      ListTile(
          title: Text(
        "Other info",
        textAlign: TextAlign.center,
      )),
      Padding(padding: EdgeInsets.symmetric(vertical: 32.0)),
      Divider(),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 64.0),
        child: ElevatedButton(
          onPressed: () {
            widget.onForget(widget.device.address);
          },
          child: Text("Forget"),
          style: ElevatedButton.styleFrom(primary: Colors.red),
        ),
      ),
    ];
    return ListView(
      children: menuItems,
    );
  }

  @override
  bool get wantKeepAlive => true;
}

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_application_1/bluetooth/alert_manager.dart';
import 'package:flutter_application_1/bluetooth/blue_broadcast_handler.dart';
import 'package:flutter_application_1/bluetooth/bot_info.dart';
import 'package:flutter_application_1/util/minutes_to_time_of_day.dart';
import 'package:flutter_application_1/util/robot_connection.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../popup_screens/alert_screen.dart';

const String untriggerCommand = "Untrigger\n";

const int musicFileNamesLen = 4;
const Map<int, String> musicFileNames = {
  0: "muzica",
  1: "muzichie",
  2: "descalta-te",
  3: "jandarmeria"
};

class LoadedMenu extends StatelessWidget {
  final RobotConnection robotConnection;
  final double displayImageHeight = 500;
  final String robotPhotoPath = 'assets/Marius.jpeg';
  const LoadedMenu({
    Key? key,
    required this.robotConnection,
  }) : super(key: key);
  //TODO: implementea-za prostiile astea cu Redux
  void toggleBotOffOn() {}
  void toggleBotManSched(value) {}
  void pickStartTime() {}
  void pickEndTime() {}
  void pickAlarm() {}
  void testAlarm() {}
  void changeBotName() {}
  void forgetAddress() {}

  @override
  Widget build(BuildContext context) {
    CompleteBotInfo info = CompleteBotInfo.fromBotInfo(robotConnection.botInfo);

    final b1 = Theme.of(context).textTheme.bodyLarge;
    final b0 = Theme.of(context).textTheme.headlineSmall;
    final headline = Theme.of(context).textTheme.headline2;

    final List<Widget> menuItems = [
      ListTile(
        enabled: info.isActive,
        title: Text(
          "${info.name} is currently ${info.isActive ? "ON" : "OFF"}",
          style:
              b0?.copyWith(color: (info.isActive ? Colors.green : Colors.red)),
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
                "Turn ${info.isActive ? "off" : "on"}",
              ),
            ),
            onPressed: !info.isManual ? null : toggleBotOffOn),
      ),
      Divider(),
      SwitchListTile(
          value: info.isManual,
          title: Text(
              "Activation mode: ${info.isManual ? "Manual" : "Scheduled"}"),
          onChanged: (value) => toggleBotManSched),
      Divider(),
      ListTile(
        leading: Icon(Icons.arrow_forward_ios),
        title: Text("Scheduled activation time: "),
        trailing:
            Text(minutesToTimeOfDay(info.startTimeMinutes).format(context)),
        enabled: !info.isManual,
        onTap: pickStartTime,
      ),
      ListTile(
        leading: Icon(Icons.arrow_forward_ios),
        title: Text("Scheduled deactivation time: "),
        trailing: Text(minutesToTimeOfDay(info.endTimeMinutes).format(context)),
        enabled: !info.isManual,
        onTap: pickEndTime,
      ),
      Divider(),
      EditableElementListTile(
        title: "Current alarm:",
        onPressed: pickAlarm,
        value: info.musicFileName,
      ),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(onPressed: testAlarm, child: Text("Test")),
      ),
      Divider(),
      ListTile(
          title: Text(
        "Other info",
        textAlign: TextAlign.center,
      )),
      EditableElementListTile(
        title: "Current robot name:",
        onPressed: changeBotName,
        value: info.name,
      ),
      Divider(),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 64.0),
        child: ElevatedButton(
          onPressed: forgetAddress,
          child: Text("Forget"),
          style: ElevatedButton.styleFrom(primary: Colors.red),
        ),
      ),
    ];
    final Widget titleBox = Stack(
      fit: StackFit.expand,
      children: [
        Align(
          alignment: Alignment.bottomCenter,
          child: Image.asset(
            robotPhotoPath,
            fit: BoxFit.cover,
            width: displayImageHeight,
            //height: widget.displayImageHeight,
          ),
        ),
        Container(
          alignment: Alignment.bottomCenter,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Colors.black.withAlpha(0),
                Theme.of(context).scaffoldBackgroundColor.withAlpha(57),
                Theme.of(context).scaffoldBackgroundColor,
              ],
            ),
          ),
        ),
      ],
    );
    return CustomScrollView(slivers: () {
      List<Widget> slivers = List<Widget>.empty(growable: true);
      slivers.add(
        SliverAppBar(
          flexibleSpace: FlexibleSpaceBar(
            background: titleBox,
            centerTitle: true,
            title: Text(
              'Bot ${info.name == '' ? "Noname" : info.name} is connected',
              style: b0?.copyWith(color: Colors.black),
              textAlign: TextAlign.center,
            ),
            collapseMode: CollapseMode.pin,
            expandedTitleScale: 1.7,
          ),
          expandedHeight: displayImageHeight,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          //foregroundColor: Colors.black,
          surfaceTintColor: Colors.black,
        ),
      );
      slivers.addAll(menuItems.map((e) => SliverToBoxAdapter(child: e)));
      return slivers;
    }());
  }
}

class EditableElementListTile extends StatelessWidget {
  final value;
  final void Function() onPressed;
  final String title;
  const EditableElementListTile(
      {required this.title,
      required this.value,
      required this.onPressed,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text("${value ?? "Musca.mp3"}"),
      trailing: ElevatedButton(
        onPressed: onPressed,
        child: const Text("Change"),
      ),
    );
  }
}

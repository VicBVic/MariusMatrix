import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_application_1/bluetooth/alert_manager.dart';
import 'package:flutter_application_1/bluetooth/blue_broadcast_handler.dart';
import 'package:flutter_application_1/bluetooth/get_bot_info.dart';
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

class LoadedMenu extends StatefulWidget {
  final BotInfo info;
  final void Function(String adress) onForget;
  final double displayImageHeight = 500;
  final BluetoothDevice device;
  final String robotPhotoPath = 'assets/Marius.jpeg';
  const LoadedMenu(
      {Key? key,
      required this.info,
      required this.onForget,
      required this.device})
      : super(key: key);

  @override
  State<LoadedMenu> createState() => _LoadedMenuState();
}

class _LoadedMenuState extends State<LoadedMenu> {
  late bool isManual = widget.info.isManual ?? false;
  late bool isActive = widget.info.isActive ?? false;
  bool isAudioPlaying = false;
  late BotInfo info;
  late StreamSubscription<String> alertSubscription;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  @override
  void initState() {
    // TODO: implement initState
    info = widget.info;
    alertSubscription = BlueBroadcastHandler.instance
        .getAlertStream(widget.device.address,
            info.name == null || info.name == '' ? " Noname" : info.name!)
        .listen((name) async {
      print("foundYa");
      await Navigator.of(context)
          .push(MaterialPageRoute(
              builder: (context) => AlertScreen(botName: name)))
          .then((value) async {
        const AndroidNotificationDetails androidPlatformChannelSpecifics =
            AndroidNotificationDetails('your channel id', 'your channel name',
                channelDescription: 'your channel description',
                importance: Importance.max,
                priority: Priority.high,
                ticker: 'ticker');
        const NotificationDetails platformChannelSpecifics =
            NotificationDetails(android: androidPlatformChannelSpecifics);
        await flutterLocalNotificationsPlugin.show(
            0, 'plain title', 'plain body', platformChannelSpecifics,
            payload: 'item x');
        super.initState();
        return;
      });
      BlueBroadcastHandler.instance
          .printMessage(widget.device.address, untriggerCommand);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    alertSubscription.pause();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("active ${info.isActive}");
    //if (!isManual) isActive = false;

    final b1 = Theme.of(context).textTheme.bodyLarge;
    final b0 = Theme.of(context).textTheme.headlineSmall;
    final headline = Theme.of(context).textTheme.headline2;

    final player = AudioPlayer();
    TimeOfDay scheduledStart = info.startTimeMinutes == null
        ? TimeOfDay.now()
        : TimeOfDay(
            minute: info.startTimeMinutes! % 60,
            hour: info.startTimeMinutes! ~/ 60);
    TimeOfDay scheduledEnd = info.endTimeMinutes == null
        ? TimeOfDay.now()
        : TimeOfDay(
            minute: info.endTimeMinutes! % 60,
            hour: info.endTimeMinutes! ~/ 60);
    String? audioName = info.musicFileName;

    final List<Widget> menuItems = [
      ListTile(
        enabled: isActive,
        title: Text(
          "${info.name ?? "Noname"} is currently ${isActive ? "ON" : "OFF"}",
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
                    BlueBroadcastHandler.instance.printMessage(
                        widget.device.address,
                        "isActive:${isActive ? "1" : "0"}\n");
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
          BlueBroadcastHandler.instance.printMessage(
              widget.device.address, "isManual:${isManual ? "1" : "0"}\n");
        }),
      ),
      Divider(),
      ListTile(
        leading: Icon(Icons.arrow_forward_ios),
        title: Text("Scheduled activation time: "),
        trailing: Text(scheduledStart.format(context)),
        enabled: !isManual,
        onTap: () async {
          //print("pls animate");
          TimeOfDay time = await showTimePicker(
                context: context,
                initialTime: scheduledStart,
              ) ??
              scheduledStart;
          print("time $time");
          int minutes = time.minute + time.hour * 60;
          setState(() => info.startTimeMinutes = minutes);
          BlueBroadcastHandler.instance
              .printMessage(widget.device.address, "endTimeMinutes:$minutes\n");
        },
      ),
      ListTile(
        leading: Icon(Icons.arrow_forward_ios),
        title: Text("Scheduled deactivation time: "),
        trailing: Text(scheduledEnd.format(context)),
        enabled: !isManual,
        onTap: () async {
          //print("pls animate");
          TimeOfDay time = await showTimePicker(
                context: context,
                initialTime: scheduledEnd,
              ) ??
              scheduledEnd;
          print("time2 $time");
          int minutes = time.minute + time.hour * 60;
          setState(() => info.endTimeMinutes = minutes);
          BlueBroadcastHandler.instance.printMessage(
              widget.device.address, "startTimeMinutes:$minutes\n");
        },
      ),
      Divider(),
      EditableElementListTile(
        title: "Current alarm:",
        onPressed: () async {
          int? index = await showDialog(
              context: context,
              builder: (context) => SimpleDialog(
                    title: Text("Choose an alarm:"),
                    children: musicFileNames
                        .map<int, Widget>((index, name) => MapEntry(
                            index,
                            ListTile(
                                title: Text(name),
                                trailing: Radio(
                                  groupValue: info.musicFileName,
                                  value: name,
                                  onChanged: (name) {
                                    Navigator.pop(context, index);
                                  },
                                ))))
                        .values
                        .toList(),
                  ));
          if (index != null)
            setState(() {
              info.musicFileName = musicFileNames[index];
              BlueBroadcastHandler.instance.printMessage(
                  widget.device.address, "currentAlarmIndex:$index\n");
            });
        },
        value: audioName,
      ),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
            onPressed: () {
              setState(() {
                BlueBroadcastHandler.instance
                    .printMessage(widget.device.address, "alert dummy\n");
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
      //Padding(padding: EdgeInsets.symmetric(vertical: 32.0)),
      EditableElementListTile(
        title: "Current robot name:",
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (context) => SimpleDialog(
              children: [
                Text(
                  "Enter a new name",
                  textAlign: TextAlign.center,
                  style: b1,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(labelText: "new name:"),
                      onChanged: (newValue) {
                        setState(() {
                          info.name = newValue;
                          print("$newValue here");
                        });
                      }),
                ),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("Change"))
              ],
            ),
          ).then((value) => setState(() {
                print("${info.name} here");
                BlueBroadcastHandler.instance
                    .printMessage(widget.device.address, "name:${info.name}\n");
              }));
        },
        value: info.name,
      ),
      Divider(),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 64.0),
        child: ElevatedButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) => SimpleDialog(
                      children: [
                        Text(
                          "Really forget it?",
                          textAlign: TextAlign.center,
                          style: b1,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("No")),
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  widget.onForget(widget.device.address);
                                },
                                child: Text("Yes")),
                          ],
                        )
                      ],
                    ));
          },
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
            widget.robotPhotoPath,
            fit: BoxFit.cover,
            width: widget.displayImageHeight,
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
              'Bot ${info.name == '' ? "Noname" : info.name ?? "Noname"} is connected',
              style: b0?.copyWith(color: Colors.black),
              textAlign: TextAlign.center,
            ),
            collapseMode: CollapseMode.pin,
            expandedTitleScale: 1.7,
          ),
          expandedHeight: widget.displayImageHeight,
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

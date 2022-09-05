import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_application_1/util/get_bot_info.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class LoadedMenu extends StatefulWidget {
  final BotInfo info;
  final void Function(String adress) onForget;
  final double displayImageHeight = 300;
  final BluetoothDevice device;
  final String robotPhotoPath = 'assets/arduino_STOCK.png';
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
  bool isManual = false;
  bool isAudioPlaying = false;
  late BotInfo info;
  @override
  void initState() {
    // TODO: implement initState
    info = widget.info;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("active ${info.isActive}");
    //if (!isManual) isActive = false;

    final b1 = Theme.of(context).textTheme.bodyLarge;
    final b0 = Theme.of(context).textTheme.headlineSmall;
    final headline = Theme.of(context).textTheme.headline2;

    final player = AudioPlayer();
    TimeOfDay scheduledStart = TimeOfDay.now();
    TimeOfDay scheduledEnd = TimeOfDay.now();
    String? audioName;
    DeviceFileSource? audioSource;
    final List<Widget> menuItems = [
      Padding(
        padding: const EdgeInsets.all(32.0),
        child: Text(
          'Bot ${info.name ?? "Noname"} is connected',
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
        enabled: info.isActive!,
        title: Text(
          "${info.name ?? "Noname"} is currently ${info.isActive! ? "ON" : "OFF"}",
          style:
              b0?.copyWith(color: (info.isActive! ? Colors.green : Colors.red)),
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
              "Turn ${info.isActive! ? "off" : "on"}",
            ),
          ),
          onPressed: !isManual
              ? null
              : () {
                  setState(() {
                    info.isActive = !info.isActive!;
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
      EditableElementListTile(
        title: "Current alarm:",
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
        value: audioName,
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
                info.name = value ?? info.name;
                print("$value here");
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
    return ListView(
      children: menuItems,
    );
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

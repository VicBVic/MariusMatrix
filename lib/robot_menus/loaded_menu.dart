import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/bluetooth/bot_info.dart';
import 'package:flutter_application_1/redux/bluetooth_state_actions.dart';
import 'package:flutter_application_1/util/minutes_to_time_of_day.dart';
import 'package:flutter_application_1/util/robot_connection.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../extra_widgets/yes_no_dialog.dart';
import '../popup_screens/alert_screen.dart';
import '../redux/bluetooth_state.dart';
import 'package:redux/redux.dart';

const String untriggerCommand = "Untrigger\n";

const int musicFileNamesLen = 4;

class LoadedMenu extends StatefulWidget {
  final RobotConnection robotConnection;

  LoadedMenu({
    Key? key,
    required this.robotConnection,
  }) : super(key: key);

  @override
  State<LoadedMenu> createState() => _LoadedMenuState();
}

class _LoadedMenuState extends State<LoadedMenu> {
  final double displayImageHeight = 500;

  final String robotPhotoPath = 'assets/Marius.jpeg';

  late CompleteBotInfo info;

  //TODO: implementea-za prostiile astea cu Redux
  void toggleBotOffOn(store) {
    info.isActive = !info.isActive;
    _refreshBotInfo(store);
  }

  void toggleBotManSched(store, value) {
    info.isManual = value;
    _refreshBotInfo(store);
  }

  void pickStartTime(store, context) async {
    TimeOfDay? pick = await showTimePicker(
        context: context,
        initialTime: minutesToTimeOfDay(info.startTimeMinutes));
    if (pick != null) info.startTimeMinutes = timeOfDayToMinutes(pick);
    _refreshBotInfo(store);
  }

  void pickEndTime(store, context) async {
    TimeOfDay? pick = await showTimePicker(
        context: context, initialTime: minutesToTimeOfDay(info.endTimeMinutes));
    if (pick != null) {
      info.endTimeMinutes = timeOfDayToMinutes(pick);
      _refreshBotInfo(store);
    }
  }

  void pickAlarm(store, context) async {
    String? pick = await showDialog(
        context: context,
        builder: (context) => SimpleDialog(
              title: Text("Pick a song"),
              children: musicFileNames.keys
                  .map((val) => ListTile(
                        trailing: Radio<String>(
                            value: val,
                            groupValue: null,
                            onChanged: (value) {
                              Navigator.pop(context, value);
                            }),
                        title: Text(val),
                      ))
                  .toList(),
            ));
    if (pick != null) {
      info.musicFileName = pick;
      _refreshBotInfo(store);
    }
  }

  void testAlarm(store) {}

  void changeBotName(store, context) async {
    await showDialog(
        context: context,
        builder: (context) => SimpleDialog(
              title: Text("Pick a new name:"),
              titlePadding:
                  EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    onChanged: (value) => info.name = value,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                  child: ElevatedButton(
                    child: Text("Confirm"),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                )
              ],
            ));
    _refreshBotInfo(store);
  }

  void forgetAddress(store) {
    showDialog(
        context: context,
        builder: (context) => YesNoDialog(
            title: Text("Really forget it?"),
            response: (response) {
              if (response == true) {
                store.dispatch(
                    DeleteBotConnectionAction(widget.robotConnection.device));
              }
            }));
  }

  void _refreshBotInfo(Store<BluetoothAppState> store) {
    setState(() {});
    store.dispatch(UpdateBotInfoAction(widget.robotConnection.device, info));
  }

  @override
  void initState() {
    info = CompleteBotInfo.fromBotInfo(widget.robotConnection.botInfo);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<BluetoothAppState>(builder: (context, store) {
      final b1 = Theme.of(context).textTheme.bodyLarge;
      final b0 = Theme.of(context).textTheme.headlineSmall;
      final headline = Theme.of(context).textTheme.headline2;

      final List<Widget> menuItems = [
        ListTile(
          enabled: info.isActive,
          title: Text(
            "${info.name} is currently ${info.isActive ? "ACTIVE" : "INACTIVE"}",
            style: b0?.copyWith(
                color: (info.isActive ? Colors.green : Colors.red)),
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
              onPressed: !info.isManual ? null : () => toggleBotOffOn(store)),
        ),
        //info.isActive ? Text("To enable editing, turn the bot off.") : Text(""),
        Divider(),
        SwitchListTile(
            value: info.isManual,
            title: Text(
                "Activation mode: ${info.isManual ? "Manual" : "Scheduled"}"),
            onChanged: (value) => toggleBotManSched(store, value)),
        Divider(),
        ListTile(
          leading: Icon(Icons.arrow_forward_ios),
          title: Text("Scheduled activation time: "),
          trailing:
              Text(minutesToTimeOfDay(info.startTimeMinutes).format(context)),
          enabled: !info.isManual,
          onTap: () => pickStartTime(store, context),
        ),
        ListTile(
          leading: Icon(Icons.arrow_forward_ios),
          title: Text("Scheduled deactivation time: "),
          trailing:
              Text(minutesToTimeOfDay(info.endTimeMinutes).format(context)),
          enabled: !info.isManual,
          onTap: () => pickEndTime(store, context),
        ),
        Divider(),
        EditableElementListTile(
          title: "Current alarm:",
          onPressed: () => pickAlarm(store, context),
          value: info.musicFileName,
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
              onPressed: () => testAlarm(store), child: Text("Test")),
        ),
        Divider(),
        ListTile(
            title: Text(
          "Other info",
          textAlign: TextAlign.center,
        )),
        EditableElementListTile(
          title: "Current robot name:",
          onPressed: () => changeBotName(store, context),
          value: info.name,
        ),
        Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 64.0),
          child: ElevatedButton(
            onPressed: () => forgetAddress(store),
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
    });
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

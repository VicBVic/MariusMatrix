import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/__device_discorvery_screen.dart';
import 'package:flutter_application_1/bluetooth/blue_broadcast_handler.dart';
import 'package:flutter_application_1/popup_screens/alert_screen.dart';
import 'package:flutter_application_1/popup_screens/device_select_screen.dart';
import 'package:flutter_application_1/file_access/file_manager.dart';
import 'package:flutter_application_1/redux/bluetooth_state.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'robot_page_view.dart';

const String untriggerString = "Untrigger\n";

class MainScaffold extends StatefulWidget {
  final String? title;
  const MainScaffold({this.title, Key? key}) : super(key: key);

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold>
    with TickerProviderStateMixin {
  void createAlertNotification(String address) {
    AwesomeNotifications().createNotification(
        content: NotificationContent(
      id: 10,
      channelKey: 'alert_channel',
      title: 'MariusMatrix',
      body: '$address detected movement!',
      fullScreenIntent: true,
      wakeUpScreen: true,
      criticalAlert: true,
    ));
  }

  @override
  void initState() {
    // TODO: implement initState
    BlueBroadcastHandler.instance.addAlarmListener((event) {
      if (event.name != "") {
        print("found name ${event.name}");
        createAlertNotification(event.name);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    AlertScreen(botName: event.name, onClose: () {}))).then(
            (value) => BlueBroadcastHandler.instance
                .printMessage(event.connection, untriggerString));
      }
    });
    super.initState();
  }

  TabController? robotPageViewController = null;

  @override
  void dispose() {
    robotPageViewController?.dispose();
    super.dispose();
  }

  void alarmUser() {}
  @override
  Widget build(BuildContext context) {
    return StoreBuilder<BluetoothAppState>(builder: ((context, store) {
      List<Tab> tabItems = store.state.robotConnections
          .map((e) => Tab(
                child: Icon(Icons.computer),
              ))
          .toList();
      robotPageViewController = TabController(
          length: tabItems.length,
          vsync: this,
          initialIndex: robotPageViewController == null
              ? 0
              : min(
                  max(tabItems.length - 1, 0), robotPageViewController!.index));
      //robotPageViewController.dispose();
      return Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, what) => [
            SliverAppBar(
              centerTitle: true,
              title: Text(
                widget.title ?? "",
                //textAlign: TextAlign.center,
              ),
              pinned: false,
              //snap: true,
              floating: false,
              bottom: TabBar(
                tabs: tabItems,
                controller: robotPageViewController,
              ),
            ),
          ],
          body: RobotPageView(
            onChangedScreen: (ix) {},
            controller: robotPageViewController!,
            checkAvalability: true,
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: ((context) => DeviceSelectScreen(
                    connectionTimeLimit: Duration(seconds: 10),
                    checkActivity: false,
                  )),
            ),
          ),
          child: const Icon(Icons.add),
        ),
      );
    }));
  }
}

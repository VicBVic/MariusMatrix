import 'package:flutter/material.dart';
import 'package:flutter_application_1/bluetooth/alert_manager.dart';
import 'package:flutter_application_1/error_menus/no_bluetooth_menu.dart';
import 'package:flutter_application_1/popup_screens/alert_screen.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'main_widgets/main_scaffold.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<bool> blueRequest =
      FlutterBluetoothSerial.instance.requestEnable().then((value) {
    if (value == null || !value) return false;
    return Permission.location.request().isGranted;
  }).then((value) async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    if (value as bool) {
      return await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.requestPermission() ??
          false;
    } else
      return false;
  });

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        //hemeMode: ThemeMode.dark,
        debugShowCheckedModeBanner: false,
        home: FutureBuilder(
          future: blueRequest,
          builder: (context, result) {
            if (result.hasData && result.data == true) {
              return const MainScaffold(
                title: "MatrixController",
              );
            } else {
              return NoBluetoothMenu(
                onRetry: () {
                  setState(() {
                    blueRequest = FlutterBluetoothSerial.instance
                        .requestEnable()
                        .then((value) {
                      if (value == null || !value) return false;
                      return Permission.location.request().isGranted;
                    });
                  });
                },
              );
            }
          },
        ));
  }
}

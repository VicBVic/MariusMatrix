import 'package:flutter/material.dart';
import 'package:flutter_application_1/Semieditables/no_bluetooth_menu.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'main_scaffold.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<bool?> blueRequest = FlutterBluetoothSerial.instance.requestEnable();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.light,
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
                    blueRequest =
                        FlutterBluetoothSerial.instance.requestEnable();
                  });
                },
              );
            }
          },
        ));
  }
}

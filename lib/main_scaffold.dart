import 'package:flutter/material.dart';
import 'package:flutter_application_1/Semieditables/__device_discorvery_screen.dart';
import 'package:flutter_application_1/Semieditables/__device_select_screen.dart';
import 'package:flutter_application_1/file_manager.dart';
import 'robot_page_view.dart';

class MainScaffold extends StatefulWidget {
  final String? title;
  const MainScaffold({this.title, Key? key}) : super(key: key);

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  Set<String> botAdresses = <String>{};
  Future<List<String>>? adressesFromFile;
  @override
  void initState() {
    super.initState();
    try {
      adressesFromFile = FileManager.instance.getBotAdresses();
      adressesFromFile?.then((value) => setState(() {
            botAdresses.addAll(value);
          }));
    } catch (error) {
      print("$error");
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? ""),
      ),
      body: RobotPageView(
        checkAvalability: true,
        wantedAdresses: botAdresses,
        onAdressForgor: (adress) {
          setState(() {
            botAdresses.remove(adress);
            FileManager.instance.updateAdresses(botAdresses.toList());
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: ((context) => DeviceSelectScreen(
                usedAdresses: botAdresses,
                checkActivity: false,
                onSelected: (device) => setState(() {
                      botAdresses.add(device.address);
                      FileManager.instance.updateAdresses(botAdresses.toList());
                    }))),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

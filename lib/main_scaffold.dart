import 'package:flutter/material.dart';
import 'package:flutter_application_1/Semieditables/device_discorvery.dart';
import 'package:flutter_application_1/Semieditables/device_select.dart';
import 'robot_page_view.dart';

class MainScaffold extends StatefulWidget {
  final String? title;
  final int? pageCount;
  const MainScaffold({this.title, Key? key, this.pageCount}) : super(key: key);

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  late int pageCount = widget.pageCount ?? 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? ""),
      ),
      body: RobotPageView(
        checkAvalability: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DeviceDiscoveryScreen(
                      start: false,
                      onSelected: (device) {},
                    )),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'robot_page_view.dart';

class MainScaffold extends StatefulWidget {
  final String? title;
  const MainScaffold({this.title, Key? key}) : super(key: key);

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int pageCount = 4;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? ""),
      ),
      body: RobotPageView(
        basePageCount: pageCount,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            final snackBar = SnackBar(
              content: const Text('Added new robot!'),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            pageCount++;
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

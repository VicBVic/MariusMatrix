import 'package:flutter/material.dart';
import 'robot_page_view.dart';

class MainScaffold extends StatelessWidget {
  final String? title;
  const MainScaffold({this.title, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? ""),
      ),
      body: RobotPageView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
      ),
    );
  }
}

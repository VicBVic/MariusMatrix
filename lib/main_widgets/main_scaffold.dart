import 'package:flutter/material.dart';
import 'package:flutter_application_1/__device_discorvery_screen.dart';
import 'package:flutter_application_1/popup_screens/device_select_screen.dart';
import 'package:flutter_application_1/file_access/file_manager.dart';
import 'robot_page_view.dart';

class MainScaffold extends StatefulWidget {
  final String? title;
  const MainScaffold({this.title, Key? key}) : super(key: key);

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    Set<String> botAdresses = <String>{};
    List<Tab> tabItems = botAdresses
        .map((e) => Tab(
              child: Icon(Icons.computer),
            ))
        .toList();
    TabController robotPageViewController =
        TabController(length: tabItems.length, vsync: this);
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
          controller: robotPageViewController,
          checkAvalability: true,
          wantedAdresses: botAdresses,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: ((context) => DeviceSelectScreen(
                  connectionTimeLimit: Duration(seconds: 10),
                  usedAdresses: botAdresses,
                  checkActivity: false,
                )),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

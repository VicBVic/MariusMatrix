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
  int currentPageIndex = 0;
  Set<String> botAdresses = <String>{};
  Future<List<String>>? adressesFromFile;
  late TabController robotPageViewController;
  @override
  void initState() {
    super.initState();
    robotPageViewController = TabController(vsync: this, length: 0);
    adressesFromFile = FileManager.instance.getBotAdresses();
    adressesFromFile
        ?.then((value) => setState(() {
              botAdresses.addAll(value.where((element) => element != ''));
              /*botAdresses.add("98:DA");
              botAdresses.add("98:DC");
              botAdresses.add("98:DE");
              botAdresses.add("98:DF");*/
              robotPageViewController =
                  TabController(vsync: this, length: botAdresses.length);
            }))
        .onError((error, stackTrace) => print("se mai intampla $error"));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Tab> tabItems = botAdresses
        .map((e) => Tab(
              child: Icon(Icons.computer),
            ))
        .toList();
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
          onAdressForgor: (adress) {
            setState(() {
              botAdresses.remove(adress);
              FileManager.instance.updateAdresses(botAdresses.toList());
              robotPageViewController =
                  TabController(vsync: this, length: botAdresses.length);
            });
          },
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
                onSelected: (device) => setState(() {
                      botAdresses.add(device.address);
                      FileManager.instance.updateAdresses(botAdresses.toList());
                      robotPageViewController = TabController(
                          vsync: this, length: botAdresses.length);
                    }))),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

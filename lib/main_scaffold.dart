import 'package:flutter/material.dart';
import 'package:flutter_application_1/Semieditables/__device_discorvery_screen.dart';
import 'package:flutter_application_1/Semieditables/device_select_screen.dart';
import 'package:flutter_application_1/file_manager.dart';
import 'robot_page_view.dart';

class MainScaffold extends StatefulWidget {
  final String? title;
  const MainScaffold({this.title, Key? key}) : super(key: key);

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int currentPageIndex = 0;
  Set<String> botAdresses = <String>{};
  Future<List<String>>? adressesFromFile;
  PageController robotPageViewController = PageController();
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
    List<BottomNavigationBarItem> bottomItems = botAdresses
        .where((element) => element != '')
        .map((e) => BottomNavigationBarItem(
              icon: Icon(Icons.computer),
              label: '',
              backgroundColor: Colors.blue,
            ))
        .toList();

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title ?? ""),
        ),
        body: RobotPageView(
          onChangedScreen: (index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          controller: robotPageViewController,
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
                  connectionTimeLimit: Duration(seconds: 10),
                  usedAdresses: botAdresses,
                  checkActivity: false,
                  onSelected: (device) => setState(() {
                        botAdresses.add(device.address);
                        FileManager.instance
                            .updateAdresses(botAdresses.toList());
                      }))),
            ),
          ),
          child: const Icon(Icons.add),
        ),
        bottomNavigationBar: bottomItems.length < 2
            ? null
            : BottomNavigationBar(
                items: bottomItems,
                currentIndex: currentPageIndex,
                onTap: (index) {
                  setState(() {
                    currentPageIndex = index;
                    robotPageViewController.jumpToPage(index);
                  });
                },
              ));
  }
}

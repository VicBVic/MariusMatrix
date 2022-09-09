import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FileManager {
  static final FileManager instance = FileManager._internal();

  factory FileManager() {
    return instance;
  }

  FileManager._internal() {
    documentDir = getApplicationDocumentsDirectory();
    botAdressesFile = documentDir.then((value) {
      print(value.path);
      print("${value.path}/bot_adresses.txt");
      return File("${value.path}/bot_adresses.txt");
    });
  }

  late Future<Directory> documentDir;
  late Future<File> botAdressesFile;

  Future<List<String>> getBotAdresses() async {
    String adressesData =
        await botAdressesFile.then((value) => value.readAsString());
    return adressesData.split('\n');
  }

  void updateAdresses(List<String> adresses) async {
    botAdressesFile.then((value) => value.writeAsString(adresses.join('\n')));
  }
}

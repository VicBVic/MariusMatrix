import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FileManager {
  static final FileManager instance = FileManager._internal();

  factory FileManager() {
    return instance;
  }

  FileManager._internal();

  Future<String> _getDataPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<File> _getBotAdressesFile() async {
    final path = await _getDataPath();
    final file = File("$path/botAdresses.txt");
    if (!(await file.exists())) await file.create(recursive: true);
    return file;
  }

  Future<List<String>> getBotAdresses() async {
    final botFile = await _getBotAdressesFile();
    String adressesData = await botFile.readAsString();
    return adressesData.split('\n');
  }

  void updateAdresses(List<String> adresses) async {
    final botFile = await _getBotAdressesFile();
    botFile.writeAsString(adresses.join('\n'));
  }
}

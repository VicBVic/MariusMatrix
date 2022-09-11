class BotInfo {
  bool? isActive, isManual;
  String? name, musicFileName;
  int? startTimeMinutes, endTimeMinutes;
  BotInfo(this.isActive, this.name);
  void parseString(String arg) {
    arg = arg.replaceAll('\n', '');
    arg = arg.replaceAll('\r', '');
    List<String> pair = arg.split(':');
    if (pair.length != 2) return;
    print("${pair.first} ${pair.last}");
    switch (pair.first) {
      case "isActive":
        isActive = (pair.last == "1");
        break;
      case "isManual":
        isManual = (pair.last == "1");
        break;
      case "name":
        name = (pair.last);
        break;
      case "musicFileName":
        musicFileName = pair.last;
        break;
      case "startTimeMinutes":
        startTimeMinutes = int.parse(pair.last);
        break;
      case "endTimeMinutes":
        endTimeMinutes = int.parse(pair.last);
        break;
      default:
        print("ce facuesti fraiere");
    }
    print(isComplete());
  }

  BotInfo.empty() {}

  bool isComplete() {
    /*print(
        "${isActive != null} ${isManual != null}${name != null} ${startTimeMinutes != null} ${endTimeMinutes != null} ${musicFileName != null}");*/
    return isActive != null &&
        isManual != null &&
        name != null &&
        startTimeMinutes != null &&
        endTimeMinutes != null &&
        musicFileName != null;
  }
}

class CompleteBotInfo {
  late bool isActive, isManual;
  late String name, musicFileName;
  late int startTimeMinutes, endTimeMinutes;
  CompleteBotInfo.fromBotInfo(BotInfo? info) {
    if (info == null || !info.isComplete())
      throw ("Info is incomplete or null.");
    isActive = info.isActive!;
    isManual = info.isManual!;
    name = info.name!;
    musicFileName = info.musicFileName!;
    startTimeMinutes = info.startTimeMinutes!;
    endTimeMinutes = info.endTimeMinutes!;
  }
}

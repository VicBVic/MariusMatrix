import 'dart:async';

import 'package:async/async.dart';

class AlertManager {
  static final AlertManager instance = AlertManager._internal();

  factory AlertManager() {
    return instance;
  }

  AlertManager._internal();

  void listen() async {
    print("alertManager entered listen body");
    await for (String name in alertStreams.stream) {
      print("alertManager found $name");
      for (final callback in listeners) {
        callback(name);
      }
    }
  }

  StreamGroup<String> alertStreams = StreamGroup.broadcast();
  List<Function(String)> listeners = List.empty(growable: true);

  void addListener(Function(String) callback) {
    listeners.add(callback);
  }

  void addStream(Stream<String> stream) {
    alertStreams.add(stream);
    print("alertMAnager added stream $stream");
  }
}

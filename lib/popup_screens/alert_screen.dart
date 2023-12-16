import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AlertScreen extends StatefulWidget {
  final String botName;
  final void Function() onClose;

  const AlertScreen({Key? key, required this.botName, required this.onClose})
      : super(key: key);

  @override
  State<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {
  final player = AudioPlayer();

  final String alarmAsset = 'assets/warning.png';

  void playSound() async {
    await player.play(AssetSource('re_bruh-alarm.mp3'));
    player.setReleaseMode(ReleaseMode.loop);
  }

  @override
  void dispose() {
    player.stop(); // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    playSound();
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(alarmAsset),
            Text(
              "Bot ${widget.botName} has been triggered!",
              style: Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.center,
            ),
            TextButton(
              onPressed: () {
                widget.onClose();
                Navigator.pop(context);
              },
              child: const Text("Okay"),
            )
          ],
        ),
      ),
    );
  }
}

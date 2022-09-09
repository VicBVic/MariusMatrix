import 'package:flutter/material.dart';

class AlertScreen extends StatelessWidget {
  final String botName;
  const AlertScreen({Key? key, required this.botName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Bot $botName has been triggered!"),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Okay"),
            )
          ],
        ),
      ),
    );
  }
}

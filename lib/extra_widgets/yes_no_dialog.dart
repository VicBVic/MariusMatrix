import 'package:flutter/material.dart';

class YesNoDialog extends AlertDialog {
  const YesNoDialog({required this.title, required this.response, super.key});
  @override
  final Widget title;
  final void Function(bool) response;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: title,
      actions: [
        TextButton(
            onPressed: () {
              response(true);
              Navigator.pop(context);
            },
            child: const Text("Yes")),
        TextButton(
            onPressed: () {
              response(false);
              Navigator.pop(context);
            },
            child: const Text("No"))
      ],
    );
  }
}

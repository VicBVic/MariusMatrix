import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class YesNoDialog extends AlertDialog {
  const YesNoDialog({required this.title, required this.response, super.key});
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
            child: Text("Yes")),
        TextButton(
            onPressed: () {
              response(false);
              Navigator.pop(context);
            },
            child: Text("No"))
      ],
    );
  }
}

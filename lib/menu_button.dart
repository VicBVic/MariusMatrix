import 'dart:ui';

import 'package:flutter/material.dart';

class MenuButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  const MenuButton({required this.onPressed, required this.child, Key? key})
      : super(key: key);

  @override
  State<MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<MenuButton> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: widget.child,
          ),
        ),
      ),
      onPressed: widget.onPressed,
    );
  }
}

import 'package:flutter/material.dart';

class MenuPopup extends StatefulWidget {
  final List<String> elements;
  final void Function(dynamic) onChanged;
  final currentItem;
  const MenuPopup(
      {required this.onChanged,
      required this.currentItem,
      required this.elements,
      Key? key})
      : super(key: key);

  @override
  State<MenuPopup> createState() => _MenuPopupState();
}

class _MenuPopupState extends State<MenuPopup> {
  void onItemChanged(value) {
    //setState(() => currentItem = value);
    widget.onChanged(value);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> rowButtons = List.generate(widget.elements.length, (index) {
      return ListTile(
        title: Text(widget.elements[index]),
        trailing: Radio(
          groupValue: widget.elements[index],
          value: widget.elements[index],
          onChanged: (dynamic value) => onItemChanged(value),
        ),
      );
    });
    return SimpleDialog(
      children: rowButtons,
    );
  }
}

void makeMenuPopup(
    {required context,
    required List<String> elements,
    required currentItem,
    required void Function(dynamic) onChanged}) {
  showDialog(
      context: context,
      builder: (context) {
        return MenuPopup(
          elements: elements,
          currentItem: currentItem,
          onChanged: onChanged,
        );
      });
}

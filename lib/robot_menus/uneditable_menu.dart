import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class UneditableMenu extends StatelessWidget {
  const UneditableMenu({super.key});
  final String robotPhotoPath = 'assets/Marius.jpeg';
  final double displayImageHeight = 500;

  @override
  Widget build(BuildContext context) {
    final Widget titleBox = Stack(
      fit: StackFit.expand,
      children: [
        Align(
          alignment: Alignment.bottomCenter,
          child: Image.asset(
            robotPhotoPath,
            fit: BoxFit.cover,
            width: displayImageHeight,
            //height: widget.displayImageHeight,
          ),
        ),
        Container(
          alignment: Alignment.bottomCenter,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Colors.black.withAlpha(0),
                Theme.of(context).scaffoldBackgroundColor.withAlpha(57),
                Theme.of(context).scaffoldBackgroundColor,
              ],
            ),
          ),
        ),
      ],
    );
    return Container();
  }
}

import 'package:flutter/material.dart';

class TextObjectData {
  double containerX = 0;
  double containerY = 0;
  String textMeme = '';
  double fontSize = 30;
  TextObjectData(
      {required this.containerX,
      required this.containerY,
      required this.textMeme});
  Widget getWidget() {
    return Positioned(
        left: containerX,
        top: containerY,
        child: Text(textMeme, style: TextStyle(fontSize: fontSize)));
  }
}

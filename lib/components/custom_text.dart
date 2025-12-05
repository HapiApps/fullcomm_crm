import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String text;
  final Color? colors;
  final double size;
  final bool isBold;
  final bool isCopy;
  final bool isSplash;
  final bool isStyle;
  final TextDecoration? decoration;
  final TextAlign? textAlign;

  const CustomText(
      {super.key,
      required this.text,
      this.colors,
      this.size = 13,
      this.isStyle = false,
      this.isBold = false,
        required this.isCopy,
      this.isSplash = false,
      this.textAlign = TextAlign.center,
      this.decoration = TextDecoration.none});

  @override
  Widget build(BuildContext context) {
    final displayText = (text == "null") ? "" : text;
    return isCopy?SelectableText(
      displayText,
      textAlign: textAlign,
      showCursor: false,
      style: TextStyle(
        decoration: decoration,
        color: colors,
        fontSize: size,
        fontWeight: isBold ? FontWeight.bold : FontWeight.w200,
        fontFamily: "Lato",
        fontStyle: isStyle ? FontStyle.italic : FontStyle.normal,
      ),
      toolbarOptions: const ToolbarOptions(copy: true, selectAll: true),
    ):IgnorePointer(
      child: Text(
        displayText,
        textAlign: textAlign,
        style: TextStyle(
          decoration: decoration,
          color: colors,
          fontSize: size,
          fontWeight: isBold ? FontWeight.bold : FontWeight.w200,
          fontFamily: "Lato",
          fontStyle: isStyle ? FontStyle.italic : FontStyle.normal,
        ),
      ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String text;
  final Color? colors;
  final double size;
  final bool isBold;
  final bool isSplash;
  final bool isStyle;
  final bool isCopy;
  final TextDecoration? decoration;
  final TextAlign? textAlign;

  const CustomText(
      {super.key,
      required this.text,
      this.colors,
      this.size = 13,
      this.isStyle = false,
      this.isCopy = true,
      this.isBold = false,
      this.isSplash = false,
      this.textAlign = TextAlign.center,
      this.decoration = TextDecoration.none});

  @override
  Widget build(BuildContext context) {
    return
        //   isCopy?Theme(
        //   data: ThemeData(
        //       textSelectionTheme: const TextSelectionThemeData(
        //         cursorColor: Colors.yellow,
        //         selectionColor: Color(0xff8EA6E7),
        //         selectionHandleColor: Colors.blue,
        //       )
        //   ),
        //   child: SelectableText(
        //     cursorColor: Colors.green,
        //     //contextMenuBuilder: null,
        //     selectionHeightStyle: BoxHeightStyle.max,
        //     selectionWidthStyle: BoxWidthStyle.max,
        //     text,
        //     textAlign: textAlign,
        //     style: TextStyle(
        //         decoration: decoration,
        //         color: colors,
        //         fontSize: size,
        //         fontWeight:isBold ? FontWeight.bold:FontWeight.w200,
        //         fontFamily:"Lato",
        //       fontStyle: isStyle?FontStyle.italic:FontStyle.normal,
        //     ),
        //   ),
        // ):
        Theme(
      data: ThemeData(
          textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Colors.yellow,
        selectionColor: Color(0xff8EA6E7),
        selectionHandleColor: Colors.blue,
      )),
      child: IgnorePointer(
        child: Text(
          text == "null" ? "" : text,
          textAlign: textAlign,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            decoration: decoration,
            color: colors,
            fontSize: size,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w200,
            fontFamily: "Lato",
            fontStyle: isStyle ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ),
    );
  }
}

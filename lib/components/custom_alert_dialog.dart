import 'package:flutter/material.dart';
import '../common/constant/colors_constant.dart';
import '../common/constant/default_constant.dart';
import 'custom_text.dart';
import 'custom_textbutton.dart';




class CustomAlertDialog extends StatelessWidget {
  final Color? bgColor;
  final String? title;
  final String? title1;
  final String? message;
  final String? positiveBtnText;
  final String? negativeBtnText;
  final double? circularBorderRadius;
  final VoidCallback onPressed;
  final VoidCallback cancelOnPressed;


  const CustomAlertDialog({super.key,
  this.title,
  this.title1,
  this.message,
  this.circularBorderRadius = 15.0,
  this.bgColor = Colors.white,
  this.positiveBtnText,
  this.negativeBtnText,
  required this.onPressed, required this.cancelOnPressed,
  })  : assert(bgColor != null),
  assert(circularBorderRadius != null);


  @override
  Widget build(BuildContext context){
    return AlertDialog(
      insetPadding: const EdgeInsets.all(5),
      backgroundColor: colorsConst.axis,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(circularBorderRadius!)),
      content: CustomText(
        colors: colorsConst.primary,
        text: title.toString(),
        isBold: true,
        size: 15,
      ),
      actions: <Widget>[
        ButtonWidget(text:constValue.camera, onClicked:onPressed, isIcon: false,width: 120,),
        ButtonWidget(text: constValue.gallery, onClicked: cancelOnPressed, isIcon: false,width: 120),
      ],
    );
  }
}



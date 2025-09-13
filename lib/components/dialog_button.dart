import 'package:flutter/material.dart';

import '../common/constant/colors_constant.dart';

class DialogButton extends StatelessWidget {
  final String text;
  final VoidCallback onPress;
  final double width;

  const DialogButton({super.key,required this.text,required this.onPress,required this.width});

  @override
  Widget build(BuildContext context){
    return  SizedBox(
      width: width,
      height: 45,
      child: ElevatedButton(
        onPressed:onPress,
        style: ElevatedButton.styleFrom(
          shadowColor: Colors.transparent,
            backgroundColor: text=="UPDATE"?colorsConst.primary:colorsConst.secondary,
            side: BorderSide(
                color: colorsConst.secondary
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5)
            )
        ),
        child: Text(text,
          style:  TextStyle(
              color: text=="UPDATE"?Colors.white:colorsConst.textColor,
              fontSize: 13,
              fontWeight: FontWeight.bold
          ),
        ),
        // const CustomText(
        //   text: "No",
        //   colors:Colors.white,
        //   size: 14,
        //   isBold: true,
        // ),
      ),
    );
  }
}

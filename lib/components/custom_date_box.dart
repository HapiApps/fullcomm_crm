import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:flutter/material.dart';
import '../common/constant/colors_constant.dart';
import 'custom_text.dart';

class CustomDateBox extends StatelessWidget {
  final String text;
  final String? errorText;
  final String value;
  final double? width;
  final void Function()? onTap;
  final bool isOptional;
  const CustomDateBox(
      {super.key,
      this.width,
      required this.text,
      required this.value,
      this.onTap,this.isOptional=false,this.errorText
      });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomText(
              text:text,
              colors:colorsConst.fieldHead,
              size:13,
              isCopy: false,
            ),
            isOptional == true
                ? const CustomText(
              text: "*",
              colors: Colors.red,
              size: 25,
              isCopy: false,
            )
                : 0.width
          ],
        ),
        isOptional == true ? 0.height : 5.height,
        InkWell(
          onTap: onTap,
          child: Container(
            alignment: Alignment.centerLeft,
            width: width,
            height: 40,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color:Colors.grey.shade400)),
            child: Row(
              children: [
                15.width,
                CustomText(
                  text: value,
                  colors: colorsConst.textColor,
                  size: 15,
                  isCopy: false,
                ),
              ],
            ),
          ),
        ),
        errorText==null?0.height:CustomText(
          text: errorText.toString(),
          textAlign: TextAlign.start,
          colors: Colors.red,
          size: 13,
          isCopy: false,
        ),
        text.isEmpty ? 10.height : 20.height,
      ],
    );
  }
}

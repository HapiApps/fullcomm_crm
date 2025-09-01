import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:flutter/material.dart';
import '../common/constant/colors_constant.dart';
import 'custom_text.dart';

class CustomDateBox extends StatelessWidget {
  final String text;
  final String value;
  final double? width;
  final void Function()? onTap;
  const CustomDateBox(
      {super.key,
      this.width,
      required this.text,
      required this.value,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text:text,
          colors:colorsConst.textColor,
          size:13,
        ),
        InkWell(
          onTap: onTap,
          child: Container(
            alignment: Alignment.centerLeft,
            width: width,
            height: 40,
            decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color:Color(0xffE1E5FA))),
            child: Row(
              children: [
                15.width,
                CustomText(
                  text: value,
                  colors: colorsConst.textColor,
                  size: 15,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

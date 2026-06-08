import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../billing_utils/sized_box.dart';
import '../common/constant/colors_constant.dart';
import 'Customtext.dart';

class CustomAppbar extends StatelessWidget {
  final String text;
  final String? subText;
  const CustomAppbar({super.key, required this.text, this.subText=""});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        20.height,
        Row(
          children: [
            IconButton(onPressed: (){
              Get.back();
            }, icon: Icon(Icons.arrow_back)),
            CustomText(
              text: text,
              colors: colorsConst.textColor,
              size: 20,
              isBold: true,
              isCopy: true,
            ),
          ],
        ),
        if(subText!="")
        Column(
          children: [
            10.height,
            Row(
              children: [
                40.width,
                CustomText(
                  text: subText!,
                  colors: colorsConst.textColor,
                  size: 14,
                  isCopy: true,
                ),
              ],
            ),
          ],
        ),
        10.height,
        Divider(
          thickness: 1.5,
          color: colorsConst.secondary,
        ),
        10.height,
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../billing_utils/sized_box.dart';
import '../common/constant/colors_constant.dart';
import 'Customtext.dart';

class CustomAppbar extends StatelessWidget {
  final String text;
  final String? subText;
  final Widget? actionsWidget;
  final bool? isDivider;
  final VoidCallback? callback;
  const CustomAppbar({super.key, required this.text, this.subText="", this.actionsWidget, this.isDivider=true, this.callback});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        20.height,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                InkWell(
                    onTap: () {
                      if (callback != null) {
                        callback!();
                      } else {
                        Get.back();
                      }
                    },child: Icon(Icons.arrow_back)),10.width,
                CustomText(
                  text: text,
                  colors: colorsConst.textColor,
                  size: 20,
                  isBold: true,
                  isCopy: true,
                ),
              ],
            ),
            actionsWidget??SizedBox()
          ],
        ),
        if(subText!="")
        Column(
          children: [
            10.height,
            CustomText(
              text: subText!,
              colors: colorsConst.textColor,
              size: 14,
              isCopy: true,
            ),
          ],
        ),
        if(isDivider==true)
        10.height,
        if(isDivider==true)
        Divider(
          thickness: 1.5,
          color: colorsConst.secondary,
        ),
        10.height,
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/constant/colors_constant.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/components/custom_text.dart';

class ActionButton extends StatelessWidget {
  final double width;
  final String image;
  final String name;
  const ActionButton({super.key, required this.width, required this.image, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: width,
      decoration: BoxDecoration(
        color: colorsConst.secondary,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child:  Row(
        children: [
          Image.asset(image),
          8.width,
          CustomText(
            text: name,
              colors: colorsConst.textColor,
              size: 16,
          ),
        ],
      ),
    );
  }
}

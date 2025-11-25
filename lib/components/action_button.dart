import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/constant/colors_constant.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/components/custom_text.dart';

class ActionButton extends StatelessWidget {
  final double width;
  final String image;
  final String name;
  final String? toolTip;
  final VoidCallback callback;
  const ActionButton({super.key, required this.width, required this.image, required this.name, this.toolTip, required this.callback});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: toolTip,
      child: InkWell(
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        onTap: callback,
        child: Container(
          height: 40,
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(image),
              10.width,
              CustomText(
                text: name,
                  colors: colorsConst.textColor,
                  size: 14,
                isBold: true,
                isCopy: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

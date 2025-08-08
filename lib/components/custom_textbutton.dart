import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/constant/colors_constant.dart';

import 'custom_text.dart';

class ButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback onClicked;
  final IconData? icon;
  final bool isIcon;
  final double? width;

  const ButtonWidget({
    super.key,
    required this.text,
    required this.onClicked,
    required this.isIcon,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        child: OutlinedButton(
          style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(40),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                  side: BorderSide(color: colorsConst.third))),
          onPressed: onClicked,
          child: isIcon == true
              ? Wrap(
                  spacing: 8.0,
                  children: [
                    CustomText(
                      text: text,
                      size: 12,
                    ),
                    Icon(icon)
                  ],
                )
              : FittedBox(
                  child: CustomText(
                    text: text,
                    colors: colorsConst.textColor,
                  ),
                ),
        ),
      );
}

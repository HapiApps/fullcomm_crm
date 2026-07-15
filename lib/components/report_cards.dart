import 'package:flutter/material.dart';
import 'package:fullcomm_crm/billing_utils/sized_box.dart';
import 'package:get/get.dart';

import '../common/styles/decoration.dart';
import 'Customtext.dart';

class DashboardCard extends StatelessWidget {

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color selectedColor;
  final VoidCallback callback;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color, required this.callback, required this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {

    return InkWell(
      onTap: callback,
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(18),
        decoration: customDecoration.baseBackgroundDecoration(
            color: Colors.white,radius: 14,borderColor: selectedColor
        ),
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: color.withOpacity(.12),
                  child: Icon(icon, color: color),
                ),
                10.width,
                CustomText(
                  text: title,size: 17,
                  isCopy: false,
                  colors: Colors.grey,
                ),
              ],
            ),
            18.width,
            CustomText(
              text: value,
              isCopy: false,
              size: 28,
              isBold: true,
            )
          ],
        ),
      ),
    );
  }
}
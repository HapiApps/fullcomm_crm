import 'package:flutter/material.dart';
import 'package:fullcomm_crm/billing_utils/sized_box.dart';

import '../common/styles/decoration.dart';
import 'Customtext.dart';

class DashboardCard extends StatelessWidget {

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      width: 240,
      padding: const EdgeInsets.all(18),
      decoration: customDecoration.baseBackgroundDecoration(
          color: Colors.white,radius: 14,borderColor: Colors.grey.shade200
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                text: title,
                isCopy: false,
                colors: Colors.grey,
              ),
            ],
          ),
          CustomText(
            text: value,
            isCopy: false,
            size: 28,
            isBold: true,
          )
        ],
      ),
    );
  }
}
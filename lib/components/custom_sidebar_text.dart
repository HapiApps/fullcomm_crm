import 'package:fullcomm_crm/common/extentions/lib_extensions.dart';
import 'package:flutter/material.dart';
import 'custom_text.dart';

class CustomSideBarText extends StatelessWidget {
  final String text;
  final VoidCallback onClicked;
  final Color textColor;
  final Color boxColor;
  const CustomSideBarText(
      {super.key,
      required this.text,
      required this.onClicked,
      required this.textColor,required this.boxColor});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClicked,
      child: Container(
        color: boxColor,
        height: 80,
        child: Row(
          children: [
            20.width,
            Text(
              text,
              textAlign: TextAlign.start,
              style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontFamily: "Lato",
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

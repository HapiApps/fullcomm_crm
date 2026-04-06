import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomerFieldWidgets {

  // Icon Button
  static Widget iconButton({required BuildContext context, required String toolTip,required String icon,required void Function() onPressed}){
    return Padding(
      padding: const EdgeInsets.only(right: 8,top: 5,bottom: 5),
      child: Tooltip(
        message: toolTip,
        child: InkWell(
            onTap: onPressed,
            child:  CircleAvatar(
              radius: 23,
             // backgroundColor: Colors.yellow.withOpacity(0.4),
              backgroundColor: Colors.transparent,
              child: SvgPicture.asset(icon),
            )
        ),
      ),
    );
  }

}
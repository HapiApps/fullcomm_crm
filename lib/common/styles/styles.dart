import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../controller/controller.dart';

final CustomStyle customStyle = CustomStyle._();

class CustomStyle {
  CustomStyle._();

  TextStyle textStyle(
      {Color? colors,
      double? size,
      TextDecoration? decoration,
      bool? isBold = false}) {
    return TextStyle(
        decoration: TextDecoration.none,
        color: colors,
        fontSize: size,
        fontWeight: isBold! ? FontWeight.bold : FontWeight.w200,
        fontFamily: "Lato");
  }

  InputDecoration inputDecoration(
      {String? text,
      bool? isIcon,
      bool? isLogin,
      IconData? iconData,
      String? image,
      VoidCallback? onPressed}) {
    return InputDecoration(
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      // hintText:text,
      hintText: "",
      hintStyle: TextStyle(
          color: Colors.grey.shade400, fontSize: 13, fontFamily: "Lato"),
      fillColor:
          text == "Search Name" ? Colors.grey.shade200 : Colors.transparent,
      filled: true,
      prefixIcon: isIcon == true
          ? IconButton(
              onPressed: onPressed,
              icon: text == "Search Name"
                  ? Icon(
                      iconData,
                      color: Colors.grey.shade400,
                    )
                  : SvgPicture.asset(image!, width: 15, height: 15))
          : null,
      suffixIcon: isLogin == true
          ? InkWell(
              onTap: () {
                Future.microtask(() {
                  controllers.isEyeOpen.value = !controllers.isEyeOpen.value;
                });
              },
              child: Icon(iconData, color: Colors.grey))
          : null,
      enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: text == "Search Name"
                ? Colors.grey.shade200
                : const Color(0xffE1E5FA),
          ),
          borderRadius: BorderRadius.circular(5)),
      focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: text == "Search Name"
                ? Colors.grey.shade200
                : const Color(0xffE1E5FA),
          ),
          borderRadius: BorderRadius.circular(5)),
      focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: text == "Search Name"
                  ? Colors.grey.shade200
                  : const Color(0xffE1E5FA)),
          borderRadius: BorderRadius.circular(5)),
      // errorStyle: const TextStyle(height:0.05,fontSize: 12),
      contentPadding:
          const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: text == "Search Name"
                  ? Colors.grey.shade200
                  : const Color(0xffE1E5FA)),
          borderRadius: BorderRadius.circular(5)),
    );
  }

  ButtonStyle buttonStyle({Color? color, double? radius}) {
    return ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius!)));
  }
}

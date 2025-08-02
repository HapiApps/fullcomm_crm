import 'package:flutter/material.dart';

final CustomDecoration customDecoration = CustomDecoration._();

class CustomDecoration{
  CustomDecoration._();
  BoxDecoration baseBackgroundDecoration({double? radius,
    Color? color,bool? isShadow, Color? shadowColor ,Color? borderColor}) {
      return BoxDecoration(
          borderRadius: BorderRadius.circular(radius!),
        color: color,
        border: Border.all(
          color: borderColor ?? Colors.transparent
        ),
        boxShadow: [
          if(isShadow==true)
           BoxShadow(
              color: shadowColor!,
              spreadRadius: 1,
              blurRadius:1,
              offset: const Offset(0.0,4)),
        ],
      );
}
}

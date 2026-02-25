import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // private constructor

  static const Color primary   = Color(0xff0078D7);
  static const Color secondary = Color(0xffFACF00);
  static const Color third     = Color(0xff283F4D);
  static const Color fourth    = Color(0xff007AFF);
  static const Color five      = Color(0xff14D6CA);

  static const Color white = Colors.white;
  static const Color black = Colors.black;

  // non-const (because of shade)
  static Color axis = Colors.grey.shade100;
}

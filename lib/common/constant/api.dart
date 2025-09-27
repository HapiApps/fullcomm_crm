import 'dart:ui';
import 'package:flutter/material.dart';

//const String domain          = "https://aruu.celwiz.com";
const String domain          = "https://aruu.in/";
const String version1        = "v1/CRM/web";
const String appName         = "ARUU’s EasyCRM";
const String scriptApi       = "$domain/CRM/script.php";
const String prospectsScript = "$domain/CRM/prospects_script.php";
const String qualifiedScript = "$domain/CRM/qualified_script.php";
const String getImage        = "$domain/CRM/get_files.php";
//https://aruu.celwiz.com/CRM/get_files.php?path=WhatsApp%20Image%202025-09-16%20at%2011.57.00%20AM.jpeg
class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        // etc.

      };
}

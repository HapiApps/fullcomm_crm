import 'dart:ui';
import 'package:flutter/material.dart';

const String domain = "https://aruu.celwiz.com";
const String version1 = "v1/CRM/web";
const String appName = "ARUU’s EasyCRM";
const String cosId = "202510";
const String scriptApi = "$domain/CRM/script.php";
const String prospectsScript = "$domain/CRM/prospects_script.php";
const String qualifiedScript = "$domain/CRM/qualified_script.php";

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        // etc.
      };
}

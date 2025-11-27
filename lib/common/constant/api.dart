import 'dart:ui';
import 'package:flutter/material.dart';


/// Aruu database
/// Dev
// const String domain      = "https://aruu.celwiz.com";
// const bool isRelease     = false;
// const String version     = "Version 0.0.7";
// const String versionNum  = "0.0.7";
// /// Prod
// // const String domain      = "https://aruu.in/";
// // const bool isRelease     = true;
// // const String version     = "Version 0.0.8";
// // const String versionNum  = "0.0.8";
// const String version1        = "v1/CRM/web";
// const String appName         = "ARUU’s EasyCRM";
// const String logo            = "assets/images/logo.png";
// const String loginLogo       = "assets/images/ARUU.png";
// const String scriptApi       = "$domain/CRM/script.php";
// const String prospectsScript = "$domain/CRM/prospects_script.php";
// const String qualifiedScript = "$domain/CRM/qualified_script.php";
// const String getImage        = "$domain/CRM/get_files.php";


/// Thirumal database
/// Dev
// const String domain      = "https://thirumald.hapirides.in";
// const bool isRelease     = false;
// const String version     = "Version 0.0.22";
// const String versionNum  = "0.0.22";
///Prod
const String domain      = "https://thirumal.hrides.in";
const bool isRelease     = true;
const String version     = "Version 0.0.26";
const String versionNum  = "0.0.26";
const String version1        = "CRM";
const String appName         = "Thirumal CRM";
const String logo            = "assets/images/thirumal.png";
const String loginLogo       = "assets/images/thirumal.png";
const String scriptApi       = "$domain/CRM/aruu_script.php";
const String prospectsScript = "$domain/CRM/prospects_script.php";
const String qualifiedScript = "$domain/CRM/qualified_script.php";
const String getImage        = "$domain/CRM/get_files.php";








class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

import 'dart:ui';
import 'package:flutter/material.dart';

// const String domain    = "https://crm.hapirides.in";
// const String version1  = "jps/v1";/devApps/
/// Thirumal
//dev
const String domain = "https://thirumald.hapirides.in"; // 9999999991
// prod
// const String domain    = "https://thirumal.hrides.in";//9999999999
//thirumald.hapirides.in/FullcommCRM/script.php
const String version1 = "v1/CRM/web";
//const String appName = "Hapi Apps";//202401
//const String appName   = "JPS";//202410
const String appName = "ARUU"; //202110
//const String appName = "Gotek";//202405
//const String appName = "NS Hydraulics";//202405

//const String cosId = "202110";
const String cosId = "202510"; // Thirumal
//const String cosId = "202504"; // JPS

const String scriptApi = "$domain/FullcommCRM/script.php";
const String prospectsScript = "$domain/FullcommCRM/prospects_script.php";
const String qualifiedScript = "$domain/FullcommCRM/qualified_script.php";
//const String insertLead      = "$domain/$version1/insert_lead.php";
const String updateLead = "$domain/$version1/update_lead.php";
const String login = "$domain/script.php";
//const String loginC          = "https://chakra.hrides.in/prod/v3/sign_on.php";
//const String mailReceive     = "$domain/$version1/mail_receive.php";
const String insertEmployee = "$domain/$version1/insert_employee.php";
const String insertUser = "$domain/$version1/insert_user.php";
const String insertCustomer = "$domain/$version1/insert_customer.php";
const String insertProduct = "$domain/$version1/insert_product.php";
const String insertCompany = "$domain/$version1/insert_company.php";
//const String insertProspects = "$domain/$version1/insert_prospects.php";
//const String insertQualified = "$domain/$version1/insert_qualified.php";
//const String getData         = "$domain/$version1/get_data.php";

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        // etc.
      };
}

import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fullcomm_crm/common/constant/api.dart';
import 'package:fullcomm_crm/common/utilities/jwt_storage.dart';
import 'package:fullcomm_crm/common/utilities/utils.dart';
import 'package:fullcomm_crm/controller/controller.dart';
import 'package:fullcomm_crm/controller/reminder_controller.dart';
import 'package:fullcomm_crm/controller/settings_controller.dart';
import 'package:fullcomm_crm/screens/DashboardPage.dart';

import '../api_services.dart';

extension AuthApi on ApiService {
  void loginCApi(context) async {
    try {
      Map data = {
        "mobile_number": controllers.loginNumber.text,
        "password": controllers.loginPassword.text,
        "action": "login_jwt"
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      debugPrint("request.body");
      debugPrint(request.body);

      final Map<String, dynamic> response = json.decode(request.body);

      controllers.loginCtr.reset();
      if (request.statusCode == 200 && response['status'] == 'success') {
        TokenStorage().writeToken(response['access_token']);
        TokenStorage().writeRefreshToken(response['refresh_token']);
        controllers.storage.write("f_name", response['user']['s_name']);
        controllers.storage.write("mobile", response['user']['s_mobile']);
        controllers.storage.write("role", response['user']['permission']);
        controllers.storage.write("id", response['user']['id']);
        controllers.storage.write("cos_id", response['user']["cos_id"]);
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool("loginScreen$versionNum", true);
        String input = "Admin";
        controllers.isAdmin.value = input == "Admin" ? true : false;
        prefs.setBool("isAdmin", controllers.isAdmin.value);
        prefs.remove("loginNumber");
        prefs.remove("loginPassword");
        getAllCallActivity("");
        getAllMailActivity();
        getAllMeetingActivity("");
        getAllNoteActivity();
        loginHistoryApi();
        allLeadsDetails();
        allNewLeadsDetails();
        allGoodLeadsDetails();
        allCustomerDetails();
        allQualifiedDetails();
        allTargetLeadsDetails();
        getUserHeading();
        getRoles();
        getSheet();
        getAllCustomers();
        getWhatsAppCustomers();
        getOpenedMailActivity(true);
        getReplyMailActivity(true);
        remController.allReminders("2");
        settingsController.allRoles();
        settingsController.allOfficeHours();
        Get.to(const DashboardPage(), duration: Duration.zero);
        controllers.loginCtr.reset();
      } else {
        controllers.loginCtr.reset();
        errorDialog(Get.context!, response['message'].toString());
      }
    } catch (e) {
      controllers.loginCtr.reset();
      errorDialog(Get.context!, 'Login failed: ${e.toString()}');
    }
  }

  void loginHistoryApi() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    WebBrowserInfo webBrowserInfo = await deviceInfo.webBrowserInfo;
    final allInfo = webBrowserInfo.data;
    try {
      Map data = {
        "mobile_number": controllers.loginNumber.text,
        "user_id": controllers.storage.read("id"),
        "cos_id": controllers.storage.read("cos_id"),
        "app_version": versionNum,
        "device_id": webBrowserInfo.productSub,
        "device_brand": allInfo.toString(),
        "device_model": webBrowserInfo.product,
        "device_os": webBrowserInfo.deviceMemory,
        "platform": "3",
        "action": "login_history"
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return loginHistoryApi();
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200) {
        debugPrint("Login history added success");
      } else {
        controllers.loginCtr.reset();
      }
    } catch (e) {
      controllers.loginCtr.reset();
    }
  }

  Future<void> sendOtpAPI({required String mobile}) async {
    try {
      Map data = {"mobile": "91$mobile", "action": "send_sms"};
      debugPrint(data.toString());
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));

      Map<String, dynamic> response = json.decode(request.body.trim());
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return sendOtpAPI(mobile: mobile);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200) {
        debugPrint("res $response");
        controllers.otp.value = response["otp"].toString();
        controllers.loginCtr.reset();
      } else {
        utils.snackBar(
            msg: response.toString(), color: Colors.red, context: Get.context!);
        controllers.loginCtr.reset();
      }
    } catch (e) {
      utils.snackBar(
          msg: e.toString(), color: Colors.red, context: Get.context!);
      controllers.loginCtr.reset();
    }
  }

  Future<void> resetPasswordAPI(
      {required String mobile, required String pass}) async {
    try {
      Map data = {
        "mobile_number": mobile,
        "password": pass,
        "updated_by": controllers.storage.read("id"),
        "cos_id": controllers.storage.read("cos_id"),
        "action": "forgot_password"
      };
      debugPrint(data.toString());
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));

      Map<String, dynamic> response = json.decode(request.body.trim());
      if (request.statusCode == 200) {
        debugPrint("res $response");
        controllers.storage.write("f_name", response["data"]["s_name"]);
        controllers.storage.write("role", response["data"]["permission"]);
        controllers.storage.write("role_name", "Admin");
        controllers.storage.write("id", response["data"]["id"]);
        controllers.storage.write("cos_id", response["data"]["cos_id"]);
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool("loginScreen$versionNum", true);
        String input = "Admin";
        controllers.isAdmin.value = input == "Admin" ? true : false;
        prefs.setBool("isAdmin", controllers.isAdmin.value);
        prefs.remove("loginNumber");
        prefs.remove("loginPassword");
        getAllCallActivity("");
        getAllMailActivity();
        getAllMeetingActivity("");
        getAllNoteActivity();
        loginHistoryApi();
        allLeadsDetails();
        allNewLeadsDetails();
        allGoodLeadsDetails();
        allCustomerDetails();
        allQualifiedDetails();
        allTargetLeadsDetails();
        getUserHeading();
        getRoles();
        getSheet();
        getAllCustomers();
        getWhatsAppCustomers();
        getInstagramCustomers();
        getOpenedMailActivity(true);
        getReplyMailActivity(true);
        remController.allReminders("2");
        settingsController.allRoles();
        settingsController.allOfficeHours();
        utils.snackBar(
          context: Get.context!,
          msg: "Password Updated Successfully",
          color: Colors.green,
        );
        Get.to(const DashboardPage(), duration: Duration.zero);
        controllers.loginCtr.reset();
      } else {
        utils.snackBar(
            msg: response.toString(), color: Colors.red, context: Get.context!);
        controllers.loginCtr.reset();
      }
    } catch (e) {
      utils.snackBar(
          msg: e.toString(), color: Colors.red, context: Get.context!);
      controllers.loginCtr.reset();
    }
  }

  Future<bool> checkMobileAPI({required String mobile}) async {
    try {
      Map data = {"mobile_number": mobile, "action": "check_mobile"};
      debugPrint(data.toString());
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));

      Map<String, dynamic> response = json.decode(request.body.trim());
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return checkMobileAPI(mobile: mobile);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200 && response.containsKey("s_name")) {
        debugPrint("res $response");
        controllers.loginCtr.reset();
        return true;
      } else {
        utils.snackBar(
            msg: "Mobile number not registered",
            color: Colors.red,
            context: Get.context!);
        controllers.loginCtr.reset();
        return false;
      }
    } catch (e) {
      utils.snackBar(
          msg: "Mobile number not registered",
          color: Colors.red,
          context: Get.context!);
      controllers.loginCtr.reset();
      return false;
    }
  }

  DateTime? parseExpiredDate(String s) {
    try {
      final input = s.trim();
      final df = DateFormat("dd-MM-yyyy h.mm a");
      return df.parseStrict(input);
    } catch (e) {
      try {
        final df2 = DateFormat("dd-MM-yyyy h:mm a");
        return df2.parseStrict(s);
      } catch (_) {
        return null;
      }
    }
  }

  Future currentVersion() async {
    try {
      Map data = {
        "search_type": "checkVersion",
        "version": versionNum,
        "cos_id": controllers.storage.read("cos_id"),
        "action": "get_data"
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      controllers.versionActive.value = false;
      controllers.updateAvailable.value = false;
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return currentVersion();
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200) {
        List response = json.decode(request.body);
        controllers.serverVersion.value = response[0]["current_version"];
        controllers.currentUserCount.value = response[0]["user_count"];
        controllers.planType.value = response[0]["plan_type"].toString();
        final expiredDate = parseExpiredDate(response[0]["expired_date"]);
        final now = DateTime.now();
        if (expiredDate != null && now.isAfter(expiredDate)) {
          utils.expiredDateDialog(response[0]["expired_date"]);
          controllers.versionActive.value = true;
          controllers.updateAvailable.value = false;
          return;
        }
        if (versionNum != controllers.serverVersion.value) {
          controllers.versionActive.value = true;
          if (response[0]["active"] == "1") {
            utils.updateDialog();
            controllers.updateAvailable.value = true;
          }
        }
      } else {
        controllers.versionActive.value = false;
      }
    } catch (e) {
      controllers.versionActive.value = false;
    }
  }
}
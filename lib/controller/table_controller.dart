import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fullcomm_crm/controller/controller.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common/constant/api.dart';
import '../common/utilities/jwt_storage.dart';
import '../common/utilities/utils.dart';
import '../services/api_services.dart';


final tableController = Get.put(TableController());
class TableController extends GetxController {

  RxMap<String, double> colWidth = <String, double>{}.obs;
  var defaultHeadings = [
    "Name",
    "Company Name",
    "Mobile Number",
    "Details Of Services Required",
    "Source Of Prospect",
    "Added Date",
    "City",
    "Status Update",
    "Designation",
    "Department",
    "Email",
    "Manager",
    "Prospect Source Details",
    "Expected Conversion Date",
    "Discussion Points",
    "Product Discussion",
    "Rating",
    "Status",
    "Total Number Of Head Count",
    "Expected Billing Value",
    "Arpu Value"
  ];
  var isLoading = false.obs;
  var headingFields = <String>[].obs;

  // void setHeadingFields(List<dynamic> data) async {
  //   try {
  //     headingFields.value = data
  //         .map((e) => controllers.formatHeading(e['user_heading'].toString()))
  //         .toList();
  //
  //     final prefs = await SharedPreferences.getInstance();
  //     final saved = prefs.getString('tableHeadings');
  //     if (saved != null) {
  //       final List<dynamic> decoded = jsonDecode(saved);
  //       final savedHeadings = decoded.cast<String>();
  //
  //       final combined = List<String>.from(savedHeadings);
  //       for (var i = 0; i < headingFields.length; i++) {
  //         if (i < combined.length) {
  //           combined[i] = headingFields[i];
  //         } else {
  //           combined.add(headingFields[i]);
  //         }
  //       }
  //       tableHeadings.value = combined;
  //     } else {
  //       tableHeadings.value = List<String>.from(headingFields);
  //     }
  //     for (var h in tableHeadings) {
  //       colWidth[h] = 150;
  //     }
  //     await prefs.setString('tableHeadings', jsonEncode(tableHeadings));
  //   } catch (e) {
  //     log("Set Heading fields error: $e");
  //   }
  // }
  ///TWO
  // void setHeadingFields(List<dynamic> data) async {
  //   try {
  //     // 1️⃣ API / incoming data
  //     log("Incoming data: $data");
  //
  //     headingFields.value = data
  //         .map((e) => controllers.formatHeading(e['user_heading'].toString()))
  //         .toList();
  //
  //     log("Formatted headingFields: ${headingFields.value}");
  //
  //     final prefs = await SharedPreferences.getInstance();
  //
  //     // 2️⃣ Local stored value
  //     final saved = prefs.getString('tableHeadings');
  //     log("Saved tableHeadings (raw): $saved");
  //
  //     if (saved != null) {
  //       final List<dynamic> decoded = jsonDecode(saved);
  //       final savedHeadings = decoded.cast<String>();
  //
  //       log("Saved headings (decoded): $savedHeadings");
  //
  //       final combined = List<String>.from(savedHeadings);
  //
  //       for (var i = 0; i < headingFields.length; i++) {
  //         if (i < combined.length) {
  //           combined[i] = headingFields[i];
  //         } else {
  //           combined.add(headingFields[i]);
  //         }
  //       }
  //
  //       tableHeadings.value = combined;
  //     } else {
  //       tableHeadings.value = List<String>.from(headingFields);
  //     }
  //
  //     // 3️⃣ Final headings used
  //     log("Final tableHeadings: ${tableHeadings.value}");
  //
  //     for (var h in tableHeadings) {
  //       colWidth[h] = 150;
  //     }
  //
  //     // 4️⃣ Saving back to local
  //     await prefs.setString('tableHeadings', jsonEncode(tableHeadings.value));
  //     log("Saved tableHeadings to local successfully");
  //
  //   } catch (e, s) {
  //     log(
  //       "Set Heading fields error",
  //       error: e,
  //       stackTrace: s,
  //     );
  //   }
  // }
  void setHeadingFields(List<dynamic> data) async {
    try {
      log("Incoming data: $data");

      final apiHeadings = data
          .map((e) => controllers.formatHeading(e['user_heading'].toString()))
          .toList();

      log("API headings: $apiHeadings");

      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('tableHeadings');

      List<String> finalHeadings;
      bool isChanged = false;

      if (saved != null) {
        final List<dynamic> decoded = jsonDecode(saved);
        final savedHeadings = decoded.cast<String>();

        log("Saved headings (order preserved): $savedHeadings");

        finalHeadings = List<String>.from(savedHeadings);
        // 🔥 only add NEW headings, keep order
        for (final h in apiHeadings) {
          if (!finalHeadings.contains(h)) {
            finalHeadings.add(h);
            isChanged = true;
            log("New heading added: $h");
          }
        }
      } else {
        // First time save
        finalHeadings = apiHeadings;
        isChanged = true;
      }

      tableHeadings.value = finalHeadings;
      log("Final tableHeadings (order kept): $finalHeadings");
      headingFields.value=finalHeadings;
      for (var h in tableHeadings) {
        colWidth[h] = 150;
      }

      // save ONLY if something changed
      if (isChanged) {
        await prefs.setString('tableHeadings', jsonEncode(finalHeadings));
        log("tableHeadings saved to local");
      } else {
        log("No change in headings, skip save");
      }
      log("FINAL HEADING ${headingFields}");
    } catch (e, s) {
      log(
        "Set Heading fields error",
        error: e,
        stackTrace: s,
      );
    }
  }

  void setHeadingFields2(List<dynamic> data) async {
    try {
      log("Incoming data: $data");

      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('tableHeadings');

      /// ---------- API MAP (system_field -> formatted heading)
      final Map<String, String> apiMap = {
        for (final e in data)
          e['system_field'].toString():
          controllers.formatHeading(e['user_heading'].toString())
      };

      log("API Map: $apiMap");

      Map<String, String> finalMap = {};
      bool isChanged = false;

      /// ---------- HANDLE OLD + NEW STORAGE
      if (saved != null) {
        final decoded = jsonDecode(saved);

        if (decoded is Map) {
          /// ✅ NEW FORMAT
          finalMap = decoded.map(
                (k, v) => MapEntry(k.toString(), v.toString()),
          );
          log("Loaded Map storage");
        } else if (decoded is List) {
          /// 🔁 OLD FORMAT (List<String>) → migrate
          log("Old List storage detected, migrating...");

          for (int i = 0; i < decoded.length && i < apiMap.length; i++) {
            finalMap[apiMap.keys.elementAt(i)] = decoded[i].toString();
          }
          isChanged = true;
        }
      }

      /// ---------- ADD / REPLACE LOGIC
      apiMap.forEach((key, value) {
        if (!finalMap.containsKey(key)) {
          finalMap[key] = value;
          isChanged = true;
          log("New heading added: $key -> $value");
        } else if (finalMap[key] != value) {
          finalMap[key] = value;
          isChanged = true;
          log("Heading replaced: $key -> $value");
        }
      });

      /// ---------- FINAL UI ORDER (API ORDER)
      final List<String> finalHeadings =
      apiMap.keys.map((k) => finalMap[k]!).toList();

      tableHeadings.value = finalHeadings;
      headingFields.value = finalHeadings;

      /// ---------- COLUMN WIDTH
      colWidth.clear();
      for (final h in finalHeadings) {
        colWidth[h] = 150;
      }

      /// ---------- SAVE ONLY IF CHANGED
      if (isChanged) {
        await prefs.setString('tableHeadings', jsonEncode(finalMap));
        log("tableHeadings saved (map format)");
      } else {
        log("No change in headings");
      }

      log("FINAL HEADINGS: $finalHeadings");
    } catch (e, s) {
      log(
        "Set Heading fields error",
        error: e,
        stackTrace: s,
      );
    }
  }


  RxBool isTableLoading = false.obs;
  RxList<String> tableHeadings = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    tableHeadings.value = headingFields.toSet().toList();
    for (var h in tableHeadings) {
      colWidth[h] = 150; // default width
    }
  }

  // Swap positions in drag-drop
  void reorderWords(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final word = headingFields.removeAt(oldIndex);
    headingFields.insert(newIndex, word);
  }

  // Apply changes (first 8 update table headings)
  void applyChanges()async{
    isTableLoading.value = true;
    tableHeadings.value = headingFields.toSet().toList();
    isTableLoading.value =false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tableHeadings', jsonEncode(tableHeadings.toList()));
  }

  // Cancel changes (restore default)
  void cancelChanges() async{
    // headingFields.value = [
    //   "Name",
    //   "Company Name",
    //   "Mobile Number",
    //   "Details Of Services Required",
    //   "Source Of Prospect",
    //   "Added Date",
    //   "City",
    //   "Status Update",
    //   "Designation",
    //   "Department",
    //   "Email",
    //   "Manager",
    //   "Prospect Source Details",
    //   "Expected Conversion Date",
    //   "Discussion Points",
    //   "Product Discussion",
    //   "Rating",
    //   "Status",
    //   "Total Number Of Head Count",
    //   "Expected Billing Value",
    //   "Arpu Value"
    // ];
    tableHeadings.value = headingFields.toSet().toList();
    for (var h in tableController.tableHeadings) {
      colWidth[h] = 150; // default width
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tableHeadings', jsonEncode(tableHeadings.toList()));
  }

  Future updateColumnNameAPI(BuildContext context,String heading,String id) async {
    try{
      Map data = {
        "action": "update_column_name",
        "id": id,
        "user_heading": heading,
        "updated_by": controllers.storage.read("id"),
        "cos_id": controllers.storage.read("cos_id")
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8")
      );
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return updateColumnNameAPI(context,heading,id);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200 && response["message"]=="Heading updated successfully"){
        apiService.getUserHeading();
        Navigator.pop(context);
        utils.snackBar(context: context, msg: "Heading updated successfully", color: Colors.green);
        controllers.productCtr.reset();
      } else {
        apiService.errorDialog(Get.context!,request.body);
        controllers.productCtr.reset();
      }
    }catch(e){
      apiService.errorDialog(Get.context!,e.toString());
      controllers.productCtr.reset();
    }
  }

  Future updateColumnAPI(BuildContext context,String heading,String value) async {
    try{
      Map data = {
        "action": "update_column",
        "old_value": heading,
        "user_heading": value,
        "updated_by": controllers.storage.read("id"),
        "cos_id": controllers.storage.read("cos_id")
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8")
      );
      Map<String, dynamic> response = json.decode(request.body);
      print("jdckdjck");
      print(data);
      print(request.body);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return updateColumnAPI(context,heading,value);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200 && response["message"]=="Heading updated successfully"){
        apiService.getUserHeading2();
        Navigator.pop(context);
        utils.snackBar(context: context, msg: "Heading updated successfully", color: Colors.green);
        controllers.productCtr.reset();
      } else {
        apiService.errorDialog(Get.context!,request.body);
        controllers.productCtr.reset();
      }
    }catch(e){
      apiService.errorDialog(Get.context!,e.toString());
      controllers.productCtr.reset();
    }
  }

  Future addColumnNameAPI(BuildContext context,String heading) async {
    try{
      Map data = {
        "action": "add_column_name",
        "user_heading": heading,
        "created_by": controllers.storage.read("id"),
        "cos_id": controllers.storage.read("cos_id")
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8")
      );
      print(request.body);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return addColumnNameAPI(context,heading);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200 ){
        Navigator.pop(context);
        apiService.getUserHeading();
        utils.snackBar(context: context, msg: "Heading added successfully", color: Colors.green);
        controllers.productCtr.reset();
      } else {
        apiService.errorDialog(Get.context!,request.body);
        controllers.productCtr.reset();
      }
    }catch(e){
      apiService.errorDialog(Get.context!,e.toString());
      controllers.productCtr.reset();
    }
  }

}
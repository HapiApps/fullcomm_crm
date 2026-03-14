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

  // void setHeading(List<dynamic> data) async {
  //   log("Set Heading 1");
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
  /// changed 9 mar
  // void setHeading(List<dynamic> data) async {
  //   print("Set Heading 1");
  //
  //   try {
  //     headingFields.value = data
  //         .map((e) => controllers.formatHeading(e['user_heading'].toString()))
  //         .toList();
  //
  //     print("Heading Fields: $headingFields");
  //
  //     final prefs = await SharedPreferences.getInstance();
  //     print("SharedPreferences loaded");
  //
  //     final saved = prefs.getString('tableHeadings');
  //     print("Saved value: $saved");
  //
  //     if (saved != null) {
  //       final decoded = jsonDecode(saved);
  //       print("Decoded: $decoded");
  //
  //       List<String> savedHeadings = [];
  //
  //       if (decoded is List) {
  //         savedHeadings = decoded.cast<String>();
  //         print("Decoded is List");
  //       } else if (decoded is Map) {
  //         savedHeadings = decoded.values.map((e) => e.toString()).toList();
  //         print("Decoded is Map");
  //       }
  //
  //       final combined = List<String>.from(savedHeadings);
  //
  //       for (var i = 0; i < headingFields.length; i++) {
  //         print("Loop index: $i");
  //
  //         if (i < combined.length) {
  //           combined[i] = headingFields[i];
  //         } else {
  //           combined.add(headingFields[i]);
  //         }
  //       }
  //
  //       tableHeadings.value = combined;
  //       print("Table Headings: $tableHeadings");
  //
  //     } else {
  //       print("No saved data");
  //       tableHeadings.value = List<String>.from(headingFields);
  //     }
  //
  //     for (var h in tableHeadings) {
  //       colWidth[h] = 150;
  //     }
  //
  //     await prefs.setString('tableHeadings', jsonEncode(tableHeadings));
  //     print("Saved to SharedPreferences");
  //
  //   } catch (e) {
  //     print("Set Heading fields error: $e");
  //   }
  // }
  /// March 14
  // void setHeading(List<dynamic> data) async {
  //   print("Set Heading 1");
  //
  //   try {
  //     headingFields.value = data
  //         .map((e) => controllers.formatHeading(e['user_heading'].toString()))
  //         .toList();
  //
  //     print("Heading Fields: $headingFields");
  //
  //     final prefs = await SharedPreferences.getInstance();
  //     final saved = prefs.getString('tableHeadings');
  //
  //     if (saved != null) {
  //       final decoded = jsonDecode(saved);
  //
  //       List<String> savedHeadings = [];
  //
  //       if (decoded is List) {
  //         savedHeadings = decoded.cast<String>();
  //       }
  //
  //       print("Saved Headings: $savedHeadings");
  //
  //       // saved list base
  //       final combined = List<String>.from(savedHeadings);
  //
  //       // new headings மட்டும் add
  //       for (var h in headingFields) {
  //         if (!combined.contains(h)) {
  //           combined.add(h);
  //         }
  //       }
  //       for (var h in tableHeadings) {
  //         colWidth[h] = 150;
  //       }
  //       tableHeadings.value = combined;
  //
  //     } else {
  //       tableHeadings.value = List<String>.from(headingFields);
  //     }
  //
  //     print("Final Headings: ${tableHeadings.value}");
  //
  //     await prefs.setString(
  //         'tableHeadings', jsonEncode(tableHeadings.value));
  //
  //   } catch (e) {
  //     print("Set Heading fields error: $e");
  //   }
  // }
  void setHeading(List<dynamic> data) async {
    print("Set Heading 1");

    try {
      // normalize function
      String normalize(String s) => s.trim().toLowerCase();

      // API headings
      headingFields.value = data
          .map((e) => controllers
          .formatHeading(e['user_heading'].toString().trim()))
          .toList();

      print("Heading Fields: $headingFields");

      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('tableHeadings');

      List<String> combined = [];

      if (saved != null) {
        final decoded = jsonDecode(saved);

        List<String> savedHeadings = [];

        if (decoded is List) {
          savedHeadings = decoded.cast<String>();
        }

        print("Saved Headings: $savedHeadings");

        combined = List<String>.from(savedHeadings);

        // add new headings (case-insensitive check)
        for (var h in headingFields) {
          if (!combined.any((e) => normalize(e) == normalize(h))) {
            combined.add(h);
          }
        }

      } else {
        combined = List<String>.from(headingFields);
      }

      // remove duplicates safely
      final uniqueHeadings = <String>[];
      final seen = <String>{};

      for (var h in combined) {
        if (!seen.contains(normalize(h))) {
          seen.add(normalize(h));
          uniqueHeadings.add(h);
        }
      }

      tableHeadings.value = uniqueHeadings;

      // set column width
      for (var h in tableHeadings) {
        colWidth[h] = colWidth[h] ?? 150;
      }

      print("Final Headings: ${tableHeadings.value}");

      await prefs.setString(
        'tableHeadings',
        jsonEncode(tableHeadings.value),
      );

    } catch (e) {
      print("Set Heading fields error: $e");
    }
  }
  void setHeadingFields(List<dynamic> data) async {
    try {
      log("Incoming data: $data");

      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('tableHeadings');

      /// API headings map
      Map<String, String> apiMap = {};
      for (var e in data) {
        String system = e['system_field'].toString();
        String heading =
        controllers.formatHeading(e['user_heading'].toString());
        apiMap[system] = heading;
      }

      log("API Map: $apiMap");

      Map<String, String> savedMap = {};
      bool isChanged = false;

      if (saved != null) {
        dynamic decoded;

        try {
          decoded = jsonDecode(saved);
        } catch (e) {
          decoded = null;
        }

        if (decoded is Map) {
          savedMap =
              decoded.map((k, v) => MapEntry(k.toString(), v.toString()));
        }

        log("Saved Map: $savedMap");

        /// update or add
        apiMap.forEach((key, value) {
          if (!savedMap.containsKey(key)) {
            savedMap[key] = value;
            isChanged = true;
            log("New column added: $value");
          } else if (savedMap[key] != value) {
            savedMap[key] = value;
            isChanged = true;
            log("Heading renamed: $value");
          }
        });
      } else {
        savedMap = apiMap;
        isChanged = true;
      }

      /// final headings list
      List<String> finalHeadings = savedMap.values.toList();

      tableHeadings.value = finalHeadings;
      headingFields.value = finalHeadings;

      log("Final tableHeadings: $finalHeadings");

      /// column width
      for (var h in finalHeadings) {
        colWidth[h] = 150;
      }

      /// save
      if (isChanged) {
        await prefs.setString('tableHeadings', jsonEncode(savedMap));
        log("tableHeadings saved to local");
      }

      log("FINAL HEADING ${headingFields.value}");
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
    print("Heading List: ${tableController.headingFields.toList()}");

    print("savedpp");
    print("done");
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
        apiService.getHeading();
        utils.snackBar(context: context, msg: "Heading updated successfully", color: Colors.green);
        controllers.productCtr.reset();
      } else {
        apiService.errorDialog(Get.context!,request.body);
        controllers.productCtr.reset();
      }
      tableController.isLoading.value=false;
    }catch(e){
      tableController.isLoading.value=false;
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
        apiService.getHeading();
        // Navigator.pop(context);
        utils.snackBar(context: context, msg: "Heading updated successfully", color: Colors.green);
        controllers.productCtr.reset();
      } else {
        apiService.errorDialog(Get.context!,request.body);
        controllers.productCtr.reset();
      }
    }catch(e){
      print(e);
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
        apiService.getHeading();
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
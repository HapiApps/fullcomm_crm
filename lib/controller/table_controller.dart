import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fullcomm_crm/controller/controller.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/constant/api.dart';
import '../common/utilities/utils.dart';
import '../services/api_services.dart';


final tableController = Get.put(TableController());
class TableController extends GetxController {
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
  var headingFields = <String>[].obs;
  void setHeadingFields(List<dynamic> data) async {
    try {
      headingFields.value = data
          .map((e) => controllers.formatHeading(e['user_heading'].toString()))
          .toList();

      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('tableHeadings');
      if (saved != null) {
        final List<dynamic> decoded = jsonDecode(saved);
        final savedHeadings = decoded.cast<String>();

        final combined = List<String>.from(savedHeadings);
        for (var i = 0; i < headingFields.length; i++) {
          if (i < combined.length) {
            combined[i] = headingFields[i];
          } else {
            combined.add(headingFields[i]);
          }
        }

        tableHeadings.value = combined;
      } else {
        tableHeadings.value = List<String>.from(headingFields);
      }
      print("Saved Headings: $headingFields");
      print("tableHeadings Headings: $tableHeadings");
      await prefs.setString('tableHeadings', jsonEncode(tableHeadings));
    } catch (e) {
      print("Set Heading fields error: $e");
    }
  }



  RxBool isTableLoading = false.obs;
  RxList<String> tableHeadings = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    tableHeadings.value = headingFields.toSet().toList();
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
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8")
      );
      print("request ${request.body}");
      Map<String, dynamic> response = json.decode(request.body);
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

}
import 'dart:convert';

import 'package:fullcomm_crm/controller/controller.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';


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
  void setHeadingFields(List<dynamic> data) async{
    try{
      headingFields.value = data.map((e) => controllers.formatHeading(e['user_heading'].toString())).toList();
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('tableHeadings');

      if (saved != null) {
        final List<dynamic> decoded = jsonDecode(saved);
        tableHeadings.value = decoded.cast<String>();
      } else {
        tableHeadings.value = headingFields.toList();
      }
    }catch(e){
      print("Set Heading fields $e");
    }
  }

  RxBool isTableLoading = false.obs;
  RxList<String> tableHeadings = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    tableHeadings.value = headingFields.toList();
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
    tableHeadings.value = headingFields.toList();
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
    tableHeadings.value = headingFields.toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tableHeadings', jsonEncode(tableHeadings.toList()));
  }
}
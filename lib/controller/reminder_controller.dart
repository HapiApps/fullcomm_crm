
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/utilities/utils.dart';
import 'package:fullcomm_crm/services/api_services.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../common/constant/api.dart';
import '../models/customer_activity.dart';
import '../models/reminder_obj.dart';
import '../provider/reminder_provider.dart';
import 'controller.dart';

final remController = Get.put(ReminderController());

class ReminderController extends GetxController with GetSingleTickerProviderStateMixin {
  TextEditingController titleController       = TextEditingController();
  TextEditingController detailsController     = TextEditingController();
  TextEditingController startController       = TextEditingController();
  TextEditingController endController         = TextEditingController();
  String? location;
  String? repeat;
  String defaultTime = "Immediately";

  TextEditingController updateTitleController   = TextEditingController();
  TextEditingController updateDetailsController = TextEditingController();
  TextEditingController updateStartController   = TextEditingController();
  TextEditingController updateEndController     = TextEditingController();
  String? updateLocation;
  String? updateRepeat;

  var sortFieldCallActivity = ''.obs;
  var setType = ''.obs;
  var sortOrderCallActivity = 'asc'.obs;
  var searchText = ''.obs;
  var reminderList = <ReminderModel>[].obs;
  var selectedReminderIds = <String>[].obs;
  var selectedMeetingIds = <String>[].obs;
  var selectedRecordMailIds = <String>[].obs;
  var selectedRecordCallIds = <String>[].obs;
  RxList<CustomerActivity> callFilteredList = <CustomerActivity>[].obs;

  void filterAndSortCalls({
    required List<CustomerActivity> allCalls,
    required String searchText,
    required String callType,
    required String sortField,
    required String sortOrder,
  }) {
    final filtered = allCalls.where((activity) {
      final matchesCallType =
          callType.isEmpty || callType == "All" || activity.callType == callType;
      final matchesSearch = searchText.isEmpty ||
          activity.customerName.toLowerCase().contains(searchText) ||
          activity.toData.toLowerCase().contains(searchText);

      return matchesCallType && matchesSearch;
    }).toList();
    if (sortField == 'customerName') {
      filtered.sort((a, b) {
        final nameA = a.customerName.toLowerCase();
        final nameB = b.customerName.toLowerCase();
        final comparison = nameA.compareTo(nameB);
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    } else if (sortField == 'mobile') {
      filtered.sort((a, b) {
        final nameA = a.toData.toLowerCase();
        final nameB = b.toData.toLowerCase();
        final comparison = nameA.compareTo(nameB);
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    } else if (sortField == 'date') {
      DateTime parseDate(String dateStr) {
        try {
          return DateFormat("dd.MM.yyyy hh:mm a").parse(dateStr);
        } catch (e) {
          return DateTime(1900);
        }
      }
      filtered.sort((a, b) {
        final dateA = parseDate(a.sentDate);
        final dateB = parseDate(b.sentDate);
        final comparison = dateA.compareTo(dateB);
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }
    callFilteredList.assignAll(filtered);
  }

  var sortBy = ''.obs;
  var ascending = true.obs;
  void sortReminders() {
    if (sortFieldCallActivity.value.isEmpty) return;

    final sorted = [...reminderList];
    final dateFormatter = DateFormat("dd-MM-yyyy h:mm a");

    sorted.sort((a, b) {
      dynamic aValue;
      dynamic bValue;
      switch (sortFieldCallActivity.value) {
        case 'customerName':
          aValue = a.customerName.toLowerCase();
          bValue = b.customerName.toLowerCase();
          break;
        case 'employeeName':
          aValue = a.employeeName.toLowerCase();
          bValue = b.employeeName.toLowerCase();
          break;
        case 'startDate':
          try {
            aValue = dateFormatter.parse(a.startDt);
            bValue = dateFormatter.parse(b.endDt);
          } catch (e) {
            aValue = DateTime(1900);
            bValue = DateTime(1900);
          }
          break;
        case 'endDate':
          try {
            aValue = dateFormatter.parse(a.endDt);
            bValue = dateFormatter.parse(b.endDt);
          } catch (e) {
            aValue = DateTime(1900);
            bValue = DateTime(1900);
          }
          break;
        default:
          aValue = '';
          bValue = '';
      }

      int result;
      if (aValue is String && bValue is String) {
        result = aValue.compareTo(bValue);
      } else if (aValue is DateTime && bValue is DateTime) {
        result = aValue.compareTo(bValue);
      } else {
        result = 0;
      }

      return sortOrderCallActivity.value == 'asc' ? result : -result;
    });
    reminderList.assignAll(sorted);
  }

  bool isCheckedReminder(String id) {
    return selectedReminderIds.contains(id);
  }
  void toggleReminderSelection(String id) {
    if (selectedReminderIds.contains(id)) {
      selectedReminderIds.remove(id);
    } else {
      selectedReminderIds.add(id);
    }
  }

  bool isCheckedMeeting(String id) {
    return selectedMeetingIds.contains(id);
  }
  void selectAllCalls() {
    selectedRecordCallIds.assignAll(callFilteredList.map((e) => e.id.toString()).toList());
  }

  void unselectAllCalls() {
    selectedRecordCallIds.clear();
  }
  void toggleMeetingSelection(String id) {
    if (selectedMeetingIds.contains(id)) {
      selectedMeetingIds.remove(id);
    } else {
      selectedMeetingIds.add(id);
    }
  }

  bool isCheckedRecordCall(String id) {
    return selectedRecordCallIds.contains(id);
  }
  void toggleRecordSelectionCall(String id) {
    if (selectedRecordCallIds.contains(id)) {
      selectedRecordCallIds.remove(id);
    } else {
      selectedRecordCallIds.add(id);
    }
  }

  bool isCheckedRecordMAil(String id) {
    return selectedRecordMailIds.contains(id);
  }
  void toggleRecordSelectionMail(String id) {
    if (selectedRecordMailIds.contains(id)) {
      selectedRecordMailIds.remove(id);
    } else {
      selectedRecordMailIds.add(id);
    }
  }
  var isLoadingReminders = false.obs;
  var followUpReminderCount = 0.obs;
  var meetingReminderCount = 0.obs;
  Future<void> allReminders(String type) async {
    isLoadingReminders.value = true;

    final url = Uri.parse(scriptApi);
    try {
      final response = await http.post(
        url,
        body: jsonEncode({
          "action": "get_data",
          "type": type,
          "cos_id": controllers.storage.read("cos_id"),
          "search_type": "allReminders"
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List) {
          reminderList.value = data.map((e) => ReminderModel.fromJson(e)).toList();
          int followUpCount = reminderList
              .where((r) => r.type.toString() == '1').length;
          int meetingCount = reminderList
              .where((r) => r.type.toString() == '2')
              .length;

          followUpReminderCount.value = followUpCount;
          meetingReminderCount.value = meetingCount;
        } else {
          reminderList.value = [];
          followUpReminderCount.value = 0;
          meetingReminderCount.value = 0;
        }
      } else {
        reminderList.value = [];
        followUpReminderCount.value = 0;
        meetingReminderCount.value = 0;
        print("Failed to load reminders: ${response.body}");
      }
    } catch (e) {
      reminderList.value = [];
      followUpReminderCount.value = 0;
      meetingReminderCount.value = 0;
      print("Error fetching reminders: $e");
    } finally {
      isLoadingReminders.value = false;
    }
  }

  Future insertReminderAPI(BuildContext context,String type) async {
    try{
      Map data = {
        "action": "insert_reminder",
        "title": titleController.text.trim(),
        "type": type,
        "location": location,
        "repeat_type": repeat,
        "employee": controllers.selectedEmployeeId.value,
        "customer": controllers.selectedCustomerId.value,
        "start_dt": startController.text.trim(),
        "end_dt": endController.text.trim(),
        "details": detailsController.text.trim(),
        "set_time": defaultTime,
        "set_type": "Email",
        "created_by": controllers.storage.read("id"),
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
      if (request.statusCode == 200 && response["message"]=="Reminder added successfully"){
         titleController.clear();
         location=null;
         repeat=null;
         controllers.clearSelectedEmployee();
         controllers.clearSelectedCustomer();
         startController.clear();
         endController.clear();
         detailsController.clear();
         final provider = Provider.of<ReminderProvider>(context, listen: false);
         provider.selectedNotification = "followup";
        allReminders(type);
        Navigator.pop(context);
        utils.snackBar(context: context, msg: "Reminder added successfully", color: Colors.green);
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

  Future updateReminderAPI(BuildContext context,String type,String id) async {
    try{
      Map data = {
        "action": "update_reminder",
        "id": id,
        "title": updateTitleController.text.trim(),
        "type": type,
        "location": updateLocation,
        "repeat_type": updateRepeat,
        "employee": controllers.selectedEmployeeId.value,
        "customer": controllers.selectedCustomerId.value,
        "start_dt": updateStartController.text.trim(),
        "end_dt": updateEndController.text.trim(),
        "details": updateDetailsController.text.trim(),
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
      if (request.statusCode == 200 && response["message"]=="Reminder updated successfully"){
        allReminders(type);
        Navigator.pop(context);
        utils.snackBar(context: context, msg: "Reminder updated successfully", color: Colors.green);
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

  Future insertSettingsReminderAPI(BuildContext context,String time) async {
    try{
      Map data = {
        "action": "insert_settings_reminder",
        "type": "Email",
        "time": time,
        "created_by": controllers.storage.read("id"),
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
      if (request.statusCode == 200 && response["message"]=="Settings added successfully"){
        Navigator.pop(context);
        utils.snackBar(context: context, msg: "Settings added successfully", color: Colors.green);
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

  Future deleteReminderAPI(BuildContext context) async {
    try{
      Map data = {
        "action": "delete_reminder",
        "user_id": controllers.storage.read("id"),
        "cos_id": controllers.storage.read("cos_id"),
        "empList": selectedReminderIds,
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8")
      );
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 200 && response["message"]=="OK"){
        allReminders("type");
        Navigator.pop(context);
        utils.snackBar(context: context, msg: "Reminder deleted successfully.", color: Colors.green);
        controllers.productCtr.reset();
        selectedReminderIds.clear();
      } else {
        apiService.errorDialog(Get.context!,request.body);
        controllers.productCtr.reset();
      }
    }catch(e){
      apiService.errorDialog(Get.context!,e.toString());
      controllers.productCtr.reset();
    }
  }

  Future<void> deleteMeetingAPI(BuildContext context) async {
    try {
      Map<String, dynamic> data = {
        "user_id": controllers.storage.read("id"),
        "cos_id": controllers.storage.read("cos_id"),
        "meetingList": selectedMeetingIds,
        "action": "delete_meeting",
      };
      print("Request: ${jsonEncode(data)}");
      final response = await http.post(
        Uri.parse(scriptApi), // your endpoint for delete_meeting.php
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode(data),
      );

      Map<String, dynamic> result = json.decode(response.body);
      print("Response: ${response.body}");

      if (response.statusCode == 200 && result["message"] == "OK") {
        apiService.getAllMeetingActivity("");
        Navigator.pop(context);
        utils.snackBar(
          context: context,
          msg: "Meeting deleted successfully.",
          color: Colors.green,
        );
        controllers.productCtr.reset();
        selectedMeetingIds.clear();
      } else {
        apiService.errorDialog(Get.context!, result["message"] ?? "Failed to delete meeting.");
        controllers.productCtr.reset();
      }
    } catch (e) {
      apiService.errorDialog(Get.context!, e.toString());
      controllers.productCtr.reset();
    }
  }


  Future<void> deleteRecordCallAPI(BuildContext context) async {
    try {
      Map<String, dynamic> data = {
        "action": "delete_record",
        "user_id": controllers.storage.read("id"),
        "cos_id": controllers.storage.read("cos_id"),
        "recordList": selectedRecordCallIds,
      };
      print("delete record $data");
      final response = await http.post(
        Uri.parse(scriptApi),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode(data),
      );
      print("Response body: ${response.body}");
      Map<String, dynamic> result = json.decode(response.body);
      if (response.statusCode == 200 && result["message"] == "OK") {
        Navigator.pop(context);
        apiService.getAllCallActivity("");
        apiService.getAllMailActivity();
        utils.snackBar(
          context: context,
          msg: "Call Record deleted successfully.",
          color: Colors.green,
        );
        controllers.productCtr.reset();
        selectedRecordCallIds.clear();

      } else {
        apiService.errorDialog(
          Get.context!,
          result["message"] ?? "Failed to delete call record.",
        );
        controllers.productCtr.reset();
      }
    } catch (e) {
      apiService.errorDialog(Get.context!, e.toString());
      controllers.productCtr.reset();
    }
  }


  Future<void> deleteRecordMailAPI(BuildContext context) async {
    try {
      Map<String, dynamic> data = {
        "action": "delete_record",
        "user_id": controllers.storage.read("id"),
        "cos_id": controllers.storage.read("cos_id"),
        "recordList": selectedRecordMailIds,
      };
      print("Response bodyjsonEncode(data): ${jsonEncode(data)}");
      final response = await http.post(
        Uri.parse(scriptApi),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode(data),
      );

      print("Response body: ${response.body}");

      Map<String, dynamic> result = json.decode(response.body);

      if (response.statusCode == 200 && result["message"] == "OK") {
        Navigator.pop(context);
        utils.snackBar(
          context: context,
          msg: "Mail Record deleted successfully.",
          color: Colors.green,
        );
        controllers.productCtr.reset();
        selectedRecordMailIds.clear();
      } else {
        apiService.errorDialog(
          Get.context!,
          result["message"] ?? "Failed to delete mail record.",
        );
        controllers.productCtr.reset();
      }
    } catch (e) {
      apiService.errorDialog(Get.context!, e.toString());
      controllers.productCtr.reset();
    }
  }


}
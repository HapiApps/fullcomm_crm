
import 'dart:convert';
import 'package:fullcomm_crm/services/api_services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../common/constant/api.dart';
import '../models/reminder_obj.dart';
import 'controller.dart';

final remController = Get.put(ReminderController());

class ReminderController extends GetxController with GetSingleTickerProviderStateMixin {
  TextEditingController titleController   = TextEditingController();
  TextEditingController detailsController   = TextEditingController();
  String? location;
  String? repeat;
  TextEditingController startController = TextEditingController();
  TextEditingController endController = TextEditingController();
  var reminderList = <ReminderModel>[].obs;
  var selectedReminderIds = <String>[].obs;
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
        allReminders(type);
        Navigator.pop(context);
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
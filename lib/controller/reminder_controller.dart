
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../common/constant/api.dart';
import '../models/reminder_obj.dart';
import 'controller.dart';

final remController = Get.put(ReminderController());

class ReminderController extends GetxController with GetSingleTickerProviderStateMixin {
  TextEditingController titleController   = TextEditingController();
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


}
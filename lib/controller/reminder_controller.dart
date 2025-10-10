
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
  var isLoadingReminders = false.obs;

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
      print("input ${{
        "action": "get_data",
        "type": type,
        "cos_id": controllers.storage.read("cos_id"),
        "search_type": "allReminders"
      }}");
     isLoadingReminders.value = false;
     print("Out put ${response.body}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          reminderList.value =
              data.map((e) => ReminderModel.fromJson(e)).toList();
        } else {
          reminderList.value = [];
        }
      } else {
        reminderList.value = [];
        print("Failed to load reminders: ${response.body}");
      }
    } catch (e) {
      reminderList.value = [];
      print("Error fetching reminders: $e");
    } finally {
      isLoadingReminders.value = false;
    }
  }

}
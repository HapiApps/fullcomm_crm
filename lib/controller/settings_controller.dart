import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fullcomm_crm/models/office_hours_obj.dart';
import 'package:fullcomm_crm/models/role_obj.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../common/constant/api.dart';
import '../common/utilities/utils.dart';
import '../services/api_services.dart';
import 'controller.dart';

final settingsController = Get.put(SettingsController());

class SettingsController extends GetxController with GetSingleTickerProviderStateMixin {
  TextEditingController roleController          = TextEditingController();
  TextEditingController descriptionController   = TextEditingController();
  TextEditingController updateRoleController    = TextEditingController();
  TextEditingController upDescriptionController = TextEditingController();
  TextEditingController daysController          = TextEditingController();
  TextEditingController shiftController         = TextEditingController();
  String? permission;
  String? updatePermission;
  var searchText = ''.obs;
  var searchOfficeText = ''.obs;
  var sortRoleField = 'name'.obs;
  var sortRoleOrder = 'asc'.obs;
  var fromTime = TimeOfDay(hour: 9, minute: 0).obs;
  var toTime = TimeOfDay(hour: 18, minute: 0).obs;

  Future<void> pickTime(BuildContext context, bool isFrom) async {
    final initialTime = isFrom ? fromTime.value : toTime.value;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime != null) {
      if (isFrom) {
        fromTime.value = pickedTime;
      } else {
        toTime.value = pickedTime;
      }
    }
  }

  String formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute $period";
  }

  void sortRoleByName() {
    sortRoleField.value = 'name';
    sortRoleOrder.value = sortRoleOrder.value == 'asc' ? 'desc' : 'asc';

    roleList.sort((a, b) {
      final nameA = a.roleName.toLowerCase();
      final nameB = b.roleName.toLowerCase();
      final comparison = nameA.compareTo(nameB);
      return sortRoleOrder.value == 'asc' ? comparison : -comparison;
    });

    roleList.refresh();
  }
  List<String> permissionList = [
    "See All Customer Records",
    "Only My Customer Records"
  ];
  var selectedRoleIds = <String>[].obs;
  bool isCheckedRole(String id) {
    return selectedRoleIds.contains(id);
  }
  void toggleReminderSelection(String id) {
    if (selectedRoleIds.contains(id)) {
      selectedRoleIds.remove(id);
    } else {
      selectedRoleIds.add(id);
    }
  }
  Future updateRoleAPI(BuildContext context,String id) async {
    try{
      Map data = {
        "action": "update_role",
        "role_name": updateRoleController.text.trim(),
        "description": upDescriptionController.text.trim(),
        "permission": updatePermission,
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
      if (request.statusCode == 200 && response["message"]=="Role updated successfully"){
        allRoles();
        Navigator.pop(context);
        utils.snackBar(context: context, msg: "Role updated successfully", color: Colors.green);
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

  Future insertRoleAPI(BuildContext context) async {
    try{
      Map data = {
        "action": "insert_role",
        "role_name": roleController.text.trim(),
        "description": descriptionController.text.trim(),
        "permission": permission,
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
      if (request.statusCode == 200 && response["message"]=="Role added successfully"){
        roleController.clear();
        descriptionController.clear();
        permission=null;
        allRoles();
        Navigator.pop(context);
        utils.snackBar(context: context, msg: "Role added successfully", color: Colors.green);
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

  Future insertOfficeHourAPI(BuildContext context) async {
    try{
      Map data = {
        "action": "insert_office_hours",
        "employee": controllers.selectedEmployeeId.value,
        "shift_name": shiftController.text.trim(),
        "from_time": settingsController.formatTime(fromTime.value),
        "to_time": settingsController.formatTime(toTime.value),
        "days": daysController.text.trim(),
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
      if (request.statusCode == 200 && response["message"]=="Office hour added successfully"){
        allOfficeHours();
        Navigator.pop(context);
        utils.snackBar(context: context, msg: "Office hour added successfully", color: Colors.green);
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
  var isLoadingRoles = false.obs;
  var rolesCount = 0.obs;
  var roleList = <RoleModel>[].obs;
  Future<void> allRoles() async {
    isLoadingRoles.value = true;

    final url = Uri.parse(scriptApi);
    try {
      final response = await http.post(
        url,
        body: jsonEncode({
          "action": "get_data",
          "cos_id": controllers.storage.read("cos_id"),
          "search_type": "settings_roles"
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
          final List<dynamic> rolesJson = data;
          roleList.value = rolesJson.map((json) => RoleModel.fromJson(json)).toList();
          rolesCount.value = roleList.length;
      } else {
        roleList.value = [];
        rolesCount.value = 0;
        print("Failed to load reminders: ${response.body}");
      }
    } catch (e) {
      roleList.value = [];
      rolesCount.value = 0;
      print("Error fetching reminders: $e");
    } finally {
      isLoadingRoles.value = false;
    }
  }

  var isLoadingOfficeHours = false.obs;
  var officeHoursCount = 0.obs;
  var officeHoursList = <OfficeHoursObj>[].obs;
  Future<void> allOfficeHours() async {
    isLoadingOfficeHours.value = true;

    final url = Uri.parse(scriptApi);
    try {
      final response = await http.post(
        url,
        body: jsonEncode({
          "action": "get_data",
          "cos_id": controllers.storage.read("cos_id"),
          "search_type": "all_office_hours"
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> rolesJson = data;
        officeHoursList.value = rolesJson.map((json) => OfficeHoursObj.fromJson(json)).toList();
        officeHoursCount.value = officeHoursList.length;
      } else {
        officeHoursList.value = [];
        officeHoursCount.value = 0;
        print("Failed to load reminders: ${response.body}");
      }
    } catch (e) {
      officeHoursList.value = [];
      officeHoursCount.value = 0;
      print("Error fetching reminders: $e");
    } finally {
      isLoadingOfficeHours.value = false;
    }
  }

  Future deleteRoleAPI(BuildContext context) async {
    try{
      Map data = {
        "action": "delete_role",
        "user_id": controllers.storage.read("id"),
        "cos_id": controllers.storage.read("cos_id"),
        "roleList": selectedRoleIds,
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
         allRoles();
        Navigator.pop(context);
        utils.snackBar(context: context, msg: "Role deleted successfully.", color: Colors.green);
        controllers.productCtr.reset();
        selectedRoleIds.clear();
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
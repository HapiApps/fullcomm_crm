import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/models/office_hours_obj.dart';
import 'package:fullcomm_crm/models/role_obj.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../common/constant/api.dart';
import '../common/constant/colors_constant.dart';
import '../common/utilities/utils.dart';
import '../components/custom_loading_button.dart';
import '../components/custom_text.dart';
import '../components/custom_textfield.dart';
import '../models/template_obj.dart';
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
  void sortRole() {
    sortRoleOrder.value = sortRoleOrder.value == 'asc' ? 'desc' : 'asc';
    int compareStrings(String? a, String? b) {
      final sa = (a ?? '').toLowerCase();
      final sb = (b ?? '').toLowerCase();
      return sa.compareTo(sb);
    }
    int comparePermissions(dynamic pa, dynamic pb) {
      String normalize(dynamic p) {
        if (p == null) return '';
        if (p is List) return p.join(',').toLowerCase();
        return p.toString().toLowerCase();
      }
      return normalize(pa).compareTo(normalize(pb));
    }
    final orderFactor = sortRoleOrder.value == 'asc' ? 1 : -1;
    roleList.sort((a, b) {
      int cmp = 0;
      switch (sortRoleField.value) {
        case 'description':
          cmp = compareStrings(a.description, b.description);
          if (cmp == 0) cmp = compareStrings(a.roleName, b.roleName);
          break;
        case 'permissions':
          cmp = comparePermissions(a.permission, b.permission);
          if (cmp == 0) cmp = compareStrings(a.roleName, b.roleName);
          break;
        case 'name':
        default:
          cmp = compareStrings(a.roleName, b.roleName);
      }
      return orderFactor * cmp;
    });
    roleList.refresh();
  }
  var sortOfficeHourField = 'name'.obs;
  var sortOfficeHourOrder = 'asc'.obs;
  void sortOfficeHour() {
    int compareStrings(String? a, String? b) {
      final sa = (a ?? '').toLowerCase();
      final sb = (b ?? '').toLowerCase();
      return sa.compareTo(sb);
    }
    int compareDates(String? a, String? b) {
      final da = (a == null || a.isEmpty) ? null : DateTime.tryParse(a);
      final db = (b == null || b.isEmpty) ? null : DateTime.tryParse(b);

      if (da == null && db == null) return 0;
      if (da == null) return -1;
      if (db == null) return 1;
      return da.compareTo(db);
    }
    final orderFactor = sortOfficeHourOrder.value == 'asc' ? 1 : -1;
    officeHoursList.sort((a, b) {
      int comparison = 0;
      switch (sortOfficeHourField.value) {
        case 'name':
          comparison = compareStrings(a.employeeName, b.employeeName);
          if (comparison == 0) {
            comparison = compareStrings(a.shiftName, b.shiftName);
          }
          break;
        case 'shift':
          comparison = compareStrings(a.shiftName, b.shiftName);
          if (comparison == 0) {
            comparison = compareStrings(a.employeeName, b.employeeName);
          }
          break;
        case 'from':
          comparison = compareStrings(a.fromTime, b.fromTime);
          if (comparison == 0) {
            comparison = compareStrings(a.employeeName, b.employeeName);
          }
          break;
        case 'to':
          comparison = compareStrings(a.toTime, b.toTime);
          if (comparison == 0) {
            comparison = compareStrings(a.employeeName, b.employeeName);
          }
          break;
        case 'days':
          comparison = compareStrings(a.days, b.days);
          if (comparison == 0) {
            comparison = compareStrings(a.employeeName, b.employeeName);
          }
          break;
        case 'date':
          comparison = compareDates(a.updatedTs, b.updatedTs);
          if (comparison == 0) {
            comparison = compareStrings(a.employeeName, b.employeeName);
          }
          break;
        default:
          comparison = compareStrings(a.employeeName, b.employeeName);
          if (comparison == 0) comparison = compareStrings(a.shiftName, b.shiftName);
      }

      return orderFactor * comparison;
    });
    officeHoursList.refresh();
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
  var selectedOfficeIds = <String>[].obs;
  bool isCheckedOffice(String id) {
    return selectedOfficeIds.contains(id);
  }
  void toggleOfficeSelection(String id) {
    if (selectedOfficeIds.contains(id)) {
      selectedOfficeIds.remove(id);
    } else {
      selectedOfficeIds.add(id);
    }
  }
  void toggleSelectAllOffices() {
    bool allSelected = officeHoursList.every((office) => selectedOfficeIds.contains(office.id));
    if (allSelected) {
      selectedOfficeIds.clear();
    } else {
      selectedOfficeIds.assignAll(officeHoursList.map((office) => office.id));
    }
  }

  Future deleteOfficeHoursAPI(BuildContext context) async {
    try{
      Map data = {
        "action": "delete_office_hours",
        "user_id": controllers.storage.read("id"),
        "cos_id": controllers.storage.read("cos_id"),
        "officeList": selectedOfficeIds,
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
      if (request.statusCode == 200 && response["message"]=="OK"){
        allOfficeHours();
        Navigator.pop(context);
        utils.snackBar(context: context, msg: "Office Hours deleted successfully.", color: Colors.green);
        controllers.productCtr.reset();
        selectedOfficeIds.clear();
      } else {
        apiService.errorDialog(Get.context!,request.body);
        controllers.productCtr.reset();
      }
    }catch(e){
      apiService.errorDialog(Get.context!,e.toString());
      controllers.productCtr.reset();
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
        "cos_id": controllers.storage.read("cos_id"),
        "id": id
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
        controllers.clearSelectedEmployee();
        shiftController.clear();
        fromTime.value = TimeOfDay(hour: 9, minute: 0);
        toTime.value = TimeOfDay(hour: 18, minute: 0);
        daysController.clear();
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

  Future insertTemplateAPI(BuildContext context) async {
    try{
      Map data = {
        "action": "add_template",
        "template_name": addNameController.text.trim(),
        "subject": addSubjectController.text.trim(),
        "message": addMessageController.text.trim(),
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
      if (request.statusCode == 200 && response["message"]=="Templates added successfully"){
        addNameController.clear();
        addSubjectController.clear();
        addMessageController.clear();
        allTemplates();
        Navigator.pop(context);
        utils.snackBar(context: context, msg: "Templates added successfully", color: Colors.green);
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

  Future updateTemplateAPI(BuildContext context,String id) async {
    try{
      Map data = {
        "action": "update_template",
        "template_name": addNameController.text.trim(),
        "subject": addSubjectController.text.trim(),
        "message": addMessageController.text.trim(),
        "updated_by": controllers.storage.read("id"),
        "cos_id": controllers.storage.read("cos_id"),
        "id": id
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
      if (request.statusCode == 200 && response["message"]=="Template updated successfully"){
        addNameController.clear();
        addSubjectController.clear();
        addMessageController.clear();
        allTemplates();
        Navigator.pop(context);
        utils.snackBar(context: context, msg: "Template updated successfully", color: Colors.green);
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

  var isLoadingTemplates = false.obs;
  var templateCount = 0.obs;
  var templateList = <TemplateModel>[].obs;
  Future<void> allTemplates() async {
    isLoadingTemplates.value = true;
    final url = Uri.parse(scriptApi);
    try {
      final response = await http.post(
        url,
        body: jsonEncode({
          "action": "get_data",
          "cos_id": controllers.storage.read("cos_id"),
          "search_type": "templates"
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> rolesJson = data;
        templateList.value = rolesJson.map((json) => TemplateModel.fromJson(json)).toList();
        templateCount.value = templateList.length;
      } else {
        templateList.value = [];
        templateCount.value = 0;
        print("Failed to load template: ${response.body}");
      }
    } catch (e) {
      templateList.value = [];
      templateCount.value = 0;
      print("Error fetching template: $e");
    } finally {
      isLoadingTemplates.value = false;
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

  final addNameController    = TextEditingController();
  final addSubjectController = TextEditingController();
  final addMessageController = TextEditingController();

  void showAddTemplateDialog(BuildContext context, {bool isEdit = false,String id = ""}) {
    String? nameError;
    String? subjectError;
    String? messageError;
    Get.dialog(
        StatefulBuilder(
          builder: (context, setState) {
            return
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          "${isEdit?"Update":"Add"} New Template",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    hintText: "Template Name",
                    text: "Template Name",
                    controller: addNameController,
                    width: 480,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    isOptional: true,
                    errorText: nameError,
                    onChanged: (value) {
                      if (value.toString().isNotEmpty) {
                        setState(() {
                          nameError = null;
                        });
                      }
                    },
                  ),
                  CustomTextField(
                    hintText: "Subject",
                    text: "Subject",
                    controller: addSubjectController,
                    width: 480,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    isOptional: true,
                    errorText: subjectError,
                    onChanged: (value) {
                      if (value.toString().isNotEmpty) {
                        setState(() {
                          subjectError = null;
                        });
                      }
                    },
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CustomText(
                            text:"Message",
                            colors: colorsConst.textColor,
                            size: 13,
                            isCopy: false,
                          ),
                          const CustomText(
                            text: "*",
                            colors: Colors.red,
                            size: 25,
                            isCopy: false,
                          )
                        ],
                      ),
                      SizedBox(
                        width: 480,
                        height: 100,
                        child: TextField(
                          controller: addMessageController,
                          maxLines: null,
                          expands: true,
                          textAlign: TextAlign.start,
                          onChanged: (value) {
                            if (value.toString().isNotEmpty) {
                              setState(() {
                                messageError = null;
                              });
                            }
                          },

                          decoration: InputDecoration(
                            hintText: "Message",
                            errorText: messageError,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(
                                color: Color(0xffE1E5FA),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(
                                color: Color(0xffE1E5FA),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color: colorsConst.primary),
                    color: Colors.white),
                width: 80,
                height: 25,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      backgroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: CustomText(
                      text: "Cancel",
                      colors: colorsConst.primary,
                      size: 14,
                      isCopy: false,
                    )),
              ),
              10.width,
              CustomLoadingButton(
                callback: (){
                  if(addNameController.text.isEmpty){
                    nameError = "Please enter template name";
                    return;
                  }
                  if(addSubjectController.text.isEmpty){
                    subjectError = "Please enter subject";
                    return;
                  }
                  if(addMessageController.text.isEmpty){
                    messageError = "Please enter message";
                    return;
                  }
                  if(isEdit){
                    updateTemplateAPI(context, id);
                    return;
                  }
                  insertTemplateAPI(context);
                },
                height: 35,
                isLoading: true,
                backgroundColor: colorsConst.primary,
                radius: 2,
                width: 80,
                controller: controllers.productCtr,
                isImage: false,
                text: "Save",
                textColor: Colors.white,
              ),
              5.width
            ],
          ),
        ],
      );
            })
    );
  }


}
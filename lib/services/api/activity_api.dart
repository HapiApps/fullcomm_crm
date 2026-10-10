import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:fullcomm_crm/common/constant/api.dart';
import 'package:fullcomm_crm/common/utilities/jwt_storage.dart';
import 'package:fullcomm_crm/common/utilities/reminder_utils.dart';
import 'package:fullcomm_crm/common/utilities/utils.dart';
import 'package:fullcomm_crm/controller/controller.dart';
import 'package:fullcomm_crm/controller/dashboard_controller.dart';
import 'package:fullcomm_crm/controller/reminder_controller.dart';
import 'package:fullcomm_crm/models/comments_obj.dart';
import 'package:fullcomm_crm/models/customer_activity.dart';
import 'package:fullcomm_crm/models/mail_receive_obj.dart';
import 'package:fullcomm_crm/models/meeting_obj.dart';

import '../api_services.dart';

extension ActivityApi on ApiService {

  Future insertCallCommentAPI(BuildContext context, String type) async {
    try {
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            "action": "insert_call_comments",
            "customer_id": controllers.selectedCustomerId.value,
            "mobile_number": controllers.selectedCustomerMobile.value,
            "customer_name": controllers.selectedCustomerName.value,
            "type": type,
            "cos_id": controllers.storage.read("cos_id"),
            "call_type": controllers.callType,
            "call_status": controllers.callStatus,
            "date":
            "${controllers.empDOB.value} ${controllers.callTime.value}",
            "created_by": controllers.storage.read("id"),
            "comments": controllers.callCommentCont.text.trim(),
          }),
          encoding: Encoding.getByName("utf-8"));
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return await insertCallCommentAPI(context, type);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200 && response["message"] == "OK") {
        controllers.callTime.value = "";
        controllers.callType = "Outgoing";
        controllers.callStatus = "Contacted";
        remController.titleController.text = "Follow-up calling";
        remController.detailsController.text = controllers.callCommentCont.text;
        controllers.callCommentCont.text = "";
        controllers.selectCallType.value = "All";
        remController.selectedCallSortBy.value = "All";
        getAllCallActivity("");
        Navigator.pop(context);
        controllers.productCtr.reset();
        if (remController.stDate.value.isEmpty) {
          try {
            String raw = controllers.empDOB.value;
            DateTime d;
            if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(raw)) {
              d = DateFormat("yyyy-MM-dd").parse(raw);
            } else if (RegExp(r'^\d{2}\.\d{2}\.\d{4}$').hasMatch(raw)) {
              d = DateFormat("dd.MM.yyyy").parse(raw);
            } else {
              d = DateTime.parse(raw);
            }
            d = d.add(const Duration(days: 3));
            remController.stDate.value = DateFormat("dd.MM.yyyy").format(d);
          } catch (e) {
            debugPrint(
                "DATE PARSE ERROR: $e   value='${remController.stDate.value}'");
          }
        }
        remController.stTime.value = "11:00 AM";
        reminderUtils.showAddReminderDialog(context);
      } else {
        errorDialog(Get.context!, request.body);
        controllers.productCtr.reset();
      }
    } on SocketException {
      controllers.productCtr.reset();
      errorDialog(Get.context!, 'No internet connection');
    } on HttpException catch (e) {
      controllers.productCtr.reset();
      errorDialog(Get.context!, 'Server error promote: ${e.toString()}');
    } catch (e) {
      errorDialog(Get.context!, e.toString());
      controllers.productCtr.reset();
    }
  }

  Future updateCallCommentAPI(
      BuildContext context, String type, String id) async {
    try {
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            "action": "update_call_comments",
            "customer_id": controllers.selectedCustomerId.value,
            "mobile_number": controllers.selectedCustomerMobile.value,
            "customer_name": controllers.selectedCustomerName.value,
            "type": type,
            "cos_id": controllers.storage.read("cos_id"),
            "call_type": controllers.callType,
            "call_status": controllers.callStatus,
            "date":
            "${controllers.empDOB.value} ${controllers.callTime.value}",
            "updated_by": controllers.storage.read("id"),
            "comments": controllers.callCommentCont.text.trim(),
            "id": id
          }),
          encoding: Encoding.getByName("utf-8"));
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return await updateCallCommentAPI(context, type, id);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200 &&
          response["message"] == "Record updated successfully") {
        controllers.clearSelectedCustomer();
        controllers.empDOB.value = "";
        controllers.callTime.value = "";
        controllers.callType = "Outgoing";
        controllers.callStatus = "Contacted";
        controllers.callCommentCont.text = "";
        getAllCallActivity("");
        Navigator.pop(context);
        controllers.productCtr.reset();
      } else {
        errorDialog(Get.context!, request.body);
        controllers.productCtr.reset();
      }
    } on SocketException {
      controllers.productCtr.reset();
      errorDialog(Get.context!, 'No internet connection');
    } on HttpException catch (e) {
      controllers.productCtr.reset();
      errorDialog(Get.context!, 'Server error promote: ${e.toString()}');
    } catch (e) {
      errorDialog(Get.context!, e.toString());
      controllers.productCtr.reset();
    }
  }

  Future getAllCallActivity(String cusId) async {
    try {
      Map data = {
        "search_type": "records",
        "cos_id": controllers.storage.read("cos_id"),
        "action": "get_data",
        "type": "7",
        "cus_id": cusId
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return getAllCallActivity(cusId);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200) {
        List response = json.decode(request.body);
        controllers.callActivity.clear();
        controllers.callActivity.value =
            response.map((e) => CustomerActivity.fromJson(e)).toList();
        controllers.allCalls.value = response.length.toString();
        remController.filterAndSortCalls(
          allCalls: controllers.callActivity,
          searchText: controllers.searchText.value.toLowerCase(),
          callType: controllers.selectCallType.value,
          sortField: controllers.sortFieldCallActivity.value,
          sortOrder: controllers.sortOrderCallActivity.value,
          selectedMonth: remController.selectedCallMonth.value,
          selectedRange: remController.selectedCallRange.value,
          selectedDateFilter: remController.selectedCallSortBy.value,
        );
      } else {
        controllers.allIncomingCalls.value = "0";
        controllers.allOutgoingCalls.value = "0";
        controllers.allMissedCalls.value = "0";
        controllers.callActivity.clear();
        throw Exception('Failed to load album Recordssss');
      }
    } catch (e) {
      controllers.allIncomingCalls.value = "0";
      controllers.allOutgoingCalls.value = "0";
      controllers.allMissedCalls.value = "0";
      controllers.callActivity.clear();
      throw Exception('Failed to load album Recordssss');
    }
  }

  Future getMailCallActivity() async {
    try {
      Map data = {
        "search_type": "mails_calls",
        "cos_id": controllers.storage.read("cos_id"),
        "action": "get_data",
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return getMailCallActivity();
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200) {
        List response = json.decode(request.body);
        remController.callMailsDetailsList2.clear();

        remController.callMailsDetailsList2.value =
            response.map((e) => CustomerActivity.fromJson(e)).toList();

        remController.dashboardCommunicationFilterList(
          dataList: remController.callMailsDetailsList2,
          searchText: controllers.searchText.value.toLowerCase(),
          callType: controllers.selectCallType.value,
          sortField: controllers.sortFieldCallActivity.value,
          sortOrder: controllers.sortOrderCallActivity.value,
          selectedMonth: remController.selectedCallMonth.value,
          selectedRange: remController.selectedCallRange.value,
          selectedDateFilter: remController.selectedCallSortBy.value,
        );
      } else {
        controllers.allIncomingCalls.value = "0";
        controllers.allOutgoingCalls.value = "0";
        controllers.allMissedCalls.value = "0";
        controllers.callActivity.clear();
        throw Exception('Failed to load album Recordssss');
      }
    } catch (e) {
      controllers.allIncomingCalls.value = "0";
      controllers.allOutgoingCalls.value = "0";
      controllers.allMissedCalls.value = "0";
      controllers.callActivity.clear();
      throw Exception('Failed to load album Recordssss');
    }
  }

  Map<String, int> getStatusCountMap() {
    final Map<String, int> map = {};

    for (var item in remController.callFilteredList) {
      final status = item.callStatus.trim();
      if (status.isEmpty) continue;

      map[status] = (map[status] ?? 0) + 1;
    }
    return map;
  }

  void mergeStatusWithCount() {
    final Map<String, int> statusCountMap = {};

    for (var item in remController.callFilteredList) {
      final status = item.callStatus.trim();
      if (status.isEmpty) continue;

      statusCountMap[status] = (statusCountMap[status] ?? 0) + 1;
    }
    controllers.hCallStatusList.value = controllers.hCallStatusList.map((item) {
      final statusValue = item["value"]?.toString();

      return {
        ...item,
        "count": statusCountMap[statusValue] ?? 0,
      };
    }).toList();

    controllers.allCalls.value =
        remController.callFilteredList.length.toString();
  }


  Future insertMeetingDetailsAPI(BuildContext context) async {
    try {
      Map data = {
        "action": "insert_meeting_details",
        "employee": controllers.selectedEmployeeId.value,
        "cus_id": controllers.selectedCustomerId.value,
        "com_name": controllers.selectedCompanyName.value,
        "cus_name": controllers.selectedCustomerName.value,
        "title": controllers.meetingTitleCrt.text.trim(),
        "cos_id": controllers.storage.read("cos_id"),
        "venue": controllers.meetingVenueCrt.text.trim(),
        "dates": "${controllers.fDate.value}||${controllers.toDate.value}",
        "times": "${controllers.fTime.value}||${controllers.toTime.value}",
        "created_by": controllers.storage.read("id"),
        "notes": controllers.callCommentCont.text.trim(),
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      log(request.body);
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return insertMeetingDetailsAPI(context);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200 && response["message"] == "OK") {
        getAllMeetingActivity("");
        controllers.clearSelectedCustomer();
        controllers.meetingTitleCrt.text = "";
        controllers.meetingVenueCrt.text = "";
        controllers.fDate.value = "";
        controllers.toDate.value = "";
        controllers.fTime.value = "";
        controllers.toTime.value = "";
        controllers.callCommentCont.text = "";
        Navigator.pop(context);
        controllers.productCtr.reset();
      } else {
        errorDialog(Get.context!, request.body);
        controllers.productCtr.reset();
      }
    } on SocketException {
      controllers.productCtr.reset();
      errorDialog(Get.context!, 'No internet connection');
    } on HttpException catch (e) {
      controllers.productCtr.reset();
      errorDialog(Get.context!, 'Server error promote: ${e.toString()}');
    } catch (e) {
      errorDialog(Get.context!, e.toString());
      controllers.productCtr.reset();
    }
  }

  Future updateMeetingDetailsAPI(BuildContext context, String id) async {
    try {
      Map data = {
        "action": "update_meeting_details",
        "cus_id": controllers.selectedCustomerId.value,
        "employee": controllers.selectedEmployeeId.value,
        "com_name": controllers.selectedCompanyName.value,
        "cus_name": controllers.selectedCustomerName.value,
        "title": controllers.meetingTitleCrt.text.trim(),
        "cos_id": controllers.storage.read("cos_id"),
        "venue": controllers.meetingVenueCrt.text.trim(),
        "dates": "${controllers.fDate.value}||${controllers.toDate.value}",
        "times": "${controllers.fTime.value}||${controllers.toTime.value}",
        "created_by": controllers.storage.read("id"),
        "id": id,
        "notes": controllers.callCommentCont.text.trim(),
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return updateMeetingDetailsAPI(context, id);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200 && response["message"] == "OK") {
        getAllMeetingActivity("");
        controllers.clearSelectedCustomer();
        controllers.meetingTitleCrt.text = "";
        controllers.meetingVenueCrt.text = "";
        controllers.fDate.value = "";
        controllers.toDate.value = "";
        controllers.fTime.value = "";
        controllers.toTime.value = "";
        controllers.callCommentCont.text = "";
        Navigator.pop(context);
        controllers.productCtr.reset();
      } else {
        errorDialog(Get.context!, request.body);
        controllers.productCtr.reset();
      }
    } on SocketException {
      controllers.productCtr.reset();
      errorDialog(Get.context!, 'No internet connection');
    } on HttpException catch (e) {
      controllers.productCtr.reset();
      errorDialog(Get.context!, 'Server error promote: ${e.toString()}');
    } catch (e) {
      errorDialog(Get.context!, e.toString());
      controllers.productCtr.reset();
    }
  }

  Future updateAppointmentStatus(BuildContext context, String status) async {
    try {
      Map data = {
        "created_by": controllers.storage.read("id"),
        "cos_id": controllers.storage.read("cos_id"),
        "status": status,
        "idList": remController.selectedMeetingIds.value,
        "action": "appointment_status"
      };

      final request = await http.post(
        Uri.parse(scriptApi),
        body: jsonEncode(data),
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
      );
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return updateAppointmentStatus(context, status);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200) {
        utils.snackBar(
            msg: "Status Updated Successfully",
            color: Colors.green,
            context: Get.context!);
        remController.selectedMeetingIds.clear();
        getAllMeetingActivity("");
        Navigator.pop(Get.context!);
        remController.selectedMeetSortBy.value =
            dashController.selectedSortBy.value;
        remController.dashboardMeetings(
          searchText: controllers.searchText.value.toLowerCase(),
          callType: controllers.selectMeetingType.value,
          sortField: controllers.sortFieldMeetingActivity.value,
          sortOrder: controllers.sortOrderMeetingActivity.value,
        );
        controllers.emailCtr.reset();
      } else {
        controllers.emailCtr.reset();
        errorDialog(Get.context!, "Status Updated Failed");
      }
    } catch (e) {
      errorDialog(Get.context!, e.toString());
      controllers.emailCtr.reset();
    }
  }

  Future getAllMeetingActivity(String cusId) async {
    try {
      Map data = {
        "search_type": "meeting_details",
        "cos_id": controllers.storage.read("cos_id"),
        "action": "get_data",
        "cus_id": cusId
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      debugPrint(data.toString());
      debugPrint(request.body);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return getAllMeetingActivity(cusId);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200) {
        List response = json.decode(request.body);
        controllers.meetingActivity.clear();
        controllers.meetingActivity.value =
            response.map((e) => MeetingObj.fromJson(e)).toList();
        remController.sortMeetings(
          searchText: controllers.searchText.value.toLowerCase(),
          callType: controllers.selectMeetingType.value,
          sortField: controllers.sortFieldMeetingActivity.value,
          sortOrder: controllers.sortOrderMeetingActivity.value,
        );
        remController.dashboardMeetings(
          searchText: controllers.searchText.value.toLowerCase(),
          callType: controllers.selectMeetingType.value,
          sortField: controllers.sortFieldMeetingActivity.value,
          sortOrder: controllers.sortOrderMeetingActivity.value,
        );
      } else {
        throw Exception('Failed to load album');
      }
    } catch (e) {
      controllers.allScheduleMeet.value = "0";
      controllers.allCompletedMeet.value = "0";
      controllers.allCancelled.value = "0";
      throw Exception('Failed to load album');
    }
  }


  Future getAllNoteActivity() async {
    try {
      Map data = {
        "search_type": "records",
        "cos_id": controllers.storage.read("cos_id"),
        "action": "get_data",
        "type": "10"
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return getAllNoteActivity();
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200) {
        List response = json.decode(request.body);
        controllers.noteActivity.clear();
        controllers.noteActivity.value =
            response.map((e) => CustomerActivity.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load album');
      }
    } catch (e) {
      throw Exception('Failed to load album');
    }
  }


  Future<List<CommentsObj>> allCommentDetails(String id) async {
    controllers.allDirectVisit.value = "0";
    controllers.allTelephoneCalls.value = "0";
    final url = Uri.parse(scriptApi);
    try {
      final response = await http.post(
        url,
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "search_type": "customer_comments",
          "id": id,
          "cos_id": controllers.storage.read("cos_id"),
          "action": "get_data"
        }),
      );
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return allCommentDetails(id);
        } else {
          controllers.setLogOut();
        }
      }
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        var type1Count = data.where((item) => item['type'] == "1").length;
        var type2Count = data.where((item) => item['type'] == "2").length;
        controllers.allDirectVisit.value = type1Count.toString();
        controllers.allTelephoneCalls.value = type2Count.toString();
        return data.map((json) => CommentsObj.fromJson(json)).toList();
      } else {
        controllers.allDirectVisit.value = "0";
        controllers.allTelephoneCalls.value = "0";
        throw Exception(
            'Failed to load products: Status code ${response.body}');
      }
    } on SocketException {
      controllers.allDirectVisit.value = "0";
      controllers.allTelephoneCalls.value = "0";
      throw Exception('No internet connection');
    } on HttpException catch (e) {
      controllers.allDirectVisit.value = "0";
      controllers.allTelephoneCalls.value = "0";
      throw Exception('Server error product: ${e.toString()}');
    } catch (e) {
      controllers.allDirectVisit.value = "0";
      controllers.allTelephoneCalls.value = "0";
      throw Exception('Unexpected error product: ${e.toString()}');
    }
  }

  Future<List<CommentsObj>> allCommentReportDetails() async {
    controllers.allDirectVisit.value = "0";
    controllers.allTelephoneCalls.value = "0";
    final url = Uri.parse(scriptApi);
    try {
      final response = await http.post(
        url,
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "search_type": "mail_receive",
          "id": controllers.storage.read("id"),
          "role": controllers.storage.read("role"),
          "cos_id": controllers.storage.read("cos_id"),
          "action": "get_data"
        }),
      );
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return allCommentReportDetails();
        } else {
          controllers.setLogOut();
        }
      }
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        var type1Count = data.where((item) => item['type'] == "1").length;
        var type2Count = data.where((item) => item['type'] == "2").length;
        controllers.allDirectVisit.value = type1Count.toString();
        controllers.allTelephoneCalls.value = type2Count.toString();
        return data.map((json) => CommentsObj.fromJson(json)).toList();
      } else {
        controllers.allDirectVisit.value = "0";
        controllers.allTelephoneCalls.value = "0";
        throw Exception(
            'Failed to load products: Status code ${response.body}');
      }
    } on SocketException {
      controllers.allDirectVisit.value = "0";
      controllers.allTelephoneCalls.value = "0";
      throw Exception('No internet connection');
    } on HttpException catch (e) {
      controllers.allDirectVisit.value = "0";
      controllers.allTelephoneCalls.value = "0";
      throw Exception('Server error product: ${e.toString()}');
    } catch (e) {
      controllers.allDirectVisit.value = "0";
      controllers.allTelephoneCalls.value = "0";
      throw Exception('Unexpected error product: ${e.toString()}');
    }
  }

  Future<List<MailReceiveObj>> mailCommentDetails(String id) async {
    final url = Uri.parse(scriptApi);
    try {
      final response = await http.post(
        url,
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "search_type": "mail_comments",
          "id": id,
          "cos_id": controllers.storage.read("cos_id"),
          "action": "get_data"
        }),
      );
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return mailCommentDetails(id);
        } else {
          controllers.setLogOut();
        }
      }
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((json) => MailReceiveObj.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load products: Status code ${response.body}');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on HttpException catch (e) {
      throw Exception('Server error product: ${e.toString()}');
    } catch (e) {
      throw Exception('Unexpected error product: ${e.toString()}');
    }
  }
}
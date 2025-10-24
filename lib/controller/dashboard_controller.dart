import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/constant/colors_constant.dart';
import 'package:fullcomm_crm/services/api_services.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../common/constant/api.dart';
import '../models/month_report_obj.dart';
import 'controller.dart';

final dashController = Get.put(DashboardController());

class DashboardController extends GetxController {
  var totalMails       = "0".obs;
  var totalEmployees   = "0".obs;
  var totalMeetings    = "0".obs;
  var pendingMeetings  = "0".obs;
  var completedMeetings = "0".obs;
  var totalCalls       = "0".obs;
  var totalWarm        = "0".obs;
  var totalCold        = "0".obs;
  var totalHot         = "0".obs;
  var totalSuspects    = "0".obs;
  var totalProspects   = "0".obs;
  var totalQualified   = "0".obs;
  var totalUnQualified = "0".obs;
  var totalCustomers   = "0".obs;
  var dayReport = <CustomerDayData>[].obs;
  RxBool isLoading = false.obs;

  final List<String> filters = [
    "Today",
    "Yesterday",
    "Last 7 Days",
    "Last 30 Days",
  ];
  var selectedSortBy = 'Today'.obs;
  var selectedRange = Rxn<DateTimeRange>(); // null-safe observable
  var isDateRangeSet = false.obs;

  void setDateRange(PickerDateRange range) {
    if (range.startDate != null && range.endDate != null) {
      selectedRange.value = DateTimeRange(
        start: range.startDate!,
        end: range.endDate!,
      );
      isDateRangeSet.value = true;
    }
  }

  void clearDateRange() {
    selectedRange.value = null;
    isDateRangeSet.value = false;
  }

  void showDatePickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        dynamic tempRange;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xffFFFCF9),
              title: const Text(
                'Select Date',
                style: TextStyle(
                  color: Color(0xFF004AAD),
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SizedBox(
                height: 300,
                width: 350,
                child: SfDateRangePicker(
                  backgroundColor: const Color(0xffFFFCF9),
                  minDate: DateTime(2023),
                  maxDate: DateTime.now(),
                  selectionMode: DateRangePickerSelectionMode.range,
                  selectionShape: DateRangePickerSelectionShape.circle,
                  selectionRadius: 18,
                  selectionColor: const Color(0xFF004AAD),
                  startRangeSelectionColor: const Color(0xFF004AAD),
                  endRangeSelectionColor: const Color(0xFF004AAD),
                  rangeSelectionColor: const Color(0x22004AAD),
                  monthCellStyle: const DateRangePickerMonthCellStyle(
                    textStyle: TextStyle(
                      fontSize: 14,
                      height: 1.0,
                      color: Colors.black87,
                    ),
                    todayTextStyle: TextStyle(
                      fontSize: 14,
                      height: 1.0,
                      color: Colors.black87,
                    ),
                  ),

                  monthViewSettings: const DateRangePickerMonthViewSettings(
                    dayFormat: 'EEE',
                    viewHeaderHeight: 28,
                  ),
                  selectionTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    height: 1.0, // fixes vertical centering of number inside circle
                  ),
                  onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                    setState(() {
                      tempRange = args.value;
                    });
                  },
                ),
              ),
              actions: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Center(
                    child: Text(
                      'Click and drag to select multiple dates',
                      style: TextStyle(
                        color: Color(0xFF004AAD),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        if (tempRange != null) {
                          setDateRange(tempRange);
                        }
                        getDashboardReport();
                        final range = dashController.selectedRange.value;
                        var today = DateTime.now();
                        getCustomerReport(range==null?"${today.year}-${today.month.toString().padLeft(2, "0")}-${today.day.toString().padLeft(2, "0")}":"${range.start.year}-${range.start.month.toString().padLeft(2, "0")}-${range.start.day.toString().padLeft(2, "0")}", range==null?"${today.year}-${today.month.toString().padLeft(2, "0")}-${today.day.toString().padLeft(2, "0")}":"${range.end.year}-${range.end.month.toString().padLeft(2, "0")}-${range.end.day.toString().padLeft(2, "0")}");
                        dashController.selectedSortBy.value = "";
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'OK',
                        style: TextStyle(
                          color: Color(0xFF004AAD),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
  Future getCustomerReport(String stDate,String endDate) async {
    try {
      Map data = {
        "search_type": "customers_count",
        "cos_id": controllers.storage.read("cos_id"),
        "action": "get_data",
        "role": controllers.storage.read("role"),
        "id": controllers.storage.read("id"),
        "stDate":stDate,
        "enDate":endDate
      };
      log("main day wise ${data.toString()}");
      dayReport.value = [];
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));

      if (request.statusCode == 200) {
        List response = json.decode(request.body);
        dayReport.value = response.map<CustomerDayData>((e) => CustomerDayData.fromJson(e),).toList();
      } else {
        throw Exception('Failed to load album ${request.body}');
      }
    } catch (e) {
      print("day_report $e");
      throw Exception('Failed to load album');
    }
  }

  Future getRatingReport() async {
    try {
      Map data = {
        "search_type": "rating_report",
        "cos_id": controllers.storage.read("cos_id"),
        "action": "get_data",
      };
      log("main ${data.toString()}");
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      print("view dashboard report");
      print(request.body);
      totalCold.value = "0";
      totalHot.value = "0";
      totalWarm.value = "0";

      if (request.statusCode == 200) {
        List response = json.decode(request.body);
        totalCold.value = response[0]["cold_total"].toString()=="null"?"0":response[0]["cold_total"];
        totalHot.value = response[0]["hot_total"].toString()=="null"?"0":response[0]["hot_total"];
        totalWarm.value = response[0]["warm_total"].toString()=="null"?"0":response[0]["warm_total"];
      } else {
        totalCold.value = "0";
        totalHot.value = "0";
        totalWarm.value = "0";
        throw Exception('Failed to load album');
      }
    } catch (e) {
      totalCold.value = "0";
      totalHot.value = "0";
      totalWarm.value = "0";
      throw Exception('Failed to load album');
    }
  }
  Future getDashboardReport() async {
    final range = dashController.selectedRange.value;
    var today = DateTime.now();
    var tomorrow = DateTime.now().add(Duration(days: 1));
    final adjustedEnd = range?.end.add(const Duration(days: 1));
    try {
      Map data = {
        "search_type": "dashboard_report",
        "cos_id": controllers.storage.read("cos_id"),
        "role": controllers.storage.read("role"),
        "id": controllers.storage.read("id"),
        "action": "get_data",
        "stDate": range==null?"${today.year}-${today.month.toString().padLeft(2, "0")}-${today.day.toString().padLeft(2, "0")}":"${range.start.year}-${range.start.month.toString().padLeft(2, "0")}-${range.start.day.toString().padLeft(2, "0")}",
        "enDate": range==null?"${tomorrow.year}-${tomorrow.month.toString().padLeft(2, "0")}-${tomorrow.day.toString().padLeft(2, "0")}":"${adjustedEnd!.year}-${adjustedEnd.month.toString().padLeft(2, "0")}-${adjustedEnd.day.toString().padLeft(2, "0")}"
      };

      log("Dashboard request data: ${data.toString()}");
      final request = await http.post(
        Uri.parse(scriptApi),
        headers: {
          "Accept": "application/text",
          "Content-Type": "application/x-www-form-urlencoded"
        },
        body: jsonEncode(data),
        encoding: Encoding.getByName("utf-8"),
      );
      if (request.statusCode == 200) {
        var response = jsonDecode(request.body) as List;
        dashController.totalMails.value       = response[0]["total_mails"] ?? "0";
        dashController.totalMeetings.value    = response[0]["total_meetings"] ?? "0";
        dashController.pendingMeetings.value  = response[0]["pending_meetings"] ?? "0";
        dashController.completedMeetings.value = response[0]["completed_meetings"] ?? "0";
        dashController.totalCalls.value       = response[0]["total_calls"] ?? "0";
        dashController.totalEmployees.value   = response[0]["total_employees"] ?? "0";
        dashController.totalHot.value         = response[0]["hot_total"]?.toString() ?? "0";
        dashController.totalWarm.value        = response[0]["warm_total"]?.toString() ?? "0";
        dashController.totalCold.value        = response[0]["cold_total"]?.toString() ?? "0";
        dashController.totalSuspects.value    = response[0]["total_suspects"]?.toString() ?? "0";
        dashController.totalProspects.value   = response[0]["total_prospects"]?.toString() ?? "0";
        dashController.totalQualified.value   = response[0]["total_qualified"]?.toString() ?? "0";
        dashController.totalUnQualified.value = response[0]["total_disqualified"]?.toString() ?? "0";
        dashController.totalCustomers.value   = response[0]["total_customers"]?.toString() ?? "0";
      } else {
        throw Exception('Failed to load dashboard report');
      }
    } catch (e) {
      print("dashboard_report error: $e");
      throw Exception('Failed to load dashboard report');
    }
  }
}
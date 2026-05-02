import 'dart:convert';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fullcomm_crm/controller/reminder_controller.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fullcomm_crm/services/api_services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../common/constant/api.dart';
import '../common/utilities/jwt_storage.dart';
import '../components/month_calender.dart';
import '../models/month_report_obj.dart';
import 'controller.dart';

final dashController = Get.put(DashboardController());

class DashboardController extends GetxController {
  var totalMails       = "0".obs;
  var totalReminders   = "0".obs;
  var totalEmployees   = "0".obs;
  var totalMeetings    = "0".obs;
  var pendingMeetings  = "0".obs;
  var completedMeetings = "0".obs;
  var totalCalls       = "0".obs;
  var totalWarm        = "0".obs;
  var totalCold        = "0".obs;
  var totalHot         = "0".obs;
  var totalWarm2        = "0".obs;
  var totalCold2        = "0".obs;
  var totalHot2         = "0".obs;
  var totalSuspects    = "0".obs;
  var totalProspects   = "0".obs;
  var totalQualified   = "0".obs;
  var totalUnQualified = "0".obs;
  var totalCustomers   = "0".obs;
  var totalQuotations   = "0".obs;
  var totalOrders   = "0".obs;
  var totalAmt   = "0".obs;
  var dayReport = <CustomerDayData>[].obs;
  RxBool isLoading = false.obs;

  Future<void> getToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      apiService.updateTokenAPI(token.toString());
    }catch(e){
    }
  }
  final List<String> filters = [
    "Today",
    "Yesterday",
    "Last 7 Days",
    "Last 30 Days",
    "Custom",
  ];
  final List<String> filterType = [
    "All",
    "Mine",
    "Team"
  ];
var selectedSortBy = "${controllers.storage.read("selectedSortBy") ?? "Today"}".obs;
var selectedRange = Rxn<DateTimeRange>(); // null-safe observable
var isDateRangeSet = false.obs;
var date1="${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}".obs;
var date2="${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}".obs;
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

  Future<DateTimeRange?> showDatePickerDialog(BuildContext context) async {
    return await showDialog<DateTimeRange?>(
      context: context,
      builder: (BuildContext context) {
        DateTimeRange? tempRange;

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
                  maxDate: DateTime(2050),
                  selectionMode: DateRangePickerSelectionMode.range,
                  selectionColor: const Color(0xFF004AAD),
                  startRangeSelectionColor: const Color(0xFF004AAD),
                  endRangeSelectionColor: const Color(0xFF004AAD),
                  rangeSelectionColor: const Color(0x22004AAD),

                  onSelectionChanged:
                      (DateRangePickerSelectionChangedArgs args) {
                    if (args.value is PickerDateRange) {
                      final PickerDateRange range = args.value;

                      if (range.startDate != null &&
                          range.endDate != null) {
                        setState(() {
                          tempRange = DateTimeRange(
                            start: range.startDate!,
                            end: range.endDate!,
                          );
                        });
                      }
                    }
                  },
                ),
              ),

              /// ACTIONS
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
                    /// CANCEL
                    TextButton(
                      onPressed: () => Navigator.pop(context, null),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    /// OK
                    TextButton(
                      onPressed: () {
                        if (tempRange != null) {

                          /// ✅ store range
                          dashController.selectedRange.value = tempRange;

                          /// ✅ convert to string date
                          dashController.date1.value =
                          "${tempRange!.start.year}-${tempRange!.start.month.toString().padLeft(2, '0')}-${tempRange!.start.day.toString().padLeft(2, '0')}";

                          dashController.date2.value =
                          "${tempRange!.end.year}-${tempRange!.end.month.toString().padLeft(2, '0')}-${tempRange!.end.day.toString().padLeft(2, '0')}";

                          /// ✅ API calls
                          getDashboardReport();
                          getLeadReport();
                          getStatusWiseReport();
                          getCustomerStatus();

                          getCustomerReport(
                            dashController.date1.value,
                            dashController.date2.value,
                          );

                          /// meeting filter
                          remController.selectedMeetRange.value = tempRange;
                          remController.selectedMeetSortBy.value =
                          "Custom Range";

                          remController.dashboardMeetings(
                            searchText:
                            controllers.searchText.value.toLowerCase(),
                            callType:
                            controllers.selectMeetingType.value,
                            sortField:
                            controllers.sortFieldMeetingActivity.value,
                            sortOrder:
                            controllers.sortOrderMeetingActivity.value,
                          );

                          /// ✅ IMPORTANT → return value
                          Navigator.pop(context, tempRange);
                        } else {
                          Navigator.pop(context, null);
                        }
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
  String _fmt(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  bool canMoveForward() {
    final amount = dashController._shiftAmountForFilter(dashController.selectedSortBy.value);
    final current = dashController.selectedRange.value;
    if (current == null) return false;

    final newEnd = current.end.add(Duration(days: amount));
    final today = DateTime.now();
    return !DateTime(newEnd.year, newEnd.month, newEnd.day)
        .isAfter(DateTime(today.year, today.month, today.day));
  }
  int _shiftAmountForFilter(String filter) {
    switch (filter) {
      case "Last 7 Days":
        return 7;
      case "Last 30 Days":
        return 30;
      default:
        return 1;
    }
  }

  void shiftRange({required bool forward}) {
    final amount = _shiftAmountForFilter(selectedSortBy.value);
    final sign = forward ? 1 : -1;

    final now = DateTime.now();
    DateTimeRange current = selectedRange.value ??
        DateTimeRange(
          start: DateTime(now.year, now.month, now.day),
          end: DateTime(now.year, now.month, now.day),
        );

    final DateTime newStart = current.start.add(Duration(days: sign * amount));
    final DateTime newEnd = current.end.add(Duration(days: sign * amount));

    if (forward) {
      final today = DateTime(now.year, now.month, now.day);
      if (DateTime(newEnd.year, newEnd.month, newEnd.day).isAfter(today)) {
        return;
      }
    }

    final normalizedStart = DateTime(newStart.year, newStart.month, newStart.day);
    final normalizedEnd = DateTime(newEnd.year, newEnd.month, newEnd.day);

    selectedRange.value = DateTimeRange(start: normalizedStart, end: normalizedEnd);

    getDashboardReport();
    getLeadReport();
    getStatusWiseReport();
    getCustomerStatus();

    if (selectedSortBy.value != "Today" && selectedSortBy.value != "Yesterday") {
      getCustomerReport(_fmt(normalizedStart), _fmt(normalizedEnd));
    } else {
      final today = DateTime.now();
      final last7days = today.subtract(Duration(days: 7));
      getCustomerReport(_fmt(last7days), _fmt(today));
    }
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
      // debugPrint("main day wise ${billing_data.toString()}");
      dayReport.value = [];
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      // debugPrint("main day wise ${request.body.toString()}");
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return getCustomerReport(stDate,endDate);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200) {
        List response = json.decode(request.body);
        dayReport.value = response.map<CustomerDayData>((e) => CustomerDayData.fromJson(e),).toList();
      } else {
        throw Exception('Failed to load album ${request.body}');
      }
    } catch (e) {
      debugPrint("day_report $e");
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
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      totalCold.value = "0";
      totalHot.value = "0";
      totalWarm.value = "0";
      totalCold2.value = "0";
      totalHot2.value = "0";
      totalWarm2.value = "0";
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return getRatingReport();
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200) {
        List response = json.decode(request.body);
        totalCold.value = response[0]["lead_cold"].toString()=="null"?"0":response[0]["lead_cold"];
        totalHot.value = response[0]["lead_hot"].toString()=="null"?"0":response[0]["lead_hot"];
        totalWarm.value = response[0]["lead_warm"].toString()=="null"?"0":response[0]["lead_warm"];

        totalCold2.value = response[0]["customer_cold"].toString()=="null"?"0":response[0]["customer_cold"];
        totalHot2.value = response[0]["customer_hot"].toString()=="null"?"0":response[0]["customer_hot"];
        totalWarm2.value = response[0]["customer_warm"].toString()=="null"?"0":response[0]["customer_warm"];
      } else {
        totalCold.value = "0";
        totalHot.value = "0";
        totalWarm.value = "0";
        totalCold2.value = "0";
        totalHot2.value = "0";
        totalWarm2.value = "0";
        throw Exception('Failed to load album');
      }
    } catch (e) {
      totalCold.value = "0";
      totalHot.value = "0";
      totalWarm.value = "0";
      totalCold2.value = "0";
      totalHot2.value = "0";
      totalWarm2.value = "0";
      throw Exception('Failed to load album');
    }
  }
  RxString timestamp = "".obs;
  RxInt refreshTime = 0.obs;

  Future getDashboardReport() async {
    // final range = dashController.selectedRange.value;
    // var today = DateTime.now();
    // var tomorrow = DateTime.now().add(Duration(days: 1));
    // final adjustedEnd = range?.end.add(const Duration(days: 1));
    try {
      Map data = {
        "search_type": "dashboard_report",
        "cos_id": controllers.storage.read("cos_id"),
        "role": controllers.storage.read("role"),
        "id": controllers.storage.read("id"),
        "action": "get_data",
        // "stDate": range==null?"${today.year}-${today.month.toString().padLeft(2, "0")}-${today.day.toString().padLeft(2, "0")}":"${range.start.year}-${range.start.month.toString().padLeft(2, "0")}-${range.start.day.toString().padLeft(2, "0")}",
        // "enDate": range==null?"${today.year}-${today.month.toString().padLeft(2, "0")}-${today.day.toString().padLeft(2, "0")}":"${range.start.year}-${range.start.month.toString().padLeft(2, "0")}-${range.start.day.toString().padLeft(2, "0")}",
        "stDate": dashController.date1.value,
        "enDate": dashController.date2.value,
      };

      debugPrint("Dashboard report 1:    ${data.toString()}");
      final request = await http.post(
        Uri.parse(scriptApi),
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
        encoding: Encoding.getByName("utf-8"),
      );
      debugPrint("Dashboard report: ${request.body}");
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return getDashboardReport();
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200) {
        // var response = jsonDecode(request.body) as List;
        // dashController.totalMails.value       = response[0]["total_mails"] ?? "0";
        // dashController.totalReminders.value   = response[0]["total_reminders"] ?? "0";
        // dashController.totalMeetings.value    = response[0]["total_meetings"] ?? "0";
        // dashController.pendingMeetings.value  = response[0]["pending_meetings"] ?? "0";
        // dashController.completedMeetings.value = response[0]["completed_meetings"] ?? "0";
        // dashController.totalCalls.value       = response[0]["total_calls"] ?? "0";
        // dashController.totalEmployees.value   = response[0]["total_employees"] ?? "0";
        // dashController.totalHot.value         = response[0]["hot_total"]?.toString() ?? "0";
        // dashController.totalWarm.value        = response[0]["warm_total"]?.toString() ?? "0";
        // dashController.totalCold.value        = response[0]["cold_total"]?.toString() ?? "0";
        // dashController.totalSuspects.value    = response[0]["total_suspects"]?.toString() ?? "0";
        // dashController.totalProspects.value   = response[0]["total_prospects"]?.toString() ?? "0";
        // dashController.totalQualified.value   = response[0]["total_qualified"]?.toString() ?? "0";
        // dashController.totalUnQualified.value = response[0]["total_disqualified"]?.toString() ?? "0";
        // dashController.totalCustomers.value   = response[0]["total_customers"]?.toString() ?? "0";

        var responseList = jsonDecode(request.body) as List;
        if (responseList.isNotEmpty) {
          var response = responseList[0] as Map<String, dynamic>;

          dashController.totalMails.value        = response["total_mails"]?.toString() ?? "0";
          dashController.totalReminders.value    = response["total_reminders"]?.toString() ?? "0";
          dashController.totalMeetings.value     = response["total_meetings"]?.toString() ?? "0";
          dashController.pendingMeetings.value   = response["pending_meetings"]?.toString() ?? "0";
          dashController.completedMeetings.value = response["completed_meetings"]?.toString() ?? "0";
          dashController.totalCalls.value        = response["total_calls"]?.toString() ?? "0";
          dashController.totalEmployees.value    = response["total_employees"]?.toString() ?? "0";
          // dashController.totalSuspects.value     = response["total_suspects"]?.toString() ?? "0";
          dashController.totalSuspects.value     = response["new_customers"]?.toString() ?? "0";
          dashController.totalProspects.value    = response["total_prospects"]?.toString() ?? "0";
          dashController.totalQualified.value    = response["total_qualified"]?.toString() ?? "0";
          dashController.totalUnQualified.value  = response["total_disqualified"]?.toString() ?? "0";
          dashController.totalCustomers.value    = response["total_customers"]?.toString() ?? "0";
          dashController.totalQuotations.value    = response["total_quotations"]?.toString() ?? "0";
          dashController.totalOrders.value    = response["total_orders"]?.toString() ?? "0";
          dashController.totalAmt.value    = response["total_amount"]?.toString() ?? "0";
        } else {
          // handle empty response gracefully
          debugPrint("Dashboard API returned empty data");
          dashController.totalQuotations.value        = "0";
          dashController.totalOrders.value        = "0";
          dashController.totalAmt.value        = "0";
          dashController.totalMails.value        = "0";
          dashController.totalReminders.value    = "0";
          dashController.totalMeetings.value     = "0";
          dashController.pendingMeetings.value   = "0";
          dashController.completedMeetings.value = "0";
          dashController.totalCalls.value        = "0";
          dashController.totalEmployees.value    = "0";
          dashController.totalSuspects.value     = "0";
          dashController.totalProspects.value    = "0";
          dashController.totalQualified.value    = "0";
          dashController.totalUnQualified.value  = "0";
          dashController.totalCustomers.value    = "0";
        }
        timestamp.value="${DateTime.now()}";
      } else {
        dashController.totalMails.value        = "0";
        dashController.totalReminders.value    = "0";
        dashController.totalMeetings.value     = "0";
        dashController.pendingMeetings.value   = "0";
        dashController.completedMeetings.value = "0";
        dashController.totalCalls.value        = "0";
        dashController.totalEmployees.value    = "0";
        dashController.totalSuspects.value     = "0";
        dashController.totalProspects.value    = "0";
        dashController.totalQualified.value    = "0";
        dashController.totalUnQualified.value  = "0";
        dashController.totalCustomers.value    = "0";
        dashController.totalQuotations.value        = "0";
        dashController.totalOrders.value        = "0";
        dashController.totalAmt.value        = "0";
        timestamp.value="${DateTime.now()}";
        throw Exception('Failed to load dashboard report');
      }
    } catch (e) {
      dashController.totalQuotations.value        = "0";
      dashController.totalOrders.value        = "0";
      dashController.totalAmt.value        = "0";
      dashController.totalMails.value        = "0";
      dashController.totalReminders.value    = "0";
      dashController.totalMeetings.value     = "0";
      dashController.pendingMeetings.value   = "0";
      dashController.completedMeetings.value = "0";
      dashController.totalCalls.value        = "0";
      dashController.totalEmployees.value    = "0";
      dashController.totalHot.value          = "0";
      dashController.totalWarm.value         = "0";
      dashController.totalCold.value         = "0";
      dashController.totalSuspects.value     = "0";
      dashController.totalProspects.value    = "0";
      dashController.totalQualified.value    = "0";
      dashController.totalUnQualified.value  = "0";
      dashController.totalCustomers.value    = "0";
      timestamp.value="${DateTime.now()}";
      throw Exception('Failed to load dashboard report $e');
    }
  }
  RxList leadReport=[].obs;
  List<Color> generateColors(int count) {
    return List.generate(count, (index) {
      final hue = (360 / count) * index;
      return HSLColor.fromAHSL(
        1.0,
        hue,
        0.65,
        0.55,
      ).toColor();
    });
  }
  List<Color> color=[];
  Future getLeadReport() async {
    // final range = dashController.selectedRange.value;
    // var today = DateTime.now();
    // var tomorrow = DateTime.now().add(Duration(days: 1));
    // final adjustedEnd = range?.end.add(const Duration(days: 1));
    leadReport.clear();
    try {
      Map data = {
        "search_type": "lead_count_report",
        "cos_id": controllers.storage.read("cos_id"),
        "role": controllers.storage.read("role"),
        "id": controllers.storage.read("id"),
        "action": "get_data",
        "stDate": dashController.date1.value,
        "enDate": dashController.date2.value,
        // "stDate": range==null?"${today.year}-${today.month.toString().padLeft(2, "0")}-${today.day.toString().padLeft(2, "0")}":"${range.start.year}-${range.start.month.toString().padLeft(2, "0")}-${range.start.day.toString().padLeft(2, "0")}",
        // "enDate": range==null?"${tomorrow.year}-${tomorrow.month.toString().padLeft(2, "0")}-${tomorrow.day.toString().padLeft(2, "0")}":"${adjustedEnd!.year}-${adjustedEnd.month.toString().padLeft(2, "0")}-${adjustedEnd.day.toString().padLeft(2, "0")}"
      };

      // log("Dashboard request dataaa: ${billing_data.toString()}");
      final request = await http.post(
        Uri.parse(scriptApi),
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
        encoding: Encoding.getByName("utf-8"),
      );
      // debugPrint(billing_data);
      // debugPrint("Dashboard report:2 ${request.body}");
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return getLeadReport();
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200) {

        var responseList = jsonDecode(request.body) as List;
        if (responseList.isNotEmpty) {
          color = generateColors(responseList.length);
          leadReport.value=responseList;
        }
        else {
          leadReport.clear();
        }
      } else {
        leadReport.clear();
        throw Exception('Failed to load dashboard report 2');
      }
    } catch (e) {
      leadReport.clear();
      throw Exception('Failed to load dashboard report 2');
    }
  }
  RxList visitStatusReport=[].obs;
  double total = 0;
  RxList customerStatusReport=[].obs;
  Future<void> getCustomerStatus() async {
    try {

      customerStatusReport.clear();
      Map data = {
        "action": "get_data",
        "search_type": "customer_range_report",
        "lead_status": controllers.leadCategoryList.last.leadStatus,
        "id": controllers.storage.read("id"),
        "role": controllers.storage.read("role"),
        "cos_id": controllers.storage.read("cos_id"),
        "stDate": dashController.date1.value,
        "enDate": dashController.date2.value,
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));

      debugPrint("customer_range_report: ${request.statusCode}");
      debugPrint("RAW RESPONSE: ${data}");
      debugPrint("RAW RESPONSE: ${request.body}");
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return getCustomerStatus();
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode != 200) {
        // debugPrint("SERVER ERROR");
        return;
      }

      final decoded = jsonDecode(request.body);

      // ✅ Safety check
      if (request.statusCode==200) {
        var decoded = json.decode(request.body);

        if (decoded is List) {
          customerStatusReport.value =List<Map<String, dynamic>>.from(decoded);
        } else {
          debugPrint("Unexpected format");
        }
      } else {
        debugPrint("API Error: ${decoded["message"]}");
      }

    } catch (e) {
      debugPrint("FLUTTER ERROR => $e");
    }
  }

  Future getStatusWiseReport() async {
    // final range = dashController.selectedRange.value;
    // var today = DateTime.now();
    // var tomorrow = DateTime.now().add(Duration(days: 1));
    // final adjustedEnd = range?.end.add(const Duration(days: 1));
    // try {
      visitStatusReport.clear();
      total=0;
      Map data = {
        "search_type": "visit_status_report",
        "cos_id": controllers.storage.read("cos_id"),
        "role": controllers.storage.read("role"),
        "id": controllers.storage.read("id"),
        "action": "get_data",
        "stDate": dashController.date1.value,
        "enDate": dashController.date2.value,
        // "stDate": range==null?"${today.year}-${today.month.toString().padLeft(2, "0")}-${today.day.toString().padLeft(2, "0")}":"${range.start.year}-${range.start.month.toString().padLeft(2, "0")}-${range.start.day.toString().padLeft(2, "0")}",
        // "enDate": range==null?"${tomorrow.year}-${tomorrow.month.toString().padLeft(2, "0")}-${tomorrow.day.toString().padLeft(2, "0")}":"${adjustedEnd!.year}-${adjustedEnd.month.toString().padLeft(2, "0")}-${adjustedEnd.day.toString().padLeft(2, "0")}"
      };

      // log("Dashboard request billing_data: visit_status_report ${billing_data.toString()}");
      final request = await http.post(
        Uri.parse(scriptApi),
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
        encoding: Encoding.getByName("utf-8"),
      );
      // debugPrint("STATUS CODE visit_status_report: ${request.statusCode}");
      // debugPrint("RAW RESPONSE: ${request.body}");
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return getStatusWiseReport();
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200) {
        var response = jsonDecode(request.body) as List;
        visitStatusReport.value=response;
        for (var item in response) {
          total += int.parse(item["total_count"].toString());
        }
        // debugPrint("total ${total}");
        // debugPrint("visitStatusReport.value ${visitStatusReport.value}");
      } else {
        visitStatusReport.clear();
        throw Exception('Failed to load dashboard report');
      }
    // } catch (e) {
    //   visitStatusReport.clear();
    //   throw Exception('Failed to load dashboard report $e');
    // }
  }
  var startDate = "".obs,endDate="".obs,month="".obs;
  var increase=false.obs;
  var monthCount=0.obs;
  late DateTime date3;
  late DateTime date4;
  void incrementMonth(RxString st,RxString en,RxString month) {
    if(increase.value==false){
      // print("FALSE");
    }else{
      date3 = DateTime(date3.year, date3.month + 1, 1);
      date4 = DateTime(date4.year, date4.month + 1, 1);
      st.value = DateFormat('dd-MM-yyyy').format(date3);
      en.value = DateFormat('dd-MM-yyyy').format(DateTime(date4.year, date4.month + 1, 0));
      month.value = DateFormat('MMMM').format(date3);
      monthCount.value = date3.month;
    }
    if(month.value==DateFormat('MMMM').format(DateTime.now())){
      increase.value=false;
    }else{
      increase.value=true;
    }
  }

  void decrementMonth(RxString st,RxString en,RxString month) {
    date3 = DateTime(date3.year, date3.month - 1, 1);
    date4 = DateTime(date4.year, date4.month - 1, 1);
    st.value = DateFormat('dd-MM-yyyy').format(date3);
    en.value = DateFormat('dd-MM-yyyy').format(DateTime(date4.year, date4.month + 1, 0));
    month.value = DateFormat('MMMM').format(date3);
    monthCount.value = date3.month;
    if(month.value==DateFormat('MMMM').format(DateTime.now())){
      increase.value=false;
    }else{
      increase.value=true;
    }
  }
var year;
  void showCustomMonthPicker({
    required BuildContext context,
    required RxString date1,
    required RxString date2,
    required RxString month,
    required void Function() function,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final now = DateTime.now();

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: SizedBox(
            width: 300,
            height: 400,
            child: CustomMonthPicker(
              // initialMonth: DateTime.now().month,
              // initialYear:  DateTime.now().year,
              initialMonth: monthCount.value,

              initialYear: (year != null && year != 0)
                  ? year
                  : now.year,
              firstYear: 2024,
              lastYear: now.year,
              // onSelected: onSelected,
              onSelected: (value) {
                var m  =value.month ;
                var y = value.year;
                year = value.year;
                var ex = ("01-${(m.toString().padLeft(2, "0"))}-$y").split("-");
                var date = DateTime(int.parse(ex.first), int.parse(ex[1]) + 1,0);
                month.value = DateFormat('MMMM').format(DateTime(0, int.parse(m.toString().padLeft(2, "0"))));
                monthCount.value = date.month;
                date1.value=("01-${(m.toString().padLeft(2, "0"))}-$y");
                date2.value="${date.day.toString().padLeft(2, "0")}-${m.toString().padLeft(2, "0")}-$y";
                function();
              },
            ),
          ),
        );
      },
    );
  }
}
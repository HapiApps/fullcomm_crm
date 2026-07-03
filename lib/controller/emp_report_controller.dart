import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:http/http.dart'as http;
import '../common/constant/api.dart';
import '../common/constant/colors_constant.dart';
import '../common/utilities/jwt_storage.dart';
import '../components/Customtext.dart';
import 'controller.dart';

final repCtr = Get.put(RepController());

class RepController extends GetxController with GetSingleTickerProviderStateMixin {
  PickerDateRange? selectedDate;
  List<DateTime> datesBetween = [];
  String betweenDates="";
  var stDate="".obs;
  var enDate="".obs;
  var empId="".obs;
  void showDatePickerDialog(BuildContext context) {
    DateTime today = DateTime.now();
    selectedDate = PickerDateRange(today, today);
    datesBetween = getDatesInRange(selectedDate!.startDate!, selectedDate!.endDate!);

    DateFormat dateFormat = DateFormat('dd-MM-yyyy');
    List<String> formattedDates = datesBetween.map((date) => dateFormat.format(date)).toList();
    betweenDates = formattedDates.join(' || ');

    stDate.value = dateFormat.format(selectedDate!.startDate!);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: CustomText(text: '   Select Date',colors: colorsConst.secondary,isBold: true, isCopy: false,),
          content: SizedBox(
            height: 300, // Adjust height as needed
            width: 300, // Adjust width as needed
            child: SfDateRangePicker(
              minDate: DateTime(2026),
              maxDate: DateTime.now(),
              onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                selectedDate = args.value;
                stDate.value="";
                enDate.value="";
                if(selectedDate?.endDate!=null){
                  stDate.value="${selectedDate?.startDate?.day.toString().padLeft(2,"0")}"
                      "-${selectedDate?.startDate?.month.toString().padLeft(2,"0")}"
                      "-${selectedDate?.startDate?.year.toString()}";

                  enDate.value="${selectedDate?.endDate?.day.toString().padLeft(2,"0")}"
                      "-${selectedDate?.endDate?.month.toString().padLeft(2,"0")}"
                      "-${selectedDate?.endDate?.year.toString()}";
                }else{
                  stDate.value="${selectedDate?.startDate?.day.toString().padLeft(2,"0")}"
                      "-${selectedDate?.startDate?.month.toString().padLeft(2,"0")}"
                      "-${selectedDate?.startDate?.year.toString()}";
                }
              },
              selectionMode: DateRangePickerSelectionMode.range,
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomText(text: 'Click and drag to select multiple dates',colors: colorsConst.primary, isCopy: false,),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  child: const CustomText(text:'Cancel',colors: Colors.grey,isBold: true, isCopy: false,),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: CustomText(text: 'OK',colors: colorsConst.primary,isBold: true, isCopy: false,),
                  onPressed: () {
                    if (selectedDate != null) {
                      datesBetween = getDatesInRange(
                        selectedDate!.startDate!,
                        selectedDate!.endDate ?? selectedDate!.startDate!,
                      );
                    }
                    DateFormat dateFormat = DateFormat('dd-MM-yyyy');

                    List<String> formattedDates = datesBetween.map((date) => dateFormat.format(date)).toList();
                    betweenDates = formattedDates.join(' || ');
                    if(empId.value!=""){
                      getWholeReport(empId.value);
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
  List<DateTime> getDatesInRange(DateTime start, DateTime end) {
    List<DateTime> days = [];
    for (int i = 0; i <= end.difference(start).inDays; i++) {
      days.add(DateTime(start.year, start.month, start.day + i));
    }
    return days;
  }

  late DateTime lastWeekStart;
  late DateTime lastWeekEnd;
  late DateTime thisWeekStart;
  late DateTime thisWeekEnd;

  late String lastWeekTitle;
  late String thisWeekTitle;

  // Monthly
  late DateTime lastMonthStart;
  late DateTime lastMonthEnd;
  late DateTime thisMonthStart;
  late DateTime thisMonthEnd;

  late String lastMonthTitle;
  late String thisMonthTitle;

  @override
  void onInit() {
    super.onInit();

    final now = DateTime.now();

    // ---------- This Week ----------
    thisWeekStart = DateTime(
      now.year,
      now.month,
      now.day - (now.weekday - 1),
    );

    thisWeekEnd = thisWeekStart.add(const Duration(days: 6));

    // ---------- Last Week ----------
    lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
    lastWeekEnd = thisWeekStart.subtract(const Duration(days: 1));

    lastWeekTitle =
    "${DateFormat('dd MMM').format(lastWeekStart)} - ${DateFormat('dd MMM yyyy').format(lastWeekEnd)}";

    thisWeekTitle =
    "${DateFormat('dd MMM').format(thisWeekStart)} - ${DateFormat('dd MMM yyyy').format(thisWeekEnd)}";

    // ---------- This Month ----------
    thisMonthStart = DateTime(now.year, now.month, 1);
    thisMonthEnd = DateTime(now.year, now.month + 1, 0);

    // ---------- Last Month ----------
    lastMonthStart = DateTime(now.year, now.month - 1, 1);
    lastMonthEnd = DateTime(now.year, now.month, 0);

    lastMonthTitle = DateFormat('MMMM yyyy').format(lastMonthStart);
    thisMonthTitle = DateFormat('MMMM yyyy').format(thisMonthStart);
  }

  var totalMails       = "0".obs;
  var totalMeetings       = "0".obs;
  var totalCalls       = "0".obs;
  var totalQuotations   = "0".obs;
  var totalSuspects    = "0".obs;
  var leadReport    = [].obs;
  var comparisonReport    = [].obs;
  var activeReport    = {}.obs;
  var firstCount = 0.obs;
  List<IconData> activityIcons = [
    Icons.call,
    Icons.mail,
    Icons.calendar_month,
    Icons.description,
    Icons.person,
  ];
  String currentHeading = "";
  String previousHeading = "";

  // switch (selectedFilter) {
  // case "This Week":
  // currentHeading = "$thisWeekFrom\n$thisWeekTo";
  // previousHeading = "$lastWeekFrom\n$lastWeekTo";
  // break;
  //
  // case "This Month":
  // currentHeading = "$thisMonthFrom\n$thisMonthTo";
  // previousHeading = "$lastMonthFrom\n$lastMonthTo";
  // break;
  //
  // default:
  // currentHeading = "$stDate\n$enDate";
  // previousHeading = "";
  // }

var refreshData=true.obs;
  Future getWholeReport(String id) async {
    try {
      refreshData.value=false;
      String lastWeekFrom = DateFormat('yyyy-MM-dd').format(lastWeekStart);
      String lastWeekTo   = DateFormat('yyyy-MM-dd').format(lastWeekEnd);

      String thisWeekFrom = DateFormat('yyyy-MM-dd').format(thisWeekStart);
      String thisWeekTo   = DateFormat('yyyy-MM-dd').format(thisWeekEnd);

      String lastMonthFrom = DateFormat('yyyy-MM-dd').format(lastMonthStart);
      String lastMonthTo   = DateFormat('yyyy-MM-dd').format(lastMonthEnd);

      String thisMonthFrom = DateFormat('yyyy-MM-dd').format(thisMonthStart);
      String thisMonthTo   = DateFormat('yyyy-MM-dd').format(thisMonthEnd);
      Map data = {
        "cos_id": controllers.storage.read("cos_id"),
        "role": controllers.storage.read("role"),
        "id": id,
        "action": "emp_report",
        "stDate": DateFormat('yyyy-MM-dd').format(DateFormat('dd-MM-yyyy').parse(stDate.value)),
        "enDate": DateFormat('yyyy-MM-dd').format(DateFormat('dd-MM-yyyy').parse(enDate.value==""?stDate.value:enDate.value)),
        "lead_status": controllers.leadCategoryList.last.leadStatus,

        "lastWeekFrom": lastWeekFrom,
        "lastWeekTo": lastWeekTo,
        "thisWeekFrom": thisWeekFrom,
        "thisWeekTo": thisWeekTo,

        "lastMonthFrom": lastMonthFrom,
        "lastMonthTo": lastMonthTo,
        "thisMonthFrom": thisMonthFrom,
        "thisMonthTo": thisMonthTo,
      };

      debugPrint("================================================");
      debugPrint("REQUEST DATA");
      debugPrint("================================================");
      debugPrint(data.toString());

      final request = await http.post(
        Uri.parse(scriptApi),
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
        encoding: Encoding.getByName("utf-8"),
      );
      debugPrint("================================================");
      debugPrint("RAW RESPONSE");
      debugPrint("================================================");
      log(request.body);

      if (request.statusCode == 401) {

        final refreshed = await controllers.refreshToken();

        if (refreshed) {
          return getWholeReport(id);
        } else {
          controllers.setLogOut();
        }
      }

      if (request.statusCode == 200) {

        final response = jsonDecode(request.body);

        debugPrint("================================================");
        debugPrint("FULL RESPONSE");
        debugPrint("================================================");
        debugPrint(response.toString());

        /// =====================================================
        /// DASHBOARD REPORT
        /// =====================================================

        Map<String, dynamic> dashboardReport =
        Map<String, dynamic>.from(
            response['data']['dashboard_report']);

        // debugPrint("================================================");
        // debugPrint("DASHBOARD REPORT");
        // debugPrint("================================================");
        // debugPrint(dashboardReport.toString());

        totalMails.value =dashboardReport["total_mails"].toString();
        totalCalls.value =dashboardReport["total_calls"].toString();
        totalSuspects.value = dashboardReport['new_customers'].toString();
        totalQuotations.value = dashboardReport["total_quotations"].toString();
        totalMeetings.value = dashboardReport["total_meetings"].toString();
        /// =====================================================
        /// Activity Customer REPORT
        /// =====================================================
        List<dynamic> activityReport = List<dynamic>.from(response['data']['lead_report']);
        leadReport.value=activityReport;
        if (activityReport.isNotEmpty) {
          firstCount.value = int.parse(
            activityReport.first["total_count"].toString(),
          );
        }

        List<dynamic> comReport = List<dynamic>.from(response['data']['comparison_report']);
        comparisonReport.value=comReport;

        Map acReport = response['data']['activity_summary'];
        activeReport.value=acReport;
        refreshData.value=true;
      } else {
        // debugPrint("================================================");
        // debugPrint("API FAILED");
        // debugPrint("================================================");
        refreshData.value=true;
        throw Exception('Failed to load dashboard report');
      }
    } catch (e) {
      // debugPrint("================================================");
      // debugPrint("CATCH ERROR");
      // debugPrint("================================================");
      // debugPrint(e.toString());
      refreshData.value=true;
      throw Exception(
          'Failed to load dashboard report $e');
    }
  }

}


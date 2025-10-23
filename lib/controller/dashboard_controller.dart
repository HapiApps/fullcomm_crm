import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/constant/colors_constant.dart';
import 'package:fullcomm_crm/services/api_services.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

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
                        apiService.getDashboardReport();
                        final range = dashController.selectedRange.value;
                        var today = DateTime.now();
                        apiService.getCustomerReport(range==null?"${today.year}-${today.month.toString().padLeft(2, "0")}-${today.day.toString().padLeft(2, "0")}":"${range.start.year}-${range.start.month.toString().padLeft(2, "0")}-${range.start.day.toString().padLeft(2, "0")}", range==null?"${today.year}-${today.month.toString().padLeft(2, "0")}-${today.day.toString().padLeft(2, "0")}":"${range.end.year}-${range.end.month.toString().padLeft(2, "0")}-${range.end.day.toString().padLeft(2, "0")}");
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

}
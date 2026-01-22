import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../common/constant/colors_constant.dart';
import '../../common/styles/decoration.dart';
import '../../common/styles/styles.dart';
import '../../common/utilities/utils.dart';
import '../../components/custom_date_box.dart';
import '../../components/custom_dropdown.dart';
import '../../components/custom_loading_button.dart';
import '../../components/custom_sidebar.dart';
import '../../components/custom_text.dart';
import '../../components/custom_textfield.dart';
import '../../components/keyboard_search.dart';
import '../../controller/controller.dart';
import '../../controller/reminder_controller.dart';
import '../../models/all_customers_obj.dart';
import '../../models/reminder_obj.dart';
import '../../provider/reminder_provider.dart';
import '../../services/api_services.dart';

class ReminderCalender extends StatefulWidget {
  const ReminderCalender({super.key});

  @override
  State<ReminderCalender> createState() => _ReminderCalenderState();
}

class _ReminderCalenderState extends State<ReminderCalender> {
  final CalendarController _calendarController = CalendarController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // apiService.getAllEmployees();
  }
  @override
  Widget build(BuildContext context) {
    var webWidth=MediaQuery.of(context).size.width * 0.5;
    var phoneWidth=MediaQuery.of(context).size.width * 0.95;
    double screenWidth = MediaQuery.of(context).size.width;
    double textFieldSize = (MediaQuery.of(context).size.width - 400) / 1.8;
    final DateTime now = DateTime.now();
    final DateTime firstDayOfYear = DateTime(now.year-1, 12, 1);
    final DateTime lastDayOfYear = DateTime(now.year, 12, 31);
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SideBar(),
          Obx(()=> Container(
            width:controllers.isLeftOpen.value?MediaQuery.of(context).size.width - 150:MediaQuery.of(context).size.width - 60,
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.center,
            padding: EdgeInsets.fromLTRB(16, 5, 16, 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                        onPressed: (){
                          Get.back();
                        },
                        icon: Icon(Icons.arrow_back,color: colorsConst.third,)),
                    20.width,
                    Center(
                      child: CustomText(
                        text: "Reminder Calender",
                        size: 20,
                        colors: Colors.black,
                        isBold: true,
                        isCopy: true,
                      ),
                    ),
                  ],
                ),
                50.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        CustomText(text: "Total Reminders", isCopy: false,),
                        CustomText(
                            text: "  ${remController.reminderFilteredList.length}",
                            colors: Colors.red, isCopy: false)
                      ],
                    ),10.width,
                    Row(
                      children: [
                        CustomText(text: "This Month", isCopy: false),
                        CustomText(text: "  ${remController.thisMonthLeave}",
                            colors: Colors.red, isCopy: false)
                      ],
                    ),
                  ],
                ), 10.height,
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(
                                  color: Colors.grey.shade100,
                                  width: 1
                              )
                            // borderColor: ,
                            // radius: 10
                          ),
                          height: 300,
                          child: SfCalendar(
                            controller: _calendarController,
                            view: CalendarView.month,
                            headerHeight: 50,
                            cellBorderColor: Colors.transparent,
                            todayTextStyle: const TextStyle(
                              color: Colors.white,
                            ),
                            dataSource: remController.dataSource,
                            minDate: firstDayOfYear,
                            maxDate: lastDayOfYear,
                            onLongPress: null,
                            onSelectionChanged: null,
                            onTap: (CalendarTapDetails value) {
                              if (value.date != null) {
                                var tappedMonth = value.date!.month.obs;
                                // var visibleMonth = remController.defaultMonth;

                                if (tappedMonth.value!=remController.defaultMonth.value) {
                                  // 🔄 Switch calendar view to the tapped month
                                  _calendarController.displayDate = value.date!;
                                  return;
                                }

                                // // ✅ Continue with tap action for current month dates
                                // remController.filterDateList(
                                //   DateFormat('dd-MM-yyyy').format(value.date!),
                                //   value.date!,
                                // );
                                setState(() {
                                  remController.filterDate.value=DateFormat('dd-MM-yyyy').format(value.date!).toString();
                                });
                                // remController.checkMonth2();
                              }
                            },
                            onViewChanged: (details) {
                              // remController.checkMonth2();
                              // remController.checkMonth(details);
                            },
                            monthCellBuilder: (BuildContext context, MonthCellDetails details) {
                              bool hasAppointments = remController.hasAppointment(details.date);
                              bool isSelected = false;

                              // if (remController.filterDate != "") {
                              //   DateTime parsedFilterDate = DateFormat('dd-MM-yyyy').parse(remController.filterDate);
                              //   isSelected = isSameDate(details.date, parsedFilterDate);
                              // }

                              // Get the middle date in the visibleDates list to determine current month in view
                              int midIndex = details.visibleDates.length ~/ 2;
                              int visibleMonth = details.visibleDates[midIndex].month;

                              bool isInCurrentMonth = details.date.month == visibleMonth;

                              Color textColor = isSelected
                                  ? Colors.grey.shade400
                                  : isInCurrentMonth
                                  ? colorsConst.primary
                                  : Colors.grey; // 👉 other month dates in grey

                              return Container(
                                alignment: Alignment.topLeft,
                                margin: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white
                                      : hasAppointments
                                      ? Colors.green
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(isSelected ? 0 : 10),
                                ),
                                child: Center(
                                  child: CustomText(
                                    text: details.date.day.toString(),
                                    isBold: true,isCopy: false,
                                    colors: textColor,
                                  ),
                                ),
                              );
                            },
                            monthViewSettings: MonthViewSettings(
                              appointmentDisplayMode: MonthAppointmentDisplayMode.none,
                              monthCellStyle: MonthCellStyle(
                                textStyle: TextStyle(
                                  color: Colors.green,
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                ),
                                trailingDatesTextStyle: TextStyle(
                                  color: Colors.grey,
                                ),
                                leadingDatesTextStyle: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Obx(()=>(remController.reminderFilteredList.isEmpty)?
                        CustomText(text: "\n\nNo tasks found", colors: colorsConst.secondary, size: 14, isCopy: false,):
                        SizedBox(
                          child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: remController.reminderFilteredList.length,
                              itemBuilder: (context, index) {
                                ReminderModel data = remController.reminderFilteredList[index]; // e.g., "24-05-2025"
                                // String dateStr = remController.reminderFilteredList[index].startDt.toString(); // e.g., "24-05-2025"
                                // DateTime dateTime = DateFormat('dd-MM-yyyy').parse(dateStr);
                                // var st = dateTime;
                                return remController.filterDate.value==getOnlyDate(data.startDt)?
                                //   returnPadLeft(
                                //     remController.defaultMonth.toString()) ==
                                //     returnPadLeft(st.month.toString())&&remController.filterDate.value=="" ?
                                dataList(kIsWeb?webWidth:phoneWidth, data):
                                // returnPadLeft(
                                //     remController.defaultMonth.toString()) ==
                                //     returnPadLeft(st.month.toString())&&remController.filterDate.value==st.toString() ?
                                remController.filterDate.value==""?dataList(kIsWeb?webWidth:phoneWidth, data):0.width;
                              }),
                        ))
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),)
        ],
      ),
    );
  }
  bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Widget dataList(double width,ReminderModel data){
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Container(
        decoration: customDecoration
            .baseBackgroundDecoration(
            color: Colors.white,borderColor: Colors.grey.shade400,
            radius: 5
        ),
        width: width,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CustomText( text:data.title.toString(),isCopy: false,colors: colorsConst.primary,isBold: true,),
                      CustomText( text:data.type.toString(),isCopy: false,),
                    ],
                  ),
                  Row(
                    children: [
                      CustomText( text:data.startDt.toString(),isCopy: false,),
                      CustomText( text:data.endDt.toString(),isCopy: false,),
                    ],
                  ),
                ],
              ),5.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText( text:data.customerName.toString(),isCopy: false,isBold: true,),
                  CustomText( text:data.employeeName.toString(),isCopy: false,colors: Colors.red,),
                ],
              ),5.height,
              CustomText( text:data.details.toString(),isCopy: false,),
              5.height,
            ],
          ),
        ),
      ),
    );
  }
  String returnPadLeft(String value){
    var output=value.toString().padLeft(2,"0");
    return output;
  }
  String getOnlyDate(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return '';

    DateTime? parsedDate;

    try {
      // Format: 21.02.2025 11:00 PM
      parsedDate = DateFormat('dd.MM.yyyy hh:mm a').parse(dateStr);
    } catch (e) {
      try {
        // Format: 21-02-2025 11:00 PM
        parsedDate = DateFormat('dd-MM-yyyy hh:mm a').parse(dateStr);
      } catch (e) {
        print("Date parse failed: $dateStr");
        return dateStr; // fallback
      }
    }

    // Output only date
    return DateFormat('dd-MM-yyyy').format(parsedDate);
  }

}
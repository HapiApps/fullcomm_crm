import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/common/utilities/notification_utils.dart';
import 'package:fullcomm_crm/components/line_chart.dart';
import 'package:fullcomm_crm/controller/dashboard_controller.dart';
import 'package:fullcomm_crm/screens/records/records.dart';
import 'package:fullcomm_crm/screens/reminder/reminder_page.dart';
import 'package:get/get.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common/constant/api.dart';
import '../common/constant/colors_constant.dart';
import '../common/utilities/utils.dart';
import '../components/custom_rating.dart';
import '../components/custom_sidebar.dart';
import '../components/custom_text.dart';
import '../controller/controller.dart';
import '../provider/employee_provider.dart';
import '../services/api_services.dart';
import 'dart:html' as html;
import 'employee/employee_screen.dart';

class NewDashboard extends StatefulWidget {
  const NewDashboard({super.key});

  @override
  State<NewDashboard> createState() => _NewDashboardState();
}

class _NewDashboardState extends State<NewDashboard> {
  late FocusNode _focusNode;
  final ScrollController _controller = ScrollController();
  final ScrollController _leftController = ScrollController();
  final ScrollController _rightController = ScrollController();
  @override
  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    dashController.getToken();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      final employeeData = Provider.of<EmployeeProvider>(context, listen: false);
      employeeData.staffRoleDetailsData(context: context);
    });

    Future.delayed(Duration.zero, () async {
      apiService.currentVersion();
      controllers.selectedIndex.value = 0;

      final prefs = await SharedPreferences.getInstance();
      controllers.isAdmin.value = prefs.getBool("isAdmin") ?? false;
      DateTime now = DateTime.now();
      dashController.selectedSortBy.value = "Today";
      dashController.selectedRange.value = DateTimeRange(
        start: DateTime(now.year, now.month, now.day),
        end: DateTime(now.year, now.month, now.day),
      );
      String today = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      var last7days = DateTime.now().subtract(Duration(days: 7));
      dashController.getCustomerReport("${last7days.year}-${last7days.month.toString().padLeft(2,'0')}-${last7days.day.toString().padLeft(2,'0')}",today);
      dashController.getDashboardReport();
      dashController.getRatingReport();
    });
  }
  String _getTooltipText(String label) {
    switch (label) {
      case 'Suspects':
        return "Initial leads with low interest";
      case 'Prospects':
        return "Interested potential customers";
      case 'Qualified':
        return "Verified serious buyers";
      case 'Disqualified':
        return "Rejected / not usable leads";
      case 'Customers':
        return "Successfully converted customers";
      default:
        return "No data available";
    }
  }
  void showWebNotification() {
    // Ask permission
    html.Notification.requestPermission().then((permission) {
      if (permission == "granted") {
       try{
         html.Notification(
           "Hello from Flutter Web 🚀",
           body: "This is a local notification example.",
           icon: "icons/Icon-192.png", // optional, must be in web/icons/
         );
       }catch(e){
          print("Error showing notification: $e");
       }
      }else{
        print("Permission not granted for notifications");
      }
    });
  }

  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   _focusNode = FocusNode();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     _focusNode.requestFocus();
  //     final employeeData = Provider.of<EmployeeProvider>(context, listen: false);
  //     employeeData.staffRoleDetailsData(context: context);
  //   });
  //   Future.delayed(Duration.zero, () async {
  //     apiService.currentVersion();
  //     controllers.selectedIndex.value = 0;
  //     final prefs = await SharedPreferences.getInstance();
  //     controllers.isAdmin.value = prefs.getBool("isAdmin") ?? false;
  //     apiService.getDayReport(DateTime.now().year.toString(),DateTime.now().month.toString());
  //   });
  //   apiService.getDashBoardReport();
  //   apiService.getRatingReport();
  //   apiService.getMonthReport();
  //
  // }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldExit = await utils.showExitDialog(context);
          if (shouldExit) {
            html.window.open("https://www.google.com", "_self");
          }
        }
      },
      child: SelectionArea(
        child: Scaffold(
            body: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SideBar(),
                Obx(() => Container(
                    width: controllers.isLeftOpen.value == false &&
                        controllers.isRightOpen.value == false
                        ? screenWidth - 200
                        : screenWidth - 400,
                    height: MediaQuery.of(context).size.height,
                    alignment: Alignment.topLeft,
                    padding: EdgeInsets.fromLTRB(40, 10, 40, 16),
                    child: Column(
                      children: [
                        10.height,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Obx((){
                              final range = dashController.selectedRange.value;
                              final selected = dashController.selectedSortBy.value;
                              if (range == null) {
                                return const Text(
                                  "Filter by Date Range",
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontFamily: "Lato",
                                  ),
                                );
                              }
                              String formatDate(DateTime date) => "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
                              String displayText;
                              if (selected == "Today") {
                                displayText = formatDate(range.start);
                              } else if (selected == "Yesterday") {
                                displayText = formatDate(range.start);
                              } else {
                                displayText = "${formatDate(range.start)}  —  ${formatDate(range.end)}";
                              }
                              return CustomText(
                                text: "Dashboard for the period $displayText ($selected)",
                                colors: colorsConst.textColor,
                                size: 20,
                                isBold: true,
                                isCopy: true,
                              );
                            }),
                            CustomText(
                              text: version,
                              colors: colorsConst.third,
                              size: 11,
                              isCopy: true,
                            ),
                          ],
                        ),
                        15.height,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Obx(() {
                              return Column(
                                children: [
                                  Row(
                                    spacing: 20,
                                    children: dashController.filters.map((filter) {
                                      final bool isSelected = dashController.selectedSortBy.value == filter;
                                      return MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTap: () {
                                            dashController.selectedSortBy.value = filter;
                                            DateTime now = DateTime.now();
                                            switch (filter) {
                                              case "Today":
                                                dashController.selectedRange.value = DateTimeRange(
                                                  start: DateTime(now.year, now.month, now.day),
                                                  end: DateTime(now.year, now.month, now.day),
                                                );
                                                break;
                                              case "Yesterday":
                                                DateTime yesterday = now.subtract(Duration(days: 1));
                                                dashController.selectedRange.value = DateTimeRange(
                                                  start: DateTime(yesterday.year, yesterday.month, yesterday.day),
                                                  end: DateTime(now.year, now.month, now.day),
                                                );
                                                break;
                                              case "Last 7 Days":
                                                dashController.selectedRange.value = DateTimeRange(
                                                  start: now.subtract(Duration(days: 6)),
                                                  end: now,
                                                );
                                                break;
                                              case "Last 30 Days":
                                                dashController.selectedRange.value = DateTimeRange(
                                                  start: now.subtract(Duration(days: 30)),
                                                  end: now,
                                                );
                                                break;
                                            }
                                            dashController.getDashboardReport();
                                            final range = dashController.selectedRange.value;
                                            var today = DateTime.now();
                                            if(dashController.selectedSortBy.value!="Today"&&dashController.selectedSortBy.value!="Yesterday"){
                                              dashController.getCustomerReport(range==null?"${today.year}-${today.month.toString().padLeft(2, "0")}-${today.day.toString().padLeft(2, "0")}":"${range.start.year}-${range.start.month.toString().padLeft(2, "0")}-${range.start.day.toString().padLeft(2, "0")}", range==null?"${today.year}-${today.month.toString().padLeft(2, "0")}-${today.day.toString().padLeft(2, "0")}":"${range.end.year}-${range.end.month.toString().padLeft(2, "0")}-${range.end.day.toString().padLeft(2, "0")}");
                                            }
                                            else{
                                              var today = "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2,'0')}-${DateTime.now().day.toString().padLeft(2,'0')}";
                                              var last7days = DateTime.now().subtract(Duration(days: 7));
                                              dashController.getCustomerReport("${last7days.year}-${last7days.month.toString().padLeft(2,'0')}-${last7days.day.toString().padLeft(2,'0')}",today);
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: isSelected ? Colors.blueAccent : Colors.white,
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(
                                                color: isSelected ? Colors.blueAccent : Colors.grey.shade400,
                                              ),
                                            ),
                                            child: IgnorePointer(
                                              child: Text(
                                                filter,
                                                style: TextStyle(
                                                  color: isSelected ? Colors.white : Colors.black87,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: "Lato",
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              );
                            }),
                            20.width,
                            Container(
                              width: 270,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: Colors.grey.shade400),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                 IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: BoxConstraints(),
                                      icon: Icon(Icons.chevron_left, size: 20, color: Colors.grey[700]),
                                      onPressed: () {
                                        dashController.shiftRange(forward: false);
                                      },
                                    ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        dashController.showDatePickerDialog(context);
                                      },
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Obx(() {
                                            final range = dashController.selectedRange.value;
                                            if (range == null) {
                                              return const Text(
                                                "Filter by Date Range",
                                                style: TextStyle(color: Colors.black54, fontFamily: "Lato"),
                                              );
                                            }
                                            return Text(
                                              "${range.start.day}-${range.start.month}-${range.start.year}  -  ${range.end.day}-${range.end.month}-${range.end.year}",
                                              style: const TextStyle(
                                                color: Colors.black87,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: "Lato",
                                              ),
                                            );
                                          }),
                                          const SizedBox(width: 6),
                                          const Icon(Icons.calendar_today, color: Colors.grey, size: 17),
                                        ],
                                      ),
                                    ),
                                  ),
                                IconButton(
                                icon: Icon(Icons.chevron_right,
                                size: 20,
                                color: dashController.canMoveForward() ? Colors.grey[700] : Colors.grey[300]),
                              onPressed: dashController.canMoveForward() ? () => dashController.shiftRange(forward: true) : null,
                            ),
                const SizedBox(width: 6),
                                ],
                              ),
                            ),

                            // InkWell(
                            //     onTap: (){
                            //       dashController.showDatePickerDialog(context);
                            //     },
                            //     child: Container(
                            //       width: 200,
                            //       height: 30,
                            //       decoration: BoxDecoration(
                            //         color: Colors.white,
                            //         borderRadius: BorderRadius.circular(5),
                            //         border: Border.all(color: Colors.grey.shade400),
                            //       ),
                            //       child: Row(
                            //         mainAxisAlignment: MainAxisAlignment.center,
                            //         children: [
                            //           Obx(() {
                            //             final range = dashController.selectedRange.value;
                            //             if (range == null) {
                            //               return const Text(
                            //                 "Filter by Date Range",
                            //                 style: TextStyle(color: Colors.black54,fontFamily: "Lato",),
                            //               );
                            //             }
                            //             return Text(
                            //               "${range.start.day}-${range.start.month}-${range.start.year}  -  ${range.end.day}-${range.end.month}-${range.end.year}",
                            //               style: const TextStyle(
                            //                 color: Colors.black87,
                            //                 fontWeight: FontWeight.w500,
                            //                 fontFamily: "Lato",
                            //               ),
                            //             );
                            //           }),
                            //           const SizedBox(width: 5),
                            //           const Icon(Icons.calendar_today,
                            //               color: Colors.grey, size: 17),
                            //           const SizedBox(width: 10),
                            //         ],
                            //       ),
                            //     ),
                            //   ),
                            50.width,
                          ],
                        ),
                        30.height,
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                  //height: screenHeight-60,
                                  width: (screenWidth-420)/2.15,
                                  child: SingleChildScrollView(
                                    controller: _leftController,
                                    child: Column(
                                      children: [
                                        Wrap(
                                          spacing: 45,
                                          runSpacing: 35,
                                          children: [
                                            InkWell(
                                              onTap: (){
                                                controllers.changeTab(1);
                                                Navigator.push(
                                                  context,
                                                  PageRouteBuilder(
                                                    pageBuilder: (context, animation1, animation2) =>
                                                    const Records(isReload: "true",),
                                                    transitionDuration: Duration.zero,
                                                    reverseTransitionDuration: Duration.zero,
                                                  ),
                                                );
                                                controllers.oldIndex.value = controllers.selectedIndex.value;
                                                controllers.selectedIndex.value = 6;
                                              },
                                              child: countShown(width: 130, head: " Mails",
                                                  count: dashController.totalMails.value.toString(),icon: Icons.email),
                                            ),
                                            InkWell(
                                                onTap: (){
                                                  controllers.changeTab(0);
                                                  Navigator.push(
                                                    context,
                                                    PageRouteBuilder(
                                                      pageBuilder: (context, animation1, animation2) =>
                                                      const Records(isReload: "true",),
                                                      transitionDuration: Duration.zero,
                                                      reverseTransitionDuration: Duration.zero,
                                                    ),
                                                  );
                                                  controllers.oldIndex.value = controllers.selectedIndex.value;
                                                  controllers.selectedIndex.value = 6;
                                                },
                                                child: countShown(width: 130, head: " Calls", count: dashController.totalCalls.value.toString(),icon: Icons.call)),
                                            InkWell(
                                              onTap: (){
                                                controllers.changeTab(2);
                                                Navigator.push(
                                                  context,
                                                  PageRouteBuilder(
                                                    pageBuilder: (context, animation1, animation2) =>
                                                    const Records(isReload: "true",),
                                                    transitionDuration: Duration.zero,
                                                    reverseTransitionDuration: Duration.zero,
                                                  ),
                                                );
                                                controllers.oldIndex.value = controllers.selectedIndex.value;
                                                controllers.selectedIndex.value = 6;
                                              },
                                              child: countShown(width: 135, head: "Appointments",
                                                  count: dashController.totalMeetings.value.toString(),
                                                  icon: Icons.calendar_month_outlined),
                                            ),
                                            InkWell(
                                              onTap: (){
                                                Navigator.push(
                                                  context,
                                                  PageRouteBuilder(
                                                    pageBuilder: (context, animation1, animation2) =>
                                                    const EmployeeScreen(),
                                                    transitionDuration: Duration.zero,
                                                    reverseTransitionDuration: Duration.zero,
                                                  ),
                                                );
                                                controllers.oldIndex.value = controllers.selectedIndex.value;
                                                controllers.selectedIndex.value = 9;
                                              },
                                              child: countShown(
                                                width: 130,
                                                head: "New Employees",
                                                count: dashController.totalEmployees.value.toString(),
                                                icon: Icons.people_outline,
                                              ),
                                            ),
                                            InkWell(
                                              onTap: (){
                                                Navigator.push(
                                                  context,
                                                  PageRouteBuilder(
                                                    pageBuilder: (context, animation1, animation2) =>
                                                    const ReminderPage(),
                                                    transitionDuration: Duration.zero,
                                                    reverseTransitionDuration: Duration.zero,
                                                  ),
                                                );
                                                controllers.oldIndex.value = controllers.selectedIndex.value;
                                                controllers.selectedIndex.value = 11;
                                              },
                                              child: countShown(
                                                width: 130,
                                                head: "Reminders",
                                                count: dashController.totalReminders.value.toString(),
                                                icon: Icons.notifications_active,
                                              ),
                                            ),
                                          ],
                                        ),
                                        10.height,
                                        Container(
                                          height: 220,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(
                                                color: Colors.grey.shade400
                                            ),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Column(
                                            children: [
                                              20.height,
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  CustomText(
                                                    text: "       Rating",
                                                    size: 16,
                                                    isBold: true,
                                                    colors: colorsConst.textColor,
                                                    isCopy: true,
                                                  ),
                                                ],
                                              ),
                                              30.height,
                                              Obx(() {
                                                final hot = int.tryParse(dashController.totalHot.value) ?? 0;
                                                final warm = int.tryParse(dashController.totalWarm.value) ?? 0;
                                                final cold = int.tryParse(dashController.totalCold.value) ?? 0;
                                                final totalCount = hot + warm + cold;
                                                return Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    InkWell(
                                                      onTap: ()async{
                                                        notificationUtils.showBrowserNotification();
                                                      },
                                                      child: RatingIndicator(
                                                        color: Colors.red,
                                                        label: ' Hot',
                                                        value: hot,
                                                        percentage: totalCount == 0 ? 0.0 : hot / totalCount,
                                                      ),
                                                    ),
                                                    RatingIndicator(
                                                      color: Colors.orange,
                                                      label: ' Warm',
                                                      value: warm,
                                                      percentage: totalCount == 0 ? 0.0 : warm / totalCount,
                                                    ),
                                                    RatingIndicator(
                                                      color: Colors.blue,
                                                      label: ' Cold',
                                                      value: cold,
                                                      percentage: totalCount == 0 ? 0.0 : cold / totalCount,
                                                    ),
                                                  ],
                                                );
                                              }),
                                            ],
                                          ),
                                        ),

                                        // Row(
                                        //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        //   children: [
                                        //     countShown(
                                        //         width:150,
                                        //         head: "Total Mails",
                                        //         count: controllers.mailActivity.length.toString()),
                                        //     20.width,
                                        //     countShown(
                                        //         width:150,
                                        //         head: "Total Calls",
                                        //         count: controllers.callActivity.length.toString()),
                                        //     20.width,
                                        //     countShown(
                                        //         width:150,
                                        //         head: "Total Meetings",
                                        //         count: controllers.meetingActivity.length.toString()),
                                        //   ],
                                        // ),
                                        10.height,
                                        Container(
                                          height: 220,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(
                                                  color: Colors.grey.shade400
                                              )
                                          ),
                                          child: Column(
                                            children: [
                                              20.height,
                                              Row(
                                                children: [
                                                  CustomText(
                                                    text: "     Quotations Send",
                                                    size: 16,
                                                    isBold: true,
                                                    isCopy: true,
                                                    colors:
                                                    colorsConst.textColor,
                                                  ),
                                                  // CustomText(
                                                  //   text: "Last Month      ",
                                                  //   size: 13,
                                                  //   colors:
                                                  //   colorsConst.textColor,
                                                  // ),
                                                ],
                                              ),
                                              40.height,
                                              Stack(
                                                children: [
                                                  Container(
                                                    width: 100,
                                                    height: 100,
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                        BorderRadius.circular(50),
                                                        border: Border.all(
                                                            color:colorsConst.primary,
                                                            width: 2.4)),
                                                    child:CustomText(
                                                      text: "0",
                                                      isCopy: true,
                                                      colors:
                                                      colorsConst.textColor,
                                                      size: 20,
                                                      isBold: true,
                                                    ),
                                                  ),
                                                  const Positioned(
                                                    bottom: 0.4,
                                                    right: 25,
                                                    child: CircleAvatar(
                                                      radius: 5,
                                                      backgroundColor: Color(0xff5D5FEF),
                                                    ),
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              SizedBox(
                                  //height: screenHeight-60,
                                  width: (screenWidth-420)/2.1,
                                  child: SingleChildScrollView(
                                    controller: _rightController,
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 300,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(10)),
                                          child: Column(
                                            children: [
                                              3.height,
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  CustomText(
                                                    text: "       New Customers",
                                                    isCopy: true,
                                                    size: 16,
                                                    isBold: true,
                                                    colors: colorsConst.textColor,
                                                  ),
                                                  // Row(
                                                  //   mainAxisAlignment: MainAxisAlignment.center,
                                                  //   children: [
                                                  //     // Month Dropdown
                                                  //     Obx(() => DropdownButton<int>(
                                                  //       value: controllers.selectedChartMonth.value,
                                                  //       items: List.generate(12, (index) {
                                                  //         final month = index + 1;
                                                  //         return DropdownMenuItem(
                                                  //           value: month,
                                                  //           child: Text(DateFormat.MMMM().format(DateTime(0, month))),
                                                  //         );
                                                  //       }),
                                                  //       onChanged: (value) {
                                                  //         if (value != null) {
                                                  //           controllers.selectedChartMonth.value = value;
                                                  //          apiService.getDayReport(controllers.selectedChartYear.value.toString().isEmpty?DateTime.now().year.toString():controllers.selectedChartYear.value.toString(), controllers.selectedChartMonth.value.toString());
                                                  //         }
                                                  //       },
                                                  //     )),
                                                  //     20.width,
                                                  //     // Year Dropdown
                                                  //     Obx(() => DropdownButton<int>(
                                                  //       value: controllers.selectedChartYear.value,
                                                  //       items: List.generate(5, (index) {
                                                  //         final year = DateTime.now().year - 4 + index;
                                                  //         return DropdownMenuItem(
                                                  //           value: year,
                                                  //           child: Text(year.toString()),
                                                  //         );
                                                  //       }),
                                                  //       onChanged: (value) {
                                                  //         if (value != null) {
                                                  //           controllers.selectedChartYear.value = value;
                                                  //           apiService.getDayReport(controllers.selectedChartYear.value.toString().isEmpty?DateTime.now().year.toString():controllers.selectedChartYear.value.toString(), controllers.selectedChartMonth.value.toString().isEmpty?DateTime.now().month.toString():controllers.selectedChartMonth.value.toString());
                                                  //         }
                                                  //       },
                                                  //     )),
                                                  //     20.width,
                                                  //   ],
                                                  // ),

                                                ],
                                              ),
                                              10.height,
                                              Container(
                                                    alignment: Alignment.center,
                                                    width: (screenWidth-420)/2.1-50,
                                                    height: 230,
                                                    child: const DayWiseBarChart()),
                                              // Row(
                                              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              //   children: [
                                              //     IconButton(
                                              //       icon: const Icon(Icons.arrow_back),
                                              //       onPressed: () => controllers.moveRange(-7),
                                              //     ),
                                              //     Text(
                                              //       "${DateFormat.MMMd().format(controllers.rangeStart.value)} - "
                                              //           "${DateFormat.MMMd().format(controllers.rangeEnd.value)}",
                                              //       style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                              //     ),
                                              //     IconButton(
                                              //       icon: const Icon(Icons.arrow_forward),
                                              //       onPressed: () => controllers.moveRange(7),
                                              //     ),
                                              //   ],
                                              // ),

                                            ],
                                          ),
                                        ),
                                        20.height,
                                        // Container(
                                        //   height: 350,
                                        //   alignment: Alignment.center,
                                        //   decoration: BoxDecoration(
                                        //     color: Colors.white,
                                        //     borderRadius: BorderRadius.circular(10),
                                        //   ),
                                        //   child: SizedBox(
                                        //     height: 200,
                                        //     child: Obx(() {
                                        //       final double totalSuspects = double.parse(dashController.totalSuspects.value).roundToDouble();
                                        //       final double totalProspects = double.parse(dashController.totalProspects.value).roundToDouble();
                                        //       final double totalQualified = double.parse(dashController.totalQualified.value).roundToDouble();
                                        //       final double totalUnQualified = double.parse(dashController.totalUnQualified.value).roundToDouble();
                                        //       final double totalCustomers = double.parse(dashController.totalCustomers.value).roundToDouble();
                                        //
                                        //       final totalSum = totalSuspects + totalProspects + totalQualified + totalUnQualified + totalCustomers;
                                        //       final bool isEmpty = totalSum == 0;
                                        //
                                        //       final Map<String, double> dataMap = isEmpty
                                        //           ? {'No customers': 1}
                                        //           : {
                                        //         'Suspects': totalSuspects,
                                        //         'Prospects': totalProspects,
                                        //         'Qualified': totalQualified,
                                        //         'Disqualified': totalUnQualified,
                                        //         'Customers': totalCustomers,
                                        //       };
                                        //       final List<Color> colorList = isEmpty
                                        //           ? [Color(0xffE0E0E0)] // Grey color for "No customers"
                                        //           : [
                                        //         Color(0xffE3B552), // Suspects
                                        //         Color(0xff0070F8), // Prospects
                                        //         Color(0xffFF43D6), // Qualified
                                        //         Color(0xffF53B37), // Unqualified
                                        //         Color(0xff45B72F), // Customers
                                        //       ];
                                        //       return PieChart(
                                        //         dataMap: dataMap,
                                        //         animationDuration: const Duration(seconds: 2),
                                        //         chartLegendSpacing: 32,
                                        //         chartRadius: MediaQuery.of(context).size.width / 2.2,
                                        //         colorList: colorList,
                                        //         chartType: ChartType.disc,
                                        //         centerText: totalSum == 0 ? "0" : "",
                                        //         centerTextStyle: TextStyle(
                                        //           color: colorsConst.textColor,
                                        //           fontFamily: "Lato",
                                        //         ),
                                        //         legendOptions: LegendOptions(
                                        //           showLegends: true,
                                        //           legendTextStyle: TextStyle(color: colorsConst.textColor, fontFamily: "Lato"),
                                        //         ),
                                        //         chartValuesOptions: ChartValuesOptions(
                                        //           showChartValuesInPercentage: false,
                                        //           showChartValues: true,
                                        //           showChartValueBackground: false,
                                        //           chartValueStyle:  TextStyle(
                                        //             color: totalSum == 0 ?Color(0xffE0E0E0):Colors.white,
                                        //             fontFamily: "Lato",
                                        //           ),
                                        //           decimalPlaces: 0,
                                        //         ),
                                        //       );
                                        //     }),
                                        //   ),
                                        //
                                        // )
                                    Container(
                                      height: 350,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start, // ✅ Full Column left-align
                                        children: [
                                          // ✅ Title aligned to start
                                          Padding(
                                            padding: const EdgeInsets.only(top: 10, bottom: 5, left: 20),
                                            child: Align(
                                              alignment: Alignment.centerLeft,   // ✅ Title starts from left
                                              child: Text(
                                                "Lead Distribution Overview",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: "Lato",
                                                ),
                                              ),
                                            ),
                                          ),
                                          30.height,
                                          Expanded(
                                            child: Obx(() {
                                              final double totalSuspects = double.parse(dashController.totalSuspects.value);
                                              final double totalProspects = double.parse(dashController.totalProspects.value);
                                              final double totalQualified = double.parse(dashController.totalQualified.value);
                                              final double totalUnQualified = double.parse(dashController.totalUnQualified.value);
                                              final double totalCustomers = double.parse(dashController.totalCustomers.value);

                                              final totalSum = totalSuspects + totalProspects + totalQualified + totalUnQualified + totalCustomers;
                                              final bool isEmpty = totalSum == 0;

                                              final Map<String, double> dataMap = isEmpty
                                                  ? {'No Customers': 1}
                                                  : {
                                                'Suspects': totalSuspects,
                                                'Prospects': totalProspects,
                                                'Qualified': totalQualified,
                                                'Disqualified': totalUnQualified,
                                                'Customers': totalCustomers,
                                              };

                                              final List<Color> colorList = isEmpty
                                                  ? [Color(0xffE0E0E0)]
                                                  : [
                                                Color(0xffE3B552), // Suspects
                                                Color(0xff0070F8), // Prospects
                                                Color(0xffFF43D6), // Qualified
                                                Color(0xffF53B37), // Disqualified
                                                Color(0xff45B72F), // Customers
                                              ];

                                              return Column(
                                                children: [
                                                  // ✅ Pie Chart Section
                                                  SizedBox(
                                                    height: 200,
                                                    child: PieChart(
                                                      dataMap: dataMap,
                                                      animationDuration: const Duration(seconds: 2),
                                                      chartLegendSpacing: 32,
                                                      chartRadius: MediaQuery.of(context).size.width / 2.2,
                                                      colorList: colorList,
                                                      chartType: ChartType.disc,
                                                      centerText: totalSum == 0 ? "0" : "",
                                                      centerTextStyle: const TextStyle(fontFamily: "Lato"),
                                                      legendOptions: LegendOptions(
                                                        showLegends: true,
                                                        legendTextStyle: const TextStyle(fontFamily: "Lato"),
                                                      ),
                                                      chartValuesOptions: ChartValuesOptions(
                                                        showChartValuesInPercentage: false,
                                                        showChartValues: true,
                                                        showChartValueBackground: false,
                                                        chartValueStyle: TextStyle(
                                                          color: totalSum == 0 ? Color(0xffE0E0E0) : Colors.white,
                                                          fontFamily: "Lato",
                                                        ),
                                                        decimalPlaces: 0,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                                    ),
                                  ),
                                )
                            ],
                          ),
                        ),
                      ],
                    )),),
                utils.funnelContainer(context)
              ],
            )
        ),
      ),
    );
  }
  Widget countShown({required double width, required String head, required String count,required IconData icon}) {
    return Container(
      width: width,
      height: 180,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),

      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.end,
          //   children:[
          //     CustomText(
          //       text: "Month",
          //       size: 13,
          //       colors: colorsConst.textColor,
          //     ),
          //     10.width
          //   ],
          // ),
          Icon(
            icon,
            color: colorsConst.primary,
            size: 50,
          ),
          CustomText(
            text: count,
            colors: colorsConst.textColor,
            size: 30,
            isBold: true,
            isCopy: true,
          ),
          15.height,
          CustomText(
            text: head,
            isCopy: true,
            colors: colorsConst.textColor,
            size: 15,
          ),
          5.height,
          head=="Appointments"?Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Tooltip(
                message: "Upcoming",
                child: Container(
                  padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      border: Border.all(
                        color: Colors.green
                      ),
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: Obx(()=>CustomText(text: dashController.completedMeetings.value,colors: Colors.green,size: 14,isBold: true,isCopy: true,))
                ),
              ),
              Tooltip(
                message: "Overdue",
                child: Container(
                    padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                    decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        border: Border.all(
                            color: Colors.red
                        ),
                        borderRadius: BorderRadius.circular(5)
                    ),
                    child: Obx(()=>IgnorePointer(
                        child: CustomText(
                          text: dashController.pendingMeetings.value,colors: Colors.red,size: 14,isBold: true,isCopy: true,)))
                ),
              ),
            ],
          ):0.height
        ],
      ),
    );
  }
}

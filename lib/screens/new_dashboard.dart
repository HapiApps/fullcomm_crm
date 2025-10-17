import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/components/line_chart.dart';
import 'package:fullcomm_crm/controller/dashboard_controller.dart';
import 'package:fullcomm_crm/screens/records/records.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common/constant/colors_constant.dart';
import '../common/utilities/utils.dart';
import '../components/custom_text.dart';
import '../controller/controller.dart';
import '../main.dart';
import '../provider/employee_provider.dart';
import '../services/api_services.dart';
import 'dashboard.dart';
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
  void initState() {
    // TODO: implement initState
    super.initState();
    _focusNode = FocusNode();
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
      var today = "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2,'0')}-${DateTime.now().day.toString().padLeft(2,'0')}";
      var last7days = DateTime.now().subtract(Duration(days: 7));
       apiService.getCustomerReport("${last7days.year}-${last7days.month.toString().padLeft(2,'0')}-${last7days.day.toString().padLeft(2,'0')}",today);
    });
    apiService.getRatingReport();
    apiService.getDashboardReport();
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
                utils.sideBarFunction(context),
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
                            CustomText(
                              text: "Dashboard",
                              colors: colorsConst.textColor,
                              size: 20,
                              isBold: true,
                            ),
                            CustomText(
                              text: controllers.version,
                              colors: colorsConst.third,
                              size: 11,
                            ),
                          ],
                        ),
                        5.height,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Obx(() {
                              return Row(
                                spacing: 20,
                                children: dashController.filters.map((filter) {
                                  final bool isSelected = dashController.selectedSortBy.value == filter;
                                  return GestureDetector(
                                    onTap: () {
                                      dashController.selectedSortBy.value = filter;
                                      DateTime now = DateTime.now();
                                      //DateTime tomorrow = DateTime.now().add(Duration(days: 1));
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
                                      apiService.getDashboardReport();
                                      final range = dashController.selectedRange.value;
                                      var today = DateTime.now();
                                      if(dashController.selectedSortBy.value!="Today"&&dashController.selectedSortBy.value!="Yesterday"){
                                        apiService.getCustomerReport(range==null?"${today.year}-${today.month.toString().padLeft(2, "0")}-${today.day.toString().padLeft(2, "0")}":"${range.start.year}-${range.start.month.toString().padLeft(2, "0")}-${range.start.day.toString().padLeft(2, "0")}", range==null?"${today.year}-${today.month.toString().padLeft(2, "0")}-${today.day.toString().padLeft(2, "0")}":"${range.end.year}-${range.end.month.toString().padLeft(2, "0")}-${range.end.day.toString().padLeft(2, "0")}");
                                      }
                                      else{
                                        var today = "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2,'0')}-${DateTime.now().day.toString().padLeft(2,'0')}";
                                        var last7days = DateTime.now().subtract(Duration(days: 7));
                                        apiService.getCustomerReport("${last7days.year}-${last7days.month.toString().padLeft(2,'0')}-${last7days.day.toString().padLeft(2,'0')}",today);
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
                                      child: Text(
                                        filter,
                                        style: TextStyle(
                                          color: isSelected ? Colors.white : Colors.black87,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: "Lato",
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            }),
                            20.width,
                            InkWell(
                              onTap: (){
                                dashController.showDatePickerDialog(context);
                              },
                              child: Container(
                                width: 200,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: Colors.grey.shade400),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Obx(() {
                                      final range = dashController.selectedRange.value;
                                      if (range == null) {
                                        return const Text(
                                          "Filter by Date Range",
                                          style: TextStyle(color: Colors.black54,fontFamily: "Lato",),
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
                                    const SizedBox(width: 5),
                                    const Icon(Icons.calendar_today,
                                        color: Colors.grey, size: 17),
                                    const SizedBox(width: 10),
                                  ],
                                ),
                              ),
                            ),
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
                                                  ),
                                                ],
                                              ),
                                              30.height,
                                              Obx(() {
                                                final hot = int.tryParse(controllers.totalHot.value) ?? 0;
                                                final warm = int.tryParse(controllers.totalWarm.value) ?? 0;
                                                final cold = int.tryParse(controllers.totalCold.value) ?? 0;
                                                final totalCount = hot + warm + cold;
                                                return Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    InkWell(
                                                      onTap: ()async{
                                                        final permission = await html.Notification.requestPermission();
                                                        if (permission == "granted") {
                                                          html.Notification(
                                                            "Hello from Flutter Web",
                                                            body: "Local notification test!",
                                                          );
                                                        } else {
                                                          print("Permission not granted");
                                                        }
                                                      },
                                                      child: RatingIndicator(
                                                        color: Colors.red,
                                                        label: 'Total Hot',
                                                        value: hot,
                                                        percentage: totalCount == 0 ? 0.0 : hot / totalCount,
                                                      ),
                                                    ),
                                                    RatingIndicator(
                                                      color: Colors.orange,
                                                      label: 'Total Warm',
                                                      value: warm,
                                                      percentage: totalCount == 0 ? 0.0 : warm / totalCount,
                                                    ),
                                                    RatingIndicator(
                                                      color: Colors.blue,
                                                      label: 'Total Cold',
                                                      value: cold,
                                                      percentage: totalCount == 0 ? 0.0 : cold / totalCount,
                                                    ),
                                                  ],
                                                );
                                              }),
                                            ],
                                          ),
                                        ),
                                        10.height,
                                        Wrap(
                                          spacing: 20,
                                          runSpacing: 10,
                                          children: [
                                            InkWell(
                                              onTap: (){
                                                controllers.changeTab(1);
                                                Navigator.push(
                                                  context,
                                                  PageRouteBuilder(
                                                    pageBuilder: (context, animation1, animation2) =>
                                                    const Records(),
                                                    transitionDuration: Duration.zero,
                                                    reverseTransitionDuration: Duration.zero,
                                                  ),
                                                );
                                                controllers.oldIndex.value = controllers.selectedIndex.value;
                                                controllers.selectedIndex.value = 6;
                                              },
                                              child: countShown(width: 130, head: "Total Mails",
                                                  count: dashController.totalMails.value.toString(),icon: Icons.email),
                                            ),
                                            InkWell(
                                                  onTap: (){
                                                    controllers.changeTab(0);
                                                    Navigator.push(
                                                      context,
                                                      PageRouteBuilder(
                                                        pageBuilder: (context, animation1, animation2) =>
                                                        const Records(),
                                                        transitionDuration: Duration.zero,
                                                        reverseTransitionDuration: Duration.zero,
                                                      ),
                                                    );
                                                    controllers.oldIndex.value = controllers.selectedIndex.value;
                                                    controllers.selectedIndex.value = 6;
                                                  },
                                                child: countShown(width: 130, head: "Total Calls", count: dashController.totalCalls.value.toString(),icon: Icons.call)),
                                            InkWell(
                                              onTap: (){
                                                controllers.changeTab(2);
                                                Navigator.push(
                                                  context,
                                                  PageRouteBuilder(
                                                    pageBuilder: (context, animation1, animation2) =>
                                                    const Records(),
                                                    transitionDuration: Duration.zero,
                                                    reverseTransitionDuration: Duration.zero,
                                                  ),
                                                );
                                                controllers.oldIndex.value = controllers.selectedIndex.value;
                                                controllers.selectedIndex.value = 6;
                                              },
                                              child: countShown(width: 130, head: "Total Meetings",
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
                                                head: "Total Employees",
                                                count: dashController.totalEmployees.value.toString(),
                                                icon: Icons.people_outline,
                                              ),
                                            ),
                                          ],
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
                                        Container(
                                          height: 350,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: SizedBox(
                                            height: 200,
                                            child: Obx(() {
                                              final double totalSuspects = double.parse(dashController.totalSuspects.value).roundToDouble();
                                              final double totalProspects = double.parse(dashController.totalProspects.value).roundToDouble();
                                              final double totalQualified = double.parse(dashController.totalQualified.value).roundToDouble();
                                              final double totalUnQualified = double.parse(dashController.totalUnQualified.value).roundToDouble();
                                              final double totalCustomers = double.parse(dashController.totalCustomers.value).roundToDouble();

                                              final totalSum = totalSuspects + totalProspects + totalQualified + totalUnQualified + totalCustomers;
                                              final bool isEmpty = totalSum == 0;

                                              final Map<String, double> dataMap = isEmpty
                                                  ? {'No customers': 1}
                                                  : {
                                                'Suspects': totalSuspects,
                                                'Prospects': totalProspects,
                                                'Qualified': totalQualified,
                                                'Unqualified': totalUnQualified,
                                                'Customers': totalCustomers,
                                              };
                                              final List<Color> colorList = isEmpty
                                                  ? [Color(0xffE0E0E0)] // Grey color for "No customers"
                                                  : [
                                                Color(0xffE3B552), // Suspects
                                                Color(0xff017EFF), // Prospects
                                                Color(0xffF55353), // Qualified
                                                Color(0xff7456FC), // Unqualified
                                                Color(0xffE3528C), // Customers
                                              ];

                                              return PieChart(
                                                dataMap: dataMap,
                                                animationDuration: const Duration(seconds: 2),
                                                chartLegendSpacing: 32,
                                                chartRadius: MediaQuery.of(context).size.width / 2.2,
                                                colorList: colorList,
                                                chartType: ChartType.disc,
                                                centerText: totalSum == 0 ? "0" : "",
                                                centerTextStyle: TextStyle(
                                                  color: colorsConst.textColor,
                                                  fontFamily: "Lato",
                                                ),
                                                legendOptions: LegendOptions(
                                                  showLegends: true,
                                                  legendTextStyle: TextStyle(color: colorsConst.textColor, fontFamily: "Lato"),
                                                ),
                                                chartValuesOptions: ChartValuesOptions(
                                                  showChartValuesInPercentage: false,
                                                  showChartValues: true,
                                                  showChartValueBackground: false,
                                                  chartValueStyle:  TextStyle(
                                                    color: totalSum == 0 ?Color(0xffE0E0E0):Colors.white,
                                                    fontFamily: "Lato",
                                                  ),
                                                  decimalPlaces: 0,
                                                ),
                                              );
                                            }),
                                          ),

                                        )
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
          ),
          15.height,
          CustomText(
            text: head,
            colors: colorsConst.textColor,
            size: 16,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/components/line_chart.dart';
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

class NewDashboard extends StatefulWidget {
  const NewDashboard({super.key});

  @override
  State<NewDashboard> createState() => _NewDashboardState();
}

class _NewDashboardState extends State<NewDashboard> {
  late FocusNode _focusNode;
  final ScrollController _controller = ScrollController();
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
       apiService.getDayReport(DateTime.now().year.toString(),DateTime.now().month.toString());
    });
    apiService.getDashBoardReport();
    apiService.getRatingReport();
    apiService.getMonthReport();
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
                    child: SingleChildScrollView(
                      controller: _controller,
                      child: Column(
                        children: [
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
                          10.height,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                height: screenHeight-60,
                                width: (screenWidth-420)/2.15,
                                child: SingleChildScrollView(
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
                                                  RatingIndicator(
                                                    color: Colors.red,
                                                    label: 'Total Hot',
                                                    value: hot,
                                                    percentage: totalCount == 0 ? 0.0 : hot / totalCount,
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
                                          countShown(width: 130, head: "Total Mails",
                                              count: controllers.mailActivity.length.toString(),icon: Icons.email),
                                          countShown(width: 130, head: "Total Calls", count: controllers.callActivity.length.toString(),icon: Icons.call),
                                          countShown(width: 130, head: "Total Meetings",
                                              count: controllers.meetingActivity.length.toString(),
                                              icon: Icons.calendar_month_outlined),
                                          countShown(
                                            width: 130,
                                            head: "Total Employees",
                                            count: context.watch<EmployeeProvider>().filteredStaff.length.toString(),
                                            icon: Icons.people_outline,
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
                                                  text:
                                                  "     Quotations Send",
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
                                                  child: Obx(()=>CustomText(
                                                    text: controllers.mailActivity.length.toString(),
                                                    colors:
                                                    colorsConst.textColor,
                                                    size: 20,
                                                    isBold: true,
                                                  ),)
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
                                height: screenHeight-60,
                                width: (screenWidth-420)/2.1,
                                child: SingleChildScrollView(
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
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    // Month Dropdown
                                                    Obx(() => DropdownButton<int>(
                                                      value: controllers.selectedChartMonth.value,
                                                      items: List.generate(12, (index) {
                                                        final month = index + 1;
                                                        return DropdownMenuItem(
                                                          value: month,
                                                          child: Text(DateFormat.MMMM().format(DateTime(0, month))),
                                                        );
                                                      }),
                                                      onChanged: (value) {
                                                        if (value != null) {
                                                          controllers.selectedChartMonth.value = value;
                                                         apiService.getDayReport(controllers.selectedChartYear.value.toString().isEmpty?DateTime.now().year.toString():controllers.selectedChartYear.value.toString(), controllers.selectedChartMonth.value.toString());
                                                        }
                                                      },
                                                    )),
                                                    20.width,
                                                    // Year Dropdown
                                                    Obx(() => DropdownButton<int>(
                                                      value: controllers.selectedChartYear.value,
                                                      items: List.generate(5, (index) {
                                                        final year = DateTime.now().year - 4 + index;
                                                        return DropdownMenuItem(
                                                          value: year,
                                                          child: Text(year.toString()),
                                                        );
                                                      }),
                                                      onChanged: (value) {
                                                        if (value != null) {
                                                          controllers.selectedChartYear.value = value;
                                                          apiService.getDayReport(controllers.selectedChartYear.value.toString().isEmpty?DateTime.now().year.toString():controllers.selectedChartYear.value.toString(), controllers.selectedChartMonth.value.toString().isEmpty?DateTime.now().month.toString():controllers.selectedChartMonth.value.toString());
                                                        }
                                                      },
                                                    )),
                                                    20.width,
                                                  ],
                                                ),

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
                                          child: PieChart(
                                            dataMap: {
                                              'Suspects': double.parse(controllers.allNewLeadsLength.value.toString()),
                                              'Prospects': double.parse(controllers.allLeadsLength.value.toString()),
                                              'Qualified': double.parse(controllers.allGoodLeadsLength.value.toString()),
                                              'Unqualified': double.parse(controllers.allDisqualifiedLength.value.toString()),  // corrected
                                              'Customers': double.parse(controllers.allCustomerLength.value.toString()),
                                            },
                                            animationDuration: const Duration(seconds: 2),
                                            chartLegendSpacing: 32,
                                            chartRadius: MediaQuery.of(context).size.width / 2.2,
                                            colorList: const [
                                              Color(0xffE3B552), // Suspects
                                              Color(0xff017EFF), // Prospects (blue)
                                              Color(0xffF55353), // Qualified (red)
                                              Color(0xff7456FC), // Unqualified (purple)
                                              Color(0xffE3528C), // Customers (pink)
                                            ],
                                            chartType: ChartType.disc,
                                            centerText: "",
                                            legendOptions: LegendOptions(
                                              showLegends: true,
                                              legendTextStyle: TextStyle(color: colorsConst.textColor),
                                            ),
                                            chartValuesOptions: ChartValuesOptions(
                                              showChartValuesInPercentage: false,
                                              showChartValues: true,
                                              showChartValueBackground: false,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
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

import 'package:flutter/material.dart';
import 'package:fullcomm_crm/billing_utils/sized_box.dart';
import 'package:fullcomm_crm/common/styles/decoration.dart';
import 'package:fullcomm_crm/components/custom_sidebar.dart';
import 'package:fullcomm_crm/controller/dashboard_controller.dart';
import 'package:fullcomm_crm/models/month_report_obj.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../common/constant/colors_constant.dart';
import '../../components/Customtext.dart';
import '../../components/custom_appbar.dart';
import '../../components/date_filter_bar.dart';
import '../../components/keyboard_search.dart';
import '../../components/report_cards.dart';
import '../../controller/controller.dart';
import '../../controller/emp_report_controller.dart';
import '../../controller/product_controller.dart';
import '../../controller/reminder_controller.dart';
import '../../models/all_customers_obj.dart';
import 'emp_filter.dart';

class EmployeeReportPage extends StatefulWidget {
  final String id;
  const EmployeeReportPage({super.key, required this.id});

  @override
  State<EmployeeReportPage> createState() => _EmployeeReportPageState();

  static Widget _button(
      String title,
      IconData icon,
      Color color,
      ) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 18, color: color),
      label: CustomText(
        text: title,
        isCopy: false,
        colors: color,
        isBold: true,
      ),
    );
  }
}

class _EmployeeReportPageState extends State<EmployeeReportPage> {
  late FocusNode _focusNode;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    repCtr.getWholeReport(widget.id);
    repCtr.empId.value=widget.id;
  }
  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Row(
        children: [
          SideBar(),
          Obx(()=>SizedBox(
            width: controllers.isLeftOpen.value==true?screenWidth-180:screenWidth-60,
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
              child: Column(
                children: [
                  CustomAppbar(
                      text:"Employee Wise Report",subText: "Detailed activity report of the selected employee",
                    // actionsWidget: EmployeeReportPage._button(
                    //   "Download",
                    //   Icons.download,
                    //   Colors.deepPurple,
                    // ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 480,
                        height: 40,
                        child: KeyboardDropdownField<AllEmployeesObj>(
                          items: controllers.employees,
                          hintText: "Search Employee Name",
                          borderRadius: 5,
                          borderColor: Colors.grey.shade200,
                          labelBuilder: (customer) =>
                          '${customer.name} ${customer.phoneNo}',
                          itemBuilder: (customer) =>
                              Container(
                                width: 300,
                                alignment: Alignment.topLeft,
                                padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                child: CustomText(
                                  text:
                                  '${customer.name} , ${customer.phoneNo}',
                                  colors: Colors.black,
                                  size: 14,
                                  isCopy: false,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                          textEditingController: controllers.cusController,
                          onSelected: (value) {
                            repCtr.empId.value=value.id;
                            repCtr.getWholeReport(repCtr.empId.value);
                          },
                          onClear: () {
                            controllers.clearSelectedCustomer();
                          },
                        ),
                      ),
                      DateFilterBar(
                        selectedSortBy: repCtr.selectedSortBy,
                        selectedRange: repCtr.selectedRange,
                        selectedMonth: repCtr.selectedMonth,
                        focusNode: _focusNode,
                        onDaysSelected: () {
                          repCtr.changeType();
                        },
                        onSelectMonth: () {
                          remController.selectMonth(
                            context,
                            repCtr.selectedSortBy,
                            repCtr.selectedMonth,
                                () {
                                  DateTime dt = DateTime.parse(repCtr.selectedMonth.toString());
                                  repCtr.stDate.value= DateFormat('dd-MM-yyyy').format(DateTime(dt.year, dt.month, 1));
                                  repCtr.enDate.value= DateFormat('dd-MM-yyyy').format(DateTime(dt.year, dt.month + 1, 0));
                                  repCtr.getWholeReport(repCtr.empId.value);
                                },false
                          );
                        },
                        onSelectDateRange: (ctx) {
                          remController.showDatePickerDialog(ctx, (pickedRange) {
                            repCtr.selectedRange.value = pickedRange;
                            List<String> dates = repCtr.selectedRange.toString().split(" - ");
                            DateTime start = DateTime.parse(dates[0]);
                            DateTime end = DateTime.parse(dates[1]);
                            repCtr.stDate.value= DateFormat('dd-MM-yyyy').format(start);
                            repCtr.enDate.value= DateFormat('dd-MM-yyyy').format(end);
                            repCtr.getWholeReport(repCtr.empId.value);
                          },false);
                        },
                      ),
                    ],
                  ),
                  20.height,
                  repCtr.refreshData.value==false?
                  CircularProgressIndicator():
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DashboardCard(
                            title: "Calls",
                            value: repCtr.totalCalls.value,
                            icon: Icons.call,
                            color: Colors.blue,
                          ),
                          DashboardCard(
                            title: "Mails",
                            value: repCtr.totalMails.value,
                            icon: Icons.mail_outline,
                            color: Colors.green,
                          ),
                          DashboardCard(
                            title: "Appointments",
                            value: repCtr.totalMeetings.value,
                            icon: Icons.calendar_today,
                            color: Colors.deepPurple,
                          ),
                          DashboardCard(
                            title: "Quotations",
                            value: repCtr.totalQuotations.value,
                            icon: Icons.description_outlined,
                            color: Colors.orange,
                          ),
                          DashboardCard(
                            title: "Leads",
                            value: repCtr.totalSuspects.value,
                            icon: Icons.groups_outlined,
                            color: Colors.pink,
                          ),
                        ],
                      ),
                      20.height,
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                            itemCount: repCtr.leadReport.length,
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {

                              int count = int.parse(
                                repCtr.leadReport[index]["total_count"].toString(),
                              );

                              double percentage = repCtr.firstCount.value == 0
                                  ? 0
                                  : (count / repCtr.firstCount.value) * 100;

                              return Row(
                                children: [
                                  Container(
                                    width: 130,
                                    padding: const EdgeInsets.all(15),
                                    decoration: customDecoration.baseBackgroundDecoration(
                                      color: controllers.leadColors[index].withOpacity(0.1),
                                      radius: 14,
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        CustomText(
                                          text: repCtr.leadReport[index]["category"],
                                          isCopy: false,
                                          colors: controllers.leadColors[index],
                                          isBold: true,
                                        ),
                                        10.height,
                                        CustomText(
                                          text: count.toString(),
                                          isCopy: false,
                                          isBold: true,
                                          size: 17,
                                        ),
                                        6.height,
                                        CustomText(
                                          text: "(${percentage.toStringAsFixed(2)}%)",
                                          isCopy: false,
                                          isBold: true,
                                        ),
                                      ],
                                    ),
                                  ),

                                  if (index != repCtr.leadReport.length - 1)
                                    const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 10),
                                      child: Icon(Icons.arrow_forward_rounded,color: Colors.grey,),
                                    ),
                                ],
                              );
                            }
                        ),
                      ),
                      20.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: screenWidth/1.4,
                            padding: const EdgeInsets.all(16),
                            decoration: customDecoration.baseBackgroundDecoration(
                              color: Colors.white,
                              radius: 15,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: screenWidth/8,
                                      child: CustomText(
                                        text: "Comparison Report",
                                        isCopy: false,
                                        isBold: true,textAlign: TextAlign.start,
                                      ),
                                    ),
                                    SizedBox(
                                      width: screenWidth/7,
                                      child: CustomText(
                                        text: "Last Week",
                                        isCopy: false,
                                        isBold: true,
                                      ),
                                    ),
                                    SizedBox(
                                      width: screenWidth/7,
                                      child: CustomText(
                                        text: "This Week",
                                        isCopy: false,
                                        isBold: true,
                                      ),
                                    ),
                                  ],
                                ),10.height,
                                Row(
                                  children: [
                                    SizedBox(
                                      width: screenWidth/8,
                                      child: CustomText(
                                        text: "Activity",
                                        isCopy: false,
                                        isBold: true,textAlign: TextAlign.start,
                                      ),
                                    ),
                                    SizedBox(
                                      width: screenWidth/7,
                                      child: CustomText(
                                        text: "${DateFormat('dd/MM/yyyy').format(repCtr.lastWeekStart)} to ${DateFormat('dd/MM/yyyy').format(repCtr.lastWeekEnd)}",
                                        isCopy: false,
                                        isBold: true,
                                      ),
                                    ),
                                    SizedBox(
                                      width: screenWidth/7,
                                      child: CustomText(
                                        text: "${DateFormat('dd/MM/yyyy').format(repCtr.thisWeekStart)} to ${DateFormat('dd/MM/yyyy').format(repCtr.thisWeekEnd)}",
                                        isCopy: false,
                                        isBold: true,
                                      ),
                                    ),
                                    SizedBox(
                                      width: screenWidth/8,
                                      child: CustomText(
                                        text: "Change",
                                        isCopy: false,
                                        isBold: true,
                                      ),
                                    ),
                                    SizedBox(
                                      width: screenWidth/6.5,
                                      child: CustomText(
                                        text: "Change %",
                                        isCopy: false,
                                        isBold: true,
                                      ),
                                    ),
                                  ],
                                ),

                                const Divider(),

                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: repCtr.comparisonReport.length,
                                  separatorBuilder: (_, __) => const Divider(height: 1),
                                  itemBuilder: (context, index) {

                                    final data = repCtr.comparisonReport[index];

                                    double percent =
                                        double.tryParse(data["change_percent"].toString()) ?? 0;
                                    int change = data["change"];

                                    bool isPositive = change >= 0;

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: screenWidth/8,
                                            child: Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 14,
                                                  backgroundColor: controllers.leadColors[index]
                                                      .withOpacity(.15),
                                                  child: Icon(
                                                    repCtr.activityIcons[index],
                                                    size: 15,
                                                    color: controllers.leadColors[index],
                                                  ),
                                                ),

                                                const SizedBox(width: 10),

                                                CustomText(
                                                  text: data["activity"],
                                                  isCopy: false,
                                                  textAlign: TextAlign.left,
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: screenWidth/7,
                                            child: CustomText(
                                              text: data["previous"].toString(),
                                              isCopy: false,
                                            ),
                                          ),
                                          SizedBox(
                                            width: screenWidth/7,
                                            child: CustomText(
                                              text: data["current"].toString(),
                                              isCopy: false,
                                            ),
                                          ),

                                          SizedBox(
                                            width: screenWidth/8,
                                            child: CustomText(
                                              text: data["change"] > 0
                                                  ? "+${data["change"]}"
                                                  : data["change"].toString(),
                                              isCopy: false,
                                              colors:
                                              isPositive ? Colors.green : Colors.red,
                                              isBold: true,
                                            ),
                                          ),

                                          SizedBox(
                                            width: screenWidth/6.5,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                CustomText(
                                                  text:
                                                  "${percent.toStringAsFixed(2)}%",
                                                  isCopy: false,
                                                  colors:
                                                  isPositive ? Colors.green : Colors.red,
                                                  isBold: true,
                                                ),
                                                const SizedBox(width: 5),
                                                Icon(
                                                  isPositive
                                                      ? Icons.arrow_drop_up
                                                      : Icons.arrow_drop_down,
                                                  color:
                                                  isPositive ? Colors.green : Colors.red,
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                )
                              ],
                            ),
                          ),
                          Container(
                            width: screenWidth/6,
                            padding: const EdgeInsets.all(18),
                            decoration: customDecoration.baseBackgroundDecoration(
                              color: Colors.white,
                              radius: 14,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                25.height,
                                const CustomText(
                                  text: "Activity Summary",
                                  isCopy: false,
                                  isBold: true,
                                  size: 15,
                                ),

                                45.height,

                                _summaryRow(
                                  "Total Activities",
                                  repCtr.activeReport["total_activities"].toString(),screenWidth/15
                                ),

                                const Divider(height: 75),

                                _summaryRow(
                                  "Average Per Day",
                                  repCtr.activeReport["average_per_day"].toString(),screenWidth/15
                                ),

                                const Divider(height: 75),

                                _summaryRow(
                                  "Most Active Day",
                                  "${repCtr.activeReport["most_active_day"]}\n(${repCtr.activeReport["most_active_count"]} Activities)",screenWidth/15
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      20.height,
                    ],
                  ),
                ],
              ),
            ),
          ),)
        ],
      ),
    );
  }
  Widget _summaryRow(String title, String value,double width) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        SizedBox(
          // color: Colors.purple,
          width: width,
          child: CustomText(
            text: title,
            isCopy: false,
            colors: Colors.grey,
            textAlign: TextAlign.left,
          ),
        ),

        CustomText(
          text: value.trim(),
          isCopy: false,
          isBold: true,
          textAlign: TextAlign.right,
        ),
      ],
    );
  }
}
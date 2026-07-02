import 'package:flutter/material.dart';
import 'package:fullcomm_crm/billing_utils/sized_box.dart';
import 'package:fullcomm_crm/common/styles/decoration.dart';
import 'package:fullcomm_crm/components/custom_sidebar.dart';
import 'package:fullcomm_crm/controller/dashboard_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../components/Customtext.dart';
import '../../components/custom_appbar.dart';
import '../../components/report_cards.dart';
import '../../controller/controller.dart';
import '../../controller/emp_report_controller.dart';
import 'emp_filter.dart';

class EmployeeReportPage extends StatefulWidget {
  const EmployeeReportPage({super.key});

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
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    repCtr.getWholeReport();
  }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xffF6F8FC),
      body: Row(
        children: [
          SideBar(),
          Obx(()=>Container(
            width: controllers.isLeftOpen.value==true?screenWidth-180:screenWidth-60,
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.all(20),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomAppbar(
                      text:"Employee Wise Report",subText: "Detailed activity report of the selected employee",
                    actionsWidget: EmployeeReportPage._button(
                      "Download",
                      Icons.download,
                      Colors.deepPurple,
                    ),
                  ),
                  const EmployeeFilter(),
                  20.height,
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
                  20.width,
                  Container(
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

                            const Expanded(
                              flex: 2,
                              child: CustomText(
                                text: "Activity",
                                isCopy: false,
                                isBold: true,
                              ),
                            ),

                            Expanded(
                              child: CustomText(
                                text: "${DateFormat('dd/MM/yyyy').format(repCtr.lastWeekStart)} to ${DateFormat('dd/MM/yyyy').format(repCtr.lastWeekEnd)}",
                                isCopy: false,
                                isBold: true,
                              ),
                            ),

                            Expanded(
                              child: CustomText(
                                text: "${DateFormat('dd/MM/yyyy').format(repCtr.thisWeekStart)} to ${DateFormat('dd/MM/yyyy').format(repCtr.thisWeekEnd)}",
                                isCopy: false,
                                isBold: true,
                              ),
                            ),

                            const Expanded(
                              child: CustomText(
                                text: "Change",
                                isCopy: false,
                                isBold: true,
                              ),
                            ),

                            const Expanded(
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

                                  Expanded(
                                    flex: 2,
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

                                        Expanded(
                                          child: CustomText(
                                            text: data["activity"],
                                            isCopy: false,
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: CustomText(
                                      text: data["previous"].toString(),
                                      isCopy: false,
                                    ),
                                  ),
                                  Expanded(
                                    child: CustomText(
                                      text: data["current"].toString(),
                                      isCopy: false,
                                    ),
                                  ),

                                  Expanded(
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

                                  Expanded(
                                    child: Row(
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
                  )
                ],
              ),
            ),
          ),)
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/constant/colors_constant.dart';
import 'package:fullcomm_crm/controller/dashboard_controller.dart';
import 'package:fullcomm_crm/controller/emp_report_controller.dart';
import 'package:intl/intl.dart';

import '../../billing_utils/sized_box.dart';
import '../../components/Customtext.dart';
import '../../controller/controller.dart';

class EmployeePerformanceTable extends StatefulWidget {
  final double width;
  const EmployeePerformanceTable({super.key, required this.width});

  @override
  State<EmployeePerformanceTable> createState() => _EmployeePerformanceTableState();
}

class _EmployeePerformanceTableState extends State<EmployeePerformanceTable> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    repCtr.stDate.value = DateFormat('dd-MM-yyyy').format(DateTime.now());
    repCtr.enDate.value = DateFormat('dd-MM-yyyy').format(DateTime.now());
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: 310,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black12,
            offset: Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: "High Performance Employees",
            size: 15,
            isBold: true,
            isCopy: false,
          ),
          5.height,
          CustomText(
            text: "Performance summary based on Lead, Customer, Quotation, Calls & Mail.",
            colors: Colors.grey,
            isCopy: false,size: 13,
          ),
          12.height,
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: colorsConst.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5),
                topRight: Radius.circular(5),
              ),
            ),
            child: Row(
              children: const [

                HeaderWidget("  Employee", width: 150,color: Colors.red,),

                HeaderWidget("Leads", width: 60,color: Colors.pink),

                HeaderWidget("Customers", width: 95,color: Colors.brown),

                HeaderWidget("Quotations", width: 95,color: Colors.purple),

                HeaderWidget("Appointments", width: 110,color: Colors.grey),

                HeaderWidget("Calls", width: 50,color: Colors.orange),

                HeaderWidget("Mails", width: 50,color: Colors.green),

                HeaderWidget("Score", width: 100,color: Colors.yellow),

              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dashController.performanceReport.length,
            itemBuilder: (_, index) {
              var data=dashController.performanceReport[index];
              return Padding(
                padding: const EdgeInsets.fromLTRB(0, 3, 0, 3),
                child: Row(
                  children: [
                    EmployeeProfile(name: data["s_name"],),
                    SizedBox(
                      width: 60,
                      child: CustomText(
                          text: data["leads"].toString(),
                          isCopy: false,
                          isBold: true,textAlign: TextAlign.start
                      ),
                    ),SizedBox(
                      width: 95,
                      child: CustomText(
                          text: data["customers"].toString(),
                          isCopy: false,
                          isBold: true,textAlign: TextAlign.start
                      ),
                    ),
                    SizedBox(
                      width: 95,
                      child: CustomText(
                          text: data["quotations"].toString(),
                          isCopy: false,
                          isBold: true,textAlign: TextAlign.start
                      ),
                    ),SizedBox(
                      width: 110,
                      child: CustomText(
                          text: data["meetings"].toString(),
                          isCopy: false,
                          isBold: true,textAlign: TextAlign.start
                      ),
                    ),SizedBox(
                      width: 50,
                      child: CustomText(
                          text: data["calls"].toString(),
                          isCopy: false,
                          isBold: true,textAlign: TextAlign.start
                      ),
                    ),SizedBox(
                      width: 50,
                      child: CustomText(
                        text: data["mails"].toString(),
                        isCopy: false,
                        isBold: true,textAlign: TextAlign.start,
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: PerformanceBar(
                        percentage: double.parse(data["total_activity"].toString()),
                      ),
                    )

                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }
}

class HeaderWidget extends StatelessWidget {

  final double width;
  final String title;
  final Color? color;

  const HeaderWidget(
      this.title,{
        super.key, required this.width, this.color,
      });

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      width: width,
      child: CustomText(
        text: title,colors: Colors.white,
        isCopy: false,size: 15,
        isBold: true,textAlign: TextAlign.start
      ),
    );
  }
}

class EmployeeProfile extends StatelessWidget {
  final String name;
  const EmployeeProfile({super.key, required this.name});

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          CustomText(
            text: "  $name",
            isCopy: false,
            isBold: true,
          ),

          // SizedBox(height:4),
          //
          // CustomText(
          //   text: "  Sales Executive",
          //   isCopy: false,
          //   colors: Colors.grey,
          // )

        ],
      ),
    );
  }
}

class PerformanceBar extends StatelessWidget {
  final double percentage;

  const PerformanceBar({
    super.key,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: "${percentage.toStringAsFixed(0)}%",
          isCopy: false,
          isBold: true,
          colors: Colors.green,
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 8,
            backgroundColor: Colors.grey.shade300,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
          ),
        ),
      ],
    );
  }
}
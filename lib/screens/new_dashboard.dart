import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:get/get.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/constant/colors_constant.dart';
import '../common/utilities/utils.dart';
import '../components/custom_text.dart';
import '../controller/controller.dart';
import '../main.dart';
import '../services/api_services.dart';
import 'dashboard.dart';

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
    });
    Future.delayed(Duration.zero, () async {
      controllers.selectedIndex.value = 0;
      final prefs = await SharedPreferences.getInstance();
      controllers.isAdmin.value = prefs.getBool("isAdmin") ?? false;
    });
    apiService.getDashBoardReport();
    apiService.getRatingReport();
  }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return SelectionArea(
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
                              height: screenHeight-80,
                              width: (screenWidth-420)/2.1,
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
                                         Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                           Obx(()=> RatingIndicator(
                                             color: Colors.red,
                                             label: 'Total Hot',
                                             value: int.parse(controllers.totalHot.value),
                                             percentage: 0.2,
                                           ),),
                                           Obx(()=> RatingIndicator(
                                             color: Colors.yellow,
                                             label: 'Total Warm',
                                             value: int.parse(controllers.totalWarm.value),
                                             percentage: 0.6,
                                           ),),
                                           Obx(()=> RatingIndicator(
                                             color: Colors.green,
                                             label: 'Total Cold',
                                             value: int.parse(controllers.totalCold.value),
                                             percentage: 0.4,
                                           ),),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  10.height,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      countShown(
                                          width:150,
                                          head: "Total Mails",
                                          count: controllers.mailActivity.length.toString()),
                                      20.width,
                                      countShown(
                                          width:150,
                                          head: "Total Calls",
                                          count: controllers.callActivity.length.toString()),
                                      20.width,
                                      countShown(
                                          width:150,
                                          head: "Total Meetings",
                                          count: controllers.meetingActivity.length.toString()),
                                    ],
                                  ),
                                  10.height,
                                  Container(
                                    height: 220,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                        BorderRadius.circular(10),
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
                                                backgroundColor:
                                                Color(0xff5D5FEF),
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
                            SizedBox(
                              height: screenHeight-80,
                              width: (screenWidth-420)/2.1,
                              child: Column(
                                children: [
                                  Container(
                                    height: 260,
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
                                            CustomText(
                                              text: "2025          ",
                                              size: 13,
                                              colors: colorsConst.textColor,
                                            ),
                                          ],
                                        ),
                                        15.height,
                                        Container(
                                            alignment: Alignment.center,
                                            width: 380,
                                            height: 210,
                                            child: const LineChartWidget())
                                      ],
                                    ),
                                  ),
                                  20.height,
                                  Container(
                                    height: 400,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      // border: Border.all(
                                      //     color: Colors.black
                                      // ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: SizedBox(
                                      height: 200,
                                      child: PieChart(
                                        dataMap: {
                                          'Suspects': double.parse(
                                              controllers.allNewLeadsLength.value.toString()),
                                          'Prospects': double.parse(
                                              controllers
                                                  .allLeadsLength
                                                  .value
                                                  .toString()),
                                          'Qualified': double.parse(
                                              controllers.allGoodLeadsLength.value
                                                  .toString()),
                                          'Disqualified': double.parse(
                                              controllers.allGoodLeadsLength.value
                                                  .toString()),
                                          'Customers': double.parse(
                                              controllers
                                                  .allCustomerLength
                                                  .value
                                                  .toString()),
                                        },
                                        centerTextStyle: TextStyle(
                                            color: colorsConst.textColor),
                                        baseChartColor: Colors.white,
                                        legendOptions: LegendOptions(
                                            legendTextStyle:
                                            TextStyle(
                                                color: colorsConst
                                                    .textColor)),
                                        animationDuration:
                                        const Duration(
                                            seconds: 2),
                                        chartLegendSpacing: 50,
                                        chartRadius:
                                        MediaQuery.of(context)
                                            .size
                                            .width /
                                            2.7,
                                        colorList: const [
                                          Color(0xff94009C),
                                          Color(0xffE3B552),
                                          Color(0xff2DD28A),
                                          Color(0xff7456FC),
                                          Color(0xffE3528C),
                                        ],
                                        chartType: ChartType.ring,
                                        ringStrokeWidth: 50,

                                        // chartValueBackgroundColor: Colors.green,
                                        // chartValueBackgroundOpacity: 0.7,
                                      ),
                                    ),
                                  ),
                                ],
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
    );
  }
  Widget countShown({required double width, required String head, required String count}) {
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

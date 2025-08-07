import 'package:get/get.dart';
import 'package:fullcomm_crm/common/extentions/lib_extensions.dart';
import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/constant/colors_constant.dart';
import 'package:fullcomm_crm/components/custom_text.dart';
import 'package:fullcomm_crm/services/api_services.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common/utilities/utils.dart';
import '../controller/controller.dart';
import '../main.dart';

class RatingIndicator extends StatelessWidget {
  final Color color;
  final String label;
  final int value;
  final double percentage;

  const RatingIndicator({super.key,
    required this.color,
    required this.label,
    required this.value,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context){
    return Column(
      children: [
        CircularPercentIndicator(
          radius: 40.0,
          lineWidth: 13.0,
          animation: true,
          percent: percentage,
          //restartAnimation: true,
          reverse: true,
          center: Text(
            '$value',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
              color: Colors.white,
            ),
          ),
          circularStrokeCap: CircularStrokeCap.square,
          progressColor: color,
          backgroundColor: colorsConst.primary,
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}




class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero,()async{
      controllers.selectedIndex.value=0;
      final prefs =await SharedPreferences.getInstance();
      controllers.isAdmin.value=prefs.getBool("isAdmin")??false;
    });
    apiService.getDashBoardReport();
  }
  @override
  Widget build(BuildContext context){
    double screenWidth=MediaQuery.of(context).size.width;
    return SelectionArea(
      child: Scaffold(
        backgroundColor: colorsConst.primary,
        // appBar:   PreferredSize(
        //   preferredSize:  const Size.fromHeight(60),
        //   child:  CustomAppbar(text: appName,),
        // ),
        body:Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:[
            utils.sideBarFunction(context),
            Obx(()=>Container(
                width:controllers.isLeftOpen.value==false&&controllers.isRightOpen.value==false?screenWidth-200:screenWidth-450,
                height: MediaQuery.of(context).size.height,
                alignment: Alignment.center,
                child:SingleChildScrollView(
                  child: Column(
                    children:[
                      20.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:[
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
                      30.height,
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children:[
                      //     Tooltip(
                      //       message: "View all Call Activity Report",
                      //       padding: const EdgeInsets.all(8),
                      //       //margin: const EdgeInsets.symmetric(horizontal: 20),
                      //       verticalOffset: -100,
                      //
                      //       textStyle:  TextStyle(
                      //           color: colorsConst.textColor, fontSize: 12),
                      //       decoration: BoxDecoration(
                      //         color: Colors.black,
                      //         borderRadius: BorderRadius.circular(8),
                      //       ),
                      //       child: InkWell(
                      //         onTap: (){
                      //           controllers.customCommentsFuture = apiService.allCommentReportDetails();
                      //           Get.to(const CallComments());
                      //         },
                      //         child: Obx(()=>Container(
                      //           height: 250,
                      //           width: (controllers.isLeftOpen.value==false&&controllers.isRightOpen.value==false?screenWidth-250:screenWidth-490)/1.9,
                      //           decoration: BoxDecoration(
                      //             color: colorsConst.secondary,
                      //             borderRadius: BorderRadius.circular(10),
                      //           ),
                      //           child:Column(
                      //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //             children:[
                      //               Row(
                      //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //                 children:[
                      //                   CustomText(
                      //                     text: "     Daily Activity Report",
                      //                     colors: colorsConst.third,
                      //                     size: 18,
                      //                     isBold: true,
                      //                   ),
                      //                   IconButton(
                      //                       tooltip: "View all Call Activity Report",
                      //                       onPressed: (){
                      //                         controllers.customCommentsFuture = apiService.allCommentReportDetails();
                      //                         Get.to(const CallComments());
                      //                       },
                      //                       icon: Icon(Icons.arrow_forward,
                      //                         color: colorsConst.textColor,
                      //                       ))
                      //                 ],
                      //               ),
                      //               Row(
                      //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //                 children:[
                      //                   Obx(()=>utils.leadFirstCon("assets/images/person1.svg",controllers.directVisit.value,"Direct Visit"),),
                      //                   Obx(()=>utils.leadFirstCon("assets/images/person2.svg",controllers.telephoneCalls.value,"Telephone call"),),
                      //                   //utils.leadFirstCon("assets/images/person3.svg","30","This Month"),
                      //                 ],
                      //               )
                      //             ],
                      //           ),
                      //         ),)
                      //       ),
                      //     ),
                      //     20.width,
                      //     Container(
                      //       width: (screenWidth-500)/2.4,
                      //       height: 250,
                      //       decoration: BoxDecoration(
                      //           color: colorsConst.secondary,
                      //           borderRadius: BorderRadius.circular(10)
                      //       ),
                      //       child: Column(
                      //         children: [
                      //           5.height,
                      //           Row(
                      //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //             children:[
                      //               CustomText(
                      //                 text: "       New Customers",
                      //                 size: 16,
                      //                 isBold: true,
                      //                 colors: colorsConst.textColor,
                      //               ),
                      //               CustomText(
                      //                 text: "2023          ",
                      //                 size: 13,
                      //                 colors: colorsConst.textColor,
                      //               ),
                      //             ],
                      //           ),
                      //           15.height,
                      //           Container(
                      //               alignment: Alignment.center,
                      //               width: 380,
                      //               height: 210,
                      //               child:const LineChartWidget()
                      //             //         LineChart(LineChartData(
                      //             //   gridData: const FlGridData(show: false),
                      //             //   titlesData: const FlTitlesData(show: true),
                      //             //   borderData: FlBorderData(show: false),
                      //             //   lineBarsData: [
                      //             //     LineChartBarData(
                      //             //       spots: [
                      //             //         FlSpot(0, 1),
                      //             //         FlSpot(1, 3),
                      //             //         FlSpot(2, 10),
                      //             //         FlSpot(3, 7),
                      //             //         FlSpot(4, 12),
                      //             //         FlSpot(5, 13),
                      //             //         FlSpot(6, 17),
                      //             //       ],
                      //             //       isCurved: true,
                      //             //       color: Colors.blue,
                      //             //       barWidth: 4,
                      //             //       isStrokeCapRound: true,
                      //             //       dotData: FlDotData(show: false),
                      //             //     ),
                      //             //   ],
                      //             // )),
                      //           )
                      //         ],
                      //       ),
                      //     )
                      //   ],
                      // ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: (screenWidth-550)/2,
                            height: 220,
                            decoration: BoxDecoration(
                              color: colorsConst.secondary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children:[
                                20.height,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children:[
                                    CustomText(
                                      text: "       Rating",
                                      size: 16,
                                      isBold: true,
                                      colors: colorsConst.textColor,
                                    ),
                                    CustomText(
                                      text: "Month          ",
                                      size: 13,
                                      colors: colorsConst.textColor,
                                    ),
                                  ],
                                ),
                                30.height,
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    RatingIndicator(
                                      color: Colors.red,
                                      label: 'Total Hot',
                                      value: 20,
                                      percentage: 0.2,
                                    ),
                                    RatingIndicator(
                                      color: Colors.yellow,
                                      label: 'Total Warm',
                                      value: 120,
                                      percentage: 0.6,
                                    ),
                                    RatingIndicator(
                                      color: Colors.green,
                                      label: 'Total Cold',
                                      value: 50,
                                      percentage: 0.4,
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                              20.width,
                              Container(
                                width: (screenWidth-500)/2.4,
                                height: 250,
                                decoration: BoxDecoration(
                                    color: colorsConst.secondary,
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                child: Column(
                                  children: [
                                    5.height,
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children:[
                                        CustomText(
                                          text: "       New Customers",
                                          size: 16,
                                          isBold: true,
                                          colors: colorsConst.textColor,
                                        ),
                                        CustomText(
                                          text: "2023          ",
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
                                        child:const LineChartWidget()
                                    )
                                  ],
                                ),
                              )
                        ],
                      ),
                      40.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children:[
                          Column(
                            children:[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  countShown(width: screenWidth * 0.11, head: "Total Suspects", count: "53"),
                                  20.width,
                                  countShown(width: screenWidth * 0.11, head: "Total Prospects", count: "31"),
                                  20.width,
                                  countShown(width: screenWidth * 0.11, head: "Total Qualified", count: "28"),
                                  20.width,
                                  countShown(width: screenWidth * 0.11, head: "Total Customers", count: "7"),
                                ],
                              ),
                              20.height,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children:[
                                  Container(
                                    width: (screenWidth-550)/2.5,
                                    height: 220,
                                    decoration: BoxDecoration(
                                      color: colorsConst.secondary,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      children: [
                                        10.height,
                                        // Row(
                                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        //   children:[
                                        //     CustomText(
                                        //       text: "     Email",
                                        //       size: 16,
                                        //       isBold: true,
                                        //       colors: colorsConst.textColor,
                                        //     ),
                                        //     CustomText(
                                        //       text: "Last Week      ",
                                        //       size: 13,
                                        //       colors: colorsConst.textColor,
                                        //     ),
                                        //   ],
                                        // ),
                                        20.height,
                                        SizedBox(
                                          width: 300,
                                          height: 150,
                                          child: PieChart(
                                            dataMap:  {
                                              'Suspects': double.parse(controllers.allNewLeadsLength.value.toString()),
                                              'Prospects': double.parse(controllers.allLeadsLength.value.toString()),
                                              'Qualified': double.parse(controllers.allGoodLeadsLength.value.toString()),
                                              'Customers': double.parse(controllers.allCustomerLength.value.toString()),
                                            },
                                            centerTextStyle: TextStyle(
                                                color: colorsConst.textColor
                                            ),
                                            baseChartColor: Colors.white,
                                            legendOptions: LegendOptions(
                                                legendTextStyle: TextStyle(
                                                    color:colorsConst.textColor
                                                )
                                            ),
                                            animationDuration: const Duration(seconds: 2),
                                            chartLegendSpacing: 50,
                                            chartRadius: MediaQuery.of(context).size.width / 2.7,
                                            colorList: const [Color(0xff94009C),Color(0xffE3B552),Color(0xff2DD28A),Color(0xffE3528C)],
                                            chartType: ChartType.ring,
                                            ringStrokeWidth: 50,

                                            // chartValueBackgroundColor: Colors.green,
                                            // chartValueBackgroundOpacity: 0.7,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  40.width,
                                  Container(
                                    width: (screenWidth-500)/3.5,
                                    height: 220,
                                    decoration: BoxDecoration(
                                      color: colorsConst.secondary,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      children: [
                                        20.height,
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children:[
                                            CustomText(
                                              text: "     Quotations Send",
                                              size: 16,
                                              isBold: true,
                                              colors: colorsConst.textColor,
                                            ),
                                            CustomText(
                                              text: "Last Month      ",
                                              size: 13,
                                              colors: colorsConst.textColor,
                                            ),
                                          ],
                                        ),
                                        40.height,
                                        Stack(
                                          children:[
                                            Container(
                                              width: 100,
                                              height: 100,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                  color: colorsConst.primary,
                                                  borderRadius: BorderRadius.circular(50),
                                                  border: Border.all(
                                                      color: const Color(0xff5D5FEF),
                                                      width: 2.4
                                                  )
                                              ),
                                              child: CustomText(
                                                text: "200",
                                                colors: colorsConst.textColor,
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
                              )
                            ],
                          ),
                          Container(
                            width:(screenWidth-500)/3.5,
                            height: 465,
                            decoration: BoxDecoration(
                              color: colorsConst.secondary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                10.height,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children:[
                                    CustomText(
                                      text: "      New Customers Orders",
                                      size: 16,
                                      isBold: true,
                                      colors: colorsConst.textColor,
                                    ),
                                    CustomText(
                                      text: "Week           ",
                                      size: 13,
                                      colors: colorsConst.textColor,
                                    ),
                                  ],
                                ),
                                10.height,
                                Container(
                                    height: 400,
                                    width: screenWidth/5.5,
                                    alignment: Alignment.center,
                                    child: utils.barChart()),
                              ],
                            ),
                          ),
                        ],
                      ),
                      20.height,
                    ],
                  ),
                )
            ),),
            utils.funnelContainer(context)
          ],
        )
      ),
    );
  }
  Widget countShown({required double width,required String head,required String count}){
    return Container(
      width: width,
      height: 180,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colorsConst.secondary,
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
            text: head,
            colors: colorsConst.textColor,
            size: 16,
          ),
          15.height,
          CustomText(
            text: count,
            colors: colorsConst.headColor,
            size: 30,
          ),
        ],
      ),
    );
  }

}

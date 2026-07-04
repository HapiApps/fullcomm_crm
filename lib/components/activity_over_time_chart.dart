import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/controller/controller.dart';
import 'package:fullcomm_crm/controller/dashboard_controller.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../controller/reminder_controller.dart';
import '../screens/records/records.dart';
import 'Customtext.dart';

class ActivityLineData {
  final String label;
  final List<double> values;
  final Color color;

  ActivityLineData({
    required this.label,
    required this.values,
    required this.color,
  });
}

class ActivityOverTimeChart extends StatefulWidget {
  final double width;
  final List<String> xLabels;
  final List<ActivityLineData> lines;

  const ActivityOverTimeChart({
    super.key,
    required this.xLabels,
    required this.lines, required this.width,
  });

  @override
  State<ActivityOverTimeChart> createState() =>
      _ActivityOverTimeChartState();
}
double getMaxY() {
  final allValues = [
    ...controllers.calls,
    ...controllers.mails,
    ...controllers.updates,
  ];

  // Empty list check
  if (allValues.isEmpty) {
    return 10;
  }

  double maxValue = allValues.reduce(
        (a, b) => a > b ? a : b,
  );

  // all values 0 na
  if (maxValue <= 0) {
    return 10;
  }

  return (maxValue + 2).ceilToDouble();
}

class _ActivityOverTimeChartState
    extends State<ActivityOverTimeChart> {

  OverlayEntry? _overlayEntry;

  void _showTooltip(
      Offset localPosition,
      int index,
      List<LineBarSpot> spots,
      ) {

    _removeTooltip();

    final RenderBox box =
    context.findRenderObject() as RenderBox;

    final Offset global =
    box.localToGlobal(localPosition);

    _overlayEntry = OverlayEntry(
      builder: (_) => Positioned(
        left: global.dx + 20,
        top: global.dy - 120,
        child: _TooltipCard(
          date: widget.xLabels[index],
          spots: spots,
          lines: widget.lines,
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeTooltip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    // print("widget.xLabels");
    // print(widget.xLabels);
    // print(widget.lines);
    // double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      // height: 360, width: screenWidth/1.8,
      height: 400, width: widget.width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomText(
              text: "Activity over time",
              isCopy: false,
              size: 15,
              isBold: true,
              colors: Colors.black,
            ),
           4.height,
            CustomText(
              text:  "Calls, mails, and customer updates",
              isCopy: false,
              size: 13,
              isBold: false,
              colors:  Color(0xff666666),
            ),

            12.height,

            const Divider(
              height: 1,
              thickness: 1,
              color: Color(0xffE5E7EB),
            ),

           16.height,

            // Expanded(
            //   child: LineChart(
            //     LineChartData(
            //       minY: 0,
            //       maxY: getMaxY(),
            //       borderData: FlBorderData(show: false),
            //
            //       gridData: FlGridData(
            //         show: true,
            //         drawVerticalLine: false,
            //         horizontalInterval: getMaxY() / 4,
            //         getDrawingHorizontalLine: (value) => const FlLine(
            //           color: Color(0xffE2E8F0),
            //           strokeWidth: 1,
            //           dashArray: [4, 4],
            //         ),
            //       ),
            //
            //       titlesData: FlTitlesData(
            //         topTitles: AxisTitles(
            //             sideTitles: SideTitles(showTitles: false)),
            //         rightTitles: AxisTitles(
            //             sideTitles: SideTitles(showTitles: false)),
            //
            //         leftTitles: AxisTitles(
            //           sideTitles: SideTitles(
            //             showTitles: true,
            //             interval: getMaxY() / 4,
            //             reservedSize: 28,
            //             getTitlesWidget: (value, meta) => Text(
            //               value.toInt().toString(),
            //               style: const TextStyle(
            //                 fontSize: 12,
            //                 color: Colors.black,
            //                 fontWeight: FontWeight.bold
            //               ),
            //             ),
            //           ),
            //         ),
            //         bottomTitles: AxisTitles(
            //           sideTitles: SideTitles(
            //             showTitles: true,
            //             interval: 1,
            //             getTitlesWidget: (value, meta) {
            //               final i = value.toInt();
            //               if (i < 0 || i >= widget.xLabels.length) {
            //                 return const SizedBox.shrink();
            //               }
            //               return Padding(
            //                 padding: const EdgeInsets.only(top: 8),
            //                 child: Text(
            //                   widget.xLabels[i],
            //                   style: const TextStyle(
            //                       fontSize: 10,
            //                       color: Colors.black,
            //                       fontWeight: FontWeight.normal
            //                   ),
            //                 ),
            //               );
            //             },
            //           ),
            //         ),
            //       ),
            //
            //       lineBarsData: widget.lines.map((line) {
            //         return LineChartBarData(
            //           spots: List.generate(
            //             line.values.length,
            //                 (i) => FlSpot(
            //               i.toDouble(),
            //               line.values[i],
            //             ),
            //           ),
            //           isCurved: true,
            //           color: line.color,
            //           barWidth: 3,
            //           dotData: FlDotData(show: false),
            //         );
            //       }).toList(),
            //
            //       lineTouchData: LineTouchData(
            //         enabled: true,
            //         handleBuiltInTouches: false,
            //         getTouchedSpotIndicator: (barData, spotIndexes) {
            //           return spotIndexes.map((index) {
            //             return TouchedSpotIndicatorData(
            //               const FlLine(
            //                 color: Color(0xffE5E7EB),
            //                 strokeWidth: 1,
            //                 dashArray: [4, 4],
            //               ),
            //               FlDotData(
            //                 show: true,
            //                 getDotPainter: (spot, percent, bar, i) =>
            //                     FlDotCirclePainter(
            //                       radius: 5,
            //                       color: bar.color!,
            //                       strokeWidth: 2,
            //                       strokeColor: Colors.white,
            //                     ),
            //               ),
            //             );
            //           }).toList();
            //         },
            //         touchCallback: (event, response) {
            //           if (!event.isInterestedForInteractions ||
            //               response == null ||
            //               response.lineBarSpots == null) {
            //             _removeTooltip();
            //             return;
            //           }
            //
            //           final spots = response.lineBarSpots!;
            //           final index = spots.first.x.toInt();
            //
            //           _showTooltip(
            //             event.localPosition!,
            //             index,
            //             spots,
            //           );
            //         },
            //         touchTooltipData: LineTouchTooltipData(
            //           getTooltipItems: (spots) {
            //             return spots.map((_) {
            //               return LineTooltipItem(
            //                 '',
            //                 const TextStyle(
            //                   color: Colors.transparent,
            //                 ),
            //               );
            //             }).toList();
            //           },
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            Expanded(
              child: SizedBox(
                width: widget.width/1,
                child: LineChart(
                  LineChartData(

                    /// IMPORTANT
                    minX: 0,
                    maxX: (widget.xLabels.length - 1).toDouble(),
                    minY: 0,
                    maxY: getMaxY(),

                    borderData: FlBorderData(show: false),

                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: getMaxY() / 4,
                      getDrawingHorizontalLine: (value) => const FlLine(
                        color: Color(0xffE2E8F0),
                        strokeWidth: 1,
                        dashArray: [4, 4],
                      ),
                    ),

                    titlesData: FlTitlesData(
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),

                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),

                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: getMaxY() / 4,
                          reservedSize: 30,

                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),

                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,

                          getTitlesWidget: (value, meta) {

                            int i = value.toInt();

                            if (i < 0 || i >= widget.xLabels.length) {
                              return const SizedBox();
                            }

                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                widget.xLabels[i],
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.black,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    /// LINES
                    lineBarsData: widget.lines.map((line) {

                      // print("LINE => ${line.label}");
                      // print(line.values);

                      return LineChartBarData(

                        spots: List.generate(
                          line.values.length,
                              (i) {

                            // print("spot => $i : ${line.values[i]}");

                            return FlSpot(
                              i.toDouble(),
                              line.values[i],
                            );
                          },
                        ),

                        isCurved: true,
                        color: line.color,
                        barWidth: 3,
                        isStrokeCapRound: true,

                        dotData: FlDotData(
                          show: true,
                        ),

                        belowBarData: BarAreaData(
                          show: false,
                        ),
                      );

                    }).toList(),

                    /// TOUCH
                    lineTouchData: LineTouchData(
                      enabled: true,
                      handleBuiltInTouches: false,

                      getTouchedSpotIndicator:
                          (barData, spotIndexes) {

                        return spotIndexes.map((index) {

                          return TouchedSpotIndicatorData(

                            const FlLine(
                              color: Color(0xffE5E7EB),
                              strokeWidth: 1,
                              dashArray: [4, 4],
                            ),

                            FlDotData(
                              show: true,

                              getDotPainter:
                                  (spot, percent, bar, i) {

                                return FlDotCirclePainter(
                                  radius: 5,
                                  color: bar.color!,
                                  strokeWidth: 2,
                                  strokeColor: Colors.white,
                                );
                              },
                            ),
                          );

                        }).toList();
                      },

                      touchCallback: (event, response) {

                        if (!event.isInterestedForInteractions ||
                            response == null ||
                            response.lineBarSpots == null) {

                          _removeTooltip();
                          return;
                        }

                        final spots = response.lineBarSpots!;
                        final index = spots.first.x.toInt();

                        _showTooltip(
                          event.localPosition!,
                          index,
                          spots,
                        );
                      },

                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (spots) {

                          return spots.map((_) {

                            return LineTooltipItem(
                              '',
                              const TextStyle(
                                color: Colors.transparent,
                              ),
                            );

                          }).toList();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

}
class _TooltipCard extends StatelessWidget {
  final String date;
  final List<LineBarSpot> spots;
  final List<ActivityLineData> lines;

  const _TooltipCard({
    required this.date,
    required this.spots,
    required this.lines,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(12),
          // boxShadow: const [
          //   BoxShadow(
          //     color: Color(0x1A000000),
          //     blurRadius: 12,
          //     offset: Offset(0, 4),
          //   ),
          // ],
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            CustomText(
              text:  date,
              isCopy: false,
              size: 13,
              isBold: true,
            ),

            8.height,
            ...spots.map((spot) {
              final line =
              lines[spot.barIndex];

              return Padding(
                padding:
                const EdgeInsets
                    .only(bottom: 4),
                child: Row(
                  mainAxisSize:
                  MainAxisSize.min,
                  children: [
                    CustomText(
                      text:  "${line.label}: ",
                      isCopy: false,
                      size: 12,
                      isBold: false,
                      colors:  line.color,
                    ),
                    CustomText(
                      text: spot.y.toInt().toString(),
                      isCopy: false,
                      size: 12,
                      isBold: true,
                      colors: line.color,
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}




// class CustomerActivityCard extends StatelessWidget {
//   final double width;
//   const CustomerActivityCard({super.key, required this.width});
//
//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     return Obx(()=>Container(
//       width: width,
//       height: 300,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: const [
//           BoxShadow(
//             blurRadius: 10,
//             color: Colors.black12,
//             offset: Offset(0, 4),
//           )
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           CustomText(
//             text: "Activity Overview" ,
//             size: 15,
//             isBold: true,isCopy: false,colors: Colors.black,
//           ),
//           10.height,
//           const Divider(
//             height: 1,
//             thickness: 1,
//             color: Color(0xffE5E7EB),
//           ),
//           5.height,
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               CustomText(
//                 text: "Customer Activity",
//                 size: 13,
//                 colors: Color(0xff666666),
//                 isCopy: false,
//               ),
//               Row(
//                 children: [
//                   CustomText(
//                     text: "Total : ",
//                     size: 13,
//                     colors: Color(0xff666666),
//                     isCopy: false,
//                   ),
//                   CustomText(
//                     text: controllers.leadCategoryList.isEmpty?"0":controllers.leadCategoryList.value.last.list2.length.toString(),
//                     size: 13,
//                     colors: Color(0xff666666),isCopy: false,isBold: true,
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           5.height,
//           dashController.customerStatusReport.isNotEmpty?
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               InkWell(
//                 onTap: dashController.customerStatusReport[0]["customer_call"].toString()!="0"?(){
//                   if(dashController.customerStatusReport[0]["customer_call"].toString()!="0"){
//                     remController.selectedCallSortBy.value = dashController.selectedSortBy.value;
//                     controllers.changeTab(0);
//                     Navigator.push(
//                       context,
//                       PageRouteBuilder(
//                         pageBuilder: (context,
//                             animation1,
//                             animation2) =>
//                         const Records(
//                           isReload: "true",
//                         ),
//                         transitionDuration:
//                         Duration.zero,
//                         reverseTransitionDuration:
//                         Duration.zero,
//                       ),
//                     );
//                     controllers.oldIndex.value = controllers.selectedIndex.value;
//                     controllers.selectedIndex.value = 101;
//                   }
//                 }:null,
//                 child: activityCircle(
//                   dashController.customerStatusReport[0]["customer_call"].toString(),
//                   double.parse(dashController.customerStatusReport[0]["customer_call"].toString()) / 100,
//                   "Calls",
//                   Color(0xFF0F8D4B),
//                 ),
//               ),
//               InkWell(
//                 onTap: dashController.customerStatusReport[0]["customer_mail"].toString()!="0"?(){
//                   if(dashController.customerStatusReport[0]["customer_mail"].toString()!="0"){
//                     remController.selectedMailSortBy.value = dashController.selectedSortBy.value;
//                     controllers.changeTab(1);
//                     Navigator.push(
//                       context,
//                       PageRouteBuilder(
//                         pageBuilder: (context,
//                             animation1,
//                             animation2) =>
//                         const Records(
//                           isReload: "true",
//                         ),
//                         transitionDuration:
//                         Duration.zero,
//                         reverseTransitionDuration:
//                         Duration.zero,
//                       ),
//                     );
//                     controllers.oldIndex.value =controllers.selectedIndex.value;
//                     controllers.selectedIndex.value = 101;
//                   }
//                 }:null,
//                 child: activityCircle(
//                   dashController.customerStatusReport[0]["customer_mail"].toString(),
//                   double.parse(dashController.customerStatusReport[0]["customer_mail"].toString()) / 100,
//                   "Mails",
//                   Color(0xFFEB3342),
//                 ),
//               ),
//               activityCircle(
//                 dashController.customerStatusReport[0]["customer_count"].toString(),
//                 double.parse(dashController.customerStatusReport[0]["customer_count"].toString()) / 100,
//                 "Updates",
//                 Color(0xFF1596E0),
//               ),
//
//             ],
//           ):0.height,
//           10.height,
//           const Divider(
//             height: 1,
//             thickness: 1,
//             color: Color(0xffE5E7EB),
//           ),
//           5.height,
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               CustomText(
//                 text: "Lead Activity",
//                 size: 13,
//                 colors: Color(0xff666666),
//                 isCopy: false,
//               ),
//               Row(
//                 children: [
//                   CustomText(
//                     text: "Total : ",
//                     size: 13,
//                     colors: Color(0xff666666),
//                     isCopy: false,
//                   ),
//                   CustomText(
//                     text: "${controllers.leadCategoryList.isEmpty?"0":controllers.leadCategoryList.fold(0, (sum, item) => sum + (item.list2.length ?? 0))-controllers.leadCategoryList.value.last.list2.length}",
//                     size: 13,
//                     colors: Color(0xff666666),isCopy: false,isBold: true,
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           5.height,
//           dashController.customerStatusReport.isNotEmpty?
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               InkWell(
//                 onTap: dashController.customerStatusReport[0]["lead_call"].toString()!="0"?(){
//                   if(dashController.customerStatusReport[0]["lead_call"].toString()!="0"){
//                     remController.selectedCallSortBy.value = dashController.selectedSortBy.value;
//                     controllers.changeTab(0);
//                     Navigator.push(
//                       context,
//                       PageRouteBuilder(
//                         pageBuilder: (context,
//                             animation1,
//                             animation2) =>
//                         const Records(
//                           isReload: "true",
//                         ),
//                         transitionDuration:
//                         Duration.zero,
//                         reverseTransitionDuration:
//                         Duration.zero,
//                       ),
//                     );
//                     controllers.oldIndex.value = controllers.selectedIndex.value;
//                     controllers.selectedIndex.value = 101;
//                   }
//                 }:null,
//                 child: activityCircle(
//                   dashController.customerStatusReport[0]["lead_call"].toString(),
//                   double.parse(dashController.customerStatusReport[0]["lead_call"].toString()) / 100,
//                   "Calls",
//                   Color(0xFF8B2CF5),
//                 ),
//               ),
//               InkWell(
//                 onTap: dashController.customerStatusReport[0]["lead_mail"].toString()!="0"?(){
//                   if(dashController.customerStatusReport[0]["lead_mail"].toString()!="0"){
//                     remController.selectedMailSortBy.value = dashController.selectedSortBy.value;
//                     controllers.changeTab(1);
//                     Navigator.push(
//                       context,
//                       PageRouteBuilder(
//                         pageBuilder: (context,
//                             animation1,
//                             animation2) =>
//                         const Records(
//                           isReload: "true",
//                         ),
//                         transitionDuration:
//                         Duration.zero,
//                         reverseTransitionDuration:
//                         Duration.zero,
//                       ),
//                     );
//                     controllers.oldIndex.value =controllers.selectedIndex.value;
//                     controllers.selectedIndex.value = 101;
//                   }
//                 }:null,
//                 child: activityCircle(
//                   dashController.customerStatusReport[0]["lead_mail"].toString(),
//                   double.parse(dashController.customerStatusReport[0]["lead_mail"].toString()) / 100,
//                   "Mails",
//                   Color(0xFFF59E0B),
//                 ),
//               ),
//               activityCircle(
//                 dashController.customerStatusReport[0]["lead_count"].toString(),
//                 double.parse(dashController.customerStatusReport[0]["lead_count"].toString()) / 100,
//                 "Updates",
//                 Color(0xFFD80B8F),
//               ),
//
//             ],
//           ):0.height,
//         ],
//       ),
//     ));
//   }
//
//   Widget activityCircle(String value, double percent, String title, Color color) {
//
//     if (percent < 0) percent = 0.0;
//     if (percent > 1) percent = 1.0;
//
//     return Column(
//       children: [
//         CircularPercentIndicator(
//           radius: 27,
//           lineWidth: 10,
//           percent: percent,
//           backgroundColor: color.withOpacity(0.2),
//           progressColor: color,
//           circularStrokeCap: CircularStrokeCap.round,
//           center: CustomText(
//             text: value,
//             size: 15,
//             isBold: true,
//             isCopy: false,
//           ),
//         ),
//         CustomText(
//           text: title,
//           size: 13,
//           isBold: true,
//           colors: color,
//           isCopy: false,
//         ),
//       ],
//     );
//   }
// }


class ActivityData {
  final String activity;
  final double customer;
  final double lead;
  final VoidCallback callback;

  ActivityData(this.activity, this.customer, this.lead, {required this.callback});
}

class CustomerActivityCard extends StatelessWidget {
  final double width;
  CustomerActivityCard({super.key, required this.width});
  final List<ActivityData> chartData = [
    ActivityData(
      "Calls",
      double.parse(dashController.customerStatusReport[0]["customer_call"].toString()),
      double.parse(dashController.customerStatusReport[0]["lead_call"].toString()),
      callback: dashController.customerStatusReport[0]["lead_call"].toString()!="0"?(){
        if(dashController.customerStatusReport[0]["lead_call"].toString()!="0"){
          remController.selectedCallSortBy.value = dashController.selectedSortBy.value;
          controllers.changeTab(0);
          Get.to(Records(
            isReload: "true",
          ));
          controllers.oldIndex.value = controllers.selectedIndex.value;
          controllers.selectedIndex.value = 101;
        }
      }:(){}
    ),
    ActivityData(
      "Mails",
      double.parse(dashController.customerStatusReport[0]["customer_mail"].toString()),
      double.parse(dashController.customerStatusReport[0]["lead_mail"].toString()),
      callback: dashController.customerStatusReport[0]["lead_mail"].toString()!="0"?(){
        if(dashController.customerStatusReport[0]["lead_mail"].toString()!="0"){
          remController.selectedMailSortBy.value = dashController.selectedSortBy.value;
          controllers.changeTab(1);
          Get.to(Records(
            isReload: "true",
          ));
          controllers.oldIndex.value =controllers.selectedIndex.value;
          controllers.selectedIndex.value = 101;
        }
      }:(){}
    ),
    ActivityData(
      "Updates",
      double.parse(dashController.customerStatusReport[0]["customer_count"].toString()),
      double.parse(dashController.customerStatusReport[0]["lead_count"].toString()),
      callback: (){}
    ),
  ];
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: width,
      height: 300,
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: "Activity Overview" ,
            size: 15,
            isBold: true,isCopy: false,colors: Colors.black,
          ),
          5.height,
          CustomText(
            text: "Overview of daily customer engagement activities.",
            colors: Colors.grey,
            isCopy: false,size: 13,
          ),
          12.height,
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xffE5E7EB),
          ),
          5.height,
          Expanded(
            child: SfCartesianChart(
              // onPointTap: (ChartPointDetails details) {
              //   switch (details.pointIndex) {
              //     case 0: // Calls
              //       remController.selectedCallSortBy.value = dashController.selectedSortBy.value;
              //       controllers.changeTab(0);
              //       Get.to(() => Records(isReload: "true"));
              //       break;
              //
              //     case 1: // Mails
              //       remController.selectedMailSortBy.value = dashController.selectedSortBy.value;
              //       controllers.changeTab(1);
              //       Get.to(() => Records(isReload: "true"));
              //       break;
              //
              //     case 2: // Updates
              //       controllers.changeTab(2);
              //       Get.to(() => Records(isReload: "true"));
              //       break;
              //   }
              // },
              legend: const Legend(
                isVisible: true,
                position: LegendPosition.bottom,
              ),
              primaryXAxis: const CategoryAxis(),
              primaryYAxis: const NumericAxis(),

              series: <CartesianSeries>[
                ColumnSeries<ActivityData, String>(
                  onPointTap: (ChartPointDetails details) {
                    chartData[details.pointIndex!].callback();
                  },
                  name: "Lead - ${controllers.leadCategoryList.isEmpty?"0":controllers.leadCategoryList.fold(0, (sum, item) => sum + (item.list2.length ?? 0))-controllers.leadCategoryList.value.last.list2.length}",
                  color: Colors.blue,
                  dataSource: chartData,
                  xValueMapper: (ActivityData data, _) => data.activity,
                  yValueMapper: (ActivityData data, _) => data.lead,
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                  ),
                ),

                ColumnSeries<ActivityData, String>(
                  onPointTap: (ChartPointDetails details) {
                    chartData[details.pointIndex!].callback();
                  },
                  name: "Customer -${controllers.leadCategoryList.isEmpty?"0":controllers.leadCategoryList.value.last.list2.length.toString()}",
                  color: Colors.green,
                  dataSource: chartData,
                  xValueMapper: (ActivityData data, _) => data.activity,
                  yValueMapper: (ActivityData data, _) => data.customer,
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}



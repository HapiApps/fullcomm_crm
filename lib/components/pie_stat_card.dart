import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'Customtext.dart';
//
// class PieStatCard extends StatefulWidget {
//   final String title;
//   final String subtitle;
//   final int total;
//   final List<PieStatValue> values;
//
//   const PieStatCard({
//     super.key,
//     required this.title,
//     required this.subtitle,
//     required this.total,
//     required this.values,
//   });
//
//   @override
//   State<PieStatCard> createState() => _PieStatCardState();
// }
//
// class _PieStatCardState extends State<PieStatCard> {
//   int touchedIndex = -1;
//   Offset? touchPosition;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 300,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: const [
//           BoxShadow(
//             color: Colors.black12,
//             blurRadius: 10,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           CustomText(
//               text:  widget.title,
//               isCopy: false,
//               size: 14,
//               isBold: true,
//               colors:Colors.black,
//           ),
//           const SizedBox(height: 2),
//           CustomText(
//               text: widget.subtitle,
//               isCopy: false,
//               size: 12,
//               isBold: false,
//               colors:Color(0xff666666)
//           ),
//           16.height,
//           const Divider(height: 1, thickness: 1, color: Color(0xffCDCDCD)),
//           16.height,
//           Expanded(
//             child: LayoutBuilder(
//               builder: (context, constraints) {
//                 return Stack(
//                   children: [
//                     PieChart(
//                       PieChartData(
//                         startDegreeOffset: -100,
//                         sectionsSpace: 3,
//                         centerSpaceRadius: 50,
//                         pieTouchData: PieTouchData(
//                           enabled: true,
//                           touchCallback: (event, response) {
//                             setState(() {
//                               if (!event.isInterestedForInteractions ||
//                                   response == null ||
//                                   response.touchedSection == null) {
//                                 touchedIndex = -1;
//                                 touchPosition = null;
//                               } else {
//                                 touchedIndex = response
//                                     .touchedSection!.touchedSectionIndex;
//                                 touchPosition =
//                                     event.localPosition;
//                               }
//                             });
//                           },
//                         ),
//
//                         sections: List.generate(
//                           widget.values.length,
//                               (index) {
//                             final value = widget.values[index];
//                             final isTouched = index == touchedIndex;
//                             return PieChartSectionData(
//                               value: value.value,
//                               color: value.color,
//                               radius: isTouched ? 30 : 20,  ///Changes
//                               showTitle: false,
//                             );
//                           },
//                         ),
//                       ),
//                     ),
//                     /// FLOATING TOOLTIP
//                     if (touchedIndex != -1 && touchPosition != null)
//                       Positioned(
//                         left: touchPosition!.dx,
//                         // top: touchPosition!.dy - 5,
//                         child: _buildTooltip(
//                           widget.values[touchedIndex],
//                         ),
//                       ),
//                     /// CENTER TEXT
//                     Align(
//                       alignment: Alignment.center,
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           CustomText(
//                               text:   widget.total.toString(),
//                               isCopy: false,
//                               size: 18,
//                               isBold: true,
//                             colors: Colors.black,
//                           ),
//                           // 4.height,
//                           const CustomText(
//                             text:  "Total Leads",
//                             isCopy: false,
//                             size: 12,
//                             isBold: false,
//                             colors:Color(0xff666666)
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ),
//           12.height,
//           for (var item in widget.values)
//           _LegendDot(item.label,
//               item.color),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTooltip(PieStatValue value) {
//     return Material(
//       color: Colors.transparent,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(color: value.color, width: 1.5),
//         ),
//         child:CustomText(
//           text:  "${value.label}: ${value.value.toInt()}",
//           isCopy: false,
//           size: 12,
//           isBold: true,
//           colors:value.color,
//         ),
//       ),
//     );
//   }
// }
//
//
// /// MODEL
// class PieStatValue {
//   final String label;
//   final double value;
//   final Color color;
//
//   const PieStatValue({
//     required this.label,
//     required this.value,
//     required this.color,
//   });
// }
//
// /// LEGEND DOT
// class _LegendDot extends StatelessWidget {
//   final String text;
//   final Color color;
//
//   const _LegendDot(this.text, this.color);
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Container(
//           width: 8,
//           height: 8,
//           decoration: BoxDecoration(
//             color: color,
//             shape: BoxShape.circle,
//           ),
//         ),
//        6.width,
//         CustomText(
//           text: text,
//           isCopy: false,
//           size: 14,
//           isBold: false,
//           colors: color,
//         ),
//       ],
//     );
//   }
// }

class PieData {
  final String label;
  final double value;
  final Color color;

  PieData({
    required this.label,
    required this.value,
    required this.color,
  });
}

class LeadPieCard extends StatefulWidget {
  final List<PieData> data;

  const LeadPieCard({super.key, required this.data});

  @override
  State<LeadPieCard> createState() => _LeadPieCardState();
}

class _LeadPieCardState extends State<LeadPieCard> {
  int touchedIndex = -1;
  Offset? touchPosition;

  double get total =>
      widget.data.fold(0, (sum, item) => sum + item.value);

  @override
  Widget build(BuildContext context) {
    return Container(
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
            text: "Lead Distribution",
            size: 14,
            isBold: true,
            isCopy: false,
          ),
          5.height,
          CustomText(
            text: "Breakdown by current stage",
            colors: Colors.grey,
            isCopy: false,size: 12,
          ),
          const Divider(),

          /// PIE CHART
          SizedBox(
            height: 150,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 45,
                        pieTouchData: PieTouchData(
                          touchCallback: (event, response) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  response == null ||
                                  response.touchedSection == null) {
                                touchedIndex = -1;
                                touchPosition = null;
                              } else {
                                touchedIndex = response
                                    .touchedSection!.touchedSectionIndex;
                                touchPosition = event.localPosition;
                              }
                            });
                          },
                        ),
                        sections:
                        List.generate(widget.data.length, (i) {
                          final isTouched = i == touchedIndex;

                          return PieChartSectionData(
                            color: widget.data[i].color,
                            value: widget.data[i].value,
                            radius: isTouched ? 45 : 30,
                            showTitle: false,
                          );
                        }),
                      ),
                    ),

                    /// CENTER TEXT
                    // if (touchedIndex == -1)
                      Align(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomText(
                              text: total.toInt().toString(),
                              size: 20,
                              isBold: true,
                              isCopy: false,
                            ),
                            CustomText(
                              text: "Total Leads",
                              colors: Colors.grey,
                              isCopy: false,
                            ),
                          ],
                        ),
                      ),

                    /// FLOATING TOOLTIP
                    if (touchedIndex != -1 &&
                        touchPosition != null)
                      Positioned(
                        left: touchPosition!.dx,
                        top: touchPosition!.dy - 50,
                        child: _buildTooltip(
                          widget.data[touchedIndex],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),

          20.height,

          /// LEGEND GRID (2 per row)
          SizedBox(
            // height: 90,
            child: GridView.builder(
              shrinkWrap: true,
              // physics:
              // const NeverScrollableScrollPhysics(),
              itemCount: widget.data.length,
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 5,
                childAspectRatio: 10,
              ),
              itemBuilder: (context, index) {
                final item = widget.data[index];

                return Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 5,
                          backgroundColor: item.color,
                        ),
                        6.width,
                        CustomText(
                          text: item.label,
                          isCopy: false,
                        ),
                      ],
                    ),
                    CustomText(
                      text: item.value.toInt().toString(),
                      isBold: true,
                      isCopy: false,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// TOOLTIP WIDGET
  Widget _buildTooltip(PieData value) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border:
          Border.all(color: value.color, width: 1.5),
          boxShadow: const [
            BoxShadow(
              blurRadius: 6,
              color: Colors.black12,
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomText(
              text: value.label,
              isBold: true,
              isCopy: false,
              colors: value.color,
            ),
            CustomText(
              text: value.value.toInt().toString(),
              isBold: true,
              isCopy: false,
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import '../controller/controller.dart';
import '../controller/dashboard_controller.dart';
import 'Customtext.dart';
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
            size: 15,
            isBold: true,
            isCopy: false,
          ),
          5.height,
          CustomText(
            text: "Breakdown by current stage",
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

          /// PIE CHART
          // if(total.toInt().toString()!="0")
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                height: 150,
                width: 100,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        PieChart(
                          PieChartData(
                            sectionsSpace: 3,
                            centerSpaceRadius: 45,
                            pieTouchData: PieTouchData(
                              enabled: true,
                              touchCallback: (event, response) {

                                if (!event.isInterestedForInteractions ||
                                    response == null ||
                                    response.touchedSection == null) {

                                  if (touchedIndex != -1) {
                                    setState(() {
                                      touchedIndex = -1;
                                    });
                                  }
                                  return;
                                }

                                final index = response.touchedSection!.touchedSectionIndex;

                                if (touchedIndex != index) {
                                  setState(() {
                                    touchedIndex = index;
                                  });
                                }
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
                          if (touchedIndex != -1)
                            Positioned(
                              top: 10,
                              right: 10,
                              child: _buildTooltip(widget.data[touchedIndex]),
                            ),
                      ],
                    );
                  },
                ),
              ),
              SizedBox(
                width: 100,
                // height: 150,
                child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: dashController.leadReport.length,
                    itemBuilder: (context,index){
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(0, 7, 0, 0),
                        child: Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CircleAvatar(
                              radius: 5,
                              backgroundColor: controllers.leadColors[index],
                            ),
                            6.width,
                            CustomText(
                              text: dashController.leadReport[index]["category"] ?? "",
                              isCopy: false,colors: controllers.leadColors[index],
                            ),
                            // 5.width,
                            // CustomText(
                            //   text: value.toString(),
                            //   isCopy: false,
                            // ),
                          ],
                        ),
                      );
                    }),
              )
            ],
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
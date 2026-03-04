import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
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
  final List<String> xLabels;
  final List<ActivityLineData> lines;
  final double maxY;

  const ActivityOverTimeChart({
    super.key,
    required this.xLabels,
    required this.lines,
    this.maxY = 100,
  });

  @override
  State<ActivityOverTimeChart> createState() =>
      _ActivityOverTimeChartState();
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
        left: global.dx + 10,
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
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      // height: 360, width: screenWidth/1.8,
      height: 400, width: screenWidth/1.85,
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

            Expanded(
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: widget.maxY,
                  borderData: FlBorderData(show: false),

                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: widget.maxY / 4,
                    getDrawingHorizontalLine: (value) => const FlLine(
                      color: Color(0xffE2E8F0),
                      strokeWidth: 1,
                      dashArray: [4, 4],
                    ),
                  ),

                  titlesData: FlTitlesData(
                    topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),

                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: widget.maxY / 4,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) => Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i >= widget.xLabels.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              widget.xLabels[i],
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  lineBarsData: widget.lines.map((line) {
                    return LineChartBarData(
                      spots: List.generate(
                        line.values.length,
                            (i) => FlSpot(
                          i.toDouble(),
                          line.values[i],
                        ),
                      ),
                      isCurved: true,
                      color: line.color,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                    );
                  }).toList(),

                  lineTouchData: LineTouchData(
                    enabled: true,
                    handleBuiltInTouches: false,
                    getTouchedSpotIndicator: (barData, spotIndexes) {
                      return spotIndexes.map((index) {
                        return TouchedSpotIndicatorData(
                          const FlLine(
                            color: Color(0xffE5E7EB),
                            strokeWidth: 1,
                            dashArray: [4, 4],
                          ),
                          FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, bar, i) =>
                                FlDotCirclePainter(
                                  radius: 5,
                                  color: bar.color!,
                                  strokeWidth: 2,
                                  strokeColor: Colors.white,
                                ),
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

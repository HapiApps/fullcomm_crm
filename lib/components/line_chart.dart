import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/constant/colors_constant.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controller/dashboard_controller.dart';

class DayWiseBarChart extends StatelessWidget {
  const DayWiseBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final sortBy = dashController.selectedSortBy.value;
      if (dashController.dayReport.isEmpty) {
        return Center(
          child: CircularProgressIndicator(color: colorsConst.primary),
        );
      }
      final report = [...dashController.dayReport];
      report.sort((a, b) => a.dayDate.compareTo(b.dayDate));
      final int showInterval = report.length > 20 ? 7 : 1;
      String targetDateString = '';
      final now = DateTime.now().toLocal();
      if (sortBy == 'Today') {
        targetDateString = DateFormat('yyyy-MM-dd').format(now);
      } else if (sortBy == 'Yesterday') {
        final yesterday = now.subtract(const Duration(days: 1));
        targetDateString = DateFormat('yyyy-MM-dd').format(yesterday);
      }
      final highlightColor = Colors.pinkAccent.shade400; // The requested pink color
      final defaultColor = Colors.green;
      return BarChart(
        BarChartData(
          maxY: (report.map((e) => e.totalCustomers).reduce((a, b) => a > b ? a : b) + 2).toDouble(),
          backgroundColor: Colors.white,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            drawHorizontalLine: true,
            getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1),
            getDrawingVerticalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: showInterval.toDouble(), // Dynamic interval
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < 0 || value.toInt() >= report.length) {
                    return const SizedBox.shrink();
                  }
                  if (showInterval == 7 && value.toInt() % 7 != 0) {
                    return const SizedBox.shrink();
                  }
                  final dateStr = report[value.toInt()].dayDate;
                  final formattedDate = DateFormat("dd MMM").format(DateTime.parse(dateStr));
                  return Text(
                      formattedDate,
                      style: const TextStyle(fontSize: 10)
                  );
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: true),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final date = report[group.x.toInt()].dayDate;
                final formatted = DateFormat("dd MMM yyyy").format(DateTime.parse(date));
                return BarTooltipItem(
                  "$formatted\n${rod.toY.toInt()} customers",
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
          barGroups: List.generate(report.length, (i) {
            final yValue = report[i].totalCustomers.toDouble();
            final barDate = report[i].dayDate.split('T').first;
            final barColor = (barDate == targetDateString && targetDateString.isNotEmpty)
                ? highlightColor
                : defaultColor;
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: yValue == 0 ? 0.1 : yValue,
                  color: barColor, // Use the dynamic color
                  width: 10,
                  borderRadius: BorderRadius.zero,
                ),
              ],
            );
          }),
        ),
      );
    });
  }
}
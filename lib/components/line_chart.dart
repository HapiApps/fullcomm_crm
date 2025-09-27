import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fullcomm_crm/controller/controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DayWiseLineChart extends StatefulWidget {
  const DayWiseLineChart({super.key});

  @override
  State<DayWiseLineChart> createState() => _DayWiseLineChartState();
}

class _DayWiseLineChartState extends State<DayWiseLineChart> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controllers.dayReport.isEmpty) {
        return const Center(child: Text("No data available"));
      }

      final month = DateTime.now().month;
      final year = DateTime.now().year;

      // Sort reports by dayNum
      final sortedReport = [...controllers.dayReport]
        ..sort((a, b) => a.dayNum.compareTo(b.dayNum));

      // Filter based on selected range
      final filteredReport = sortedReport.where((e) {
        final date = DateTime(year, month, e.dayNum);
        return date.isAfter(controllers.rangeStart.value.subtract(const Duration(days: 1))) &&
            date.isBefore(controllers.rangeEnd.value.add(const Duration(days: 1)));
      }).toList();

      // Labels for x-axis
      final dayLabels = {
        for (var e in filteredReport)
          e.dayNum: DateFormat.MMMd().format(DateTime(year, month, e.dayNum))
      };

      return LineChart(
        LineChartData(
          minY: 0,
          maxY: 100,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            drawHorizontalLine: true,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.shade200,
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Colors.grey.shade200,
                strokeWidth:1,
              );
            },
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 20,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      value.toInt().toString(),
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  final label = dayLabels[value.toInt()] ?? '';
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(label, style: const TextStyle(fontSize: 10)),
                  );
                },
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              color: Colors.pink,
              barWidth: 2,
              dotData: FlDotData(show: false),
              spots: filteredReport.map((e) => FlSpot(
                e.dayNum.toDouble(),
                e.totalCustomers.toDouble(),
              )).toList(),
            ),
          ],
        ),
      );
    });

  }
}


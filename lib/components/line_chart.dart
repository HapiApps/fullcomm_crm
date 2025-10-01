import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/constant/colors_constant.dart';
import 'package:fullcomm_crm/controller/controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DayWiseBarChart extends StatefulWidget {
  const DayWiseBarChart({super.key});

  @override
  State<DayWiseBarChart> createState() => _DayWiseBarChartState();
}

class _DayWiseBarChartState extends State<DayWiseBarChart> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controllers.dayReport.isEmpty) {
        return Center(child: CircularProgressIndicator(
          color: colorsConst.primary,
        ));
      }
      final sortedReport = [...controllers.dayReport]
        ..sort((a, b) => a.dayNum.compareTo(b.dayNum));
      final fullMonthReport = sortedReport;
      return BarChart(
        BarChartData(
          maxY: 10,
          backgroundColor: Colors.white,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            drawHorizontalLine: true,
            getDrawingHorizontalLine: (value) {
            return FlLine( color: Colors.grey.shade200, strokeWidth: 1);
            },
            getDrawingVerticalLine: (value) {
            return FlLine( color: Colors.grey.shade200, strokeWidth:1);
            },
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: 2,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    int dayNum = value.toInt();
                    int today = DateTime.now().day;
                    int currentMonth = DateTime.now().month;
                    int currentYear = DateTime.now().year;

                    int selectedMonth = controllers.selectedChartMonth.value.toString().isEmpty
                        ? currentMonth
                        : controllers.selectedChartMonth.value;
                    int selectedYear = currentYear;
                    if (selectedMonth == currentMonth && selectedYear == currentYear) {
                      if (dayNum > today) {
                        return const SizedBox.shrink();
                      }
                    } else {
                      int lastDay = DateTime(selectedYear, selectedMonth + 1, 0).day;
                      if (dayNum > lastDay) {
                        return const SizedBox.shrink();
                      }
                    }
                    if ((dayNum - 1) % 6 == 0) {
                      final date = DateTime(selectedYear, selectedMonth, dayNum);
                      return Text(
                        DateFormat("d MMM").format(date),
                        style: const TextStyle(fontSize: 10),
                      );
                    }
                    return const SizedBox.shrink();
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
                return BarTooltipItem(
                  rod.toY.toString(),
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          barGroups: fullMonthReport.map((e) {
            final yValue = e.totalCustomers.toDouble();
            return BarChartGroupData(
              x: e.dayNum,
              barRods: [
                BarChartRodData(
                  toY: yValue == 0 ? 0.1 : yValue,
                  color: colorsConst.primary,
                  width: 10,
                  borderRadius: BorderRadius.zero,
                ),
              ],
            );
          }).toList(),
        ),
      );
    });
  }
}

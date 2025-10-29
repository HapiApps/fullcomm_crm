import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/components/line_chart.dart';
import 'package:fullcomm_crm/controller/dashboard_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common/constant/colors_constant.dart';
import '../components/custom_rating.dart';
import '../components/custom_text.dart';
import '../controller/controller.dart';

class MobileDashboard extends StatefulWidget {
  const MobileDashboard({super.key});

  @override
  State<MobileDashboard> createState() => _MobileDashboardState();
}

class _MobileDashboardState extends State<MobileDashboard> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      controllers.selectedIndex.value = 0;
      final prefs = await SharedPreferences.getInstance();
      controllers.isAdmin.value = prefs.getBool("isAdmin") ?? false;
      var today =
          "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";
      var last7days = DateTime.now().subtract(const Duration(days: 7));
      dashController.getCustomerReport(
          "${last7days.year}-${last7days.month.toString().padLeft(2, '0')}-${last7days.day.toString().padLeft(2, '0')}",
          today);
    });
    dashController.getRatingReport();
    dashController.getDashboardReport();
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 800;
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        title: CustomText(
          text: "Dashboard",
          size: 26,
          isBold: true,
          colors: Colors.black,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                CustomText(
                  text: controllers.version,
                  colors: colorsConst.third,
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SelectionArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  30.height,
                  Column(
                    children: [
                      Obx(() {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ...["Today", "Yesterday", "Last 7 Days"].map((filter) {
                              final bool isSelected = dashController.selectedSortBy.value == filter;
                              return GestureDetector(
                                onTap: () {
                                  dashController.selectedSortBy.value = filter;
                                  DateTime now = DateTime.now();
                                  switch (filter) {
                                    case "Today":
                                      DateTime now = DateTime.now();
                                      dashController.selectedSortBy.value = "Today";
                                      dashController.selectedRange.value = DateTimeRange(
                                        start: now.subtract(const Duration(days: 7)), // last 8 days
                                        end: now,
                                      );
                                      break;
                                    case "Yesterday":
                                      dashController.selectedSortBy.value = "Yesterday";
                                      DateTime today = DateTime.now();
                                      DateTime yesterday = today.subtract(const Duration(days: 1));
                                      DateTime startDate = today.subtract(const Duration(days: 7));
                                      DateTime endDate = today;
                                      dashController.selectedRange.value = DateTimeRange(
                                        start: startDate,
                                        end: endDate,
                                      );
                                      // 🔹 Fetch data for the range
                                      dashController.getDashboardReport();
                                      dashController.getCustomerReport(
                                        DateFormat('yyyy-MM-dd').format(startDate),
                                        DateFormat('yyyy-MM-dd').format(endDate),
                                      );
                                      break;
                                    case "Last 7 Days":
                                      DateTime now = DateTime.now();
                                      dashController.selectedSortBy.value = "Last 7 Days";

                                      dashController.selectedRange.value = DateTimeRange(
                                        start: now.subtract(const Duration(days: 6)),
                                        end: now,
                                      );
                                      break;
                                  }

                                  final range = dashController.selectedRange.value;
                                  if (range != null) {
                                    dashController.getDashboardReport();
                                    dashController.getCustomerReport(
                                      "${range.start.year}-${range.start.month.toString().padLeft(2, '0')}-${range.start.day.toString().padLeft(2, '0')}",
                                      "${range.end.year}-${range.end.month.toString().padLeft(2, '0')}-${range.end.day.toString().padLeft(2, '0')}",
                                    );
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8, bottom: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.blueAccent : Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: isSelected ? Colors.blueAccent : Colors.grey.shade400,
                                    ),
                                  ),
                                  child: Text(
                                    filter,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.black87,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: "Lato",
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        );
                      }),
                      10.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Last 30 Days Button
                          Obx(() {
                            final bool isSelected = dashController.selectedSortBy.value == "Last 30 Days";
                            return GestureDetector(
                              onTap: () {
                                dashController.selectedSortBy.value = "Last 30 Days";
                                DateTime now = DateTime.now();

                                dashController.selectedRange.value = DateTimeRange(
                                  start: now.subtract(const Duration(days: 30)),
                                  end: now,
                                );

                                final range = dashController.selectedRange.value;
                                if (range != null) {
                                  dashController.getDashboardReport();
                                  dashController.getCustomerReport(
                                    "${range.start.year}-${range.start.month.toString().padLeft(2, '0')}-${range.start.day.toString().padLeft(2, '0')}",
                                    "${range.end.year}-${range.end.month.toString().padLeft(2, '0')}-${range.end.day.toString().padLeft(2, '0')}",
                                  );
                                }
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 8, bottom: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.blueAccent : Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: isSelected ? Colors.blueAccent : Colors.grey.shade400,
                                  ),
                                ),
                                child:  Text(
                                  "Last 30 Days",
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: "Lato",
                                  ),
                                ),
                              ),
                            );
                          }),
                          10.width,
                          // Date Range Picker
                          InkWell(
                            onTap: () {
                              dashController.showDatePickerDialog(context);
                              final range = dashController.selectedRange.value;
                              if (range != null) {
                                dashController.getDashboardReport();
                                dashController.getCustomerReport(
                                  "${range.start.year}-${range.start.month.toString().padLeft(2, '0')}-${range.start.day.toString().padLeft(2, '0')}",
                                  "${range.end.year}-${range.end.month.toString().padLeft(2, '0')}-${range.end.day.toString().padLeft(2, '0')}",
                                );
                              }
                            },
                            child: Container(
                              width: 200,
                              height: 45,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: Colors.grey.shade400),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Obx(() {
                                    final range = dashController.selectedRange.value;
                                    if (range == null) {
                                      return const Text(
                                        "Select Date Range",
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontFamily: "Lato",
                                        ),
                                      );
                                    }
                                    return Text(
                                      "${range.start.day}-${range.start.month}-${range.start.year} → ${range.end.day}-${range.end.month}-${range.end.year}",
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontFamily: "Lato",
                                      ),
                                    );
                                  }),
                                  const SizedBox(width: 5),
                                  const Icon(Icons.calendar_today, color: Colors.grey, size: 16),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  20.height,
                  if (isMobile)
                    Column(
                      children: [
                        _newCustomerChart(),
                        10.height,
                        _pieChartSection(),
                        10.height,
                        _ratingCard(),
                        10.height,
                        _countCards(),
                        10.height,
                        _quotationCard(),
                      ],
                    )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _ratingCard() {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomText(text: "Rating", size: 19, isBold: true),
          20.height,
          Obx(() {
            final hot = int.tryParse(dashController.totalHot.value) ?? 0;
            final warm = int.tryParse(dashController.totalWarm.value) ?? 0;
            final cold = int.tryParse(dashController.totalCold.value) ?? 0;
            final total = hot + warm + cold;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                RatingIndicator(
                  color: Colors.red,
                  label: 'Total Hot',
                  value: hot,
                  percentage: total == 0 ? 0 : hot / total,
                  labelStyle: const TextStyle(
                    fontSize: 17,
                    // fontWeight: FontWeight.w600,
                    fontFamily: "Lato",
                  ),
                ),
                RatingIndicator(
                  color: Colors.orange,
                  label: 'Total Warm',
                  value: warm,
                  percentage: total == 0 ? 0 : warm / total,
                  labelStyle: const TextStyle(
                    fontSize: 17,
                    // fontWeight: FontWeight.w600,
                    fontFamily: "Lato",
                  ),
                ),
                RatingIndicator(
                  color: Colors.blue,
                  label: 'Total Cold',
                  value: cold,
                  percentage: total == 0 ? 0 : cold / total,
                  labelStyle: const TextStyle(
                    fontSize: 17,
                    // fontWeight: FontWeight.w600,
                    fontFamily: "Lato",
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
  Widget _quotationCard() {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Row(
            children: [
              CustomText(
                text: "Quotations Sent",
                size: 16,
                isBold: true,
                colors: colorsConst.textColor,
              ),
            ],
          ),
         40.height,
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: colorsConst.primary, width: 2.4),
                  ),
                  child: CustomText(
                    text: "0",
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
                ),
              ],
            ),
          ),
        ],
      ),
    );

  }


  Widget _newCustomerChart() {
    return Container(
      height: 430,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "New Customers",
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontFamily: "Lato",
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Obx(() {
                    if (dashController.dayReport.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    final report = [...dashController.dayReport];
                    final maxY = (report.map((e) => e.totalCustomers)
                        .reduce((a, b) => a > b ? a : b) + 2).toDouble();
                    final roundedMaxY = ((maxY / 5).ceil() * 5);
                    const step = 5;
                    final yLabels = List.generate(
                      (roundedMaxY ~/ step) + 1,
                          (i) => i * step,
                    );

                    return Container(
                      width: 30,
                      alignment: Alignment.bottomRight,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: yLabels.reversed.map((y) {
                          return Text(
                            y.toString(),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.black54,
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }),


                  const SizedBox(width: 6),
                  Expanded(
                    child: Transform.translate(
                      offset:  Offset(0, 20),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: 800,
                          height: 380,
                          child: const DayWiseBarChart(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pieChartSection() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Obx(() {
        final double totalSuspects =
            double.tryParse(dashController.totalSuspects.value) ?? 0;
        final double totalProspects =
            double.tryParse(dashController.totalProspects.value) ?? 0;
        final double totalQualified =
            double.tryParse(dashController.totalQualified.value) ?? 0;
        final double totalUnQualified =
            double.tryParse(dashController.totalUnQualified.value) ?? 0;
        final double totalCustomers =
            double.tryParse(dashController.totalCustomers.value) ?? 0;

        final totalSum = totalSuspects +
            totalProspects +
            totalQualified +
            totalUnQualified +
            totalCustomers;

        final isEmpty = totalSum == 0;

        final Map<String, double> dataMap = isEmpty
            ? {'No Data': 1}
            : {
          'Suspects': totalSuspects,
          'Prospects': totalProspects,
          'Qualified': totalQualified,
          'Disqualified': totalUnQualified,
          'Customers': totalCustomers,
        };

        final List<Color> colors = const [
          Color(0xffE3B552),
          Color(0xff017EFF),
          Color(0xffF55353),
          Color(0xff7456FC),
          Color(0xffE3528C),
        ];

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: 180,
              height: 200,
              child: PieChart(
                dataMap: dataMap,
                animationDuration: const Duration(seconds: 1),
                colorList: colors,
                chartType: ChartType.disc,
                baseChartColor: Colors.transparent,
                chartRadius: 180,
                legendOptions: const LegendOptions(showLegends: false),
                chartValuesOptions: const ChartValuesOptions(
                  showChartValues: true,
                  showChartValueBackground: false,
                  chartValueStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _legendItem("Suspects", totalSuspects, colors[0]),
                    SizedBox(height:10 ,),
                    _legendItem("Prospects", totalProspects, colors[1]),
                    SizedBox(height:10 ,),
                    _legendItem("Qualified", totalQualified, colors[2]),
                    SizedBox(height:10 ,),
                    _legendItem("Disqualified", totalUnQualified, colors[3]),
                    SizedBox(height:10 ,),
                    _legendItem("Customers", totalCustomers, colors[4]),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  /// 🔹 Custom legend item row
  Widget _legendItem(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: "Lato",
                color: Colors.black87,
              ),
            ),
          ),
          // Text(
          //   value.toInt().toString(),
          //   style: const TextStyle(
          //     fontSize: 16,
          //     fontFamily: "Lato",
          //     fontWeight: FontWeight.bold,
          //     color: Colors.black87,
          //   ),
          // ),
        ],
      ),
    );
  }


  Widget _countCards() {
    return Column(
      children: [
        // 🔹 Row 1 → Total Mails & Total Calls
        Row(
          children: [
            // 📨 Total Mails
            Expanded(
              child: Container(
                height: 160,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.email_outlined,
                            color: colorsConst.primary, size: 36),
                        const SizedBox(width: 8),
                        Obx(() => CustomText(
                          text: dashController.totalMails.value,
                          size: 24,
                          isBold: true,
                        )),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const CustomText(
                        text: "Total Mails",
                        size: 17,
                        colors: Colors.black87),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 10),

            // 📞 Total Calls
            Expanded(
              child: Container(
                height: 160,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.call_outlined,
                            color: colorsConst.primary, size: 36),
                        const SizedBox(width: 8),
                        Obx(() => CustomText(
                          text: dashController.totalCalls.value,
                          size: 24,
                          isBold: true,
                        )),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const CustomText(
                        text: "Total Calls",
                        size: 17,
                        colors: Colors.black87),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // 🔹 Row 2 → Total Appointments & Total Employees
        Row(
          children: [
            // 📅 Total Appointments
            Expanded(
              child: Container(
                height: 160,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_month_outlined,
                            color: colorsConst.primary, size: 36),
                        const SizedBox(width: 8),
                        Obx(() => CustomText(
                          text: dashController.totalMeetings.value,
                          size: 24,
                          isBold: true,
                        )),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const CustomText(
                        text: "Total Appointments",
                        size: 17,
                        colors: Colors.black87),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            border: Border.all(color: Colors.green),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Obx(() => CustomText(
                            text: dashController.completedMeetings.value,
                            colors: Colors.green,
                            size: 14,
                            isBold: true,
                          )),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            border: Border.all(color: Colors.red),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Obx(() => CustomText(
                            text: dashController.pendingMeetings.value,
                            colors: Colors.red,
                            size: 14,
                            isBold: true,
                          )),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 10),

            // 👥 Total Employees
            Expanded(
              child: Container(
                height: 160,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: 18,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline,
                            color: colorsConst.primary, size: 36),
                        const SizedBox(width: 8),
                        Obx(() => CustomText(
                          text: dashController.totalEmployees.value,
                          size: 24,
                          isBold: true,
                        )),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const CustomText(
                        text: "Total Employees",
                        size: 17,
                        colors: Colors.black87),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:fullcomm_crm/screens/leads/suspects.dart';
import 'package:intl/intl.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/components/line_chart.dart';
import 'package:fullcomm_crm/controller/dashboard_controller.dart';
import 'package:fullcomm_crm/screens/leads/rating_leads.dart';
import 'package:fullcomm_crm/screens/records/records.dart';
import 'package:fullcomm_crm/screens/reminder/reminder_page.dart';
import 'package:get/get.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common/constant/api.dart';
import '../common/constant/app_colors.dart';
import '../common/constant/colors_constant.dart';
import '../common/constant/dashboard_assets.dart';
import '../common/utilities/utils.dart';
import '../components/activity_over_time_chart.dart';
import '../components/activityratingbar.dart';
import '../components/custom_rating.dart';
import '../components/custom_sidebar.dart';
import '../components/custom_text.dart';
import '../components/customer_status_card.dart';
import '../components/pie_stat_card.dart';
import '../components/wave_stat_card.dart';
import '../controller/controller.dart';
import '../controller/reminder_controller.dart';
import '../provider/dashboard_provider.dart';
import '../provider/employee_provider.dart';
import '../services/api_services.dart';
import 'dart:html' as html;
import 'employee/employee_screen.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  final ScrollController _controller = ScrollController();
  final ScrollController _leftController = ScrollController();
  final ScrollController _rightController = ScrollController();

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    dashController.getToken();
    apiService.getLeadCategories();
    apiService.getCustomLeads();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      final employeeData = Provider.of<EmployeeProvider>(context, listen: false);
      employeeData.staffRoleDetailsData(context: context);
      controllers.getCallStatus();
      controllers.getRangeStatus();
      controllers.getIndustries();
    });

    Future.delayed(Duration.zero, () async {
      apiService.currentVersion();
      controllers.selectedIndex.value = 100;
      final prefs = await SharedPreferences.getInstance();
      controllers.isAdmin.value = prefs.getBool("isAdmin") ?? false;
      DateTime now = DateTime.now();
      dashController.selectedSortBy.value = "Today";
      remController.selectedMeetSortBy.value=dashController.selectedSortBy.value;
      // controllers.selectedProspectSortBy.value = "Today";
      // controllers.selectedQualifiedSortBy.value = "Today";
      // controllers.selectedCustomerSortBy.value = "Today";
      // remController.selectedMeetSortBy.value = "Today";
      // remController.selectedCallSortBy.value = "Today";
      // remController.selectedReminderSortBy.value = "Today";
      remController.filterAndSortMeetings(
        searchText: controllers.searchText.value.toLowerCase(),
        callType: controllers.selectMeetingType.value,
        sortField: controllers.sortFieldMeetingActivity.value,
        sortOrder: controllers.sortOrderMeetingActivity.value,
      );
      dashController.selectedRange.value = DateTimeRange(
        start: DateTime(now.year, now.month, now.day),
        end: DateTime(now.year, now.month, now.day),
      );
      String today =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      var last7days = DateTime.now().subtract(Duration(days: 7));
      dashController.getCustomerReport(
          "${last7days.year}-${last7days.month.toString().padLeft(2, '0')}-${last7days.day.toString().padLeft(2, '0')}",
          today);
      dashController.getDashboardReport();
      dashController.getLeadReport();
      dashController.getStatusWiseReport();
      dashController.getRatingReport();
    });

    _leadItemController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _leadItemAnimations = [
      // Suspect
      CurvedAnimation(
        parent: _leadItemController,
        curve: const Interval(0.0, 0.20, curve: Curves.easeOut),
      ),

      // Prospect
      CurvedAnimation(
        parent: _leadItemController,
        curve: const Interval(0.35, 0.55, curve: Curves.easeOut),
      ),

      // Qualified
      CurvedAnimation(
        parent: _leadItemController,
        curve: const Interval(0.70, 0.90, curve: Curves.easeOut),
      ),

      // Customer
      CurvedAnimation(
        parent: _leadItemController,
        curve: const Interval(1.00, 1.0, curve: Curves.easeOut),
      ),
    ];
  }

  void showWebNotification() {
    // Ask permission
    html.Notification.requestPermission().then((permission) {
      if (permission == "granted") {
        try {
          html.Notification(
            "Hello from Flutter Web 🚀",
            body: "This is a local notification example.",
            icon: "icons/Icon-192.png", // optional, must be in web/icons/
          );
        } catch (e) {
          print("Error showing notification: $e");
        }
      } else {
        print("Permission not granted for notifications");
      }
    });
  }
  DateTime? selectedDate;
  final statValues = [1596, 256, 65, 264, 6];
  late final maxValue = statValues.reduce((a, b) => a > b ? a : b);
  String selectedFilter = "Today";
  bool isJourneyToday = true;

  bool isLeadPanelOpen = false;

  final List<String> filters = [
    "Today",
    "Yesterday",
    "Last 7 days",
    "Last 30 days",
  ];

  late AnimationController _leadItemController;
  late List<Animation<double>> _leadItemAnimations;
  int? hoveredIndex;
  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.year}";
  }

  @override
  void dispose() {
    _leadItemController.dispose();
    super.dispose();
  }

  Widget _animatedLeadItem({required int index, required Widget child}) {
    final anim = _leadItemAnimations[index];

    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -1.2),
          end: Offset.zero,
        ).animate(anim),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;
    final isTablet = width >= 768 && width < 1100;
    final isDesktop = width >= 1100;
    final dashboard = context.watch<DashboardProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      // appBar: PreferredSize(
      //   preferredSize: Size.fromHeight(screenWidth < 900 ? 120 : 100),
      //   child: Container(
      //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      //     decoration: _topBarDecoration(),
      //     child: SafeArea(
      //       bottom: false,
      //       child: Row(
      //         crossAxisAlignment: CrossAxisAlignment.center,
      //         children: [
      //           /// ---------- LEFT ----------
      //           Expanded(
      //             flex: 4,
      //             child: Row(
      //               children: [
      //                 Image.asset(DashboardAssets.menu),
      //                 12.width,
      //                 Expanded(
      //                   child: Column(
      //                     crossAxisAlignment: CrossAxisAlignment.start,
      //                     mainAxisSize: MainAxisSize.min,
      //                     children: [
      //                       const Text(
      //                         "CRM Dashboard",
      //                         style: TextStyle(
      //                           fontSize: 18,
      //                           fontWeight: FontWeight.bold,
      //                         ),
      //                       ),
      //                       4.height,
      //                       InkWell(
      //                         onTap: () {
      //                           context.read<DashboardProvider>().pickDateRange(
      //                             context,
      //                           );
      //                         },
      //                         child: Row(
      //                           children: [
      //                             Image.asset(DashboardAssets.calendar),
      //                             6.width,
      //                             Expanded(
      //                               child: Consumer<DashboardProvider>(
      //                                 builder: (_, dashboard, __) {
      //                                   final text =
      //                                       dashboard.selectedRange == null
      //                                       ? "Select Date Range"
      //                                       : "${dashboard.format(dashboard.selectedRange!.start)}"
      //                                             " → "
      //                                             "${dashboard.format(dashboard.selectedRange!.end)}"
      //                                             " • ${dashboard.days()} days";
      //
      //                                   return Text(
      //                                     text,
      //                                     maxLines: 1,
      //                                     overflow: TextOverflow.ellipsis,
      //                                     style:  GoogleFonts.inter(
      //                                       fontSize: 12,
      //                                       fontWeight: FontWeight.bold,
      //                                       color: Color(0xff666666),
      //                                     ),
      //                                   );
      //                                 },
      //                               ),
      //                             ),
      //                           ],
      //                         ),
      //                       ),
      //                     ],
      //                   ),
      //                 ),
      //               ],
      //             ),
      //           ),
      //           /// ---------- CENTER ----------
      //           Expanded(
      //             flex: 3,
      //             child: Column(
      //               mainAxisSize: MainAxisSize.min,
      //               crossAxisAlignment: CrossAxisAlignment.end,
      //               children: [
      //                 Container(
      //                   padding: const EdgeInsets.all(6),
      //                   decoration: _filterGroupDecoration(),
      //                   child: SingleChildScrollView(
      //                     scrollDirection: Axis.horizontal,
      //                     child: Row(
      //                       children: filters.map(_filterChip).toList(),
      //                     ),
      //                   ),
      //                 ),
      //                 4.height,
      //                 Text( "version 0.0.7",style: GoogleFonts.inter(
      //                     fontSize: 11, color: AppColors.primary,
      //                 ),)
      //               ],
      //             ),
      //           ),
      //           /// ---------- RIGHT ----------
      //           Expanded(
      //             flex: 3,
      //             child: Row(
      //               mainAxisAlignment: MainAxisAlignment.end,
      //               children: [
      //                 Expanded(
      //                   child: Column(
      //                     crossAxisAlignment: CrossAxisAlignment.end,
      //                     mainAxisSize: MainAxisSize.min,
      //                     children: [
      //                       Text( "Hi, Gopal", style: GoogleFonts.inter(
      //                         fontSize: 13,
      //                         fontWeight: FontWeight.bold,
      //                       ),),
      //                       4.height,
      //                       Row(
      //                         mainAxisSize: MainAxisSize.min,
      //                         children: [
      //                           GestureDetector(
      //                             onTap: () async {
      //                               final pickedDate = await showDatePicker(
      //                                 context: context,
      //                                 initialDate: selectedDate,
      //                                 firstDate: DateTime(2020),
      //                                 lastDate: DateTime(2030),
      //                               );
      //
      //                               if (pickedDate != null) {
      //                                 setState(() {
      //                                   selectedDate = pickedDate;
      //                                 });
      //                               }
      //                             },
      //                             child: Text(selectedDate == null
      //                                 ? "Last Sync · --"
      //                                 : "Last Sync · ${_formatDate(selectedDate!)}",style: GoogleFonts.inter(fontSize: 11,
      //                               fontWeight: FontWeight.bold,),)
      //                           ),
      //                           6.height,
      //                           Image.asset(DashboardAssets.sync),
      //                         ],
      //                       ),
      //                     ],
      //                   ),
      //                 ),
      //                 6.width,
      //                 Image.asset(DashboardAssets.defaultPerson),
      //               ],
      //             ),
      //           ),
      //         ],
      //       ),
      //     ),
      //   ),
      // ),
      body: SelectionArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SideBar(),
            Container(
              width: controllers.isLeftOpen.value == false &&
                  controllers.isRightOpen.value == false
                  ? screenWidth - 100
                  : screenWidth - 150,
              height: MediaQuery.of(context).size.height,
              alignment: Alignment.topLeft,
              // color: Colors.pinkAccent,
              padding: EdgeInsets.fromLTRB(40, 10, 0, 16),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Obx(()=>Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        20.height,
                        Container(
                          // color: Colors.yellow,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              WaveStatCard(
                                  title: "Mails",
                                  numericValue: int.parse(dashController
                                      .totalMails.value
                                      .toString()),
                                  maxValue: maxValue,
                                  iconPath: DashboardAssets.mail,
                                  valueColor: const Color(0xff2457C5),
                                  callback:(){
                                    remController.selectedMailSortBy.value = dashController.selectedSortBy.value;
                                    controllers.changeTab(1);
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context,
                                            animation1,
                                            animation2) =>
                                        const Records(
                                          isReload: "true",
                                        ),
                                        transitionDuration:
                                        Duration.zero,
                                        reverseTransitionDuration:
                                        Duration.zero,
                                      ),
                                    );
                                    controllers.oldIndex.value =
                                        controllers.selectedIndex.value;
                                    controllers.selectedIndex.value = 6;
                                  }
                              ),
                              WaveStatCard(
                                  title: "Calls",
                                  numericValue: int.parse(dashController.totalCalls.value.toString()),
                                  maxValue: maxValue,
                                  iconPath: DashboardAssets.phone,
                                  valueColor: const Color(0xff53922A),
                                  callback:(){
                                    remController.selectedCallSortBy.value = dashController.selectedSortBy.value;
                                    controllers.changeTab(0);
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context,
                                            animation1,
                                            animation2) =>
                                        const Records(
                                          isReload: "true",
                                        ),
                                        transitionDuration:
                                        Duration.zero,
                                        reverseTransitionDuration:
                                        Duration.zero,
                                      ),
                                    );
                                    controllers.oldIndex.value = controllers.selectedIndex.value;
                                    controllers.selectedIndex.value = 6;
                                  }
                              ),
                              WaveStatCard(
                                callback: () {
                                  remController.selectedMeetSortBy.value = dashController.selectedSortBy.value;
                                  controllers.changeTab(2);
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation1, animation2) =>
                                      const Records(
                                        isReload: "true",
                                      ),
                                      transitionDuration: Duration.zero,
                                      reverseTransitionDuration: Duration.zero,
                                    ),
                                  );
                                  controllers.oldIndex.value = controllers.selectedIndex.value;
                                  controllers.selectedIndex.value = 6;
                                },
                                title: "Appointments",
                                numericValue: int.parse(dashController.totalMeetings.value.toString()),
                                maxValue: maxValue,
                                iconPath: DashboardAssets.date,
                                valueColor: const Color(0xff8B2CF5),
                              ),
                              WaveStatCard(
                                callback: () {
                                  controllers.selectedProspectSortBy.value = dashController.selectedSortBy.value;
                                  // Navigator.push(
                                  //   context,
                                  //   PageRouteBuilder(
                                  //     pageBuilder: (context, animation1, animation2) => const Suspects(),
                                  //     transitionDuration: Duration.zero,
                                  //     reverseTransitionDuration: Duration.zero,
                                  //   ),
                                  // );
                                  controllers.oldIndex.value = controllers.selectedIndex.value;
                                  controllers.selectedIndex.value = 100;
                                },
                                title: "New Customers",
                                numericValue: int.parse(dashController.totalSuspects.value.toString()),
                                maxValue: maxValue,
                                iconPath: DashboardAssets.people,
                                valueColor: const Color(0xffF29D38),
                              ),
                              WaveStatCard(
                                callback: () {
                                  remController.selectedReminderSortBy.value = dashController.selectedSortBy.value;
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context,
                                          animation1,
                                          animation2) =>
                                      const ReminderPage(),
                                      transitionDuration:
                                      Duration.zero,
                                      reverseTransitionDuration:
                                      Duration.zero,
                                    ),
                                  );
                                  controllers.oldIndex.value =
                                      controllers.selectedIndex.value;
                                  controllers.selectedIndex.value =
                                  11;
                                },
                                title: "Reminders",
                                numericValue: int.parse(dashController
                                    .totalReminders.value
                                    .toString()),
                                maxValue: maxValue,
                                iconPath: DashboardAssets.alarm,
                                valueColor: const Color(0xffBB271A),
                              ),
                            ],
                          ),
                        ),
                        20.height,
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                // -------- Lead Distribution --------
                                SizedBox(
                                  width: screenWidth / 4,
                                  height: 350,
                                  child: dashController.leadReport.isEmpty
                                      ? Center(child: Text("No Data"))
                                      : LeadPieCard(
                                    // title: "Lead Distribution",
                                    // subtitle: "Breakdown by current stage",
                                    // total: controllers.allLeadList.length,
                                    data: [
                                      for (int i = 0; i < dashController.leadReport.length; i++)
                                        PieData(
                                          label: dashController.leadReport[i]["category"] ?? "",
                                          value: double.tryParse(
                                              dashController.leadReport[i]["customer_count"].toString()) ??
                                              0,
                                          color: dashController.color[i],
                                        ),
                                    ],
                                  ),
                                ),
                                20.height,
                                // -------- Customer Status --------
                                SizedBox(
                                  width: screenWidth / 4,
                                  child: CustomerStatusCard(
                                    items: [
                                      for (var i = 0;
                                      i < dashController.visitStatusReport.length;
                                      i++)
                                        CustomerStatusItem(
                                          label: dashController.visitStatusReport[i]["value"].toString(),
                                          value: int.parse(
                                              dashController.visitStatusReport[i]["total_count"].toString()),
                                          percentage: dashController.total == 0
                                              ? 0
                                              : double.parse(
                                              dashController.visitStatusReport[i]["total_count"].toString()) /
                                              dashController.total,
                                        ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            16.width,
                            // ================= RIGHT COLUMN =================
                            Column(
                              children: [
                                Row(
                                  children: [
                                    // Activity Rating
                                    Container(
                                      height: 250,
                                      width: screenWidth/3.7,
                                      padding: const EdgeInsets.all(16),
                                      decoration: _whiteCard(),
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          // -------- TITLE --------
                                          CustomText(
                                            text: "Activity Rating",
                                            isCopy: false,
                                            size: 14,
                                            isBold: true,
                                          ),

                                          4.height,

                                          // -------- SUBTITLE --------
                                          CustomText(
                                            text: "Customer Engagement Levels",
                                            isCopy: false,
                                            size: 12,
                                            isBold: false,
                                            colors: Color(0xff6B7280),
                                          ),

                                          10.height,

                                          // -------- DIVIDER --------
                                          const Divider(
                                            height: 1,
                                            thickness: 1,
                                            color: Color(0xffD1D5DB),
                                          ),

                                          18.height,

                                          // -------- RATING BAR () --------
                                          Expanded(
                                            child: LayoutBuilder(
                                              builder: (context, constraints) {
                                                final hot = int.tryParse(
                                                    dashController
                                                        .totalHot.value) ??
                                                    0;
                                                final warm = int.tryParse(
                                                    dashController
                                                        .totalWarm.value) ??
                                                    0;
                                                final cold = int.tryParse(
                                                    dashController
                                                        .totalCold.value) ??
                                                    0;
                                                final total = hot + warm + cold;

                                                return ActivityRatingBar(
                                                  hot: hot,
                                                  warm: warm,
                                                  cold: cold,
                                                  totalWidth:
                                                  constraints.maxWidth,
                                                );
                                              },
                                            ),
                                          ),
                                          12.height,
                                          Wrap(
                                            spacing: 16,
                                            runSpacing: 8,
                                            children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const SizedBox(
                                                    width: 8,
                                                    height: 8,
                                                    child: DecoratedBox(
                                                      decoration: BoxDecoration(
                                                        color: Color(
                                                          0xffEF4444,
                                                        ),
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  CustomText(
                                                    text: "Hot (0-${int.tryParse(dashController.totalHot.value) ??0}d)",
                                                    isCopy: false,
                                                    size: 11,
                                                    isBold: true,
                                                    colors: const Color(0xffEF4444),
                                                  ),
                                                ],
                                              ),

                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  SizedBox(
                                                    width: 8,
                                                    height: 8,
                                                    child: DecoratedBox(
                                                      decoration: BoxDecoration(
                                                        color: Color(
                                                          0xffF59E0B,
                                                        ),
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 6),
                                                  CustomText(
                                                    text:  "Warm (${(int.tryParse(dashController.totalHot.value) ??0)+1}-${int.tryParse(
                                                        dashController.totalWarm.value) ??0}d)",
                                                    isCopy: false,
                                                    size: 11,
                                                    isBold: true,
                                                    colors: Color(0xffF59E0B),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  SizedBox(
                                                    width: 8,
                                                    height: 8,
                                                    child: DecoratedBox(
                                                      decoration: BoxDecoration(
                                                        color: Color(
                                                          0xff3B82F6,
                                                        ),
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 6),
                                                  CustomText(
                                                    text:  "Cold (${(int.tryParse(dashController.totalWarm.value) ??0)+1}+d)",
                                                    isCopy: false,
                                                    size: 11,
                                                    isBold: true,
                                                    colors: Color(0xff3B82F6),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    16.width,
                                    // Quotations Sent
                                    SizedBox(
                                      width: screenWidth/3.7,
                                      child: Container(
                                        height: 250,
                                        padding: const EdgeInsets.all(16),
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
                                        child: Stack(
                                          clipBehavior: Clip.none,
                                          alignment: Alignment.center,
                                          children: [
                                            // -------- MAIN CONTENT --------
                                            Column(
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              children: [
                                                Stack(
                                                  clipBehavior: Clip.none,
                                                  alignment: Alignment.center,
                                                  children: [
                                                    // Main outlined circle
                                                    Container(
                                                      width: 110,
                                                      height: 110,
                                                      alignment: Alignment.center,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: Colors.black,
                                                          width: 2,
                                                        ),
                                                      ),

                                                      child:const CustomText(
                                                        text: "42",
                                                        isCopy: false,
                                                        size: 26,
                                                        isBold: true,
                                                      ),
                                                    ),

                                                    // Small top dot
                                                    const Positioned(
                                                      top: -6,
                                                      child: CircleAvatar(
                                                        radius: 5,
                                                        backgroundColor:
                                                        Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                16.height,
                                                const CustomText(
                                                  text:"Quotations Sent",
                                                  isCopy: false,
                                                  size: 13,
                                                  isBold: true,
                                                  colors: Colors.black,
                                                ),
                                              ],
                                            ),

                                            // -------- FILE ICON (OVERLAP) --------
                                            Positioned(
                                              top: 10,
                                              left: 10,
                                              child: Image.asset(
                                                DashboardAssets.file,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                20.height,
                                // -------- Activity Over Time () --------
                                ActivityOverTimeChart(
                                  maxY: 80,
                                  xLabels: controllers.xLabels,
                                  lines: [
                                    ActivityLineData(
                                      label: "Calls",
                                      color: Color(0xff3B82F6),
                                      values: controllers.calls,
                                    ),
                                    ActivityLineData(
                                      label: "Mails",
                                      color: Color(0xff10B981),
                                      values: controllers.mails,
                                    ),
                                    ActivityLineData(
                                      label: "Updates",
                                      color: Color(0xffEF4444),
                                      values: controllers.updates,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    )),
                  ),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 420),
                    curve: Curves.easeOutCubic,
                    top: 0,
                    bottom: 0,
                    right: isLeadPanelOpen ? 0 : -240,
                    child: _leadStagesPanel(),
                  ),

                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    top: 0,
                    bottom: 0,
                    right: isLeadPanelOpen ? -64 : 0,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: isLeadPanelOpen ? 0 : 1,
                      child: _leadStagesRail(context),
                    ),
                  ),
                ]
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _leadStagesPanel() {
    return Container(
      width: 240,
      height: MediaQuery.of(context).size.height - 140,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 14,
            offset: Offset(-6, 0),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // ================= HEADER =================
            SizedBox(
              height: 28,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  //  Centered Title
                  const Align(
                    alignment: Alignment.center,
                    child:  const CustomText(
                      text:"LEAD STAGES",
                      isCopy: false,
                      size: 14,
                      isBold: true,
                      colors: Colors.black,
                    ),
                  ),

                  //  Close Button Right Side
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isLeadPanelOpen = false;
                        });
                      },
                      child: Image.asset(DashboardAssets.leadStage),
                    ),
                  ),
                ],
              ),
            ),

            6.height,

            // ================= JOURNEY SWITCH =================
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isJourneyToday = !isJourneyToday;
                    });
                  },
                  child: const Icon(
                    Icons.circle,
                    size: 6,
                    color: Color(0xffD9D9D9),
                  ),
                ),
                6.width,

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return ClipRect(
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.6),
                          end: Offset.zero,
                        ).animate(animation),
                        child: FadeTransition(opacity: animation, child: child),
                      ),
                    );
                  },
                  child: CustomText(
                    text: isJourneyToday
                        ? "Today's Customer Journey"
                        : "Overall Customer Journey",
                    key:  ValueKey(isJourneyToday),
                    isCopy: false,
                    size: 11,
                    isBold: true,
                    colors: Colors.black,
                  ),
                ),

                6.width,

                GestureDetector(
                  onTap: () {
                    setState(() {
                      isJourneyToday = !isJourneyToday;
                    });
                  },
                  child: const Icon(
                    Icons.circle,
                    size: 6,
                    color: Color(0xffD9D9D9),
                  ),
                ),
              ],
            ),

            20.height,

            // ================= FUNNEL ITEMS =================
            for (int i = 0; i < dashController.leadReport.length; i++)
              _animatedLeadItem(
                index: 0,
                child: _leadItem(
                  title: dashController.leadReport[i]["category"] ?? "",
                  image: DashboardAssets.suspect,
                  count: dashController.leadReport[i]["customer_count"].toString(),
                  width: 180,
                ),
              ),
            // _animatedLeadItem(
            //   index: 0,
            //   child: _leadItem(
            //     title: "Suspect",
            //     image: DashboardAssets.suspect,
            //     count: "654",
            //     width: 180,
            //   ),
            // ),
            //
            // _animatedLeadItem(
            //   index: 1,
            //   child: _leadItem(
            //     title: "Prospect",
            //     image: DashboardAssets.prospect,
            //     count: "598",
            //     width: 160,
            //   ),
            // ),
            //
            // _animatedLeadItem(
            //   index: 2,
            //   child: _leadItem(
            //     title: "Qualified",
            //     image: DashboardAssets.qualified,
            //     count: "452",
            //     width: 140,
            //   ),
            // ),
            //
            // _animatedLeadItem(
            //   index: 3,
            //   child: _leadItem(
            //     title: "Customer",
            //     image: DashboardAssets.customer,
            //     count: "309",
            //     width: 120,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _filterGroupDecoration() => BoxDecoration(
    color: Color(0xffE2E8F0),
    borderRadius: BorderRadius.circular(10),
  );

  BoxDecoration _topBarDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(10),
    boxShadow: const [
      BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
    ],
  );

  Widget _leadStagesRail(BuildContext context) {
    return Container(
      width: 64,
      height: MediaQuery.of(context).size.height - 140,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            spreadRadius: 1,
            offset: Offset(-4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          16.height,

          // 🔹 ICON (PNG)
          InkWell(
            onTap: () {
              setState(() {
                isLeadPanelOpen = !isLeadPanelOpen;
                if (isLeadPanelOpen) {
                  _leadItemController.forward(from: 0);
                }
              });
            },
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xffE5E7EB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(child: Image.asset(DashboardAssets.leadStage)),
            ),
          ),

          24.height,

          // 🔹 TEXT (TOP → BOTTOM)
          const Expanded(
            child: RotatedBox(
              quarterTurns: 1,
              child:
              // CustomText(
              //   text:   "LEAD STAGES",
              //   isCopy: false,
              //   size: 14,
              //   isBold: true,
              //   colors: Colors.black,
              // ),
              Text(
                "LEAD STAGES",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String text) {
    final bool active = selectedFilter == text;

    return InkWell(
      onTap: () => setState(() => selectedFilter = text),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: CustomText(
        text: text,
        isCopy: false,
        size: 12,
        isBold: true,
        colors: active ? Color(0xff0078D7) : Color(0xff666666),
      ),
      ),
    );
  }
}

Widget _leadItem({
  required String title,
  required String image,
  required String count,
  required double width,
}) {
  return Column(
    children: [
      Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(image, width: width, fit: BoxFit.contain),
          CustomText(
            text:  title.toUpperCase(),
            isCopy: false,
            size: 11,
            isBold: true,
            colors: Colors.black,
          ),
        ],
      ),
      10.height,
      CustomText(
        text: count,
        isCopy: false,
        size: 14,
        isBold: true,
        colors: Colors.black,
      ),
      25.height,
    ],
  );
}

BoxDecoration _whiteCard() => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(12),
  boxShadow: const [
    BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 4)),
  ],
);

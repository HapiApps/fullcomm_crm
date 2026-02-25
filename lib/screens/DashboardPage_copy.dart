//
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter/material.dart';
// import 'package:fullcomm_crm/screens/leads/suspects.dart';
// import 'package:intl/intl.dart';
// import 'package:fullcomm_crm/common/extentions/extensions.dart';
// import 'package:fullcomm_crm/components/line_chart.dart';
// import 'package:fullcomm_crm/controller/dashboard_controller.dart';
// import 'package:fullcomm_crm/screens/leads/rating_leads.dart';
// import 'package:fullcomm_crm/screens/records/records.dart';
// import 'package:fullcomm_crm/screens/reminder/reminder_page.dart';
// import 'package:get/get.dart';
// import 'package:pie_chart/pie_chart.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../common/constant/api.dart';
// import '../common/constant/app_colors.dart';
// import '../common/constant/colors_constant.dart';
// import '../common/constant/dashboard_assets.dart';
// import '../common/utilities/utils.dart';
// import '../components/activity_over_time_chart.dart';
// import '../components/activityratingbar.dart';
// import '../components/custom_rating.dart';
// import '../components/custom_sidebar.dart';
// import '../components/custom_text.dart';
// import '../components/customer_status_card.dart';
// import '../components/pie_stat_card.dart';
// import '../components/wave_stat_card.dart';
// import '../controller/controller.dart';
// import '../controller/reminder_controller.dart';
// import '../provider/dashboard_provider.dart';
// import '../provider/employee_provider.dart';
// import '../services/api_services.dart';
// import 'dart:html' as html;
// import 'employee/employee_screen.dart';
//
// class DashboardPage extends StatefulWidget {
//   const DashboardPage({super.key});
//
//   @override
//   State<DashboardPage> createState() => _DashboardPageState();
// }
//
// class _DashboardPageState extends State<DashboardPage>
//     with SingleTickerProviderStateMixin {
//   DateTime? selectedDate;
//   final statValues = [1596, 256, 65, 264, 6];
//   late final maxValue = statValues.reduce((a, b) => a > b ? a : b);
//   String selectedFilter = "Today";
//   bool isJourneyToday = true;
//
//   bool isLeadPanelOpen = false;
//
//   final List<String> filters = [
//     "Today",
//     "Yesterday",
//     "Last 7 days",
//     "Last 30 days",
//   ];
//
//   late AnimationController _leadItemController;
//   late List<Animation<double>> _leadItemAnimations;
//   int? hoveredIndex;
//   String _formatDate(DateTime date) {
//     return "${date.day.toString().padLeft(2, '0')}-"
//         "${date.month.toString().padLeft(2, '0')}-"
//         "${date.year}";
//   }
//
//   @override
//   void initState() {
//     super.initState();
//
//     _leadItemController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 2200),
//     );
//
//     _leadItemAnimations = [
//       // Suspect
//       CurvedAnimation(
//         parent: _leadItemController,
//         curve: const Interval(0.0, 0.20, curve: Curves.easeOut),
//       ),
//
//       // Prospect
//       CurvedAnimation(
//         parent: _leadItemController,
//         curve: const Interval(0.35, 0.55, curve: Curves.easeOut),
//       ),
//
//       // Qualified
//       CurvedAnimation(
//         parent: _leadItemController,
//         curve: const Interval(0.70, 0.90, curve: Curves.easeOut),
//       ),
//
//       // Customer
//       CurvedAnimation(
//         parent: _leadItemController,
//         curve: const Interval(1.00, 1.0, curve: Curves.easeOut),
//       ),
//     ];
//   }
//
//   @override
//   void dispose() {
//     _leadItemController.dispose();
//     super.dispose();
//   }
//
//   Widget _animatedLeadItem({required int index, required Widget child}) {
//     final anim = _leadItemAnimations[index];
//
//     return FadeTransition(
//       opacity: anim,
//       child: SlideTransition(
//         position: Tween<Offset>(
//           begin: const Offset(0, -1.2),
//           end: Offset.zero,
//         ).animate(anim),
//         child: child,
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     final width = MediaQuery.of(context).size.width;
//     final isMobile = width < 768;
//     final isTablet = width >= 768 && width < 1100;
//     final isDesktop = width >= 1100;
//     final dashboard = context.watch<DashboardProvider>();
//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F6F8),
//       // appBar: PreferredSize(
//       //   preferredSize: Size.fromHeight(screenWidth < 900 ? 120 : 100),
//       //   child: Container(
//       //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
//       //     decoration: _topBarDecoration(),
//       //     child: SafeArea(
//       //       bottom: false,
//       //       child: Row(
//       //         crossAxisAlignment: CrossAxisAlignment.center,
//       //         children: [
//       //           /// ---------- LEFT ----------
//       //           Expanded(
//       //             flex: 4,
//       //             child: Row(
//       //               children: [
//       //                 Image.asset(DashboardAssets.menu),
//       //                 12.width,
//       //                 Expanded(
//       //                   child: Column(
//       //                     crossAxisAlignment: CrossAxisAlignment.start,
//       //                     mainAxisSize: MainAxisSize.min,
//       //                     children: [
//       //                       const Text(
//       //                         "CRM Dashboard",
//       //                         style: TextStyle(
//       //                           fontSize: 18,
//       //                           fontWeight: FontWeight.bold,
//       //                         ),
//       //                       ),
//       //                       4.height,
//       //                       InkWell(
//       //                         onTap: () {
//       //                           context.read<DashboardProvider>().pickDateRange(
//       //                             context,
//       //                           );
//       //                         },
//       //                         child: Row(
//       //                           children: [
//       //                             Image.asset(DashboardAssets.calendar),
//       //                             6.width,
//       //                             Expanded(
//       //                               child: Consumer<DashboardProvider>(
//       //                                 builder: (_, dashboard, __) {
//       //                                   final text =
//       //                                       dashboard.selectedRange == null
//       //                                       ? "Select Date Range"
//       //                                       : "${dashboard.format(dashboard.selectedRange!.start)}"
//       //                                             " → "
//       //                                             "${dashboard.format(dashboard.selectedRange!.end)}"
//       //                                             " • ${dashboard.days()} days";
//       //
//       //                                   return Text(
//       //                                     text,
//       //                                     maxLines: 1,
//       //                                     overflow: TextOverflow.ellipsis,
//       //                                     style:  GoogleFonts.inter(
//       //                                       fontSize: 12,
//       //                                       fontWeight: FontWeight.bold,
//       //                                       color: Color(0xff666666),
//       //                                     ),
//       //                                   );
//       //                                 },
//       //                               ),
//       //                             ),
//       //                           ],
//       //                         ),
//       //                       ),
//       //                     ],
//       //                   ),
//       //                 ),
//       //               ],
//       //             ),
//       //           ),
//       //           /// ---------- CENTER ----------
//       //           Expanded(
//       //             flex: 3,
//       //             child: Column(
//       //               mainAxisSize: MainAxisSize.min,
//       //               crossAxisAlignment: CrossAxisAlignment.end,
//       //               children: [
//       //                 Container(
//       //                   padding: const EdgeInsets.all(6),
//       //                   decoration: _filterGroupDecoration(),
//       //                   child: SingleChildScrollView(
//       //                     scrollDirection: Axis.horizontal,
//       //                     child: Row(
//       //                       children: filters.map(_filterChip).toList(),
//       //                     ),
//       //                   ),
//       //                 ),
//       //                 4.height,
//       //                 Text( "version 0.0.7",style: GoogleFonts.inter(
//       //                     fontSize: 11, color: AppColors.primary,
//       //                 ),)
//       //               ],
//       //             ),
//       //           ),
//       //           /// ---------- RIGHT ----------
//       //           Expanded(
//       //             flex: 3,
//       //             child: Row(
//       //               mainAxisAlignment: MainAxisAlignment.end,
//       //               children: [
//       //                 Expanded(
//       //                   child: Column(
//       //                     crossAxisAlignment: CrossAxisAlignment.end,
//       //                     mainAxisSize: MainAxisSize.min,
//       //                     children: [
//       //                       Text( "Hi, Gopal", style: GoogleFonts.inter(
//       //                         fontSize: 13,
//       //                         fontWeight: FontWeight.bold,
//       //                       ),),
//       //                       4.height,
//       //                       Row(
//       //                         mainAxisSize: MainAxisSize.min,
//       //                         children: [
//       //                           GestureDetector(
//       //                             onTap: () async {
//       //                               final pickedDate = await showDatePicker(
//       //                                 context: context,
//       //                                 initialDate: selectedDate,
//       //                                 firstDate: DateTime(2020),
//       //                                 lastDate: DateTime(2030),
//       //                               );
//       //
//       //                               if (pickedDate != null) {
//       //                                 setState(() {
//       //                                   selectedDate = pickedDate;
//       //                                 });
//       //                               }
//       //                             },
//       //                             child: Text(selectedDate == null
//       //                                 ? "Last Sync · --"
//       //                                 : "Last Sync · ${_formatDate(selectedDate!)}",style: GoogleFonts.inter(fontSize: 11,
//       //                               fontWeight: FontWeight.bold,),)
//       //                           ),
//       //                           6.height,
//       //                           Image.asset(DashboardAssets.sync),
//       //                         ],
//       //                       ),
//       //                     ],
//       //                   ),
//       //                 ),
//       //                 6.width,
//       //                 Image.asset(DashboardAssets.defaultPerson),
//       //               ],
//       //             ),
//       //           ),
//       //         ],
//       //       ),
//       //     ),
//       //   ),
//       // ),
//       body: SelectionArea(
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             SideBar(),
//             Container(
//               width: controllers.isLeftOpen.value == false &&
//                   controllers.isRightOpen.value == false
//                   ? screenWidth - 200
//                   : screenWidth - 400,
//               height: MediaQuery.of(context).size.height,
//               alignment: Alignment.topLeft,
//               padding: EdgeInsets.fromLTRB(40, 10, 40, 16),
//               child: Stack(
//                 children: [
//                   SingleChildScrollView(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         20.height,
//                         Row(
//                           children: [
//                             WaveStatCard(
//                               title: "Mails",
//                               numericValue: 1596,
//                               maxValue: maxValue,
//                               iconPath: DashboardAssets.mail,
//                               valueColor: const Color(0xff2457C5),
//                             ),
//                             WaveStatCard(
//                               title: "Calls",
//                               numericValue: 256,
//                               maxValue: maxValue,
//                               iconPath: DashboardAssets.phone,
//                               valueColor: const Color(0xff53922A),
//                             ),
//                             WaveStatCard(
//                               title: "Appointments",
//                               numericValue: 65,
//                               maxValue: maxValue,
//                               iconPath: DashboardAssets.date,
//                               valueColor: const Color(0xff8B2CF5),
//                             ),
//                             WaveStatCard(
//                               title: "New Customers",
//                               numericValue: 264,
//                               maxValue: maxValue,
//                               iconPath: DashboardAssets.people,
//                               valueColor: const Color(0xffF29D38),
//                             ),
//                             WaveStatCard(
//                               title: "Reminders",
//                               numericValue: 6,
//                               maxValue: maxValue,
//                               iconPath: DashboardAssets.alarm,
//                               valueColor: const Color(0xffBB271A),
//                             ),
//                           ],
//                         ),
//                         // Row(
//                         //   children: const [
//                         //     WaveStatCard(
//                         //       title: "Mails",
//                         //       value: "1596",
//                         //       iconPath: DashboardAssets.mail,
//                         //       waveImage: DashboardAssets.waveBlue,
//                         //       valueColor: Color(0xff2457C5),
//                         //     ),
//                         //     WaveStatCard(
//                         //       title: "Calls",
//                         //       value: "256",
//                         //       iconPath: DashboardAssets.phone,
//                         //       waveImage: DashboardAssets.waveGreen,
//                         //       valueColor: Color(0xff53922A),
//                         //     ),
//                         //     WaveStatCard(
//                         //       title: "Appointments",
//                         //       value: "65",
//                         //       iconPath: DashboardAssets.date,
//                         //       waveImage: DashboardAssets.wavePurple,
//                         //       valueColor: Color(0xff8B2CF5),
//                         //     ),
//                         //     WaveStatCard(
//                         //       title: "New Customers",
//                         //       value: "264",
//                         //       iconPath: DashboardAssets.people,
//                         //       waveImage: DashboardAssets.waveOrange,
//                         //       valueColor: Color(0xffF29D38),
//                         //     ),
//                         //     WaveStatCard(
//                         //       title: "Reminders",
//                         //       value: "06",
//                         //       iconPath: DashboardAssets.alarm,
//                         //       waveImage: DashboardAssets.waveRed,
//                         //       valueColor: Color(0xffBB271A),
//                         //     ),
//                         //   ],
//                         // ),
//                         20.height,
//                         Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Column(
//                               children: [
//                                 // -------- Lead Distribution --------
//                                 SizedBox(
//                                   width: 420,
//                                   height: 350,
//                                   child: PieStatCard(
//                                     title: "Lead Distribution",
//                                     subtitle: "Breakdown by current stage",
//                                     total: 2360,
//                                     values: const [
//                                       PieStatValue(
//                                         label: "Suspect",
//                                         value: 40,
//                                         color: Color(0xffF59E0B),
//                                       ),
//                                       PieStatValue(
//                                         label: "Prospect",
//                                         value: 25,
//                                         color: Color(0xff3B82F6),
//                                       ),
//                                       PieStatValue(
//                                         label: "Qualified",
//                                         value: 20,
//                                         color: Color(0xff8B5CF6),
//                                       ),
//                                       PieStatValue(
//                                         label: "Customers",
//                                         value: 10,
//                                         color: Color(0xff10B981),
//                                       ),
//                                       PieStatValue(
//                                         label: "Disqualified",
//                                         value: 5,
//                                         color: Color(0xffEF4444),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//
//                                 20.height,
//
//                                 // -------- Customer Status --------
//                                 SizedBox(
//                                   width: 420,
//                                   child: CustomerStatusCard(
//                                     items: [
//                                       CustomerStatusItem(
//                                         label: "Contacted",
//                                         value: 45,
//                                         percentage: 0.85,
//                                       ),
//                                       CustomerStatusItem(
//                                         label: "Call Back",
//                                         value: 32,
//                                         percentage: 0.65,
//                                       ),
//                                       CustomerStatusItem(
//                                         label: "Demo Scheduled",
//                                         value: 28,
//                                         percentage: 0.55,
//                                       ),
//                                       CustomerStatusItem(
//                                         label: "Not Interested",
//                                         value: 12,
//                                         percentage: 0.25,
//                                       ),
//                                       CustomerStatusItem(
//                                         label: "New Status",
//                                         value: 20,
//                                         percentage: 0.40,
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             16.width,
//                             // ================= RIGHT COLUMN =================
//                             Expanded(
//                               child: Column(
//                                 children: [
//                                   Row(
//                                     children: [
//                                       // Activity Rating
//                                       Expanded(
//                                         flex: 2,
//                                         child: Container(
//                                           height: 250,
//                                           padding: const EdgeInsets.all(16),
//                                           decoration: _whiteCard(),
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               // -------- TITLE --------
//                                               CustomText(
//                                                 text: "Activity Rating",
//                                                 isCopy: false,
//                                                 size: 14,
//                                                 isBold: true,
//                                               ),
//
//                                               4.height,
//
//                                               // -------- SUBTITLE --------
//                                               CustomText(
//                                                 text: "Customer Engagement Levels",
//                                                 isCopy: false,
//                                                 size: 12,
//                                                 isBold: false,
//                                                 colors: Color(0xff6B7280),
//                                               ),
//
//                                               10.height,
//
//                                               // -------- DIVIDER --------
//                                               const Divider(
//                                                 height: 1,
//                                                 thickness: 1,
//                                                 color: Color(0xffD1D5DB),
//                                               ),
//
//                                               18.height,
//
//                                               // -------- RATING BAR () --------
//                                               Expanded(
//                                                 child: LayoutBuilder(
//                                                   builder: (context, constraints) {
//                                                     final hot = 45;
//                                                     final warm = 32;
//                                                     final cold = 24;
//                                                     final total = hot + warm + cold;
//
//                                                     return ActivityRatingBar(
//                                                       hot: hot,
//                                                       warm: warm,
//                                                       cold: cold,
//                                                       totalWidth:
//                                                           constraints.maxWidth,
//                                                     );
//                                                   },
//                                                 ),
//                                               ),
//                                               12.height,
//                                               Wrap(
//                                                 spacing: 16,
//                                                 runSpacing: 8,
//                                                 children: [
//                                                   Row(
//                                                     mainAxisSize: MainAxisSize.min,
//                                                     children: const [
//                                                       SizedBox(
//                                                         width: 8,
//                                                         height: 8,
//                                                         child: DecoratedBox(
//                                                           decoration: BoxDecoration(
//                                                             color: Color(
//                                                               0xffEF4444,
//                                                             ),
//                                                             shape: BoxShape.circle,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                       SizedBox(width: 6),
//                                                       const CustomText(
//                                                         text: "Hot (0-30d)",
//                                                         isCopy: false,
//                                                         size: 11,
//                                                         isBold: true,
//                                                         colors: Color(0xffEF4444),
//                                                       ),
//                                                     ],
//                                                   ),
//
//                                                   Row(
//                                                     mainAxisSize: MainAxisSize.min,
//                                                     children: const [
//                                                       SizedBox(
//                                                         width: 8,
//                                                         height: 8,
//                                                         child: DecoratedBox(
//                                                           decoration: BoxDecoration(
//                                                             color: Color(
//                                                               0xffF59E0B,
//                                                             ),
//                                                             shape: BoxShape.circle,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                       SizedBox(width: 6),
//                                                       const CustomText(
//                                                         text:  "Warm (31-60d)",
//                                                         isCopy: false,
//                                                         size: 11,
//                                                         isBold: true,
//                                                         colors: Color(0xffF59E0B),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                   Row(
//                                                     mainAxisSize: MainAxisSize.min,
//                                                     children: const [
//                                                       SizedBox(
//                                                         width: 8,
//                                                         height: 8,
//                                                         child: DecoratedBox(
//                                                           decoration: BoxDecoration(
//                                                             color: Color(
//                                                               0xff3B82F6,
//                                                             ),
//                                                             shape: BoxShape.circle,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                       SizedBox(width: 6),
//                                                       const CustomText(
//                                                         text:  "Cold (61+d)",
//                                                         isCopy: false,
//                                                         size: 11,
//                                                         isBold: true,
//                                                         colors: Color(0xff3B82F6),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ],
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                       16.width,
//                                       // Quotations Sent
//                                       SizedBox(
//                                         width: 370,
//                                         child: Container(
//                                           height: 250,
//                                           padding: const EdgeInsets.all(16),
//                                           decoration: BoxDecoration(
//                                             color: Colors.white,
//                                             borderRadius: BorderRadius.circular(12),
//                                             boxShadow: const [
//                                               BoxShadow(
//                                                 color: Color(0x14000000),
//                                                 blurRadius: 10,
//                                                 offset: Offset(0, 4),
//                                               ),
//                                             ],
//                                           ),
//                                           child: Stack(
//                                             clipBehavior: Clip.none,
//                                             alignment: Alignment.center,
//                                             children: [
//                                               // -------- MAIN CONTENT --------
//                                               Column(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment.center,
//                                                 children: [
//                                                   Stack(
//                                                     clipBehavior: Clip.none,
//                                                     alignment: Alignment.center,
//                                                     children: [
//                                                       // Main outlined circle
//                                                       Container(
//                                                         width: 110,
//                                                         height: 110,
//                                                         alignment: Alignment.center,
//                                                         decoration: BoxDecoration(
//                                                           shape: BoxShape.circle,
//                                                           border: Border.all(
//                                                             color: Colors.black,
//                                                             width: 2,
//                                                           ),
//                                                         ),
//
//                                                         child:const CustomText(
//                                                           text: "42",
//                                                           isCopy: false,
//                                                           size: 26,
//                                                           isBold: true,
//                                                         ),
//                                                       ),
//
//                                                       // Small top dot
//                                                       const Positioned(
//                                                         top: -6,
//                                                         child: CircleAvatar(
//                                                           radius: 5,
//                                                           backgroundColor:
//                                                               Colors.black,
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//
//                                                   16.height,
//                                                   const CustomText(
//                                                     text:"Quotations Sent",
//                                                     isCopy: false,
//                                                     size: 13,
//                                                     isBold: true,
//                                                     colors: Colors.black,
//                                                   ),
//                                                 ],
//                                               ),
//
//                                               // -------- FILE ICON (OVERLAP) --------
//                                               Positioned(
//                                                 top: 10,
//                                                 left: 10,
//                                                 child: Image.asset(
//                                                   DashboardAssets.file,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   20.height,
//                                   // -------- Activity Over Time () --------
//                                   ActivityOverTimeChart(
//                                     maxY: 80,
//                                     xLabels: [
//                                       "Jan21",
//                                       "Jan22",
//                                       "Jan23",
//                                       "Jan24",
//                                       "Jan25",
//                                       "Jan26",
//                                       "Jan27",
//                                       "Jan28",
//                                       "Jan29",
//                                       "Jan30",
//                                       "Jan31",
//                                       "Feb1",
//                                       "Feb2",
//                                       "Feb3",
//                                       "Feb4",
//                                       "Feb5",
//                                       "Feb6",
//                                     ],
//                                     lines: [
//                                       ActivityLineData(
//                                         label: "Calls",
//                                         color: Color(0xff3B82F6),
//                                         values: [
//                                           50,
//                                           65,
//                                           30,
//                                           36,
//                                           26,
//                                           68,
//                                           60,
//                                           52,
//                                           42,
//                                           33,
//                                           40,
//                                           50,
//                                           68,
//                                           34,
//                                           50,
//                                           48,
//                                           46,
//                                         ],
//                                       ),
//                                       ActivityLineData(
//                                         label: "Mails",
//                                         color: Color(0xff10B981),
//                                         values: [
//                                           12,
//                                           10,
//                                           8,
//                                           14,
//                                           15,
//                                           16,
//                                           9,
//                                           7,
//                                           18,
//                                           16,
//                                           14,
//                                           12,
//                                           14,
//                                           10,
//                                           8,
//                                           11,
//                                           19,
//                                         ],
//                                       ),
//                                       ActivityLineData(
//                                         label: "Updates",
//                                         color: Color(0xffEF4444),
//                                         values: [
//                                           6,
//                                           3,
//                                           12,
//                                           10,
//                                           22,
//                                           5,
//                                           20,
//                                           16,
//                                           12,
//                                           18,
//                                           15,
//                                           25,
//                                           7,
//                                           17,
//                                           9,
//                                           6,
//                                           16,
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   // AnimatedPositioned(
//                   //   duration: const Duration(milliseconds: 420),
//                   //   curve: Curves.easeOutCubic,
//                   //   top: 0,
//                   //   bottom: 0,
//                   //   right: isLeadPanelOpen ? 0 : -240,
//                   //   child: _leadStagesPanel(),
//                   // ),
//                   //
//                   // AnimatedPositioned(
//                   //   duration: const Duration(milliseconds: 300),
//                   //   top: 0,
//                   //   bottom: 0,
//                   //   right: isLeadPanelOpen ? -64 : 0,
//                   //   child: AnimatedOpacity(
//                   //     duration: const Duration(milliseconds: 200),
//                   //     opacity: isLeadPanelOpen ? 0 : 1,
//                   //     child: _leadStagesRail(context),
//                   //   ),
//                   // ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _leadStagesPanel() {
//     return Container(
//       width: 240,
//       height: MediaQuery.of(context).size.height - 140,
//       padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: const [
//           BoxShadow(
//             color: Colors.black26,
//             blurRadius: 14,
//             offset: Offset(-6, 0),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           // ================= HEADER =================
//           SizedBox(
//             height: 28,
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 //  Centered Title
//                 const Align(
//                   alignment: Alignment.center,
//                   child:  const CustomText(
//                     text:"LEAD STAGES",
//                     isCopy: false,
//                     size: 14,
//                     isBold: true,
//                     colors: Colors.black,
//                   ),
//                 ),
//
//                 //  Close Button Right Side
//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         isLeadPanelOpen = false;
//                       });
//                     },
//                     child: Image.asset(DashboardAssets.leadStage),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           6.height,
//
//           // ================= JOURNEY SWITCH =================
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     isJourneyToday = !isJourneyToday;
//                   });
//                 },
//                 child: const Icon(
//                   Icons.circle,
//                   size: 6,
//                   color: Color(0xffD9D9D9),
//                 ),
//               ),
//               6.width,
//
//               AnimatedSwitcher(
//                 duration: const Duration(milliseconds: 300),
//                 transitionBuilder: (child, animation) {
//                   return ClipRect(
//                     child: SlideTransition(
//                       position: Tween<Offset>(
//                         begin: const Offset(0, 0.6),
//                         end: Offset.zero,
//                       ).animate(animation),
//                       child: FadeTransition(opacity: animation, child: child),
//                     ),
//                   );
//                 },
//                 child: CustomText(
//                   text: isJourneyToday
//                       ? "Today's Customer Journey"
//                       : "Overall Customer Journey",
//                   key:  ValueKey(isJourneyToday),
//                   isCopy: false,
//                   size: 11,
//                   isBold: true,
//                   colors: Colors.black,
//                 ),
//               ),
//
//               6.width,
//
//               GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     isJourneyToday = !isJourneyToday;
//                   });
//                 },
//                 child: const Icon(
//                   Icons.circle,
//                   size: 6,
//                   color: Color(0xffD9D9D9),
//                 ),
//               ),
//             ],
//           ),
//
//           20.height,
//
//           // ================= FUNNEL ITEMS =================
//           _animatedLeadItem(
//             index: 0,
//             child: _leadItem(
//               title: "Suspect",
//               image: DashboardAssets.suspect,
//               count: "654",
//               width: 180,
//             ),
//           ),
//
//           _animatedLeadItem(
//             index: 1,
//             child: _leadItem(
//               title: "Prospect",
//               image: DashboardAssets.prospect,
//               count: "598",
//               width: 160,
//             ),
//           ),
//
//           _animatedLeadItem(
//             index: 2,
//             child: _leadItem(
//               title: "Qualified",
//               image: DashboardAssets.qualified,
//               count: "452",
//               width: 140,
//             ),
//           ),
//
//           _animatedLeadItem(
//             index: 3,
//             child: _leadItem(
//               title: "Customer",
//               image: DashboardAssets.customer,
//               count: "309",
//               width: 120,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   BoxDecoration _filterGroupDecoration() => BoxDecoration(
//     color: Color(0xffE2E8F0),
//     borderRadius: BorderRadius.circular(10),
//   );
//
//   BoxDecoration _topBarDecoration() => BoxDecoration(
//     color: Colors.white,
//     borderRadius: BorderRadius.circular(10),
//     boxShadow: const [
//       BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
//     ],
//   );
//
//   Widget _leadStagesRail(BuildContext context) {
//     return Container(
//       width: 64,
//       height: MediaQuery.of(context).size.height - 140,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: const [
//           BoxShadow(
//             color: Colors.black26,
//             blurRadius: 12,
//             spreadRadius: 1,
//             offset: Offset(-4, 0),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           16.height,
//
//           // 🔹 ICON (PNG)
//           InkWell(
//             onTap: () {
//               setState(() {
//                 isLeadPanelOpen = !isLeadPanelOpen;
//                 if (isLeadPanelOpen) {
//                   _leadItemController.forward(from: 0);
//                 }
//               });
//             },
//             child: Container(
//               width: 38,
//               height: 38,
//               decoration: BoxDecoration(
//                 color: const Color(0xffE5E7EB),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Center(child: Image.asset(DashboardAssets.leadStage)),
//             ),
//           ),
//
//           24.height,
//
//           // 🔹 TEXT (TOP → BOTTOM)
//           const Expanded(
//             child: RotatedBox(
//               quarterTurns: 1,
//               child:
//               // CustomText(
//               //   text:   "LEAD STAGES",
//               //   isCopy: false,
//               //   size: 14,
//               //   isBold: true,
//               //   colors: Colors.black,
//               // ),
//               Text(
//                 "LEAD STAGES",
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w700,
//                   letterSpacing: 2,
//                   color: Colors.black,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _filterChip(String text) {
//     final bool active = selectedFilter == text;
//
//     return InkWell(
//       onTap: () => setState(() => selectedFilter = text),
//       borderRadius: BorderRadius.circular(10),
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 4),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         decoration: BoxDecoration(
//           color: active ? Colors.white : Colors.transparent,
//           borderRadius: BorderRadius.circular(10),
//           boxShadow: active
//               ? [
//                   BoxShadow(
//                     color: Colors.black12,
//                     blurRadius: 6,
//                     offset: const Offset(0, 2),
//                   ),
//                 ]
//               : null,
//         ),
//         child: CustomText(
//         text: text,
//         isCopy: false,
//         size: 12,
//         isBold: true,
//         colors: active ? Color(0xff0078D7) : Color(0xff666666),
//       ),
//       ),
//     );
//   }
// }
//
// Widget _leadItem({
//   required String title,
//   required String image,
//   required String count,
//   required double width,
// }) {
//   return Column(
//     children: [
//       Stack(
//         alignment: Alignment.center,
//         children: [
//           Image.asset(image, width: width, fit: BoxFit.contain),
//           CustomText(
//             text:  title.toUpperCase(),
//             isCopy: false,
//             size: 11,
//             isBold: true,
//             colors: Colors.black,
//           ),
//         ],
//       ),
//       10.height,
//       CustomText(
//         text: count,
//         isCopy: false,
//         size: 14,
//         isBold: true,
//         colors: Colors.black,
//       ),
//       25.height,
//     ],
//   );
// }
//
// BoxDecoration _whiteCard() => BoxDecoration(
//   color: Colors.white,
//   borderRadius: BorderRadius.circular(12),
//   boxShadow: const [
//     BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 4)),
//   ],
// );
// // Row(
// //   crossAxisAlignment: CrossAxisAlignment.center,
// //   children: [
// //
// //     /// ---------- LEFT ----------
// //     Row(
// //       children: [
// //         Image.asset(
// //           "assets/images/menu.png",
// //           color: Colors.black54,
// //         ),
// //         const SizedBox(width: 12),
// //
// //         Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             const Text(
// //               "CRM Dashboard",
// //               style: TextStyle(
// //                 fontSize: 18,
// //                 fontWeight: FontWeight.bold,
// //               ),
// //             ),
// //             const SizedBox(height: 4),
// //
// //             InkWell(
// //               onTap: () {
// //                 context.read<DashboardProvider>().pickDateRange(context);
// //               },
// //               child: Row(
// //                 children: [
// //                   Image.asset(
// //                     "assets/images/new_calendar.png",
// //                     color: Colors.black54,
// //                   ),
// //                   const SizedBox(width: 6),
// //                   Consumer<DashboardProvider>(
// //                     builder: (_, dashboard, __) {
// //                       final text =
// //                       dashboard.selectedRange == null
// //                           ? "Select Date Range"
// //                           : "${dashboard.format(dashboard.selectedRange!.start)}"
// //                           " → "
// //                           "${dashboard.format(dashboard.selectedRange!.end)}"
// //                           " • ${dashboard.days()} days";
// //
// //                       return Text(
// //                         text,
// //                         maxLines: 1,
// //                         overflow: TextOverflow.ellipsis,
// //                         style: const TextStyle(
// //                           fontSize: 12,
// //                           fontWeight: FontWeight.bold,
// //                           color: Color(0xff666666),
// //                         ),
// //                       );
// //                     },
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ],
// //         ),
// //       ],
// //     ),
// //
// //     const Spacer(),
// //
// //     /// ---------- CENTER (TRUE CENTER) ----------
// //     Column(
// //       mainAxisSize: MainAxisSize.min,
// //       children: [
// //         Container(
// //           padding: const EdgeInsets.all(6),
// //           decoration: _filterGroupDecoration(),
// //           child: SingleChildScrollView(
// //             scrollDirection: Axis.horizontal,
// //             child: Row(
// //               children: filters.map(_filterChip).toList(),
// //             ),
// //           ),
// //         ),
// //         const SizedBox(height: 4),
// //         const Text(
// //           "version 0.0.7",
// //           style: TextStyle(fontSize: 11, color: Colors.blue),
// //         ),
// //       ],
// //     ),
// //
// //     const Spacer(),
// //
// //     /// ---------- RIGHT ----------
// //     Row(
// //       children: [
// //         Column(
// //           crossAxisAlignment: CrossAxisAlignment.end,
// //           mainAxisSize: MainAxisSize.min,
// //           children: const [
// //             Text(
// //               "Hi, Gopal",
// //               maxLines: 1,
// //               overflow: TextOverflow.ellipsis,
// //               style: TextStyle(
// //                 fontSize: 13,
// //                 fontWeight: FontWeight.bold,
// //               ),
// //             ),
// //             SizedBox(height: 2),
// //             Text(
// //               "Last Sync · 02-01-2026",
// //               maxLines: 1,
// //               overflow: TextOverflow.ellipsis,
// //               style: TextStyle(
// //                 fontSize: 11,
// //                 fontWeight: FontWeight.bold,
// //               ),
// //             ),
// //           ],
// //         ),
// //         const SizedBox(width: 8),
// //         Image.asset(
// //           "assets/images/default_person.png",
// //           width: 40,
// //           height: 40,
// //         ),
// //       ],
// //     ),
// //   ],
// // )
// // Container(
// //   padding: const EdgeInsets.symmetric(
// //     horizontal: 20,
// //     vertical: 14,
// //   ),
// //   decoration: _topBarDecoration(),
// //   child: Row(
// //     crossAxisAlignment: CrossAxisAlignment.center,
// //     children: [
// //       // ---------- LEFT ----------
// //       Row(
// //         children: [
// //           Image.asset(
// //             "assets/images/menu.png",
// //             color: Colors.black54,
// //           ),
// //           const SizedBox(width: 12),
// //
// //           Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               const Text(
// //                 "CRM Dashboard",
// //                 style: TextStyle(
// //                   fontSize: 18,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //               ),
// //               const SizedBox(height: 4),
// //
// //               InkWell(
// //                 onTap: () {
// //                   context
// //                       .read<DashboardProvider>()
// //                       .pickDateRange(context);
// //                 },
// //                 borderRadius: BorderRadius.circular(6),
// //                 child: Row(
// //                   children: [
// //                     Image.asset(
// //                       "assets/images/new_calendar.png",
// //                       color: Colors.black54,
// //                     ),
// //                     const SizedBox(width: 6),
// //
// //                     Consumer<DashboardProvider>(
// //                       builder: (_, dashboard, __) {
// //                         if (dashboard.selectedRange == null) {
// //                           return const Text(
// //                             "Select Date Range",
// //                             style: TextStyle(
// //                               fontSize: 12,
// //                               fontWeight: FontWeight.bold,
// //                               color: Color(0xff666666),
// //                             ),
// //                           );
// //                         }
// //
// //                         return Row(
// //                           children: [
// //                             Text(
// //                               "${dashboard.format(dashboard.selectedRange!.start)}"
// //                               " → "
// //                               "${dashboard.format(dashboard.selectedRange!.end)}",
// //                               style: const TextStyle(
// //                                 fontSize: 12,
// //                                 fontWeight: FontWeight.bold,
// //                                 color: Color(0xff666666),
// //                               ),
// //                             ),
// //                             const SizedBox(width: 8),
// //                             const Text(
// //                               "•",
// //                               style: TextStyle(
// //                                 fontSize: 12,
// //                                 color: Color(0xff999999),
// //                               ),
// //                             ),
// //                             const SizedBox(width: 8),
// //                             Text(
// //                               "${dashboard.days()} days",
// //                               style: const TextStyle(
// //                                 fontSize: 12,
// //                                 fontWeight: FontWeight.bold,
// //                                 color: Color(0xff666666),
// //                               ),
// //                             ),
// //                           ],
// //                         );
// //                       },
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ],
// //       ),
// //
// //       const Spacer(),
// //       // ---------- CENTER FILTER ----------
// //       Column(
// //         crossAxisAlignment: CrossAxisAlignment.end,
// //         children: [
// //           Container(
// //             padding: const EdgeInsets.all(6),
// //             decoration: _filterGroupDecoration(),
// //             child: Row(
// //               children: filters.map(_filterChip).toList(),
// //             ),
// //           ),
// //           const SizedBox(height: 4),
// //           const Text(
// //             "version 0.0.7",
// //             style: TextStyle(fontSize: 11, color: Colors.blue),
// //           ),
// //         ],
// //       ),
// //       const Spacer(),
// //
// //       // ---------- RIGHT ----------
// //       Row(
// //         children: [
// //           Column(
// //             crossAxisAlignment: CrossAxisAlignment.end,
// //             children: [
// //               const Text(
// //                 "Hi, Gopal",
// //                 style: TextStyle(
// //                   fontSize: 13,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //               ),
// //               const SizedBox(height: 2),
// //               Row(
// //                 children: [
// //                   const Text(
// //                     "Last Sync · 02-01-2026",
// //                     style: TextStyle(
// //                       fontSize: 11,
// //                       fontWeight: FontWeight.bold,
// //                     ),
// //                   ),
// //                   const SizedBox(width: 4),
// //                   Image.asset(
// //                     "assets/images/sync.png",
// //                     width: 12,
// //                     height: 12,
// //                     color: Colors.black54,
// //                   ),
// //                 ],
// //               ),
// //             ],
// //           ),
// //           const SizedBox(width: 10),
// //           Image.asset(
// //             "assets/images/default_person.png",
// //             width: 50,
// //             height: 50,
// //           ),
// //         ],
// //       ),
// //     ],
// //   ),
// // ),
// // SingleChildScrollView(
// //   scrollDirection: Axis.horizontal,
// //   child: Row(
// //     crossAxisAlignment: CrossAxisAlignment.start,
// //     children: [
// //       // -------- Lead Distribution --------
// //       SizedBox(
// //         width: 420,
// //         height: 350,
// //         child: PieStatCard(
// //           title: "Lead Distribution",
// //           subtitle: "Breakdown by current stage",
// //           total: 2360,
// //           values: const [
// //             PieStatValue(
// //               label: "Suspect",
// //               value: 40,
// //               color: Color(0xffF59E0B),
// //             ),
// //             PieStatValue(
// //               label: "Prospect",
// //               value: 25,
// //               color: Color(0xff3B82F6),
// //             ),
// //             PieStatValue(
// //               label: "Qualified",
// //               value: 20,
// //               color: Color(0xff8B5CF6),
// //             ),
// //             PieStatValue(
// //               label: "Customers",
// //               value: 10,
// //               color: Color(0xff10B981),
// //             ),
// //             PieStatValue(
// //               label: "Disqualified",
// //               value: 5,
// //               color: Color(0xffEF4444),
// //             ),
// //           ],
// //         ),
// //       ),
// //       const SizedBox(width: 16),
// //       SizedBox(
// //         width: 420,
// //         child: Container(
// //           height: 250,
// //           padding: const EdgeInsets.all(16),
// //           decoration: BoxDecoration(
// //             color: Colors.white,
// //             borderRadius: BorderRadius.circular(12),
// //             boxShadow: const [
// //               BoxShadow(
// //                 color: Color(0x14000000),
// //                 blurRadius: 10,
// //                 offset: Offset(0, 4),
// //               ),
// //             ],
// //           ),
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //
// //               // -------- TITLE --------
// //               const Text(
// //                 "Activity Rating",
// //                 style: TextStyle(
// //                   fontWeight: FontWeight.bold,
// //                   fontSize: 14,
// //                   color: Colors.black,
// //                 ),
// //               ),
// //
// //               const SizedBox(height: 4),
// //
// //               // -------- SUBTITLE --------
// //               const Text(
// //                 "Customer Engagement Levels",
// //                 style: TextStyle(
// //                   fontSize: 12,
// //                   color: Color(0xff6B7280),
// //                 ),
// //               ),
// //
// //               const SizedBox(height: 10),
// //
// //               // -------- DIVIDER --------
// //               const Divider(
// //                 height: 1,
// //                 thickness: 1,
// //                 color: Color(0xffD1D5DB),
// //               ),
// //
// //               const SizedBox(height: 18),
// //
// //               // -------- RATING BAR (INLINE) --------
// //               ClipRRect(
// //                 borderRadius: BorderRadius.circular(10),
// //                 child: Row(
// //                   children: [
// //                     Expanded(
// //                       flex: 35,
// //                       child: Container(
// //                         height: 22,
// //                         color: const Color(0xffEF4444),
// //                       ),
// //                     ),
// //                     Expanded(
// //                       flex: 40,
// //                       child: Container(
// //                         height: 22,
// //                         color: const Color(0xffF59E0B),
// //                       ),
// //                     ),
// //                     Expanded(
// //                       flex: 25,
// //                       child: Container(
// //                         height: 22,
// //                         color: const Color(0xff3B82F6),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //
// //               const SizedBox(height: 12),
// //               Row(
// //                 children: [
// //
// //                   // Hot
// //                   Row(
// //                     mainAxisSize: MainAxisSize.min,
// //                     children: const [
// //                       SizedBox(
// //                         width: 8,
// //                         height: 8,
// //                         child: DecoratedBox(
// //                           decoration: BoxDecoration(
// //                             color: Color(0xffEF4444),
// //                             shape: BoxShape.circle,
// //                           ),
// //                         ),
// //                       ),
// //                       SizedBox(width: 6),
// //                       Text(
// //                         "Hot (0-30d)",
// //                         style: TextStyle(
// //                           fontSize: 11,
// //                           color: Color(0xffEF4444),
// //                           fontWeight: FontWeight.w500,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //
// //                   const SizedBox(width: 16),
// //
// //                   // Warm
// //                   Row(
// //                     mainAxisSize: MainAxisSize.min,
// //                     children: const [
// //                       SizedBox(
// //                         width: 8,
// //                         height: 8,
// //                         child: DecoratedBox(
// //                           decoration: BoxDecoration(
// //                             color: Color(0xffF59E0B),
// //                             shape: BoxShape.circle,
// //                           ),
// //                         ),
// //                       ),
// //                       SizedBox(width: 6),
// //                       Text(
// //                         "Warm (31-60d)",
// //                         style: TextStyle(
// //                           fontSize: 11,
// //                           color: Color(0xffF59E0B),
// //                           fontWeight: FontWeight.w500,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //
// //                   const SizedBox(width: 16),
// //
// //                   // Cold
// //                   Row(
// //                     mainAxisSize: MainAxisSize.min,
// //                     children: const [
// //                       SizedBox(
// //                         width: 8,
// //                         height: 8,
// //                         child: DecoratedBox(
// //                           decoration: BoxDecoration(
// //                             color: Color(0xff3B82F6),
// //                             shape: BoxShape.circle,
// //                           ),
// //                         ),
// //                       ),
// //                       SizedBox(width: 6),
// //                       Text(
// //                         "Cold (61+d)",
// //                         style: TextStyle(
// //                           fontSize: 11,
// //                           color: Color(0xff3B82F6),
// //                           fontWeight: FontWeight.w500,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ],
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //       const SizedBox(width: 16),
// //       SizedBox(
// //         width: 370,
// //         child: Container(
// //           height: 250,
// //           padding: const EdgeInsets.all(16),
// //           decoration: BoxDecoration(
// //             color: Colors.white,
// //             borderRadius: BorderRadius.circular(12),
// //             boxShadow: const [
// //               BoxShadow(
// //                 color: Color(0x14000000),
// //                 blurRadius: 10,
// //                 offset: Offset(0, 4),
// //               ),
// //             ],
// //           ),
// //           child: Stack(
// //             clipBehavior: Clip.none,
// //             alignment: Alignment.center,
// //             children: [
// //
// //               // -------- MAIN CONTENT --------
// //               Column(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: [
// //                   Stack(
// //                     clipBehavior: Clip.none,
// //                     alignment: Alignment.center,
// //                     children: [
// //
// //                       // Main outlined circle
// //                       Container(
// //                         width: 110,
// //                         height: 110,
// //                         alignment: Alignment.center,
// //                         decoration: BoxDecoration(
// //                           shape: BoxShape.circle,
// //                           border: Border.all(
// //                             color: Colors.black,
// //                             width: 2,
// //                           ),
// //                         ),
// //                         child: const Text(
// //                           "42",
// //                           style: TextStyle(
// //                             fontSize: 26,
// //                             fontWeight: FontWeight.bold,
// //                           ),
// //                         ),
// //                       ),
// //
// //                       // Small top dot
// //                       const Positioned(
// //                         top: -6,
// //                         child: CircleAvatar(
// //                           radius: 5,
// //                           backgroundColor: Colors.black,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //
// //                   const SizedBox(height: 16),
// //
// //                   const Text(
// //                     "Quotations Sent",
// //                     style: TextStyle(
// //                       fontSize: 13,
// //                       fontWeight: FontWeight.w600,
// //                       color: Colors.black87,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //
// //               // -------- FILE ICON (OVERLAP) --------
// //               Positioned(
// //                 top: 10,
// //                 left: 10,
// //                 child: Image.asset(
// //                   "assets/images/file.png",
// //                   width: 50,
// //                   height: 50,
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //
// //     ],
// //   ),
// // ),
// // const SizedBox(height: 20),
// // Row(
// //   crossAxisAlignment: CrossAxisAlignment.start,
// //   children: [
// //
// //     // ================= CUSTOMER STATUS =================
// //     SizedBox(
// //       width: 420,
// //       child: Container(
// //         height: 300,
// //         padding: const EdgeInsets.all(16),
// //         decoration: BoxDecoration(
// //           color: Colors.white,
// //           borderRadius: BorderRadius.circular(12),
// //           boxShadow: const [
// //             BoxShadow(
// //               color: Color(0x14000000),
// //               blurRadius: 10,
// //               offset: Offset(0, 4),
// //             ),
// //           ],
// //         ),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //
// //             // Title
// //             const Text(
// //               "Customer Status",
// //               style: TextStyle(
// //                 fontWeight: FontWeight.bold,
// //                 fontSize: 14,
// //               ),
// //             ),
// //
// //             const SizedBox(height: 4),
// //
// //             // Subtitle
// //             const Text(
// //               "Breakdown by engagement status",
// //               style: TextStyle(
// //                 fontSize: 12,
// //                 color: Colors.black54,
// //               ),
// //             ),
// //
// //             const SizedBox(height: 12),
// //
// //             // Divider
// //             const Divider(
// //               height: 1,
// //               thickness: 1,
// //               color: Color(0xffE5E7EB),
// //             ),
// //
// //             const SizedBox(height: 16),
// //
// //             // Status rows
// //             _statusRow(
// //                 "Contacted", 0.85, const Color(0xff6366F1)),
// //             const SizedBox(height: 14),
// //
// //             _statusRow(
// //                 "Call Back", 0.65, const Color(0xff3B82F6)),
// //             const SizedBox(height: 14),
// //
// //             _statusRow("Demo\nScheduled", 0.55,
// //                 const Color(0xff6366F1)),
// //             const SizedBox(height: 14),
// //
// //             _statusRow("Not\nInterested", 0.25,
// //                 const Color(0xff3B82F6)),
// //           ],
// //         ),
// //       ),
// //     ),
// //
// //     const SizedBox(width: 16),
// //
// //     // ================= ACTIVITY OVER TIME =================
// //     Expanded(
// //       child: Container(
// //         height: 340,
// //         decoration: BoxDecoration(
// //           color: Colors.white,
// //           borderRadius: BorderRadius.circular(12),
// //           boxShadow: const [
// //             BoxShadow(
// //               color: Color(0x14000000),
// //               blurRadius: 10,
// //               offset: Offset(0, 4),
// //             ),
// //           ],
// //         ),
// //         child: Column(
// //           children: [
// //
// //             // ================= HEADER (FIGMA STYLE) =================
// //             Padding(
// //               padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: const [
// //                   Text(
// //                     "Activity over time",
// //                     style: TextStyle(
// //                       fontWeight: FontWeight.bold,
// //                       fontSize: 14,
// //                     ),
// //                   ),
// //                   SizedBox(height: 4),
// //                   Text(
// //                     "Calls, mails, and customer updates",
// //                     style: TextStyle(
// //                       fontSize: 12,
// //                       color: Colors.black54,
// //                     ),
// //                   ),
// //                   SizedBox(height: 12),
// //                   Divider(
// //                     height: 1,
// //                     thickness: 1,
// //                     color: Color(0xffE5E7EB),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //
// //             // ================= CHART AREA =================
// //             Expanded(
// //               child: Padding(
// //                 padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
// //                 child: LineChart(
// //                   LineChartData(
// //                     minY: 0,
// //                     maxY: 80,
// //                     borderData: FlBorderData(show: false),
// //
// //                     gridData: FlGridData(
// //                       show: true,
// //                       drawVerticalLine: false,
// //                       horizontalInterval: 20,
// //                       getDrawingHorizontalLine: (value) => FlLine(
// //                         color: const Color(0xffE5E7EB),
// //                         strokeWidth: 1,
// //                         dashArray: [4, 4],
// //                       ),
// //                     ),
// //
// //                     titlesData: FlTitlesData(
// //                       topTitles: AxisTitles(
// //                         sideTitles: SideTitles(showTitles: false),
// //                       ),
// //                       rightTitles: AxisTitles(
// //                         sideTitles: SideTitles(showTitles: false),
// //                       ),
// //                       leftTitles: AxisTitles(
// //                         sideTitles: SideTitles(
// //                           showTitles: true,
// //                           interval: 20,
// //                           reservedSize: 28,
// //                           getTitlesWidget: (value, meta) => Text(
// //                             value.toInt().toString(),
// //                             style: const TextStyle(
// //                               fontSize: 10,
// //                               color: Colors.black54,
// //                             ),
// //                           ),
// //                         ),
// //                       ),
// //                       bottomTitles: AxisTitles(
// //                         sideTitles: SideTitles(
// //                           showTitles: true,
// //                           interval: 1,
// //                           getTitlesWidget: (value, meta) {
// //                             final labels = [
// //                               "Jan21","Jan22","Jan23","Jan24","Jan25","Jan26",
// //                               "Jan27","Jan28","Jan29","Jan30","Jan31",
// //                               "Feb1","Feb2","Feb3","Feb4","Feb5","Feb6",
// //                             ];
// //                             if (value.toInt() < 0 ||
// //                                 value.toInt() >= labels.length) {
// //                               return const SizedBox.shrink();
// //                             }
// //                             return Padding(
// //                               padding: const EdgeInsets.only(top: 8),
// //                               child: Text(
// //                                 labels[value.toInt()],
// //                                 style: const TextStyle(
// //                                   fontSize: 10,
// //                                   color: Colors.black54,
// //                                 ),
// //                               ),
// //                             );
// //                           },
// //                         ),
// //                       ),
// //                     ),
// //
// //                     lineBarsData: [
// //                       _activityLine(
// //                         const Color(0xff2563EB),
// //                         [50,65,30,36,26,68,60,52,42,33,40,50,68,34,50,48,46],
// //                       ),
// //                       _activityLine(
// //                         const Color(0xff7C3AED),
// //                         [8,5,15,14,20,6,18,14,10,16,14,22,8,16,10,8,18],
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     ),
// //
// //   ],
// // ),

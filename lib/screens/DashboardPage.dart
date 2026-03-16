import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fullcomm_crm/controller/product_controller.dart';
import 'package:fullcomm_crm/screens/settings/lead_categories.dart';
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
import '../common/styles/decoration.dart';
import '../common/utilities/utils.dart';
import '../components/activity_over_time_chart.dart';
import '../components/activityratingbar.dart';
import '../components/custom_rating.dart';
import '../components/custom_sidebar.dart';
import '../components/custom_text.dart';
import '../components/customer_status_card.dart';
import '../components/keyboard_search.dart';
import '../components/pie_stat_card.dart';
import '../components/wave_stat_card.dart';
import '../controller/controller.dart';
import '../controller/reminder_controller.dart';
import '../controller/table_controller.dart';
import '../models/all_customers_obj.dart';
import '../provider/dashboard_provider.dart';
import '../provider/employee_provider.dart';
import '../services/api_services.dart';
import 'dart:html' as html;
import 'employee/employee_screen.dart';
import 'leads/new_lead_page.dart';

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
  String formatFirstDate(String input) {
    try {
      List<String> parts = input.split("||").map((e) => e.trim()).toList();
      String datePart = parts.isNotEmpty ? parts.first : "";
      String? timePart;
      if (parts.length >= 2) {
        for (String p in parts.reversed) {
          if (p.contains(':') ||
              p.toLowerCase().contains('am') ||
              p.toLowerCase().contains('pm')) {
            timePart = p;
            break;
          }
        }
      }
      datePart = datePart.replaceAll('.', '-');
      String combined = timePart != null && timePart.isNotEmpty
          ? "$datePart $timePart"
          : datePart;
      DateTime parsedDate;
      if (combined.contains(':') ||
          combined.toLowerCase().contains('am') ||
          combined.toLowerCase().contains('pm')) {
        parsedDate = DateFormat("dd-MM-yyyy h:mm a").parse(combined);
        return DateFormat("dd-MM-yyyy h:mm a").format(parsedDate);
      } else {
        parsedDate = DateFormat("dd-MM-yyyy").parse(combined);
        return DateFormat("dd-MM-yyyy").format(parsedDate);
      }
    } catch (e) {
      print("Error parsing: $e");
      return "";
    }
  }
  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    dashController.getToken();
    apiService.getHeading();
    Timer.periodic(const Duration(seconds: 30), (timer) {
      dashController.refreshTime.value++;
    });
    if(controllers.leadCategoryList.isEmpty){
      apiService.getLeadCategories();
    }
    if(controllers.allLeadList.isEmpty){
      apiService.getCustomLeads();
    }
    apiService.getAllLeadCategories();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      final employeeData = Provider.of<EmployeeProvider>(context, listen: false);
      employeeData.staffRoleDetailsData(context: context);
      controllers.getCallStatus();
      controllers.getRangeStatus();
      controllers.getIndustries();
      productCtr.getProducts();
    });

    Future.delayed(Duration.zero, () async {
      apiService.currentVersion();
      controllers.selectedIndex.value = 100;
      final prefs = await SharedPreferences.getInstance();
      controllers.isAdmin.value = prefs.getBool("isAdmin") ?? false;
      DateTime now = DateTime.now();
      // dashController.selectedSortBy.value = "Today";
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
      dashController.getCustomerStatus();
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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenWidth < 900 ? 120 : 100),
        child: Container(
          width: controllers.isLeftOpen.value == false &&
              controllers.isRightOpen.value == false
              ? screenWidth - 100
              : screenWidth - 150,
          height: 90,
          alignment: Alignment.topLeft,
          // color: Colors.pinkAccent,
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
          decoration: _topBarDecoration(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// ---------- LEFT ----------
              Row(
                children: [
                  Tooltip(
                    message: "Click to close the side panel.",
                    child: InkWell(
                      child:Image.asset(DashboardAssets.menu,width:60,height:60),
                      onTap: () {
                        controllers.isLeftOpen.value = !controllers.isLeftOpen.value;
                      },
                    ),
                  ),10.width,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomText(
                        text:"ARUU's EasyCRM",size:18,isBold: true,isCopy: false,colors:Colors.white
                      ),5.height,
                      InkWell(
                        onTap: () {
                          dashController.showDatePickerDialog(context);
                        },
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_today_outlined,color:Colors.white,size: 15,),
                            6.width,
                            Obx(() {
                              final range = dashController
                                  .selectedRange.value;
                              if (range == null) {
                                return const Text(
                                  "Filter by Date Range",
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontFamily: "Lato"),
                                );
                              }
                              return CustomText(
                                text:range.start == range.end
                                    ? "${range.start.day}-${range.start.month}-${range.start.year}"
                                    : "${range.start.day}-${range.start.month}-${range.start.year} - "
                                    "${range.end.day}-${range.end.month}-${range.end.year}",
                               isBold: true,isCopy: false,colors:Colors.white
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                width: screenWidth/4,
                child: KeyboardDropdownField<AllCustomersObj>(
                  items: controllers.customers,
                  borderRadius: 5,
                  borderColor: Colors.grey.shade300,
                  hintText: "Global Search By Mobile Number",
                  // labelText: "",
                  labelBuilder: (customer) =>
                  // '${customer.firstname}${customer.companyName.toString().isEmpty ? "" : ", ${customer.companyName}"} ${customer.firstname.toString().isEmpty ? "" : "-"} ${customer.mobileNumber}',
                  '${customer.name}${customer.companyName.toString().isEmpty ? "" : ", ${customer.companyName}"} ${customer.name.toString().isEmpty ? "" : "-"} ${customer.phoneNo} - ${customer.category}',
                  itemBuilder: (customer) {
                    return Container(
                      width: screenWidth/2.5,
                      alignment: Alignment.topLeft,
                      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                      child: CustomText(
                        text:
                        '${customer.name}${customer.companyName.toString().isEmpty ? "" : ", ${customer.companyName}"} ${customer.name.toString().isEmpty ? "" : "-"} ${customer.phoneNo} - ${customer.category}',
                        colors: Colors.black,
                        size: 14,
                        isCopy: false,
                        textAlign: TextAlign.start,
                      ),
                    );
                  },
                  textEditingController: controllers.cusController,
                  onSelected: (value) {
                    controllers.search.text = value.name.toString();
                    print("value.leadStatus ${value.leadStatus}");
                    for (var i = 0; i < controllers.leadCategoryList.length; i++) {
                      var item = controllers.leadCategoryList[i];
                      if (item.leadStatus == value.leadStatus) {
                        controllers.selectedIndex.value =
                            int.tryParse(value.leadStatus.toString()) ?? 0;
                        Get.off(
                              () => NewLeadPage(
                            index: item.leadStatus,
                            name: item.value,
                            list: item.list,
                            list2: item.list2,
                            listIndex: i,
                          ),
                          preventDuplicates: false,
                        );
                        break;
                      }
                    }
                  },
                  onClear: () {
                    // if (onSearchChanged != null) onSearchChanged!("");
                    controllers.clearSelectedCustomer();
                  },
                ),
              ),
              /// ---------- CENTER ----------
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Obx(() {
                    return Container(
                      padding: const EdgeInsets.all(6),
                      decoration: _filterGroupDecoration(),
                      child: Row(
                        children: dashController.filters.map((filter) {
                          final bool isSelected =
                              dashController.selectedSortBy.value == filter;

                          return MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                dashController.selectedSortBy.value = filter;
                                DateTime now = DateTime.now();
                                switch (filter) {
                                  // case "Today":
                                  //   dashController.selectedRange
                                  //       .value = DateTimeRange(
                                  //     start: DateTime(now.year,
                                  //         now.month, now.day),
                                  //     end: DateTime(now.year,
                                  //         now.month, now.day),
                                  //   );
                                  //   break;
                                  // case "Yesterday":
                                  //   DateTime yesterday = now
                                  //       .subtract(Duration(days: 1));
                                  //   dashController.selectedRange
                                  //       .value = DateTimeRange(
                                  //     start: DateTime(
                                  //         yesterday.year,
                                  //         yesterday.month,
                                  //         yesterday.day),
                                  //     end: DateTime(now.year,
                                  //         now.month, now.day),
                                  //   );
                                  //   break;
                                  // case "Last 7 Days":
                                  //   dashController.selectedRange
                                  //       .value = DateTimeRange(
                                  //     start: now.subtract(
                                  //         Duration(days: 6)),
                                  //     end: now,
                                  //   );
                                  //   break;
                                  // case "Last 30 Days":
                                  //   dashController.selectedRange
                                  //       .value = DateTimeRange(
                                  //     start: now.subtract(
                                  //         Duration(days: 30)),
                                  //     end: now,
                                  //   );
                                  //   break;
                                  case "Today":
                                    dashController.date1.value =
                                    "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
                                    dashController.date2.value = dashController.date1.value;
                                    break;

                                  case "Yesterday":
                                    DateTime yesterday = now.subtract(const Duration(days: 1));

                                    dashController.date1.value =
                                    "${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}";
                                    dashController.date2.value = dashController.date1.value;
                                    break;

                                  case "Last 7 Days":
                                    DateTime start7 = now.subtract(const Duration(days: 6));

                                    dashController.date1.value =
                                    "${start7.year}-${start7.month.toString().padLeft(2, '0')}-${start7.day.toString().padLeft(2, '0')}";
                                    dashController.date2.value =
                                    "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
                                    break;

                                  case "Last 30 Days":
                                    DateTime start30 = now.subtract(const Duration(days: 29));

                                    dashController.date1.value =
                                    "${start30.year}-${start30.month.toString().padLeft(2, '0')}-${start30.day.toString().padLeft(2, '0')}";
                                    dashController.date2.value =
                                    "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
                                    break;
                                }
                                dashController.getDashboardReport();
                                dashController.getLeadReport();
                                dashController.getStatusWiseReport();
                                dashController.getCustomerStatus();
                                final range = dashController.selectedRange.value;
                                var today = DateTime.now();
                                if (dashController.selectedSortBy.value != "Today" &&
                                    dashController.selectedSortBy.value != "Yesterday") {
                                  dashController.getCustomerReport(
                                      range == null
                                          ? "${today.year}-${today.month.toString().padLeft(2, "0")}-${today.day.toString().padLeft(2, "0")}"
                                          : "${range.start.year}-${range.start.month.toString().padLeft(2, "0")}-${range.start.day.toString().padLeft(2, "0")}",
                                      range == null
                                          ? "${today.year}-${today.month.toString().padLeft(2, "0")}-${today.day.toString().padLeft(2, "0")}"
                                          : "${range.end.year}-${range.end.month.toString().padLeft(2, "0")}-${range.end.day.toString().padLeft(2, "0")}");
                                } else {
                                  var today = "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";
                                  var last7days = DateTime.now().subtract(Duration(days: 7));
                                  dashController.getCustomerReport(
                                      "${last7days.year}-${last7days.month.toString().padLeft(2, '0')}-${last7days.day.toString().padLeft(2, '0')}",
                                      today);
                                }
                                remController.selectedMeetSortBy.value = dashController.selectedSortBy.value;
                                remController.filterAndSortMeetings(
                                  searchText: controllers.searchText.value.toLowerCase(),
                                  callType: controllers.selectMeetingType.value,
                                  sortField: controllers.sortFieldMeetingActivity.value,
                                  sortOrder: controllers.sortOrderMeetingActivity.value,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: isSelected
                                      ? const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ]
                                      : null,
                                ),
                                child: CustomText(
                                  text: filter,
                                  isCopy: false,
                                  size: 12,
                                  isBold: true,
                                  colors: isSelected
                                      ? const Color(0xff0078D7)
                                      : const Color(0xff666666),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }),
                  5.width,
                  CustomText(
                    text: version,
                    size: 11,
                    isCopy: false,
                    colors: Colors.white,
                    isBold: true,
                  ),
                ],
              ),
              /// ---------- RIGHT ----------
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomText(text:"Hi, ${controllers.storage.read("f_name") ?? ""}",isBold:true,isCopy:false,colors:Colors.white,size:14),
                      4.height,
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Obx(() {

                            if (dashController.timestamp.value.isEmpty) {
                              return const CustomText(
                                isCopy: false,
                                text: "Last Sync · --",
                                size: 12.5,
                                isBold: true,
                                colors: Colors.white,
                              );
                            }

                            final diff = DateTime.now()
                                .difference(DateTime.parse(dashController.timestamp.value));

                            String timeText = "";

                            if (diff.inSeconds < 60) {
                              timeText = "Just now";
                            }
                            else if (diff.inMinutes < 60) {
                              timeText = "${diff.inMinutes} mins ago";
                            }
                            else if (diff.inHours < 24) {
                              timeText = "${diff.inHours} hrs ago";
                            }
                            else {
                              timeText = "${diff.inDays} days ago";
                            }

                            return CustomText(
                              text: "Last Sync · $timeText",
                              size: 12.5,
                              isBold: true,
                              isCopy: true,
                              colors: Colors.white,
                            );
                          }),
                          6.height,
                          CircleAvatar(
                            backgroundColor: Colors.white,radius: 8,
                              child: Icon(Icons.sync,color: colorsConst.primary,size: 13,)),
                        ],
                      ),
                    ],
                  ),
                  10.width,
                  Image.asset(DashboardAssets.defaultPerson),
                ],
              ),
            ],
          ),
        ),
      ),
      body: SelectionArea(
        child:
      Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SideBar(),
            Obx(()=>controllers.isCrmData.value==false?Center(child: CircularProgressIndicator()):
            Container(
              width: controllers.isLeftOpen.value == false &&
                  controllers.isRightOpen.value == false
                  ? screenWidth - 150
                  : screenWidth - 150,
              height: MediaQuery.of(context).size.height,
              alignment: Alignment.topLeft,
              // color: Colors.pinkAccent,
              padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
              child: Stack(
                  children: [
                    SingleChildScrollView(
                      child: Obx(()=>Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          20.height,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [1.width,
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
                              ),SizedBox(width: screenWidth/75,),
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
                              ),SizedBox(width: screenWidth/75,),
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
                              ),SizedBox(width: screenWidth/75,),
                              WaveStatCard(
                                callback: () {
                                  controllers.isLeadsExpanded.value=true;
                                  setState(() {
                                    controllers.selectedIndex.value =int.parse(controllers.leadCategoryList[0].leadStatus);
                                  });
                                  print(controllers.selectedIndex.value);
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation1, animation2) => NewLeadPage(index: controllers.leadCategoryList[0].leadStatus,
                                        name: controllers.leadCategoryList[0].value,list: controllers.leadCategoryList[0].list,
                                        list2: controllers.leadCategoryList[0].list2, listIndex: 0,),
                                      transitionDuration: Duration.zero,
                                      reverseTransitionDuration: Duration.zero,
                                    ),
                                  );
                                  controllers.oldIndex.value = controllers.selectedIndex.value;
                                  controllers.selectedIndex.value = 100;
                                },
                                title: "Leads",
                                numericValue: int.parse(dashController.totalSuspects.value.toString()),
                                maxValue: maxValue,
                                iconPath: DashboardAssets.people,
                                valueColor: const Color(0xffF29D38),
                              ),SizedBox(width: screenWidth/75,),
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
                              SizedBox(
                                width: screenWidth/7.5,
                              )
                            ],
                          ),
                          CustomerActivityCard(),
                          20.height,
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: screenWidth / 4,
                                // height: 350,
                                child: LeadPieCard(
                                  // title: "Lead Distribution",
                                  // subtitle: "Breakdown by current stage",
                                  // total: controllers.allLeadList.length,
                                    data: [
                                      for (int i = 0; i < dashController.leadReport.length; i++)
                                        if ((double.tryParse(
                                            dashController.leadReport[i]["customer_count"].toString()) ??
                                            0) >
                                            0)
                                          PieData(
                                            label: dashController.leadReport[i]["category"] ?? "",
                                            value: double.tryParse(
                                                dashController.leadReport[i]["customer_count"].toString()) ??
                                                0,
                                            color: dashController.color[i],
                                          ),
                                    ]
                                ),
                              ),

                              // 10.width,
                              // ================= RIGHT COLUMN =================
                              Container(
                                height: 300,
                                width: screenWidth /5,
                                padding: const EdgeInsets.all(16),
                                decoration: _whiteCard(),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    // -------- TITLE --------
                                    CustomText(
                                      text: "Active Status",
                                      isCopy: false,
                                      size: 15,
                                      isBold: true,
                                    ),
                                    4.height,
                                    // -------- SUBTITLE --------
                                    CustomText(
                                      text: "Customer Engagement Levels",
                                      isCopy: false,
                                      size: 13,
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
                                              // text: "Hot ${dashController.totalHot.value=="0"?"0":"(0-${(int.tryParse(dashController.totalHot.value) ??0)}d)"}",
                                              text: "Hot ${dashController.totalHot.value=="0"?"0":dashController.totalHot.value}",
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
                                              text: "Warm ${dashController.totalWarm.value=="0"?"0":"(${(int.tryParse(dashController.totalHot.value) ??0)+1}-${int.tryParse(
                                                  dashController.totalWarm.value) ??0}d)"}",
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
                                              text: "Cold ${dashController.totalWarm.value=="0"?"0":"(${(int.tryParse(dashController.totalWarm.value) ??0)+1}+d)"}",
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
                              // 15.width,
                              // -------- Call Status --------
                              InkWell(
                                onTap: (){
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
                                },
                                child: SizedBox(
                                  width: screenWidth/3.5,
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
                                ),
                              ),
                              SizedBox(
                                width: screenWidth/9,
                              )
                            ],
                          ),
                          20.height,
                          // -------- Activity Over Time () --------
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  Container(
                                    color: Colors.white,
                                    width: screenWidth /4.5,
                                    child: Table(
                                      columnWidths: {
                                        0: FixedColumnWidth(130),
                                        1: FixedColumnWidth(130),
                                        2: FixedColumnWidth(150),
                                      },
                                      border: TableBorder(
                                        horizontalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                                        verticalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                                      ),
                                      children: [
                                        TableRow(
                                            decoration: BoxDecoration(
                                                color: colorsConst.primary,
                                                borderRadius: const BorderRadius.only(
                                                    topLeft: Radius.circular(5),
                                                    topRight: Radius.circular(5))),
                                            children: [
                                              headerCell(2, Row(
                                                children: [
                                                  CustomText(//1
                                                    textAlign: TextAlign.left,
                                                    text: "Customer Name",
                                                    size: 12,
                                                    isBold: true,
                                                    isCopy: true,
                                                    colors: Colors.white,
                                                  ),
                                                  const SizedBox(width: 3),
                                                  GestureDetector(
                                                    onTap: (){
                                                      if(controllers.sortFieldMeetingActivity.value=='customerName' && controllers.sortOrderMeetingActivity.value=='asc'){
                                                        controllers.sortOrderMeetingActivity.value='desc';
                                                      }else{
                                                        controllers.sortOrderMeetingActivity.value='asc';
                                                      }
                                                      controllers.sortFieldMeetingActivity.value='customerName';
                                                      remController.filterAndSortMeetings(
                                                        searchText: controllers.searchText.value.toLowerCase(),
                                                        callType: controllers.selectMeetingType.value,
                                                        sortField: controllers.sortFieldMeetingActivity.value,
                                                        sortOrder: controllers.sortOrderMeetingActivity.value,
                                                      );
                                                    },
                                                    child: Obx(() => Image.asset(
                                                      controllers.sortFieldMeetingActivity.value.isEmpty
                                                          ? "assets/images/arrow.png"
                                                          : controllers.sortOrderMeetingActivity.value == 'asc'
                                                          ? "assets/images/arrow_up.png"
                                                          : "assets/images/arrow_down.png",
                                                      width: 15,
                                                      height: 15,
                                                    ),
                                                    ),
                                                  ),
                                                ],
                                              ),),
                                              headerCell(3, Row(
                                                children: [
                                                  CustomText(//2
                                                    textAlign: TextAlign.left,
                                                    text: "Company name",
                                                    isCopy: true,
                                                    size: 12,
                                                    isBold: true,
                                                    colors: Colors.white,
                                                  ),
                                                  const SizedBox(width: 3),
                                                  GestureDetector(
                                                    onTap: (){
                                                      if(controllers.sortFieldMeetingActivity.value=='companyName' && controllers.sortOrderMeetingActivity.value=='asc'){
                                                        controllers.sortOrderMeetingActivity.value='desc';
                                                      }else{
                                                        controllers.sortOrderMeetingActivity.value='asc';
                                                      }
                                                      controllers.sortFieldMeetingActivity.value='companyName';
                                                      remController.filterAndSortMeetings(
                                                        searchText: controllers.searchText.value.toLowerCase(),
                                                        callType: controllers.selectMeetingType.value,
                                                        sortField: controllers.sortFieldMeetingActivity.value,
                                                        sortOrder: controllers.sortOrderMeetingActivity.value,
                                                      );
                                                    },
                                                    child: Obx(() => Image.asset(
                                                      controllers.sortFieldMeetingActivity.value.isEmpty
                                                          ? "assets/images/arrow.png"
                                                          : controllers.sortOrderMeetingActivity.value == 'asc'
                                                          ? "assets/images/arrow_up.png"
                                                          : "assets/images/arrow_down.png",
                                                      width: 15,
                                                      height: 15,
                                                    ),
                                                    ),
                                                  ),
                                                ],
                                              ),),
                                              headerCell(7, Row(
                                                children: [
                                                  CustomText(
                                                    textAlign: TextAlign.center,
                                                    text: "Date",
                                                    isCopy: true,
                                                    size: 12,
                                                    isBold: true,
                                                    colors: Colors.white,
                                                  ),
                                                  const SizedBox(width: 3),
                                                  GestureDetector(
                                                    onTap: (){
                                                      if(controllers.sortFieldMeetingActivity.value=='date' && controllers.sortOrderMeetingActivity.value=='asc'){
                                                        controllers.sortOrderMeetingActivity.value='desc';
                                                      }else{
                                                        controllers.sortOrderMeetingActivity.value='asc';
                                                      }
                                                      controllers.sortFieldMeetingActivity.value='date';
                                                      remController.filterAndSortMeetings(
                                                        searchText: controllers.searchText.value.toLowerCase(),
                                                        callType: controllers.selectMeetingType.value,
                                                        sortField: controllers.sortFieldMeetingActivity.value,
                                                        sortOrder: controllers.sortOrderMeetingActivity.value,
                                                      );
                                                    },
                                                    child: Obx(() => Image.asset(
                                                      controllers.sortFieldMeetingActivity.value.isEmpty
                                                          ? "assets/images/arrow.png"
                                                          : controllers.sortOrderMeetingActivity.value == 'asc'
                                                          ? "assets/images/arrow_up.png"
                                                          : "assets/images/arrow_down.png",
                                                      width: 15,
                                                      height: 15,
                                                    ),
                                                    ),
                                                  ),
                                                ],
                                              ),)
                                            ]),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    color: Colors.white,
                                    width: screenWidth /4.5,
                                    child: remController.meetingFilteredList.isEmpty?
                                    CustomText(
                                      text: "\n\n\nNo Appointments\n\n\n",
                                      isCopy: true,
                                      colors: colorsConst.textColor,
                                      size: 16,)
                                        :RawKeyboardListener(
                                      focusNode: _focusNode,
                                      autofocus: true,
                                      child: ListView.builder(
                                        controller: _controller,
                                        shrinkWrap: true,
                                        physics: const ScrollPhysics(),
                                        itemCount: remController.meetingFilteredList.length,
                                        itemBuilder: (context, index) {
                                          final data = remController.meetingFilteredList[index];
                                          return Table(
                                            columnWidths: {
                                              0: FixedColumnWidth(130),
                                              1: FixedColumnWidth(130),
                                              2: FixedColumnWidth(150),
                                            },
                                            border: TableBorder(
                                              horizontalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                                              verticalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                                              // bottom:  BorderSide(width: 0.2, color: Colors.green.shade400),
                                            ),
                                            children:[
                                              TableRow(
                                                  decoration: BoxDecoration(
                                                    color: int.parse(index.toString()) % 2 == 0 ? Colors.white : colorsConst.backgroundColor,
                                                  ),
                                                  children:[
                                                    Tooltip(
                                                      message: data.cusName.toString()=="null"?"":data.cusName.toString(),
                                                      child: Padding(
                                                        padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                                                        child: CustomText(
                                                          textAlign: TextAlign.left,
                                                          text: data.cusName.toString()=="null"?"":data.cusName.toString(),
                                                          size: 12,
                                                          isCopy: true,
                                                          colors:colorsConst.textColor,
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                                                      child: CustomText(
                                                        textAlign: TextAlign.left,
                                                        text:data.comName.toString()=="null"?"":data.comName.toString(),
                                                        size: 12,
                                                        isCopy: true,
                                                        colors: colorsConst.textColor,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                                                      child: CustomText(
                                                        textAlign: TextAlign.left,
                                                        text: formatFirstDate("${data.dates} ${data.time}"),
                                                        size: 12,
                                                        isCopy: true,
                                                        colors: colorsConst.textColor,
                                                      ),
                                                    ),
                                                  ]
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
                              SizedBox(
                                width: screenWidth/9,
                              )
                            ],
                          ),
                          // 20.height,
                          // Row(
                          //   children: [
                          //     Column(
                          //       children: [
                          //         Container(
                          //           color: Colors.white,
                          //           width: screenWidth/1.3,
                          //           child: Table(
                          //             columnWidths: {
                          //               0: FixedColumnWidth(130),
                          //               1: FixedColumnWidth(130),
                          //               2: FixedColumnWidth(150),
                          //             },
                          //             border: TableBorder(
                          //               horizontalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                          //               verticalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                          //             ),
                          //             children: [
                          //               TableRow(
                          //                   decoration: BoxDecoration(
                          //                       color: colorsConst.primary,
                          //                       borderRadius: const BorderRadius.only(
                          //                           topLeft: Radius.circular(5),
                          //                           topRight: Radius.circular(5))),
                          //                   children: [
                          //                     headerCell(2, Row(
                          //                       children: [
                          //                         CustomText(//1
                          //                           textAlign: TextAlign.left,
                          //                           text: "Customer Name",
                          //                           size: 15,
                          //                           isBold: true,
                          //                           isCopy: true,
                          //                           colors: Colors.white,
                          //                         ),
                          //                         const SizedBox(width: 3),
                          //                         GestureDetector(
                          //                           onTap: (){
                          //                             if(controllers.sortFieldMeetingActivity.value=='customerName' && controllers.sortOrderMeetingActivity.value=='asc'){
                          //                               controllers.sortOrderMeetingActivity.value='desc';
                          //                             }else{
                          //                               controllers.sortOrderMeetingActivity.value='asc';
                          //                             }
                          //                             controllers.sortFieldMeetingActivity.value='customerName';
                          //                             remController.filterAndSortMeetings(
                          //                               searchText: controllers.searchText.value.toLowerCase(),
                          //                               callType: controllers.selectMeetingType.value,
                          //                               sortField: controllers.sortFieldMeetingActivity.value,
                          //                               sortOrder: controllers.sortOrderMeetingActivity.value,
                          //                             );
                          //                           },
                          //                           child: Obx(() => Image.asset(
                          //                             controllers.sortFieldMeetingActivity.value.isEmpty
                          //                                 ? "assets/images/arrow.png"
                          //                                 : controllers.sortOrderMeetingActivity.value == 'asc'
                          //                                 ? "assets/images/arrow_up.png"
                          //                                 : "assets/images/arrow_down.png",
                          //                             width: 15,
                          //                             height: 15,
                          //                           ),
                          //                           ),
                          //                         ),
                          //                       ],
                          //                     ),),
                          //                     headerCell(3, Row(
                          //                       children: [
                          //                         CustomText(//2
                          //                           textAlign: TextAlign.left,
                          //                           text: "Company name",
                          //                           isCopy: true,
                          //                           size: 15,
                          //                           isBold: true,
                          //                           colors: Colors.white,
                          //                         ),
                          //                         const SizedBox(width: 3),
                          //                         GestureDetector(
                          //                           onTap: (){
                          //                             if(controllers.sortFieldMeetingActivity.value=='companyName' && controllers.sortOrderMeetingActivity.value=='asc'){
                          //                               controllers.sortOrderMeetingActivity.value='desc';
                          //                             }else{
                          //                               controllers.sortOrderMeetingActivity.value='asc';
                          //                             }
                          //                             controllers.sortFieldMeetingActivity.value='companyName';
                          //                             remController.filterAndSortMeetings(
                          //                               searchText: controllers.searchText.value.toLowerCase(),
                          //                               callType: controllers.selectMeetingType.value,
                          //                               sortField: controllers.sortFieldMeetingActivity.value,
                          //                               sortOrder: controllers.sortOrderMeetingActivity.value,
                          //                             );
                          //                           },
                          //                           child: Obx(() => Image.asset(
                          //                             controllers.sortFieldMeetingActivity.value.isEmpty
                          //                                 ? "assets/images/arrow.png"
                          //                                 : controllers.sortOrderMeetingActivity.value == 'asc'
                          //                                 ? "assets/images/arrow_up.png"
                          //                                 : "assets/images/arrow_down.png",
                          //                             width: 15,
                          //                             height: 15,
                          //                           ),
                          //                           ),
                          //                         ),
                          //                       ],
                          //                     ),),
                          //                     headerCell(7, Row(
                          //                       children: [
                          //                         CustomText(
                          //                           textAlign: TextAlign.center,
                          //                           text: "Date",
                          //                           isCopy: true,
                          //                           size: 15,
                          //                           isBold: true,
                          //                           colors: Colors.white,
                          //                         ),
                          //                         const SizedBox(width: 3),
                          //                         GestureDetector(
                          //                           onTap: (){
                          //                             if(controllers.sortFieldMeetingActivity.value=='date' && controllers.sortOrderMeetingActivity.value=='asc'){
                          //                               controllers.sortOrderMeetingActivity.value='desc';
                          //                             }else{
                          //                               controllers.sortOrderMeetingActivity.value='asc';
                          //                             }
                          //                             controllers.sortFieldMeetingActivity.value='date';
                          //                             remController.filterAndSortMeetings(
                          //                               searchText: controllers.searchText.value.toLowerCase(),
                          //                               callType: controllers.selectMeetingType.value,
                          //                               sortField: controllers.sortFieldMeetingActivity.value,
                          //                               sortOrder: controllers.sortOrderMeetingActivity.value,
                          //                             );
                          //                           },
                          //                           child: Obx(() => Image.asset(
                          //                             controllers.sortFieldMeetingActivity.value.isEmpty
                          //                                 ? "assets/images/arrow.png"
                          //                                 : controllers.sortOrderMeetingActivity.value == 'asc'
                          //                                 ? "assets/images/arrow_up.png"
                          //                                 : "assets/images/arrow_down.png",
                          //                             width: 15,
                          //                             height: 15,
                          //                           ),
                          //                           ),
                          //                         ),
                          //                       ],
                          //                     ),)
                          //                   ]),
                          //             ],
                          //           ),
                          //         ),
                          //         Container(
                          //           color: Colors.white,
                          //           width: screenWidth/1.3,
                          //           child: remController.meetingFilteredList.isEmpty?
                          //           CustomText(
                          //             text: "\n\n\nNo Appointments\n\n\n",
                          //             isCopy: true,
                          //             colors: colorsConst.textColor,
                          //             size: 16,)
                          //               :RawKeyboardListener(
                          //             focusNode: _focusNode,
                          //             autofocus: true,
                          //             child: ListView.builder(
                          //               controller: _controller,
                          //               shrinkWrap: true,
                          //               physics: const ScrollPhysics(),
                          //               itemCount: remController.meetingFilteredList.length,
                          //               itemBuilder: (context, index) {
                          //                 final data = remController.meetingFilteredList[index];
                          //                 return Table(
                          //                   columnWidths: {
                          //                     0: FixedColumnWidth(130),
                          //                     1: FixedColumnWidth(130),
                          //                     2: FixedColumnWidth(150),
                          //                   },
                          //                   border: TableBorder(
                          //                     horizontalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                          //                     verticalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                          //                     // bottom:  BorderSide(width: 0.2, color: Colors.green.shade400),
                          //                   ),
                          //                   children:[
                          //                     TableRow(
                          //                         decoration: BoxDecoration(
                          //                           color: int.parse(index.toString()) % 2 == 0 ? Colors.white : colorsConst.backgroundColor,
                          //                         ),
                          //                         children:[
                          //                           Tooltip(
                          //                             message: data.cusName.toString()=="null"?"":data.cusName.toString(),
                          //                             child: Padding(
                          //                               padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                          //                               child: CustomText(
                          //                                 textAlign: TextAlign.left,
                          //                                 text: data.cusName.toString()=="null"?"":data.cusName.toString(),
                          //                                 size: 15,
                          //                                 isCopy: true,
                          //                                 colors:colorsConst.textColor,
                          //                               ),
                          //                             ),
                          //                           ),
                          //                           Padding(
                          //                             padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                          //                             child: CustomText(
                          //                               textAlign: TextAlign.left,
                          //                               text:data.comName.toString()=="null"?"":data.comName.toString(),
                          //                               size: 15,
                          //                               isCopy: true,
                          //                               colors: colorsConst.textColor,
                          //                             ),
                          //                           ),
                          //                           Padding(
                          //                             padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                          //                             child: CustomText(
                          //                               textAlign: TextAlign.left,
                          //                               text: formatFirstDate("${data.dates} ${data.time}"),
                          //                               size: 15,
                          //                               isCopy: true,
                          //                               colors: colorsConst.textColor,
                          //                             ),
                          //                           ),
                          //                         ]
                          //                     ),
                          //                   ],
                          //                 );
                          //               },
                          //             ),
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //     SizedBox(
                          //       width: screenWidth/9,
                          //     )
                          //   ],
                          // ),
                          20.height,
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
            )),
          ],
        ),
      ),
    );
  }
  List<double> colWidths = [
    50,   // 0 Checkbox
    80,  // 1 Actions
    150,  // 2 Event Name
    150,  // 3 Type
    150,  // 4 Location
    150,  // 5 Employee Name
    150,  // 6 Customer Name
    150,  // 7 Start Date
  ];
  Widget headerCell(int index, Widget child) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          alignment: index==0?Alignment.center:Alignment.centerLeft,
          child: child,
        ),
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          width: 10,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragUpdate: (details) {
              setState(() {
                colWidths[index] += details.delta.dx;
                if (colWidths[index] < 60) colWidths[index] = 60;
              });
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.resizeColumn,
              child: Container(color: Colors.transparent),
            ),
          ),
        ),
      ],
    );
  }
  Widget _leadStagesPanel() {
    return Container(
      width: MediaQuery.of(context).size.width*0.12,
      height: MediaQuery.of(context).size.height - 140,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        // borderRadius: BorderRadius.all(154),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const CustomText(
                        text:"LEAD STAGES",
                        isCopy: false,
                        size: 14,
                        isBold: true,
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isLeadPanelOpen = false;
                          });
                        },
                        child: Image.asset(DashboardAssets.leadStage),
                      ),
                    ],
                  )
                ],
              ),
            ),

            6.height,

            // ================= JOURNEY SWITCH =================
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
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
                  child: CustomText(text:"Life Time Customer Journey",
                    isCopy: false,
                    isBold: true,
                    colors: colorsConst.primary,
                  ),
                ),
              ],
            ),

            20.height,

            // ================= FUNNEL ITEMS =================
            for (int i = 0; i < controllers.leadCategoryList.length; i++)
              _animatedLeadItem(
                index: 0,
                child: _leadItem(
                  title: controllers.leadCategoryList[i].value,
                  image: DashboardAssets.suspect,
                  count: controllers.leadCategoryList[i].list.length.toString(),
                  index: i,
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
    borderRadius: BorderRadius.circular(5),
  );

  BoxDecoration _topBarDecoration() => BoxDecoration(
    color: colorsConst.primary,
    // borderRadius: BorderRadius.circular(10),
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
  required int index,
}) {
  return Column(
    children: [
      Row(
        children: [
          Container(
            height: 55,
            width: 10,
            decoration: BoxDecoration(
              color: controllers.leadColors[index],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
            ),
          ),
          Container(
            height: 55,
            width: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
              border: Border(
                right: BorderSide(
                  color:Colors.grey.shade100,
                  width: 2,
                ),
                top: BorderSide(
                  color:Colors.grey.shade100,
                  width: 2,
                ),
                bottom: BorderSide(
                  color:Colors.grey.shade100,
                  width: 2,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text:  title.toUpperCase(),
                        isCopy: false,
                        size: 11,
                        isBold: true,
                        colors: Colors.black,
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CustomText(
                        text: count,
                        isCopy: false,
                        size: 14,
                        isBold: true,
                        colors: Colors.black,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      if(index!=controllers.leadCategoryList.length-1)
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            height: 20,
            color: Colors.grey.shade400,width: 2,
          ),
          Container(
            height: 10,
            color: Colors.grey.shade300,width: 2,
          )
        ],
      )
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

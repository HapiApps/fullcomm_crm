import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fullcomm_crm/controller/product_controller.dart';
import 'package:fullcomm_crm/screens/quotation/quotation_page.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/controller/dashboard_controller.dart';
import 'package:fullcomm_crm/screens/records/records.dart';
import 'package:fullcomm_crm/screens/reminder/reminder_page.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common/constant/api.dart';
import '../common/constant/colors_constant.dart';
import '../common/constant/dashboard_assets.dart';
import '../common/styles/decoration.dart';
import '../common/utilities/reminder_utils.dart';
import '../common/utilities/utils.dart';
import '../components/activity_over_time_chart.dart';
import '../components/custom_loading_button.dart';
import '../components/custom_sidebar.dart';
import '../components/custom_text.dart';
import '../components/customer_status_card.dart';
import '../components/keyboard_search.dart';
import '../components/pie_stat_card.dart';
import '../components/search_custom_dropdown.dart';
import '../components/wave_stat_card.dart';
import '../controller/controller.dart';
import '../controller/reminder_controller.dart';
import '../models/all_customers_obj.dart';
import '../provider/employee_provider.dart';
import '../services/api_services.dart';
import 'dart:html' as html;
import '../view_models/billing_provider.dart';
import 'leads/new_lead_page.dart';
import 'leads/rating_customer_page.dart';
import 'order/order_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  final ScrollController _controller = ScrollController();
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
    // Timer.periodic(const Duration(seconds: 30), (timer) {
    //   dashController.refreshTime.value++;
    // });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      if(controllers.leadCategoryList.isEmpty){
        apiService.getLeadCategories();
      }
      if(controllers.allLeadList.isEmpty){
        apiService.getCustomLeads();
      }
      if(controllers.allLeadCategoryList.isEmpty){
        apiService.getAllLeadCategories();
      }
      apiService.getAllEmployees();
      if(dashController.customerStatusReport.isEmpty){
        dashController.getCustomerStatus();
      }
      if(Provider.of<BillingProvider>(context, listen: false).productsList.isEmpty){
        Provider.of<BillingProvider>(context, listen: false).getProducts();
      }
      if(productCtr.products.isEmpty){
        productCtr.getProducts();
      }
      final employeeData = Provider.of<EmployeeProvider>(context, listen: false);
      employeeData.staffRoleDetailsData(context: context);
      if(controllers.hCallStatusList.isEmpty){
        controllers.getCallStatus();
      }
      controllers.getRangeStatus();
      controllers.getIndustries();
      // productCtr.getProducts();
      productCtr.getOrderDetails();
      productCtr.getQuotationDetails();
      productCtr.getTermsAndConditions();
      apiService.currentVersion();
      controllers.selectedIndex.value = 100;
      // final prefs = await SharedPreferences.getInstance();
      // controllers.isAdmin.value = prefs.getBool("isAdmin") ?? false;
      DateTime now = DateTime.now();
      // dashController.selectedSortBy.value = "Today";
      // dashController.selectedSortBy.value = controllers.storage.read("selectedSortBy") ?? "Today";
      checkDate();
      remController.selectedMeetSortBy.value=dashController.selectedSortBy.value;
      remController.selectedCallSortBy.value=dashController.selectedSortBy.value;
      remController.selectedReminderSortBy.value=dashController.selectedSortBy.value;
      // controllers.selectedProspectSortBy.value = "Today";
      // controllers.selectedQualifiedSortBy.value = "Today";
      // controllers.selectedCustomerSortBy.value = "Today";
      // remController.selectedMeetSortBy.value = "Today";
      // remController.selectedReminderSortBy.value = "Today";
      remController.dashboardMeetings(
        searchText: controllers.searchText.value.toLowerCase(),
        callType: controllers.selectMeetingType.value,
        sortField: controllers.sortFieldMeetingActivity.value,
        sortOrder: controllers.sortOrderMeetingActivity.value,
      );
      if(remController.reminderList.isEmpty){
        remController.allReminders("2");
      }
      if(remController.callMailsDetailsList.isEmpty){
        apiService.getMailCallActivity();
      }
      remController.dashboardSortReminders();
      remController.dashboardCommunicationFilterList(
        dataList: remController.callMailsDetailsList2,
        searchText: controllers.searchText.value.toLowerCase(),
        callType: controllers.selectCallType.value,
        sortField: controllers.sortFieldCallActivity.value,
        sortOrder: controllers.sortOrderCallActivity.value,
        selectedMonth: remController.selectedCallMonth.value,
        selectedRange: remController.selectedCallRange.value,
        selectedDateFilter: remController.selectedCallSortBy.value,
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
  ///
  // @override
  // void initState() {
  //   super.initState();
  //
  //   _focusNode = FocusNode();
  //
  //   _leadItemController = AnimationController(
  //     vsync: this,
  //     duration: const Duration(milliseconds: 2200),
  //   );
  //
  //   _leadItemAnimations = [
  //     CurvedAnimation(
  //       parent: _leadItemController,
  //       curve: const Interval(0.0, 0.20, curve: Curves.easeOut),
  //     ),
  //     CurvedAnimation(
  //       parent: _leadItemController,
  //       curve: const Interval(0.35, 0.55, curve: Curves.easeOut),
  //     ),
  //     CurvedAnimation(
  //       parent: _leadItemController,
  //       curve: const Interval(0.70, 0.90, curve: Curves.easeOut),
  //     ),
  //     CurvedAnimation(
  //       parent: _leadItemController,
  //       curve: const Interval(0.90, 1.0, curve: Curves.easeOut),
  //     ),
  //   ];
  //
  //   WidgetsBinding.instance.addPostFrameCallback((_) async {
  //     _focusNode.requestFocus();
  //
  //     /// 🔹 SMALL DELAY (avoid UI freeze)
  //     await Future.delayed(const Duration(milliseconds: 100));
  //
  //     /// ===============================
  //     /// 🔥 FIRST PRIORITY (FAST LOAD)
  //     /// ===============================
  //     await Future.wait([
  //       dashController.getToken(),
  //       apiService.getHeading(),
  //       apiService.getAllEmployees(),
  //       dashController.getDashboardReport(),
  //     ]);
  //
  //     /// ===============================
  //     /// 🔥 SECOND PRIORITY
  //     /// ===============================
  //     Future.delayed(const Duration(milliseconds: 5), () {
  //       if (controllers.leadCategoryList.isEmpty) {
  //         apiService.getLeadCategories();
  //       }
  //
  //       if (controllers.allLeadList.isEmpty) {
  //         apiService.getCustomLeads();
  //       }
  //
  //       if (controllers.allLeadCategoryList.isEmpty) {
  //         apiService.getAllLeadCategories();
  //       }
  //
  //       if (dashController.customerStatusReport.isEmpty) {
  //         dashController.getCustomerStatus();
  //       }
  //
  //       if (controllers.hCallStatusList.isEmpty) {
  //         controllers.getCallStatus();
  //       }
  //
  //       controllers.getRangeStatus();
  //       controllers.getIndustries();
  //
  //       final billing =
  //       Provider.of<BillingProvider>(context, listen: false);
  //       if (billing.productsList.isEmpty) {
  //         billing.getProducts();
  //       }
  //
  //       if (productCtr.products.isEmpty) {
  //         productCtr.getProducts();
  //       }
  //
  //       productCtr.getTermsAndConditions();
  //     });
  //
  //     /// ===============================
  //     /// 🔥 THIRD PRIORITY (BACKGROUND)
  //     /// ===============================
  //     Future.delayed(const Duration(seconds: 1), () {
  //       productCtr.getOrderDetails();
  //       productCtr.getQuotationDetails();
  //
  //       dashController.getLeadReport();
  //       dashController.getStatusWiseReport();
  //       dashController.getRatingReport();
  //
  //       apiService.currentVersion();
  //     });
  //
  //     /// ===============================
  //     /// 🔥 DATE & FILTER SETUP
  //     /// ===============================
  //     DateTime now = DateTime.now();
  //     controllers.selectedIndex.value = 100;
  //
  //     checkDate();
  //
  //     remController.selectedMeetSortBy.value =
  //         dashController.selectedSortBy.value;
  //     remController.selectedCallSortBy.value =
  //         dashController.selectedSortBy.value;
  //     remController.selectedReminderSortBy.value =
  //         dashController.selectedSortBy.value;
  //
  //     /// 🔹 Meetings
  //     remController.dashboardMeetings(
  //       searchText: controllers.searchText.value.toLowerCase(),
  //       callType: controllers.selectMeetingType.value,
  //       sortField: controllers.sortFieldMeetingActivity.value,
  //       sortOrder: controllers.sortOrderMeetingActivity.value,
  //     );
  //
  //     /// 🔹 Reminder
  //     if (remController.reminderList.isEmpty) {
  //       remController.allReminders("2");
  //     }
  //
  //     /// 🔹 Call / Mail
  //     if (remController.callMailsDetailsList.isEmpty) {
  //       apiService.getMailCallActivity();
  //     }
  //
  //     /// 🔹 Delay filter (IMPORTANT 🔥)
  //     Future.delayed(const Duration(milliseconds: 500), () {
  //       remController.dashboardSortReminders();
  //       remController.dashboardCommunicationFilterList(
  //         dataList: remController.callMailsDetailsList2,
  //         searchText: controllers.searchText.value.toLowerCase(),
  //         callType: controllers.selectCallType.value,
  //         sortField: controllers.sortFieldCallActivity.value,
  //         sortOrder: controllers.sortOrderCallActivity.value,
  //         selectedMonth: remController.selectedCallMonth.value,
  //         selectedRange: remController.selectedCallRange.value,
  //         selectedDateFilter:
  //         remController.selectedCallSortBy.value,
  //       );
  //     });
  //
  //     /// 🔹 Reports (Last 7 Days)
  //     String today =
  //         "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  //
  //     var last7days = now.subtract(const Duration(days: 7));
  //
  //     dashController.getCustomerReport(
  //       "${last7days.year}-${last7days.month.toString().padLeft(2, '0')}-${last7days.day.toString().padLeft(2, '0')}",
  //       today,
  //     );
  //   });
  // }
void checkDate(){
  DateTime now = DateTime.now();
  switch (dashController.selectedSortBy.value) {
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
  dashController.selectedRange.value = DateTimeRange(
    start: DateTime.parse(dashController.date1.value),
    end: DateTime.parse(dashController.date2.value),
  );
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

  late AnimationController _leadItemController;
  late List<Animation<double>> _leadItemAnimations;
  int? hoveredIndex;

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
  int hoverIndex = -1;
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    // final width = MediaQuery.of(context).size.width;
    // final isMobile = width < 768;
    // final isTablet = width >= 768 && width < 1100;
    // final isDesktop = width >= 1100;
    // final dashboard = context.watch<DashboardProvider>();
    // debugPrint("dashController.selectedCallSortBy.value ${dashController.selectedSortBy.value}");
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
                      CustomText(text:"Hi, ${controllers.storage.read("f_name") ?? ""}",isBold:true,isCopy:false,colors:Colors.white,size:14),
                    ],
                  ),
                ],
              ),
              SizedBox(
                width: screenWidth/4,
                // child: KeyboardDropdownField<AllCustomersObj>(
                //   items: controllers.customers,
                //   borderRadius: 5,
                //   borderColor: Colors.grey.shade300,
                //   hintText: "Global Search By Mobile Number",
                //   // labelText: "",
                //   labelBuilder: (customer) =>
                //   // '${customer.firstname}${customer.companyName.toString().isEmpty ? "" : ", ${customer.companyName}"} ${customer.firstname.toString().isEmpty ? "" : "-"} ${customer.mobileNumber}',
                //   '${customer.name}${customer.companyName.toString().isEmpty ? "" : ", ${customer.companyName}"} ${customer.name.toString().isEmpty ? "" : "-"} ${customer.phoneNo} - ${customer.category}',
                //   itemBuilder: (customer) {
                //     return Container(
                //       width: screenWidth/2.5,
                //       alignment: Alignment.topLeft,
                //       padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                //       child: CustomText(
                //         text:
                //         '${customer.name}${customer.companyName.toString().isEmpty ? "" : ", ${customer.companyName}"} ${customer.name.toString().isEmpty ? "" : "-"} ${customer.phoneNo} - ${customer.category}',
                //         colors: Colors.black,
                //         size: 14,
                //         isCopy: false,
                //         textAlign: TextAlign.start,
                //       ),
                //     );
                //   },
                //   textEditingController: controllers.cusController,
                //   onSelected: (value) {
                //     controllers.search.text = value.name.toString();
                //     for (var i = 0; i < controllers.leadCategoryList.length; i++) {
                //       var item = controllers.leadCategoryList[i];
                //       if (item.leadStatus == value.leadStatus) {
                //         controllers.selectedIndex.value =
                //             int.tryParse(value.leadStatus.toString()) ?? 0;
                //         Get.off(
                //               () => NewLeadPage(
                //             index: item.leadStatus,
                //             name: item.value,
                //             list: item.list,
                //             list2: item.list2,
                //             listIndex: i,
                //           ),
                //           preventDuplicates: false,
                //         );
                //         break;
                //       }
                //     }
                //   },
                //   onClear: () {
                //     // if (onSearchChanged != null) onSearchChanged!("");
                //     controllers.clearSelectedCustomer();
                //   },
                // ),
                child: CDropdownField<AllCustomersObj>(
                  items: controllers.customers,
                  labelBuilder: (item) => item.name,
                  leadBuilder: (item) => item.category,
                  subLabelBuilder: (item) => item.phoneNo, // 🔥 optional
                  itemBuilder: (item) => SizedBox(), // not used now
                  onSelected: (item) {
                    print("item.name");
                    print(item.name);
                    controllers.search.text = item.name.toString();
                    for (var i = 0; i < controllers.leadCategoryList.length; i++) {
                      if(controllers.leadCategoryList[i].value==item.category.toString()){
                        print(controllers.leadCategoryList[i].value);
                        print(item.category.toString());

                        controllers.selectedIndex.value =int.tryParse(item.leadStatus.toString()) ?? 0;
                        Get.off(
                              () => NewLeadPage(
                            index: item.leadStatus,
                            name: controllers.leadCategoryList[i].value,
                            list: controllers.leadCategoryList[i].list,
                            list2: controllers.leadCategoryList[i].list2,
                            listIndex: i,
                          ),
                          preventDuplicates: false,
                        );
                        break;
                      }
                    }
                    // showDialog(
                    //   context: context,
                    //   builder: (_) => AlertDialog(
                    //     title: Text("Customer"),
                    //     content: Text(item.name),
                    //   ),
                    // );
                  },
                  borderRadius: 8,
                  borderColor: Colors.grey,
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
                                  case "Custom":
                                    dashController.showDatePickerDialog(context).then((range) {
                                      if (range != null) {
                                        dashController.selectedRange.value = range;

                                        dashController.date1.value =
                                        "${range.start.year}-${range.start.month.toString().padLeft(2, '0')}-${range.start.day.toString().padLeft(2, '0')}";

                                        dashController.date2.value =
                                        "${range.end.year}-${range.end.month.toString().padLeft(2, '0')}-${range.end.day.toString().padLeft(2, '0')}";

                                        /// 👉 API calls here only after selection
                                        dashController.getDashboardReport();
                                        dashController.getLeadReport();
                                        dashController.getStatusWiseReport();
                                        dashController.getCustomerStatus();

                                        dashController.getCustomerReport(
                                          dashController.date1.value,
                                          dashController.date2.value,
                                        );
                                      }
                                    });

                                    return;
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
                                remController.selectedCallSortBy.value = dashController.selectedSortBy.value;
                                remController.selectedReminderSortBy.value = dashController.selectedSortBy.value;
                                remController.dashboardMeetings(
                                  searchText: controllers.searchText.value.toLowerCase(),
                                  callType: controllers.selectMeetingType.value,
                                  sortField: controllers.sortFieldMeetingActivity.value,
                                  sortOrder: controllers.sortOrderMeetingActivity.value,
                                );
                                remController.dashboardCommunicationFilterList(
                                  dataList: remController.callMailsDetailsList2,
                                  searchText: controllers.searchText.value.toLowerCase(),
                                  callType: controllers.selectCallType.value,
                                  sortField: controllers.sortFieldCallActivity.value,
                                  sortOrder: controllers.sortOrderCallActivity.value,
                                  selectedMonth: remController.selectedCallMonth.value,
                                  selectedRange: remController.selectedCallRange.value,
                                  selectedDateFilter: remController.selectedCallSortBy.value,
                                );
                                remController.dashboardSortReminders();
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
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_today_outlined,color:Colors.white,size: 15,),
                          6.width,
                          Obx(() {
                            final range = dashController.selectedRange.value;
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
                      8.height,
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
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: SelectionArea(
        child: Row(
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
              child: GestureDetector(
                onTap:(){
                  setState(() {
                    isLeadPanelOpen = false;
                  });
                },
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
                                      controllers.selectedIndex.value = 101;
                                    }
                                ),SizedBox(width: screenWidth/85,),
                                WaveStatCard(
                                    title: "Calls",
                                    numericValue: int.parse(dashController.totalCalls.value.toString()),
                                    // numericValue: remController.callFilteredList.length,
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
                                      controllers.selectedIndex.value = 101;
                                    }
                                ),SizedBox(width: screenWidth/85,),
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
                                    controllers.selectedIndex.value = 101;
                                  },
                                  title: "Appointments",
                                  // numericValue: int.parse(dashController.totalMeetings.value.toString()),
                                  numericValue: remController.meetingFilteredList.length,
                                  maxValue: maxValue,
                                  iconPath: DashboardAssets.date,
                                  valueColor: const Color(0xff8B2CF5),
                                ),SizedBox(width: screenWidth/85,),
                                WaveStatCard(
                                  callback: () {
                                    controllers.isLeadsExpanded.value=true;
                                    setState(() {
                                      controllers.selectedIndex.value =int.parse(controllers.leadCategoryList[0].leadStatus);
                                    });
                                    // print(controllers.selectedIndex.value);
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
                                ),SizedBox(width: screenWidth/85,),
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
                                    102;
                                  },
                                  title: "Reminders",
                                  numericValue: int.parse(dashController
                                      .totalReminders.value
                                      .toString()),
                                  maxValue: maxValue,
                                  iconPath: DashboardAssets.alarm,
                                  valueColor: const Color(0xffBB271A),
                                ),
                                SizedBox(width: screenWidth/85,),
                                WaveStatCard(
                                  callback: () {
                                    productCtr.selectedCallSortBy.value = dashController.selectedSortBy.value;
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context,
                                            animation1,
                                            animation2) =>
                                        const OrderPage(),
                                        transitionDuration:
                                        Duration.zero,
                                        reverseTransitionDuration:
                                        Duration.zero,
                                      ),
                                    );
                                    controllers.oldIndex.value =controllers.selectedIndex.value;
                                    controllers.selectedIndex.value =106;
                                  },
                                  title: "Orders",
                                  numericValue: int.parse(dashController.totalOrders.value.toString()),
                                  maxValue: maxValue,
                                  iconPath: DashboardAssets.cart,amt: productCtr.formatAmount(dashController.totalAmt.value),
                                  valueColor: Colors.pink,
                                ),
                                SizedBox(width: screenWidth/85,),
                                WaveStatCard(
                                  callback: () {
                                    productCtr.selectedCallSortBy.value = dashController.selectedSortBy.value;
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context,
                                            animation1,
                                            animation2) =>
                                        const QuotationPage(),
                                        transitionDuration:
                                        Duration.zero,
                                        reverseTransitionDuration:
                                        Duration.zero,
                                      ),
                                    );
                                    controllers.oldIndex.value =controllers.selectedIndex.value;
                                    controllers.selectedIndex.value =107;
                                  },
                                  title: "Quotations",
                                  numericValue: int.parse(dashController.totalQuotations.value.toString()),
                                  maxValue: maxValue,
                                  iconPath: DashboardAssets.quo,
                                  valueColor: Colors.brown,
                                ),
                                SizedBox(
                                  width: screenWidth/7.5,
                                )
                              ],
                            ),
                            20.height,
                            Row(
                              children: [
                                Container(
                                  width: screenWidth/3,
                                  padding: const EdgeInsets.all(14),
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
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  CustomText(text: "Appointments", isCopy: false,isBold: true,size: 15,textAlign: TextAlign.start,),10.width,
                                                  InkWell(
                                                    onTap: (){
                                                      final futureDate = DateTime.now().add(const Duration(days: 3));
                                                      final adjustedDate = futureDate.weekday == DateTime.sunday?futureDate.add(const Duration(days: 1)):futureDate;
                                                      controllers.fDate.value = DateFormat('dd-MM-yyyy').format(adjustedDate);
                                                      controllers.fTime.value = DateFormat('hh.mm a').format(DateTime.now().add(const Duration(minutes: 15)));
                                                      controllers.toDate.value = DateFormat('dd-MM-yyyy').format(adjustedDate);
                                                      controllers.toTime.value = DateFormat('hh.mm a').format(DateTime.now().add(const Duration(minutes: 30)));

                                                      setState(() {
                                                        controllers.clearSelectedCustomer();
                                                        controllers.cusController.text = "";
                                                        controllers.callType = "Outgoing";
                                                        controllers.callStatus = "Contacted";
                                                      });
                                                      controllers.callCommentCont.text = "";
                                                      controllers.meetingTitleCrt.text = "";
                                                      controllers.meetingVenueCrt.text = "";
                                                      utils.addAppointment(context);
                                                    },
                                                    child: Card(
                                                      color: colorsConst.primary,
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(4.0),
                                                        child: Icon(Icons.add,color: Colors.white,size: 18,),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              InkWell(
                                                onTap: (){
                                                  controllers.selectedIndex.value=101;
                                                  controllers.changeTab(2);
                                                  Get.to(Records(isReload: "true"));
                                                },
                                                child: Row(
                                                  children: [
                                                    CustomText(text: "View All Appointments", isCopy: false,size: 13,textAlign: TextAlign.start,colors: colorsConst.primary,),5.width,
                                                    Icon(Icons.north_east,size: 20,color: colorsConst.primary,)
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                          Obx(() {
                                            return Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: _filterGroupDecoration(),
                                              child: Row(
                                                children: dashController.filterType.map((filter) {
                                                  final bool isSelected = remController.filterApp.value == filter;
                                                  return MouseRegion(
                                                    cursor: SystemMouseCursors.click,
                                                    child: GestureDetector(
                                                      behavior: HitTestBehavior.opaque,
                                                      onTap: () {
                                                        remController.filterApp.value = filter;
                                                        remController.dashboardMeetings(
                                                          searchText: controllers.searchText.value.toLowerCase(),
                                                          callType: controllers.selectMeetingType.value,
                                                          sortField: controllers.sortFieldMeetingActivity.value,
                                                          sortOrder: controllers.sortOrderMeetingActivity.value,
                                                        );
                                                      },
                                                      child: Container(
                                                        width: MediaQuery.of(context).size.width*0.05,
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
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(5.0),
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
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            );
                                          }),
                                        ],
                                      ),5.height,
                                      Container(
                                        color: Colors.white,
                                        width: screenWidth/3,
                                        child: Table(
                                          // columnWidths: {
                                          //   0: FixedColumnWidth(100),
                                          //   1: FixedColumnWidth(100),
                                          //   2: FixedColumnWidth(100),
                                          //   3: FixedColumnWidth(100),
                                          // },
                                          border: TableBorder(
                                            horizontalInside:BorderSide(width: 0.5, color: Colors.grey),
                                            verticalInside:BorderSide(width: 0.5, color: Colors.grey),
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
                                                        text: "Lead Name",
                                                        size: 15,
                                                        isBold: true,
                                                        isCopy: true,
                                                        colors: Colors.white,
                                                      ),
                                                      1.width,
                                                      GestureDetector(
                                                        onTap: (){
                                                          if(controllers.sortFieldMeetingActivity.value=='customerName' && controllers.sortOrderMeetingActivity.value=='asc'){
                                                            controllers.sortOrderMeetingActivity.value='desc';
                                                          }else{
                                                            controllers.sortOrderMeetingActivity.value='asc';
                                                          }
                                                          controllers.sortFieldMeetingActivity.value='customerName';
                                                          remController.dashboardMeetings(
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
                                                        text: "Company",
                                                        isCopy: true,
                                                        size: 15,
                                                        isBold: true,
                                                        colors: Colors.white,
                                                      ),
                                                      1.width,
                                                      GestureDetector(
                                                        onTap: (){
                                                          if(controllers.sortFieldMeetingActivity.value=='companyName' && controllers.sortOrderMeetingActivity.value=='asc'){
                                                            controllers.sortOrderMeetingActivity.value='desc';
                                                          }else{
                                                            controllers.sortOrderMeetingActivity.value='asc';
                                                          }
                                                          controllers.sortFieldMeetingActivity.value='companyName';
                                                          remController.dashboardMeetings(
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
                                                        text: "Employee",
                                                        isCopy: true,
                                                        size: 15,
                                                        isBold: true,
                                                        colors: Colors.white,
                                                      ),
                                                      1.width,
                                                      GestureDetector(
                                                        onTap: (){
                                                          if(controllers.sortFieldMeetingActivity.value=='emp' && controllers.sortOrderMeetingActivity.value=='asc'){
                                                            controllers.sortOrderMeetingActivity.value='desc';
                                                          }else{
                                                            controllers.sortOrderMeetingActivity.value='asc';
                                                          }
                                                          controllers.sortFieldMeetingActivity.value='emp';
                                                          remController.dashboardMeetings(
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
                                                        text: "Date & Time",
                                                        isCopy: true,
                                                        size: 15,
                                                        isBold: true,
                                                        colors: Colors.white,
                                                      ),
                                                      1.width,
                                                      GestureDetector(
                                                        onTap: (){
                                                          if(controllers.sortFieldMeetingActivity.value=='date' && controllers.sortOrderMeetingActivity.value=='asc'){
                                                            controllers.sortOrderMeetingActivity.value='desc';
                                                          }else{
                                                            controllers.sortOrderMeetingActivity.value='asc';
                                                          }
                                                          controllers.sortFieldMeetingActivity.value='date';
                                                          remController.dashboardMeetings(
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
                                        width: screenWidth/3,
                                        height: 200,
                                        child: remController.meetingFilteredList.isEmpty?
                                        Center(
                                          child: CustomText(
                                            text: "No Appointments",
                                            isCopy: true,
                                            colors: colorsConst.textColor,
                                            size: 16,),
                                        )
                                            :ListView.builder(
                                          controller: _controller,
                                          shrinkWrap: true,
                                          physics: const ScrollPhysics(),
                                          itemCount: remController.meetingFilteredList.length,
                                          itemBuilder: (context, index) {
                                            final data = remController.meetingFilteredList[index];
                                            return Table(
                                              // columnWidths: {
                                              //   0: FixedColumnWidth(100),
                                              //   1: FixedColumnWidth(100),
                                              //   2: FixedColumnWidth(100),
                                              //   3: FixedColumnWidth(100),
                                              // },
                                              border: TableBorder(
                                                horizontalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                                                verticalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                                                // bottom:  BorderSide(width: 0.2, color: Colors.green.shade400),
                                              ),
                                              children:[
                                                TableRow(
                                                    decoration: BoxDecoration(
                                                      color: int.parse(index.toString()) % 2 == 0 ? Colors.white : Colors.grey.shade100,
                                                      border: Border.all(
                                                        color: Colors.grey.shade200
                                                      )
                                                    ),
                                                    children:[
                                                      InkWell(
                                                        onTap:(){
                                                          showMeetingDialog(context, remController.meetingFilteredList,index);
                                                        },
                                                        child: Padding(
                                                          padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                                                          child: CustomText(
                                                            textAlign: TextAlign.left,
                                                            text: data.cusName.toString()=="null"?"":data.cusName.toString(),
                                                            size: 13,
                                                            isCopy: false,
                                                            colors:colorsConst.textColor,
                                                          ),
                                                        ),
                                                      ),
                                                      InkWell(
                                                        onTap:(){
                                                          showMeetingDialog(context, remController.meetingFilteredList,index);
                                                        },
                                                        child: Padding(
                                                          padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                                                          child: CustomText(
                                                            textAlign: TextAlign.left,
                                                            text:data.comName.toString()=="null"?"":data.comName.toString(),
                                                            size: 13,
                                                            isCopy: false,
                                                            colors: colorsConst.textColor,
                                                          ),
                                                        ),
                                                      ),
                                                      InkWell(
                                                        onTap:(){
                                                          showMeetingDialog(context, remController.meetingFilteredList,index);
                                                        },
                                                        child: Padding(
                                                          padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                                                          child: CustomText(
                                                            textAlign: TextAlign.left,
                                                            text:data.employeeName.toString()=="null"?"":data.employeeName.toString(),
                                                            size: 13,
                                                            isCopy: false,
                                                            colors: colorsConst.textColor,
                                                          ),
                                                        ),
                                                      ),
                                                      InkWell(
                                                        onTap:(){
                                                          showMeetingDialog(context, remController.meetingFilteredList,index);
                                                        },
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(10.0),
                                                          child: CustomText(
                                                            textAlign: TextAlign.left,
                                                            text: utils.formatDateTime(data.dates,data.time),
                                                            size: 13,
                                                            isCopy: false,
                                                            colors: colorsConst.textColor,
                                                          ),
                                                        ),
                                                      ),
                                                    ]
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                15.width,
                                Container(
                                  width: screenWidth/2.3,
                                  padding: const EdgeInsets.all(14),
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
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  CustomText(text: "Reminders", isCopy: false,isBold: true,size: 15,),
                                                  10.width,
                                                  InkWell(
                                                    onTap: (){
                                                      reminderUtils.showAddReminderDialog(context);
                                                    },
                                                    child: Card(
                                                      color: colorsConst.primary,
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(4.0),
                                                        child: Icon(Icons.add,color: Colors.white,size: 18,),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              InkWell(
                                                onTap: (){
                                                  controllers.selectedIndex.value=102;
                                                  Get.to(ReminderPage());
                                                },
                                                child: Row(
                                                  children: [
                                                    CustomText(text: "View All Reminders", isCopy: false,size: 13,textAlign: TextAlign.start,colors: colorsConst.primary,),5.width,
                                                    Icon(Icons.north_east,size: 20,color: colorsConst.primary,)
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                          Obx(() {
                                            return Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: _filterGroupDecoration(),
                                              child: Row(
                                                children: dashController.filterType.map((filter) {
                                                  final bool isSelected = remController.filterRem.value == filter;
                                                  return MouseRegion(
                                                    cursor: SystemMouseCursors.click,
                                                    child: GestureDetector(
                                                      behavior: HitTestBehavior.opaque,
                                                      onTap: () {
                                                        remController.filterRem.value = filter;
                                                        remController.dashboardSortReminders();
                                                      },
                                                      child: Container(
                                                        width: MediaQuery.of(context).size.width*0.05,
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
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(5.0),
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
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            );
                                          }),
                                        ],
                                      ),5.height,
                                      Container(
                                        color: Colors.white,
                                        width: screenWidth/1.29,
                                        child: Table(
                                          // columnWidths: {
                                          //   0: FixedColumnWidth(5),
                                          //   1: FixedColumnWidth(5),
                                          //   2: FixedColumnWidth(5),
                                          //   3: FixedColumnWidth(5),
                                          //   4: FixedColumnWidth(5),
                                          // },
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
                                                        text: "Event Name",
                                                        size: 15,
                                                        isBold: true,
                                                        isCopy: true,
                                                        colors: Colors.white,
                                                      ),
                                                      1.width,
                                                      GestureDetector(
                                                        onTap: () {
                                                          if (remController.sortFieldCallActivity.value == 'title' &&
                                                              remController.sortOrderCallActivity.value == 'asc') {
                                                            remController.sortOrderCallActivity.value = 'desc';
                                                          } else {
                                                            remController.sortOrderCallActivity.value = 'asc';
                                                          }
                                                          remController.sortFieldCallActivity.value = 'title';
                                                          remController.dashboardSortReminders();
                                                        },
                                                        child: Obx(() => Image.asset(
                                                          controllers.sortFieldCallActivity.value.isEmpty
                                                              ? "assets/images/arrow.png"
                                                              : controllers.sortOrderCallActivity.value == 'asc'
                                                              ? "assets/images/arrow_up.png"
                                                              : "assets/images/arrow_down.png",
                                                          width: 15,
                                                          height: 15,
                                                        )),
                                                      ),
                                                    ],
                                                  ),),
                                                  headerCell(3, Row(
                                                    children: [
                                                      CustomText(//2
                                                        textAlign: TextAlign.left,
                                                        text: "Type",
                                                        isCopy: true,
                                                        size: 15,
                                                        isBold: true,
                                                        colors: Colors.white,
                                                      ),
                                                      1.width,
                                                      GestureDetector(
                                                        onTap: () {
                                                          if (remController.sortFieldCallActivity.value == 'type' &&
                                                              remController.sortOrderCallActivity.value == 'asc') {
                                                            remController.sortOrderCallActivity.value = 'desc';
                                                          } else {
                                                            remController.sortOrderCallActivity.value = 'asc';
                                                          }
                                                          remController.sortFieldCallActivity.value = 'type';
                                                          remController.dashboardSortReminders();
                                                        },
                                                        child: Obx(() => Image.asset(
                                                          controllers.sortFieldCallActivity.value.isEmpty
                                                              ? "assets/images/arrow.png"
                                                              : controllers.sortOrderCallActivity.value == 'asc'
                                                              ? "assets/images/arrow_up.png"
                                                              : "assets/images/arrow_down.png",
                                                          width: 15,
                                                          height: 15,
                                                        )),
                                                      ),
                                                    ],
                                                  ),),
                                                  headerCell(7, Row(
                                                    children: [
                                                      CustomText(
                                                        textAlign: TextAlign.center,
                                                        text: "Lead Name",
                                                        isCopy: true,
                                                        size: 15,
                                                        isBold: true,
                                                        colors: Colors.white,
                                                      ),
                                                      1.width,
                                                      GestureDetector(
                                                        onTap: () {
                                                          if (remController.sortBy.value == 'customerName' &&
                                                              remController.sortOrderCallActivity.value == 'asc') {
                                                            remController.sortOrderCallActivity.value = 'desc';
                                                          } else {
                                                            remController.sortOrderCallActivity.value = 'asc';
                                                          }
                                                          remController.sortBy.value = 'customerName';
                                                          remController.dashboardSortReminders();
                                                        },
                                                        child: Obx(() => Image.asset(
                                                          remController.sortBy.value.isEmpty
                                                              ? "assets/images/arrow.png"
                                                              : controllers.sortOrderCallActivity.value == 'asc'
                                                              ? "assets/images/arrow_up.png"
                                                              : "assets/images/arrow_down.png",
                                                          width: 15,
                                                          height: 15,
                                                        )),
                                                      ),
                                                    ],
                                                  ),),
                                                  headerCell(7, Row(
                                                    children: [
                                                      CustomText(
                                                        textAlign: TextAlign.center,
                                                        text: "Employee",
                                                        isCopy: true,
                                                        size: 15,
                                                        isBold: true,
                                                        colors: Colors.white,
                                                      ),
                                                      1.width,
                                                      GestureDetector(
                                                        onTap: () {
                                                          if (remController.sortFieldCallActivity.value == 'employeeName' &&
                                                              remController.sortOrderCallActivity.value == 'asc') {
                                                            remController.sortOrderCallActivity.value = 'desc';
                                                          } else {
                                                            remController.sortOrderCallActivity.value = 'asc';
                                                          }
                                                          remController.sortFieldCallActivity.value = 'employeeName';
                                                          remController.dashboardSortReminders();
                                                        },
                                                        child: Obx(() => Image.asset(
                                                          controllers.sortFieldCallActivity.value.isEmpty
                                                              ? "assets/images/arrow.png"
                                                              : controllers.sortOrderCallActivity.value == 'asc'
                                                              ? "assets/images/arrow_up.png"
                                                              : "assets/images/arrow_down.png",
                                                          width: 15,
                                                          height: 15,
                                                        )),
                                                      ),
                                                    ],
                                                  ),),
                                                  headerCell(7, Row(
                                                    children: [
                                                      CustomText(
                                                        textAlign: TextAlign.center,
                                                        text: "Date & Time",
                                                        isCopy: true,
                                                        size: 15,
                                                        isBold: true,
                                                        colors: Colors.white,
                                                      ),
                                                      1.width,
                                                      GestureDetector(
                                                        onTap: () {
                                                          if (remController.sortFieldCallActivity.value == 'startDate' &&
                                                              remController.sortOrderCallActivity.value == 'asc') {
                                                            remController.sortOrderCallActivity.value = 'desc';
                                                          } else {
                                                            remController.sortOrderCallActivity.value = 'asc';
                                                          }
                                                          remController.sortFieldCallActivity.value = 'startDate';
                                                          remController.dashboardSortReminders();
                                                        },
                                                        child: Obx(() => Image.asset(
                                                          controllers.sortFieldCallActivity.value.isEmpty
                                                              ? "assets/images/arrow.png"
                                                              : controllers.sortOrderCallActivity.value == 'asc'
                                                              ? "assets/images/arrow_up.png"
                                                              : "assets/images/arrow_down.png",
                                                          width: 15,
                                                          height: 15,
                                                        )),
                                                      ),
                                                    ],
                                                  ),),
                                                ]),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        color: Colors.white,
                                        width: screenWidth/1.29,
                                        height: 200,
                                        child: remController.reminderFilteredList.isEmpty?
                                        Center(
                                          child: CustomText(
                                            text: "No Reminders",
                                            isCopy: true,
                                            colors: colorsConst.textColor,
                                            size: 16,),
                                        )
                                            :ListView.builder(
                                          controller: _controller,
                                          shrinkWrap: true,
                                          physics: const ScrollPhysics(),
                                          itemCount: remController.reminderFilteredList.length,
                                          itemBuilder: (context, index) {
                                            final data = remController.reminderFilteredList[index];
                                            return Table(
                                              // columnWidths: {
                                              //   0: FixedColumnWidth(5),
                                              //   1: FixedColumnWidth(5),
                                              //   2: FixedColumnWidth(5),
                                              //   3: FixedColumnWidth(5),
                                              //   4: FixedColumnWidth(5),
                                              // },
                                              border: TableBorder(
                                                horizontalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                                                verticalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                                                // bottom:  BorderSide(width: 0.2, color: Colors.green.shade400),
                                              ),
                                              children:[
                                                TableRow(
                                                    decoration: BoxDecoration(
                                                      color: int.parse(index.toString()) % 2 == 0 ? Colors.white : Colors.grey.shade100,
                                                        border: Border.all(
                                                            color: Colors.grey.shade200
                                                        )
                                                    ),
                                                    children:[
                                                      InkWell(
                                                        onTap:(){
                                                          showReminderDialog(context,remController.reminderFilteredList,index);
                                                        },
                                                        child: Padding(
                                                          padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                                                          child: CustomText(
                                                            textAlign: TextAlign.left,
                                                            text: data.title.toString(),
                                                            size: 13,
                                                            isCopy: false,
                                                            colors:colorsConst.textColor,
                                                          ),
                                                        ),
                                                      ),
                                                      InkWell(
                                                        onTap:(){
                                                          showReminderDialog(context,remController.reminderFilteredList,index);
                                                        },
                                                        child: Padding(
                                                          padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                                                          child: CustomText(
                                                            textAlign: TextAlign.left,
                                                            text: data.type.toString()=="1"?"Follow-up":"Appointment",
                                                            size: 13,
                                                            isCopy: false,
                                                            colors:colorsConst.textColor,
                                                          ),
                                                        ),
                                                      ),
                                                      InkWell(
                                                        onTap:(){
                                                          showReminderDialog(context,remController.reminderFilteredList,index);
                                                        },
                                                        child: Padding(
                                                          padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                                                          child: CustomText(
                                                            textAlign: TextAlign.left,
                                                            text: data.customerName.toString()=="null"?"":data.customerName.toString(),
                                                            size: 13,
                                                            isCopy: false,
                                                            colors:colorsConst.textColor,
                                                          ),
                                                        ),
                                                      ),
                                                      InkWell(
                                                        onTap:(){
                                                          showReminderDialog(context,remController.reminderFilteredList,index);
                                                        },
                                                        child: Padding(
                                                          padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                                                          child: CustomText(
                                                            textAlign: TextAlign.left,
                                                            text: data.employeeName.toString(),
                                                            size: 13,
                                                            isCopy: false,
                                                            colors:colorsConst.textColor,
                                                          ),
                                                        ),
                                                      ),
                                                      InkWell(
                                                        onTap:(){
                                                          showReminderDialog(context,remController.reminderFilteredList,index);
                                                        },
                                                        child: Padding(
                                                          padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                                                          child: CustomText(
                                                            textAlign: TextAlign.left,
                                                            text: controllers.formatDate(data.startDt.toString()),
                                                            size: 13,
                                                            isCopy: false,
                                                            colors:colorsConst.textColor,
                                                          ),
                                                        ),
                                                      ),
                                                    ]
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: screenWidth/9,
                                )
                              ],
                            ),
                            20.height,
                            Row(
                              children: [
                                SizedBox(
                                  width: screenWidth/1.29,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: screenWidth / 4,
                                        height: 300,
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
                                                    color: controllers.leadColors[i],
                                                  ),
                                            ]
                                        ),
                                      ),
                                      CustomerActivityCard(),
                                      Container(
                                        height: 300,
                                        width: screenWidth/3.3,
                                        padding: const EdgeInsets.all(16),
                                        decoration: _whiteCard(),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            // -------- TITLE --------
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                CustomText(
                                                  text: "Portfolio Heat",
                                                  isCopy: false,
                                                  size: 15,
                                                  isBold: true,
                                                ),
                                                4.height,
                                                // -------- DIVIDER --------
                                                const Divider(
                                                  height: 1,
                                                  thickness: 1,
                                                  color: Color(0xffD1D5DB),
                                                ),
                                              ],
                                            ),
                                            CustomText(
                                              text: "Customer Engagement Levels",
                                              isCopy: false,
                                              size: 13,
                                              isBold: false,
                                              colors: Color(0xff6B7280),
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                InkWell(
                                                  onTap:dashController.totalHot2.value!="0"?(){
                                                    Get.to(RatingPage(rep:"1",type: "Hot", pageName: 'Customer',));
                                                  }:null,
                                                  child: Container(
                                                    height: screenWidth/30,width: screenWidth/20,
                                                    decoration: customDecoration.baseBackgroundDecoration(
                                                        color: Color(0xFFFFF2F2),radius: 10
                                                    ),
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                      children: [
                                                        Image.asset("assets/images/hot.png"),
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            CustomText(text: "Hot", isCopy: false,isBold: true,colors: Color(0xFFEF4444)),
                                                            5.width,
                                                            CustomText(text: "${int.tryParse(dashController.totalHot2.value) ??0}", isCopy: false,isBold: true,colors: Color(0xFFEF4444)),

                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap:dashController.totalWarm2.value!="0"?(){
                                                    Get.to(RatingPage(rep:"1",type: "Warm", pageName: 'Customer',));
                                                  }:null,
                                                  child: Container(
                                                    height: screenWidth/30,width: screenWidth/20,
                                                    decoration: customDecoration.baseBackgroundDecoration(
                                                        color: Color(0xFFFFF8ED),radius: 10
                                                    ),
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                      children: [
                                                        Image.asset("assets/images/warm.png"),
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            CustomText(text: "Warm", isCopy: false,isBold: true,colors: Color(0xFFF59E0B)),
                                                            5.width,
                                                            CustomText(text: "${int.tryParse(dashController.totalWarm2.value) ??0}", isCopy: false,isBold: true,colors: Color(0xFFF59E0B)),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap:dashController.totalCold2.value!="0"?(){
                                                    Get.to(RatingPage(rep:"1",type: "Cold", pageName: 'Customer',));
                                                  }:null,
                                                  child: Container(
                                                    height: screenWidth/30,width: screenWidth/20,
                                                    decoration: customDecoration.baseBackgroundDecoration(
                                                        color: Color(0xFFF0F6FF),radius: 10
                                                    ),
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                      children: [
                                                        Image.asset("assets/images/cold.png"),
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            CustomText(text: "Cold", isCopy: false,isBold: true,colors: Color(0xFF3B82F6)),5.width,
                                                            CustomText(text: "${int.tryParse(dashController.totalCold2.value) ??0}", isCopy: false,isBold: true,colors: Color(0xFF3B82F6)),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const Divider(
                                              height: 1,
                                              thickness: 1,
                                              color: Color(0xffD1D5DB),
                                            ),
                                            CustomText(
                                              text: "Lead Engagement Levels",
                                              isCopy: false,
                                              size: 13,
                                              isBold: false,
                                              colors: Color(0xff6B7280),
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                InkWell(
                                                  onTap:dashController.totalHot.value!="0"?(){
                                                    Get.to(RatingPage(rep:"2",type: "Hot", pageName: 'Leads',));
                                                  }:null,
                                                  child: Container(
                                                    height: screenWidth/30,width: screenWidth/20,
                                                    decoration: customDecoration.baseBackgroundDecoration(
                                                        color: Color(0xFFFFF2F2),radius: 10
                                                    ),
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                      children: [
                                                        Image.asset("assets/images/hot.png"),
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            CustomText(text: "Hot", isCopy: false,isBold: true,colors: Color(0xFFEF4444)),
                                                            5.width,
                                                            CustomText(text: "${int.tryParse(dashController.totalHot.value) ??0}", isCopy: false,isBold: true,colors: Color(0xFFEF4444)),

                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap:dashController.totalWarm.value!="0"?(){
                                                    Get.to(RatingPage(rep:"2",type: "Warm", pageName: 'Leads',));
                                                  }:null,
                                                  child: Container(
                                                    height: screenWidth/30,width: screenWidth/20,
                                                    decoration: customDecoration.baseBackgroundDecoration(
                                                        color: Color(0xFFFFF8ED),radius: 10
                                                    ),
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                      children: [
                                                        Image.asset("assets/images/warm.png"),
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            CustomText(text: "Warm", isCopy: false,isBold: true,colors: Color(0xFFF59E0B)),
                                                            5.width,
                                                            CustomText(text: "${int.tryParse(dashController.totalWarm.value) ??0}", isCopy: false,isBold: true,colors: Color(0xFFF59E0B)),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap:dashController.totalCold.value!="0"?(){
                                                    Get.to(RatingPage(rep:"2",type: "Cold", pageName: 'Leads',));
                                                  }:null,
                                                  child: Container(
                                                    height: screenWidth/30,width: screenWidth/20,
                                                    decoration: customDecoration.baseBackgroundDecoration(
                                                        color: Color(0xFFF0F6FF),radius: 10
                                                    ),
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                      children: [
                                                        Image.asset("assets/images/cold.png"),
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            CustomText(text: "Cold", isCopy: false,isBold: true,colors: Color(0xFF3B82F6)),5.width,
                                                            CustomText(text: "${int.tryParse(dashController.totalCold.value) ??0}", isCopy: false,isBold: true,colors: Color(0xFF3B82F6)),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: screenWidth/9,
                                )
                              ],
                            ),
                            20.height,
                            Row(
                              children: [
                                Container(
                                  width: screenWidth/2.17,
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
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              CustomText(text: "Communication Details", isCopy: false,isBold: true,size: 15,),
                                              // 10.width,
                                              // InkWell(
                                              //   onTap: (){
                                              //     controllers.empDOB.value = DateFormat('dd-MM-yyyy').format(DateTime.now());
                                              //     controllers.callTime.value = DateFormat('hh.mm a').format(DateTime.now().subtract(const Duration(minutes: 15)));
                                              //     setState(() {
                                              //       controllers.clearSelectedCustomer();
                                              //       controllers.cusController.text = "";
                                              //       controllers.callType = "Outgoing";
                                              //       controllers.callStatus = controllers.hCallStatusList[0]["value"];
                                              //       controllers.callCommentCont.text = "";
                                              //     });
                                              //     utils.showCallDialog(
                                              //         context,"Add Call Log",
                                              //             (){
                                              //           apiService.insertCallCommentAPI(context, "7");
                                              //         },false
                                              //     );
                                              //   },
                                              //   child: CircleAvatar(
                                              //     backgroundColor: colorsConst.primary,
                                              //     radius: 15,
                                              //     child: Icon(Icons.add,color: Colors.white,size: 18,),
                                              //   ),
                                              // )
                                            ],
                                          ),
                                          Obx(() {
                                            return Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: _filterGroupDecoration(),
                                              child: Row(
                                                children: dashController.filterType.map((filter) {
                                                  final bool isSelected = remController.filterCall.value == filter;
                                                  return MouseRegion(
                                                    cursor: SystemMouseCursors.click,
                                                    child: GestureDetector(
                                                      behavior: HitTestBehavior.opaque,
                                                      onTap: () {
                                                        remController.filterCall.value = filter;
                                                        remController.dashboardCommunicationFilterList(
                                                          dataList: remController.callMailsDetailsList2,
                                                          searchText: controllers.searchText.value.toLowerCase(),
                                                          callType: controllers.selectCallType.value,
                                                          sortField: controllers.sortFieldCallActivity.value,
                                                          sortOrder: controllers.sortOrderCallActivity.value,
                                                          selectedMonth: remController.selectedCallMonth.value,
                                                          selectedRange: remController.selectedCallRange.value,
                                                          selectedDateFilter: remController.selectedCallSortBy.value,
                                                        );
                                                      },
                                                      child: Container(
                                                        width: MediaQuery.of(context).size.width*0.05,
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
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(5.0),
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
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            );
                                          }),
                                        ],
                                      ),5.height,
                                      Container(
                                        color: Colors.white,
                                        width: screenWidth/2,
                                        child: Table(
                                          columnWidths: {
                                            0: FixedColumnWidth(100),
                                            1: FixedColumnWidth(100),
                                            2: FixedColumnWidth(100),
                                            3: FixedColumnWidth(100),
                                            4: FixedColumnWidth(100),
                                            5: FixedColumnWidth(100),
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
                                                  headerCell(1, Row(
                                                    children: [
                                                      CustomText(//1
                                                        textAlign: TextAlign.left,
                                                        text: "Lead Name",
                                                        size: 15,
                                                        isBold: true,
                                                        isCopy: true,
                                                        colors: Colors.white,
                                                      ),3.width,
                                                      GestureDetector(
                                                        onTap: (){
                                                          if(controllers.sortFieldCallActivity.value=='customerName' && controllers.sortOrderCallActivity.value=='asc'){
                                                            controllers.sortOrderCallActivity.value='desc';
                                                          }else{
                                                            controllers.sortOrderCallActivity.value='asc';
                                                          }
                                                          controllers.sortFieldCallActivity.value='customerName';
                                                          remController.dashboardCommunicationFilterList(
                                                            dataList: remController.callMailsDetailsList2,
                                                            searchText: controllers.searchText.value.toLowerCase(),
                                                            callType: controllers.selectCallType.value,
                                                            sortField: controllers.sortFieldCallActivity.value,
                                                            sortOrder: controllers.sortOrderCallActivity.value,
                                                            selectedMonth: remController.selectedCallMonth.value,
                                                            selectedRange: remController.selectedCallRange.value,
                                                            selectedDateFilter: remController.selectedCallSortBy.value,
                                                          );
                                                        },
                                                        child: Obx(() => Image.asset(
                                                          controllers.sortFieldCallActivity.value.isEmpty
                                                              ? "assets/images/arrow.png"
                                                              : controllers.sortOrderCallActivity.value == 'asc'
                                                              ? "assets/images/arrow_up.png"
                                                              : "assets/images/arrow_down.png",
                                                          width: 15,
                                                          height: 15,
                                                        ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),),
                                                  headerCell(1, Row(
                                                    children: [
                                                      CustomText(//1
                                                        textAlign: TextAlign.left,
                                                        text: "Company",
                                                        size: 15,
                                                        isBold: true,
                                                        isCopy: true,
                                                        colors: Colors.white,
                                                      ),3.width,
                                                      GestureDetector(
                                                        onTap: (){
                                                          if(controllers.sortFieldCallActivity.value=='company' && controllers.sortOrderCallActivity.value=='asc'){
                                                            controllers.sortOrderCallActivity.value='desc';
                                                          }else{
                                                            controllers.sortOrderCallActivity.value='asc';
                                                          }
                                                          controllers.sortFieldCallActivity.value='company';
                                                          remController.dashboardCommunicationFilterList(
                                                            dataList: remController.callMailsDetailsList2,
                                                            searchText: controllers.searchText.value.toLowerCase(),
                                                            callType: controllers.selectCallType.value,
                                                            sortField: controllers.sortFieldCallActivity.value,
                                                            sortOrder: controllers.sortOrderCallActivity.value,
                                                            selectedMonth: remController.selectedCallMonth.value,
                                                            selectedRange: remController.selectedCallRange.value,
                                                            selectedDateFilter: remController.selectedCallSortBy.value,
                                                          );
                                                        },
                                                        child: Obx(() => Image.asset(
                                                          controllers.sortFieldCallActivity.value.isEmpty
                                                              ? "assets/images/arrow.png"
                                                              : controllers.sortOrderCallActivity.value == 'asc'
                                                              ? "assets/images/arrow_up.png"
                                                              : "assets/images/arrow_down.png",
                                                          width: 15,
                                                          height: 15,
                                                        ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),),
                                                  headerCell(2, Row(
                                                    children: [
                                                      CustomText(
                                                        textAlign: TextAlign.center,
                                                        text: "Call Date",
                                                        isCopy: true,
                                                        size: 15,
                                                        isBold: true,
                                                        colors: Colors.white,
                                                      ),3.width,
                                                      GestureDetector(
                                                        onTap: (){
                                                          if(controllers.sortFieldCallActivity.value=='date' && controllers.sortOrderCallActivity.value=='asc'){
                                                            controllers.sortOrderCallActivity.value='desc';
                                                          }else{
                                                            controllers.sortOrderCallActivity.value='asc';
                                                          }
                                                          controllers.sortFieldCallActivity.value='date';
                                                          remController.dashboardCommunicationFilterList(
                                                            dataList: remController.callMailsDetailsList2,
                                                            searchText: controllers.searchText.value.toLowerCase(),
                                                            callType: controllers.selectCallType.value,
                                                            sortField: controllers.sortFieldCallActivity.value,
                                                            sortOrder: controllers.sortOrderCallActivity.value,
                                                            selectedMonth: remController.selectedCallMonth.value,
                                                            selectedRange: remController.selectedCallRange.value,
                                                            selectedDateFilter: remController.selectedCallSortBy.value,
                                                          );
                                                        },
                                                        child: Obx(() => Image.asset(
                                                          controllers.sortFieldCallActivity.value.isEmpty
                                                              ? "assets/images/arrow.png"
                                                              : controllers.sortOrderCallActivity.value == 'asc'
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
                                                      CustomText(
                                                        textAlign: TextAlign.center,
                                                        text: "Call Type",
                                                        isCopy: true,
                                                        size: 15,
                                                        isBold: true,
                                                        colors: Colors.white,
                                                      ),3.width,
                                                      GestureDetector(
                                                        onTap: (){
                                                          if(controllers.sortFieldCallActivity.value=='type' && controllers.sortOrderCallActivity.value=='asc'){
                                                            controllers.sortOrderCallActivity.value='desc';
                                                          }else{
                                                            controllers.sortOrderCallActivity.value='asc';
                                                          }
                                                          controllers.sortFieldCallActivity.value='type';
                                                          remController.dashboardCommunicationFilterList(
                                                            dataList: remController.callMailsDetailsList2,
                                                            searchText: controllers.searchText.value.toLowerCase(),
                                                            callType: controllers.selectCallType.value,
                                                            sortField: controllers.sortFieldCallActivity.value,
                                                            sortOrder: controllers.sortOrderCallActivity.value,
                                                            selectedMonth: remController.selectedCallMonth.value,
                                                            selectedRange: remController.selectedCallRange.value,
                                                            selectedDateFilter: remController.selectedCallSortBy.value,
                                                          );
                                                        },
                                                        child: Obx(() => Image.asset(
                                                          controllers.sortFieldCallActivity.value.isEmpty
                                                              ? "assets/images/arrow.png"
                                                              : controllers.sortOrderCallActivity.value == 'asc'
                                                              ? "assets/images/arrow_up.png"
                                                              : "assets/images/arrow_down.png",
                                                          width: 15,
                                                          height: 15,
                                                        ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),),
                                                  headerCell(4, Row(
                                                    children: [
                                                      CustomText(
                                                        textAlign: TextAlign.center,
                                                        text: "Type",
                                                        isCopy: true,
                                                        size: 15,
                                                        isBold: true,
                                                        colors: Colors.white,
                                                      ),3.width,
                                                      // GestureDetector(
                                                      //   onTap: (){
                                                      //     if(controllers.sortFieldCallActivity.value=='status' && controllers.sortOrderCallActivity.value=='asc'){
                                                      //       controllers.sortOrderCallActivity.value='desc';
                                                      //     }else{
                                                      //       controllers.sortOrderCallActivity.value='asc';
                                                      //     }
                                                      //     controllers.sortFieldCallActivity.value='status';
                                                      //     remController.dashboardCommunicationFilterList(
                                                      //       dataList: remController.callMailsDetailsList,
                                                      //       searchText: controllers.searchText.value.toLowerCase(),
                                                      //       callType: controllers.selectCallType.value,
                                                      //       sortField: controllers.sortFieldCallActivity.value,
                                                      //       sortOrder: controllers.sortOrderCallActivity.value,
                                                      //       selectedMonth: remController.selectedCallMonth.value,
                                                      //       selectedRange: remController.selectedCallRange.value,
                                                      //       selectedDateFilter: remController.selectedCallSortBy.value,
                                                      //     );
                                                      //   },
                                                      //   child: Obx(() => Image.asset(
                                                      //     controllers.sortFieldCallActivity.value.isEmpty
                                                      //         ? "assets/images/arrow.png"
                                                      //         : controllers.sortOrderCallActivity.value == 'asc'
                                                      //         ? "assets/images/arrow_up.png"
                                                      //         : "assets/images/arrow_down.png",
                                                      //     width: 15,
                                                      //     height: 15,
                                                      //   ),
                                                      //   ),
                                                      // ),
                                                    ],
                                                  ),),
                                                  headerCell(5, Row(
                                                    children: [
                                                      CustomText(
                                                        textAlign: TextAlign.center,
                                                        text: "Added By",
                                                        isCopy: true,
                                                        size: 15,
                                                        isBold: true,
                                                        colors: Colors.white,
                                                      ),3.width,
                                                      GestureDetector(
                                                        onTap: (){
                                                          if(controllers.sortFieldCallActivity.value=='addedBy' && controllers.sortOrderCallActivity.value=='asc'){
                                                            controllers.sortOrderCallActivity.value='desc';
                                                          }else{
                                                            controllers.sortOrderCallActivity.value='asc';
                                                          }
                                                          controllers.sortFieldCallActivity.value='addedBy';
                                                          remController.dashboardCommunicationFilterList(
                                                            dataList: remController.callMailsDetailsList2,
                                                            searchText: controllers.searchText.value.toLowerCase(),
                                                            callType: controllers.selectCallType.value,
                                                            sortField: controllers.sortFieldCallActivity.value,
                                                            sortOrder: controllers.sortOrderCallActivity.value,
                                                            selectedMonth: remController.selectedCallMonth.value,
                                                            selectedRange: remController.selectedCallRange.value,
                                                            selectedDateFilter: remController.selectedCallSortBy.value,
                                                          );
                                                        },
                                                        child: Obx(() => Image.asset(
                                                          controllers.sortFieldCallActivity.value.isEmpty
                                                              ? "assets/images/arrow.png"
                                                              : controllers.sortOrderCallActivity.value == 'asc'
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
                                        width: screenWidth/2,
                                        height: 200,
                                        child: remController.callMailsDetailsList.isEmpty?
                                        Center(
                                          child: CustomText(
                                            text: "No Communication Details Found",
                                            isCopy: true,
                                            colors: colorsConst.textColor,
                                            size: 16,),
                                        )
                                            :ListView.builder(
                                          controller: _controller,
                                          shrinkWrap: true,
                                          physics: const ScrollPhysics(),
                                          itemCount: remController.callMailsDetailsList.length,
                                          itemBuilder: (context, index) {
                                            final data = remController.callMailsDetailsList[index];
                                            return Table(
                                              columnWidths: {
                                                0: FixedColumnWidth(100),
                                                1: FixedColumnWidth(100),
                                                2: FixedColumnWidth(100),
                                                3: FixedColumnWidth(100),
                                                4: FixedColumnWidth(100),
                                                5: FixedColumnWidth(100),
                                              },
                                              border: TableBorder(
                                                horizontalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                                                verticalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                                                // bottom:  BorderSide(width: 0.2, color: Colors.green.shade400),
                                              ),
                                              children:[
                                                TableRow(
                                                    decoration: BoxDecoration(
                                                      color: int.parse(index.toString()) % 2 == 0 ? Colors.white : Colors.grey.shade100,
                                                        border: Border.all(
                                                            color: Colors.grey.shade200
                                                        )
                                                    ),
                                                    children:[
                                                      InkWell(
                                                        onTap:(){
                                                          showCallDialog(context,remController.callMailsDetailsList,index);
                                                        },
                                                        child: Padding(
                                                          padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                                                          child: CustomText(
                                                            textAlign: TextAlign.left,
                                                            text: data.customerName.toString()=="null"?"":data.customerName.toString(),
                                                            size: 15,
                                                            isCopy: false,
                                                            colors:colorsConst.textColor,
                                                          ),
                                                        ),
                                                      ),
                                                      InkWell(
                                                        onTap:(){
                                                          showCallDialog(context,remController.callMailsDetailsList,index);
                                                        },
                                                        child: Padding(
                                                          padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                                                          child: CustomText(
                                                            textAlign: TextAlign.left,
                                                            text: data.companyName.toString()=="null"?"":data.companyName.toString(),
                                                            size: 15,
                                                            isCopy: false,
                                                            colors:colorsConst.textColor,
                                                          ),
                                                        ),
                                                      ),
                                                      InkWell(
                                                        onTap:(){
                                                          showCallDialog(context,remController.callMailsDetailsList,index);
                                                        },
                                                        child: Padding(
                                                          padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                                                          child: Column(
                                                            children: [
                                                              CustomText(
                                                                textAlign: TextAlign.left,
                                                                text: data.sentDate.toString().split(" ")[0],
                                                                size: 15,
                                                                isCopy: false,
                                                                colors: colorsConst.textColor,
                                                              ),
                                                              CustomText(
                                                                textAlign: TextAlign.start,
                                                                text: "${data.sentDate.toString().split(" ")[1]} ${data.sentDate.toString().split(" ")[2]}",
                                                                size: 15,
                                                                isCopy: false,
                                                                colors: colorsConst.textColor,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      InkWell(
                                                        onTap:(){
                                                          showCallDialog(context,remController.callMailsDetailsList,index);
                                                        },
                                                        child: Padding(
                                                          padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                                                          child: CustomText(
                                                            textAlign: TextAlign.left,
                                                            text: data.callType,
                                                            size: 15,
                                                            isCopy: false,
                                                            colors: colorsConst.textColor,
                                                          ),
                                                        ),
                                                      ),
                                                      InkWell(
                                                        onTap:(){
                                                          showCallDialog(context,remController.callMailsDetailsList,index);
                                                        },
                                                        child: Padding(
                                                          padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                                                          child: CustomText(
                                                            textAlign: TextAlign.left,
                                                            text: data.callStatus=="null"||data.callStatus==""?"Mail":"Call",
                                                            size: 15,
                                                            isCopy: false,
                                                            colors: colorsConst.textColor,
                                                          ),
                                                        ),
                                                      ),
                                                      InkWell(
                                                        onTap:(){
                                                          showCallDialog(context,remController.callMailsDetailsList,index);
                                                        },
                                                        child: Padding(
                                                          padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                                                          child: CustomText(
                                                            textAlign: TextAlign.left,
                                                            text: data.name,
                                                            size: 15,
                                                            isCopy: false,
                                                            colors: colorsConst.textColor,
                                                          ),
                                                        ),
                                                      ),
                                                    ]
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                15.width,
                                InkWell(
                                  onTap: (){
                                    remController.selectedCallSortBy.value = dashController.selectedSortBy.value;
                                    controllers.changeTab(0);
                                    controllers.selectCallType.value = "All";
                                    Navigator.push( context,
                                      PageRouteBuilder( pageBuilder: (context, animation1, animation2) =>
                                      const Records( isReload: "true", ), transitionDuration: Duration.zero, reverseTransitionDuration: Duration.zero,
                                      ),
                                    );
                                    controllers.oldIndex.value = controllers.selectedIndex.value;
                                    controllers.selectedIndex.value = 101;
                                  },
                                  child: SizedBox(
                                    width: screenWidth/3.3,
                                    height: 310,
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
                            Row(
                              children: [
                                SizedBox(
                                  width: screenWidth/1.29,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      ActivityOverTimeChart(
                                        // maxY: 330,
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
                                ),
                                SizedBox(
                                  width: screenWidth/9,
                                )
                              ],
                            ),
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
              ),
            )),
          ],
        ),
      ),
    );
  }
  // String formatDateTime(String dates,String times) {
  //   try {
  //     List<String> dateList = dates.split("||");
  //     List<String> timeList = times.split("||");
  //     String finalDate="";
  //     String finalTime="";
  //     String startDate = dateList[0];
  //     String startTime = timeList[0];
  //     String endDate = dateList[1];
  //     String endTime = timeList[1];
  //
  //
  //
  //     if (startDate == endDate) {
  //       // same date → no repeat
  //       finalDate=startDate;
  //     } else {
  //       finalDate="$startDate - $endDate";
  //     }
  //     if (startTime == endTime) {
  //       // same date → no repeat
  //       finalTime=startTime;
  //     } else {
  //       finalTime="$startTime - $endTime";
  //     }
  //     return "$finalDate to $finalTime";
  //   } catch (e) {
  //     return "";
  //   }
  // }
  ///
  // String formatDateTime(String dates, String times) {
  //   try {
  //     List<String> dateList = dates.split("||");
  //     List<String> timeList = times.split("||");
  //
  //     String startDate = dateList[0];
  //     String endDate = dateList[1];
  //
  //     String startTime = timeList[0];
  //     String endTime = timeList[1];
  //
  //     DateTime now = DateTime.now();
  //
  //     DateTime start = DateFormat("dd.MM.yyyy").parse(startDate);
  //     DateTime end = DateFormat("dd.MM.yyyy").parse(endDate);
  //
  //     String formatDate(DateTime date) {
  //       if (date.year == now.year) {
  //         return DateFormat("dd/MM").format(date);
  //       } else {
  //         return DateFormat("dd/MM/yyyy").format(date);
  //       }
  //     }
  //
  //     // ✅ SAME DATE
  //     if (startDate == endDate) {
  //       if (startTime == endTime) {
  //         return "${formatDate(start)} $startTime";
  //       } else {
  //         return "${formatDate(start)} $startTime to $endTime";
  //       }
  //     }
  //
  //     // ✅ DIFFERENT DATE
  //     return "${formatDate(start)} $startTime to ${formatDate(end)} $endTime";
  //
  //   } catch (e) {
  //     return "";
  //   }
  // }
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
    return InkWell(
      onTap: () {
        setState(() {
          isLeadPanelOpen = false;
        });
      },
      child: Container(
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
                        Image.asset(DashboardAssets.leadStage)
                      ],
                    ),
                  ],
                ),
              ),

              10.height,
              CustomText(
                text: "Life Time Customer Journey",
                isCopy: false,colors: Colors.blue,
              ),
              10.height,
              Container(
                height: 50,
                width: MediaQuery.of(context).size.width*0.1,
                decoration: customDecoration.baseBackgroundDecoration(
                  color: colorsConst.primary,
                  radius: 10,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: "${controllers.leadCategoryList.isEmpty?0:controllers.leadCategoryList.fold(0, (sum, item) => sum + (item.list2.length ?? 0))-controllers.leadCategoryList.value.last.list2.length}",
                              size: 16,
                              isCopy: false,colors: Colors.white,isBold: true,
                            ),5.height,
                            CustomText(
                              text: "${controllers.leadCategoryList.value.last.list2.length}",size: 16,
                              isCopy: false,colors: Colors.white,isBold: true,
                            )
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: "total leads",
                              isCopy: false,colors: Colors.white,
                            ),5.height,
                            CustomText(
                              text: "total customers",
                              isCopy: false,colors: Colors.white,
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
              10.height,
              // ================= FUNNEL ITEMS =================
              for (int i = 0; i < controllers.leadCategoryList.length; i++)
                _animatedLeadItem(
                  index: 0,
                  // child: Column(
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   mainAxisAlignment: MainAxisAlignment.start,
                  //   children: [
                  //     Row(
                  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //       children: [
                  //         Row(
                  //           children: [
                  //             Container(
                  //               height: 30,
                  //               width: 30,
                  //               alignment: Alignment.center,
                  //               decoration: BoxDecoration(
                  //                 color: controllers.leadColors[i].withOpacity(0.10),
                  //                 shape: BoxShape.circle,
                  //               ),
                  //               child: Container(
                  //                 height: 12,
                  //                 width: 12,
                  //                 decoration: BoxDecoration(
                  //                   color: controllers.leadColors[i],
                  //                   shape: BoxShape.circle,
                  //                 ),
                  //               ),
                  //             ),10.width,
                  //             CustomText(
                  //               text:  controllers.leadCategoryList[i].value.toUpperCase(),
                  //               isCopy: false,
                  //               size: 11,
                  //               isBold: true,
                  //               colors: controllers.leadColors[i],
                  //             ),
                  //           ],
                  //         ),
                  //         CustomText(
                  //           text: controllers.leadCategoryList[i].list.length.toString(),
                  //           isCopy: false,
                  //           size: 14,
                  //           isBold: true,
                  //           colors: controllers.leadColors[i],
                  //         ),
                  //       ],
                  //     ),
                  //     if(i!=controllers.leadCategoryList.length-1)
                  //     Padding(
                  //       padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                  //       child: Container(
                  //         height: 25,color: Colors.grey.shade300,width: 2,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  child: MouseRegion(
                    onEnter: (_) {
                      setState(() {
                        hoverIndex = i;
                      });
                    },
                    onExit: (_) {
                      setState(() {
                        hoverIndex = -1;
                      });
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 40,
                              width: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: controllers.leadColors[i].withOpacity(0.10),
                                shape: BoxShape.circle,
                              ),
                              child: Container(
                                height: 20,
                                width: 20,
                                decoration: BoxDecoration(
                                  color: controllers.leadColors[i],
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: CustomText(text: controllers.leadCategoryList[i].displayOrder.toString(),
                                    isCopy: false,isBold: true,colors: Colors.white,textAlign: TextAlign.center,),
                                ),
                              ),
                            ),
                            10.width,
                            Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: hoverIndex == i
                                    ? controllers.leadColors[i].withOpacity(0.08) // 🔥 hover color
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(
                                      // color:Colors.cyanAccent,
                                      width: MediaQuery.of(context).size.width*0.05,
                                      child: CustomText(
                                        text: controllers.leadCategoryList[i].value.toUpperCase(),
                                        isCopy: false,
                                        textAlign: TextAlign.start,
                                        size: 11,
                                        isBold: true,
                                        colors: controllers.leadColors[i],
                                      ),
                                    ),
                                    CustomText(
                                      text: controllers.leadCategoryList[i].list.length.toString(),
                                      isCopy: false,
                                      size: 14,
                                      isBold: true,
                                      colors: controllers.leadColors[i],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (i != controllers.leadCategoryList.length - 1)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                            child: Container(
                              height: 20,
                              color: Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
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
    return InkWell(
      onTap: () {
        setState(() {
          isLeadPanelOpen = !isLeadPanelOpen;
          if (isLeadPanelOpen) {
            _leadItemController.forward(from: 0);
          }
        });
      },
      child: Container(
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
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xffE5E7EB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(child: Image.asset(DashboardAssets.leadStage)),
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
      ),
    );
  }
}

BoxDecoration _whiteCard() => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(12),
  boxShadow: const [
    BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 4)),
  ],
);



class CDropdownField<T extends Object> extends StatefulWidget {
  final List<T> items;
  final Widget Function(T item) itemBuilder;
  final String Function(T item) labelBuilder;
  final String Function(T item)? subLabelBuilder; // 🔥 NEW
  final String Function(T item)? leadBuilder; // 🔥 NEW
  final void Function(T item)? onSelected;
  final String? initialText;
  final FocusNode? focusNode;
  final String? hintText;
  final String? labelText;
  final double borderRadius;
  final Color borderColor;
  final TextEditingController? textEditingController;
  final bool Function(String input, T item)? filterFn;
  final VoidCallback? onClear;

  const CDropdownField({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.labelBuilder,
    this.subLabelBuilder,
    this.onSelected,
    this.initialText,
    this.filterFn,
    this.focusNode,
    this.hintText,
    this.labelText,
    this.textEditingController,
    this.onClear,
    required this.borderRadius,
    required this.borderColor, this.leadBuilder,
  });

  @override
  State<CDropdownField<T>> createState() =>
      _CDropdownFieldState<T>();
}

class _CDropdownFieldState<T extends Object>
    extends State<CDropdownField<T>> {
  late TextEditingController controller;
  late FocusNode focusNode;
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    controller = widget.textEditingController ?? TextEditingController();
    focusNode = widget.focusNode ?? FocusNode();
    scrollController = ScrollController();

    if (widget.initialText != null && controller.text.isEmpty) {
      controller.text = widget.initialText!;
    }
  }

  @override
  void dispose() {
    if (widget.textEditingController == null) controller.dispose();
    if (widget.focusNode == null) focusNode.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<T>(
      textEditingController: controller,
      focusNode: focusNode,

      /// ✅ FIX 1: mobile + name search
      optionsBuilder: (TextEditingValue value) {
        final input = value.text.trim().toLowerCase();

        List<T> results = widget.items.toList();

        results.sort((a, b) => widget.labelBuilder(a)
            .toLowerCase()
            .compareTo(widget.labelBuilder(b).toLowerCase()));

        if (input.isEmpty) return results;

        final filtered = results.where((item) {
          if (widget.filterFn != null) {
            return widget.filterFn!(input, item);
          }

          final name = widget.labelBuilder(item).toLowerCase();

          final phone = widget.subLabelBuilder != null
              ? widget.subLabelBuilder!(item).toLowerCase()
              : "";

          return name.contains(input) || phone.contains(input);
        }).toList();

        return filtered;
      },

      displayStringForOption: widget.labelBuilder,

      /// ✅ FIX 2: value select ஆகணும்
      onSelected: (T item) {
        controller.text = widget.labelBuilder(item); // 🔥 முக்கியம்
        widget.onSelected?.call(item);
      },

      fieldViewBuilder: (context, ctrl, focus, onSubmit) {
        return SizedBox(
          height: 40,
          child: TextField(
            controller: ctrl,
            focusNode: focus,
            onSubmitted: (_) => onSubmit(),
            decoration: InputDecoration(
              prefixIcon: Image.asset("assets/images/search.png"),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              filled: true,
              fillColor: Colors.white,
              hintText: "Search Leads",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(color: widget.borderColor),
              ),
              suffixIcon: OutlinedButton(
                onPressed: () {
                  setState(() {
                    ctrl.clear();
                  });
                  widget.onClear?.call();
                },
                child: Icon(
                  controller.text.isEmpty
                      ? Icons.arrow_drop_down
                      : Icons.clear,
                ),
              ),
            ),
          ),
        );
      },

      optionsViewBuilder: (context, onSelected, options) {
        final highlightedIndex = AutocompleteHighlightedOption.of(context);
        final inputText = controller.text;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollController.hasClients && highlightedIndex >= 0) {
            scrollController.animateTo(
              highlightedIndex * 60,
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeInOut,
            );
          }
        });

        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            child: Container(
              width: MediaQuery.of(context).size.width / 4,
              constraints: const BoxConstraints(maxHeight: 250),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),

              /// ✅ FIX 3: proper "No results"
              child: options.isEmpty && inputText.isNotEmpty
                  ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: CustomText(
                    text: "No results found",
                    size: 13,
                    isCopy: false,
                  ),
                ),
              )
                  : Column(
                children: [
                  /// 👉 உங்க existing UI untouched
                  if (inputText.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          Image.asset("assets/images/search.png"),
                          10.width,
                          CustomText(
                            text: "Results for",
                            size: 12,
                            isCopy: false,
                            colors: Colors.grey.shade500,
                          ),
                          10.width,
                          Container(
                            decoration: customDecoration
                                .baseBackgroundDecoration(
                                color: Colors.grey.shade100,
                                radius: 5,
                                borderColor: Colors.black54),
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: CustomText(
                                text: inputText,
                                isBold: true,
                                size: 12,
                                isCopy: false,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  Divider(color: Colors.grey.shade200),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        SizedBox(
                            height: 30,
                            width: 30,
                            child: Image.asset("assets/images/people2.png")),
                        10.width,
                        CustomText(
                          isCopy: false,
                          text: "LEADS",
                          size: 12,
                          isBold: true,
                        ),
                        10.width,
                        Container(
                          decoration: customDecoration
                              .baseBackgroundDecoration(
                              color: Colors.grey.shade100,
                              radius: 5,
                              borderColor: Colors.grey.shade400),
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: CustomText(
                              text: options.length.toString(),
                              colors: Colors.grey,
                              size: 12,
                              isCopy: false,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  5.height,
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final option = options.elementAt(index);
                        final isHighlighted =
                            index == highlightedIndex;

                        final name =
                        widget.labelBuilder(option);

                        final subText = widget.subLabelBuilder != null
                            ? widget.subLabelBuilder!(option)
                            : "";

                        final status = widget.leadBuilder != null
                            ? widget.leadBuilder!(option)
                            : "";

                        return InkWell(
                          onTap: () => onSelected(option),
                          child: Container(
                            color: isHighlighted
                                ? Colors.blue.withOpacity(0.1)
                                : Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            child: Row(
                              children: [
                                Container(
                                  height: 30,
                                  width: 30,
                                  decoration: customDecoration
                                      .baseBackgroundDecoration(
                                      color: colorsConst.primary,
                                      radius: 10),
                                  child: Image.asset(
                                      "assets/images/people1.png"),
                                ),
                                10.width,
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      CustomText(
                                        text: name,
                                        size: 14,
                                        isCopy: false,
                                        isBold: true,
                                      ),
                                      if (subText.isNotEmpty)
                                        CustomText(
                                          text: subText,
                                          size: 12,
                                          isCopy: false,
                                          colors: Colors.grey,
                                        ),
                                    ],
                                  ),
                                ),
                                CustomText(
                                  text: status,
                                  size: 12,
                                  isCopy: false,
                                  colors: Colors.blue,
                                ),
                                10.width,
                                Icon(Icons.arrow_forward,
                                    size: 15,
                                    color: colorsConst.primary)
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (inputText.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 10, 10),
                        child: CustomText(text: "${options.length} result found", isCopy: false,colors: Colors.grey,),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:fullcomm_crm/controller/product_controller.dart';
import 'package:fullcomm_crm/screens/quotation/quotation_history.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/controller/dashboard_controller.dart';
import 'package:fullcomm_crm/screens/records/records.dart';
import 'package:fullcomm_crm/screens/reminder/reminder_page.dart';
import 'package:get/get.dart';
import '../common/constant/api.dart';
import '../common/constant/colors_constant.dart';
import '../common/constant/dashboard_assets.dart';
import '../common/styles/decoration.dart';
import '../common/utilities/dashboard_dialog.dart';
import '../common/utilities/reminder_utils.dart';
import '../common/utilities/test_download.dart';
import '../common/utilities/utils.dart';
import '../components/activity_over_time_chart.dart';
import '../components/custom_text.dart';
import '../components/customer_status_card.dart';
import '../components/pie_stat_card.dart';
import '../components/wave_stat_card.dart';
import '../controller/controller.dart';
import '../controller/new_payroll_controller.dart';
import '../controller/reminder_controller.dart';
import '../provider/employee_provider.dart';
import '../services/api_services.dart';
import '../services/new_payroll_api_services.dart';
import '../services/services/notification_service.dart';
import '../view_models/billing_provider.dart';
import 'employee/dashboard_emp_report.dart';
import 'leads/new_lead_page.dart';
import 'leads/rating_customer_page.dart';
import 'order/order_page.dart';

bool _crmSyncedThisSession = false;
bool _todayNotifiedThisSession = false;

class MobileDashboardPage extends StatefulWidget {
  const MobileDashboardPage({super.key});

  @override
  State<MobileDashboardPage> createState() => _MobileDashboardPageState();
}

class _MobileDashboardPageState extends State<MobileDashboardPage> {
  var services = NewPayrollApiServices.instance;
  final ScrollController _appScroll = ScrollController();
  final ScrollController _remScroll = ScrollController();
  final ScrollController _comScroll = ScrollController();

  static const double _pad = 12;

  // ───────────────────────── helpers ─────────────────────────

  String _fmt(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  String _next(String s) => s == "Last 7 Days"
      ? "Next 7 Days"
      : s == "Last 30 Days"
      ? "Next 30 Days"
      : s;

  void _openReminderPage() {
    remController.selectedReminderSortBy.value =
        _next(dashController.selectedSortBy.value);
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, a1, a2) => const ReminderPage(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
    controllers.oldIndex.value = controllers.selectedIndex.value;
    controllers.selectedIndex.value = 102;
  }

  void _openAppointmentPage() {
    remController.selectedMeetSortBy.value =
        _next(dashController.selectedSortBy.value);
    controllers.changeTab(2);
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, a1, a2) => const Records(isReload: "true"),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
    controllers.oldIndex.value = controllers.selectedIndex.value;
    controllers.selectedIndex.value = 101;
  }

  List<String> _pickCustomersToCall({int count = 5}) {
    final List<Map<String, dynamic>> picked = [];

    for (final l in controllers.allLeadList) {
      final firstName = (l.firstname ?? '').trim();
      final company = (l.companyName ?? '').trim();
      final name = firstName.isNotEmpty ? firstName : company;
      final phone = (l.mobileNumber ?? '').trim();

      if (name.isEmpty || name == 'null') continue;
      if (phone.isEmpty || phone == 'null') continue;

      DateTime? latest;
      for (final m in [l.lastCall, l.lastMail, l.lastMeeting, l.lastReminder]) {
        if (m == null) continue;
        final dt = DateTime.tryParse(m['created_ts']?.toString() ?? '');
        if (dt != null && (latest == null || dt.isAfter(latest))) latest = dt;
      }
      picked.add({'name': name, 'last': latest});
    }
    picked.sort((a, b) {
      final da = a['last'] as DateTime?;
      final db = b['last'] as DateTime?;
      if (da == null && db == null) return 0;
      if (da == null) return -1;
      if (db == null) return 1;
      return da.compareTo(db);
    });

    return picked.take(count).map((e) => e['name'] as String).toList();
  }

  Future<void> _showTodayNotifications() async {
    if (_todayNotifiedThisSession) return;
    _todayNotifiedThisSession = true;

    final allowed = await NotificationService.requestPermission();
    if (!allowed) return;

    final reminders = remController.getTodayReminders();
    final meetings = remController.getTodayMeetings();
    if (reminders.isEmpty && meetings.isEmpty) {
      final names = _pickCustomersToCall();

      if (names.isEmpty) {
        NotificationService.show(
          'No appointments or reminders today',
          'Your schedule is clear today. A good time to reach out to your leads!',
          tag: 'today-empty',
          sticky: true,
        );
      } else {
        NotificationService.show(
          'No appointments or reminders today',
          'Why not call these customers today?\n'
              '${names.map((n) => '• $n').join('\n')}',
          tag: 'today-empty',
          sticky: true,
        );
      }
      return;
    }

    for (final m in meetings) {
      final startTime = m.time.split('||').first.trim();
      final cus = m.cusName.trim();
      final com = m.comName.trim();
      final who = cus.isNotEmpty && com.isNotEmpty
          ? '$cus ($com)'
          : (cus.isNotEmpty ? cus : com);

      NotificationService.show(
        'Appointment today at $startTime',
        who.isEmpty
            ? 'You have an appointment "${m.title}". Would you like to view the details?'
            : 'Are you ready for your "${m.title}" meeting with $who? Would you like to view the details?',
        tag: 'meeting-${m.id}',
        sticky: true,
        onClick: _openAppointmentPage,
      );
      await Future.delayed(const Duration(milliseconds: 400));
    }

    for (final r in reminders) {
      final time = r.startDt.split(' ').skip(1).join(' ');
      final isFollowUp = r.type.toString() == '1';
      final customer = r.customerName.trim();

      NotificationService.show(
        '${isFollowUp ? "Follow-up" : "Reminder"} today at $time',
        customer.isNotEmpty
            ? 'Do you want to follow up with $customer about "${r.title}"? Open the Reminders page?'
            : 'Reminder: "${r.title}". Open the Reminders page?',
        tag: 'reminder-${r.id}',
        sticky: true,
        onClick: _openReminderPage,
      );
      await Future.delayed(const Duration(milliseconds: 400));
    }
  }

  Future<void> _runBatch(List<Future<void> Function()> tasks) async {
    await Future.wait(tasks.map((t) async {
      try {
        await t();
      } catch (e) {
        debugPrint("API error: $e");
      }
    }));
    await Future.delayed(const Duration(milliseconds: 300));
  }

  // ───────────────────────── lifecycle ─────────────────────────

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      dashController.selectedSortBy.value =
      "${controllers.storage.read("selectedSortBy") ?? "Today"}";
      controllers.selectedIndex.value = 100;
      remController.selectedMeetSortBy.value = dashController.selectedSortBy.value;
      remController.selectedCallSortBy.value = dashController.selectedSortBy.value;
      remController.selectedReminderSortBy.value = dashController.selectedSortBy.value;
      checkDate();

      final billing = Provider.of<BillingProvider>(context, listen: false);
      final employeeData = Provider.of<EmployeeProvider>(context, listen: false);

      await _runBatch([
            () async => apiService.getHeading(),
            () async => apiService.currentVersion(),
      ]);
      if (!mounted) return;

      final now = DateTime.now();
      final today = _fmt(now);
      final last7 = _fmt(now.subtract(const Duration(days: 7)));

      await _runBatch([
            () async => dashController.getCustomerReport(last7, today),
            () async => dashController.getWholeReport(),
            () async {
          if (remController.reminderList.isEmpty) await remController.allReminders("2");
        },
            () async {
          if (remController.callMailsDetailsList.isEmpty) await apiService.getMailCallActivity();
        },
      ]);
      if (!mounted) return;

      _refreshMeetings();
      remController.dashboardSortReminders();
      _refreshComm();

      await _runBatch([
            () async { if (controllers.leadCategoryList.isEmpty) await apiService.getLeadCategories(); },
            () async { if (controllers.allLeadList.isEmpty) await apiService.getCustomLeads(); },
            () async { if (controllers.allLeadCategoryList.isEmpty) await apiService.getAllLeadCategories(); },
            () async => apiService.getAllEmployees(),
      ]);
      if (!mounted) return;

      await _runBatch([
            () async { if (billing.productsList.isEmpty) await billing.getProducts(); },
            () async { if (productCtr.products.isEmpty) await productCtr.getProducts(); },
            () async { if (productCtr.ordersList.isEmpty) await productCtr.getOrderDetails(); },
            () async { if (productCtr.quotationsList.isEmpty) await productCtr.getQuotationDetails(); },
      ]);
      if (!mounted) return;

      await _runBatch([
            () async { if (productCtr.termsAndConditionsList.isEmpty) await productCtr.getTermsAndConditions(); },
            () async { if (pyrlCtr.settingList.isEmpty) await services.getRoleSettings(context); },
            () async { if (controllers.hCallStatusList.isEmpty) await controllers.getCallStatus(); },
            () async { if (controllers.industriesList.isEmpty) await controllers.getIndustries(); },
      ]);
      if (!mounted) return;

      await _runBatch([
            () async => employeeData.staffRoleDetailsData(context: context),
            () async { if (controllers.instagramCustomers.isEmpty) await apiService.getInstagramCustomers(); },
            () async => controllers.insertSeriesNo(context, true),
      ]);

      if (!_crmSyncedThisSession) {
        _crmSyncedThisSession = true;
        await apiService.syncContactsToCrm();
      }
      await _showTodayNotifications();
    });
  }

  void checkDate() {
    DateTime now = DateTime.now();
    switch (dashController.selectedSortBy.value) {
      case "Today":
        dashController.date1.value = _fmt(now);
        dashController.date2.value = dashController.date1.value;
        break;
      case "Yesterday":
        dashController.date1.value = _fmt(now.subtract(const Duration(days: 1)));
        dashController.date2.value = dashController.date1.value;
        break;
      case "Last 7 Days":
        dashController.date1.value = _fmt(now.subtract(const Duration(days: 6)));
        dashController.date2.value = _fmt(now);
        break;
      case "Last 30 Days":
        dashController.date1.value = _fmt(now.subtract(const Duration(days: 29)));
        dashController.date2.value = _fmt(now);
        break;
    }
    dashController.selectedRange.value = DateTimeRange(
      start: DateTime.parse(dashController.date1.value),
      end: DateTime.parse(dashController.date2.value),
    );
  }

  @override
  void dispose() {
    _appScroll.dispose();
    _remScroll.dispose();
    _comScroll.dispose();
    super.dispose();
  }

  // ───────────────────────── data refresh ─────────────────────────

  void _refreshMeetings() {
    remController.dashboardMeetings(
      searchText: controllers.searchText.value.toLowerCase(),
      callType: controllers.selectMeetingType.value,
      sortField: controllers.sortFieldMeetingActivity.value,
      sortOrder: controllers.sortOrderMeetingActivity.value,
    );
  }

  void _refreshComm() {
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
  }

  void _loadReports() {
    dashController.getWholeReport();
    final sel = dashController.selectedSortBy.value;
    if (sel != "Today" && sel != "Yesterday") {
      dashController.getCustomerReport(
          dashController.date1.value, dashController.date2.value);
    } else {
      final now = DateTime.now();
      dashController.getCustomerReport(
          _fmt(now.subtract(const Duration(days: 7))), _fmt(now));
    }
  }

  Future<void> _onFilterTap(String filter) async {
    dashController.selectedSortBy.value = filter;
    final now = DateTime.now();
    switch (filter) {
      case "Today":
        dashController.date1.value = _fmt(now);
        dashController.date2.value = dashController.date1.value;
        break;
      case "Yesterday":
        dashController.date1.value = _fmt(now.subtract(const Duration(days: 1)));
        dashController.date2.value = dashController.date1.value;
        break;
      case "Last 7 Days":
        dashController.date1.value = _fmt(now.subtract(const Duration(days: 6)));
        dashController.date2.value = _fmt(now);
        break;
      case "Last 30 Days":
        dashController.date1.value = _fmt(now.subtract(const Duration(days: 29)));
        dashController.date2.value = _fmt(now);
        break;
      case "Custom":
        final range = await dashController.showDatePickerDialog(context);
        if (range != null) {
          dashController.selectedRange.value = range;
          dashController.date1.value = _fmt(range.start);
          dashController.date2.value = _fmt(range.end);
          _loadReports();
        }
        return;
    }
    dashController.selectedRange.value = DateTimeRange(
      start: DateTime.parse(dashController.date1.value),
      end: DateTime.parse(dashController.date2.value),
    );
    _loadReports();

    remController.selectedMeetSortBy.value = filter;
    remController.selectedCallSortBy.value = filter;
    remController.selectedReminderSortBy.value = filter;
    _refreshMeetings();
    _refreshComm();
    remController.dashboardSortReminders();
  }

  Future<void> _refreshAll() async {
    _loadReports();
    _refreshMeetings();
    _refreshComm();
    remController.dashboardSortReminders();
    await Future.delayed(const Duration(milliseconds: 600));
  }

  DateTimeRange _shift(DateTimeRange r, int dir) {
    final d = Duration(days: (r.end.difference(r.start).inDays + 1) * dir);
    return DateTimeRange(start: r.start.add(d), end: r.end.add(d));
  }

  // ───────────────────────── sorting ─────────────────────────

  void _sortMeetings(String field) {
    final asc = controllers.sortFieldMeetingActivity.value == field &&
        controllers.sortOrderMeetingActivity.value == 'asc';
    controllers.sortOrderMeetingActivity.value = asc ? 'desc' : 'asc';
    controllers.sortFieldMeetingActivity.value = field;
    _refreshMeetings();
  }

  void _sortReminders(String field) {
    final current = field == 'customerName'
        ? remController.sortBy.value
        : remController.sortFieldCallActivity.value;
    final asc = current == field && remController.sortOrderCallActivity.value == 'asc';
    remController.sortOrderCallActivity.value = asc ? 'desc' : 'asc';
    if (field == 'customerName') {
      remController.sortBy.value = field;
    } else {
      remController.sortFieldCallActivity.value = field;
    }
    remController.dashboardSortReminders();
  }

  void _sortComm(String field) {
    final asc = controllers.sortFieldCallActivity.value == field &&
        controllers.sortOrderCallActivity.value == 'asc';
    controllers.sortOrderCallActivity.value = asc ? 'desc' : 'asc';
    controllers.sortFieldCallActivity.value = field;
    _refreshComm();
  }

  void _addAppointment() {
    final futureDate = DateTime.now().add(const Duration(days: 3));
    final adjustedDate = futureDate.weekday == DateTime.sunday
        ? futureDate.add(const Duration(days: 1))
        : futureDate;
    controllers.fDate.value = DateFormat('dd-MM-yyyy').format(adjustedDate);
    controllers.fTime.value =
        DateFormat('hh:mm a').format(DateTime.now().add(const Duration(minutes: 15)));
    controllers.toDate.value = DateFormat('dd-MM-yyyy').format(adjustedDate);
    controllers.toTime.value =
        DateFormat('hh:mm a').format(DateTime.now().add(const Duration(minutes: 30)));

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
  }

  // ───────────────────────── build ─────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: PopScope(
        canPop: false,
        child: Obx(() {
          if (controllers.isCrmData.value == false) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              _header(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshAll,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(_pad, 14, _pad, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _statCards(),
                        16.height,
                        _appointmentsCard(),
                        16.height,
                        _remindersCard(),
                        16.height,
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: EmployeePerformanceTable(width: 650),
                        ),
                        16.height,
                        _communicationCard(),
                        16.height,
                        _leadPie(),
                        if (dashController.customerStatusReport.isNotEmpty) ...[
                          16.height,
                          CustomerActivityCard(
                              width: MediaQuery.of(context).size.width - _pad * 2),
                        ],
                        16.height,
                        _visitStatus(),
                        16.height,
                        _comparisonCard(),
                        16.height,
                        _highValueCard(),
                        16.height,
                        ActivityOverTimeChart(
                          width: MediaQuery.of(context).size.width - _pad * 2,
                          xLabels: controllers.xLabels.toList(),
                          lines: [
                            ActivityLineData(
                                label: "Calls",
                                values: controllers.calls.toList(),
                                color: const Color(0xFF0F8D4B)),
                            ActivityLineData(
                                label: "Mails",
                                values: controllers.mails.toList(),
                                color: const Color(0xFFEB3342)),
                            ActivityLineData(
                                label: "Updates",
                                values: controllers.updates.toList(),
                                color: const Color(0xFF1596E0)),
                          ],
                        ),
                        16.height,
                        _portfolioHeat(),
                        16.height,
                        _leadStagesCard(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ───────────────────────── header ─────────────────────────

  Widget _header() {
    return Container(
      decoration: _topBarDecoration(),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (controllers.comName.text.isNotEmpty) ...[
                        CustomText(
                            text: controllers.comName.text,
                            size: 16,
                            isBold: true,
                            isCopy: false,
                            colors: Colors.white),
                        4.height,
                      ],
                      CustomText(
                          text: "ARUU's EasyCRM",
                          size: 18,
                          isBold: true,
                          isCopy: false,
                          colors: Colors.white),
                      4.height,
                      CustomText(
                          text: "Hi, ${controllers.storage.read("f_name") ?? ""}",
                          size: 14,
                          isBold: true,
                          isCopy: false,
                          colors: Colors.white),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CustomText(
                        text: version,
                        size: 11,
                        isCopy: false,
                        colors: Colors.white,
                        isBold: true),
                    6.height,
                    _syncText(),
                  ],
                ),
              ],
            ),
            12.height,
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: _filterGroupDecoration(),
                child: Row(
                  children: dashController.filters.map<Widget>((filter) {
                    final bool isSelected =
                        dashController.selectedSortBy.value == filter;
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _onFilterTap(filter),
                      child: Container(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: isSelected
                              ? const [
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 2))
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
                    );
                  }).toList(),
                ),
              ),
            ),
            10.height,
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    color: Colors.white, size: 15),
                6.width,
                Obx(() {
                  final range = dashController.selectedRange.value;
                  if (range == null) {
                    return const CustomText(
                        text: "Filter by Date Range",
                        isCopy: false,
                        isBold: true,
                        colors: Colors.white);
                  }
                  return CustomText(
                      text: range.start == range.end
                          ? "${range.start.day}-${range.start.month}-${range.start.year}"
                          : "${range.start.day}-${range.start.month}-${range.start.year} - "
                          "${range.end.day}-${range.end.month}-${range.end.year}",
                      isBold: true,
                      isCopy: false,
                      colors: Colors.white);
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _syncText() {
    return Obx(() {
      if (dashController.timestamp.value.isEmpty) {
        return const CustomText(
            isCopy: false,
            text: "Last Sync · --",
            size: 12,
            isBold: true,
            colors: Colors.white);
      }
      final diff =
      DateTime.now().difference(DateTime.parse(dashController.timestamp.value));
      String timeText;
      if (diff.inSeconds < 60) {
        timeText = "Just now";
      } else if (diff.inMinutes < 60) {
        timeText = "${diff.inMinutes} mins ago";
      } else if (diff.inHours < 24) {
        timeText = "${diff.inHours} hrs ago";
      } else {
        timeText = "${diff.inDays} days ago";
      }
      return CustomText(
          text: "Last Sync · $timeText",
          size: 12,
          isBold: true,
          isCopy: false,
          colors: Colors.white);
    });
  }

  // ───────────────────────── stat cards (horizontal scroll) ─────────────────────────

  Widget _statCards() {
    final maxValue = [1596, 256, 65, 264, 6].reduce((a, b) => a > b ? a : b);

    final cards = <Widget>[
      WaveStatCard(
        callback: () {
          controllers.selectedQualifiedSortBy.value = dashController.selectedSortBy.value;
          controllers.isLeadsExpanded.value = true;
          setState(() {
            controllers.selectedIndex.value =
                int.parse(controllers.leadCategoryList[0].leadStatus);
          });
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, a1, a2) => NewLeadPage(
                index: controllers.leadCategoryList[0].leadStatus,
                name: controllers.leadCategoryList[0].value,
                list: controllers.leadCategoryList[0].list,
                list2: controllers.leadCategoryList[0].list2,
                listIndex: 0,
              ),
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
      ),
      WaveStatCard(
        callback: _openAppointmentPage,
        title: "Appointments",
        numericValue: remController.dMeetings.length,
        maxValue: maxValue,
        iconPath: DashboardAssets.date,
        valueColor: const Color(0xff8B2CF5),
      ),
      WaveStatCard(
        callback: _openReminderPage,
        title: "Reminders",
        numericValue: remController.reminderFilteredList2.length,
        maxValue: maxValue,
        iconPath: DashboardAssets.alarm,
        valueColor: const Color(0xffBB271A),
      ),
      WaveStatCard(
        callback: () {
          productCtr.selectedCallSortBy.value = dashController.selectedSortBy.value;
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, a1, a2) => const OrderPage(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
          controllers.oldIndex.value = controllers.selectedIndex.value;
          controllers.selectedIndex.value = 106;
        },
        title: "Orders",
        numericValue: int.parse(dashController.totalOrders.value.toString()),
        maxValue: maxValue,
        iconPath: DashboardAssets.cart,
        amt: productCtr.formatAmount2(dashController.totalAmt.value),
        valueColor: Colors.pink,
      ),
      WaveStatCard(
        callback: () {
          productCtr.selectedCallSortBy.value = dashController.selectedSortBy.value;
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, a1, a2) => const QuotationHistory(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
          controllers.oldIndex.value = controllers.selectedIndex.value;
          controllers.selectedIndex.value = 107;
        },
        title: "Quotations",
        numericValue: int.parse(dashController.totalQuotations.value.toString()),
        amt: productCtr.formatAmount2(dashController.totalQuotationsAmt.value),
        maxValue: maxValue,
        iconPath: DashboardAssets.quo,
        valueColor: Colors.brown,
      ),
    ];

    return SizedBox(
      height: 125,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: cards.length,
        separatorBuilder: (_, __) => 12.width,
        itemBuilder: (_, i) => SizedBox(width: 190, child: cards[i]),
      ),
    );
  }

  // ───────────────────────── reusable pieces ─────────────────────────

  Widget _card({required Widget child}) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [
        BoxShadow(blurRadius: 10, color: Colors.black12, offset: Offset(0, 4))
      ],
    ),
    child: child,
  );

  Widget _segment(String selected, void Function(String) onTap) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: _filterGroupDecoration(),
      child: Row(
        children: dashController.filterType.map<Widget>((filter) {
          final bool isSelected = selected == filter;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(filter),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 7),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? const [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2))
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
  }

  Widget _dateNav({
    required DateTimeRange? range,
    required VoidCallback onPrev,
    required VoidCallback onPick,
    required VoidCallback onNext,
  }) {
    String label;
    if (range == null) {
      label = DateFormat("dd-MM-yyyy").format(DateTime.now());
    } else if (range.start.year == range.end.year &&
        range.start.month == range.end.month &&
        range.start.day == range.end.day) {
      label = DateFormat("dd-MM-yyyy").format(range.start);
    } else {
      label =
      "${DateFormat("dd-MM-yyyy").format(range.start)} - ${DateFormat("dd-MM-yyyy").format(range.end)}";
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
            onTap: onPrev,
            child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(Icons.arrow_back, color: colorsConst.primary, size: 18))),
        InkWell(
            onTap: onPick,
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: CustomText(text: label, isCopy: false))),
        InkWell(
            onTap: onNext,
            child: Padding(
                padding: const EdgeInsets.all(6),
                child:
                Icon(Icons.arrow_forward, color: colorsConst.primary, size: 18))),
      ],
    );
  }

  Widget _addButton(VoidCallback onTap) => InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: colorsConst.primary, borderRadius: BorderRadius.circular(6)),
      child: const Icon(Icons.add, color: Colors.white, size: 18),
    ),
  );

  Widget _sortMenu(Map<String, String> fields, void Function(String) onSelected) {
    return PopupMenuButton<String>(
      tooltip: 'Sort',
      icon: Icon(Icons.swap_vert, color: colorsConst.primary),
      onSelected: onSelected,
      itemBuilder: (_) => fields.entries
          .map((e) => PopupMenuItem<String>(value: e.key, child: Text(e.value)))
          .toList(),
    );
  }

  Widget _cardTitle(String title, String? subtitle) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CustomText(text: title, isCopy: false, isBold: true, size: 15),
      if (subtitle != null) ...[
        4.height,
        CustomText(
            text: subtitle, isCopy: false, size: 13, colors: Colors.grey),
      ],
    ],
  );

  Widget _emptyBox(String text) => SizedBox(
    height: 120,
    child: Center(
        child: CustomText(
            text: text, isCopy: false, colors: colorsConst.textColor, size: 15)),
  );

  Widget _row({required int index, required VoidCallback onTap, required Widget child}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: index % 2 == 0 ? Colors.white : Colors.grey.shade100,
          border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        ),
        child: child,
      ),
    );
  }

  String _clean(dynamic v) {
    final s = v.toString();
    return s == "null" ? "" : s;
  }

  // ───────────────────────── appointments ─────────────────────────

  Widget _appointmentsCard() {
    final list = remController.dMeetings;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: _openAppointmentPage,
                child: CustomText(
                    text: "Appointments",
                    isCopy: false,
                    isBold: true,
                    size: 15,
                    colors: colorsConst.primary),
              ),
              10.width,
              _addButton(_addAppointment),
              const Spacer(),
              _sortMenu(const {
                'customerName': 'Lead Name',
                'companyName': 'Company',
                'emp': 'Employee',
                'date': 'Date & Time',
              }, _sortMeetings),
            ],
          ),
          _dateNav(
            range: remController.selectedCallRange.value,
            onPrev: () {
              final r = remController.selectedCallRange.value;
              if (r == null) return;
              remController.selectedCallRange.value = _shift(r, -1);
              _refreshMeetings();
            },
            onPick: () {
              remController.showDatePickerDialog(context, (pickedRange) {
                remController.selectedMeetSortBy.value = "Custom Range";
                remController.selectedCallRange.value = pickedRange;
                _refreshMeetings();
              }, true);
            },
            onNext: () {
              final r = remController.selectedCallRange.value;
              if (r == null) return;
              final n = _shift(r, 1);
              if (n.end.isAfter(DateTime.now())) return;
              remController.selectedCallRange.value = n;
              _refreshMeetings();
            },
          ),
          6.height,
          _segment(remController.filterApp.value, (f) {
            remController.filterApp.value = f;
            _refreshMeetings();
          }),
          8.height,
          if (list.isEmpty)
            _emptyBox("No Appointments")
          else
            SizedBox(
              height: 260,
              child: ListView.builder(
                controller: _appScroll,
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final data = list[index];
                  return _row(
                    index: index,
                    onTap: () => showMeetingDialog(context, list, index),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                  text: _clean(data.cusName),
                                  size: 14,
                                  isBold: true,
                                  isCopy: false,
                                  textAlign: TextAlign.left,
                                  colors: colorsConst.textColor),
                              2.height,
                              CustomText(
                                  text: _clean(data.comName),
                                  size: 12,
                                  isCopy: false,
                                  textAlign: TextAlign.left,
                                  colors: Colors.grey),
                              2.height,
                              CustomText(
                                  text: _clean(data.employeeName),
                                  size: 12,
                                  isCopy: false,
                                  textAlign: TextAlign.left,
                                  colors: colorsConst.primary),
                            ],
                          ),
                        ),
                        8.width,
                        Flexible(
                          child: CustomText(
                              text: utils.formatDateTime(data.dates, data.time),
                              size: 12,
                              isCopy: false,
                              textAlign: TextAlign.right,
                              colors: colorsConst.textColor),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  // ───────────────────────── reminders ─────────────────────────

  Widget _remindersCard() {
    final list = remController.reminderFilteredList2;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: _openReminderPage,
                child: CustomText(
                    text: "Reminders",
                    isCopy: false,
                    isBold: true,
                    size: 15,
                    colors: colorsConst.primary),
              ),
              10.width,
              _addButton(() => reminderUtils.showAddReminderDialog(context)),
              const Spacer(),
              _sortMenu(const {
                'title': 'Event Name',
                'type': 'Type',
                'customerName': 'Lead Name',
                'employeeName': 'Employee',
                'startDate': 'Date & Time',
              }, _sortReminders),
            ],
          ),
          _dateNav(
            range: remController.selectedReminderRange.value,
            onPrev: () {
              final r = remController.selectedReminderRange.value;
              if (r == null) return;
              remController.selectedReminderRange.value = _shift(r, -1);
              remController.dashboardSortReminders();
            },
            onPick: () {
              remController.showDatePickerDialog(context, (pickedRange) {
                remController.selectedReminderSortBy.value = "Custom Range";
                remController.selectedReminderRange.value = pickedRange;
                remController.dashboardSortReminders();
              }, true);
            },
            onNext: () {
              final r = remController.selectedReminderRange.value;
              if (r == null) return;
              final n = _shift(r, 1);
              if (n.end.isAfter(DateTime.now())) return;
              remController.selectedReminderRange.value = n;
              remController.dashboardSortReminders();
            },
          ),
          6.height,
          _segment(remController.filterRem.value, (f) {
            remController.filterRem.value = f;
            remController.dashboardSortReminders();
          }),
          8.height,
          if (list.isEmpty)
            _emptyBox("No Reminders")
          else
            SizedBox(
              height: 260,
              child: ListView.builder(
                controller: _remScroll,
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final data = list[index];
                  final isFollow = data.type.toString() == "1";
                  return _row(
                    index: index,
                    onTap: () => showReminderDialog(context, list, index),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: CustomText(
                                  text: data.title.toString(),
                                  size: 14,
                                  isBold: true,
                                  isCopy: false,
                                  textAlign: TextAlign.left,
                                  colors: colorsConst.textColor),
                            ),
                            8.width,
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isFollow
                                    ? Colors.orange.shade50
                                    : Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: CustomText(
                                  text: isFollow ? "Follow-up" : "Appointment",
                                  size: 11,
                                  isBold: true,
                                  isCopy: false,
                                  colors: isFollow ? Colors.orange : Colors.blue),
                            ),
                          ],
                        ),
                        4.height,
                        CustomText(
                            text: _clean(data.customerName),
                            size: 12,
                            isCopy: false,
                            textAlign: TextAlign.left,
                            colors: Colors.grey),
                        2.height,
                        Row(
                          children: [
                            Expanded(
                              child: CustomText(
                                  text: data.employeeName.toString(),
                                  size: 12,
                                  isCopy: false,
                                  textAlign: TextAlign.left,
                                  colors: colorsConst.primary),
                            ),
                            CustomText(
                                text: controllers.formatDate(data.startDt.toString()),
                                size: 12,
                                isCopy: false,
                                colors: colorsConst.textColor),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  // ───────────────────────── communication ─────────────────────────

  Widget _communicationCard() {
    final list = remController.callMailsDetailsList;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _cardTitle("Communication Details",
                    "Communication insights based on calls and emails."),
              ),
              _sortMenu(const {
                'customerName': 'Lead Name',
                'company': 'Company',
                'date': 'Call Date',
                'type': 'In/Out',
                'addedBy': 'Added By',
              }, _sortComm),
            ],
          ),
          10.height,
          _segment(remController.filterCall.value, (f) {
            remController.filterCall.value = f;
            _refreshComm();
          }),
          8.height,
          if (list.isEmpty)
            _emptyBox("No Communication Details Found")
          else
            SizedBox(
              height: 280,
              child: ListView.builder(
                controller: _comScroll,
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final data = list[index];
                  final isMail =
                      data.callStatus == "null" || data.callStatus == "";
                  return _row(
                    index: index,
                    onTap: () => showCallDialog(context, list, index),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: (isMail ? Colors.red : Colors.green)
                                .withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(isMail ? Icons.mail_outline : Icons.call,
                              size: 16,
                              color: isMail ? Colors.red : Colors.green),
                        ),
                        10.width,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                  text: _clean(data.customerName),
                                  size: 14,
                                  isBold: true,
                                  isCopy: false,
                                  textAlign: TextAlign.left,
                                  colors: colorsConst.textColor),
                              2.height,
                              CustomText(
                                  text: _clean(data.companyName),
                                  size: 12,
                                  isCopy: false,
                                  textAlign: TextAlign.left,
                                  colors: Colors.grey),
                              2.height,
                              CustomText(
                                  text: "${data.callType} • ${data.name}",
                                  size: 12,
                                  isCopy: false,
                                  textAlign: TextAlign.left,
                                  colors: colorsConst.primary),
                            ],
                          ),
                        ),
                        8.width,
                        Flexible(
                          child: CustomText(
                              text: data.sentDate.toString(),
                              size: 11,
                              isCopy: false,
                              textAlign: TextAlign.right,
                              colors: colorsConst.textColor),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  // ───────────────────────── charts ─────────────────────────

  Widget _leadPie() {
    return SizedBox(
      height: 300,
      child: LeadPieCard(
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
        ],
      ),
    );
  }

  Widget _visitStatus() {
    return InkWell(
      onTap: () {
        remController.selectedCallSortBy.value = dashController.selectedSortBy.value;
        controllers.changeTab(0);
        controllers.selectCallType.value = "All";
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, a1, a2) => const Records(isReload: "true"),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        controllers.oldIndex.value = controllers.selectedIndex.value;
        controllers.selectedIndex.value = 101;
      },
      child: SizedBox(
        height: 310,
        child: CustomerStatusCard(
          items: [
            for (var i = 0; i < dashController.visitStatusReport.length; i++)
              CustomerStatusItem(
                label: dashController.visitStatusReport[i]["value"].toString(),
                value: int.parse(
                    dashController.visitStatusReport[i]["total_count"].toString()),
                percentage: dashController.total == 0
                    ? 0
                    : double.parse(dashController.visitStatusReport[i]["total_count"]
                    .toString()) /
                    dashController.total,
              ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── lead comparison ─────────────────────────

  Widget _comparisonCard() {
    final weekly = dashController.selectFilter.value == "Weekly";
    final Iterable list =
    weekly ? dashController.comparisonReport : dashController.comparisonReport2;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle("Lead Comparison Report",
              "Compare lead progress across categories on a weekly or monthly basis."),
          10.height,
          Container(
            padding: const EdgeInsets.all(4),
            decoration: _filterGroupDecoration(),
            child: Row(
              children: dashController.repType.map<Widget>((filter) {
                final bool isSelected = dashController.selectFilter.value == filter;
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => dashController.selectFilter.value = filter,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
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
          ),
          12.height,
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: colorsConst.primary,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5), topRight: Radius.circular(5)),
            ),
            child: Row(
              children: [
                const Expanded(
                    flex: 3,
                    child: CustomText(
                        text: "Category",
                        isCopy: false,
                        isBold: true,
                        colors: Colors.white,
                        size: 13,
                        textAlign: TextAlign.start)),
                Expanded(
                    flex: 2,
                    child: CustomText(
                        text: weekly ? "Last Week" : "Last Month",
                        isCopy: false,
                        isBold: true,
                        colors: Colors.white,
                        size: 13,
                        textAlign: TextAlign.center)),
                Expanded(
                    flex: 2,
                    child: CustomText(
                        text: weekly ? "This Week" : "This Month",
                        isCopy: false,
                        isBold: true,
                        colors: Colors.white,
                        size: 13,
                        textAlign: TextAlign.center)),
                const Expanded(
                    flex: 2,
                    child: CustomText(
                        text: "Change",
                        isCopy: false,
                        isBold: true,
                        colors: Colors.white,
                        size: 13,
                        textAlign: TextAlign.center)),
              ],
            ),
          ),
          5.height,
          for (final e in list) _comparisonRow(e),
          8.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.report_gmailerrorred_sharp,
                  color: Colors.grey, size: 18),
              5.width,
              const Flexible(
                child: CustomText(
                    text: "Changes show the difference between the selected periods",
                    isCopy: false,
                    size: 12,
                    colors: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _comparisonRow(dynamic e) {
    final int last = int.tryParse(e['last_week']?.toString() ?? '0') ?? 0;
    final int current = int.tryParse(e['this_week']?.toString() ?? '0') ?? 0;
    final int diff = current - last;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  flex: 3,
                  child: CustomText(
                      text: e['category'] ?? '',
                      isCopy: false,
                      isBold: true,
                      textAlign: TextAlign.start)),
              Expanded(
                  flex: 2,
                  child: CustomText(
                      text: "$last",
                      isCopy: false,
                      isBold: true,
                      textAlign: TextAlign.center)),
              Expanded(
                  flex: 2,
                  child: CustomText(
                      text: "$current",
                      isCopy: false,
                      isBold: true,
                      textAlign: TextAlign.center)),
              Expanded(
                flex: 2,
                child: Container(
                  height: 22,
                  alignment: Alignment.center,
                  decoration: customDecoration.baseBackgroundDecoration(
                    color: diff > 0
                        ? Colors.green.shade50
                        : diff < 0
                        ? Colors.red.shade50
                        : Colors.grey.shade50,
                    radius: 20,
                  ),
                  child: CustomText(
                    text: diff > 0
                        ? "▲ ${diff.toString().padLeft(2, "0")}"
                        : diff < 0
                        ? "▼ ${diff.abs().toString().padLeft(2, "0")}"
                        : "-",
                    colors: diff > 0
                        ? Colors.green
                        : diff < 0
                        ? Colors.red
                        : Colors.grey,
                    isBold: true,
                    isCopy: false,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          const Divider(thickness: 0.1, color: Colors.grey),
        ],
      ),
    );
  }

  // ───────────────────────── high value customers ─────────────────────────

  Widget _highValueCard() {
    return InkWell(
      onTap: () {
        productCtr.selectedCallSortBy.value = dashController.selectedSortBy.value;
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, a1, a2) => const QuotationHistory(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        controllers.oldIndex.value = controllers.selectedIndex.value;
        controllers.selectedIndex.value = 107;
      },
      child: _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                    child:
                    _cardTitle("High-Value Customer", "Based on Quotation Amount")),
                8.width,
                Container(
                  decoration: customDecoration.baseBackgroundDecoration(
                      color: const Color(0xFFD2EBFF).withOpacity(0.2),
                      radius: 10,
                      borderColor: Colors.grey.shade100),
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        backgroundColor: Color(0xFFD2EBFF),
                        child: CustomText(
                            text: "₹",
                            isCopy: false,
                            isBold: true,
                            colors: Colors.blue,
                            size: 15),
                      ),
                      6.width,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CustomText(
                              text: "Total Value", isCopy: false, isBold: true, size: 12),
                          2.height,
                          CustomText(
                              text: productCtr
                                  .formatAmount(dashController.totalQuotationAmt.value),
                              isCopy: false,
                              isBold: true,
                              size: 13,
                              colors: Colors.blue),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            for (int index = dashController.ranges.length - 1; index >= 0; index--)
              _rangeBlock(index),
          ],
        ),
      ),
    );
  }

  Widget _rangeBlock(int index) {
    final range = dashController.ranges[index];
    final items = dashController.groupedData[range] ?? [];
    final color = dashController.colorList[index];

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: customDecoration.baseBackgroundDecoration(
            color: Colors.white, radius: 10, borderColor: Colors.grey.shade200),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.shade100,
              child: Icon(Icons.keyboard_double_arrow_up, color: color),
            ),
            10.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomText(text: range, isCopy: false, size: 16, isBold: true),
                      5.width,
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: customDecoration.baseBackgroundDecoration(
                            color: color.shade100, radius: 15),
                        child: CustomText(
                            text: '${items.length}',
                            isCopy: false,
                            isBold: true,
                            colors: color),
                      ),
                    ],
                  ),
                  if (items.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: CustomText(
                          text: 'No quotations found',
                          isCopy: false,
                          colors: Colors.grey),
                    )
                  else
                    ...items.map<Widget>(
                          (e) => Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                      text: "${e['q_no']} • ${e['company_name']}",
                                      isCopy: false,
                                      isBold: true,
                                      size: 13,
                                      textAlign: TextAlign.start,
                                      colors: Colors.grey),
                                  CustomText(
                                      text: "${e['category']}",
                                      isCopy: false,
                                      isBold: true,
                                      size: 12,
                                      textAlign: TextAlign.start,
                                      colors: color),
                                ],
                              ),
                            ),
                            8.width,
                            CustomText(
                                text: productCtr.formatAmount(e['total_amt']),
                                isCopy: false,
                                isBold: true,
                                size: 13,
                                colors: color),
                          ],
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

  // ───────────────────────── portfolio heat ─────────────────────────

  Widget _heatTile({
    required String asset,
    required String label,
    required String count,
    required Color color,
    required Color bg,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 90,
          decoration: customDecoration.baseBackgroundDecoration(color: bg, radius: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image.asset(asset, height: 34),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(text: label, isCopy: false, isBold: true, colors: color),
                  5.width,
                  CustomText(
                      text: "${int.tryParse(count) ?? 0}",
                      isCopy: false,
                      isBold: true,
                      colors: color),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _portfolioHeat() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle("Portfolio Heat",
              "Visualize the current engagement health of your portfolio."),
          12.height,
          const Divider(height: 1, thickness: 1, color: Color(0xffE5E7EB)),
          12.height,
          const CustomText(
              text: "Customer Engagement Levels",
              isCopy: false,
              size: 13,
              colors: Color(0xff6B7280)),
          10.height,
          Row(
            children: [
              _heatTile(
                asset: "assets/images/hot.png",
                label: "Hot",
                count: dashController.totalHot2.value,
                color: const Color(0xFFEF4444),
                bg: const Color(0xFFFFF2F2),
                onTap: dashController.totalHot2.value != "0"
                    ? () => Get.to(
                    RatingPage(rep: "1", type: "Hot", pageName: 'Customer'))
                    : null,
              ),
              10.width,
              _heatTile(
                asset: "assets/images/warm.png",
                label: "Warm",
                count: dashController.totalWarm2.value,
                color: const Color(0xFFF59E0B),
                bg: const Color(0xFFFFF8ED),
                onTap: dashController.totalWarm2.value != "0"
                    ? () => Get.to(
                    RatingPage(rep: "1", type: "Warm", pageName: 'Customer'))
                    : null,
              ),
              10.width,
              _heatTile(
                asset: "assets/images/cold.png",
                label: "Cold",
                count: dashController.totalCold2.value,
                color: const Color(0xFF3B82F6),
                bg: const Color(0xFFF0F6FF),
                onTap: dashController.totalCold2.value != "0"
                    ? () => Get.to(
                    RatingPage(rep: "1", type: "Cold", pageName: 'Customer'))
                    : null,
              ),
            ],
          ),
          14.height,
          const Divider(height: 1, thickness: 1, color: Color(0xffD1D5DB)),
          12.height,
          const CustomText(
              text: "Lead Engagement Levels",
              isCopy: false,
              size: 13,
              colors: Color(0xff6B7280)),
          10.height,
          Row(
            children: [
              _heatTile(
                asset: "assets/images/hot.png",
                label: "Hot",
                count: dashController.totalHot.value,
                color: const Color(0xFFEF4444),
                bg: const Color(0xFFFFF2F2),
                onTap: dashController.totalHot.value != "0"
                    ? () =>
                    Get.to(RatingPage(rep: "2", type: "Hot", pageName: 'Leads'))
                    : null,
              ),
              10.width,
              _heatTile(
                asset: "assets/images/warm.png",
                label: "Warm",
                count: dashController.totalWarm.value,
                color: const Color(0xFFF59E0B),
                bg: const Color(0xFFFFF8ED),
                onTap: dashController.totalWarm.value != "0"
                    ? () =>
                    Get.to(RatingPage(rep: "2", type: "Warm", pageName: 'Leads'))
                    : null,
              ),
              10.width,
              _heatTile(
                asset: "assets/images/cold.png",
                label: "Cold",
                count: dashController.totalCold.value,
                color: const Color(0xFF3B82F6),
                bg: const Color(0xFFF0F6FF),
                onTap: dashController.totalCold.value != "0"
                    ? () =>
                    Get.to(RatingPage(rep: "2", type: "Cold", pageName: 'Leads'))
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ───────────────────────── lead stages ─────────────────────────

  Widget _summaryPill(String value, String label) => Expanded(
    child: Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: customDecoration.baseBackgroundDecoration(
          color: colorsConst.primary, radius: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
              text: value,
              size: 16,
              isCopy: false,
              colors: Colors.white,
              isBold: true),
          CustomText(text: label, isCopy: false, size: 12, colors: Colors.white),
        ],
      ),
    ),
  );

  Widget _leadStagesCard() {
    final cats = controllers.leadCategoryList;
    final totalLeads = cats.isEmpty
        ? 0
        : cats.fold<int>(0, (sum, item) => sum + (item.list2.length as int)) -
        (cats.last.list2.length as int);
    final totalCustomers = cats.isEmpty ? 0 : cats.last.list2.length;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CustomText(
                  text: "LEAD STAGES", isCopy: false, size: 14, isBold: true),
              10.width,
              SizedBox(height: 24, child: Image.asset(DashboardAssets.leadStage)),
            ],
          ),
          6.height,
          const CustomText(
              text: "Life Time Customer Journey", isCopy: false, colors: Colors.blue),
          12.height,
          Row(
            children: [
              _summaryPill("$totalLeads", "total leads"),
              10.width,
              _summaryPill("$totalCustomers", "total customers"),
            ],
          ),
          12.height,
          for (int i = 0; i < cats.length; i++)
            InkWell(
              onTap: () {
                controllers.oldIndex.value = controllers.selectedIndex.value;
                controllers.selectedIndex.value = 500;
                controllers.isLeadsExpanded.toggle();
                if (controllers.selectedQualifiedSortBy.value == "") {
                  controllers.selectedQualifiedSortBy.value = "All";
                }
                controllers.isSettingsExpanded.value = false;
                controllers.isPayrollExpanded.value = false;
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, a1, a2) => NewLeadPage(
                      index: cats[i].leadStatus,
                      name: cats[i].value,
                      list: cats[i].list,
                      list2: cats[i].list2,
                      listIndex: i,
                    ),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
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
                          height: 22,
                          width: 22,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: controllers.leadColors[i], shape: BoxShape.circle),
                          child: CustomText(
                              text: cats[i].displayOrder.toString(),
                              isCopy: false,
                              isBold: true,
                              colors: Colors.white,
                              textAlign: TextAlign.center),
                        ),
                      ),
                      12.width,
                      Expanded(
                        child: CustomText(
                            text: cats[i].value.toUpperCase(),
                            isCopy: false,
                            textAlign: TextAlign.start,
                            size: 12,
                            isBold: true,
                            colors: controllers.leadColors[i]),
                      ),
                      CustomText(
                          text: cats[i].list2.length.toString(),
                          isCopy: false,
                          size: 14,
                          isBold: true,
                          colors: controllers.leadColors[i]),
                      6.width,
                      Icon(Icons.chevron_right, size: 18, color: Colors.grey.shade500),
                    ],
                  ),
                  if (i != cats.length - 1)
                    Padding(
                      padding: const EdgeInsets.only(left: 19),
                      child: Container(height: 18, width: 2, color: Colors.grey.shade300),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ───────────────────────── decorations ─────────────────────────

  BoxDecoration _filterGroupDecoration() => BoxDecoration(
    color: const Color(0xffE2E8F0),
    borderRadius: BorderRadius.circular(8),
  );

  BoxDecoration _topBarDecoration() => BoxDecoration(
    color: colorsConst.primary,
    boxShadow: const [
      BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
    ],
  );
}
import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/controller/product_controller.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../common/constant/api.dart';
import '../common/constant/colors_constant.dart';
import '../common/constant/dashboard_assets.dart';
import '../common/styles/decoration.dart';
import '../common/utilities/dashboard_dialog.dart';
import '../common/utilities/reminder_utils.dart';
import '../common/utilities/utils.dart';
import '../components/activity_over_time_chart.dart';
import '../components/custom_text.dart';
import '../components/customer_status_card.dart';
import '../components/pie_stat_card.dart';
import '../controller/controller.dart';
import '../controller/dashboard_controller.dart';
import '../controller/new_payroll_controller.dart';
import '../controller/reminder_controller.dart';
import '../provider/employee_provider.dart';
import '../services/api_services.dart';
import '../services/new_payroll_api_services.dart';
import '../services/services/notification_service.dart';
import '../view_models/billing_provider.dart';
import 'employee/dashboard_emp_report.dart';

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

  // ---------------------------------------------------------------- helpers
  String _fmt(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

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
      NotificationService.show(
        'No appointments or reminders today',
        names.isEmpty
            ? 'Your schedule is clear today. A good time to reach out to your leads!'
            : 'Why not call these customers today?\n${names.map((n) => '• $n').join('\n')}',
        tag: 'today-empty',
        sticky: true,
      );
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
            ? 'You have an appointment "${m.title}".'
            : 'Are you ready for your "${m.title}" meeting with $who?',
        tag: 'meeting-${m.id}',
        sticky: true,
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
            ? 'Do you want to follow up with $customer about "${r.title}"?'
            : 'Reminder: "${r.title}".',
        tag: 'reminder-${r.id}',
        sticky: true,
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

  // ------------------------------------------------------------------ init
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
        () async => dashController.getToken(),
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

      _refreshLists();

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

  void _refreshMeetings() => remController.dashboardMeetings(
        searchText: controllers.searchText.value.toLowerCase(),
        callType: controllers.selectMeetingType.value,
        sortField: controllers.sortFieldMeetingActivity.value,
        sortOrder: controllers.sortOrderMeetingActivity.value,
      );

  void _refreshCalls() => remController.dashboardCommunicationFilterList(
        dataList: remController.callMailsDetailsList2,
        searchText: controllers.searchText.value.toLowerCase(),
        callType: controllers.selectCallType.value,
        sortField: controllers.sortFieldCallActivity.value,
        sortOrder: controllers.sortOrderCallActivity.value,
        selectedMonth: remController.selectedCallMonth.value,
        selectedRange: remController.selectedCallRange.value,
        selectedDateFilter: remController.selectedCallSortBy.value,
      );

  void _refreshLists() {
    _refreshMeetings();
    remController.dashboardSortReminders();
    _refreshCalls();
  }

  void checkDate() {
    final now = DateTime.now();
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

  void _applyFilter(String filter) {
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
        dashController.showDatePickerDialog(context).then((range) {
          if (range != null) {
            dashController.selectedRange.value = range;
            dashController.date1.value = _fmt(range.start);
            dashController.date2.value = _fmt(range.end);
            dashController.getWholeReport();
            dashController.getCustomerReport(
                dashController.date1.value, dashController.date2.value);
          }
        });
        return;
    }

    dashController.getWholeReport();
    final range = dashController.selectedRange.value;
    if (filter != "Today" && filter != "Yesterday") {
      dashController.getCustomerReport(
        range == null ? _fmt(now) : _fmt(range.start),
        range == null ? _fmt(now) : _fmt(range.end),
      );
    } else {
      dashController.getCustomerReport(
          _fmt(now.subtract(const Duration(days: 7))), _fmt(now));
    }
    remController.selectedMeetSortBy.value = filter;
    remController.selectedCallSortBy.value = filter;
    remController.selectedReminderSortBy.value = filter;
    _refreshLists();
  }

  @override
  void dispose() {
    _appScroll.dispose();
    _remScroll.dispose();
    _comScroll.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ small UI kit
  static const _chipBg = Color(0xffE2E8F0);

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      );

  Widget _section({
    required String title,
    String? subtitle,
    Widget? trailing,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 14),
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(text: title, isCopy: false, isBold: true, size: 15, colors: colorsConst.primary),
                    if (subtitle != null) ...[
                      3.height,
                      CustomText(text: subtitle, isCopy: false, size: 12, colors: Colors.grey),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          10.height,
          child,
        ],
      ),
    );
  }

  /// Pill-style segmented selector (scrolls horizontally if needed)
  Widget _chips({
    required List<String> items,
    required String Function() selected,
    required void Function(String) onTap,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: _chipBg, borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: items.map((f) {
            final sel = selected() == f;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(f),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: sel ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: sel
                      ? const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))]
                      : null,
                ),
                child: CustomText(
                  text: f,
                  isCopy: false,
                  size: 12,
                  isBold: true,
                  colors: sel ? const Color(0xff0078D7) : const Color(0xff666666),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _addButton(VoidCallback onTap) => InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(color: colorsConst.primary, borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.add, color: Colors.white, size: 18),
        ),
      );

  /// ◀ date range ▶ control
  Widget _rangeNav({
    required Rx<DateTimeRange?> range,
    required VoidCallback onChanged,
    required void Function(DateTimeRange) onPicked,
  }) {
    Widget arrow(IconData i, VoidCallback t) => InkWell(
          onTap: t,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(i, color: colorsConst.primary, size: 18),
          ),
        );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        arrow(Icons.arrow_back, () {
          final c = range.value;
          if (c == null) return;
          final d = c.end.difference(c.start).inDays + 1;
          range.value = DateTimeRange(
            start: c.start.subtract(Duration(days: d)),
            end: c.end.subtract(Duration(days: d)),
          );
          onChanged();
        }),
        InkWell(
          onTap: () => remController.showDatePickerDialog(context, onPicked, true),
          child: Obx(() {
            final r = range.value;
            final f = DateFormat("dd-MM-yyyy");
            if (r == null) return CustomText(text: f.format(DateTime.now()), isCopy: false, size: 12);
            final same = r.start.year == r.end.year &&
                r.start.month == r.end.month &&
                r.start.day == r.end.day;
            return CustomText(
              text: same ? f.format(r.start) : "${f.format(r.start)} - ${f.format(r.end)}",
              isCopy: false,
              size: 12,
            );
          }),
        ),
        arrow(Icons.arrow_forward, () {
          final c = range.value;
          if (c == null) return;
          final d = c.end.difference(c.start).inDays + 1;
          final newEnd = c.end.add(Duration(days: d));
          if (newEnd.isAfter(DateTime.now())) return;
          range.value = DateTimeRange(start: c.start.add(Duration(days: d)), end: newEnd);
          onChanged();
        }),
      ],
    );
  }

  Widget _emptyBox(String text) => SizedBox(
        height: 90,
        child: Center(child: CustomText(text: text, isCopy: false, colors: colorsConst.textColor, size: 14)),
      );

  Widget _listTile({
    required VoidCallback onTap,
    required String title,
    required List<String> lines,
    String? trailing,
    Color? trailingColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xffF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(text: title, isCopy: false, isBold: true, size: 14, textAlign: TextAlign.start),
                  for (final l in lines.where((e) => e.isNotEmpty && e != "null"))
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: CustomText(text: l, isCopy: false, size: 12, colors: Colors.grey.shade700, textAlign: TextAlign.start),
                    ),
                ],
              ),
            ),
            if (trailing != null && trailing.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (trailingColor ?? colorsConst.primary).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: CustomText(text: trailing, isCopy: false, size: 11, isBold: true, colors: trailingColor ?? colorsConst.primary),
              ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String title, String value, String iconPath, Color color, {String? amt}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
            child: Image.asset(iconPath),
          ),
          10.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomText(text: title, isCopy: false, size: 12, colors: Colors.grey.shade700, textAlign: TextAlign.start),
                CustomText(text: value, isCopy: false, size: 20, isBold: true, colors: color),
                if (amt != null && amt.isNotEmpty)
                  CustomText(text: amt, isCopy: false, size: 11, isBold: true, colors: Colors.grey.shade700),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heatTile(String asset, String label, String count, Color c, Color bg) {
    return Expanded(
      child: Container(
        height: 90,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: customDecoration.baseBackgroundDecoration(color: bg, radius: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(height: 38, child: Image.asset(asset)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomText(text: label, isCopy: false, isBold: true, colors: c),
                5.width,
                CustomText(text: "${int.tryParse(count) ?? 0}", isCopy: false, isBold: true, colors: c),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _comparisonRow(Map e) {
    final last = int.tryParse(e['last_week']?.toString() ?? '0') ?? 0;
    final current = int.tryParse(e['this_week']?.toString() ?? '0') ?? 0;
    final diff = current - last;
    final color = diff > 0 ? Colors.green : diff < 0 ? Colors.red : Colors.grey;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Expanded(flex: 4, child: CustomText(text: e['category'] ?? '', isCopy: false, isBold: true, textAlign: TextAlign.start)),
              Expanded(flex: 2, child: CustomText(text: "$last", isCopy: false, isBold: true)),
              Expanded(flex: 2, child: CustomText(text: "$current", isCopy: false, isBold: true)),
              Container(
                width: 56,
                height: 22,
                alignment: Alignment.center,
                decoration: customDecoration.baseBackgroundDecoration(
                  color: color.withOpacity(0.1),
                  radius: 20,
                ),
                child: CustomText(
                  text: diff > 0
                      ? "▲ ${diff.toString().padLeft(2, "0")}"
                      : diff < 0
                          ? "▼ ${diff.abs().toString().padLeft(2, "0")}"
                          : "-",
                  isCopy: false,
                  isBold: true,
                  colors: color,
                  size: 12,
                ),
              ),
            ],
          ),
        ),
        const Divider(thickness: 0.1, color: Colors.grey, height: 1),
      ],
    );
  }

  // ------------------------------------------------------------------ build
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: SafeArea(
        child: Obx(() {
          if (controllers.isCrmData.value == false) {
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: () async {
              await dashController.getWholeReport();
              _refreshLists();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _header(),
                  12.height,
                  _filterBar(),
                  12.height,
                  _statGrid(),
                  14.height,
                  _appointmentsSection(),
                  _remindersSection(),
                  _communicationSection(),
                  EmployeePerformanceTable(width: screenWidth - 24).paddingSymmetric(horizontal: 12),
                  14.height,
                  _leadPieSection(screenWidth),
                  _comparisonSection(),
                  _highValueSection(),
                  ActivityOverTimeChart(
                    width: screenWidth - 24,
                    xLabels: controllers.xLabels.toList(),
                    lines: [
                      ActivityLineData(label: "Calls", values: controllers.calls.toList(), color: const Color(0xFF0F8D4B)),
                      ActivityLineData(label: "Mails", values: controllers.mails.toList(), color: const Color(0xFFEB3342)),
                      ActivityLineData(label: "Updates", values: controllers.updates.toList(), color: const Color(0xFF1596E0)),
                    ],
                  ).paddingSymmetric(horizontal: 12),
                  14.height,
                  _heatSection(),
                  _leadStagesSection(),
                  20.height,
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ----------------------------------------------------------------- header
  Widget _header() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: colorsConst.primary,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (controllers.comName.text.isNotEmpty)
                  CustomText(text: controllers.comName.text, size: 16, isBold: true, isCopy: false, colors: Colors.white, textAlign: TextAlign.start),
                4.height,
                CustomText(text: "ARUU's EasyCRM", size: 16, isBold: true, isCopy: false, colors: Colors.white),
                4.height,
                CustomText(text: "Hi, ${controllers.storage.read("f_name") ?? ""}", isBold: true, isCopy: false, colors: Colors.white, size: 13),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CustomText(text: version, size: 11, isCopy: false, colors: Colors.white, isBold: true),
              6.height,
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today_outlined, color: Colors.white, size: 13),
                  5.width,
                  Obx(() {
                    final r = dashController.selectedRange.value;
                    if (r == null) return const SizedBox();
                    return CustomText(
                      text: r.start == r.end
                          ? "${r.start.day}-${r.start.month}-${r.start.year}"
                          : "${r.start.day}-${r.start.month}-${r.start.year} - ${r.end.day}-${r.end.month}-${r.end.year}",
                      isBold: true,
                      isCopy: false,
                      size: 11,
                      colors: Colors.white,
                    );
                  }),
                ],
              ),
              6.height,
              Obx(() {
                if (dashController.timestamp.value.isEmpty) {
                  return const CustomText(isCopy: false, text: "Last Sync · --", size: 11, isBold: true, colors: Colors.white);
                }
                final diff = DateTime.now().difference(DateTime.parse(dashController.timestamp.value));
                final t = diff.inSeconds < 60
                    ? "Just now"
                    : diff.inMinutes < 60
                        ? "${diff.inMinutes} mins ago"
                        : diff.inHours < 24
                            ? "${diff.inHours} hrs ago"
                            : "${diff.inDays} days ago";
                return CustomText(text: "Last Sync · $t", size: 11, isBold: true, isCopy: false, colors: Colors.white);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Obx(() => _chips(
            items: dashController.filters.toList().cast<String>(),
            selected: () => dashController.selectedSortBy.value,
            onTap: _applyFilter,
          )),
    );
  }

  // ------------------------------------------------------------ stat cards
  Widget _statGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Obx(() {
        final cards = [
          _statCard("Leads", "${int.tryParse(dashController.totalSuspects.value.toString()) ?? 0}",
              DashboardAssets.people, const Color(0xffF29D38)),
          _statCard("Appointments", "${remController.dMeetings.length}",
              DashboardAssets.date, const Color(0xff8B2CF5)),
          _statCard("Reminders", "${remController.reminderFilteredList2.length}",
              DashboardAssets.alarm, const Color(0xffBB271A)),
          _statCard("Orders", "${int.tryParse(dashController.totalOrders.value.toString()) ?? 0}",
              DashboardAssets.cart, Colors.pink,
              amt: productCtr.formatAmount2(dashController.totalAmt.value)),
          _statCard("Quotations", "${int.tryParse(dashController.totalQuotations.value.toString()) ?? 0}",
              DashboardAssets.quo, Colors.brown,
              amt: productCtr.formatAmount2(dashController.totalQuotationsAmt.value)),
        ];
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.0,
          children: cards,
        );
      }),
    );
  }

  // ------------------------------------------------------------ appointments
  Widget _appointmentsSection() {
    return _section(
      title: "Appointments",
      trailing: _addButton(() {
        final futureDate = DateTime.now().add(const Duration(days: 3));
        final adjusted = futureDate.weekday == DateTime.sunday
            ? futureDate.add(const Duration(days: 1))
            : futureDate;
        controllers.fDate.value = DateFormat('dd-MM-yyyy').format(adjusted);
        controllers.fTime.value = DateFormat('hh:mm a').format(DateTime.now().add(const Duration(minutes: 15)));
        controllers.toDate.value = DateFormat('dd-MM-yyyy').format(adjusted);
        controllers.toTime.value = DateFormat('hh:mm a').format(DateTime.now().add(const Duration(minutes: 30)));
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
      }),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _rangeNav(
            range: remController.selectedCallRange,
            onChanged: _refreshMeetings,
            onPicked: (r) {
              remController.selectedMeetSortBy.value = "Custom Range";
              remController.selectedCallRange.value = r;
              _refreshMeetings();
            },
          ),
          6.height,
          Obx(() => _chips(
                items: dashController.filterType.toList().cast<String>(),
                selected: () => remController.filterApp.value,
                onTap: (f) {
                  remController.filterApp.value = f;
                  _refreshMeetings();
                },
              )),
          10.height,
          Obx(() {
            final list = remController.dMeetings;
            if (list.isEmpty) return _emptyBox("No Appointments");
            return SizedBox(
              height: 260,
              child: ListView.builder(
                controller: _appScroll,
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final d = list[i];
                  return _listTile(
                    onTap: () => showMeetingDialog(context, list, i),
                    title: d.cusName.toString() == "null" ? "" : d.cusName.toString(),
                    lines: [
                      d.comName.toString(),
                      d.employeeName.toString(),
                      utils.formatDateTime(d.dates, d.time),
                    ],
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  // --------------------------------------------------------------- reminders
  Widget _remindersSection() {
    return _section(
      title: "Reminders",
      trailing: _addButton(() => reminderUtils.showAddReminderDialog(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _rangeNav(
            range: remController.selectedReminderRange,
            onChanged: remController.dashboardSortReminders,
            onPicked: (r) {
              remController.selectedReminderSortBy.value = "Custom Range";
              remController.selectedReminderRange.value = r;
              remController.dashboardSortReminders();
            },
          ),
          6.height,
          Obx(() => _chips(
                items: dashController.filterType.toList().cast<String>(),
                selected: () => remController.filterRem.value,
                onTap: (f) {
                  remController.filterRem.value = f;
                  remController.dashboardSortReminders();
                },
              )),
          10.height,
          Obx(() {
            final list = remController.reminderFilteredList2;
            if (list.isEmpty) return _emptyBox("No Reminders");
            return SizedBox(
              height: 260,
              child: ListView.builder(
                controller: _remScroll,
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final d = list[i];
                  final isFollow = d.type.toString() == "1";
                  return _listTile(
                    onTap: () => showReminderDialog(context, list, i),
                    title: d.title.toString(),
                    trailing: isFollow ? "Follow-up" : "Appointment",
                    trailingColor: isFollow ? Colors.orange : Colors.purple,
                    lines: [
                      d.customerName.toString(),
                      d.employeeName.toString(),
                      controllers.formatDate(d.startDt.toString()),
                    ],
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  // ----------------------------------------------------------- communication
  Widget _communicationSection() {
    return _section(
      title: "Communication Details",
      subtitle: "Communication insights based on calls and emails.",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => _chips(
                items: dashController.filterType.toList().cast<String>(),
                selected: () => remController.filterCall.value,
                onTap: (f) {
                  remController.filterCall.value = f;
                  _refreshCalls();
                },
              )),
          10.height,
          Obx(() {
            final list = remController.callMailsDetailsList;
            if (list.isEmpty) return _emptyBox("No Communication Details Found");
            return SizedBox(
              height: 300,
              child: ListView.builder(
                controller: _comScroll,
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final d = list[i];
                  final isMail = d.callStatus == "null" || d.callStatus == "";
                  return _listTile(
                    onTap: () => showCallDialog(context, list, i),
                    title: d.customerName.toString() == "null" ? "" : d.customerName.toString(),
                    trailing: isMail ? "Mail" : "Call",
                    trailingColor: isMail ? Colors.red : Colors.green,
                    lines: [
                      d.companyName.toString(),
                      "${d.sentDate}",
                      "${d.callType} • ${d.name}",
                    ],
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------ charts
  Widget _leadPieSection(double screenWidth) {
    return Column(
      children: [
        Container(
          height: 300,
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 14),
          child: Obx(() => LeadPieCard(
                data: [
                  for (int i = 0; i < dashController.leadReport.length; i++)
                    if ((double.tryParse(dashController.leadReport[i]["customer_count"].toString()) ?? 0) > 0)
                      PieData(
                        label: dashController.leadReport[i]["category"] ?? "",
                        value: double.tryParse(dashController.leadReport[i]["customer_count"].toString()) ?? 0,
                        color: controllers.leadColors[i],
                      ),
                ],
              )),
        ),
        Obx(() => dashController.customerStatusReport.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
                child: CustomerActivityCard(width: screenWidth - 24),
              )
            : const SizedBox()),
        Container(
          height: 310,
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 14),
          child: Obx(() => CustomerStatusCard(
                items: [
                  for (var i = 0; i < dashController.visitStatusReport.length; i++)
                    CustomerStatusItem(
                      label: dashController.visitStatusReport[i]["value"].toString(),
                      value: int.parse(dashController.visitStatusReport[i]["total_count"].toString()),
                      percentage: dashController.total == 0
                          ? 0
                          : double.parse(dashController.visitStatusReport[i]["total_count"].toString()) /
                              dashController.total,
                    ),
                ],
              )),
        ),
      ],
    );
  }

  Widget _comparisonSection() {
    return _section(
      title: "Lead Comparison Report",
      subtitle: "Compare lead progress across categories weekly or monthly.",
      child: Obx(() {
        final weekly = dashController.selectFilter.value == "Weekly";
        final rows = weekly ? dashController.comparisonReport : dashController.comparisonReport2;
        return Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: _chips(
                items: dashController.repType.toList().cast<String>(),
                selected: () => dashController.selectFilter.value,
                onTap: (f) => dashController.selectFilter.value = f,
              ),
            ),
            10.height,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              decoration: BoxDecoration(
                color: colorsConst.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Expanded(flex: 4, child: CustomText(text: "Category", isCopy: false, isBold: true, colors: Colors.white, size: 12, textAlign: TextAlign.start)),
                  Expanded(flex: 2, child: CustomText(text: weekly ? "Last Wk" : "Last Mo", isCopy: false, isBold: true, colors: Colors.white, size: 12)),
                  Expanded(flex: 2, child: CustomText(text: weekly ? "This Wk" : "This Mo", isCopy: false, isBold: true, colors: Colors.white, size: 12)),
                  const SizedBox(
                    width: 56,
                    child: CustomText(text: "Change", isCopy: false, isBold: true, colors: Colors.white, size: 12),
                  ),
                ],
              ),
            ),
            for (final e in rows) _comparisonRow(e),
            10.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.report_gmailerrorred_sharp, color: Colors.grey, size: 16),
                5.width,
                const Flexible(
                  child: CustomText(text: "Changes show the difference between the selected periods", isCopy: false, colors: Colors.grey, size: 11),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _highValueSection() {
    return _section(
      title: "High-Value Customer",
      subtitle: "Based on Quotation Amount",
      trailing: Container(
        padding: const EdgeInsets.all(8),
        decoration: customDecoration.baseBackgroundDecoration(
          color: const Color(0xFFD2EBFF).withOpacity(0.2),
          radius: 10,
          borderColor: Colors.grey.shade100,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const CustomText(text: "Total Value", isCopy: false, isBold: true, size: 11),
            Obx(() => CustomText(
                  text: productCtr.formatAmount(dashController.totalQuotationAmt.value),
                  isCopy: false,
                  isBold: true,
                  size: 13,
                  colors: Colors.blue,
                )),
          ],
        ),
      ),
      child: Obx(() {
        final ranges = dashController.ranges;
        return Column(
          children: [
            for (int index = ranges.length - 1; index >= 0; index--)
              _highValueRange(index, ranges[index]),
          ],
        );
      }),
    );
  }

  Widget _highValueRange(int index, dynamic range) {
    final items = dashController.groupedData[range] ?? [];
    final color = dashController.colorList[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: customDecoration.baseBackgroundDecoration(
        color: Colors.white,
        radius: 10,
        borderColor: Colors.grey.shade200,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: color.shade100,
                child: Icon(Icons.keyboard_double_arrow_up, color: color, size: 18),
              ),
              10.width,
              CustomText(text: range, isCopy: false, size: 14, isBold: true),
              6.width,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: customDecoration.baseBackgroundDecoration(color: color.shade100, radius: 15),
                child: CustomText(text: '${items.length}', isCopy: false, isBold: true, colors: color, size: 12),
              ),
            ],
          ),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: CustomText(text: 'No quotations found', isCopy: false, colors: Colors.grey, size: 12),
            )
          else
            ...items.map((e) => Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(text: e['company_name'], isCopy: false, isBold: true, size: 13, textAlign: TextAlign.start),
                            2.height,
                            Row(
                              children: [
                                CustomText(text: e['q_no'], isCopy: false, colors: Colors.grey, size: 11),
                                5.width,
                                const Icon(Icons.circle, color: Colors.grey, size: 6),
                                5.width,
                                CustomText(text: "${e['category']}", isCopy: false, isBold: true, colors: color, size: 11),
                              ],
                            ),
                          ],
                        ),
                      ),
                      CustomText(text: productCtr.formatAmount(e['total_amt']), isCopy: false, isBold: true, colors: color, size: 13),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  // ----------------------------------------------------------- portfolio heat
  Widget _heatSection() {
    const hotBg = Color(0xFFFFF2F2), warmBg = Color(0xFFFFF8ED), coldBg = Color(0xFFF0F6FF);
    const hot = Color(0xFFEF4444), warm = Color(0xFFF59E0B), cold = Color(0xFF3B82F6);

    return _section(
      title: "Portfolio Heat",
      subtitle: "Visualize the current engagement health of your portfolio.",
      child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomText(text: "Customer Engagement Levels", isCopy: false, size: 12, colors: Color(0xff6B7280)),
              8.height,
              Row(children: [
                _heatTile("assets/images/hot.png", "Hot", dashController.totalHot2.value, hot, hotBg),
                _heatTile("assets/images/warm.png", "Warm", dashController.totalWarm2.value, warm, warmBg),
                _heatTile("assets/images/cold.png", "Cold", dashController.totalCold2.value, cold, coldBg),
              ]),
              12.height,
              const Divider(height: 1, thickness: 1, color: Color(0xffD1D5DB)),
              12.height,
              const CustomText(text: "Lead Engagement Levels", isCopy: false, size: 12, colors: Color(0xff6B7280)),
              8.height,
              Row(children: [
                _heatTile("assets/images/hot.png", "Hot", dashController.totalHot.value, hot, hotBg),
                _heatTile("assets/images/warm.png", "Warm", dashController.totalWarm.value, warm, warmBg),
                _heatTile("assets/images/cold.png", "Cold", dashController.totalCold.value, cold, coldBg),
              ]),
            ],
          )),
    );
  }

  // ------------------------------------------------------------- lead stages
  Widget _leadStagesSection() {
    return _section(
      title: "Lead Stages",
      subtitle: "Life Time Customer Journey",
      trailing: SizedBox(height: 26, child: Image.asset(DashboardAssets.leadStage)),
      child: Obx(() {
        final list = controllers.leadCategoryList;
        final customers = list.isEmpty ? 0 : list.last.list2.length;
        final leads = list.isEmpty
            ? 0
            : list.fold<int>(0, (sum, item) => sum + (item.list2.length as int)) - customers;

        Widget pill(String value, String label) => Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: customDecoration.baseBackgroundDecoration(color: colorsConst.primary, radius: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(text: value, size: 16, isCopy: false, colors: Colors.white, isBold: true),
                    CustomText(text: label, size: 12, isCopy: false, colors: Colors.white),
                  ],
                ),
              ),
            );

        return Column(
          children: [
            Row(children: [pill("$leads", "total leads"), pill("$customers", "customers")]),
            12.height,
            for (int i = 0; i < list.length; i++)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 36,
                        width: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: controllers.leadColors[i].withOpacity(0.10), shape: BoxShape.circle),
                        child: Container(
                          height: 20,
                          width: 20,
                          decoration: BoxDecoration(color: controllers.leadColors[i], shape: BoxShape.circle),
                          child: Center(
                            child: CustomText(text: list[i].displayOrder.toString(), isCopy: false, isBold: true, colors: Colors.white, size: 11),
                          ),
                        ),
                      ),
                      10.width,
                      Expanded(
                        child: CustomText(
                          text: list[i].value.toUpperCase(),
                          isCopy: false,
                          textAlign: TextAlign.start,
                          size: 12,
                          isBold: true,
                          colors: controllers.leadColors[i],
                        ),
                      ),
                      CustomText(text: list[i].list2.length.toString(), isCopy: false, size: 14, isBold: true, colors: controllers.leadColors[i]),
                    ],
                  ),
                  if (i != list.length - 1)
                    Padding(
                      padding: const EdgeInsets.only(left: 17),
                      child: Container(height: 14, width: 2, color: Colors.grey.shade300),
                    ),
                ],
              ),
          ],
        );
      }),
    );
  }
}

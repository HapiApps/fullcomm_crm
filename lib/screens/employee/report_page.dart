import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fullcomm_crm/billing_utils/sized_box.dart';
import 'package:fullcomm_crm/common/styles/decoration.dart';
import 'package:fullcomm_crm/components/custom_sidebar.dart';
import 'package:fullcomm_crm/controller/dashboard_controller.dart';
import 'package:fullcomm_crm/models/month_report_obj.dart';
import 'package:fullcomm_crm/services/api_services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/constant/api.dart';
import '../../common/constant/colors_constant.dart';
import '../../common/utilities/utils.dart';
import '../../components/Customtext.dart';
import '../../components/custom_appbar.dart';
import '../../components/custom_no_data.dart';
import '../../components/date_filter_bar.dart';
import '../../components/keyboard_search.dart';
import '../../components/report_cards.dart';
import '../../controller/controller.dart';
import '../../controller/emp_report_controller.dart';
import '../../controller/product_controller.dart';
import '../../controller/reminder_controller.dart';
import '../../models/all_customers_obj.dart';
import '../order/order_page.dart';
import '../quotation/view_quotation_details.dart';
import 'emp_filter.dart';

class EmployeeReportPage extends StatefulWidget {
  final String id;
  final String name;
  const EmployeeReportPage({super.key, required this.id, required this.name});

  @override
  State<EmployeeReportPage> createState() => _EmployeeReportPageState();

  static Widget _button(
      String title,
      IconData icon,
      Color color,
      ) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 18, color: color),
      label: CustomText(
        text: title,
        isCopy: false,
        colors: color,
        isBold: true,
      ),
    );
  }
}

class _EmployeeReportPageState extends State<EmployeeReportPage> {
  late FocusNode _focusNode;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      repCtr.empId.value=widget.id;

      repCtr.changeType();

      var selectedRange = DateTimeRange(
        start: DateFormat('dd-MM-yyyy').parse(repCtr.stDate.value),
        end: DateFormat('dd-MM-yyyy').parse(
          repCtr.enDate.value.isEmpty
              ? repCtr.stDate.value
              : repCtr.enDate.value,
        ),
      );
      remController.filterAndSortCalls(
        allCalls: controllers.callActivity,
        searchText: widget.name,
        callType: controllers.selectCallType.value,
        sortField: controllers.sortFieldCallActivity.value,
        sortOrder: controllers.sortOrderCallActivity.value,
        selectedMonth: repCtr.selectedMonth.value,
        selectedRange: selectedRange,
        selectedDateFilter: repCtr.selectedSortBy.value,
      );
      remController.selectedMailSortBy.value=repCtr.selectedSortBy.value;
      remController.selectedCallRange.value=selectedRange;
      remController.selectedMailMonth.value=repCtr.selectedMonth.value;
      remController.searchText.value=widget.name;
      remController.sortMails(widget.name);

      remController.selectedMeetSortBy.value=repCtr.selectedSortBy.value;
      remController.selectedMeetMonth.value=repCtr.selectedMonth.value;
      remController.selectedCallRange.value=selectedRange;
      remController.sortMeetings(
        searchText: widget.name,
        callType: controllers.selectMeetingType.value,
        sortField: '',
        sortOrder: controllers.sortOrderMeetingActivity.value,
      );

      productCtr.filterAndSortQuotations(
        searchText: widget.name,
        sortField: controllers.sortFieldCallActivity.value,
        sortOrder: controllers.sortOrderCallActivity.value,
        selectedMonth: productCtr.selectedCallMonth.value,
        selectedRange: remController.selectedCallRange.value,
        selectedDateFilter: productCtr.selectedCallSortBy.value,
      );

      productCtr.filterAndSortOrders(
        searchText: widget.name,
        sortField: controllers.sortFieldCallActivity.value,
        sortOrder: controllers.sortOrderCallActivity.value,
        selectedMonth: repCtr.selectedMonth.value,
        selectedRange: selectedRange,
        selectedDateFilter: remController.selectedMailSortBy.value,
      );
    });
  }
  List<double> colWidths = [
    170,  // 2 c Name
    170,  // 2 lead Name
    130,  // 3 no
    150,  // 4 type
    200,  // 5 message
    150,  // 6 status
    150,  // 7 lead status
    170,  // 8 Date
    250,  // 8 Date
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
  final ScrollController _controller = ScrollController();
  final ScrollController _horizontalController = ScrollController();
  @override
  void dispose() {
    _controller.dispose();
    _horizontalController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final Map<int, TableColumnWidth> tableWidthMap = {
      for (int i = 0; i < colWidths.length; i++) i: FixedColumnWidth(colWidths[i])
    };

    double totalTableWidth = colWidths.reduce((a, b) => a + b);
    return Scaffold(
      body: Row(
        children: [
          SideBar(),
          Obx(()=>SizedBox(
            width: controllers.isLeftOpen.value==true?screenWidth-180:screenWidth-60,
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
              child: Column(
                children: [
                  CustomAppbar(
                      text:"Employee Wise Report",subText: "Detailed activity report of the selected employee",
                    // actionsWidget: EmployeeReportPage._button(
                    //   "Download",
                    //   Icons.download,
                    //   Colors.deepPurple,
                    // ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 480,
                        height: 40,
                        child: KeyboardDropdownField<AllEmployeesObj>(
                          items: controllers.employees,
                          hintText: "Search Employee Name",
                          borderRadius: 5,
                          borderColor: Colors.grey.shade300,
                          labelBuilder: (customer) =>
                          '${customer.name} ${customer.phoneNo}',
                          itemBuilder: (customer) =>
                              Container(
                                width: 300,
                                alignment: Alignment.topLeft,
                                padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                child: CustomText(
                                  text:
                                  '${customer.name} , ${customer.phoneNo}',
                                  colors: Colors.black,
                                  size: 14,
                                  isCopy: false,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                          textEditingController: controllers.cusController,
                          onSelected: (value) {
                            repCtr.empId.value=value.id;
                            repCtr.getWholeReport(repCtr.empId.value);
                          },
                          onClear: () {
                            controllers.clearSelectedCustomer();
                          },
                        ),
                      ),
                      DateFilterBar(
                        isEmp: true,
                        selectedSortBy: repCtr.selectedSortBy,
                        selectedRange: repCtr.selectedRange,
                        selectedMonth: repCtr.selectedMonth,
                        focusNode: _focusNode,
                        onDaysSelected: () {
                          repCtr.changeType();
                          apiService.getEmpLeads(repCtr.stDate.value,repCtr.enDate.value);
                          var selectedRange = DateTimeRange(
                            start: DateFormat('dd-MM-yyyy').parse(repCtr.stDate.value),
                            end: DateFormat('dd-MM-yyyy').parse(
                              repCtr.enDate.value.isEmpty
                                  ? repCtr.stDate.value
                                  : repCtr.enDate.value,
                            ),
                          );
                          remController.filterAndSortCalls(
                            allCalls: controllers.callActivity,
                            searchText: widget.name,
                            callType: controllers.selectCallType.value,
                            sortField: controllers.sortFieldCallActivity.value,
                            sortOrder: controllers.sortOrderCallActivity.value,
                            selectedMonth: repCtr.selectedMonth.value,
                            selectedRange: selectedRange,
                            selectedDateFilter: repCtr.selectedSortBy.value,
                          );
                          remController.selectedMailSortBy.value=repCtr.selectedSortBy.value;
                          remController.selectedCallRange.value=selectedRange;
                          remController.selectedMailMonth.value=repCtr.selectedMonth.value;
                          remController.searchText.value=widget.name;
                          remController.sortMails(widget.name);

                          // remController.selectedMeetSortBy.value=repCtr.selectedSortBy.value;
                          remController.selectedMeetSortBy.value=repCtr.selectedSortBy.value=="Last 30 Days"?"Next 30 Days":
                          repCtr.selectedSortBy.value=="Last 7 Days"?"Next 7 Days":repCtr.selectedSortBy.value;
                          remController.selectedMeetMonth.value=repCtr.selectedMonth.value;
                          remController.selectedCallRange.value=null;
                          remController.sortMeetings(
                            searchText: widget.name,
                            callType: controllers.selectMeetingType.value,
                            sortField: controllers.sortFieldMeetingActivity.value,
                            sortOrder: controllers.sortOrderMeetingActivity.value,
                          );

                          productCtr.filterAndSortQuotations(
                            searchText: widget.name,
                            sortField: controllers.sortFieldCallActivity.value,
                            sortOrder: controllers.sortOrderCallActivity.value,
                            selectedMonth: productCtr.selectedCallMonth.value,
                            selectedRange: remController.selectedCallRange.value,
                            selectedDateFilter: productCtr.selectedCallSortBy.value,
                          );

                          productCtr.filterAndSortOrders(
                            searchText: widget.name,
                            sortField: controllers.sortFieldCallActivity.value,
                            sortOrder: controllers.sortOrderCallActivity.value,
                            selectedMonth: repCtr.selectedMonth.value,
                            selectedRange: selectedRange,
                            selectedDateFilter: remController.selectedMailSortBy.value,
                          );
                        },
                        onSelectMonth: () {
                          remController.selectMonth(
                            context,
                            repCtr.selectedSortBy,
                            repCtr.selectedMonth,
                                () {
                                  DateTime dt = DateTime.parse(repCtr.selectedMonth.toString());
                                  repCtr.stDate.value= DateFormat('dd-MM-yyyy').format(DateTime(dt.year, dt.month, 1));
                                  repCtr.enDate.value= DateFormat('dd-MM-yyyy').format(DateTime(dt.year, dt.month + 1, 0));
                                  repCtr.getWholeReport(repCtr.empId.value);
                                  apiService.getEmpLeads(repCtr.stDate.value,repCtr.enDate.value);
                                  var selectedRange = DateTimeRange(
                                    start: DateFormat('dd-MM-yyyy').parse(repCtr.stDate.value),
                                    end: DateFormat('dd-MM-yyyy').parse(
                                      repCtr.enDate.value.isEmpty
                                          ? repCtr.stDate.value
                                          : repCtr.enDate.value,
                                    ),
                                  );
                                  remController.filterAndSortCalls(
                                    allCalls: controllers.callActivity,
                                    searchText: widget.name,
                                    callType: controllers.selectCallType.value,
                                    sortField: controllers.sortFieldCallActivity.value,
                                    sortOrder: controllers.sortOrderCallActivity.value,
                                    selectedMonth: repCtr.selectedMonth.value,
                                    selectedRange: selectedRange,
                                    selectedDateFilter: repCtr.selectedSortBy.value,
                                  );

                                  remController.selectedMailSortBy.value=repCtr.selectedSortBy.value;
                                  remController.selectedCallRange.value=selectedRange;
                                  remController.selectedMailMonth.value=repCtr.selectedMonth.value;
                                  remController.sortMails(widget.name);

                                  remController.selectedMeetSortBy.value=repCtr.selectedSortBy.value=="Last 30 Days"?"Next 30 Days":
                                  repCtr.selectedSortBy.value=="Last 7 Days"?"Next 7 Days":repCtr.selectedSortBy.value;
                                  remController.selectedMeetMonth.value=repCtr.selectedMonth.value;
                                  remController.selectedCallRange.value=selectedRange;
                                  remController.sortMeetings(
                                    searchText: widget.name,
                                    callType: controllers.selectMeetingType.value,
                                    sortField: '',
                                    sortOrder: controllers.sortOrderMeetingActivity.value,
                                  );

                                  productCtr.filterAndSortQuotations(
                                    searchText: widget.name,
                                    sortField: controllers.sortFieldCallActivity.value,
                                    sortOrder: controllers.sortOrderCallActivity.value,
                                    selectedMonth: productCtr.selectedCallMonth.value,
                                    selectedRange: remController.selectedCallRange.value,
                                    selectedDateFilter: productCtr.selectedCallSortBy.value,
                                  );

                                  productCtr.filterAndSortOrders(
                                    searchText: widget.name,
                                    sortField: controllers.sortFieldCallActivity.value,
                                    sortOrder: controllers.sortOrderCallActivity.value,
                                    selectedMonth: repCtr.selectedMonth.value,
                                    selectedRange: selectedRange,
                                    selectedDateFilter: remController.selectedMailSortBy.value,
                                  );
                                },false
                          );
                        },
                        onSelectDateRange: (ctx) {
                          remController.showDatePickerDialog(ctx, (pickedRange) {
                            repCtr.selectedRange.value = pickedRange;
                            List<String> dates = repCtr.selectedRange.toString().split(" - ");
                            DateTime start = DateTime.parse(dates[0]);
                            DateTime end = DateTime.parse(dates[1]);
                            repCtr.stDate.value= DateFormat('dd-MM-yyyy').format(start);
                            repCtr.enDate.value= DateFormat('dd-MM-yyyy').format(end);
                            repCtr.getWholeReport(repCtr.empId.value);
                            apiService.getEmpLeads(repCtr.stDate.value,repCtr.enDate.value);
                            var selectedRange = DateTimeRange(
                              start: DateFormat('dd-MM-yyyy').parse(repCtr.stDate.value),
                              end: DateFormat('dd-MM-yyyy').parse(
                                repCtr.enDate.value.isEmpty
                                    ? repCtr.stDate.value
                                    : repCtr.enDate.value,
                              ),
                            );
                            remController.filterAndSortCalls(
                              allCalls: controllers.callActivity,
                              searchText: widget.name,
                              callType: controllers.selectCallType.value,
                              sortField: controllers.sortFieldCallActivity.value,
                              sortOrder: controllers.sortOrderCallActivity.value,
                              selectedMonth: repCtr.selectedMonth.value,
                              selectedRange: selectedRange,
                              selectedDateFilter: repCtr.selectedSortBy.value,
                            );

                            remController.selectedMailSortBy.value=repCtr.selectedSortBy.value;
                            remController.selectedCallRange.value=selectedRange;
                            remController.selectedMailMonth.value=repCtr.selectedMonth.value;
                            remController.searchText.value=widget.name;
                            remController.sortMails(widget.name);

                            remController.selectedMeetSortBy.value=repCtr.selectedSortBy.value=="Last 30 Days"?"Next 30 Days":
                            repCtr.selectedSortBy.value=="Last 7 Days"?"Next 7 Days":repCtr.selectedSortBy.value;
                            productCtr.selectedCallSortBy.value=repCtr.selectedSortBy.value;

                            remController.selectedMeetMonth.value=repCtr.selectedMonth.value;
                            remController.selectedCallRange.value=selectedRange;

                            remController.sortMeetings(
                              searchText: widget.name,
                              callType: controllers.selectMeetingType.value,
                              sortField: controllers.selectMeetingType.value,
                              sortOrder: controllers.sortOrderMeetingActivity.value,
                            );

                            productCtr.filterAndSortQuotations(
                              searchText: widget.name,
                              sortField: controllers.sortFieldCallActivity.value,
                              sortOrder: controllers.sortOrderCallActivity.value,
                              selectedMonth: productCtr.selectedCallMonth.value,
                              selectedRange: remController.selectedCallRange.value,
                              selectedDateFilter: productCtr.selectedCallSortBy.value,
                            );
                            print("sent ${remController.selectedMailSortBy.value}");

                            productCtr.filterAndSortOrders(
                              searchText: widget.name,
                              sortField: controllers.sortFieldCallActivity.value,
                              sortOrder: controllers.sortOrderCallActivity.value,
                              selectedMonth: repCtr.selectedMonth.value,
                              selectedRange: selectedRange,
                              selectedDateFilter: remController.selectedMailSortBy.value,
                            );
                          },false);
                        },
                      ),
                    ],
                  ),
                  20.height,
                  // repCtr.refreshData.value==false?
                  // CircularProgressIndicator():
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DashboardCard(
                            title: "Leads",
                            // value: repCtr.totalSuspects.value,
                            value: controllers.empLeadList.length.toString(),
                            icon: Icons.groups_outlined,
                            color: Colors.pink,
                            selectedColor: repCtr.selectFilter.value=="Leads"?colorsConst.primary:Colors.grey.shade200,
                            callback: (){
                              repCtr.selectFilter.value="Leads";
                              // apiService.getEmpLeads(repCtr.stDate.value,repCtr.enDate.value);
                            },
                          ),
                          DashboardCard(
                            title: "Calls",
                            // value: repCtr.totalCalls.value,
                            value: remController.paginatedItems.length.toString(),
                            icon: Icons.call,
                            color: Colors.blue,
                            selectedColor: repCtr.selectFilter.value=="Calls"?colorsConst.primary:Colors.grey.shade200,
                            callback: (){
                              if(remController.paginatedItems.isNotEmpty){
                                repCtr.selectFilter.value="Calls";
                                var selectedRange = DateTimeRange(
                                  start: DateFormat('dd-MM-yyyy').parse(repCtr.stDate.value),
                                  end: DateFormat('dd-MM-yyyy').parse(
                                    repCtr.enDate.value.isEmpty
                                        ? repCtr.stDate.value
                                        : repCtr.enDate.value,
                                  ),
                                );
                                remController.filterAndSortCalls(
                                  allCalls: controllers.callActivity,
                                  searchText: widget.name,
                                  callType: controllers.selectCallType.value,
                                  sortField: controllers.sortFieldCallActivity.value,
                                  sortOrder: controllers.sortOrderCallActivity.value,
                                  selectedMonth: repCtr.selectedMonth.value,
                                  selectedRange: selectedRange,
                                  selectedDateFilter: repCtr.selectedSortBy.value,
                                );
                              }
                            },
                          ),
                          DashboardCard(
                            title: "Mails",
                            // value: repCtr.totalMails.value,
                            value: remController.paginatedMailItems.length.toString(),
                            icon: Icons.mail_outline,
                            color: Colors.green,
                            selectedColor: repCtr.selectFilter.value=="Mails"?colorsConst.primary:Colors.grey.shade200,
                            callback: (){
                              if(remController.paginatedMailItems.isNotEmpty){
                                repCtr.selectFilter.value="Mails";
                                var selectedRange = DateTimeRange(
                                  start: DateFormat('dd-MM-yyyy').parse(repCtr.stDate.value),
                                  end: DateFormat('dd-MM-yyyy').parse(
                                    repCtr.enDate.value.isEmpty
                                        ? repCtr.stDate.value
                                        : repCtr.enDate.value,
                                  ),
                                );
                                remController.selectedMailSortBy.value=repCtr.selectedSortBy.value;
                                remController.selectedCallRange.value=selectedRange;
                                remController.selectedMailMonth.value=repCtr.selectedMonth.value;
                                remController.searchText.value=widget.name;
                                remController.sortMails(widget.name);
                              }
                            },
                          ),
                          DashboardCard(
                            title: "Appointments",
                            // value: repCtr.totalMeetings.value,
                            value: remController.paginatedAppItems.length.toString(),
                            icon: Icons.calendar_today,
                            color: Colors.deepPurple,
                            selectedColor: repCtr.selectFilter.value=="Appointments"?colorsConst.primary:Colors.grey.shade200,
                            callback: (){
                              if(remController.paginatedAppItems.isNotEmpty){
                                repCtr.selectFilter.value="Appointments";
                                // var selectedRange = DateTimeRange(
                                //   start: DateFormat('dd-MM-yyyy').parse(repCtr.stDate.value),
                                //   end: DateFormat('dd-MM-yyyy').parse(
                                //     repCtr.enDate.value.isEmpty
                                //         ? repCtr.stDate.value
                                //         : repCtr.enDate.value,
                                //   ),
                                // );
                                // remController.selectedMeetSortBy.value=repCtr.selectedSortBy.value=="Last 30 Days"?"Next 30 Days":
                                // repCtr.selectedSortBy.value=="Last 7 Days"?"Next 7 Days":repCtr.selectedSortBy.value;
                                // remController.selectedMeetMonth.value=repCtr.selectedMonth.value;
                                // remController.selectedCallRange.value=selectedRange;
                                // remController.sortMeetings(
                                //   searchText: widget.name,
                                //   callType: controllers.selectMeetingType.value,
                                //   sortField: '',
                                //   sortOrder: controllers.sortOrderMeetingActivity.value,
                                // );
                              }
                            },
                          ),
                          DashboardCard(
                            title: "Quotations",
                            value: productCtr.paginatedItems.length.toString(),
                            // value: repCtr.totalQuotations.value,
                            icon: Icons.description_outlined,
                            color: Colors.orange,
                            selectedColor: repCtr.selectFilter.value=="Quotations"?colorsConst.primary:Colors.grey.shade200,
                            callback: (){
                              if(productCtr.paginatedItems.isNotEmpty){
                                repCtr.selectFilter.value="Quotations";
                                productCtr.filterAndSortQuotations(
                                  searchText: widget.name,
                                  sortField: controllers.sortFieldCallActivity.value,
                                  sortOrder: controllers.sortOrderCallActivity.value,
                                  selectedMonth: productCtr.selectedCallMonth.value,
                                  selectedRange: remController.selectedCallRange.value,
                                  selectedDateFilter: productCtr.selectedCallSortBy.value,
                                );
                              }
                            },
                          ),
                          DashboardCard(
                            title: "Orders",
                            // value: repCtr.totalOrders.value,
                            value: productCtr.paginatedOrdersItems.length.toString(),
                            icon: Icons.shopping_cart,
                            color: Colors.brown,
                            selectedColor: repCtr.selectFilter.value=="Orders"?colorsConst.primary:Colors.grey.shade200,
                            callback: (){
                              if(productCtr.paginatedOrdersItems.isNotEmpty){
                                repCtr.selectFilter.value="Orders";
                                var selectedRange = DateTimeRange(
                                  start: DateFormat('dd-MM-yyyy').parse(repCtr.stDate.value),
                                  end: DateFormat('dd-MM-yyyy').parse(
                                    repCtr.enDate.value.isEmpty
                                        ? repCtr.stDate.value
                                        : repCtr.enDate.value,
                                  ),
                                );
                                productCtr.filterAndSortOrders(
                                  searchText: widget.name,
                                  sortField: controllers.sortFieldCallActivity.value,
                                  sortOrder: controllers.sortOrderCallActivity.value,
                                  selectedMonth: repCtr.selectedMonth.value,
                                  selectedRange: selectedRange,
                                  selectedDateFilter: remController.selectedMailSortBy.value,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      20.height,
                      if(repCtr.selectFilter.value=="Leads")
                      controllers.isCustomer.value==false?
                      Center(
                          child: SizedBox(
                              height: 30,width: 30,
                              child: CircularProgressIndicator())):
                      Container(
                        decoration: customDecoration.baseBackgroundDecoration(
                            color: Colors.grey.shade50,borderColor: colorsConst.primary,radius: 10
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      CustomText(text: "Lead Detail Report ", isCopy: false,isBold: true,size: 18,),
                                      30.width,
                                      Obx(()=> utils.selectHeatingType2("Total Leads",
                                          controllers.sortOrderType.value=="all", (){
                                            productCtr.filterAndSortQuotations(
                                              searchText: widget.name,
                                              sortField: controllers.sortFieldCallActivity.value,
                                              sortOrder: controllers.sortOrderCallActivity.value,
                                              selectedMonth: productCtr.selectedCallMonth.value,
                                              selectedRange: remController.selectedCallRange.value,
                                              selectedDateFilter: productCtr.selectedCallSortBy.value,
                                            );
                                          }, Colors.blueAccent,controllers.empLeadList.length.toString().obs,width: 150),),
                                      10.width,
                                      Obx(()=>utils.selectHeatingType2("Converted to ${controllers.leadCategoryList.last.value}",
                                          controllers.sortOrderType.value=="Order Confirmed", (){
                                            productCtr.filterAndSortQuotations(
                                              searchText: widget.name,
                                              sortField: controllers.sortFieldCallActivity.value,
                                              sortOrder: controllers.sortOrderCallActivity.value,
                                              selectedMonth: productCtr.selectedCallMonth.value,
                                              selectedRange: remController.selectedCallRange.value,
                                              selectedDateFilter: productCtr.selectedCallSortBy.value,
                                            );
                                          }, Colors.green,controllers.mainCus.value.toString().obs,width: 250),),
                                      10.width,
                                      Obx(()=> utils.selectHeatingType2("In Progress",
                                          controllers.sortOrderType.value=="Pending", (){
                                            productCtr.filterAndSortQuotations(
                                              searchText: widget.name,
                                              sortField: controllers.sortFieldCallActivity.value,
                                              sortOrder: controllers.sortOrderCallActivity.value,
                                              selectedMonth: productCtr.selectedCallMonth.value,
                                              selectedRange: remController.selectedCallRange.value,
                                              selectedDateFilter: productCtr.selectedCallSortBy.value,
                                            );
                                          }, Colors.orange,controllers.pendingCus.value.toString().obs,width: 150),),
                                    ],
                                  ),
                                  InkWell(
                                      onTap: (){
                                        repCtr.selectFilter.value="";
                                      },
                                      child: Icon(Icons.clear,))
                                ],
                              ),
                              20.height,
                              controllers.empLeadList.isEmpty?
                              Center(
                                  child: SizedBox(
                                      height: 300,width: 300,
                                      child: CustomNoData())):
                              SizedBox(
                                width: double.infinity,
                                height: 300,
                                child: Column(
                                  children: [
                                    // HEADER
                                    Table(
                                      // columnWidths: tableWidthMap,
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
                                              headerCell(
                                                2,  Row(
                                                children: [
                                                  CustomText(
                                                    textAlign: TextAlign.left,
                                                    text: "Company Name",
                                                    size: 15,
                                                    isBold: true,
                                                    isCopy: true,
                                                    colors: Colors.white,
                                                  ),
                                                ],
                                              ),),
                                              headerCell(
                                                3,  Row(
                                                children: [
                                                  CustomText(
                                                    textAlign: TextAlign.left,
                                                    text: "Lead Name",
                                                    size: 15,
                                                    isBold: true,
                                                    isCopy: true,
                                                    colors: Colors.white,
                                                  ),
                                                ],
                                              ),),
                                              headerCell(4, Row(
                                                children: [
                                                  CustomText(//2
                                                    textAlign: TextAlign.left,
                                                    text: "Mobile No",
                                                    size: 15,
                                                    isBold: true,
                                                    isCopy: true,
                                                    colors: Colors.white,
                                                  ),
                                                ],
                                              ),),
                                              headerCell(5, Row(
                                                children: [
                                                  CustomText(
                                                    textAlign: TextAlign.left,
                                                    text: "Lead Status",
                                                    size: 15,
                                                    isBold: true,
                                                    isCopy: true,
                                                    colors: Colors.white,
                                                  ),
                                                ],
                                              ),),
                                              headerCell(6, Row(
                                                children: [
                                                  CustomText(
                                                    textAlign: TextAlign.left,
                                                    text: "Created Timestamp",
                                                    size: 15,
                                                    isBold: true,
                                                    isCopy: true,
                                                    colors: Colors.white,
                                                  ),
                                                ],
                                              ),),
                                            ]),
                                      ],
                                    ),
                                    // BODY LIST
                                    Expanded(
                                      child: ListView.builder(
                                        controller: _controller,
                                        // shrinkWrap: true,
                                        // physics: const ScrollPhysics(),
                                        itemCount: controllers.empLeadList.length,
                                        itemBuilder: (context, index) {
                                          final data = controllers.empLeadList[index];
                                          return Table(
                                            // columnWidths: tableWidthMap,
                                            border: TableBorder(
                                              horizontalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                                              verticalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                                              bottom:  BorderSide(width: 0.5, color: Colors.grey.shade400),
                                            ),
                                            children:[
                                              TableRow(
                                                  decoration: BoxDecoration(
                                                    color: int.parse(index.toString()) % 2 == 0 ? Colors.white : colorsConst.backgroundColor,
                                                  ),
                                                  children:[
                                                    Padding(
                                                      padding: const EdgeInsets.all(10.0),
                                                      child: CustomText(
                                                        textAlign: TextAlign.left,
                                                        text: data.companyName.toString()=="null"?"":data.companyName.toString(),
                                                        size: 14,
                                                        isCopy: true,
                                                        colors:colorsConst.textColor,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(10.0),
                                                      child: CustomText(
                                                        textAlign: TextAlign.left,
                                                        text: data.firstname.toString()=="null"?"":data.firstname.toString(),
                                                        size: 14,
                                                        isCopy: true,
                                                        colors:colorsConst.textColor,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(10.0),
                                                      child: CustomText(
                                                        textAlign: TextAlign.left,
                                                        text:data.mobileNumber.toString()=="null"?"":data.mobileNumber.toString(),
                                                        size: 14,
                                                        isCopy: true,
                                                        colors: colorsConst.textColor,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(10.0),
                                                      child: CustomText(
                                                        textAlign: TextAlign.left,
                                                        text: data.category.toString(),
                                                        size: 14,
                                                        isCopy: true,
                                                        colors:colorsConst.textColor,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(10.0),
                                                      child: CustomText(
                                                        textAlign: TextAlign.left,
                                                        text: productCtr.formatDateTime(data.createdTs.toString()),
                                                        size: 14,
                                                        isCopy: true,
                                                        colors:colorsConst.textColor,
                                                      ),
                                                    ),
                                                  ]
                                              ),

                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                    20.height,
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if(repCtr.selectFilter.value=="Calls")
                      Container(
                        decoration: customDecoration.baseBackgroundDecoration(
                            color: Colors.grey.shade50,borderColor: colorsConst.primary,radius: 10
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      CustomText(text: "Call Activity Report ", isCopy: false,isBold: true,size: 18,),
                                      30.width,
                                      Obx(()=>utils.selectHeatingType2("All",
                                          controllers.selectCallType.value=="All", (){
                                            controllers.selectCallType.value="All";
                                            var selectedRange = DateTimeRange(
                                              start: DateFormat('dd-MM-yyyy').parse(repCtr.stDate.value),
                                              end: DateFormat('dd-MM-yyyy').parse(
                                                repCtr.enDate.value.isEmpty
                                                    ? repCtr.stDate.value
                                                    : repCtr.enDate.value,
                                              ),
                                            );
                                            remController.filterAndSortCalls(
                                              allCalls: controllers.callActivity,
                                              searchText: widget.name,
                                              callType: controllers.selectCallType.value,
                                              sortField: controllers.sortFieldCallActivity.value,
                                              sortOrder: controllers.sortOrderCallActivity.value,
                                              selectedMonth: repCtr.selectedMonth.value,
                                              selectedRange: selectedRange,
                                              selectedDateFilter: repCtr.selectedSortBy.value,
                                            );
                                          }, Colors.blueAccent,controllers.allCalls),),
                                      10.width,
                                      Obx(() {
                                        final colors = List<Color>.from(controllers.callColors)..shuffle();

                                        for (int i = 0; i < controllers.hCallStatusList.length; i++) {
                                          controllers.callStatusColors[controllers.hCallStatusList[i]["value"]] =
                                          colors[i % colors.length];
                                        }
                                        return Wrap(
                                          spacing: 10,
                                          runSpacing: 10,
                                          children: controllers.hCallStatusList.map((item) {
                                            final Color color = controllers.callStatusColors[item["value"]] ?? Colors.grey;
                                            return InkWell(
                                              onTap: () {
                                                controllers.selectCallType.value = item["value"];
                                                var selectedRange = DateTimeRange(
                                                  start: DateFormat('dd-MM-yyyy').parse(repCtr.stDate.value),
                                                  end: DateFormat('dd-MM-yyyy').parse(
                                                    repCtr.enDate.value.isEmpty
                                                        ? repCtr.stDate.value
                                                        : repCtr.enDate.value,
                                                  ),
                                                );
                                                remController.filterAndSortCalls(
                                                  allCalls: controllers.callActivity,
                                                  searchText: widget.name,
                                                  callType: controllers.selectCallType.value,
                                                  sortField: controllers.sortFieldCallActivity.value,
                                                  sortOrder: controllers.sortOrderCallActivity.value,
                                                  selectedMonth: repCtr.selectedMonth.value,
                                                  selectedRange: selectedRange,
                                                  selectedDateFilter: repCtr.selectedSortBy.value,
                                                );
                                              },
                                              child: Container(
                                                // width: width,
                                                decoration: customDecoration.baseBackgroundDecoration(
                                                    borderColor: controllers.selectCallType.value == item["value"]
                                                        ? color
                                                        : Colors.transparent,
                                                    radius: 5,color:color.withOpacity(0.1)
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(10),
                                                  child: Row(
                                                    children: [
                                                      CustomText(
                                                        text: item["value"],
                                                        colors: color,
                                                        isBold: true,
                                                        size: 15,
                                                        isCopy: false,
                                                      ),
                                                      10.width,
                                                      CustomText(
                                                        text: item["count"].toString(),
                                                        colors: color,
                                                        size: 15,
                                                        isCopy: false,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        );
                                      }),
                                    ],
                                  ),
                                  InkWell(
                                      onTap: (){
                                        repCtr.selectFilter.value="";
                                      },
                                      child: Icon(Icons.clear,))
                                ],
                              ),
                              20.height,
                              remController.paginatedItems.isEmpty?
                              Center(
                                  child: SizedBox(
                                      height: 300,width: 300,
                                      child: CustomNoData())):
                              SizedBox(
                                width: double.infinity,
                                height: 300,
                                child: Column(
                                  children: [
                                    // HEADER
                                    Table(
                                      // columnWidths: tableWidthMap,
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
                                              headerCell(
                                                2,  Row(
                                                children: [
                                                  CustomText(
                                                    textAlign: TextAlign.left,
                                                    text: "Company Name",
                                                    size: 15,
                                                    isBold: true,
                                                    isCopy: true,
                                                    colors: Colors.white,
                                                  ),
                                                ],
                                              ),),
                                              headerCell(
                                                3,  Row(
                                                children: [
                                                  CustomText(
                                                    textAlign: TextAlign.left,
                                                    text: "Lead Name",
                                                    size: 15,
                                                    isBold: true,
                                                    isCopy: true,
                                                    colors: Colors.white,
                                                  ),
                                                ],
                                              ),),
                                              headerCell(4, Row(
                                                children: [
                                                  CustomText(//2
                                                    textAlign: TextAlign.left,
                                                    text: "Mobile No",
                                                    size: 15,
                                                    isBold: true,
                                                    isCopy: true,
                                                    colors: Colors.white,
                                                  ),
                                                ],
                                              ),),
                                              headerCell(5, Row(
                                                children: [
                                                  CustomText(
                                                    textAlign: TextAlign.left,
                                                    text: "In/Out",
                                                    size: 15,
                                                    isBold: true,
                                                    isCopy: true,
                                                    colors: Colors.white,
                                                  ),
                                                ],
                                              ),),
                                              headerCell(6, Row(
                                                children: [
                                                  CustomText(
                                                    textAlign: TextAlign.left,
                                                    text: "Message",
                                                    size: 15,
                                                    isBold: true,
                                                    isCopy: true,
                                                    colors: Colors.white,
                                                  ),
                                                ],
                                              ),),
                                              headerCell(7, Row(
                                                children: [
                                                  CustomText(//4
                                                    textAlign: TextAlign.left,
                                                    text: "Status",
                                                    size: 15,
                                                    isBold: true,
                                                    isCopy: true,
                                                    colors: Colors.white,
                                                  ),
                                                ],
                                              ),),
                                              headerCell(8, Row(
                                                children: [
                                                  CustomText(//4
                                                    textAlign: TextAlign.left,
                                                    text: "Lead Status",
                                                    size: 15,
                                                    isBold: true,
                                                    isCopy: true,
                                                    colors: Colors.white,
                                                  ),
                                                ],
                                              ),),
                                              headerCell(9, Row(
                                                children: [
                                                  CustomText(
                                                    textAlign: TextAlign.left,
                                                    text: "Date",
                                                    size: 15,
                                                    isBold: true,
                                                    isCopy: true,
                                                    colors: Colors.white,
                                                  ),
                                                ],
                                              ),),
                                            ]),
                                      ],
                                    ),
                                    // BODY LIST
                                    Expanded(
                                      child: ListView.builder(
                                        controller: _controller,
                                        // shrinkWrap: true,
                                        // physics: const ScrollPhysics(),
                                        itemCount: remController.paginatedItems.length,
                                        itemBuilder: (context, index) {
                                          final data = remController.paginatedItems[index];
                                          return Table(
                                            // columnWidths: tableWidthMap,
                                            border: TableBorder(
                                              horizontalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                                              verticalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                                              bottom:  BorderSide(width: 0.5, color: Colors.grey.shade400),
                                            ),
                                            children:[
                                              TableRow(
                                                  decoration: BoxDecoration(
                                                    color: int.parse(index.toString()) % 2 == 0 ? Colors.white : colorsConst.backgroundColor,
                                                  ),
                                                  children:[
                                                    Padding(
                                                      padding: const EdgeInsets.all(10.0),
                                                      child: CustomText(
                                                        textAlign: TextAlign.left,
                                                        text: data.companyName.toString()=="null"?"":data.companyName.toString(),
                                                        size: 14,
                                                        isCopy: true,
                                                        colors:colorsConst.textColor,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(10.0),
                                                      child: CustomText(
                                                        textAlign: TextAlign.left,
                                                        text: data.customerName.toString()=="null"?"":data.customerName.toString(),
                                                        size: 14,
                                                        isCopy: true,
                                                        colors:colorsConst.textColor,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(10.0),
                                                      child: CustomText(
                                                        textAlign: TextAlign.left,
                                                        text:data.toData.toString()=="null"?"":data.toData.toString(),
                                                        size: 14,
                                                        isCopy: true,
                                                        colors: colorsConst.textColor,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(10.0),
                                                      child: CustomText(
                                                        textAlign: TextAlign.left,
                                                        text: data.callType.toString(),
                                                        size: 14,
                                                        isCopy: true,
                                                        colors:colorsConst.textColor,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(10.0),
                                                      child: CustomText(
                                                        textAlign: TextAlign.left,
                                                        text: data.message.toString(),
                                                        size: 14,
                                                        isCopy: true,
                                                        colors:colorsConst.textColor,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(10.0),
                                                      child: CustomText(
                                                        textAlign: TextAlign.left,
                                                        text: data.callStatus.toString(),
                                                        size: 14,
                                                        isCopy: true,
                                                        colors:colorsConst.textColor,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(10.0),
                                                      child: CustomText(
                                                        textAlign: TextAlign.left,
                                                        text: data.leadStatus.toString(),
                                                        size: 14,
                                                        isCopy: true,
                                                        colors:colorsConst.textColor,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(10.0),
                                                      child: CustomText(
                                                        textAlign: TextAlign.left,
                                                        text: controllers.formatDate(data.sentDate.toString()),
                                                        size: 14,
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
                                    20.height,
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if(repCtr.selectFilter.value=="Mails")
                      Container(
                        decoration: customDecoration.baseBackgroundDecoration(
                            color: Colors.grey.shade50,borderColor: colorsConst.primary,radius: 10
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      CustomText(text: "Mail Activity Report", isCopy: false,isBold: true,size: 18,),
                                      30.width,
                                      Obx(()=> utils.selectHeatingType2("To", controllers.isSent.value, (){
                                        apiService.getAllMailActivity();
                                        // }, false,controllers.allSentMails),),
                                      },Colors.blueAccent,remController.mailFilteredList.length.toString().obs),),
                                      10.width,
                                      Obx(()=>utils.selectHeatingType2("Opened", controllers.isOpened.value, (){
                                        apiService.getOpenedMailActivity(false);
                                      }, Colors.green,controllers.allOpenedMails),),
                                      10.width,
                                      Obx(()=> utils.selectHeatingType2("Replied", controllers.isReplied.value, (){
                                        apiService.getReplyMailActivity(false);
                                      }, Colors.purple,controllers.allReplyMails),),

                                    ],
                                  ),
                                  InkWell(
                                      onTap: (){
                                        repCtr.selectFilter.value="";
                                      },
                                      child: Icon(Icons.clear,))
                                ],
                              ),
                              20.height,
                              remController.paginatedMailItems.isEmpty?
                              Center(
                                  child: SizedBox(
                                      height: 300,width: 300,
                                      child: CustomNoData())):
                              SizedBox(
                                width: double.infinity,
                                height: 300,
                                child: Column(
                                  children: [
                                    // HEADER
                                    Table(
                                      // columnWidths: tableWidthMap,
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
                                              headerCell(0, CustomText(
                                                textAlign: TextAlign.left,
                                                text: "Lead Name",
                                                size: 15,
                                                isBold: true,
                                                isCopy: false,
                                                colors: Colors.white,
                                              ),),
                                              headerCell(1, Row(
                                                children: [
                                                  CustomText(
                                                    textAlign: TextAlign.left,
                                                    text: "Company Name",
                                                    size: 15,
                                                    isBold: true,
                                                    isCopy: false,
                                                    colors: Colors.white,
                                                  ),
                                                ],
                                              ),),
                                              headerCell(2, Row(
                                                children: [
                                                  CustomText(
                                                    textAlign: TextAlign.left,
                                                    text: "Sent Mail",
                                                    size: 15,
                                                    isBold: true,
                                                    isCopy: false,
                                                    colors: Colors.white,
                                                  ),
                                                ],
                                              ),),
                                              headerCell(3, Row(
                                                children: [
                                                  CustomText(
                                                    textAlign: TextAlign.left,
                                                    text: "Subject",
                                                    size: 15,
                                                    isBold: true,
                                                    isCopy: true,
                                                    colors: Colors.white,
                                                  ),
                                                ],
                                              ),),
                                              headerCell(4, Row(
                                                children: [
                                                  CustomText(
                                                    textAlign: TextAlign.left,
                                                    text: "Message",
                                                    size: 15,
                                                    isBold: true,
                                                    isCopy: true,
                                                    colors: Colors.white,
                                                  ),
                                                ],
                                              ),),
                                              headerCell(5,  CustomText(
                                                textAlign: TextAlign.left,
                                                text: "Attachment",
                                                size: 15,
                                                isBold: true,
                                                isCopy: true,
                                                colors: Colors.white,
                                              ),),
                                              headerCell(6, CustomText(
                                                textAlign: TextAlign.center,
                                                text: "Date",
                                                size: 15,
                                                isBold: true,
                                                isCopy: true,
                                                colors: Colors.white,
                                              ),)
                                            ]),
                                      ],
                                    ),
                                    // BODY LIST
                                    Expanded(
                                      child: Obx((){
                                        final searchText = remController.searchText.value.toLowerCase();
                                        final filteredList = remController.paginatedMailItems.where((activity) {
                                          final matchesSearch =
                                              (activity.name.toString().toLowerCase().contains(searchText)) ||
                                              (activity.customerName.toString().toLowerCase().contains(searchText)) ||
                                              (activity.companyName.toString().toLowerCase().contains(searchText)) ||
                                              (activity.toData.toString().toLowerCase().contains(searchText)) ||
                                              (activity.subject.toString().toLowerCase().contains(searchText));
                                          return matchesSearch;
                                        }).toList();
                                        return ListView.builder(
                                          controller: _controller,
                                          // shrinkWrap: true,
                                          // physics: const ScrollPhysics(),
                                          itemCount: filteredList.length,
                                          itemBuilder: (context, index) {
                                            final data = filteredList[index];
                                            var imageList =data.attachment.toString().split("||");
                                            return Table(
                                              // columnWidths: {
                                              //   for (int i = 0; i < colWidths.length; i++)
                                              //     i: FixedColumnWidth(colWidths[i]),
                                              // },
                                              border: TableBorder(
                                                horizontalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                                                verticalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                                                bottom:  BorderSide(width: 0.5, color: Colors.grey.shade400),
                                              ),
                                              children:[
                                                TableRow(
                                                    decoration: BoxDecoration(
                                                      color: int.parse(index.toString()) % 2 == 0 ? Colors.white : colorsConst.backgroundColor,
                                                    ),
                                                    children:[
                                                      Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign.left,
                                                          isCopy: true,
                                                          text:data.customerName.toString()=="null"?"":data.customerName.toString().trim(),
                                                          size: 14,
                                                          colors: colorsConst.textColor,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign.left,
                                                          isCopy: true,
                                                          text:data.companyName.toString()=="null"?"":data.companyName.toString().trim(),
                                                          size: 14,
                                                          colors: colorsConst.textColor,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign.left,
                                                          isCopy: true,
                                                          text:data.toData.toString()=="null"?"":data.toData.toString().trim(),
                                                          size: 14,
                                                          colors: colorsConst.textColor,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign.left,
                                                          isCopy: true,
                                                          text: data.subject.toString().trim(),
                                                          size: 14,
                                                          colors:colorsConst.textColor,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: CustomText(
                                                          isCopy: true,
                                                          textAlign: TextAlign.left,
                                                          text: data.message.toString().trim(),
                                                          size: 14,
                                                          colors:colorsConst.textColor,
                                                        ),
                                                      ),
                                                      InkWell(
                                                        onTap:(){
                                                          showMailImageDialog(context, imageList,0);
                                                        },
                                                        child: imageList.isNotEmpty
                                                            ? Builder(
                                                          builder: (context) {
                                                            final file = imageList.first.toLowerCase();
                                                            final pdfUrl = "$getImage?path=${Uri.encodeComponent(imageList.first)}";
                                                            if (file.endsWith(".pdf")) {
                                                              return InkWell(
                                                                onTap: () async {
                                                                  if (await canLaunchUrl(Uri.parse(pdfUrl))) {
                                                                    await launchUrl(Uri.parse(pdfUrl), mode: LaunchMode.platformDefault);
                                                                  } else {
                                                                    utils.snackBar(context: context, msg: 'Could not launch $pdfUrl', color: Colors.red);
                                                                  }
                                                                },
                                                                child: Container(
                                                                  padding: const EdgeInsets.all(8.0),
                                                                  child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: [
                                                                      const Icon(Icons.picture_as_pdf, color: Colors.red, size: 40),
                                                                      const SizedBox(height: 5),
                                                                      const Text("View PDF", style: TextStyle(fontSize: 12)),
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            } else if(file.toString()=="null"||file.toString()==""){
                                                              return Padding(
                                                                padding: const EdgeInsets.all(10.0),
                                                                child: CustomText(
                                                                  isCopy: false,textAlign: TextAlign.center,
                                                                  text:"No attachment",colors: Colors.grey, size: 14,
                                                                ),
                                                              );
                                                            } else if(file.endsWith(".svg")){
                                                              return SvgPicture.network(
                                                                "$getImage?path=${imageList.first}",
                                                                height: 50,width: 50,
                                                                fit: BoxFit.cover,
                                                                placeholderBuilder: (context) =>
                                                                const CircularProgressIndicator(),
                                                              );
                                                            }  else {
                                                              // else if (file.endsWith(".jpg"
                                                              //   }) ||
                                                              //   file.endsWith(".jpeg") ||
                                                              //   file.endsWith(".png")) {
                                                              return Padding(
                                                                padding: const EdgeInsets.only(top: 5),
                                                                child: Image.network(
                                                                  "$getImage?path=${Uri.encodeComponent(imageList.first)}",
                                                                  height: 50,
                                                                  fit: BoxFit.cover,
                                                                ),
                                                              );
                                                            }
                                                            // else {
                                                            //   return ListTile(
                                                            //     title: Text("Unsupported file"),
                                                            //   );
                                                            // }
                                                          },
                                                        )
                                                            : Padding(
                                                          padding: const EdgeInsets.all(10.0),
                                                          child: CustomText(
                                                            isCopy: false,textAlign: TextAlign.center,
                                                            text:"No attachment",colors: Colors.grey, size: 14,
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign.left,
                                                          text: controllers.formatDate(data.sentDate.toString()),
                                                          size: 14,
                                                          isCopy: true,
                                                          colors: colorsConst.textColor,
                                                        ),
                                                      ),
                                                    ]
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }),
                                    ),
                                    20.height,
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if(repCtr.selectFilter.value=="Appointments")
                      Container(
                        decoration: customDecoration.baseBackgroundDecoration(
                            color: Colors.grey.shade50,borderColor: colorsConst.primary,radius: 10
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      CustomText(text: "Appointments Activity Report", isCopy: false,isBold: true,size: 18,),
                                      30.width,
                                      Obx(()=> utils.selectHeatingType2("Scheduled",
                                          controllers.selectMeetingType.value=="Scheduled", (){
                                            controllers.selectMeetingType.value="Scheduled";
                                            var selectedRange = DateTimeRange(
                                              start: DateFormat('dd-MM-yyyy').parse(repCtr.stDate.value),
                                              end: DateFormat('dd-MM-yyyy').parse(
                                                repCtr.enDate.value.isEmpty
                                                    ? repCtr.stDate.value
                                                    : repCtr.enDate.value,
                                              ),
                                            );
                                            remController.selectedMeetSortBy.value=repCtr.selectedSortBy.value=="Last 30 Days"?"Next 30 Days":
                                            repCtr.selectedSortBy.value=="Last 7 Days"?"Next 7 Days":repCtr.selectedSortBy.value;
                                            remController.selectedMeetMonth.value=repCtr.selectedMonth.value;
                                            remController.selectedCallRange.value=selectedRange;
                                            remController.sortMeetings(
                                              searchText: widget.name,
                                              callType: controllers.selectMeetingType.value,
                                              sortField: '',
                                              sortOrder: controllers.sortOrderMeetingActivity.value,
                                            );
                                          }, Colors.blueAccent,controllers.allScheduleMeet,width: 130),),
                                      10.width,
                                      Obx(()=>utils.selectHeatingType2("Completed",
                                          controllers.selectMeetingType.value=="Completed", (){
                                            controllers.selectMeetingType.value="Completed";
                                            var selectedRange = DateTimeRange(
                                              start: DateFormat('dd-MM-yyyy').parse(repCtr.stDate.value),
                                              end: DateFormat('dd-MM-yyyy').parse(
                                                repCtr.enDate.value.isEmpty
                                                    ? repCtr.stDate.value
                                                    : repCtr.enDate.value,
                                              ),
                                            );
                                            remController.selectedMeetSortBy.value=repCtr.selectedSortBy.value=="Last 30 Days"?"Next 30 Days":
                                            repCtr.selectedSortBy.value=="Last 7 Days"?"Next 7 Days":repCtr.selectedSortBy.value;
                                            remController.selectedMeetMonth.value=repCtr.selectedMonth.value;
                                            remController.selectedCallRange.value=selectedRange;
                                            remController.sortMeetings(
                                              searchText: widget.name,
                                              callType: controllers.selectMeetingType.value,
                                              sortField: '',
                                              sortOrder: controllers.sortOrderMeetingActivity.value,
                                            );
                                          }, Colors.green,controllers.allCompletedMeet,width: 130),),
                                      10.width,
                                      Obx(()=> utils.selectHeatingType2("Cancelled",
                                          controllers.selectMeetingType.value=="Cancelled", (){
                                            controllers.selectMeetingType.value="Cancelled";
                                            var selectedRange = DateTimeRange(
                                              start: DateFormat('dd-MM-yyyy').parse(repCtr.stDate.value),
                                              end: DateFormat('dd-MM-yyyy').parse(
                                                repCtr.enDate.value.isEmpty
                                                    ? repCtr.stDate.value
                                                    : repCtr.enDate.value,
                                              ),
                                            );
                                            remController.selectedMeetSortBy.value=repCtr.selectedSortBy.value=="Last 30 Days"?"Next 30 Days":
                                            repCtr.selectedSortBy.value=="Last 7 Days"?"Next 7 Days":repCtr.selectedSortBy.value;
                                            remController.selectedMeetMonth.value=repCtr.selectedMonth.value;
                                            remController.selectedCallRange.value=selectedRange;
                                            remController.sortMeetings(
                                              searchText: widget.name,
                                              callType: controllers.selectMeetingType.value,
                                              sortField: '',
                                              sortOrder: controllers.sortOrderMeetingActivity.value,
                                            );
                                          }, Colors.redAccent,controllers.allCancelled,width: 130),),
                                    ],
                                  ),
                                  InkWell(
                                      onTap: (){
                                        repCtr.selectFilter.value="";
                                      },
                                      child: Icon(Icons.clear))
                                ],
                              ),
                              20.height,
                              remController.paginatedAppItems.isEmpty?
                              Center(
                                  child: SizedBox(
                                      height: 300,width: 300,
                                      child: CustomNoData())):
                              SizedBox(
                                width: double.infinity,
                                height: 300,
                                child: Column(
                                  children: [
                                    // HEADER
                                    Table(
                                      // columnWidths: tableWidthMap,
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
                                              headerCell(2, CustomText(//1
                                                textAlign: TextAlign.left,
                                                text: "Lead Name",
                                                size: 15,
                                                isBold: true,
                                                isCopy: true,
                                                colors: Colors.white,
                                              ),),
                                              headerCell(3, CustomText(//2
                                                textAlign: TextAlign.left,
                                                text: "Company name",
                                                isCopy: true,
                                                size: 15,
                                                isBold: true,
                                                colors: Colors.white,
                                              ),),
                                              headerCell(4, CustomText(//2
                                                textAlign: TextAlign.left,
                                                text: "Employee",
                                                isCopy: true,
                                                size: 15,
                                                isBold: true,
                                                colors: Colors.white,
                                              ),),
                                              headerCell(5, CustomText(
                                                textAlign: TextAlign.left,
                                                text: "Title",
                                                isCopy: true,
                                                size: 15,
                                                isBold: true,
                                                colors: Colors.white,
                                              ),),
                                              headerCell(6,  CustomText(
                                                textAlign: TextAlign.left,
                                                text: "Venue",
                                                isCopy: true,
                                                size: 15,
                                                isBold: true,
                                                colors: Colors.white,
                                              ),),
                                              headerCell(7,  CustomText(
                                                textAlign: TextAlign.left,
                                                text: "Status",
                                                isCopy: true,
                                                size: 15,
                                                isBold: true,
                                                colors: Colors.white,
                                              ),),
                                              headerCell(8, CustomText(
                                                textAlign: TextAlign.left,
                                                text: "Notes",
                                                isCopy: true,
                                                size: 15,
                                                isBold: true,
                                                colors: Colors.white,
                                              ),),
                                              headerCell(9, CustomText(
                                                textAlign: TextAlign.center,
                                                text: "Date",
                                                isCopy: true,
                                                size: 15,
                                                isBold: true,
                                                colors: Colors.white,
                                              ),)
                                            ]),
                                      ],
                                    ),
                                    // BODY LIST
                                    Expanded(
                                      child: ListView.builder(
                                        controller: _controller,
                                        shrinkWrap: true,
                                        physics: const ScrollPhysics(),
                                        itemCount: remController.paginatedAppItems.length,
                                        itemBuilder: (context, index) {
                                          final data = remController.paginatedAppItems[index];
                                          return Table(
                                            // columnWidths: {
                                            //   for (int i = 0; i < colWidths.length; i++)
                                            //     i: FixedColumnWidth(colWidths[i]),
                                            // },
                                            border: TableBorder(
                                              horizontalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                                              verticalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                                              bottom:  BorderSide(width: 0.5, color: Colors.grey.shade400),
                                            ),
                                            children:[
                                              TableRow(
                                                  decoration: BoxDecoration(
                                                    color: int.parse(index.toString()) % 2 == 0 ? Colors.white : colorsConst.backgroundColor,
                                                  ),
                                                  children:[
                                                    Padding(
                                                      padding: const EdgeInsets.all(10.0),
                                                      child: CustomText(
                                                        textAlign: TextAlign.left,
                                                        text: data.cusName.toString()=="null"?"":data.cusName.toString(),
                                                        size: 14,
                                                        isCopy: true,
                                                        colors:colorsConst.textColor,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(10.0),
                                                      child: CustomText(
                                                        textAlign: TextAlign.left,
                                                        text:data.comName.toString()=="null"?"":data.comName.toString(),
                                                        size: 14,
                                                        isCopy: true,
                                                        colors: colorsConst.textColor,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(10.0),
                                                      child: CustomText(
                                                        textAlign: TextAlign.left,
                                                        text:data.employeeName.toString()=="null"?"":data.employeeName.toString(),
                                                        size: 14,
                                                        isCopy: true,
                                                        colors: colorsConst.textColor,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(10.0),
                                                      child: CustomText(
                                                        textAlign: TextAlign.left,
                                                        isCopy: true,
                                                        text: data.title.toString(),
                                                        size: 14,
                                                        colors:colorsConst.textColor,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(10.0),
                                                      child: CustomText(
                                                        textAlign: TextAlign.left,
                                                        text: data.venue.toString(),
                                                        size: 14,
                                                        isCopy: true,
                                                        colors:colorsConst.textColor,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(10.0),
                                                      child: CustomText(
                                                        textAlign: TextAlign.left,
                                                        text: data.status.toString(),
                                                        size: 14,
                                                        isCopy: true,
                                                        colors:data.status.toString()=="Scheduled"?Colors.blue:data.status.toString()=="Cancelled"?Colors.red:Colors.green,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(10.0),
                                                      child: CustomText(
                                                        textAlign: TextAlign.left,
                                                        text: data.notes.toString(),
                                                        isCopy: true,
                                                        size: 14,
                                                        colors:colorsConst.textColor,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(10.0),
                                                      child: CustomText(
                                                        textAlign: TextAlign.left,
                                                        text: utils.formatDateTime(data.dates,data.time),
                                                        size: 14,
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
                                    20.height,
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if(repCtr.selectFilter.value=="Quotations")
                      Container(
                        decoration: customDecoration.baseBackgroundDecoration(
                          color: Colors.grey.shade50,borderColor: colorsConst.primary,radius: 10
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      CustomText(text: "Quotations Details Report", isCopy: false,isBold: true,size: 18,),
                                      30.width,
                                      Obx(()=> utils.selectHeatingType2("Total Quotations",
                                          controllers.sortOrderType.value=="all", (){
                                            controllers.sortOrderType.value="";
                                            productCtr.filterAndSortQuotations(
                                              searchText: widget.name,
                                              sortField: controllers.sortFieldCallActivity.value,
                                              sortOrder: controllers.sortOrderCallActivity.value,
                                              selectedMonth: productCtr.selectedCallMonth.value,
                                              selectedRange: remController.selectedCallRange.value,
                                              selectedDateFilter: productCtr.selectedCallSortBy.value,
                                            );
                                          }, Colors.blueAccent,productCtr.fullOrder.value.toString().obs,width: 180),),
                                      10.width,
                                      Obx(()=>utils.selectHeatingType2("Converted to order",
                                          controllers.sortOrderType.value=="Order Confirmed", (){
                                            controllers.sortOrderType.value="Order Confirmed";
                                            productCtr.filterAndSortQuotations(
                                              searchText: widget.name,
                                              sortField: controllers.sortFieldCallActivity.value,
                                              sortOrder: controllers.sortOrderCallActivity.value,
                                              selectedMonth: productCtr.selectedCallMonth.value,
                                              selectedRange: remController.selectedCallRange.value,
                                              selectedDateFilter: productCtr.selectedCallSortBy.value,
                                            );
                                          }, Colors.green,productCtr.completedOrder.value.toString().obs,width: 200),),
                                      10.width,
                                      Obx(()=> utils.selectHeatingType2("Pending",
                                          controllers.sortOrderType.value=="Pending", (){
                                            controllers.sortOrderType.value="Pending";
                                            productCtr.filterAndSortQuotations(
                                              searchText: widget.name,
                                              sortField: controllers.sortFieldCallActivity.value,
                                              sortOrder: controllers.sortOrderCallActivity.value,
                                              selectedMonth: productCtr.selectedCallMonth.value,
                                              selectedRange: remController.selectedCallRange.value,
                                              selectedDateFilter: productCtr.selectedCallSortBy.value,
                                            );
                                          }, Colors.redAccent,productCtr.pendingOrder.value.toString().obs,width: 130),),
                                    ],
                                  ),
                                  InkWell(
                                      onTap: (){
                                        repCtr.selectFilter.value="";
                                      },
                                      child: Icon(Icons.clear))
                                ],
                              ),
                              20.height,
                              productCtr.paginatedItems.isEmpty?
                              Center(
                                  child: SizedBox(
                                      height: 300,width: 300,
                                      child: CustomNoData())):
                              SizedBox(
                                width: double.infinity,
                                height: 300,
                                child: Column(
                                  children: [
                                    // HEADER
                                    Table(
                                      // columnWidths: tableWidthMap,
                                      border: TableBorder(
                                        horizontalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                                        verticalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                                      ),
                                      children: [
                                        TableRow(
                                            decoration: BoxDecoration(
                                                color: colorsConst.primary,
                                                borderRadius: const BorderRadius
                                                    .only(
                                                    topLeft: Radius.circular(
                                                        5),
                                                    topRight: Radius.circular(
                                                        5))),
                                            children: [
                                              headerCell(8, CustomText(
                                                textAlign: TextAlign.left,
                                                text: "Quotation Number - Date",
                                                size: 15,
                                                isBold: true,
                                                isCopy: true,
                                                colors: Colors.white,
                                              ),),
                                              headerCell(3, CustomText( //4
                                                textAlign: TextAlign.left,
                                                text: "Status",
                                                size: 15,
                                                isBold: true,
                                                isCopy: true,
                                                colors: Colors.white,
                                              ),),
                                              headerCell(4, CustomText( //2
                                                textAlign: TextAlign.left,
                                                text: "Customer",
                                                size: 15,
                                                isBold: true,
                                                isCopy: true,
                                                colors: Colors.white,
                                              ),),
                                              headerCell(5, CustomText( //2
                                                textAlign: TextAlign.left,
                                                text: "Company",
                                                size: 15,
                                                isBold: true,
                                                isCopy: true,
                                                colors: Colors.white,
                                              ),),
                                              headerCell(6, CustomText(
                                                textAlign: TextAlign.left,
                                                text: "Phone No",
                                                size: 15,
                                                isBold: true,
                                                isCopy: true,
                                                colors: Colors.white,
                                              ),),
                                              headerCell(7, CustomText(
                                                textAlign: TextAlign.left,
                                                text: "Tot Prds",
                                                size: 15,
                                                isBold: true,
                                                isCopy: true,
                                                colors: Colors.white,
                                              ),),
                                              headerCell(8, CustomText(
                                                textAlign: TextAlign.left,
                                                text: "Tot Item",
                                                size: 15,
                                                isBold: true,
                                                isCopy: true,
                                                colors: Colors.white,
                                              ),),
                                              headerCell(9, CustomText(
                                                textAlign: TextAlign.left,
                                                text: "Tot Amt",
                                                size: 15,
                                                isBold: true,
                                                isCopy: true,
                                                colors: Colors.white,
                                              ),),
                                              headerCell(10, CustomText( //4
                                                textAlign: TextAlign.left,
                                                text: "Validity",
                                                size: 15,
                                                isBold: true,
                                                isCopy: true,
                                                colors: Colors.white,
                                              ),),
                                              headerCell(11, CustomText(
                                                textAlign: TextAlign.left,
                                                text: "Quotation",
                                                size: 15,
                                                isBold: true,
                                                isCopy: true,
                                                colors: Colors.white,
                                              ),),
                                            ]),
                                      ],
                                    ),
                                    // BODY LIST
                                    Expanded(
                                      child: ListView.builder(
                                        controller: _controller,
                                        itemCount: productCtr.paginatedItems
                                            .length,
                                        itemBuilder: (context, index) {
                                          var data = productCtr.paginatedItems[index];
                                          return Table(
                                            // columnWidths: tableWidthMap,
                                            border: TableBorder(
                                              horizontalInside: BorderSide(
                                                  width: 0.5,
                                                  color: Colors.grey
                                                      .shade400),
                                              verticalInside: BorderSide(
                                                  width: 0.5,
                                                  color: Colors.grey
                                                      .shade400),
                                              bottom: BorderSide(width: 0.5,
                                                  color: Colors.grey
                                                      .shade400),
                                            ),
                                            children: [
                                              TableRow(
                                                  decoration: BoxDecoration(
                                                    color: int.parse(
                                                        index.toString()) %
                                                        2 == 0 ? Colors
                                                        .white : colorsConst
                                                        .backgroundColor,
                                                  ),
                                                  children: [
                                                    InkWell(
                                                      onTap:(){
                                                        Get.to(ViewQuotationDetails(id:data.id.toString(), list: data,));
                                                      },
                                                      child: Padding(
                                                        padding: const EdgeInsets
                                                            .all(10.0),
                                                        child: Column(
                                                          children: [
                                                            Row(
                                                              children: [
                                                                // SizedBox(
                                                                //   width: 30,
                                                                //   child: Column(
                                                                //     crossAxisAlignment: CrossAxisAlignment.start,
                                                                //     children: [
                                                                //       CustomText(text: "Quo", isCopy: false,size: 13,),
                                                                //       if(data.poNumber!="null"&&data.poNumber!="")
                                                                //         CustomText(text: "PO", isCopy: false,size: 13,colors: Colors.blue,),
                                                                //       if(data.invoiceDate!="null"&&data.invoiceDate!="")
                                                                //         CustomText(text: "Inv", isCopy: false,size: 13,colors: Colors.green,),
                                                                //     ],
                                                                //   ),
                                                                // ),
                                                                SizedBox(
                                                                  width: 60,
                                                                  // color: Colors.pinkAccent,
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      CustomText(
                                                                        textAlign: TextAlign.left,
                                                                        text: data.quotationNo,
                                                                        size: 13,
                                                                        isCopy: true,
                                                                        colors: colorsConst.textColor,
                                                                      ),
                                                                      if(data.poNumber!="null"&&data.poNumber!="")
                                                                        CustomText(
                                                                          textAlign: TextAlign.center,
                                                                          text: data.poNumber,
                                                                          size: 13,
                                                                          isCopy: true,
                                                                          colors: Colors.blue,
                                                                        ),
                                                                      if(data.invoiceDate!="null"&&data.invoiceDate!="")
                                                                        CustomText(
                                                                          textAlign: TextAlign.center,
                                                                          text: data.iNo,
                                                                          size: 13,
                                                                          isCopy: true,
                                                                          colors: Colors.green,
                                                                        ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 60,
                                                                  // color: Colors.pinkAccent,
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      CustomText(
                                                                        textAlign: TextAlign.left,
                                                                        text: productCtr.showDate(data.createdTs.toString()),
                                                                        size: 13,
                                                                        isCopy: true,
                                                                        colors: colorsConst.textColor,
                                                                      ),
                                                                      if(data.poNumber!="null"&&data.poNumber!="")
                                                                        CustomText(
                                                                          textAlign: TextAlign.center,
                                                                          text: data.poDate,
                                                                          size: 13,
                                                                          isCopy: true,
                                                                          colors: Colors.blue,
                                                                        ),
                                                                      if(data.invoiceDate!="null"&&data.invoiceDate!="")
                                                                        CustomText(
                                                                          textAlign: TextAlign.left,
                                                                          text: productCtr.showDate(data.invoiceDate.toString()),
                                                                          size: 13,
                                                                          isCopy: true,
                                                                          colors: Colors.green,
                                                                        ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    InkWell(
                                                      onTap:(){
                                                        Get.to(ViewQuotationDetails(id:data.id.toString(), list: data,));
                                                      },
                                                      child: Padding(
                                                        padding: const EdgeInsets
                                                            .all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign
                                                              .left,
                                                          text: data.status,
                                                          size: 14,
                                                          isCopy: true,
                                                          colors: colorsConst
                                                              .textColor,
                                                        ),
                                                      ),
                                                    ),
                                                    InkWell(
                                                      onTap:(){
                                                        Get.to(ViewQuotationDetails(id:data.id.toString(), list: data,));
                                                      },
                                                      child: Padding(
                                                        padding: const EdgeInsets
                                                            .all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign
                                                              .left,
                                                          text: data.name
                                                              .toString() ==
                                                              "null"
                                                              ? ""
                                                              : data.name
                                                              .toString(),
                                                          size: 14,
                                                          isCopy: true,
                                                          colors: colorsConst
                                                              .textColor,
                                                        ),
                                                      ),
                                                    ),
                                                    InkWell(
                                                      onTap:(){
                                                        Get.to(ViewQuotationDetails(id:data.id.toString(), list: data,));
                                                      },
                                                      child: Padding(
                                                        padding: const EdgeInsets
                                                            .all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign
                                                              .left,
                                                          text: data.company
                                                              .toString() ==
                                                              "null"
                                                              ? ""
                                                              : data.company
                                                              .toString(),
                                                          size: 14,
                                                          isCopy: true,
                                                          colors: colorsConst
                                                              .textColor,
                                                        ),
                                                      ),
                                                    ),
                                                    InkWell(
                                                      onTap:(){
                                                        Get.to(ViewQuotationDetails(id:data.id.toString(), list: data,));
                                                      },
                                                      child: Padding(
                                                        padding: const EdgeInsets
                                                            .all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign
                                                              .left,
                                                          text: data.number
                                                              .toString(),
                                                          size: 14,
                                                          isCopy: true,
                                                          colors: colorsConst
                                                              .textColor,
                                                        ),
                                                      ),
                                                    ),
                                                    InkWell(
                                                      onTap:(){
                                                        Get.to(ViewQuotationDetails(id:data.id.toString(), list: data,));
                                                      },
                                                      child: Padding(
                                                        padding: const EdgeInsets
                                                            .all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign
                                                              .center,
                                                          text: data
                                                              .totalProduct
                                                              .toString(),
                                                          size: 14,
                                                          isCopy: true,
                                                          colors: colorsConst
                                                              .textColor,
                                                        ),
                                                      ),
                                                    ),
                                                    InkWell(
                                                      onTap:(){
                                                        Get.to(ViewQuotationDetails(id:data.id.toString(), list: data,));
                                                      },
                                                      child: Padding(
                                                        padding: const EdgeInsets
                                                            .all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign
                                                              .center,
                                                          text: data
                                                              .totalItem
                                                              .toString(),
                                                          size: 14,
                                                          isCopy: true,
                                                          colors: colorsConst
                                                              .textColor,
                                                        ),
                                                      ),
                                                    ),
                                                    InkWell(
                                                      onTap:(){
                                                        Get.to(ViewQuotationDetails(id:data.id.toString(), list: data,));
                                                      },
                                                      child: Padding(
                                                        padding: const EdgeInsets
                                                            .all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign
                                                              .end,
                                                          text: productCtr
                                                              .formatAmount(
                                                              data.totalAmt
                                                                  .toString()),
                                                          size: 14,
                                                          isCopy: true,
                                                          colors: colorsConst
                                                              .textColor,
                                                        ),
                                                      ),
                                                    ),
                                                    InkWell(
                                                      onTap:(){
                                                        Get.to(ViewQuotationDetails(id:data.id.toString(), list: data,));
                                                      },
                                                      child: Padding(
                                                        padding: const EdgeInsets
                                                            .all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign
                                                              .left,
                                                          text: data.validityDate.toString().contains("to")
                                                              ? data.validityDate.toString().split("to").last.trim()
                                                              : data.validityDate.toString(),
                                                          size: 14,
                                                          isCopy: true,
                                                          colors: colorsConst
                                                              .textColor,
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .all(10.0),
                                                      child: InkWell(
                                                        onTap: () {
                                                          String url = "$getImage?path=${Uri.encodeComponent(data.invoicePdf)}";
                                                          utils.showPdfDialog(
                                                              context, url);
                                                        },
                                                        child: Padding(
                                                          padding: const EdgeInsets
                                                              .fromLTRB(
                                                              8, 10, 8, 10),
                                                          child: CustomText(
                                                            text: "View Quotation",
                                                            isCopy: false,
                                                            colors: colorsConst
                                                                .primary,),
                                                        ),
                                                      ),
                                                    ),
                                                  ]
                                              ),
                                            ],
                                          );
                                        },
                                      )
                                    ),
                                    20.height,
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if(repCtr.selectFilter.value=="Orders")
                      Container(
                        decoration: customDecoration.baseBackgroundDecoration(
                            color: Colors.grey.shade50,borderColor: colorsConst.primary,radius: 10
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      CustomText(text: "Orders Details Report", isCopy: false,isBold: true,size: 18,),
                                      30.width,
                                      Obx(()=> utils.selectHeatingType2("Total Orders",
                                          ""=="all", (){
                                          }, Colors.blueAccent,productCtr.paginatedOrdersItems.length.toString().obs,width: 150),),
                                    ],
                                  ),
                                  InkWell(
                                      onTap: (){
                                        repCtr.selectFilter.value="";
                                      },
                                      child: Icon(Icons.clear))
                                ],
                              ),
                              20.height,
                              productCtr.paginatedOrdersItems.isEmpty?
                              Center(
                                  child: SizedBox(
                                      height: 300,width: 300,
                                      child: CustomNoData())):
                              SizedBox(
                                width: double.infinity,
                                height: 300,
                                child: Column(
                                  children: [
                                    // HEADER
                                    Table(
                                      // columnWidths: tableWidthMap,
                                      border: TableBorder(
                                        horizontalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                                        verticalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                                      ),
                                      children: [
                                        TableRow(
                                            decoration: BoxDecoration(
                                                color: colorsConst.primary,
                                                borderRadius: const BorderRadius
                                                    .only(
                                                    topLeft: Radius.circular(
                                                        5),
                                                    topRight: Radius.circular(
                                                        5))),
                                            children: [
                                              headerCell(8, CustomText(
                                                textAlign: TextAlign.left,
                                                text: "Invoice No",
                                                size: 15,
                                                isBold: true,
                                                isCopy: true,
                                                colors: Colors.white,
                                              ),),
                                              headerCell(3, CustomText( //4
                                                textAlign: TextAlign.left,
                                                text: "status",
                                                size: 15,
                                                isBold: true,
                                                isCopy: true,
                                                colors: Colors.white,
                                              ),),
                                              headerCell(4, CustomText( //2
                                                textAlign: TextAlign.left,
                                                text: "Company Name",
                                                size: 15,
                                                isBold: true,
                                                isCopy: true,
                                                colors: Colors.white,
                                              ),),
                                              headerCell(5, CustomText( //2
                                                textAlign: TextAlign.left,
                                                text: "Customer Name",
                                                size: 15,
                                                isBold: true,
                                                isCopy: true,
                                                colors: Colors.white,
                                              ),),
                                              headerCell(6, CustomText(
                                                textAlign: TextAlign.left,
                                                text: "Total Amount",
                                                size: 15,
                                                isBold: true,
                                                isCopy: true,
                                                colors: Colors.white,
                                              ),),
                                              headerCell(7, CustomText(
                                                textAlign: TextAlign.left,
                                                text: "Order Date",
                                                size: 15,
                                                isBold: true,
                                                isCopy: true,
                                                colors: Colors.white,
                                              ),),
                                              headerCell(8, CustomText(
                                                textAlign: TextAlign.left,
                                                text: "Order Details",
                                                size: 15,
                                                isBold: true,
                                                isCopy: true,
                                                colors: Colors.white,
                                              ),),
                                            ]),
                                      ],
                                    ),
                                    // BODY LIST
                                    Expanded(
                                      child: ListView.builder(
                                        controller: _controller,
                                        itemCount: productCtr.paginatedOrdersItems.length,
                                        itemBuilder: (context, index) {
                                          var data = productCtr.paginatedOrdersItems[index];
                                          return Table(
                                            // columnWidths: tableWidthMap,
                                            border: TableBorder(
                                              horizontalInside: BorderSide(
                                                  width: 0.5,
                                                  color: Colors.grey
                                                      .shade400),
                                              verticalInside: BorderSide(
                                                  width: 0.5,
                                                  color: Colors.grey
                                                      .shade400),
                                              bottom: BorderSide(width: 0.5,
                                                  color: Colors.grey
                                                      .shade400),
                                            ),
                                            children: [
                                              TableRow(
                                                  decoration: BoxDecoration(
                                                    color: int.parse(
                                                        index.toString()) %
                                                        2 == 0 ? Colors
                                                        .white : colorsConst
                                                        .backgroundColor,
                                                  ),
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.all(10.0),
                                                      child: CustomText(
                                                        textAlign: TextAlign.left,
                                                        text: data.orderId.toString() == "null"? ""
                                                            : data.orderId.toString(),
                                                        size: 13,
                                                        isCopy: true,
                                                        colors: colorsConst.textColor,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(10.0),
                                                      child: CustomText(
                                                        textAlign: TextAlign.left,
                                                        text: data.status.toString(),
                                                        size: 13,
                                                        isCopy: true,
                                                        colors: colorsConst.textColor,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(10.0),
                                                      child: CustomText(
                                                        textAlign: TextAlign.left,
                                                        text: data.companyName.toString(),
                                                        size: 13,
                                                        isCopy: true,
                                                        colors: colorsConst.textColor,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(10.0),
                                                      child: CustomText(
                                                        textAlign: TextAlign.left,
                                                        text: data.customerName.toString(),
                                                        size: 13,
                                                        isCopy: true,
                                                        colors: colorsConst.textColor,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(10.0),
                                                      child: CustomText(
                                                        textAlign: TextAlign.left,
                                                        text: productCtr.formatAmount(
                                                          data.totalAmt.toString(),
                                                        ),
                                                        size: 13,
                                                        isCopy: true,
                                                        colors: colorsConst.textColor,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(10.0),
                                                      child: CustomText(
                                                        textAlign: TextAlign.left,
                                                        text: productCtr.fixedDateTime(
                                                          data.createdTs.toString(),
                                                        ),
                                                        size: 13,
                                                        isCopy: true,
                                                        colors: colorsConst.textColor,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(10.0),
                                                      child: InkWell(
                                                        onTap:(){
                                                          showDialog(
                                                            context: context,
                                                            builder: (_) => OrderInvoiceDialog(order: data),
                                                          );
                                                        },
                                                        child: CustomText(
                                                          textAlign: TextAlign.left,
                                                          text: "View Order",
                                                          size: 13,
                                                          isCopy: false,
                                                          colors: colorsConst.primary,
                                                        ),
                                                      ),
                                                    ),
                                                  ]
                                              ),
                                            ],
                                          );
                                        },
                                      )
                                    ),
                                    20.height,
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      20.height,
                      SizedBox(
                        width: double.infinity,
                        height: 100,
                        child: ListView.builder(
                            itemCount: repCtr.leadReport.length,
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {

                              int count = int.parse(
                                repCtr.leadReport[index]["total_count"].toString(),
                              );

                              double percentage = repCtr.firstCount.value == 0
                                  ? 0
                                  : (count / repCtr.firstCount.value) * 100;

                              return Row(
                                children: [
                                  Container(
                                    width: 130,
                                    padding: const EdgeInsets.all(15),
                                    decoration: customDecoration.baseBackgroundDecoration(
                                      color: controllers.leadColors[index].withOpacity(0.1),
                                      radius: 14,
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        CustomText(
                                          text: repCtr.leadReport[index]["category"],
                                          isCopy: false,
                                          colors: controllers.leadColors[index],
                                          isBold: true,
                                        ),
                                        10.height,
                                        CustomText(
                                          text: count.toString(),
                                          isCopy: false,
                                          isBold: true,
                                          size: 17,
                                        ),
                                        6.height,
                                        CustomText(
                                          text: "(${percentage.toStringAsFixed(2)}%)",
                                          isCopy: false,
                                          isBold: true,
                                        ),
                                      ],
                                    ),
                                  ),

                                  if (index != repCtr.leadReport.length - 1)
                                    const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 10),
                                      child: Icon(Icons.arrow_forward_rounded,color: Colors.grey,),
                                    ),
                                ],
                              );
                            }
                        ),
                      ),
                      20.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: screenWidth/1.4,
                            padding: const EdgeInsets.all(16),
                            decoration: customDecoration.baseBackgroundDecoration(
                              color: Colors.white,
                              radius: 15,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: colorsConst.primary,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      topRight: Radius.circular(8)
                                    )
                                  ),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: screenWidth/8,
                                              child: CustomText(size: 15,
                                                text: "Comparison Report",
                                                isCopy: false,colors: Colors.white,
                                                isBold: true,textAlign: TextAlign.start,
                                              ),
                                            ),
                                            SizedBox(
                                              width: screenWidth/7,
                                              child: CustomText(size: 15,
                                                text: "Last Week",
                                                isCopy: false,colors: Colors.white,
                                                isBold: true,
                                              ),
                                            ),
                                            SizedBox(
                                              width: screenWidth/7,
                                              child: CustomText(size: 15,
                                                text: "This Week",colors: Colors.white,
                                                isCopy: false,
                                                isBold: true,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: screenWidth/8,
                                              child: CustomText(size: 15,
                                                text: "Activity",
                                                isCopy: false,colors: Colors.white,
                                                isBold: true,textAlign: TextAlign.start,
                                              ),
                                            ),
                                            SizedBox(
                                              width: screenWidth/7,
                                              child: CustomText(size: 15,
                                                text: "${DateFormat('dd/MM/yyyy').format(repCtr.lastWeekStart)} to ${DateFormat('dd/MM/yyyy').format(repCtr.lastWeekEnd)}",
                                                isCopy: false,colors: Colors.white,
                                                isBold: true,
                                              ),
                                            ),
                                            SizedBox(
                                              width: screenWidth/7,
                                              child: CustomText(size: 15,
                                                text: "${DateFormat('dd/MM/yyyy').format(repCtr.thisWeekStart)} to ${DateFormat('dd/MM/yyyy').format(repCtr.thisWeekEnd)}",
                                                isCopy: false,colors: Colors.white,
                                                isBold: true,
                                              ),
                                            ),
                                            SizedBox(
                                              width: screenWidth/8,
                                              child: CustomText(size: 15,
                                                text: "Change",
                                                isCopy: false,colors: Colors.white,
                                                isBold: true,
                                              ),
                                            ),
                                            SizedBox(
                                              width: screenWidth/7,
                                              child: CustomText(size: 15,
                                                text: "Change %",colors: Colors.white,
                                                isCopy: false,
                                                isBold: true,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: repCtr.comparisonReport.length,
                                  separatorBuilder: (_, __) => const Divider(height: 1),
                                  itemBuilder: (context, index) {

                                    final data = repCtr.comparisonReport[index];

                                    double percent =
                                        double.tryParse(data["change_percent"].toString()) ?? 0;
                                    int change = data["change"];

                                    bool isPositive = change >= 0;

                                    return Padding(
                                      // padding: const EdgeInsets.symmetric(vertical: 12),
                                      padding: const EdgeInsets.all(5),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: screenWidth/8,
                                            child: Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 14,
                                                  backgroundColor: controllers.leadColors[index]
                                                      .withOpacity(.15),
                                                  child: Icon(
                                                    repCtr.activityIcons[index],
                                                    size: 15,
                                                    color: controllers.leadColors[index],
                                                  ),
                                                ),

                                                const SizedBox(width: 10),

                                                CustomText(
                                                  text: data["activity"],
                                                  isCopy: false,
                                                  textAlign: TextAlign.left,
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: screenWidth/7,
                                            child: CustomText(
                                              text: data["previous"].toString(),
                                              isCopy: false,
                                            ),
                                          ),
                                          SizedBox(
                                            width: screenWidth/7,
                                            child: CustomText(
                                              text: data["current"].toString(),
                                              isCopy: false,
                                            ),
                                          ),

                                          SizedBox(
                                            width: screenWidth/8,
                                            child: CustomText(
                                              text: data["change"] > 0
                                                  ? "+${data["change"]}"
                                                  : data["change"].toString(),
                                              isCopy: false,
                                              colors:
                                              isPositive ? Colors.green : Colors.red,
                                              isBold: true,
                                            ),
                                          ),

                                          SizedBox(
                                            width: screenWidth/7,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                CustomText(
                                                  text:
                                                  "${percent.toStringAsFixed(2)}%",
                                                  isCopy: false,
                                                  colors:
                                                  isPositive ? Colors.green : Colors.red,
                                                  isBold: true,
                                                ),
                                                const SizedBox(width: 5),
                                                Icon(
                                                  isPositive
                                                      ? Icons.arrow_drop_up
                                                      : Icons.arrow_drop_down,
                                                  color:
                                                  isPositive ? Colors.green : Colors.red,
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                )
                              ],
                            ),
                          ),
                          Container(
                            width: screenWidth/6,
                            height: 300,
                            padding: const EdgeInsets.all(18),
                            decoration: customDecoration.baseBackgroundDecoration(
                              color: Colors.white,
                              radius: 14,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      color: colorsConst.primary,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(8),
                                          topRight: Radius.circular(8)
                                      )
                                  ),
                                  width: screenWidth/7,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const CustomText(
                                          text: "Activity Summary",
                                          isCopy: false,
                                          isBold: true,
                                          size: 15,colors: Colors.white,
                                        ),
                                        5.height,
                                        const CustomText(
                                          text: "Employee Status Overview",
                                          isCopy: false,colors: Colors.white,
                                          size: 14,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                20.height,
                                _summaryRow(
                                  "Total Activities",
                                  repCtr.activeReport["total_activities"].toString(),screenWidth/15
                                ),
                                const Divider(),
                                _summaryRow(
                                  "Average Per Day",
                                  repCtr.activeReport["average_per_day"].toString(),screenWidth/15
                                ),
                                const Divider(),
                                _summaryRow(
                                  "Most Active Day",
                                  "${repCtr.activeReport["most_active_day"]}\n(${repCtr.activeReport["most_active_count"]} Activities)",screenWidth/15
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      20.height,
                    ],
                  ),
                ],
              ),
            ),
          ),)
        ],
      ),
    );
  }
  Widget _summaryRow(String title, String value,double width) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        SizedBox(
          // color: Colors.purple,
          width: width,
          child: CustomText(
            text: title,
            isCopy: false,
            colors: Colors.grey,
            textAlign: TextAlign.left,
          ),
        ),

        CustomText(
          text: value.trim(),
          isCopy: false,
          isBold: true,
          textAlign: TextAlign.right,
        ),
      ],
    );
  }
}
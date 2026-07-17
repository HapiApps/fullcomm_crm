import 'package:flutter/material.dart';
import 'package:fullcomm_crm/billing_utils/sized_box.dart';
import 'package:fullcomm_crm/common/constant/colors_constant.dart';
import 'package:fullcomm_crm/components/custom_loading_button.dart';
import 'package:fullcomm_crm/controller/product_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../common/utilities/excel_export_service.dart';
import '../components/custom_appbar.dart';
import '../components/custom_sidebar.dart';
import '../components/custom_text.dart'; // adjust path if CustomText is elsewhere
import '../controller/controller.dart';
import '../controller/dashboard_controller.dart';

class ReportTablesScreen extends StatefulWidget {
  const ReportTablesScreen({super.key});

  @override
  State<ReportTablesScreen> createState() => _ReportTablesScreenState();
}

class _ReportTablesScreenState extends State<ReportTablesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final Map<String, dynamic> dashboardData = {
    'totalSales': int.parse(dashController.totalQuotationsAmt.value.toString()),
    'totalPurchase': int.parse(dashController.totalAmt.value.toString()),
    'totalExpenses': 75000,
    'totalReceipts': 790000,
    'totalPayments': 510000,
    'cashBalance': 145000,
    'bankBalance': 230000,
    'profit': int.parse(dashController.totalAmt.value.toString()),
  };

  final List<Map<String, dynamic>> dayBookList = [
    {'date': '08-07-2026', 'voucherNo': 'S001', 'type': 'Sales', 'particulars': 'ABC Traders', 'debit': 15000, 'credit': 0},
    {'date': '08-07-2026', 'voucherNo': 'P001', 'type': 'Purchase', 'particulars': 'XYZ Suppliers', 'debit': 0, 'credit': 8500},
    {'date': '08-07-2026', 'voucherNo': 'E001', 'type': 'Expense', 'particulars': 'Office Rent', 'debit': 12000, 'credit': 0},
  ];
  final List<Map<String, dynamic>> salesList = [];
  // final List<Map<String, dynamic>> salesList = [
  //   {'date': '08-07-2026', 'invoiceNo': 'INV001', 'customer': 'ABC Traders', 'amount': 12000, 'gst': 2160, 'total': 14160},
  //   {'date': '08-07-2026', 'invoiceNo': 'INV002', 'customer': 'Kumar Stores', 'amount': 18000, 'gst': 3240, 'total': 21240},
  // ];

  final List<Map<String, dynamic>> purchaseList = [];
  // final List<Map<String, dynamic>> purchaseList = [
  //   {'date': '08-07-2026', 'billNo': 'P001', 'supplier': 'XYZ Suppliers', 'amount': 25000, 'gst': 4500, 'total': 29500},
  // ];

  final List<Map<String, dynamic>> ledgerList = [
    {'date': '01-07-2026', 'voucher': 'Opening', 'particulars': 'Opening Balance', 'debit': 0, 'credit': 0, 'balance': '10,000 Dr'},
    {'date': '08-07-2026', 'voucher': 'Sales', 'particulars': 'Invoice INV001', 'debit': 14160, 'credit': 0, 'balance': '24,160 Dr'},
    {'date': '10-07-2026', 'voucher': 'Receipt', 'particulars': 'Cash Received', 'debit': 0, 'credit': 10000, 'balance': '14,160 Dr'},
  ];

  final List<Map<String, dynamic>> trialBalanceList = [
    {'ledger': 'Cash', 'debit': 145000, 'credit': 0},
    {'ledger': 'Bank', 'debit': 230000, 'credit': 0},
    {'ledger': 'Sales', 'debit': 0, 'credit': 850000},
    {'ledger': 'Purchase', 'debit': 420000, 'credit': 0},
    {'ledger': 'Expenses', 'debit': 75000, 'credit': 0},
    {'ledger': 'Capital', 'debit': 0, 'credit': 320000},
  ];

  final List<Map<String, dynamic>> plList = [
    {'particulars': 'Sales', 'amount': 850000},
    {'particulars': 'Less Purchase', 'amount': 420000},
    {'particulars': 'Gross Profit', 'amount': 430000},
    {'particulars': 'Less Expenses', 'amount': 75000},
    {'particulars': 'Net Profit', 'amount': 355000},
  ];

  final Map<String, dynamic> bsData = {
    'assets': [
      {'particulars': 'Cash', 'amount': 145000},
      {'particulars': 'Bank', 'amount': 230000},
      {'particulars': 'Stock', 'amount': 360000},
      {'particulars': 'Debtors', 'amount': 220000},
    ],
    'liabilities': [
      {'particulars': 'Capital', 'amount': 650000},
      {'particulars': 'Creditors', 'amount': 305000},
    ],
  };

  final List<Map<String, dynamic>> receivablesList = [
    {'customer': 'ABC Traders', 'amount': 45000, 'dueDays': 15},
    {'customer': 'Kumar Stores', 'amount': 28000, 'dueDays': 7},
  ];

  final List<Map<String, dynamic>> payablesList = [
    {'supplier': 'XYZ Suppliers', 'amount': 38000, 'dueDays': 10},
    {'supplier': 'Ravi Agencies', 'amount': 22500, 'dueDays': 5},
  ];

  final List<Map<String, dynamic>> stockList = [
    {'product': 'Rice', 'opening': 200, 'inward': 100, 'outward': 80, 'closing': 220},
    {'product': 'Sugar', 'opening': 150, 'inward': 50, 'outward': 40, 'closing': 160},
  ];

  final List<Map<String, dynamic>> expenseList = [
    {'date': '01-07-2026', 'expenseHead': 'Rent', 'amount': 12000},
    {'date': '02-07-2026', 'expenseHead': 'Electricity', 'amount': 4500},
    {'date': '03-07-2026', 'expenseHead': 'Fuel', 'amount': 2800},
  ];

  final List<String> _reportNames = const [
    'Dashboard', 'Day Book', 'Sales Register', 'Purchase Register',
    'Ledger', 'Trial Balance', 'Profit & Loss', 'Balance Sheet',
    'Receivables', 'Payables', 'Stock Summary', 'Expense Report',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _reportNames.length, vsync: this);
    addData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
void addData(){
    for(var i=0;i<productCtr.quotationsList.length;i++){
      salesList.add({
        "date":DateFormat('dd/MM/yyyy').format(DateTime.parse(productCtr.quotationsList[i].createdTs)),
        "invoiceNo":productCtr.quotationsList[i].iNo,
        "customer":productCtr.quotationsList[i].name,
        "amt":productCtr.quotationsList[i].totalAmt,
        "gst":'0',
        "total":productCtr.quotationsList[i].totalAmt,
      });
      if(productCtr.quotationsList[i].poNumber!="null"&&productCtr.quotationsList[i].poNumber!=""){
        purchaseList.add({
          "date":productCtr.quotationsList[i].poDate,
          "billNo":productCtr.quotationsList[i].poNumber,
          "supplier":productCtr.quotationsList[i].name,
          "amount":productCtr.quotationsList[i].amount,
          "gst":'0',
          "total":productCtr.quotationsList[i].totalAmt,
        });
      }
    }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SideBar(),
          Obx(() => Container(
            width: controllers.isLeftOpen.value
                ? MediaQuery.of(context).size.width - 160
                : MediaQuery.of(context).size.width - 60,
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.center,
            padding: const EdgeInsets.fromLTRB(16, 5, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomAppbar(text: "Reports", subText: "",
                  actionsWidget: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
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
                                          dashController.getWholeReport();
                                        }
                                      });

                                      return;
                                  }
                                  dashController.getWholeReport();
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
                      ),
                      if(dashController.selectedSortBy.value=="Custom")
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [
                          20.width,
                          Icon(Icons.calendar_today_outlined,size: 15,),
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
                                isBold: true,isCopy: false
                            );
                          }),
                        ],
                      ),20.width,
                      CustomLoadingButton(
                          callback: () async {
                            await ExcelExportService.exportAllReports(
                              dashboard: dashboardData,
                              dayBook: dayBookList,
                              salesRegister: salesList,
                              purchaseRegister: purchaseList,
                              ledgerEntries: ledgerList,
                              trialBalance: trialBalanceList,
                              profitLoss: plList,
                              balanceSheet: bsData,
                              receivables: receivablesList,
                              payables: payablesList,
                              stockSummary: stockList,
                              expenses: expenseList,
                            );
                          }, isLoading: false,
                          backgroundColor: Colors.green, radius: 5, width: 150,isImage: false,text: "Download",height: 40,),
                    ],
                  ),),
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: colorsConst.primary,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: colorsConst.primary,
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: "Lato",
                      fontStyle: FontStyle.normal,
                    ),
                    tabs: _reportNames.map((name) => Tab(text: name)).toList(),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _dashboardTable(),
                      _dayBookTable(),
                      _salesRegisterTable(),
                      _purchaseRegisterTable(),
                      _ledgerTable(),
                      _trialBalanceTable(),
                      _profitLossTable(),
                      _balanceSheetTable(),
                      _receivablesTable(),
                      _payablesTable(),
                      _stockSummaryTable(),
                      _expenseReportTable(),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // ---------------- Generic striped Table builder (matches employee table style) ----------------

  Widget _buildStyledTable({
    required List<String> headers,
    required List<List<String>> rows,
    Map<int, TableColumnWidth>? columnWidths,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        columnWidths: columnWidths,
        defaultColumnWidth: const FixedColumnWidth(150), // fallback if a column width missing
        border: TableBorder(
          horizontalInside: BorderSide(width: 0.5, color: Colors.grey.shade400),
          verticalInside: BorderSide(width: 0.5, color: Colors.grey.shade400),
          bottom: BorderSide(width: 0.5, color: Colors.grey.shade400),
        ),
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: colorsConst.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5),
                topRight: Radius.circular(5),
              ),
            ),
            children: headers
                .map((h) => Padding(
              padding: const EdgeInsets.all(10.0),
              child: CustomText(
                textAlign: TextAlign.left,
                text: h,
                size: 14,
                isCopy: false,
                colors: Colors.white,
              ),
            ))
                .toList(),
          ),
          ...rows.asMap().entries.map((entry) {
            final i = entry.key;
            final row = entry.value;
            return TableRow(
              decoration: BoxDecoration(
                color: i % 2 == 0 ? Colors.white : colorsConst.backgroundColor,
              ),
              children: row
                  .map((cell) => Padding(
                padding: const EdgeInsets.all(10.0),
                child: CustomText(
                  textAlign: TextAlign.left,
                  text: cell,
                  size: 14,
                  isCopy: false,
                  colors: colorsConst.textColor,
                ),
              ))
                  .toList(),
            );
          }),
        ],
      ),
    );
  }
  BoxDecoration _filterGroupDecoration() => BoxDecoration(
    color: Color(0xffE2E8F0),
    borderRadius: BorderRadius.circular(5),
  );

  String _labelize(String key) {
    final withSpaces = key.replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(0)}');
    return withSpaces[0].toUpperCase() + withSpaces.substring(1);
  }

  // ---------------- 1. Dashboard ----------------

  Widget _dashboardTable() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
      child: _buildStyledTable(
        headers: ['Details', 'Value'],
        rows: dashboardData.entries
            .map((e) => [_labelize(e.key), (productCtr.formatAmount(e.value))])
            .toList(),
        columnWidths: {
          0:FixedColumnWidth(200),1:FixedColumnWidth(150)
        }
      ),
    );
  }

  // ---------------- 2. Day Book ----------------

  Widget _dayBookTable() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
      child: _buildStyledTable(
        headers: ['Date', 'Voucher No', 'Type', 'Particulars', 'Debit', 'Credit'],
        rows: dayBookList
            .map((r) => [
          '${r['date']}', '${r['voucherNo']}', '${r['type']}',
          '${r['particulars']}', (productCtr.formatAmount(r['debit'])), (productCtr.formatAmount(r['credit'])),
        ])
            .toList(),
          columnWidths: {
            0:FixedColumnWidth(200),1:FixedColumnWidth(150),2:FixedColumnWidth(150),3:FixedColumnWidth(150),4:FixedColumnWidth(150),5:FixedColumnWidth(150)
          }
      ),
    );
  }

  // ---------------- 3. Sales Register ----------------

  Widget _salesRegisterTable() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
      child: _buildStyledTable(
        headers: ['Date', 'Invoice No', 'Customer', 'Amount', 'GST', 'Total'],
        rows: salesList
            .map((r) => [
          '${r['date']}', '${r['invoiceNo']}', '${r['customer']}',
          (productCtr.formatAmount(r['amount'])), '${r['gst']}', (productCtr.formatAmount(r['total'])),
        ])
            .toList(),
          columnWidths: {
            0:FixedColumnWidth(200),1:FixedColumnWidth(150),2:FixedColumnWidth(250),3:FixedColumnWidth(150),4:FixedColumnWidth(150),5:FixedColumnWidth(150)
          }
      ),
    );
  }

  // ---------------- 4. Purchase Register ----------------

  Widget _purchaseRegisterTable() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
      child: _buildStyledTable(
        headers: ['Date', 'Bill No', 'Supplier', 'Amount', 'GST', 'Total'],
        rows: purchaseList
            .map((r) => [
          '${r['date']}', '${r['billNo']}', '${r['supplier']}',
          (productCtr.formatAmount(r['amount'])), '${r['gst']}', (productCtr.formatAmount(r['total'])),
        ])
            .toList(),
          columnWidths: {
            0:FixedColumnWidth(200),1:FixedColumnWidth(150),2:FixedColumnWidth(250),3:FixedColumnWidth(150),4:FixedColumnWidth(150),5:FixedColumnWidth(150)
          }
      ),
    );
  }

  // ---------------- 5. Ledger ----------------

  Widget _ledgerTable() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
      child: _buildStyledTable(
        headers: ['Date', 'Voucher', 'Particulars', 'Debit', 'Credit', 'Balance'],
        rows: ledgerList
            .map((r) => [
          '${r['date']}', '${r['voucher']}', '${r['particulars']}',
          (productCtr.formatAmount(r['debit'])), productCtr.formatAmount(r['credit']), '${r['balance']}',
        ])
            .toList(),
          columnWidths: {
            0:FixedColumnWidth(200),1:FixedColumnWidth(150),2:FixedColumnWidth(150),3:FixedColumnWidth(150),4:FixedColumnWidth(150),5:FixedColumnWidth(150)
          }
      ),
    );
  }

  // ---------------- 6. Trial Balance ----------------

  Widget _trialBalanceTable() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
      child: _buildStyledTable(
        headers: ['Ledger', 'Debit', 'Credit'],
        rows: trialBalanceList
            .map((r) => [(productCtr.formatAmount(r['ledger'])), (productCtr.formatAmount(r['debit'])), '${r['credit']}'])
            .toList(),
          columnWidths: {
            0:FixedColumnWidth(200),1:FixedColumnWidth(150),2:FixedColumnWidth(150)
          }
      ),
    );
  }

  // ---------------- 7. Profit & Loss ----------------

  Widget _profitLossTable() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
      child: _buildStyledTable(
        headers: ['Particulars', 'Amount'],
        rows: plList.map((r) => ['${r['particulars']}', (productCtr.formatAmount(r['amount']))]).toList(),
          columnWidths: {
            0:FixedColumnWidth(200),1:FixedColumnWidth(150)
          }
      ),
    );
  }

  // ---------------- 8. Balance Sheet ----------------

  Widget _balanceSheetTable() {
    final assets = (bsData['assets'] as List<Map<String, dynamic>>);
    final liabilities = (bsData['liabilities'] as List<Map<String, dynamic>>);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          20.height,
          CustomText(
            text: 'Assets',
            size: 16,
            isCopy: false,
            colors: colorsConst.textColor,
          ),
          20.height,
          _buildStyledTable(
            headers: const ['Particulars', 'Amount'],
            rows: assets.map((r) => ['${r['particulars']}', (productCtr.formatAmount(r['amount']))]).toList(),
              columnWidths: {
                0:FixedColumnWidth(200),1:FixedColumnWidth(150)
              }
          ),
          30.height,
          CustomText(
            text: 'Liabilities',
            size: 16,
            isCopy: false,
            colors: colorsConst.textColor,
          ),
          20.height,
          _buildStyledTable(
            headers: const ['Particulars', 'Amount'],
            rows: liabilities.map((r) => ['${r['particulars']}', productCtr.formatAmount(r['amount'])]).toList(),
              columnWidths: {
                0:FixedColumnWidth(200),1:FixedColumnWidth(150)
              }
          ),
        ],
      ),
    );
  }

  // ---------------- 9. Receivables ----------------

  Widget _receivablesTable() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
      child: _buildStyledTable(
        headers: ['Customer', 'Amount', 'Due Days'],
        rows: receivablesList
            .map((r) => ['${r['customer']}', productCtr.formatAmount(r['amount']), '${r['dueDays']}'])
            .toList(),
            columnWidths: {
              0:FixedColumnWidth(200),1:FixedColumnWidth(150),2:FixedColumnWidth(150)
            }
      ),
    );
  }

  // ---------------- 10. Payables ----------------

  Widget _payablesTable() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
      child: _buildStyledTable(
        headers: ['Supplier', 'Amount', 'Due Days'],
        rows: payablesList
            .map((r) => ['${r['supplier']}', productCtr.formatAmount(r['amount']), '${r['dueDays']}'])
            .toList(),
            columnWidths: {
              0:FixedColumnWidth(200),1:FixedColumnWidth(150),2:FixedColumnWidth(150)
            }
      ),
    );
  }

  // ---------------- 11. Stock Summary ----------------

  Widget _stockSummaryTable() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
      child: _buildStyledTable(
        headers: ['Product', 'Opening', 'Inward', 'Outward', 'Closing'],
        rows: stockList
            .map((r) => [
          '${r['product']}', '${r['opening']}', '${r['inward']}',
          '${r['outward']}', '${r['closing']}',
        ])
            .toList(),
          columnWidths: {
            0:FixedColumnWidth(200),1:FixedColumnWidth(150),2:FixedColumnWidth(150),3:FixedColumnWidth(150),4:FixedColumnWidth(150)
          }
      ),
    );
  }

  // ---------------- 12. Expense Report ----------------

  Widget _expenseReportTable() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
      child: _buildStyledTable(
        headers: ['Date', 'Expense Head', 'Amount'],
        rows: expenseList
            .map((r) => ['${r['date']}', '${r['expenseHead']}', productCtr.formatAmount(r['amount'])])
            .toList(),
          columnWidths: {
            0:FixedColumnWidth(200),1:FixedColumnWidth(150),2:FixedColumnWidth(150)
          }
      ),
    );
  }
}

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fullcomm_crm/billing_utils/sized_box.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:flutter/services.dart';
import '../../billing_utils/text_formats.dart';
import '../../common/billing_data/local_data.dart';
import '../../res/colors.dart';
import '../../res/components/k_s_textfield.dart';
import '../../res/components/k_text.dart';
import '../../view_models/billing_provider.dart';
import '../pdf/bill_pdf.dart';

class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({super.key});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  bool isSearchMode = true;
  int selectedRowIndex = 0;

  final FocusNode _rootFocusNode = FocusNode();
  final FocusNode _customerFocusNode = FocusNode();
  final ScrollController _tableScrollController = ScrollController();


  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _rootFocusNode.requestFocus();
      _customerFocusNode.requestFocus();

      final provider =
      Provider.of<BillingProvider>(context, listen: false);

      provider.changeDateFilter("Today");

      final today = DateTime.now();
      final tomorrow = today.add(const Duration(days: 1));

      provider.getAllOrderDetails(
        DateFormat('yyyy-MM-dd').format(today),
        DateFormat('yyyy-MM-dd').format(tomorrow),
      );
      provider. getAllOnlineOrderDetails(
        DateFormat('yyyy-MM-dd').format(today),
        DateFormat('yyyy-MM-dd').format(tomorrow),
      );

      provider.clearSearch();
    });
  }

  @override
  void dispose() {
    _rootFocusNode.dispose();
    _customerFocusNode.dispose();
    super.dispose();
  }
  void _scrollToSelectedRow() {
    const rowHeight = 48.0;

    final maxScroll = _tableScrollController.position.maxScrollExtent;
    final minScroll = _tableScrollController.position.minScrollExtent;

    double targetOffset = selectedRowIndex * rowHeight;

    // 🔥 clamp inside valid range
    targetOffset = targetOffset.clamp(minScroll, maxScroll);

    _tableScrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
    );
  }


  /// 📅 CUSTOM DATE

  void showDatePickerDialog(BuildContext context) {
    final dateProvider = Provider.of<BillingProvider>(context, listen: false);
    dynamic selectedRange;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const MyText(
              text: 'Select Date',
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
            content: SizedBox(
              height: 300,
              width: 300,
              child: SfDateRangePicker(
                backgroundColor: const Color(0xffFFFCF9),
                minDate: DateTime(2023),
                maxDate: DateTime.now(),
                selectionMode: DateRangePickerSelectionMode.range,
                onSelectionChanged: (args) {
                  setState(() {
                    selectedRange = args.value;
                  });
                },
              ),
            ),
            actions: [
              TextButton(
                child: const MyText(
                  text: 'Cancel',
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: const MyText(
                  text: 'OK',
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
                onPressed: () {
                  if (selectedRange != null) {
                    dateProvider.changeDateFilter(" ");
                    dateProvider.setDateRange(selectedRange);
                  }
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
  Widget _totalBox(
      String label,
      double amount,
      Color color, {
        VoidCallback? onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        decoration: BoxDecoration(
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(12),
          color: color.withOpacity(0.08),
        ),
        child: Text(
          "$label :  ${TextFormat.formattedAmount(amount)}",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final billingProvider = Provider.of<BillingProvider>(context);
    final width = MediaQuery.of(context).size.width;

    return Focus(
      focusNode: _rootFocusNode,
      autofocus: true,

      /// 🔥 SINGLE KEYBOARD HANDLER
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        if (event.logicalKey == LogicalKeyboardKey.escape) {
         billingProvider.dropdownFocusNode.requestFocus();
          Navigator.pop(context);
          return KeyEventResult.handled;
        }
        /// 🔍 SEARCH MODE
        if (isSearchMode) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
              event.logicalKey == LogicalKeyboardKey.enter) {
            if (billingProvider.allOrders.isNotEmpty) {
              setState(() {
                isSearchMode = false;
                selectedRowIndex = 0;
              });
            }
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        }

        /// 📋 TABLE MODE
        if (!isSearchMode) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            if (selectedRowIndex <
                billingProvider.allOrders.length - 1) {
              setState(() => selectedRowIndex++);
              _scrollToSelectedRow();
              return KeyEventResult.handled;// 👈 scroll
            }

          }

          if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            if (selectedRowIndex > 0) {
              setState(() => selectedRowIndex--);
              _scrollToSelectedRow();
              return KeyEventResult.handled;
            }

          }

          if (event.logicalKey == LogicalKeyboardKey.enter) {
            final data =
            billingProvider.allOrders[selectedRowIndex];
            BillPdf().printCustomBill(context, data: data);
            return KeyEventResult.handled;
          }

          if (event.logicalKey == LogicalKeyboardKey.escape) {
            setState(() => isSearchMode = true);
            _customerFocusNode.requestFocus();
            billingProvider.dropdownFocusNode.requestFocus();
            return KeyEventResult.handled;
          }
        }

        return KeyEventResult.ignored;
      },

      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: IconButton(onPressed: (){
            Navigator.pop(context);
            billingProvider.dropdownFocusNode.requestFocus();

          }, icon:Icon(Icons.arrow_back)),
          title: const Text("Search Bill Details",style: TextStyle(color: AppColors.black,fontWeight: FontWeight.bold,fontSize: 24),),
        ),

        body: Column(
          children: [
            const SizedBox(height: 10),

            /// 🔎 FILTER + SEARCH
            Wrap(
              spacing: 16,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                /// RADIO FILTERS
                _radio("Last 30 Days"),
                _radio("Last 7 Days"),
                _radio("Today"),


                /// CUSTOM DATE
                Container(
                  width: 210,
                  height: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      /// TEXT
                      Expanded(
                        child: Text(
                          billingProvider.stDate.isEmpty
                              ? "Select Date"
                              : "${billingProvider.stDate} - ${billingProvider.enDate}",
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      /// CALENDAR ICON CLICK
                      InkWell(
                        onTap: () => showDatePickerDialog(context),
                        child: const Icon(
                          Icons.calendar_today,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),

                /// SEARCH FIELDS
                _searchField(
                  "Customer Name",
                  billingProvider.searchName,
                  focusNode: _customerFocusNode,
                  onChanged: (v) =>
                      billingProvider.setSearchQuery(name: v),
                ),
                _searchField(
                  "Invoice No",
                  billingProvider.bill,
                  onChanged: (v) =>
                      billingProvider.setSearchQuery(bill: v),
                ),
                _searchField(
                  "Amount",
                  billingProvider.searchAmount,
                  onChanged: (v) =>
                      billingProvider.setSearchQuery(total: v),
                ),
                _searchField(
                  "Product",
                  billingProvider.searchProd,
                  onChanged: (v) =>
                      billingProvider.setSearchQuery(product: v),
                ),
              ],
            ),

            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _totalBox(
                  'Total Bill',
                  billingProvider.allOrders.length.toDouble(),
                  Colors.deepOrange,
                  onTap: () {
                    // billingProvider.debugAllOrders; // CASH
                    billingProvider.allPaymentTotal; // CASH
                    setState(() {
                      selectedRowIndex = 0;
                      isSearchMode = false;
                    });
                  },
                ),
                20.width,
                _totalBox(
                  'Total',
                  billingProvider.allPaymentTotal,
                  Colors.deepPurpleAccent,
                  onTap: () {
                   // billingProvider.debugAllOrders; // CASH
                    billingProvider.allPaymentTotal; // CASH
                    setState(() {
                      selectedRowIndex = 0;
                      isSearchMode = false;
                    });
                  },
                ),
                const SizedBox(width: 12),
                _totalBox(
                  'Cash',
                  billingProvider.cashTotal,
                  Colors.green,
                  onTap: () {
                    billingProvider.filterByPaymentMethodId(2); // CASH
                    setState(() {
                      selectedRowIndex = 0;
                      isSearchMode = false;
                    });
                  },
                ),
                const SizedBox(width: 12),
                _totalBox(
                  'UPI',
                  billingProvider.upiTotal,
                  Colors.blue,
                  onTap: () {
                    billingProvider.filterByPaymentMethodId(1); // UPI
                    setState(() {
                      selectedRowIndex = 0;
                      isSearchMode = false;
                    });
                  },
                ),
                const SizedBox(width: 12),
                _totalBox(
                  'Credit',
                  billingProvider.creditTotal,
                  Colors.red,
                  onTap: () {
                    billingProvider.filterByPaymentMethodId(3); // CREDIT
                    setState(() {
                      selectedRowIndex = 0;
                      isSearchMode = false;
                    });
                  },
                ),
                const SizedBox(width: 12),
                _totalBox(
                  'Credit Card',
                  billingProvider.creditCardTotal,
                  Colors.pink,
                  onTap: () {
                    billingProvider.filterByPaymentMethodId(4); // CARD
                    setState(() {
                      selectedRowIndex = 0;
                      isSearchMode = false;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            // SizedBox(
            //   height: 260,
            //   width: 520,
            //   child: BarChart(
            //     BarChartData(
            //       maxY: 35,
            //       gridData: FlGridData(show: false),
            //       borderData: FlBorderData(show: true),
            //
            //       /// tooltip (number box)
            //       barTouchData: BarTouchData(
            //         enabled: true,
            //         touchTooltipData: BarTouchTooltipData(
            //         //  tooltipBgColor: Colors.black87,
            //           getTooltipItem: (group, groupIndex, rod, rodIndex) {
            //             return BarTooltipItem(
            //               rod.toY.toString(),
            //               const TextStyle(
            //                 color: Colors.white,
            //                 fontWeight: FontWeight.bold,
            //                 fontSize: 14,
            //               ),
            //             );
            //           },
            //         ),
            //       ),
            //
            //       titlesData: FlTitlesData(
            //
            //         /// remove left numbers
            //         leftTitles: AxisTitles(
            //           sideTitles: SideTitles(showTitles: false),
            //         ),
            //
            //         /// remove right numbers
            //         rightTitles: AxisTitles(
            //           sideTitles: SideTitles(showTitles: false),
            //         ),
            //
            //         /// remove top numbers
            //         topTitles: AxisTitles(
            //           sideTitles: SideTitles(showTitles: false),
            //         ),
            //
            //         /// bottom labels
            //         bottomTitles: AxisTitles(
            //           sideTitles: SideTitles(
            //             showTitles: true,
            //             getTitlesWidget: (value, meta) {
            //
            //               switch (value.toInt()) {
            //
            //                 case 0:
            //                   return const Text("Placed");
            //
            //                 case 1:
            //                   return const Text("Processing");
            //
            //                 case 2:
            //                   return const Text("Packed");
            //
            //                 case 3:
            //                   return const Text("Assigned");
            //
            //                 case 4:
            //                   return const Text("Completed");
            //
            //                 case 5:
            //                   return const Text("Cancelled");
            //
            //               }
            //
            //               return const Text("");
            //             },
            //           ),
            //         ),
            //       ),
            //
            //       barGroups: [
            //         _bar(0, billingProvider.orderPlaced, Colors.blue),
            //         _bar(1, billingProvider.processing, Colors.orange),
            //         _bar(2, billingProvider.packed, Colors.purple),
            //         _bar(3, billingProvider.deliveryPersonAssigned, Colors.teal),
            //         _bar(4, billingProvider.completed, Colors.green),
            //         _bar(5, billingProvider.cancelled, Colors.red),
            //       ],
            //     ),
            //
            //     /// animation
            //     swapAnimationDuration: const Duration(milliseconds: 800),
            //     swapAnimationCurve: Curves.easeInOut,
            //   ),
            // ),
            const SizedBox(height: 30),
            /// 📋 TABLE
            Expanded(
              child:billingProvider.isLoading
              // 🔄 LOADING STATE
                  ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.lightGreen,
                ),
              )

              // ❌ EMPTY STATE
                  :billingProvider.allOrders.isEmpty
              // 🔄 LOADING STATE
                  ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.lightGreen,
                ),
              ): billingProvider.allOrders.isEmpty
                  ?const Center(
                child: Text(
                  "Not Found",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              )
                  : Expanded(
                child: billingProvider.isLoading
                    ? const Center(
                  child: CircularProgressIndicator(color: Colors.lightGreen),
                )
                    : billingProvider.searchAllOrders.isEmpty
                    ? const Center(
                  child: Text(
                    "Not Found",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                )
                    : Column(
                  children: [
                    /// ✅ FIXED HEADER (NOT SCROLLING)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: width),
                        child: Container(
                          color: Colors.grey.shade200,
                          child: DataTable(
                            headingRowHeight: 45,
                            dataRowHeight: 0, // 🔥 hide row height
                            showCheckboxColumn: false,
                            columns: const [
                              DataColumn(label: Text("Date")),
                              DataColumn(label: Text("Invoice No")),
                              DataColumn(label: Text("Name")),
                              DataColumn(label: Text("Amount")),
                              DataColumn(label: Text("Action")),
                            ],
                            rows: const [], // 🔥 no rows only header
                          ),
                        ),
                      ),
                    ),

                    /// ✅ BODY SCROLL ONLY
                    Expanded(
                      child: Scrollbar(
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          controller: _tableScrollController,
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minWidth: width),
                              child: DataTable(
                                headingRowHeight: 0, // 🔥 hide heading row
                                showCheckboxColumn: false,
                                columns: const [
                                  DataColumn(label: Text("")),
                                  DataColumn(label: Text("")),
                                  DataColumn(label: Text("")),
                                  DataColumn(label: Text("")),
                                  DataColumn(label: Text("")),
                                ],
                                rows: billingProvider.searchAllOrders
                                    .reversed
                                    .toList()
                                    .asMap()
                                    .entries
                                    .map((e) {
                                  final index = e.key;
                                  final data = e.value;

                                  return DataRow(
                                    selected:
                                    !isSearchMode && selectedRowIndex == index,
                                    onSelectChanged: (_) {
                                      setState(() {
                                        isSearchMode = false;
                                        selectedRowIndex = index;
                                      });

                                      // 🔥 your dialog code
                                    },
                                    cells: [
                                      DataCell(
                                        Text(
                                          billingProvider.formatDateTime(
                                            data.createdTs.toString(),
                                          ),
                                        ),
                                      ),
                                      DataCell(Text(data.invoiceNo.toString())),
                                      DataCell(
                                        Text(
                                          (data.name == null ||
                                              data.name
                                                  .toString()
                                                  .trim()
                                                  .isEmpty ||
                                              data.name == "0")
                                              ? "Cash Customer"
                                              : data.name!,
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          TextFormat.formattedAmount(
                                            double.parse(data.oTotal.toString()),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Row(
                                          children: [
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppColors.primary,
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(15),
                                                ),
                                              ),
                                              onPressed: () {
                                                BillPdf().printCustomBill(
                                                  context,
                                                  data: data,
                                                );
                                              },
                                              child: const Text(
                                                "Print",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 20),
                                            if (localData.cancelCode == 1)
                                              ElevatedButton(
                                                onPressed: () {
                                                  context.read<BillingProvider>().cancelOrder(
                                                    data.invoiceNo.toString(),
                                                    context,
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                                ),
                                                child: const MyText(
                                                  text: "Cancel Bill",
                                                  color: Colors.white,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )

          ],
        ),
      ),
    );
  }

  /// 🔘 RADIO WIDGET
  Widget _radio(String label) {
    final provider =
    Provider.of<BillingProvider>(context, listen: false);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String>(
          value: label,
          groupValue: provider.selectedDate,
          onChanged: (v) {
            provider.changeDateFilter(v!);
            provider.applyQuickDateFilter(v);

    }

        ),
        Text(label),
      ],
    );
  }

  Widget _searchField(
      String label,
      TextEditingController controller, {
        FocusNode? focusNode,
        required Function(String) onChanged,
      }) {
    return MySmallTextField(
      width: 180,
      height: 40,
      labelText: label,
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,

      /// 🔥 IMPORTANT — search mode enable
      onTap: () {
        setState(() => isSearchMode = true);
      },

      onChanged: (value) {
        onChanged(value);
      },

      suffixIcon: controller.text.isEmpty
          ? null
          : IconButton(
        icon: const Icon(Icons.clear, size: 16),
        onPressed: () {
          controller.clear();
          onChanged("");
        },
      ),
    );
  }


  BarChartGroupData _bar(int x, int y, Color color) {
    return BarChartGroupData(
      x: x,
      showingTooltipIndicators: [0],
      barRods: [
        BarChartRodData(
          toY: y.toDouble(),
          width: 20,
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
      ],
    );
  }

}


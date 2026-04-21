import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fullcomm_crm/common/constant/key_constant.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/services/api_services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../common/constant/api.dart';
import '../../common/constant/colors_constant.dart';
import '../../common/utilities/utils.dart';
import '../../components/Customtext.dart';
import '../../components/custom_loading_button.dart';
import '../../components/custom_search_textfield.dart';
import '../../components/date_filter_bar.dart';
import '../../controller/controller.dart';
import '../../controller/image_controller.dart';
import '../../controller/product_controller.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui;
import '../../controller/reminder_controller.dart';
import '../../controller/settings_controller.dart';
import '../../models/billing_models/billing_product.dart';
import '../../view_models/billing_provider.dart';
class QuotationHistory extends StatefulWidget {
  const QuotationHistory({super.key, });

  @override
  State<QuotationHistory> createState() => _QuotationHistoryState();
}

class _QuotationHistoryState extends State<QuotationHistory> {
  var sizeInKB=0.0.obs;
  List<double> colWidths = [
    60,//s no
    200,//Action
    150,//q no
    150,//cus
    150,//com
    130,//com no
    140,//prd
    110,//ite
    110,//amt
    130,//date
    120,//vali
    150,//quo
    140,//stat
  ];
  final ScrollController _controller = ScrollController();
  final ScrollController _horizontalController = ScrollController();
  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    Future.delayed(Duration.zero,(){
      productCtr.filterAndSortQuotations(
        searchText: controllers.searchText.value.toLowerCase(),
        sortField: controllers.sortFieldCallActivity.value,
        sortOrder: controllers.sortOrderCallActivity.value,
        selectedMonth: productCtr.selectedCallMonth.value,
        selectedRange: productCtr.selectedCallRange.value,
        selectedDateFilter: productCtr.selectedCallSortBy.value,
      );
    });
  }
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
                // colWidths[index] += details.delta.dx;
                // if (colWidths[index] < 60) colWidths[index] = 60;
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
  bool dateCheck() {
    return controllers.stDate.value !=
        "${DateTime.now().day.toString().padLeft(2, "0")}"
            "-${DateTime.now().month.toString().padLeft(2, "0")}"
            "-${DateTime.now().year.toString()}";
  }
  late FocusNode _focusNode;
  List<String> statusList = ["Confirm Order", "Upload PO", "Quotation Draft"];
  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    _horizontalController.dispose();
    super.dispose();
  }
  // KEYBOARD SCROLL LOGIC
  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      const double horizontalScrollAmount = 60.0;
      const double verticalScrollAmount = 50.0; // Adjust for row height

      // --- HORIZONTAL SCROLLING ---
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _horizontalController.animateTo(
          (_horizontalController.offset + horizontalScrollAmount).clamp(0.0, _horizontalController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 100),
          curve: Curves.linear,
        );
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _horizontalController.animateTo(
          (_horizontalController.offset - horizontalScrollAmount).clamp(0.0, _horizontalController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 100),
          curve: Curves.linear,
        );
      }

      // --- VERTICAL SCROLLING (Add this part) ---
      else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _controller.animateTo(
          (_controller.offset + verticalScrollAmount).clamp(0.0, _controller.position.maxScrollExtent),
          duration: const Duration(milliseconds: 100),
          curve: Curves.linear,
        );
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _controller.animateTo(
          (_controller.offset - verticalScrollAmount).clamp(0.0, _controller.position.maxScrollExtent),
          duration: const Duration(milliseconds: 100),
          curve: Curves.linear,
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    // Column widths mapped for the Table widget
    final Map<int, TableColumnWidth> tableWidthMap = {
      for (int i = 0; i < colWidths.length; i++) i: FixedColumnWidth(colWidths[i])
    };

    double totalTableWidth = colWidths.reduce((a, b) => a + b);
    return Consumer<BillingProvider>(
        builder: (context, billingProvider,_) {
          return SelectionArea(
            child: Scaffold(
              body: Obx(() =>
                  Container(
                    width: controllers.isLeftOpen.value
                        ? MediaQuery
                        .of(context)
                        .size
                        .width - 150
                        : MediaQuery
                        .of(context)
                        .size
                        .width - 60,
                    height: MediaQuery
                        .of(context)
                        .size
                        .height,
                    padding: const EdgeInsets.fromLTRB(16, 5, 16, 16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomText(
                                  text: "Quotation Details",
                                  colors: colorsConst.textColor,
                                  size: 20,
                                  isBold: true,
                                  isCopy: true,
                                ),
                                10.height,
                                CustomText(
                                  text: "View all quotation details",
                                  colors: colorsConst.textColor,
                                  size: 14,
                                  isCopy: true,
                                ),
                              ],
                            ),
                            CustomLoadingButton(
                              callback: () {
                                controllers.changeTab(1);
                              },
                              isLoading: false,
                              height: 35,
                              backgroundColor: colorsConst.primary,
                              radius: 2,
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.15,
                              isImage: false,
                              text: "Create Quotation",
                              textColor: Colors.white,
                            ),
                          ],
                        ),
                        10.height,
                        Divider(
                          thickness: 1.5,
                          color: colorsConst.secondary,
                        ),
                        10.height,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomSearchTextField(
                              controller: controllers.search,
                              hintText: "Search Customer Name / Number / Total Amount",
                              onChanged: (value) {
                                controllers.searchText.value =
                                    value.toString().trim();
                                setState(() {
                                  final suggestions = productCtr.quotationsList2
                                      .where(
                                          (user) {
                                        final customerName = user.name
                                            .toString().toLowerCase();
                                        final customerNo = user.number
                                            .toString().toLowerCase();
                                        final bankName = user.totalAmt
                                            .toString().toLowerCase();
                                        final input = value
                                            .toString()
                                            .toLowerCase()
                                            .trim();
                                        return customerName.contains(input) ||
                                            customerNo.contains(input) ||
                                            bankName.contains(input);
                                      }).toList();
                                  productCtr.quotationsList.value = suggestions;
                                });
                              },
                            ),
                            DateFilterBar(
                              selectedSortBy: productCtr.selectedCallSortBy,
                              selectedRange: productCtr.selectedCallRange,
                              selectedMonth: productCtr.selectedCallMonth,
                              focusNode: _focusNode,
                              onDaysSelected: () {
                                productCtr.filterAndSortQuotations(
                                  searchText: controllers.searchText.value
                                      .toLowerCase(),
                                  sortField: controllers.sortFieldCallActivity
                                      .value,
                                  sortOrder: controllers.sortOrderCallActivity
                                      .value,
                                  selectedMonth: productCtr.selectedCallMonth
                                      .value,
                                  selectedRange: productCtr.selectedCallRange
                                      .value,
                                  selectedDateFilter: productCtr
                                      .selectedCallSortBy.value,
                                );
                              },
                              onSelectMonth: () {
                                remController.selectMonth(
                                  context,
                                  productCtr.selectedCallSortBy,
                                  productCtr.selectedCallMonth,
                                      () {
                                    productCtr.filterAndSortQuotations(
                                      searchText: controllers.searchText.value
                                          .toLowerCase(),
                                      sortField: controllers
                                          .sortFieldCallActivity.value,
                                      sortOrder: controllers
                                          .sortOrderCallActivity.value,
                                      selectedMonth: productCtr
                                          .selectedCallMonth.value,
                                      selectedRange: productCtr
                                          .selectedCallRange.value,
                                      selectedDateFilter: productCtr
                                          .selectedCallSortBy.value,
                                    );
                                  },
                                );
                              },
                              onSelectDateRange: (ctx) {
                                remController.showDatePickerDialog(
                                    ctx, (pickedRange) {
                                  productCtr.selectedCallRange.value =
                                      pickedRange;
                                  productCtr.filterAndSortQuotations(
                                    searchText: controllers.searchText.value
                                        .toLowerCase(),
                                    sortField: controllers.sortFieldCallActivity
                                        .value,
                                    sortOrder: controllers.sortOrderCallActivity
                                        .value,
                                    selectedMonth: productCtr.selectedCallMonth
                                        .value,
                                    selectedRange: productCtr.selectedCallRange
                                        .value,
                                    selectedDateFilter: productCtr
                                        .selectedCallSortBy.value,
                                  );
                                });
                              },
                            )
                          ],
                        ),
                        15.height,
                        Expanded(
                          child: KeyboardListener(
                            focusNode: _focusNode,
                            onKeyEvent: _handleKeyEvent,
                            child: Scrollbar(
                              controller: _horizontalController,
                              thumbVisibility: true,
                              child: SingleChildScrollView(
                                controller: _horizontalController,
                                scrollDirection: Axis.horizontal,
                                child: SizedBox(
                                  width: totalTableWidth,
                                  child: Column(
                                    children: [
                                      // HEADER
                                      Table(
                                        columnWidths: tableWidthMap,
                                        border: TableBorder(
                                          horizontalInside: BorderSide(
                                              width: 0.5,
                                              color: Colors.grey.shade400),
                                          verticalInside: BorderSide(width: 0.5,
                                              color: Colors.grey.shade400),
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
                                                headerCell(2, CustomText(
                                                  textAlign: TextAlign.left,
                                                  text: "S.No",
                                                  size: 15,
                                                  isBold: true,
                                                  isCopy: true,
                                                  colors: Colors.white,
                                                ),),
                                                headerCell(2, CustomText(
                                                  textAlign: TextAlign.left,
                                                  text: "Action",
                                                  size: 15,
                                                  isBold: true,
                                                  isCopy: true,
                                                  colors: Colors.white,
                                                ),),
                                                headerCell(2, Row(
                                                  children: [
                                                    CustomText(
                                                      textAlign: TextAlign.left,
                                                      text: "Quotation No",
                                                      size: 15,
                                                      isBold: true,
                                                      isCopy: true,
                                                      colors: Colors.white,
                                                    ),
                                                    3.width,
                                                    GestureDetector(
                                                      onTap: () {
                                                        if (controllers
                                                            .sortFieldCallActivity
                                                            .value == 'qno' &&
                                                            controllers
                                                                .sortOrderCallActivity
                                                                .value ==
                                                                'asc') {
                                                          controllers
                                                              .sortOrderCallActivity
                                                              .value = 'desc';
                                                        } else {
                                                          controllers
                                                              .sortOrderCallActivity
                                                              .value = 'asc';
                                                        }
                                                        controllers
                                                            .sortFieldCallActivity
                                                            .value = 'qno';
                                                        productCtr
                                                            .filterAndSortQuotations(
                                                          searchText: controllers
                                                              .searchText.value
                                                              .toLowerCase(),
                                                          sortField: controllers
                                                              .sortFieldCallActivity
                                                              .value,
                                                          sortOrder: controllers
                                                              .sortOrderCallActivity
                                                              .value,
                                                          selectedMonth: productCtr
                                                              .selectedCallMonth
                                                              .value,
                                                          selectedRange: productCtr
                                                              .selectedCallRange
                                                              .value,
                                                          selectedDateFilter: productCtr
                                                              .selectedCallSortBy
                                                              .value,
                                                        );
                                                      },
                                                      child: Obx(() =>
                                                          Image.asset(
                                                            controllers
                                                                .sortFieldCallActivity
                                                                .value.isEmpty
                                                                ? "assets/images/arrow.png"
                                                                : controllers
                                                                .sortOrderCallActivity
                                                                .value == 'asc'
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
                                                    CustomText( //2
                                                      textAlign: TextAlign.left,
                                                      text: "Customer",
                                                      size: 15,
                                                      isBold: true,
                                                      isCopy: true,
                                                      colors: Colors.white,
                                                    ),
                                                    3.width,
                                                    GestureDetector(
                                                      onTap: () {
                                                        if (controllers
                                                            .sortFieldCallActivity
                                                            .value == 'name' &&
                                                            controllers
                                                                .sortOrderCallActivity
                                                                .value ==
                                                                'asc') {
                                                          controllers
                                                              .sortOrderCallActivity
                                                              .value = 'desc';
                                                        } else {
                                                          controllers
                                                              .sortOrderCallActivity
                                                              .value = 'asc';
                                                        }
                                                        controllers
                                                            .sortFieldCallActivity
                                                            .value = 'name';
                                                        productCtr
                                                            .filterAndSortQuotations(
                                                          searchText: controllers
                                                              .searchText.value
                                                              .toLowerCase(),
                                                          sortField: controllers
                                                              .sortFieldCallActivity
                                                              .value,
                                                          sortOrder: controllers
                                                              .sortOrderCallActivity
                                                              .value,
                                                          selectedMonth: productCtr
                                                              .selectedCallMonth
                                                              .value,
                                                          selectedRange: productCtr
                                                              .selectedCallRange
                                                              .value,
                                                          selectedDateFilter: productCtr
                                                              .selectedCallSortBy
                                                              .value,
                                                        );
                                                      },
                                                      child: Obx(() =>
                                                          Image.asset(
                                                            controllers
                                                                .sortFieldCallActivity
                                                                .value.isEmpty
                                                                ? "assets/images/arrow.png"
                                                                : controllers
                                                                .sortOrderCallActivity
                                                                .value == 'asc'
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
                                                    CustomText( //2
                                                      textAlign: TextAlign.left,
                                                      text: "Company",
                                                      size: 15,
                                                      isBold: true,
                                                      isCopy: true,
                                                      colors: Colors.white,
                                                    ),
                                                    3.width,
                                                    GestureDetector(
                                                      onTap: () {
                                                        if (controllers
                                                            .sortFieldCallActivity
                                                            .value ==
                                                            'company' &&
                                                            controllers
                                                                .sortOrderCallActivity
                                                                .value ==
                                                                'asc') {
                                                          controllers
                                                              .sortOrderCallActivity
                                                              .value = 'desc';
                                                        } else {
                                                          controllers
                                                              .sortOrderCallActivity
                                                              .value = 'asc';
                                                        }
                                                        controllers
                                                            .sortFieldCallActivity
                                                            .value = 'company';
                                                        productCtr
                                                            .filterAndSortQuotations(
                                                          searchText: controllers
                                                              .searchText.value
                                                              .toLowerCase(),
                                                          sortField: controllers
                                                              .sortFieldCallActivity
                                                              .value,
                                                          sortOrder: controllers
                                                              .sortOrderCallActivity
                                                              .value,
                                                          selectedMonth: productCtr
                                                              .selectedCallMonth
                                                              .value,
                                                          selectedRange: productCtr
                                                              .selectedCallRange
                                                              .value,
                                                          selectedDateFilter: productCtr
                                                              .selectedCallSortBy
                                                              .value,
                                                        );
                                                      },
                                                      child: Obx(() =>
                                                          Image.asset(
                                                            controllers
                                                                .sortFieldCallActivity
                                                                .value.isEmpty
                                                                ? "assets/images/arrow.png"
                                                                : controllers
                                                                .sortOrderCallActivity
                                                                .value == 'asc'
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
                                                      textAlign: TextAlign.left,
                                                      text: "Phone No",
                                                      size: 15,
                                                      isBold: true,
                                                      isCopy: true,
                                                      colors: Colors.white,
                                                    ),
                                                    3.width,
                                                    GestureDetector(
                                                      onTap: () {
                                                        if (controllers
                                                            .sortFieldCallActivity
                                                            .value ==
                                                            'number' &&
                                                            controllers
                                                                .sortOrderCallActivity
                                                                .value ==
                                                                'asc') {
                                                          controllers
                                                              .sortOrderCallActivity
                                                              .value = 'desc';
                                                        } else {
                                                          controllers
                                                              .sortOrderCallActivity
                                                              .value = 'asc';
                                                        }
                                                        controllers
                                                            .sortFieldCallActivity
                                                            .value = 'number';
                                                        productCtr
                                                            .filterAndSortQuotations(
                                                          searchText: controllers
                                                              .searchText.value
                                                              .toLowerCase(),
                                                          sortField: controllers
                                                              .sortFieldCallActivity
                                                              .value,
                                                          sortOrder: controllers
                                                              .sortOrderCallActivity
                                                              .value,
                                                          selectedMonth: productCtr
                                                              .selectedCallMonth
                                                              .value,
                                                          selectedRange: productCtr
                                                              .selectedCallRange
                                                              .value,
                                                          selectedDateFilter: productCtr
                                                              .selectedCallSortBy
                                                              .value,
                                                        );
                                                      },
                                                      child: Obx(() =>
                                                          Image.asset(
                                                            controllers
                                                                .sortFieldCallActivity
                                                                .value.isEmpty
                                                                ? "assets/images/arrow.png"
                                                                : controllers
                                                                .sortOrderCallActivity
                                                                .value == 'asc'
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
                                                      textAlign: TextAlign.left,
                                                      text: "Tot Products",
                                                      size: 15,
                                                      isBold: true,
                                                      isCopy: true,
                                                      colors: Colors.white,
                                                    ),
                                                    3.width,
                                                    GestureDetector(
                                                      onTap: () {
                                                        if (controllers
                                                            .sortFieldCallActivity
                                                            .value ==
                                                            'products' &&
                                                            controllers
                                                                .sortOrderCallActivity
                                                                .value ==
                                                                'asc') {
                                                          controllers
                                                              .sortOrderCallActivity
                                                              .value = 'desc';
                                                        } else {
                                                          controllers
                                                              .sortOrderCallActivity
                                                              .value = 'asc';
                                                        }
                                                        controllers
                                                            .sortFieldCallActivity
                                                            .value = 'products';
                                                        productCtr
                                                            .filterAndSortQuotations(
                                                          searchText: controllers
                                                              .searchText.value
                                                              .toLowerCase(),
                                                          sortField: controllers
                                                              .sortFieldCallActivity
                                                              .value,
                                                          sortOrder: controllers
                                                              .sortOrderCallActivity
                                                              .value,
                                                          selectedMonth: productCtr
                                                              .selectedCallMonth
                                                              .value,
                                                          selectedRange: productCtr
                                                              .selectedCallRange
                                                              .value,
                                                          selectedDateFilter: productCtr
                                                              .selectedCallSortBy
                                                              .value,
                                                        );
                                                      },
                                                      child: Obx(() =>
                                                          Image.asset(
                                                            controllers
                                                                .sortFieldCallActivity
                                                                .value.isEmpty
                                                                ? "assets/images/arrow.png"
                                                                : controllers
                                                                .sortOrderCallActivity
                                                                .value == 'asc'
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
                                                      textAlign: TextAlign.left,
                                                      text: "Tot Item",
                                                      size: 15,
                                                      isBold: true,
                                                      isCopy: true,
                                                      colors: Colors.white,
                                                    ),
                                                    3.width,
                                                    GestureDetector(
                                                      onTap: () {
                                                        if (controllers
                                                            .sortFieldCallActivity
                                                            .value == 'item' &&
                                                            controllers
                                                                .sortOrderCallActivity
                                                                .value ==
                                                                'asc') {
                                                          controllers
                                                              .sortOrderCallActivity
                                                              .value = 'desc';
                                                        } else {
                                                          controllers
                                                              .sortOrderCallActivity
                                                              .value = 'asc';
                                                        }
                                                        controllers
                                                            .sortFieldCallActivity
                                                            .value = 'item';
                                                        productCtr
                                                            .filterAndSortQuotations(
                                                          searchText: controllers
                                                              .searchText.value
                                                              .toLowerCase(),
                                                          sortField: controllers
                                                              .sortFieldCallActivity
                                                              .value,
                                                          sortOrder: controllers
                                                              .sortOrderCallActivity
                                                              .value,
                                                          selectedMonth: productCtr
                                                              .selectedCallMonth
                                                              .value,
                                                          selectedRange: productCtr
                                                              .selectedCallRange
                                                              .value,
                                                          selectedDateFilter: productCtr
                                                              .selectedCallSortBy
                                                              .value,
                                                        );
                                                      },
                                                      child: Obx(() =>
                                                          Image.asset(
                                                            controllers
                                                                .sortFieldCallActivity
                                                                .value.isEmpty
                                                                ? "assets/images/arrow.png"
                                                                : controllers
                                                                .sortOrderCallActivity
                                                                .value == 'asc'
                                                                ? "assets/images/arrow_up.png"
                                                                : "assets/images/arrow_down.png",
                                                            width: 15,
                                                            height: 15,
                                                          ),
                                                      ),
                                                    ),
                                                  ],
                                                ),),
                                                headerCell(5, Row(
                                                  children: [
                                                    CustomText(
                                                      textAlign: TextAlign.left,
                                                      text: "Tot Amt",
                                                      size: 15,
                                                      isBold: true,
                                                      isCopy: true,
                                                      colors: Colors.white,
                                                    ),
                                                    3.width,
                                                    GestureDetector(
                                                      onTap: () {
                                                        if (controllers
                                                            .sortFieldCallActivity
                                                            .value == 'amt' &&
                                                            controllers
                                                                .sortOrderCallActivity
                                                                .value ==
                                                                'asc') {
                                                          controllers
                                                              .sortOrderCallActivity
                                                              .value = 'desc';
                                                        } else {
                                                          controllers
                                                              .sortOrderCallActivity
                                                              .value = 'asc';
                                                        }
                                                        controllers
                                                            .sortFieldCallActivity
                                                            .value = 'amt';
                                                        productCtr
                                                            .filterAndSortQuotations(
                                                          searchText: controllers
                                                              .searchText.value
                                                              .toLowerCase(),
                                                          sortField: controllers
                                                              .sortFieldCallActivity
                                                              .value,
                                                          sortOrder: controllers
                                                              .sortOrderCallActivity
                                                              .value,
                                                          selectedMonth: productCtr
                                                              .selectedCallMonth
                                                              .value,
                                                          selectedRange: productCtr
                                                              .selectedCallRange
                                                              .value,
                                                          selectedDateFilter: productCtr
                                                              .selectedCallSortBy
                                                              .value,
                                                        );
                                                      },
                                                      child: Obx(() =>
                                                          Image.asset(
                                                            controllers
                                                                .sortFieldCallActivity
                                                                .value.isEmpty
                                                                ? "assets/images/arrow.png"
                                                                : controllers
                                                                .sortOrderCallActivity
                                                                .value == 'asc'
                                                                ? "assets/images/arrow_up.png"
                                                                : "assets/images/arrow_down.png",
                                                            width: 15,
                                                            height: 15,
                                                          ),
                                                      ),
                                                    ),
                                                  ],
                                                ),),
                                                headerCell(6, Row(
                                                  children: [
                                                    CustomText( //4
                                                      textAlign: TextAlign.left,
                                                      text: "Sent Date",
                                                      size: 15,
                                                      isBold: true,
                                                      isCopy: true,
                                                      colors: Colors.white,
                                                    ),
                                                    3.width,
                                                    GestureDetector(
                                                      onTap: () {
                                                        if (controllers
                                                            .sortFieldCallActivity
                                                            .value == 'date' &&
                                                            controllers
                                                                .sortOrderCallActivity
                                                                .value ==
                                                                'asc') {
                                                          controllers
                                                              .sortOrderCallActivity
                                                              .value = 'desc';
                                                        } else {
                                                          controllers
                                                              .sortOrderCallActivity
                                                              .value = 'asc';
                                                        }
                                                        controllers
                                                            .sortFieldCallActivity
                                                            .value = 'date';
                                                        productCtr
                                                            .filterAndSortQuotations(
                                                          searchText: controllers
                                                              .searchText.value
                                                              .toLowerCase(),
                                                          sortField: controllers
                                                              .sortFieldCallActivity
                                                              .value,
                                                          sortOrder: controllers
                                                              .sortOrderCallActivity
                                                              .value,
                                                          selectedMonth: productCtr
                                                              .selectedCallMonth
                                                              .value,
                                                          selectedRange: productCtr
                                                              .selectedCallRange
                                                              .value,
                                                          selectedDateFilter: productCtr
                                                              .selectedCallSortBy
                                                              .value,
                                                        );
                                                      },
                                                      child: Obx(() =>
                                                          Image.asset(
                                                            controllers
                                                                .sortFieldCallActivity
                                                                .value.isEmpty
                                                                ? "assets/images/arrow.png"
                                                                : controllers
                                                                .sortOrderCallActivity
                                                                .value == 'asc'
                                                                ? "assets/images/arrow_up.png"
                                                                : "assets/images/arrow_down.png",
                                                            width: 15,
                                                            height: 15,
                                                          ),
                                                      ),
                                                    ),
                                                  ],
                                                ),),
                                                headerCell(6, Row(
                                                  children: [
                                                    CustomText( //4
                                                      textAlign: TextAlign.left,
                                                      text: "Validity",
                                                      size: 15,
                                                      isBold: true,
                                                      isCopy: true,
                                                      colors: Colors.white,
                                                    ),
                                                    3.width,
                                                    GestureDetector(
                                                      onTap: () {
                                                        if (controllers
                                                            .sortFieldCallActivity
                                                            .value ==
                                                            'validity' &&
                                                            controllers
                                                                .sortOrderCallActivity
                                                                .value ==
                                                                'asc') {
                                                          controllers
                                                              .sortOrderCallActivity
                                                              .value = 'desc';
                                                        } else {
                                                          controllers
                                                              .sortOrderCallActivity
                                                              .value = 'asc';
                                                        }
                                                        controllers
                                                            .sortFieldCallActivity
                                                            .value = 'validity';
                                                        productCtr
                                                            .filterAndSortQuotations(
                                                          searchText: controllers
                                                              .searchText.value
                                                              .toLowerCase(),
                                                          sortField: controllers
                                                              .sortFieldCallActivity
                                                              .value,
                                                          sortOrder: controllers
                                                              .sortOrderCallActivity
                                                              .value,
                                                          selectedMonth: productCtr
                                                              .selectedCallMonth
                                                              .value,
                                                          selectedRange: productCtr
                                                              .selectedCallRange
                                                              .value,
                                                          selectedDateFilter: productCtr
                                                              .selectedCallSortBy
                                                              .value,
                                                        );
                                                      },
                                                      child: Obx(() =>
                                                          Image.asset(
                                                            controllers
                                                                .sortFieldCallActivity
                                                                .value.isEmpty
                                                                ? "assets/images/arrow.png"
                                                                : controllers
                                                                .sortOrderCallActivity
                                                                .value == 'asc'
                                                                ? "assets/images/arrow_up.png"
                                                                : "assets/images/arrow_down.png",
                                                            width: 15,
                                                            height: 15,
                                                          ),
                                                      ),
                                                    ),
                                                  ],
                                                ),),
                                                headerCell(8, CustomText(
                                                  textAlign: TextAlign.left,
                                                  text: "Quotation",
                                                  size: 15,
                                                  isBold: true,
                                                  isCopy: true,
                                                  colors: Colors.white,
                                                ),),
                                                headerCell(7, Row(
                                                  children: [
                                                    CustomText( //4
                                                      textAlign: TextAlign.left,
                                                      text: "Status",
                                                      size: 15,
                                                      isBold: true,
                                                      isCopy: true,
                                                      colors: Colors.white,
                                                    ),
                                                    3.width,
                                                    GestureDetector(
                                                      onTap: () {
                                                        if (controllers
                                                            .sortFieldCallActivity
                                                            .value ==
                                                            'status' &&
                                                            controllers
                                                                .sortOrderCallActivity
                                                                .value ==
                                                                'asc') {
                                                          controllers
                                                              .sortOrderCallActivity
                                                              .value = 'desc';
                                                        } else {
                                                          controllers
                                                              .sortOrderCallActivity
                                                              .value = 'asc';
                                                        }
                                                        controllers
                                                            .sortFieldCallActivity
                                                            .value = 'status';
                                                        productCtr
                                                            .filterAndSortQuotations(
                                                          searchText: controllers
                                                              .searchText.value
                                                              .toLowerCase(),
                                                          sortField: controllers
                                                              .sortFieldCallActivity
                                                              .value,
                                                          sortOrder: controllers
                                                              .sortOrderCallActivity
                                                              .value,
                                                          selectedMonth: productCtr
                                                              .selectedCallMonth
                                                              .value,
                                                          selectedRange: productCtr
                                                              .selectedCallRange
                                                              .value,
                                                          selectedDateFilter: productCtr
                                                              .selectedCallSortBy
                                                              .value,
                                                        );
                                                      },
                                                      child: Obx(() =>
                                                          Image.asset(
                                                            controllers
                                                                .sortFieldCallActivity
                                                                .value.isEmpty
                                                                ? "assets/images/arrow.png"
                                                                : controllers
                                                                .sortOrderCallActivity
                                                                .value == 'asc'
                                                                ? "assets/images/arrow_up.png"
                                                                : "assets/images/arrow_down.png",
                                                            width: 15,
                                                            height: 15,
                                                          ),
                                                      ),
                                                    ),
                                                  ],
                                                ),),
                                                // headerCell(9, CustomText(
                                                //   textAlign: TextAlign.left,
                                                //   text: "Confirm Order",
                                                //   size: 15,
                                                //   isBold: true,
                                                //   isCopy: true,
                                                //   colors: Colors.white,
                                                // ),)
                                              ]),
                                        ],
                                      ),
                                      // BODY LIST
                                      Expanded(
                                        child: Obx(() {
                                          if (productCtr.quotationsList.isEmpty)
                                            return const Center(
                                                child: Text("No Data Found"));
                                          return ListView.builder(
                                            controller: _controller,
                                            itemCount: productCtr.quotationsList
                                                .length,
                                            itemBuilder: (context, index) {
                                              var data = productCtr
                                                  .quotationsList[index];
                                              return Table(
                                                columnWidths: tableWidthMap,
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
                                                          padding: const EdgeInsets
                                                              .all(10.0),
                                                          child: CustomText(
                                                            textAlign: TextAlign
                                                                .left,
                                                            text: "${index +
                                                                1}",
                                                            size: 14,
                                                            isCopy: true,
                                                            colors: colorsConst
                                                                .textColor,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets
                                                              .all(10.0),
                                                          child: Container(
                                                            height: 40,
                                                            padding: const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 10),
                                                            decoration: BoxDecoration(
                                                              color: Colors
                                                                  .white,
                                                              borderRadius: BorderRadius
                                                                  .circular(8),
                                                              border: Border
                                                                  .all(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade400,
                                                                  width: 1.2),
                                                            ),
                                                            child: DropdownButtonHideUnderline(
                                                              child: DropdownButton<
                                                                  String>(
                                                                value: data
                                                                    .dropValue,
                                                                hint: CustomText(
                                                                  text: "Select Status",
                                                                  isCopy: false,
                                                                  colors: Colors
                                                                      .grey,),
                                                                isExpanded: true,
                                                                icon: const Icon(
                                                                    Icons
                                                                        .keyboard_arrow_down),
                                                                items: statusList
                                                                    .map((
                                                                    status) {
                                                                  return DropdownMenuItem(
                                                                    value: status,
                                                                    child: CustomText(
                                                                        text: status,
                                                                        isCopy: false),
                                                                  );
                                                                }).toList(),
                                                                onChanged: (
                                                                    value) {
                                                                  setState(() {
                                                                    data
                                                                        .dropValue =
                                                                        value;
                                                                    if (data
                                                                        .status !=
                                                                        "Order Confirmed" &&
                                                                        data
                                                                            .dropValue ==
                                                                            "Confirm Order") {
                                                                      var idList=data.pId.split("||");
                                                                      var nameList=data.pName.split("||");
                                                                      var qtyList=data.qty.split("||");
                                                                      var priceList=data.price.split("||");
                                                                      var mrpList=data.mrp.split("||");
                                                                      for(var i=0;i<idList.length;i++){
                                                                        billingProvider.addBillingItem(
                                                                          BillingItem(
                                                                            id: idList[i],
                                                                            product: nameList[i],
                                                                            productTitle: nameList[i],
                                                                            variation: qtyList[i],
                                                                            variationUnit: "",
                                                                            quantity: qtyList[i],
                                                                            p_out_price: priceList[i],
                                                                            p_mrp:mrpList[i],
                                                                          ),
                                                                        );
                                                                      }
                                                                      ///
                                                                      // showDialog(
                                                                      //     context: context,
                                                                      //     barrierDismissible: false,
                                                                      //     builder: (context) {
                                                                      //       return AlertDialog(
                                                                      //         content: CustomText(
                                                                      //           text: "Are you sure confirm this order?",
                                                                      //           size: 16,
                                                                      //           isCopy: false,
                                                                      //           isBold: true,
                                                                      //           colors: colorsConst.textColor,
                                                                      //         ),
                                                                      //         actions: [
                                                                      //           Row(
                                                                      //             mainAxisAlignment: MainAxisAlignment.end,
                                                                      //             children: [
                                                                      //               Container(
                                                                      //                 decoration: BoxDecoration(
                                                                      //                     border: Border.all(color: colorsConst.primary),
                                                                      //                     color: Colors.white),
                                                                      //                 width: 80,
                                                                      //                 height: 25,
                                                                      //                 child: ElevatedButton(
                                                                      //                     style: ElevatedButton.styleFrom(
                                                                      //                       shape: const RoundedRectangleBorder(
                                                                      //                         borderRadius: BorderRadius.zero,
                                                                      //                       ),
                                                                      //                       backgroundColor: Colors.white,
                                                                      //                     ),
                                                                      //                     onPressed: () {
                                                                      //                       Navigator.pop(context);
                                                                      //                     },
                                                                      //                     child: CustomText(
                                                                      //                       text: "Cancel",
                                                                      //                       isCopy: false,
                                                                      //                       colors: colorsConst.primary,
                                                                      //                       size: 14,
                                                                      //                     )),
                                                                      //               ),
                                                                      //               10.width,
                                                                      //               CustomLoadingButton(
                                                                      //                 callback: (){
                                                                      //                   apiService.confirmOrderAPI(context,data.id.toString(),data.cusId.toString(),data.totalAmt.toString(),data.name.toString(),data.number.toString());
                                                                      //                 },
                                                                      //                 height: 35,
                                                                      //                 isLoading: true,
                                                                      //                 backgroundColor: colorsConst.primary,
                                                                      //                 radius: 2,
                                                                      //                 width: 80,
                                                                      //                 controller: controllers.productCtr,
                                                                      //                 isImage: false,
                                                                      //                 text: "Confirm",
                                                                      //                 textColor: Colors.white,
                                                                      //               ),
                                                                      //               5.width
                                                                      //             ],
                                                                      //           ),
                                                                      //         ],
                                                                      //       );
                                                                      //     });
                                                                    } else
                                                                    if (data
                                                                        .status ==
                                                                        "Order Confirmed" &&
                                                                        data
                                                                            .dropValue ==
                                                                            "Confirm Order") {
                                                                      utils
                                                                          .snackBar(
                                                                          context: context,
                                                                          msg: "Already order confirmed",
                                                                          color: Colors
                                                                              .red);
                                                                    } else
                                                                    if (data
                                                                        .status !=
                                                                        "PO Sent" &&
                                                                        data
                                                                            .dropValue ==
                                                                            "Upload PO") {
                                                                      controllers
                                                                          .emailToCtr
                                                                          .clear();
                                                                      controllers
                                                                          .emailSubjectCtr
                                                                          .text =
                                                                          DateFormat(
                                                                              'dd-MM-yyyy')
                                                                              .format(
                                                                              DateTime
                                                                                  .now());
                                                                      controllers
                                                                          .emailMessageCtr
                                                                          .clear();
                                                                      controllers
                                                                          .notesCtr
                                                                          .clear();
                                                                      imageController
                                                                          .photo1
                                                                          .value =
                                                                      "";
                                                                      showDialog(
                                                                          context: context,
                                                                          barrierDismissible: false,
                                                                          builder: (
                                                                              context) {
                                                                            return AlertDialog(
                                                                              actions: [
                                                                                Column(
                                                                                  children: [
                                                                                    Divider(
                                                                                      color: Colors
                                                                                          .grey
                                                                                          .shade300,
                                                                                      thickness: 1,
                                                                                    ),
                                                                                    Row(
                                                                                      mainAxisAlignment: MainAxisAlignment
                                                                                          .end,
                                                                                      children: [
                                                                                        TextButton(
                                                                                            onPressed: () {
                                                                                              Navigator
                                                                                                  .pop(
                                                                                                  context);
                                                                                            },
                                                                                            child: CustomText(
                                                                                              text: "Cancel",
                                                                                              isCopy: false,
                                                                                              isBold: true,)),
                                                                                        15
                                                                                            .width,
                                                                                        CustomLoadingButton(
                                                                                          callback: () {
                                                                                            if (controllers
                                                                                                .emailToCtr
                                                                                                .text
                                                                                                .trim()
                                                                                                .isEmpty) {
                                                                                              utils
                                                                                                  .showToast(
                                                                                                  "PO Number is empty!",
                                                                                                  Colors
                                                                                                      .red);
                                                                                              controllers
                                                                                                  .emailCtr
                                                                                                  .reset();
                                                                                              return;
                                                                                            }
                                                                                            if (controllers
                                                                                                .emailSubjectCtr
                                                                                                .text
                                                                                                .trim()
                                                                                                .isEmpty) {
                                                                                              utils
                                                                                                  .showToast(
                                                                                                  "PO Date is empty!",
                                                                                                  Colors
                                                                                                      .red);
                                                                                              controllers
                                                                                                  .emailCtr
                                                                                                  .reset();
                                                                                              return;
                                                                                            }
                                                                                            if (controllers
                                                                                                .notesCtr
                                                                                                .text
                                                                                                .trim()
                                                                                                .isEmpty) {
                                                                                              utils
                                                                                                  .showToast(
                                                                                                  "Notes is empty!",
                                                                                                  Colors
                                                                                                      .red);
                                                                                              controllers
                                                                                                  .emailCtr
                                                                                                  .reset();
                                                                                              return;
                                                                                            }
                                                                                            apiService
                                                                                                .insertPOAPI(
                                                                                                context,
                                                                                                data
                                                                                                    .email,
                                                                                                data
                                                                                                    .cusId
                                                                                                    .toString(),
                                                                                                data
                                                                                                    .id
                                                                                                    .toString(),
                                                                                                data
                                                                                                    .name
                                                                                                    .toString());
                                                                                          },
                                                                                          controller: controllers
                                                                                              .emailCtr,
                                                                                          isImage: false,
                                                                                          isLoading: true,
                                                                                          backgroundColor: colorsConst
                                                                                              .primary,
                                                                                          radius: 5,
                                                                                          width: 200,
                                                                                          height: 50,
                                                                                          text: "Send PO",
                                                                                          textColor: Colors
                                                                                              .white,
                                                                                        ),
                                                                                      ],
                                                                                    )
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                              content: SizedBox(
                                                                                  width: 600,
                                                                                  height: 400,
                                                                                  child: SingleChildScrollView(
                                                                                    child: Column(
                                                                                      crossAxisAlignment: CrossAxisAlignment
                                                                                          .start,
                                                                                      children: [
                                                                                        Align(
                                                                                            alignment: Alignment
                                                                                                .topRight,
                                                                                            child: InkWell(
                                                                                                onTap: () {
                                                                                                  Navigator
                                                                                                      .pop(
                                                                                                      context);
                                                                                                },
                                                                                                child: Icon(
                                                                                                  Icons
                                                                                                      .clear,
                                                                                                  size: 18,
                                                                                                  color: colorsConst
                                                                                                      .textColor,
                                                                                                ))),
                                                                                        Center(
                                                                                            child: CustomText(
                                                                                                colors: colorsConst
                                                                                                    .primary,
                                                                                                isBold: true,
                                                                                                size: 17,
                                                                                                text: "Upload Purchase Order",
                                                                                                isCopy: false)),
                                                                                        30
                                                                                            .height,
                                                                                        SizedBox(
                                                                                          width: 600,
                                                                                          child: TextField(
                                                                                            controller: controllers
                                                                                                .emailToCtr,
                                                                                            inputFormatters: constInputFormatters
                                                                                                .accNoInput,
                                                                                            style: TextStyle(
                                                                                                fontSize: 15,
                                                                                                color: colorsConst
                                                                                                    .textColor),
                                                                                            decoration: InputDecoration(
                                                                                              hintText: "PO Number",
                                                                                              hintStyle: TextStyle(
                                                                                                  color: colorsConst
                                                                                                      .textColor,
                                                                                                  fontSize: 14,
                                                                                                  fontFamily: "Lato"),
                                                                                              labelText: "PO Number",
                                                                                              labelStyle: TextStyle(
                                                                                                  color: colorsConst
                                                                                                      .textColor,
                                                                                                  fontSize: 14,
                                                                                                  fontFamily: "Lato"),
                                                                                              border: OutlineInputBorder(),
                                                                                              enabledBorder: OutlineInputBorder(
                                                                                                  borderSide: BorderSide(
                                                                                                    color: Colors
                                                                                                        .grey
                                                                                                        .shade400,
                                                                                                  ),
                                                                                                  borderRadius: BorderRadius
                                                                                                      .circular(
                                                                                                      5)),
                                                                                              focusedBorder: OutlineInputBorder(
                                                                                                  borderSide: BorderSide(
                                                                                                    color: colorsConst
                                                                                                        .primary,
                                                                                                  ),
                                                                                                  borderRadius: BorderRadius
                                                                                                      .circular(
                                                                                                      5)),
                                                                                              focusedErrorBorder: OutlineInputBorder(
                                                                                                  borderSide: BorderSide(
                                                                                                      color: const Color(
                                                                                                          0xffE1E5FA)),
                                                                                                  borderRadius: BorderRadius
                                                                                                      .circular(
                                                                                                      5)),
                                                                                              contentPadding: const EdgeInsets
                                                                                                  .symmetric(
                                                                                                  vertical: 10.0,
                                                                                                  horizontal: 10.0),
                                                                                              errorBorder: OutlineInputBorder(
                                                                                                  borderSide: BorderSide(
                                                                                                      color: const Color(
                                                                                                          0xffE1E5FA)),
                                                                                                  borderRadius: BorderRadius
                                                                                                      .circular(
                                                                                                      5)),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        30
                                                                                            .height,
                                                                                        SizedBox(
                                                                                          width: 600,
                                                                                          height: 50,
                                                                                          child: TextField(
                                                                                            readOnly: true,
                                                                                            onTap: () {
                                                                                              utils
                                                                                                  .datePicker(
                                                                                                  context: context,
                                                                                                  textEditingController:
                                                                                                  controllers
                                                                                                      .emailSubjectCtr,
                                                                                                  pathVal: controllers
                                                                                                      .empDOB);
                                                                                            },
                                                                                            controller: controllers
                                                                                                .emailSubjectCtr,
                                                                                            style: TextStyle(
                                                                                              color: colorsConst
                                                                                                  .textColor,
                                                                                            ),
                                                                                            decoration: InputDecoration(
                                                                                              hintText: "PO Date",
                                                                                              hintStyle: TextStyle(
                                                                                                  color: colorsConst
                                                                                                      .textColor,
                                                                                                  fontSize: 14,
                                                                                                  fontFamily: "Lato"),
                                                                                              labelText: "PO Date",
                                                                                              labelStyle: TextStyle(
                                                                                                  color: colorsConst
                                                                                                      .textColor,
                                                                                                  fontSize: 14,
                                                                                                  fontFamily: "Lato"),
                                                                                              border: OutlineInputBorder(),
                                                                                              enabledBorder: OutlineInputBorder(
                                                                                                  borderSide: BorderSide(
                                                                                                    color: Colors
                                                                                                        .grey
                                                                                                        .shade400,
                                                                                                  ),
                                                                                                  borderRadius: BorderRadius
                                                                                                      .circular(
                                                                                                      5)),
                                                                                              focusedBorder: OutlineInputBorder(
                                                                                                  borderSide: BorderSide(
                                                                                                    color: colorsConst
                                                                                                        .primary,
                                                                                                  ),
                                                                                                  borderRadius: BorderRadius
                                                                                                      .circular(
                                                                                                      5)),
                                                                                              focusedErrorBorder: OutlineInputBorder(
                                                                                                  borderSide: BorderSide(
                                                                                                      color: const Color(
                                                                                                          0xffE1E5FA)),
                                                                                                  borderRadius: BorderRadius
                                                                                                      .circular(
                                                                                                      5)),
                                                                                              contentPadding: const EdgeInsets
                                                                                                  .symmetric(
                                                                                                  vertical: 10.0,
                                                                                                  horizontal: 10.0),
                                                                                              errorBorder: OutlineInputBorder(
                                                                                                  borderSide: BorderSide(
                                                                                                      color: const Color(
                                                                                                          0xffE1E5FA)),
                                                                                                  borderRadius: BorderRadius
                                                                                                      .circular(
                                                                                                      5)),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        30
                                                                                            .height,
                                                                                        SizedBox(
                                                                                          width: 600,
                                                                                          child: TextField(
                                                                                            textInputAction: TextInputAction
                                                                                                .newline,
                                                                                            controller: controllers
                                                                                                .notesCtr,
                                                                                            keyboardType: TextInputType
                                                                                                .multiline,
                                                                                            maxLines: null,
                                                                                            minLines: 3,
                                                                                            style: TextStyle(
                                                                                              color: colorsConst
                                                                                                  .textColor,
                                                                                            ),
                                                                                            decoration: InputDecoration(
                                                                                              hintText: "Notes",
                                                                                              hintStyle: TextStyle(
                                                                                                  color: colorsConst
                                                                                                      .textColor,
                                                                                                  fontSize: 14,
                                                                                                  fontFamily: "Lato"),
                                                                                              labelText: "Notes",
                                                                                              labelStyle: TextStyle(
                                                                                                  color: colorsConst
                                                                                                      .textColor,
                                                                                                  fontSize: 14,
                                                                                                  fontFamily: "Lato"),
                                                                                              border: OutlineInputBorder(),
                                                                                              enabledBorder: OutlineInputBorder(
                                                                                                  borderSide: BorderSide(
                                                                                                    color: Colors
                                                                                                        .grey
                                                                                                        .shade400,
                                                                                                  ),
                                                                                                  borderRadius: BorderRadius
                                                                                                      .circular(
                                                                                                      5)),
                                                                                              focusedBorder: OutlineInputBorder(
                                                                                                  borderSide: BorderSide(
                                                                                                    color: colorsConst
                                                                                                        .primary,
                                                                                                  ),
                                                                                                  borderRadius: BorderRadius
                                                                                                      .circular(
                                                                                                      5)),
                                                                                              focusedErrorBorder: OutlineInputBorder(
                                                                                                  borderSide: BorderSide(
                                                                                                      color: const Color(
                                                                                                          0xffE1E5FA)),
                                                                                                  borderRadius: BorderRadius
                                                                                                      .circular(
                                                                                                      5)),
                                                                                              contentPadding: const EdgeInsets
                                                                                                  .symmetric(
                                                                                                  vertical: 10.0,
                                                                                                  horizontal: 10.0),
                                                                                              errorBorder: OutlineInputBorder(
                                                                                                  borderSide: BorderSide(
                                                                                                      color: const Color(
                                                                                                          0xffE1E5FA)),
                                                                                                  borderRadius: BorderRadius
                                                                                                      .circular(
                                                                                                      5)),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        30
                                                                                            .height,
                                                                                        InkWell(
                                                                                          onTap: () {
                                                                                            utils
                                                                                                .chooseFile(
                                                                                                mediaDataV: imageController
                                                                                                    .empMediaData,
                                                                                                fileName: imageController
                                                                                                    .empFileName,
                                                                                                pathName: imageController
                                                                                                    .photo1);
                                                                                          },
                                                                                          child: Row(
                                                                                            children: [
                                                                                              Icon(
                                                                                                  Icons
                                                                                                      .attach_file,
                                                                                                  size: 18,
                                                                                                  color: Colors
                                                                                                      .black),
                                                                                              SizedBox(
                                                                                                  width: 6),
                                                                                              Text(
                                                                                                  "Attach File",
                                                                                                  style: TextStyle(
                                                                                                      fontSize: 14,
                                                                                                      fontWeight: FontWeight
                                                                                                          .bold)),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                        30
                                                                                            .height,
                                                                                        Obx(() =>
                                                                                        imageController
                                                                                            .photo1
                                                                                            .value
                                                                                            .isEmpty
                                                                                            ? 0
                                                                                            .height
                                                                                            : Container(
                                                                                          padding: const EdgeInsets
                                                                                              .symmetric(
                                                                                              horizontal: 6,
                                                                                              vertical: 4),
                                                                                          decoration: BoxDecoration(
                                                                                            color: Color(
                                                                                                0xff86BAE3FF),
                                                                                            borderRadius: BorderRadius
                                                                                                .circular(
                                                                                                20),
                                                                                          ),
                                                                                          child: Row(
                                                                                            mainAxisSize: MainAxisSize
                                                                                                .min,
                                                                                            children: [
                                                                                              Obx(() =>
                                                                                                  CustomText(
                                                                                                    text: imageController
                                                                                                        .empFileName
                                                                                                        .value,
                                                                                                    isCopy: false,)),
                                                                                              SizedBox(
                                                                                                width: 10,),
                                                                                              IconButton(
                                                                                                padding: EdgeInsets
                                                                                                    .zero,
                                                                                                constraints: const BoxConstraints(),
                                                                                                onPressed: () {
                                                                                                  imageController
                                                                                                      .photo1
                                                                                                      .value =
                                                                                                  "";
                                                                                                },
                                                                                                icon: const Icon(
                                                                                                    Icons
                                                                                                        .close,
                                                                                                    size: 10),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),),
                                                                                      ],
                                                                                    ),
                                                                                  )),
                                                                            );
                                                                          });
                                                                    } else
                                                                    if (data
                                                                        .status ==
                                                                        "PO Sent" &&
                                                                        data
                                                                            .dropValue ==
                                                                            "Upload PO") {
                                                                      utils
                                                                          .snackBar(
                                                                          context: context,
                                                                          msg: "Already PO Sent",
                                                                          color: Colors
                                                                              .red);
                                                                    }
                                                                  });
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets
                                                              .all(10.0),
                                                          child: CustomText(
                                                            textAlign: TextAlign
                                                                .left,
                                                            text: data
                                                                .quotationNo,
                                                            size: 14,
                                                            isCopy: true,
                                                            colors: colorsConst
                                                                .textColor,
                                                          ),
                                                        ),
                                                        Tooltip(
                                                          message: data.name
                                                              .toString() ==
                                                              "null" ? "" : data
                                                              .name.toString(),
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
                                                        Tooltip(
                                                          message: data.company
                                                              .toString() ==
                                                              "null" ? "" : data
                                                              .company
                                                              .toString(),
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
                                                        Tooltip(
                                                          message: data.number
                                                              .toString() ==
                                                              "null" ? "" : data
                                                              .number
                                                              .toString(),
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
                                                        Tooltip(
                                                          message: data
                                                              .totalProduct
                                                              .toString(),
                                                          child: Padding(
                                                            padding: const EdgeInsets
                                                                .all(10.0),
                                                            child: CustomText(
                                                              textAlign: TextAlign
                                                                  .left,
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
                                                        Tooltip(
                                                          message: data
                                                              .totalItem
                                                              .toString(),
                                                          child: Padding(
                                                            padding: const EdgeInsets
                                                                .all(10.0),
                                                            child: CustomText(
                                                              textAlign: TextAlign
                                                                  .left,
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
                                                        Tooltip(
                                                          message: productCtr
                                                              .formatAmount(
                                                              data.totalAmt
                                                                  .toString()),
                                                          child: Padding(
                                                            padding: const EdgeInsets
                                                                .all(10.0),
                                                            child: CustomText(
                                                              textAlign: TextAlign
                                                                  .left,
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
                                                        Padding(
                                                          padding: const EdgeInsets
                                                              .all(10.0),
                                                          child: CustomText(
                                                            textAlign: TextAlign
                                                                .left,
                                                            text: productCtr
                                                                .fixedDateTime(
                                                                data.createdTs
                                                                    .toString()),
                                                            size: 14,
                                                            isCopy: true,
                                                            colors: colorsConst
                                                                .textColor,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets
                                                              .all(10.0),
                                                          child: CustomText(
                                                            textAlign: TextAlign
                                                                .left,
                                                            text: data
                                                                .validityDate
                                                                .toString(),
                                                            size: 14,
                                                            isCopy: true,
                                                            colors: colorsConst
                                                                .textColor,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets
                                                              .all(10.0),
                                                          child: InkWell(
                                                            onTap: () {
                                                              String url = "$getImage?path=${Uri
                                                                  .encodeComponent(
                                                                  data
                                                                      .invoicePdf)}";
                                                              showPdfDialog(
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
                                                        Tooltip(
                                                          message: data.status,
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
                                                        // Padding(
                                                        //   padding: const EdgeInsets.all(10.0),
                                                        //   child: InkWell(
                                                        //       onTap: data.status=="Order Confirmed"?null:(){
                                                        //         apiService.confirmOrderAPI(context,data.id.toString(),data.cusId.toString(),data.totalAmt.toString(),data.name.toString(),data.number.toString());
                                                        //     }, child: Padding(
                                                        //       padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
                                                        //       child: CustomText(text: "CONFIRM ORDER", isCopy: false,isBold: true,colors: data.status=="Order Confirmed"?Colors.grey:Colors.green,),
                                                        //     ),),
                                                        // ),
                                                      ]
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        }),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // SizedBox(
                        //   width: controllers.isLeftOpen.value?MediaQuery.of(context).size.width - 150:MediaQuery.of(context).size.width - 60,
                        //   child: Table(
                        //     columnWidths: const {
                        //       0: FixedColumnWidth(60),//s no
                        //       1: FlexColumnWidth(1.5),//Action
                        //       2: FlexColumnWidth(1.3),//q no
                        //       3: FlexColumnWidth(1.7),//cus
                        //       4: FlexColumnWidth(1.7),//com
                        //       5: FlexColumnWidth(1.2),//com no
                        //       6: FlexColumnWidth(1.3),//prd
                        //       7: FlexColumnWidth(1),//ite
                        //       8: FlexColumnWidth(1),//amt
                        //       9: FlexColumnWidth(1),//date
                        //       10: FlexColumnWidth(1),//vali
                        //       11: FlexColumnWidth(1),//quo
                        //       12: FlexColumnWidth(0.9),//stat
                        //     },
                        //     border: TableBorder(
                        //       horizontalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                        //       verticalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                        //     ),
                        //     children: [
                        //       TableRow(
                        //           decoration: BoxDecoration(
                        //               color: colorsConst.primary,
                        //               borderRadius: const BorderRadius.only(
                        //                   topLeft: Radius.circular(5),
                        //                   topRight: Radius.circular(5))),
                        //           children: [
                        //             headerCell(2,  CustomText(
                        //               textAlign: TextAlign.left,
                        //               text: "S.No",
                        //               size: 15,
                        //               isBold: true,
                        //               isCopy: true,
                        //               colors: Colors.white,
                        //             ),),
                        //             headerCell(2,  CustomText(
                        //               textAlign: TextAlign.left,
                        //               text: "Action",
                        //               size: 15,
                        //               isBold: true,
                        //               isCopy: true,
                        //               colors: Colors.white,
                        //             ),),
                        //             headerCell(2,  Row(
                        //               children: [
                        //                 CustomText(
                        //                   textAlign: TextAlign.left,
                        //                   text: "Quotation No",
                        //                   size: 15,
                        //                   isBold: true,
                        //                   isCopy: true,
                        //                   colors: Colors.white,
                        //                 ),
                        //                 3.width,
                        //                 GestureDetector(
                        //                   onTap: (){
                        //                     if(controllers.sortFieldCallActivity.value=='qno' && controllers.sortOrderCallActivity.value=='asc'){
                        //                       controllers.sortOrderCallActivity.value='desc';
                        //                     }else{
                        //                       controllers.sortOrderCallActivity.value='asc';
                        //                     }
                        //                     controllers.sortFieldCallActivity.value='qno';
                        //                     productCtr.filterAndSortQuotations(
                        //                       searchText: controllers.searchText.value.toLowerCase(),
                        //                       sortField: controllers.sortFieldCallActivity.value,
                        //                       sortOrder: controllers.sortOrderCallActivity.value,
                        //                       selectedMonth: productCtr.selectedCallMonth.value,
                        //                       selectedRange: productCtr.selectedCallRange.value,
                        //                       selectedDateFilter: productCtr.selectedCallSortBy.value,
                        //                     );
                        //                   },
                        //                   child: Obx(() => Image.asset(
                        //                     controllers.sortFieldCallActivity.value.isEmpty
                        //                         ? "assets/images/arrow.png"
                        //                         : controllers.sortOrderCallActivity.value == 'asc'
                        //                         ? "assets/images/arrow_up.png"
                        //                         : "assets/images/arrow_down.png",
                        //                     width: 15,
                        //                     height: 15,
                        //                   ),
                        //                   ),
                        //                 ),
                        //
                        //               ],
                        //             ),),
                        //             headerCell(3, Row(
                        //               children: [
                        //                 CustomText(//2
                        //                   textAlign: TextAlign.left,
                        //                   text: "Customer",
                        //                   size: 15,
                        //                   isBold: true,
                        //                   isCopy: true,
                        //                   colors: Colors.white,
                        //                 ),
                        //                 3.width,
                        //                 GestureDetector(
                        //                   onTap: (){
                        //                     if(controllers.sortFieldCallActivity.value=='name' && controllers.sortOrderCallActivity.value=='asc'){
                        //                       controllers.sortOrderCallActivity.value='desc';
                        //                     }else{
                        //                       controllers.sortOrderCallActivity.value='asc';
                        //                     }
                        //                     controllers.sortFieldCallActivity.value='name';
                        //                     productCtr.filterAndSortQuotations(
                        //                       searchText: controllers.searchText.value.toLowerCase(),
                        //                       sortField: controllers.sortFieldCallActivity.value,
                        //                       sortOrder: controllers.sortOrderCallActivity.value,
                        //                       selectedMonth: productCtr.selectedCallMonth.value,
                        //                       selectedRange: productCtr.selectedCallRange.value,
                        //                       selectedDateFilter: productCtr.selectedCallSortBy.value,
                        //                     );
                        //                   },
                        //                   child: Obx(() => Image.asset(
                        //                     controllers.sortFieldCallActivity.value.isEmpty
                        //                         ? "assets/images/arrow.png"
                        //                         : controllers.sortOrderCallActivity.value == 'asc'
                        //                         ? "assets/images/arrow_up.png"
                        //                         : "assets/images/arrow_down.png",
                        //                     width: 15,
                        //                     height: 15,
                        //                   ),
                        //                   ),
                        //                 ),
                        //               ],
                        //             ),),
                        //             headerCell(3, Row(
                        //               children: [
                        //                 CustomText(//2
                        //                   textAlign: TextAlign.left,
                        //                   text: "Company",
                        //                   size: 15,
                        //                   isBold: true,
                        //                   isCopy: true,
                        //                   colors: Colors.white,
                        //                 ),
                        //                 3.width,
                        //                 GestureDetector(
                        //                   onTap: (){
                        //                     if(controllers.sortFieldCallActivity.value=='company' && controllers.sortOrderCallActivity.value=='asc'){
                        //                       controllers.sortOrderCallActivity.value='desc';
                        //                     }else{
                        //                       controllers.sortOrderCallActivity.value='asc';
                        //                     }
                        //                     controllers.sortFieldCallActivity.value='company';
                        //                     productCtr.filterAndSortQuotations(
                        //                       searchText: controllers.searchText.value.toLowerCase(),
                        //                       sortField: controllers.sortFieldCallActivity.value,
                        //                       sortOrder: controllers.sortOrderCallActivity.value,
                        //                       selectedMonth: productCtr.selectedCallMonth.value,
                        //                       selectedRange: productCtr.selectedCallRange.value,
                        //                       selectedDateFilter: productCtr.selectedCallSortBy.value,
                        //                     );
                        //                   },
                        //                   child: Obx(() => Image.asset(
                        //                     controllers.sortFieldCallActivity.value.isEmpty
                        //                         ? "assets/images/arrow.png"
                        //                         : controllers.sortOrderCallActivity.value == 'asc'
                        //                         ? "assets/images/arrow_up.png"
                        //                         : "assets/images/arrow_down.png",
                        //                     width: 15,
                        //                     height: 15,
                        //                   ),
                        //                   ),
                        //                 ),
                        //               ],
                        //             ),),
                        //             headerCell(4, Row(
                        //               children: [
                        //                 CustomText(
                        //                   textAlign: TextAlign.left,
                        //                   text: "Phone No",
                        //                   size: 15,
                        //                   isBold: true,
                        //                   isCopy: true,
                        //                   colors: Colors.white,
                        //                 ),
                        //                 3.width,
                        //                 GestureDetector(
                        //                   onTap: (){
                        //                     if(controllers.sortFieldCallActivity.value=='number' && controllers.sortOrderCallActivity.value=='asc'){
                        //                       controllers.sortOrderCallActivity.value='desc';
                        //                     }else{
                        //                       controllers.sortOrderCallActivity.value='asc';
                        //                     }
                        //                     controllers.sortFieldCallActivity.value='number';
                        //                     productCtr.filterAndSortQuotations(
                        //                       searchText: controllers.searchText.value.toLowerCase(),
                        //                       sortField: controllers.sortFieldCallActivity.value,
                        //                       sortOrder: controllers.sortOrderCallActivity.value,
                        //                       selectedMonth: productCtr.selectedCallMonth.value,
                        //                       selectedRange: productCtr.selectedCallRange.value,
                        //                       selectedDateFilter: productCtr.selectedCallSortBy.value,
                        //                     );
                        //                   },
                        //                   child: Obx(() => Image.asset(
                        //                     controllers.sortFieldCallActivity.value.isEmpty
                        //                         ? "assets/images/arrow.png"
                        //                         : controllers.sortOrderCallActivity.value == 'asc'
                        //                         ? "assets/images/arrow_up.png"
                        //                         : "assets/images/arrow_down.png",
                        //                     width: 15,
                        //                     height: 15,
                        //                   ),
                        //                   ),
                        //                 ),
                        //               ],
                        //             ),),
                        //             headerCell(2, Row(
                        //               children: [
                        //                 CustomText(
                        //                   textAlign: TextAlign.left,
                        //                   text: "Tot Products",
                        //                   size: 15,
                        //                   isBold: true,
                        //                   isCopy: true,
                        //                   colors: Colors.white,
                        //                 ),
                        //                 3.width,
                        //                 GestureDetector(
                        //                   onTap: (){
                        //                     if(controllers.sortFieldCallActivity.value=='products' && controllers.sortOrderCallActivity.value=='asc'){
                        //                       controllers.sortOrderCallActivity.value='desc';
                        //                     }else{
                        //                       controllers.sortOrderCallActivity.value='asc';
                        //                     }
                        //                     controllers.sortFieldCallActivity.value='products';
                        //                     productCtr.filterAndSortQuotations(
                        //                       searchText: controllers.searchText.value.toLowerCase(),
                        //                       sortField: controllers.sortFieldCallActivity.value,
                        //                       sortOrder: controllers.sortOrderCallActivity.value,
                        //                       selectedMonth: productCtr.selectedCallMonth.value,
                        //                       selectedRange: productCtr.selectedCallRange.value,
                        //                       selectedDateFilter: productCtr.selectedCallSortBy.value,
                        //                     );
                        //                   },
                        //                   child: Obx(() => Image.asset(
                        //                     controllers.sortFieldCallActivity.value.isEmpty
                        //                         ? "assets/images/arrow.png"
                        //                         : controllers.sortOrderCallActivity.value == 'asc'
                        //                         ? "assets/images/arrow_up.png"
                        //                         : "assets/images/arrow_down.png",
                        //                     width: 15,
                        //                     height: 15,
                        //                   ),
                        //                   ),
                        //                 ),
                        //               ],
                        //             ),),
                        //             headerCell(2, Row(
                        //               children: [
                        //                 CustomText(
                        //                   textAlign: TextAlign.left,
                        //                   text: "Tot Item",
                        //                   size: 15,
                        //                   isBold: true,
                        //                   isCopy: true,
                        //                   colors: Colors.white,
                        //                 ),
                        //                 3.width,
                        //                 GestureDetector(
                        //                   onTap: (){
                        //                     if(controllers.sortFieldCallActivity.value=='item' && controllers.sortOrderCallActivity.value=='asc'){
                        //                       controllers.sortOrderCallActivity.value='desc';
                        //                     }else{
                        //                       controllers.sortOrderCallActivity.value='asc';
                        //                     }
                        //                     controllers.sortFieldCallActivity.value='item';
                        //                     productCtr.filterAndSortQuotations(
                        //                       searchText: controllers.searchText.value.toLowerCase(),
                        //                       sortField: controllers.sortFieldCallActivity.value,
                        //                       sortOrder: controllers.sortOrderCallActivity.value,
                        //                       selectedMonth: productCtr.selectedCallMonth.value,
                        //                       selectedRange: productCtr.selectedCallRange.value,
                        //                       selectedDateFilter: productCtr.selectedCallSortBy.value,
                        //                     );
                        //                   },
                        //                   child: Obx(() => Image.asset(
                        //                     controllers.sortFieldCallActivity.value.isEmpty
                        //                         ? "assets/images/arrow.png"
                        //                         : controllers.sortOrderCallActivity.value == 'asc'
                        //                         ? "assets/images/arrow_up.png"
                        //                         : "assets/images/arrow_down.png",
                        //                     width: 15,
                        //                     height: 15,
                        //                   ),
                        //                   ),
                        //                 ),
                        //               ],
                        //             ),),
                        //             headerCell(5, Row(
                        //               children: [
                        //                 CustomText(
                        //                   textAlign: TextAlign.left,
                        //                   text: "Tot Amt",
                        //                   size: 15,
                        //                   isBold: true,
                        //                   isCopy: true,
                        //                   colors: Colors.white,
                        //                 ),
                        //                 3.width,
                        //                 GestureDetector(
                        //                   onTap: (){
                        //                     if(controllers.sortFieldCallActivity.value=='amt' && controllers.sortOrderCallActivity.value=='asc'){
                        //                       controllers.sortOrderCallActivity.value='desc';
                        //                     }else{
                        //                       controllers.sortOrderCallActivity.value='asc';
                        //                     }
                        //                     controllers.sortFieldCallActivity.value='amt';
                        //                     productCtr.filterAndSortQuotations(
                        //                       searchText: controllers.searchText.value.toLowerCase(),
                        //                       sortField: controllers.sortFieldCallActivity.value,
                        //                       sortOrder: controllers.sortOrderCallActivity.value,
                        //                       selectedMonth: productCtr.selectedCallMonth.value,
                        //                       selectedRange: productCtr.selectedCallRange.value,
                        //                       selectedDateFilter: productCtr.selectedCallSortBy.value,
                        //                     );
                        //                   },
                        //                   child: Obx(() => Image.asset(
                        //                     controllers.sortFieldCallActivity.value.isEmpty
                        //                         ? "assets/images/arrow.png"
                        //                         : controllers.sortOrderCallActivity.value == 'asc'
                        //                         ? "assets/images/arrow_up.png"
                        //                         : "assets/images/arrow_down.png",
                        //                     width: 15,
                        //                     height: 15,
                        //                   ),
                        //                   ),
                        //                 ),
                        //               ],
                        //             ),),
                        //             headerCell(6, Row(
                        //               children: [
                        //                 CustomText(//4
                        //                   textAlign: TextAlign.left,
                        //                   text: "Sent Date",
                        //                   size: 15,
                        //                   isBold: true,
                        //                   isCopy: true,
                        //                   colors: Colors.white,
                        //                 ),
                        //                 3.width,
                        //                 GestureDetector(
                        //                   onTap: (){
                        //                     if(controllers.sortFieldCallActivity.value=='date' && controllers.sortOrderCallActivity.value=='asc'){
                        //                       controllers.sortOrderCallActivity.value='desc';
                        //                     }else{
                        //                       controllers.sortOrderCallActivity.value='asc';
                        //                     }
                        //                     controllers.sortFieldCallActivity.value='date';
                        //                     productCtr.filterAndSortQuotations(
                        //                       searchText: controllers.searchText.value.toLowerCase(),
                        //                       sortField: controllers.sortFieldCallActivity.value,
                        //                       sortOrder: controllers.sortOrderCallActivity.value,
                        //                       selectedMonth: productCtr.selectedCallMonth.value,
                        //                       selectedRange: productCtr.selectedCallRange.value,
                        //                       selectedDateFilter: productCtr.selectedCallSortBy.value,
                        //                     );
                        //                   },
                        //                   child: Obx(() => Image.asset(
                        //                     controllers.sortFieldCallActivity.value.isEmpty
                        //                         ? "assets/images/arrow.png"
                        //                         : controllers.sortOrderCallActivity.value == 'asc'
                        //                         ? "assets/images/arrow_up.png"
                        //                         : "assets/images/arrow_down.png",
                        //                     width: 15,
                        //                     height: 15,
                        //                   ),
                        //                   ),
                        //                 ),
                        //               ],
                        //             ),),
                        //             headerCell(6, Row(
                        //               children: [
                        //                 CustomText(//4
                        //                   textAlign: TextAlign.left,
                        //                   text: "Validity",
                        //                   size: 15,
                        //                   isBold: true,
                        //                   isCopy: true,
                        //                   colors: Colors.white,
                        //                 ),
                        //                 3.width,
                        //                 GestureDetector(
                        //                   onTap: (){
                        //                     if(controllers.sortFieldCallActivity.value=='validity' && controllers.sortOrderCallActivity.value=='asc'){
                        //                       controllers.sortOrderCallActivity.value='desc';
                        //                     }else{
                        //                       controllers.sortOrderCallActivity.value='asc';
                        //                     }
                        //                     controllers.sortFieldCallActivity.value='validity';
                        //                     productCtr.filterAndSortQuotations(
                        //                       searchText: controllers.searchText.value.toLowerCase(),
                        //                       sortField: controllers.sortFieldCallActivity.value,
                        //                       sortOrder: controllers.sortOrderCallActivity.value,
                        //                       selectedMonth: productCtr.selectedCallMonth.value,
                        //                       selectedRange: productCtr.selectedCallRange.value,
                        //                       selectedDateFilter: productCtr.selectedCallSortBy.value,
                        //                     );
                        //                   },
                        //                   child: Obx(() => Image.asset(
                        //                     controllers.sortFieldCallActivity.value.isEmpty
                        //                         ? "assets/images/arrow.png"
                        //                         : controllers.sortOrderCallActivity.value == 'asc'
                        //                         ? "assets/images/arrow_up.png"
                        //                         : "assets/images/arrow_down.png",
                        //                     width: 15,
                        //                     height: 15,
                        //                   ),
                        //                   ),
                        //                 ),
                        //               ],
                        //             ),),
                        //             headerCell(8, CustomText(
                        //               textAlign: TextAlign.left,
                        //               text: "Quotation",
                        //               size: 15,
                        //               isBold: true,
                        //               isCopy: true,
                        //               colors: Colors.white,
                        //             ),),
                        //             headerCell(7, Row(
                        //               children: [
                        //                 CustomText(//4
                        //                   textAlign: TextAlign.left,
                        //                   text: "Status",
                        //                   size: 15,
                        //                   isBold: true,
                        //                   isCopy: true,
                        //                   colors: Colors.white,
                        //                 ),
                        //                 3.width,
                        //                 GestureDetector(
                        //                   onTap: (){
                        //                     if(controllers.sortFieldCallActivity.value=='status' && controllers.sortOrderCallActivity.value=='asc'){
                        //                       controllers.sortOrderCallActivity.value='desc';
                        //                     }else{
                        //                       controllers.sortOrderCallActivity.value='asc';
                        //                     }
                        //                     controllers.sortFieldCallActivity.value='status';
                        //                     productCtr.filterAndSortQuotations(
                        //                       searchText: controllers.searchText.value.toLowerCase(),
                        //                       sortField: controllers.sortFieldCallActivity.value,
                        //                       sortOrder: controllers.sortOrderCallActivity.value,
                        //                       selectedMonth: productCtr.selectedCallMonth.value,
                        //                       selectedRange: productCtr.selectedCallRange.value,
                        //                       selectedDateFilter: productCtr.selectedCallSortBy.value,
                        //                     );
                        //                   },
                        //                   child: Obx(() => Image.asset(
                        //                     controllers.sortFieldCallActivity.value.isEmpty
                        //                         ? "assets/images/arrow.png"
                        //                         : controllers.sortOrderCallActivity.value == 'asc'
                        //                         ? "assets/images/arrow_up.png"
                        //                         : "assets/images/arrow_down.png",
                        //                     width: 15,
                        //                     height: 15,
                        //                   ),
                        //                   ),
                        //                 ),
                        //               ],
                        //             ),),
                        //             // headerCell(9, CustomText(
                        //             //   textAlign: TextAlign.left,
                        //             //   text: "Confirm Order",
                        //             //   size: 15,
                        //             //   isBold: true,
                        //             //   isCopy: true,
                        //             //   colors: Colors.white,
                        //             // ),)
                        //           ]),
                        //     ],
                        //   ),
                        // ),
                        // Expanded(
                        //     child: Obx((){
                        //       return productCtr.quotationsList.isEmpty? Container(
                        //           width: MediaQuery.of(context).size.width,
                        //           height: MediaQuery.of(context).size.height/2,
                        //           alignment: Alignment.center,
                        //           child: SvgPicture.asset(
                        //               "assets/images/noDataFound.svg"))
                        //           :RawKeyboardListener(
                        //         focusNode: _focusNode,
                        //         autofocus: true,
                        //         onKey: (event) {
                        //           if (event is RawKeyDownEvent) {
                        //             if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                        //               _controller.animateTo(
                        //                 _controller.offset + 100,
                        //                 duration: const Duration(milliseconds: 200),
                        //                 curve: Curves.easeInOut,
                        //               );
                        //             } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                        //               _controller.animateTo(
                        //                 _controller.offset - 100,
                        //                 duration: const Duration(milliseconds: 200),
                        //                 curve: Curves.easeInOut,
                        //               );
                        //             }
                        //           }
                        //         },
                        //         child: ListView.builder(
                        //           controller: _controller,
                        //           shrinkWrap: true,
                        //           physics: const ScrollPhysics(),
                        //           itemCount: productCtr.quotationsList.length,
                        //           itemBuilder: (context, index) {
                        //             final data = productCtr.quotationsList[index];
                        //             return Table(
                        //               columnWidths: const {
                        //                 0: FixedColumnWidth(60),//s no
                        //                 1: FlexColumnWidth(1.5),//Action
                        //                 2: FlexColumnWidth(1.3),//q no
                        //                 3: FlexColumnWidth(1.7),//cus
                        //                 4: FlexColumnWidth(1.7),//com
                        //                 5: FlexColumnWidth(1.2),//com no
                        //                 6: FlexColumnWidth(1.3),//prd
                        //                 7: FlexColumnWidth(1),//ite
                        //                 8: FlexColumnWidth(1),//amt
                        //                 9: FlexColumnWidth(1),//date
                        //                 10: FlexColumnWidth(1),//vali
                        //                 11: FlexColumnWidth(1),//quo
                        //                 12: FlexColumnWidth(0.9),//stat
                        //               },
                        //               border: TableBorder(
                        //                 horizontalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                        //                 verticalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                        //                 bottom:  BorderSide(width: 0.5, color: Colors.grey.shade400),
                        //               ),
                        //               children:[
                        //                 TableRow(
                        //                     decoration: BoxDecoration(
                        //                       color: int.parse(index.toString()) % 2 == 0 ? Colors.white : colorsConst.backgroundColor,
                        //                     ),
                        //                     children:[
                        //                       Padding(
                        //                         padding: const EdgeInsets.all(10.0),
                        //                         child: CustomText(
                        //                           textAlign: TextAlign.left,
                        //                           text: "${index+1}",
                        //                           size: 14,
                        //                           isCopy: true,
                        //                           colors:colorsConst.textColor,
                        //                         ),
                        //                       ),
                        //                       Padding(
                        //                         padding: const EdgeInsets.all(10.0),
                        //                         child: Container(
                        //                           height:40,
                        //                           padding: const EdgeInsets.symmetric(horizontal: 10),
                        //                           decoration: BoxDecoration(
                        //                             color: Colors.white,
                        //                             borderRadius: BorderRadius.circular(8),
                        //                             border: Border.all(color: Colors.grey.shade400, width: 1.2),
                        //                           ),
                        //                           child: DropdownButtonHideUnderline(
                        //                             child: DropdownButton<String>(
                        //                               value: data.dropValue,
                        //                               hint: CustomText(text: "Select Status",isCopy: false,colors: Colors.grey,),
                        //                               isExpanded: true,
                        //                               icon: const Icon(Icons.keyboard_arrow_down),
                        //                               items: statusList.map((status) {
                        //                                 return DropdownMenuItem(
                        //                                   value: status,
                        //                                   child: CustomText(text: status,isCopy: false),
                        //                                 );
                        //                               }).toList(),
                        //                               onChanged: (value) {
                        //                                 setState(() {
                        //                                   data.dropValue = value;
                        //                                   if(data.status!="Order Confirmed"&&data.dropValue=="Confirm Order"){
                        //                                     showDialog(
                        //                                         context: context,
                        //                                         barrierDismissible: false,
                        //                                         builder: (context) {
                        //                                           return AlertDialog(
                        //                                             content: CustomText(
                        //                                               text: "Are you sure confirm this order?",
                        //                                               size: 16,
                        //                                               isCopy: false,
                        //                                               isBold: true,
                        //                                               colors: colorsConst.textColor,
                        //                                             ),
                        //                                             actions: [
                        //                                               Row(
                        //                                                 mainAxisAlignment: MainAxisAlignment.end,
                        //                                                 children: [
                        //                                                   Container(
                        //                                                     decoration: BoxDecoration(
                        //                                                         border: Border.all(color: colorsConst.primary),
                        //                                                         color: Colors.white),
                        //                                                     width: 80,
                        //                                                     height: 25,
                        //                                                     child: ElevatedButton(
                        //                                                         style: ElevatedButton.styleFrom(
                        //                                                           shape: const RoundedRectangleBorder(
                        //                                                             borderRadius: BorderRadius.zero,
                        //                                                           ),
                        //                                                           backgroundColor: Colors.white,
                        //                                                         ),
                        //                                                         onPressed: () {
                        //                                                           Navigator.pop(context);
                        //                                                         },
                        //                                                         child: CustomText(
                        //                                                           text: "Cancel",
                        //                                                           isCopy: false,
                        //                                                           colors: colorsConst.primary,
                        //                                                           size: 14,
                        //                                                         )),
                        //                                                   ),
                        //                                                   10.width,
                        //                                                   CustomLoadingButton(
                        //                                                     callback: (){
                        //                                                     apiService.confirmOrderAPI(context,data.id.toString(),data.cusId.toString(),data.totalAmt.toString(),data.name.toString(),data.number.toString());
                        //                                                     },
                        //                                                     height: 35,
                        //                                                     isLoading: true,
                        //                                                     backgroundColor: colorsConst.primary,
                        //                                                     radius: 2,
                        //                                                     width: 80,
                        //                                                     controller: controllers.productCtr,
                        //                                                     isImage: false,
                        //                                                     text: "Confirm",
                        //                                                     textColor: Colors.white,
                        //                                                   ),
                        //                                                   5.width
                        //                                                 ],
                        //                                               ),
                        //                                             ],
                        //                                           );
                        //                                         });
                        //                                   }else if(data.status=="Order Confirmed"&&data.dropValue=="Confirm Order"){
                        //                                     utils.snackBar(context: context, msg: "Already order confirmed", color: Colors.red);
                        //                                   }
                        //                                 });
                        //                               },
                        //                             ),
                        //                           ),
                        //                         ),
                        //                       ),
                        //                       Padding(
                        //                         padding: const EdgeInsets.all(10.0),
                        //                         child: CustomText(
                        //                           textAlign: TextAlign.left,
                        //                           text: data.quotationNo,
                        //                           size: 14,
                        //                           isCopy: true,
                        //                           colors:colorsConst.textColor,
                        //                         ),
                        //                       ),
                        //                       Tooltip(
                        //                         message: data.name.toString()=="null"?"":data.name.toString(),
                        //                         child: Padding(
                        //                           padding: const EdgeInsets.all(10.0),
                        //                           child: CustomText(
                        //                             textAlign: TextAlign.left,
                        //                             text:data.name.toString()=="null"?"":data.name.toString(),
                        //                             size: 14,
                        //                             isCopy: true,
                        //                             colors: colorsConst.textColor,
                        //                           ),
                        //                         ),
                        //                       ),
                        //                       Tooltip(
                        //                         message: data.company.toString()=="null"?"":data.company.toString(),
                        //                         child: Padding(
                        //                           padding: const EdgeInsets.all(10.0),
                        //                           child: CustomText(
                        //                             textAlign: TextAlign.left,
                        //                             text:data.company.toString()=="null"?"":data.company.toString(),
                        //                             size: 14,
                        //                             isCopy: true,
                        //                             colors: colorsConst.textColor,
                        //                           ),
                        //                         ),
                        //                       ),
                        //                       Tooltip(
                        //                         message: data.number.toString()=="null"?"":data.number.toString(),
                        //                         child: Padding(
                        //                           padding: const EdgeInsets.all(10.0),
                        //                           child: CustomText(
                        //                             textAlign: TextAlign.left,
                        //                             text: data.number.toString(),
                        //                             size: 14,
                        //                             isCopy: true,
                        //                             colors:colorsConst.textColor,
                        //                           ),
                        //                         ),
                        //                       ),
                        //                       Tooltip(
                        //                         message: data.totalProduct.toString(),
                        //                         child: Padding(
                        //                           padding: const EdgeInsets.all(10.0),
                        //                           child: CustomText(
                        //                             textAlign: TextAlign.left,
                        //                             text: data.totalProduct.toString(),
                        //                             size: 14,
                        //                             isCopy: true,
                        //                             colors:colorsConst.textColor,
                        //                           ),
                        //                         ),
                        //                       ),
                        //                       Tooltip(
                        //                         message: data.totalItem.toString(),
                        //                         child: Padding(
                        //                           padding: const EdgeInsets.all(10.0),
                        //                           child: CustomText(
                        //                             textAlign: TextAlign.left,
                        //                             text: data.totalItem.toString(),
                        //                             size: 14,
                        //                             isCopy: true,
                        //                             colors:colorsConst.textColor,
                        //                           ),
                        //                         ),
                        //                       ),
                        //                       Tooltip(
                        //                         message: productCtr.formatAmount(data.totalAmt.toString()),
                        //                         child: Padding(
                        //                           padding: const EdgeInsets.all(10.0),
                        //                           child: CustomText(
                        //                             textAlign: TextAlign.left,
                        //                             text: productCtr.formatAmount(data.totalAmt.toString()),
                        //                             size: 14,
                        //                             isCopy: true,
                        //                             colors:colorsConst.textColor,
                        //                           ),
                        //                         ),
                        //                       ),
                        //                       Padding(
                        //                         padding: const EdgeInsets.all(10.0),
                        //                         child: CustomText(
                        //                           textAlign: TextAlign.left,
                        //                           text: productCtr.fixedDateTime(data.createdTs.toString()),
                        //                           size: 14,
                        //                           isCopy: true,
                        //                           colors:colorsConst.textColor,
                        //                         ),
                        //                       ),
                        //                       Padding(
                        //                         padding: const EdgeInsets.all(10.0),
                        //                         child: CustomText(
                        //                           textAlign: TextAlign.left,
                        //                           text: data.validityDate.toString(),
                        //                           size: 14,
                        //                           isCopy: true,
                        //                           colors:colorsConst.textColor,
                        //                         ),
                        //                       ),
                        //                       Padding(
                        //                         padding: const EdgeInsets.all(10.0),
                        //                         child: InkWell(
                        //                           onTap: () {
                        //                             String url = "$getImage?path=${Uri.encodeComponent(data.invoicePdf)}";
                        //                             showPdfDialog(context, url);
                        //                           },
                        //                           child: Padding(
                        //                             padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
                        //                             child: CustomText(text: "View Quotation", isCopy: false,colors: colorsConst.primary,),
                        //                           ),
                        //                         ),
                        //                       ),
                        //                       Tooltip(
                        //                         message: data.status,
                        //                         child: Padding(
                        //                           padding: const EdgeInsets.all(10.0),
                        //                           child: CustomText(
                        //                             textAlign: TextAlign.left,
                        //                             text: data.status,
                        //                             size: 14,
                        //                             isCopy: true,
                        //                             colors:colorsConst.textColor,
                        //                           ),
                        //                         ),
                        //                       ),
                        //                       // Padding(
                        //                       //   padding: const EdgeInsets.all(10.0),
                        //                       //   child: InkWell(
                        //                       //       onTap: data.status=="Order Confirmed"?null:(){
                        //                       //         apiService.confirmOrderAPI(context,data.id.toString(),data.cusId.toString(),data.totalAmt.toString(),data.name.toString(),data.number.toString());
                        //                       //     }, child: Padding(
                        //                       //       padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
                        //                       //       child: CustomText(text: "CONFIRM ORDER", isCopy: false,isBold: true,colors: data.status=="Order Confirmed"?Colors.grey:Colors.green,),
                        //                       //     ),),
                        //                       // ),
                        //                     ]
                        //                 ),
                        //
                        //               ],
                        //             );
                        //           },
                        //         ),
                        //       );
                        //     })
                        // ),
                      ],
                    ),
                  )),
            ),
          );
        }
    );
  }
  void showPdfDialog(BuildContext context, String url) {
    final viewId = 'pdf-view-${DateTime.now().millisecondsSinceEpoch}';

    ui.platformViewRegistry.registerViewFactory(
      viewId,
          (int viewId) => html.IFrameElement()
        ..src = url
        ..style.border = 'none'
        ..width = '100%'
        ..height = '100%',
    );

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: SizedBox(
            width: 800,
            height: 600,
            child: HtmlElementView(viewType: viewId),
          ),
        );
      },
    );
  }
  // /// 🔴 HEADER CELL
  // Widget headerCell(String text, VoidCallback onTap) {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: Container(
  //       height: 50,
  //       alignment: Alignment.center,
  //       child: Obx(() {
  //         bool isActive = controllers.sortField.value == text;
  //
  //         return Row(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             CustomText(
  //               text: text,
  //               colors: Colors.white,
  //               isBold: true,
  //               isCopy: false,
  //             ),
  //             5.width,
  //             Image.asset(
  //               !isActive
  //                   ? "assets/images/arrow.png"
  //                   : controllers.sortOrderN.value == 'asc'
  //                   ? "assets/images/arrow_up.png"
  //                   : "assets/images/arrow_down.png",
  //               width: 15,
  //               height: 15,
  //               color: isActive ? Colors.white : Colors.grey,
  //             )
  //           ],
  //         );
  //       }),
  //     ),
  //   );
  // }
  //
  // /// 🟢 VALUE CELL
  // Widget valueCell(String text) {
  //   return Container(
  //     height: 45,
  //     alignment: Alignment.center,
  //     child: CustomText(
  //       text: text,
  //       isCopy: false,
  //     ),
  //   );
  // }
}
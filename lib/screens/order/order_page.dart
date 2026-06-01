import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/common/styles/decoration.dart';
import 'package:fullcomm_crm/common/utilities/utils.dart';
import 'package:fullcomm_crm/components/custom_no_data.dart';
import 'package:fullcomm_crm/models/order_model.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../common/constant/colors_constant.dart';
import '../../components/Customtext.dart';
import '../../components/custom_search_textfield.dart';
import '../../components/custom_sidebar.dart';
import '../../components/date_filter_bar.dart';
import '../../components/pagination.dart';
import '../../controller/controller.dart';
import '../../controller/product_controller.dart';
import '../../controller/reminder_controller.dart';
import 'dart:typed_data';
import 'dart:html' as html;
class OrderPage extends StatefulWidget {
  const OrderPage({super.key, });

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    Future.delayed(Duration.zero,(){
      productCtr.filterAndSortOrders(
        searchText: controllers.searchText.value.toLowerCase(),
        sortField: controllers.sortFieldCallActivity.value,
        sortOrder: controllers.sortOrderCallActivity.value,
        selectedMonth: productCtr.selectedCallMonth.value,
        selectedRange: productCtr.selectedCallRange.value,
        selectedDateFilter: productCtr.selectedCallSortBy.value,
      );
    });
  }
  List<Map<String, dynamic>> columns = [
    {
      "key": "sno",
      "title": "S.No",
      "width": 80.0,
    },
    {
      "key": "order_no",
      "title": "Order No",
      "width": 150.0,
    },
    {
      "key": "status",
      "title": "Status",
      "width": 200.0,
    },
    {
      "key": "company",
      "title": "Company Name",
      "width": 350.0,
    },
    {
      "key": "customer",
      "title": "Customer Name",
      "width": 350.0,
    },
    {
      "key": "amount",
      "title": "Total Amount",
      "width": 150.0,
    },
    {
      "key": "date",
      "title": "Order Date",
      "width": 200.0,
    },
    {
      "key": "details",
      "title": "Order Details",
      "width": 200.0,
    },
  ];
  Widget headerCell(int index, Widget child) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          alignment:
          index == 0 ? Alignment.center : Alignment.centerLeft,
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
                columns[index]["width"] += details.delta.dx;

                if (columns[index]["width"] < 60) {
                  columns[index]["width"] = 60.0;
                }
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
  final ScrollController _controller = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    _horizontalController.dispose();
    super.dispose();
  }
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
    final Map<int, TableColumnWidth> tableWidthMap = {
      for (int i = 0; i < columns.length; i++)
        i: FixedColumnWidth(columns[i]["width"])
    };

    double totalTableWidth = columns.fold(
      0.0,
          (sum, item) => sum + item["width"],
    );
    return SelectionArea(
      child: Scaffold(
        body: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SideBar(),
            Obx(()=>Container(
              width:controllers.isLeftOpen.value?MediaQuery.of(context).size.width - 150:MediaQuery.of(context).size.width - 60,
              height: MediaQuery.of(context).size.height,
              alignment: Alignment.center,
              padding: EdgeInsets.fromLTRB(20, 5, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomText(
                            text: "Orders",
                            colors: colorsConst.textColor,
                            size: 20,
                            isBold: true,
                            isCopy: true,
                          ),
                          10.height,
                          CustomText(
                            text: "View all of your Orders Details",
                            colors: colorsConst.textColor,
                            size: 14,
                            isCopy: true,
                          ),
                        ],
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
                        hintText: "Search Customer Name",
                        onChanged: (value) {
                          controllers.searchText.value = value.toString().trim();
                          setState(() {
                            final suggestions=productCtr.ordersList2.where(
                                    (user){
                                  final customerName = user.customerName.toString().toLowerCase();
                                  final companyName = user.companyName.toString().toLowerCase();
                                  final customerNo = user.totalAmt.toString().toLowerCase();
                                  final input = value.toString().toLowerCase().trim();
                                  return customerName.contains(input) || customerNo.contains(input)|| companyName.contains(input);
                                }).toList();
                            productCtr.ordersList.value=suggestions;
                          });
                        },
                      ),
                      DateFilterBar(
                        selectedSortBy: productCtr.selectedCallSortBy,
                        selectedRange: productCtr.selectedCallRange,
                        selectedMonth: productCtr.selectedCallMonth,
                        focusNode: _focusNode,
                        onDaysSelected: () {
                          productCtr.filterAndSortOrders(
                            searchText: controllers.searchText.value.toLowerCase(),
                            sortField: controllers.sortFieldCallActivity.value,
                            sortOrder: controllers.sortOrderCallActivity.value,
                            selectedMonth: productCtr.selectedCallMonth.value,
                            selectedRange: productCtr.selectedCallRange.value,
                            selectedDateFilter: productCtr.selectedCallSortBy.value,
                          );
                        },
                        onSelectMonth: () {
                          remController.selectMonth(
                            context,
                            productCtr.selectedCallSortBy,
                            productCtr.selectedCallMonth,
                                () {
                              productCtr.filterAndSortOrders(
                                searchText: controllers.searchText.value.toLowerCase(),
                                sortField: controllers.sortFieldCallActivity.value,
                                sortOrder: controllers.sortOrderCallActivity.value,
                                selectedMonth: productCtr.selectedCallMonth.value,
                                selectedRange: productCtr.selectedCallRange.value,
                                selectedDateFilter: productCtr.selectedCallSortBy.value,
                              );
                            },
                          );
                        },
                        onSelectDateRange: (ctx) {
                          remController.showDatePickerDialog(ctx, (pickedRange) {
                            productCtr.selectedCallRange.value = pickedRange;
                            productCtr.filterAndSortOrders(
                              searchText: controllers.searchText.value.toLowerCase(),
                              sortField: controllers.sortFieldCallActivity.value,
                              sortOrder: controllers.sortOrderCallActivity.value,
                              selectedMonth: productCtr.selectedCallMonth.value,
                              selectedRange: productCtr.selectedCallRange.value,
                              selectedDateFilter: productCtr.selectedCallSortBy.value,
                            );
                          });
                        },
                      )
                    ],
                  ),
                  10.height,

                  Expanded(
                    child: KeyboardListener(
                      focusNode: _focusNode,
                      autofocus: true,
                      onKeyEvent: _handleKeyEvent,
                      child: Scrollbar(
                        controller: _horizontalController,
                        thumbVisibility: true,
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (scrollNotification) {
                            _focusNode.requestFocus();
                            return false;
                          },
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
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(5),
                                            topRight: Radius.circular(5),
                                          ),
                                        ),
                                        children: List.generate(columns.length, (index) {

                                          final column = columns[index];
                                          return DragTarget<int>(

                                            onWillAccept: (fromIndex) => fromIndex != index,

                                            onAccept: (fromIndex) {

                                              if (fromIndex == index) return;

                                              setState(() {

                                                final item = columns.removeAt(fromIndex);

                                                columns.insert(index, item);

                                              });
                                            },

                                            builder: (context, candidateData, rejectedData) {

                                              return LongPressDraggable<int>(

                                                data: index,

                                                feedback: Material(
                                                  child: Container(
                                                    width: columns[index]["width"],
                                                    padding: const EdgeInsets.all(10),
                                                    color: colorsConst.primary,
                                                    child: Text(
                                                      columns[index]["title"],
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                childWhenDragging: Opacity(
                                                  opacity: 0.3,
                                                  child: headerCell(
                                                    index,
                                                    Row(
                                                      children: [

                                                        Expanded(
                                                          child: CustomText(
                                                            textAlign: TextAlign.left,
                                                            text: column["title"],
                                                            size: 15,
                                                            isBold: true,
                                                            isCopy: true,
                                                            colors: Colors.white,
                                                          ),
                                                        ),

                                                        GestureDetector(
                                                          onTap: () {

                                                            String sortKey = "";

                                                            switch (column["key"]) {
                                                              case "order_no":
                                                                sortKey = "number";
                                                                break;

                                                              case "status":
                                                                sortKey = "status";
                                                                break;

                                                              case "company":
                                                                sortKey = "company";
                                                                break;

                                                              case "customer":
                                                                sortKey = "name";
                                                                break;

                                                              case "amount":
                                                                sortKey = "amt";
                                                                break;

                                                              case "date":
                                                                sortKey = "date";
                                                                break;
                                                            }

                                                            if (sortKey.isNotEmpty) {

                                                              if (controllers.sortFieldCallActivity.value ==
                                                                  sortKey &&
                                                                  controllers.sortOrderCallActivity.value ==
                                                                      'asc') {
                                                                controllers.sortOrderCallActivity.value =
                                                                'desc';
                                                              } else {
                                                                controllers.sortOrderCallActivity.value =
                                                                'asc';
                                                              }

                                                              controllers.sortFieldCallActivity.value =
                                                                  sortKey;

                                                              productCtr.filterAndSortOrders(
                                                                searchText: controllers.searchText.value
                                                                    .toLowerCase(),
                                                                sortField: controllers
                                                                    .sortFieldCallActivity.value,
                                                                sortOrder: controllers
                                                                    .sortOrderCallActivity.value,
                                                                selectedMonth:
                                                                productCtr.selectedCallMonth.value,
                                                                selectedRange:
                                                                productCtr.selectedCallRange.value,
                                                                selectedDateFilter:
                                                                productCtr.selectedCallSortBy.value,
                                                              );
                                                            }
                                                          },
                                                          child: Obx(
                                                                () => Image.asset(
                                                              controllers
                                                                  .sortFieldCallActivity.value.isEmpty
                                                                  ? "assets/images/arrow.png"
                                                                  : controllers.sortOrderCallActivity
                                                                  .value ==
                                                                  'asc'
                                                                  ? "assets/images/arrow_up.png"
                                                                  : "assets/images/arrow_down.png",
                                                              width: 15,
                                                              height: 15,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),

                                                child: headerCell(
                                                  index,
                                                  Row(
                                                    children: [

                                                      Expanded(
                                                        child: CustomText(
                                                          textAlign: TextAlign.left,
                                                          text: column["title"],
                                                          size: 15,
                                                          isBold: true,
                                                          isCopy: true,
                                                          colors: Colors.white,
                                                        ),
                                                      ),

                                                      GestureDetector(
                                                        onTap: () {

                                                          String sortKey = "";

                                                          switch (column["key"]) {
                                                            case "sno":
                                                              sortKey = "number";
                                                              break;

                                                            case "order_no":
                                                              sortKey = "number";
                                                              break;

                                                            case "status":
                                                              sortKey = "status";
                                                              break;

                                                            case "company":
                                                              sortKey = "company";
                                                              break;

                                                            case "customer":
                                                              sortKey = "name";
                                                              break;

                                                            case "amount":
                                                              sortKey = "amt";
                                                              break;

                                                            case "date":
                                                              sortKey = "date";
                                                              break;
                                                          }

                                                          if (sortKey.isNotEmpty) {

                                                            if (controllers.sortFieldCallActivity.value ==
                                                                sortKey &&
                                                                controllers.sortOrderCallActivity.value ==
                                                                    'asc') {
                                                              controllers.sortOrderCallActivity.value =
                                                              'desc';
                                                            } else {
                                                              controllers.sortOrderCallActivity.value =
                                                              'asc';
                                                            }

                                                            controllers.sortFieldCallActivity.value =
                                                                sortKey;

                                                            productCtr.filterAndSortOrders(
                                                              searchText: controllers.searchText.value
                                                                  .toLowerCase(),
                                                              sortField: controllers
                                                                  .sortFieldCallActivity.value,
                                                              sortOrder: controllers
                                                                  .sortOrderCallActivity.value,
                                                              selectedMonth:
                                                              productCtr.selectedCallMonth.value,
                                                              selectedRange:
                                                              productCtr.selectedCallRange.value,
                                                              selectedDateFilter:
                                                              productCtr.selectedCallSortBy.value,
                                                            );
                                                          }
                                                        },
                                                        child: Obx(
                                                              () => Image.asset(
                                                            controllers
                                                                .sortFieldCallActivity.value.isEmpty
                                                                ? "assets/images/arrow.png"
                                                                : controllers.sortOrderCallActivity
                                                                .value ==
                                                                'asc'
                                                                ? "assets/images/arrow_up.png"
                                                                : "assets/images/arrow_down.png",
                                                            width: 15,
                                                            height: 15,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        }),
                                      ),
                                    ],
                                  ),
                                  // BODY LIST
                                  Expanded(
                                    child: Obx(() {
                                      if (productCtr.paginatedOrdersItems.isEmpty) {
                                        return Center(
                                            child: SizedBox(
                                              height: 500,width: 500,
                                                child: CustomNoData()));
                                      }
                                      return ListView.builder(
                                        controller: _controller,
                                        itemCount: productCtr.paginatedOrdersItems
                                            .length,
                                        itemBuilder: (context, index) {
                                          var data = productCtr.paginatedOrdersItems[index];
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
                                                  color: index % 2 == 0
                                                      ? Colors.white
                                                      : colorsConst.backgroundColor,
                                                ),

                                                children: List.generate(columns.length, (colIndex) {

                                                  final key = columns[colIndex]["key"];

                                                  switch (key) {

                                                    case "sno":
                                                      return Padding(
                                                          padding: const EdgeInsets.all(10.0),
                                                          child: CustomText(
                                                          textAlign: TextAlign.left,
                                                          text: (index+1).toString(),
                                                          size: 14,
                                                          isCopy: true,
                                                          colors: colorsConst.textColor,
                                                          ),
                                                        );
                                                      case "order_no":
                                                      return Tooltip(
                                                        message: data.orderId.toString() == "null"
                                                            ? ""
                                                            : data.orderId.toString(),
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(10.0),
                                                          child: CustomText(
                                                            textAlign: TextAlign.left,
                                                            text: data.orderId.toString() == "null"
                                                                ? ""
                                                                : data.orderId.toString(),
                                                            size: 14,
                                                            isCopy: true,
                                                            colors: colorsConst.textColor,
                                                          ),
                                                        ),
                                                      );

                                                    case "status":
                                                      return Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign.left,
                                                          text: data.status.toString(),
                                                          size: 14,
                                                          isCopy: true,
                                                          colors: data.status.toString() == "Completed"
                                                              ? Colors.green
                                                              : colorsConst.textColor,
                                                        ),
                                                      );

                                                    case "company":
                                                      return Tooltip(
                                                        message: data.companyName.toString(),
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(10.0),
                                                          child: CustomText(
                                                            textAlign: TextAlign.left,
                                                            text: data.companyName.toString(),
                                                            size: 14,
                                                            isCopy: true,
                                                            colors: colorsConst.textColor,
                                                          ),
                                                        ),
                                                      );

                                                    case "customer":
                                                      return Tooltip(
                                                        message: data.customerName.toString(),
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(10.0),
                                                          child: CustomText(
                                                            textAlign: TextAlign.left,
                                                            text: data.customerName.toString(),
                                                            size: 14,
                                                            isCopy: true,
                                                            colors: colorsConst.textColor,
                                                          ),
                                                        ),
                                                      );

                                                    case "amount":
                                                      return Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign.left,
                                                          text: productCtr.formatAmount(
                                                            data.totalAmt.toString(),
                                                          ),
                                                          size: 14,
                                                          isCopy: true,
                                                          colors: colorsConst.textColor,
                                                        ),
                                                      );

                                                    case "date":
                                                      return Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign.left,
                                                          text: productCtr.fixedDateTime(
                                                            data.createdTs.toString(),
                                                          ),
                                                          size: 14,
                                                          isCopy: true,
                                                          colors: colorsConst.textColor,
                                                        ),
                                                      );

                                                    case "details":
                                                      return InkWell(
                                                        onTap: () {
                                                          showDialog(
                                                            context: context,
                                                            builder: (_) => OrderInvoiceDialog(order: data),
                                                          );
                                                        },
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(10.0),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Icon(
                                                                Icons.print,
                                                                color: colorsConst.primary,
                                                              ),
                                                              5.width,
                                                              CustomText(
                                                                text: "View Order",
                                                                isCopy: false,
                                                                colors: colorsConst.primary,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );

                                                    default:
                                                      return const SizedBox();
                                                  }
                                                }),
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
                  ),
                  20.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      PaginationWidget(
                        currentPage: productCtr.currentOrdersPage,
                        totalPages:(productCtr.paginatedOrdersItems.length / productCtr.itemsOrdersPerPage).ceil(),
                        onPageChanged: (page) {
                          setState(() {
                            productCtr.currentOrdersPage = page;
                          });
                        },
                      ),
                    ],
                  ),
                  20.height,
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget valueCell(String text) {
    return Container(
      height: 45,
      alignment: Alignment.center,
      child: CustomText(
        text:text,isCopy: false,
      ),
    );
  }
}


class OrderInvoiceDialog extends StatelessWidget {
  final Order order;

  const OrderInvoiceDialog({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final products = order.products ?? [];

    return Dialog(
      child: Container(
        width: 800,
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap:(){
                      Get.back();
                    },
                      child: Icon(Icons.clear,color: Colors.grey,)),
                ],
              ),10.height,
              Center(
                child: CustomText(
                  text: "Order Preview",
                  size: 20,
                  isBold: true,
                  isCopy: false,
                ),
              ),
              10.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                      onTap:(){
                        printInvoice(order);
                      },
                      child: Container(
                        height: 35,width: 35,
                          decoration: customDecoration.baseBackgroundDecoration(
                            color: colorsConst.primary,radius: 10
                          ),
                          child: Icon(Icons.print,color: Colors.white,))),20.width,
                  InkWell(
                      onTap: () {
                        downloadInvoice(order);
                      },
                      child: Container(
                          height: 35,width: 35,
                          decoration: customDecoration.baseBackgroundDecoration(
                            color: colorsConst.primary,radius: 10
                          ),
                          child: Icon(Icons.download,color: Colors.white,))),
                ],
              ),10.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  topItem("Invoice No", order.orderId.toString()),
                  topItem("Order date", productCtr.formatDateTime(order.createdTs)),
                  topItem("Mobile Number", order.mobile.toString()=="null"?"":order.mobile.toString()),
                  topItem("Customer Name", order.customerName.toString()=="null"?"N/A":order.customerName.toString()),
                ],
              ),
              30.height,
              CustomText(
                text:"Order Item",size: 22,isCopy: false,isBold: true,
              ),
              15.height,
              /// 🟢 TABLE
              Table(
                border: TableBorder.all(color: Colors.grey.shade300),
                columnWidths: const {
                  0: FixedColumnWidth(60),
                  1: FlexColumnWidth(),
                  2: FixedColumnWidth(80),
                  3: FixedColumnWidth(80),
                  4: FixedColumnWidth(100),
                },
                children: [

                  /// HEADER
                  TableRow(
                    decoration: BoxDecoration(color: colorsConst.primary),
                    children: [
                      header("S.No"),
                      header("Product Name"),
                      header("Qty"),
                      header("Price"),
                      header("Total"),
                    ],
                  ),

                  /// DATA
                  ...List.generate(products.length, (index) {
                    final p = products[index];

                    return TableRow(
                      children: [
                        cell("${index + 1}"),
                        cell(p.name ?? ""),
                        cell(p.qty.toString()),
                        cell(productCtr.formatAmount(p.price)),
                        cell(productCtr.formatAmount(p.amount)),
                      ],
                    );
                  }),
                ],
              ),
              20.height,
              /// TOTAL
              Align(
                alignment: Alignment.centerRight,
                child: CustomText(
                  text:"Total: ${productCtr.formatAmount(order.totalAmt)}",size: 18,isCopy: false,isBold: true,),
                ),
              10.height,

              /// 🔴 TOTAL ORDER
              CustomText(
                text: "Total Order",
                size: 20,
                isBold: true,
                isCopy: false,
              ),

              10.height,

              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    totalRow("Sub Total", productCtr.formatAmount(order.subtotal)),
                    divider(),
                    totalRow("Delivery Charge", "₹0"),
                    divider(),
                    totalRow("Net Amount", productCtr.formatAmount(order.totalAmt), isBold: true),
                  ],
                ),
              ),

              10.height,

              /// 🟢 SHIPPING & BILLING
              CustomText(
                text: "Shipping and Order Details",
                size: 20,
                isBold: true,
                isCopy: false,
              ),

              10.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: "Shipping Address",
                        isBold: true,
                        isCopy: false,
                      ),10.height,
                      CustomText(
                        text: order.address.isNotEmpty ? order.address : "-",
                        isCopy: false,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: "Order Status",
                        isBold: true,
                        isCopy: false,
                      ),10.height,
                      CustomText(
                        text: order.status,
                        isCopy: false,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  Future<void> downloadInvoice(Order data) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 20),

                /// HEADER
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      flex: 6,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            "Hapi Apps",
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            "7/38, East Street, Kulaiyankarisal\nThoothukudi, Tamil Nadu, 628103",
                          ),
                          pw.SizedBox(height: 5),
                          pw.Text("Email : info@hapiapps.com"),
                          pw.Text("Mobile : +91 9677 281 724"),
                          pw.Text("GSTIN : "),
                        ],
                      ),
                    ),

                    pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(),
                        borderRadius: pw.BorderRadius.circular(5),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          rowText("Invoice No :", data.orderId),
                          rowText(
                            "Invoice Date :",
                            data.createdTs.split(" ").first,
                          ),
                          rowText("Order No :", data.id),
                        ],
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 15),

                /// CUSTOMER
                pw.Text("M/S : ${data.customerName}"),
                pw.Text("Address : ${data.address}"),

                pw.SizedBox(height: 10),

                pw.Text("PARTY GSTIN : "),

                pw.SizedBox(height: 10),

                /// PRODUCTS TABLE
                pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(1),
                    1: const pw.FlexColumnWidth(4),
                    2: const pw.FlexColumnWidth(1),
                    3: const pw.FlexColumnWidth(2),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        tableCell("S. No.", isHeader: true),
                        tableCell("Particulars", isHeader: true),
                        tableCell("Qty.", isHeader: true),
                        tableCell("Amount INR", isHeader: true),
                      ],
                    ),

                    ...List.generate(data.products.length, (index) {
                      final p = data.products[index];

                      return pw.TableRow(
                        children: [
                          tableCell("${index + 1}"),
                          tableCell(p.name),
                          tableCell("${p.qty}"),
                          tableCell("Rs. ${p.price}"),
                        ],
                      );
                    }),
                  ],
                ),

                pw.SizedBox(height: 10),

                /// BOTTOM SECTION
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      flex: 6,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            "Amount in Words: INR ${productCtr.numberToWords(int.parse(data.totalAmt))} Only",
                          ),
                          pw.SizedBox(height: 10),
                          pw.Text("UPI ID:"),
                          pw.Text("Bank Account No:"),
                          pw.Text("Name: Hapi Apps"),
                          pw.Text("IFSC:"),
                          pw.Text("Kulaiyankarisal Branch"),
                        ],
                      ),
                    ),

                    pw.Expanded(
                      flex: 4,
                      child: pw.Container(
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(),
                        ),
                        child: pw.Column(
                          children: [
                            totalRows("Total Before Tax", data.totalAmt),
                            totalRows("SGST 9%", "0"),
                            totalRows("CGST 9%", "0"),
                            totalRows("Round Off", "0"),
                            totalRows(
                              "Grand Total",
                              data.totalAmt,
                              isBold: true,
                            ),
                            pw.SizedBox(height: 20),
                            pw.Text("Signature"),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    /// SAVE PDF
    final Uint8List pdfBytes = await pdf.save();

    /// DOWNLOAD PDF IN WEB
    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);

    html.AnchorElement(href: url)
      ..setAttribute(
        "download",
        "Invoice_${data.orderId}.pdf",
      )
      ..click();

    html.Url.revokeObjectUrl(url);
  }
  Future<void> printInvoice(Order data) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 20),

                /// 🟢 HEADER ROW
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [

                    /// LEFT SIDE (Company)
                    pw.Expanded(
                      flex: 6,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("Hapi Apps",
                              style: pw.TextStyle(
                                  fontSize: 18,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.Text(
                              "7/38, East Street, Kulaiyankarisal\nThoothukudi, Tamil Nadu, 628103"),
                          pw.SizedBox(height: 5),
                          pw.Text("Email : info@hapiapps.com"),
                          pw.Text("Mobile : +91 9677 281 724"),
                          pw.Text("GSTIN : "),
                        ],
                      ),
                    ),

                    /// RIGHT BOX
                    pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(),
                        borderRadius: pw.BorderRadius.circular(5),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          rowText("InvoiceNo:", data.orderId),
                          rowText("InvoiceDate:",
                              data.createdTs.split(" ").first),
                          rowText("OrderNo:", data.id),
                        ],
                      ),
                    )
                  ],
                ),

                pw.SizedBox(height: 15),

                /// CUSTOMER
                pw.Text("M/S : ${data.customerName}"),
                pw.Text("Address : ${data.address}"),

                pw.SizedBox(height: 10),

                pw.Text("PARTY GSTIN : "),

                pw.SizedBox(height: 10),

                /// 🔵 TABLE
                pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(1),
                    1: const pw.FlexColumnWidth(4),
                    2: const pw.FlexColumnWidth(1),
                    3: const pw.FlexColumnWidth(2),
                  },
                  children: [

                    /// HEADER
                    pw.TableRow(
                      children: [
                        tableCell("S. No.", isHeader: true),
                        tableCell("Particulars", isHeader: true),
                        tableCell("Qty.", isHeader: true),
                        tableCell("Amount INR", isHeader: true),
                      ],
                    ),

                    /// DATA
                    ...List.generate(data.products.length, (index) {
                      final p = data.products[index];

                      return pw.TableRow(
                        children: [
                          tableCell("${index + 1}"),
                          tableCell(p.name),
                          tableCell(p.qty.toString()),
                          tableCell("Rs. ${p.price}"),
                        ],
                      );
                    }),
                  ],
                ),

                pw.SizedBox(height: 10),

                /// 🔶 BOTTOM SECTION
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [

                    /// LEFT SIDE
                    pw.Expanded(
                      flex: 6,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                              "Amount in Words: INR ${productCtr.numberToWords(int.parse(data.totalAmt))} Only"),
                          pw.SizedBox(height: 10),
                          pw.Text("UPI ID:"),
                          pw.Text("Bank Account No:"),
                          pw.Text("Name: Hapi Apps"),
                          pw.Text("IFSC: ..."),
                          pw.Text("Kulaiyankarisal branch"),
                        ],
                      ),
                    ),

                    /// RIGHT SIDE (TOTAL BOX)
                    pw.Expanded(
                      flex: 4,
                      child: pw.Container(
                        decoration:
                        pw.BoxDecoration(border: pw.Border.all()),
                        child: pw.Column(
                          children: [
                            totalRows("Total Before Tax SGST", "15,000"),
                            totalRows("CGST 9%", "1,350"),
                            totalRows("Round Off 9%", "1,350"),
                            totalRows("Total After", "1,350"),
                            totalRows("Tax for HapiApps", data.totalAmt,
                                isBold: true),
                            pw.SizedBox(height: 20),
                            pw.Text("Signature"),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }
  pw.Widget tableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight:
          isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
  pw.Widget rowText(String title, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.Text(title),
          pw.SizedBox(width: 5),
          pw.Text(value),
        ],
      ),
    );
  }
  pw.Widget totalRows(String title, String value,{bool isBold = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      decoration: pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide()),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(title,
              style: pw.TextStyle(
                  fontWeight: isBold
                      ? pw.FontWeight.bold
                      : pw.FontWeight.normal)),
          pw.Text(value,
              style: pw.TextStyle(
                  fontWeight: isBold
                      ? pw.FontWeight.bold
                      : pw.FontWeight.normal)),
        ],
      ),
    );
  }
  Widget totalRow(String title, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            text: title,
            isBold: isBold,
            isCopy: false,
          ),
          CustomText(
            text: value,
            isBold: isBold,
            isCopy: false,
          ),
        ],
      ),
    );
  }

  Widget divider() {
    return Divider(height: 1, color: Colors.grey.shade300);
  }
  /// 🔧 Widgets
  Widget topItem(String title, String value) {
    return Column(
      children: [
        CustomText(text:title, isCopy: false,isBold: true,),
        const SizedBox(height: 5),
        CustomText(text: value,isCopy: false,),
      ],
    );
  }

  Widget header(String text) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: CustomText(
        text:text,isCopy: false,isBold: true,colors: Colors.white,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget cell(String text) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: CustomText(text:text, textAlign: TextAlign.center,isCopy: false,),
    );
  }

  Widget imageCell() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Icon(Icons.image, size: 40), // replace with NetworkImage if needed
    );
  }
}

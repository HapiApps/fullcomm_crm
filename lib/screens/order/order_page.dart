import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/common/styles/decoration.dart';
import 'package:fullcomm_crm/common/utilities/utils.dart';
import 'package:fullcomm_crm/components/custom_loading_button.dart';
import 'package:fullcomm_crm/models/order_model.dart';
import 'package:fullcomm_crm/screens/invoice/invoice.dart';
import 'package:fullcomm_crm/screens/order/place_order.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:screenshot/screenshot.dart';
import '../../common/constant/colors_constant.dart';
import '../../components/Customtext.dart';
import '../../components/custom_search_textfield.dart';
import '../../components/custom_sidebar.dart';
import '../../components/keyboard_search.dart';
import '../../controller/controller.dart';
import '../../controller/product_controller.dart';
import '../../models/all_customers_obj.dart';
import '../../models/product_model.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key, });

  @override
  State<OrderPage> createState() => _OrderPageState();
}

// class _OrderPageState extends State<OrderPage> {
//   final ScrollController _controller = ScrollController();
//   late FocusNode _focusNode;
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _focusNode = FocusNode();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _focusNode.requestFocus();
//       // productCtr.isSelectAll.value=false;
//     });
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     controllers.totalProspectPages.value=(productCtr.ordersList.length / controllers.itemsPerPage).ceil();
//     var weWidth=MediaQuery.of(context).size.width;
//     return SelectionArea(
//       child: Scaffold(
//         body: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             SideBar(),
//             Obx(() => Container(
//               width:controllers.isLeftOpen.value?MediaQuery.of(context).size.width - 150:MediaQuery.of(context).size.width - 60,
//               height: MediaQuery.of(context).size.height,
//               alignment: Alignment.center,
//               padding: EdgeInsets.fromLTRB(20, 5, 20, 16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Header Section
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               InkWell(
//                                 onTap:(){
//                                   Get.back();
//                                 },
//                                   child: Icon(Icons.arrow_back)),10.width,
//                               CustomText(
//                                 text: "Orders",
//                                 colors: colorsConst.textColor,
//                                 size: 25,
//                                 isBold: true,
//                                 isCopy: true,
//                               ),
//                             ],
//                           ),
//                           10.height,
//                           CustomText(
//                             text: "View all of your Orders Details\n\n\n",
//                             colors: colorsConst.textColor,
//                             size: 14,
//                             isCopy: true,
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                   Obx(() {
//                     if (productCtr.ordersList.isEmpty) {
//                       return const Center(
//                         child: CustomText(
//                           text: "No Orders Found",
//                           isCopy: false,
//                         ),
//                       );
//                     }
//                     return Column(
//                       children: [
//                         /// 🔴 HEADER (Fixed)
//                         Table(
//                           border: TableBorder.all(color: Colors.grey.shade300),
//                           columnWidths: {
//                             0: FixedColumnWidth(weWidth / 8),
//                             1: FixedColumnWidth(weWidth / 2.55),
//                             2: FixedColumnWidth(weWidth / 8),
//                             3: FixedColumnWidth(weWidth / 7),
//                             4: FixedColumnWidth(weWidth / 9)
//                           },
//                           children: [
//                             TableRow(
//                               decoration: BoxDecoration(
//                                 color: colorsConst.primary,
//                               ),
//                               children: [
//                                 headerCell("Order No"),
//                                 headerCell("Customer"),
//                                 headerCell("Total Amount"),
//                                 headerCell("Order Date"),
//                                 headerCell("Invoice"),
//                               ],
//                             ),
//                           ],
//                         ),
//
//                         /// 🟢 BODY (Scrollable மட்டும்)
//                         SizedBox(
//                           height: MediaQuery.of(context).size.height*0.6, // 👈 scroll area
//                           child: Obx(() {
//                             if (productCtr.ordersList.isEmpty) {
//                               return const Center(
//                                 child: CustomText(
//                                   text: "No Orders Found",
//                                   isCopy: false,
//                                 ),
//                               );
//                             }
//
//                             return SingleChildScrollView(
//                               child: Table(
//                                 border: TableBorder.all(color: Colors.grey.shade300),
//                                 columnWidths: {
//                                   0: FixedColumnWidth(weWidth / 8),
//                                   1: FixedColumnWidth(weWidth / 2.55),
//                                   2: FixedColumnWidth(weWidth / 8),
//                                   3: FixedColumnWidth(weWidth / 7),
//                                   4: FixedColumnWidth(weWidth / 9)
//                                 },
//                                 children: List.generate(productCtr.ordersList.length, (index) {
//                                   final e = productCtr.ordersList[index];
//                                   return TableRow(
//                                     decoration: BoxDecoration(
//                                       color: index % 2 == 0
//                                           ? Colors.white
//                                           : Colors.grey.shade50,
//                                     ),
//                                     children: [
//                                       valueCell(e.orderId.toString()),
//                                       valueCell(e.customerName.toString()),
//                                       valueCell(productCtr.formatAmount(e.totalAmt.toString())),
//                                       valueCell(productCtr.formatDateTime(e.createdTs.toString())),
//                                       SizedBox(
//                                         height: 50,
//                                         child: Padding(
//                                           padding: const EdgeInsets.all(8.0),
//                                           child: ElevatedButton(
//                                               onPressed: (){
//                                                 showDialog(
//                                                   context: context,
//                                                   builder: (_) => OrderInvoiceDialog(order: e),
//                                                 );
//                                               },
//                                               child: Row(
//                                                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                                                 children: [
//                                                   Icon(Icons.print,color: Colors.white,),
//                                                   CustomText(text: "Invoice", isCopy: false),
//                                                 ],
//                                               )),
//                                         ),
//                                       ),
//                                     ],
//                                   );
//                                 }),
//                               ),
//                             );
//                           }),
//                         ),
//                       ],
//                     );
//                   }),
//                   productCtr.ordersList.isNotEmpty? Obx(() {
//                     int totalPages = controllers.totalProspectPages.value == 0 ? 1 : controllers.totalProspectPages.value;
//                     final currentPage = controllers.currentProspectPage.value;
//                     return Row(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         utils.paginationButton(Icons.chevron_left, currentPage > 1, () {
//                           _focusNode.requestFocus();
//                           controllers.currentProspectPage.value--;
//                           controllers.changeOrderPage(productCtr.ordersList,productCtr.ordersList2);
//                           print("controllers.currentProspectPage.value --- ${controllers.currentProspectPage.value}");
//                         }),
//                         ...utils.buildPagination(totalPages, currentPage),
//                         utils.paginationButton(Icons.chevron_right, currentPage < totalPages, () {
//                           controllers.currentProspectPage.value++;
//                           _focusNode.requestFocus();
//                           controllers.changeOrderPage(productCtr.ordersList,productCtr.ordersList2);
//                           print("controllers.currentProspectPage.value +++ ${controllers.currentProspectPage.value}");
//                         }),
//                       ],
//                     );
//                   }):0.height,
//                   20.height,
//                 ],
//               ),
//             ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//   Widget headerText(String text) {
//     return CustomText(
//       text: text,
//       isBold: true,size: 16,
//       colors: Colors.white, isCopy: false,
//     );
//   }
//   Widget headerCell(String text) {
//     return Container(
//       height: 60, // 👈 heading height increase
//       alignment: Alignment.centerLeft,
//       child: Center(
//         child: CustomText(
//           text: text,size: 16,
//           isCopy: false,
//           isBold: true,
//           colors: Colors.white,
//         ),
//       ),
//     );
//   }
//   Widget valueCell(String text) {
//     return Container(
//       height: 50, // 👈 heading height increase
//       alignment: Alignment.centerLeft,
//       child: Center(
//         child: CustomText(
//           text: text,size: 16,
//           isCopy: false,
//         ),
//       ),
//     );
//   }
// }


class _OrderPageState extends State<OrderPage> {
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();
  late FocusNode _focusNode;
  final ScrollController _headerHorizontalController = ScrollController();
  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      controllers.totalProspectPages.value=(productCtr.ordersList.length / controllers.itemsPerPage).ceil();
    });
    /// 🔥 SYNC HEADER + BODY
    _horizontalController.addListener(() {
      if (_headerHorizontalController.hasClients &&
          _headerHorizontalController.offset != _horizontalController.offset) {
        _headerHorizontalController.jumpTo(_horizontalController.offset);
      }
    });

  }

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    _headerHorizontalController.dispose(); // ✅ add
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var weWidth = MediaQuery.of(context).size.width;

    return SelectionArea(
      child: Scaffold(
        body: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SideBar(),
            Container(
              width:controllers.isLeftOpen.value?MediaQuery.of(context).size.width - 150:MediaQuery.of(context).size.width - 60,
              height: MediaQuery.of(context).size.height,
              alignment: Alignment.center,
              padding: EdgeInsets.fromLTRB(20, 5, 20, 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              InkWell(
                                  onTap:(){
                                    Get.back();
                                  },
                                  child: Icon(Icons.arrow_back)),10.width,
                              CustomText(
                                text: "Orders",
                                colors: colorsConst.textColor,
                                size: 25,
                                isBold: true,
                                isCopy: true,
                              ),
                            ],
                          ),
                          10.height,
                          CustomText(
                            text: "View all of your Orders Details\n\n\n",
                            colors: colorsConst.textColor,
                            size: 14,
                            isCopy: true,
                          ),
                        ],
                      ),
                    ],
                  ),
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
                                  final input = value.toString().toLowerCase().trim();
                                  return customerName.contains(input);
                                }).toList();
                            productCtr.ordersList.value=suggestions;
                          });
                        },
                      ),
                      Obx(()=>productCtr.idsList.isNotEmpty?
                      Row(
                        children: [
                          CustomText(text: "Selected count: ${productCtr.idsList.value.length}", isCopy: false),15.width,
                          InkWell(
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            onTap: (){
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    content: CustomText(
                                      text: "Are you sure delete this products?",
                                      size: 16,
                                      isBold: true,
                                      isCopy: false,
                                      colors: colorsConst.textColor,
                                    ),
                                    actions: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(color: colorsConst.primary),
                                                color: Colors.white),
                                            width: 80,
                                            height: 25,
                                            child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  shape: const RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.zero,
                                                  ),
                                                  backgroundColor: Colors.white,
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: CustomText(
                                                  text: "Cancel",
                                                  isCopy: false,
                                                  colors: colorsConst.primary,
                                                  size: 14,
                                                )),
                                          ),
                                          10.width,
                                          CustomLoadingButton(
                                            callback: ()async{
                                              productCtr.deleteProduct(context);
                                            },
                                            height: 35,
                                            isLoading: true,
                                            backgroundColor: colorsConst.primary,
                                            radius: 2,
                                            width: 80,
                                            controller: controllers.productCtr,
                                            isImage: false,
                                            text: "Delete",
                                            textColor: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Container(
                              height: 40,
                              width: 100,
                              decoration: BoxDecoration(
                                color: colorsConst.secondary,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                  ),
                                ],
                              ),
                              child:  Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset("assets/images/action_delete.png"),
                                  10.width,
                                  CustomText(
                                    text: "Delete",
                                    colors: colorsConst.textColor,
                                    size: 14,
                                    isBold: true,
                                    isCopy: false,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ):0.width)
                    ],
                  ),
                  10.height,
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _focusNode.requestFocus(); // 👈 keyboard activate
                      },
                      child: RawKeyboardListener(
                        focusNode: _focusNode,
                        autofocus: true,
                        onKey: (event) {
                          if (event is! RawKeyDownEvent) return;

                          if (!_verticalController.hasClients ||
                              !_horizontalController.hasClients) return;

                          const double scrollAmount = 120;

                          final maxV = _verticalController.position.maxScrollExtent;
                          final minV = _verticalController.position.minScrollExtent;

                          final maxH = _horizontalController.position.maxScrollExtent;
                          final minH = _horizontalController.position.minScrollExtent;

                          /// ⬇ DOWN
                          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                            final newOffset =
                            (_verticalController.offset + scrollAmount).clamp(minV, maxV);

                            _verticalController.animateTo(
                              newOffset,
                              duration: Duration(milliseconds: 200),
                              curve: Curves.easeOut,
                            );
                          }

                          /// ⬆ UP
                          if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                            final newOffset =
                            (_verticalController.offset - scrollAmount).clamp(minV, maxV);

                            _verticalController.animateTo(
                              newOffset,
                              duration: Duration(milliseconds: 200),
                              curve: Curves.easeOut,
                            );
                          }

                          /// ➡ RIGHT
                          if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                            final newOffset =
                            (_horizontalController.offset + scrollAmount).clamp(minH, maxH);

                            _horizontalController.animateTo(
                              newOffset,
                              duration: Duration(milliseconds: 200),
                              curve: Curves.easeOut,
                            );
                          }

                          /// ⬅ LEFT
                          if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                            final newOffset =
                            (_horizontalController.offset - scrollAmount).clamp(minH, maxH);

                            _horizontalController.animateTo(
                              newOffset,
                              duration: Duration(milliseconds: 200),
                              curve: Curves.easeOut,
                            );
                          }
                        },

                        child: Column(
                          children: [

                            /// 🔴 HEADER (separate controller)
                            SingleChildScrollView(
                              controller: _headerHorizontalController, // ✅ IMPORTANT
                              scrollDirection: Axis.horizontal,
                              child: SizedBox(
                                width: 2000, // 👈 SAME WIDTH
                                child: Table(
                                  border: TableBorder(
                                    horizontalInside:
                                    BorderSide(width: 0.5, color: Colors.grey.shade400),
                                    verticalInside:
                                    BorderSide(width: 0.5, color: Colors.grey.shade400),
                                  ),
                                    columnWidths: {
                                      0: FixedColumnWidth(weWidth / 15),
                                      1: FixedColumnWidth(weWidth / 5),
                                      2: FixedColumnWidth(weWidth / 8),
                                      3: FixedColumnWidth(weWidth / 7),
                                      4: FixedColumnWidth(weWidth / 9)
                                    },
                                  children: [
                                    TableRow(
                                      decoration: BoxDecoration(
                                        color: colorsConst.primary,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(5),
                                          topRight: Radius.circular(5),
                                        ),
                                      ),
                                      children: [
                                        headerCell(
                                          "Order No",
                                          field: "orderId",
                                          callBack: () {
                                            if (controllers.sortOrderN.value == 'asc') {
                                              productCtr.ordersList.sort(
                                                      (a, b) => a.orderId.compareTo(b.orderId));
                                            } else {
                                              productCtr.ordersList.sort(
                                                      (a, b) => b.orderId.compareTo(a.orderId));
                                            }
                                          },
                                        ),
                                        headerCell(
                                          "Customer Name",
                                          field: "customerName",
                                          callBack: () {
                                            if (controllers.sortOrderN.value == 'asc') {
                                              productCtr.ordersList.sort(
                                                      (a, b) => a.customerName.compareTo(b.customerName));
                                            } else {
                                              productCtr.ordersList.sort(
                                                      (a, b) => b.customerName.compareTo(a.customerName));
                                            }
                                          },
                                        ),
                                        headerCell("Total Amount",callBack: (){
                                          if(controllers.sortOrderN.value == 'asc'){
                                            productCtr.ordersList.sort((a, b) =>
                                                a.totalAmt.toString().toLowerCase()
                                                    .compareTo(b.totalAmt.toString().toLowerCase()));
                                          }else{
                                            productCtr.ordersList.sort((a, b) =>
                                                b.totalAmt.toString().toLowerCase()
                                                    .compareTo(a.totalAmt.toString().toLowerCase()));
                                          }
                                        }, field: 'Total Amount'),
                                        headerCell("Order Date",callBack: (){
                                          if(controllers.sortOrderN.value == 'asc'){
                                            productCtr.ordersList.sort((a, b) =>
                                                a.createdTs.toString().toLowerCase()
                                                    .compareTo(b.createdTs.toString().toLowerCase()));
                                          }else{
                                            productCtr.ordersList.sort((a, b) =>
                                                b.createdTs.toString().toLowerCase()
                                                    .compareTo(a.createdTs.toString().toLowerCase()));
                                          }
                                        }, field: 'Order Date'),
                                        headerCell("Invoice",callBack: (){}, field: ''),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            /// 🟢 BODY
                            Expanded(
                              child: Scrollbar(
                                controller: _horizontalController,
                                thumbVisibility: true,
                                trackVisibility: true,
                                thickness: 8,
                                radius: const Radius.circular(8),
                                scrollbarOrientation: ScrollbarOrientation.bottom, // 👈 முக்கியம்
                                child: SingleChildScrollView(
                                  controller: _horizontalController,
                                  scrollDirection: Axis.horizontal,
                                  child: SizedBox(
                                    width: 2000, // 👈 must same
                                    child: Scrollbar(
                                      controller: _verticalController,
                                      thumbVisibility: true,
                                      trackVisibility: true,
                                      child: SingleChildScrollView(
                                        controller: _verticalController,
                                        child: Table(
                                            columnWidths: {
                                              0: FixedColumnWidth(weWidth / 15),
                                              1: FixedColumnWidth(weWidth / 5),
                                              2: FixedColumnWidth(weWidth / 8),
                                              3: FixedColumnWidth(weWidth / 7),
                                              4: FixedColumnWidth(weWidth / 9)
                                            },
                                          border: TableBorder.all(color: Colors.grey.shade300),
                                          children: List.generate(productCtr.ordersList.length, (index) {
                                            final e = productCtr.ordersList[index];
                                            return TableRow(
                                              decoration: BoxDecoration(
                                                color: index % 2 == 0
                                                    ? Colors.white
                                                    : colorsConst.backgroundColor,
                                              ),
                                              children: [
                                                valueCell(e.orderId.toString()),
                                                valueCell(e.customerName.toString()),
                                                valueCell(productCtr.formatAmount(e.totalAmt.toString())),
                                                valueCell(productCtr.formatDateTime(e.createdTs.toString())),
                                                SizedBox(
                                            height: 50,
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: ElevatedButton(
                                                  onPressed: (){
                                                    showDialog(
                                                      context: context,
                                                      builder: (_) => OrderInvoiceDialog(order: e),
                                                    );
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children: [
                                                      Icon(Icons.print,color: Colors.white,),
                                                      CustomText(text: "Invoice", isCopy: false),
                                                    ],
                                                  )),
                                            ),
                                          ),
                                              ],
                                            );
                                          }),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                    productCtr.ordersList.isNotEmpty? Obx(() {
                    int totalPages = controllers.totalProspectPages.value == 0 ? 1 : controllers.totalProspectPages.value;
                    final currentPage = controllers.currentProspectPage.value;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        utils.paginationButton(Icons.chevron_left, currentPage > 1, () {
                          _focusNode.requestFocus();
                          controllers.currentProspectPage.value--;
                          controllers.changeOrderPage(productCtr.ordersList,productCtr.ordersList2);
                          print("controllers.currentProspectPage.value --- ${controllers.currentProspectPage.value}");
                        }),
                        ...utils.buildPagination(totalPages, currentPage),
                        utils.paginationButton(Icons.chevron_right, currentPage < totalPages, () {
                          controllers.currentProspectPage.value++;
                          _focusNode.requestFocus();
                          controllers.changeOrderPage(productCtr.ordersList,productCtr.ordersList2);
                          print("controllers.currentProspectPage.value +++ ${controllers.currentProspectPage.value}");
                        }),
                      ],
                    );
                  }):0.height,
                  20.height,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget headerCell(String text,{required VoidCallback callBack, required String field}) {
    return Container(
      height: 45,
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomText(
            text: text,
            isCopy: false,
            colors: Colors.white,
          ),
          5.width,
          GestureDetector(
            onTap: () {
              setState(() {

                /// toggle asc/desc
                if (controllers.sortField.value == field) {
                  controllers.sortOrderN.value =
                  controllers.sortOrderN.value == 'asc' ? 'desc' : 'asc';
                } else {
                  controllers.sortField.value = field;
                  controllers.sortOrderN.value = 'asc';
                }

                callBack();
              });
            },
            child: Obx(() => Image.asset(
              controllers.sortField.value != field
                  ? "assets/images/arrow.png"
                  : controllers.sortOrderN.value == 'asc'
                  ? "assets/images/arrow_up.png"
                  : "assets/images/arrow_down.png",
              width: 15,
              height: 15,
            )),
          ),
        ],
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
                      onTap:()async{
                        // final image = await productCtr.screenshotController.capture();
                        //
                        // if (image == null) return;
                        //
                        // final pdf = pw.Document();
                        //
                        // final imagePdf = pw.MemoryImage(image);
                        //
                        // pdf.addPage(
                        //   pw.Page(
                        //     build: (context) => pw.Center(
                        //       child: pw.Image(imagePdf),
                        //     ),
                        //   ),
                        // );
                        //
                        // await Printing.sharePdf(
                        //     bytes: await pdf.save(),
                        // filename: 'invoice_${order.orderId}.pdf',
                        // );
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

                /// 🔴 TITLE BOX
                pw.Center(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(),
                      borderRadius: pw.BorderRadius.circular(5),
                    ),
                    child: pw.Text("TAX INVOICE",
                        style: pw.TextStyle(fontSize: 14)),
                  ),
                ),

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
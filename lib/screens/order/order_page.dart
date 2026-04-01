import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
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
import '../../components/date_filter_bar.dart';
import '../../components/keyboard_search.dart';
import '../../controller/controller.dart';
import '../../controller/product_controller.dart';
import '../../controller/reminder_controller.dart';
import '../../models/all_customers_obj.dart';
import '../../models/product_model.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key, });

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {

  List<double> colWidths = [
    20,   // 0 Checkbox
    80,  // 1 Actions
    100,  // 2 Event Name
    100,  // 2 Event Name
    100,  // 3 Type
  ];
  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controllers.totalProspectPages.value=(productCtr.ordersList.length / controllers.itemsPerPage).ceil();
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
  bool dateCheck() {
    return controllers.stDate.value !=
        "${DateTime.now().day.toString().padLeft(2, "0")}"
            "-${DateTime.now().month.toString().padLeft(2, "0")}"
            "-${DateTime.now().year.toString()}";
  }
  late FocusNode _focusNode;
  final ScrollController _controller = ScrollController();

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
                        hintText: "Search Product Name",
                        onChanged: (value) {
                          controllers.searchText.value = value.toString().trim();
                          setState(() {
                            final suggestions=productCtr.ordersList2.where(
                                    (user){
                                  final customerName = user.customerName.toString().toLowerCase();
                                  final customerNo = user.totalAmt.toString().toLowerCase();
                                  final input = value.toString().toLowerCase().trim();
                                  return customerName.contains(input) || customerNo.contains(input);
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
                  SizedBox(
                    width: controllers.isLeftOpen.value?MediaQuery.of(context).size.width - 150:MediaQuery.of(context).size.width - 60,
                    child: Table(
                      columnWidths: {
                        for (int i = 0; i < colWidths.length; i++)
                          i: FixedColumnWidth(colWidths[i]),
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
                                  CustomText(//2
                                    textAlign: TextAlign.left,
                                    text: "Order No",
                                    size: 15,
                                    isBold: true,
                                    isCopy: true,
                                    colors: Colors.white,
                                  ),
                                  3.width,
                                  GestureDetector(
                                    onTap: (){
                                      if(controllers.sortFieldCallActivity.value=='number' && controllers.sortOrderCallActivity.value=='asc'){
                                        controllers.sortOrderCallActivity.value='desc';
                                      }else{
                                        controllers.sortOrderCallActivity.value='asc';
                                      }
                                      controllers.sortFieldCallActivity.value='number';
                                      productCtr.filterAndSortOrders(
                                        searchText: controllers.searchText.value.toLowerCase(),
                                        sortField: controllers.sortFieldCallActivity.value,
                                        sortOrder: controllers.sortOrderCallActivity.value,
                                        selectedMonth: productCtr.selectedCallMonth.value,
                                        selectedRange: productCtr.selectedCallRange.value,
                                        selectedDateFilter: productCtr.selectedCallSortBy.value,
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
                                  CustomText(//2
                                    textAlign: TextAlign.left,
                                    text: "Customer Name",
                                    size: 15,
                                    isBold: true,
                                    isCopy: true,
                                    colors: Colors.white,
                                  ),
                                  3.width,
                                  GestureDetector(
                                    onTap: (){
                                      if(controllers.sortFieldCallActivity.value=='name' && controllers.sortOrderCallActivity.value=='asc'){
                                        controllers.sortOrderCallActivity.value='desc';
                                      }else{
                                        controllers.sortOrderCallActivity.value='asc';
                                      }
                                      controllers.sortFieldCallActivity.value='name';
                                      productCtr.filterAndSortOrders(
                                        searchText: controllers.searchText.value.toLowerCase(),
                                        sortField: controllers.sortFieldCallActivity.value,
                                        sortOrder: controllers.sortOrderCallActivity.value,
                                        selectedMonth: productCtr.selectedCallMonth.value,
                                        selectedRange: productCtr.selectedCallRange.value,
                                        selectedDateFilter: productCtr.selectedCallSortBy.value,
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
                                    textAlign: TextAlign.left,
                                    text: "Total Amount",
                                    size: 15,
                                    isBold: true,
                                    isCopy: true,
                                    colors: Colors.white,
                                  ),
                                  3.width,
                                  GestureDetector(
                                    onTap: (){
                                      if(controllers.sortFieldCallActivity.value=='amt' && controllers.sortOrderCallActivity.value=='asc'){
                                        controllers.sortOrderCallActivity.value='desc';
                                      }else{
                                        controllers.sortOrderCallActivity.value='asc';
                                      }
                                      controllers.sortFieldCallActivity.value='amt';
                                      productCtr.filterAndSortOrders(
                                        searchText: controllers.searchText.value.toLowerCase(),
                                        sortField: controllers.sortFieldCallActivity.value,
                                        sortOrder: controllers.sortOrderCallActivity.value,
                                        selectedMonth: productCtr.selectedCallMonth.value,
                                        selectedRange: productCtr.selectedCallRange.value,
                                        selectedDateFilter: productCtr.selectedCallSortBy.value,
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
                              headerCell(5, Row(
                                children: [
                                  CustomText(
                                    textAlign: TextAlign.left,
                                    text: "Order Date",
                                    size: 15,
                                    isBold: true,
                                    isCopy: true,
                                    colors: Colors.white,
                                  ),
                                  3.width,
                                  GestureDetector(
                                    onTap: (){
                                      if(controllers.sortFieldCallActivity.value=='date' && controllers.sortOrderCallActivity.value=='asc'){
                                        controllers.sortOrderCallActivity.value='desc';
                                      }else{
                                        controllers.sortOrderCallActivity.value='asc';
                                      }
                                      controllers.sortFieldCallActivity.value='date';
                                      productCtr.filterAndSortOrders(
                                        searchText: controllers.searchText.value.toLowerCase(),
                                        sortField: controllers.sortFieldCallActivity.value,
                                        sortOrder: controllers.sortOrderCallActivity.value,
                                        selectedMonth: productCtr.selectedCallMonth.value,
                                        selectedRange: productCtr.selectedCallRange.value,
                                        selectedDateFilter: productCtr.selectedCallSortBy.value,
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
                              headerCell(6, CustomText(//4
                                textAlign: TextAlign.left,
                                text: "Invoice",
                                size: 15,
                                isBold: true,
                                isCopy: true,
                                colors: Colors.white,
                              ),),
                            ]),
                      ],
                    ),
                  ),
                  /// 🟢 TABLE BODY
                  Expanded(
                      child: Obx((){
                        return productCtr.ordersList.isEmpty? Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height/2,
                            alignment: Alignment.center,
                            child: SvgPicture.asset("assets/images/noDataFound.svg"))
                            :RawKeyboardListener(
                          focusNode: _focusNode,
                          autofocus: true,
                          onKey: (event) {
                            if (event is RawKeyDownEvent) {
                              if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                                _controller.animateTo(
                                  _controller.offset + 100,
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                );
                              } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                                _controller.animateTo(
                                  _controller.offset - 100,
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                );
                              }
                            }
                          },
                          child: ListView.builder(
                            controller: _controller,
                            shrinkWrap: true,
                            physics: const ScrollPhysics(),
                            itemCount: productCtr.ordersList.length,
                            itemBuilder: (context, index) {
                              final data = productCtr.ordersList[index];
                              return Table(
                                columnWidths: {
                                  for (int i = 0; i < colWidths.length; i++)
                                    i: FixedColumnWidth(colWidths[i]),
                                },
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
                                        // Padding(
                                        //   padding: const EdgeInsets.all(10.0),
                                        //   child: Checkbox(
                                        //     value: remController.isCheckedRecordCall(data.id.toString()),
                                        //     onChanged: (value) {
                                        //       setState(() {
                                        //         remController.toggleRecordSelectionCall(data.id.toString());
                                        //       });
                                        //     },
                                        //   ),
                                        // ),
                                        // Padding(
                                        //   padding: const EdgeInsets.all(10.0),
                                        //   child: Row(
                                        //     mainAxisAlignment: MainAxisAlignment.start,
                                        //     children: [
                                        //       IconButton(
                                        //           onPressed: (){
                                        //             String sentDate = data.sentDate;
                                        //             if (sentDate.isNotEmpty) {
                                        //               List<String> parts = sentDate.split(' ');
                                        //               String datePart = parts[0];
                                        //               String timePart = parts.sublist(1).join(' ');
                                        //               controllers.empDOB.value = datePart;
                                        //               controllers.callTime.value = timePart;
                                        //             }
                                        //             controllers.selectNCustomer(data.sentId, data.customerName, "", data.toData);
                                        //             controllers.callType = data.callType;
                                        //             controllers.callStatus = data.callStatus;
                                        //             controllers.callCommentCont.text = data.message;
                                        //             utils.showCallDialog(
                                        //                 context,"Update Call log",
                                        //                     (){
                                        //                   apiService.updateCallCommentAPI(context, "7",data.id);
                                        //                 },false
                                        //             );
                                        //
                                        //
                                        //             // showDialog(
                                        //             //     context: context,
                                        //             //     barrierDismissible: false,
                                        //             //     builder: (context) {
                                        //             //       String customerError = "";
                                        //             //       String dateError = "";
                                        //             //       String timeError = "";
                                        //             //       return StatefulBuilder(
                                        //             //           builder: (BuildContext context, StateSetter setState){
                                        //             //             return  AlertDialog(
                                        //             //               title: Row(
                                        //             //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        //             //                 children: [
                                        //             //                   CustomText(
                                        //             //                     text: "",
                                        //             //                     size: 16,
                                        //             //                     isBold: true,
                                        //             //                     colors: colorsConst.textColor,
                                        //             //                     isCopy: false,
                                        //             //                   ),
                                        //             //                   IconButton(
                                        //             //                       onPressed: (){
                                        //             //                         Navigator.of(context).pop();
                                        //             //                       },
                                        //             //                       icon: Icon(Icons.clear,
                                        //             //                         color: Colors.black,
                                        //             //                       ))
                                        //             //                 ],
                                        //             //               ),
                                        //             //               content: SizedBox(
                                        //             //                 width: 520,
                                        //             //                 height: 450,
                                        //             //                 child: SingleChildScrollView(
                                        //             //                   child: Column(
                                        //             //                     mainAxisAlignment: MainAxisAlignment.center,
                                        //             //                     crossAxisAlignment: CrossAxisAlignment.center,
                                        //             //                     children: [
                                        //             //                       Column(
                                        //             //                         crossAxisAlignment: CrossAxisAlignment.start,
                                        //             //                         children: [
                                        //             //                           Row(
                                        //             //                             children: [
                                        //             //                               CustomText(
                                        //             //                                 text:"Customer Name",
                                        //             //                                 colors: colorsConst.textColor,
                                        //             //                                 size: 13,
                                        //             //                                 isCopy: false,
                                        //             //                               ),
                                        //             //                               const CustomText(
                                        //             //                                 text: "*",
                                        //             //                                 colors: Colors.red,
                                        //             //                                 size: 25,
                                        //             //                                 isCopy: false,
                                        //             //                               )
                                        //             //                             ],
                                        //             //                           ),
                                        //             //                           SizedBox(
                                        //             //                             width: 480,
                                        //             //                             height: 50,
                                        //             //                             child: KeyboardDropdownField<AllCustomersObj>(
                                        //             //                               items: controllers.customers,
                                        //             //                               borderRadius: 5,
                                        //             //                               borderColor: Colors.grey.shade300,
                                        //             //                               hintText: "Customers",
                                        //             //                               labelText: "",
                                        //             //                               labelBuilder: (customer) =>'${customer.name}${customer.companyName.isEmpty ? "" : " ,${customer.companyName}"} ${customer.name.isEmpty?"":"-"} ${customer.phoneNo}',
                                        //             //                               itemBuilder: (customer) {
                                        //             //                                 return Container(
                                        //             //                                   width: 300,
                                        //             //                                   alignment: Alignment.topLeft,
                                        //             //                                   padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                        //             //                                   child: CustomText(
                                        //             //                                     text: '${customer.name}${customer.companyName.isEmpty ? "" : " ,${customer.companyName}"} ${customer.name.isEmpty?"":"-"} ${customer.phoneNo}',
                                        //             //                                     colors: Colors.black,
                                        //             //                                     size: 14,
                                        //             //                                     isCopy: false,
                                        //             //                                     textAlign: TextAlign.start,
                                        //             //                                   ),
                                        //             //                                 );
                                        //             //                               },
                                        //             //                               textEditingController: controllers.cusController,
                                        //             //                               onSelected: (value) {
                                        //             //                                 controllers.selectCustomer(value);
                                        //             //                               },
                                        //             //                               onClear: () {
                                        //             //                                 controllers.clearSelectedCustomer();
                                        //             //                               },
                                        //             //                             ),
                                        //             //                           ),
                                        //             //                           if (customerError.isNotEmpty)
                                        //             //                             Padding(
                                        //             //                               padding: const EdgeInsets.only(top: 4.0),
                                        //             //                               child: Text(
                                        //             //                                 customerError,
                                        //             //                                 style: const TextStyle(
                                        //             //                                     color: Colors.red,
                                        //             //                                     fontSize: 13),
                                        //             //                               ),
                                        //             //                             ),
                                        //             //                         ],
                                        //             //                       ),
                                        //             //                       10.height,
                                        //             //                       Row(
                                        //             //                         mainAxisAlignment: MainAxisAlignment.center,
                                        //             //                         children: [
                                        //             //                           Obx(() => CustomDateBox(
                                        //             //                             text: "Date",
                                        //             //                             isOptional: true,
                                        //             //                             errorText: dateError,
                                        //             //                             value: controllers.upDate.value,
                                        //             //                             width: 235,
                                        //             //                             onTap: () {
                                        //             //                               utils.datePicker(
                                        //             //                                   context: context,
                                        //             //                                   textEditingController: controllers.dateOfConCtr,
                                        //             //                                   pathVal: controllers.upDate);
                                        //             //                             },
                                        //             //                           ),
                                        //             //                           ),
                                        //             //                           15.width,
                                        //             //                           Obx(() => CustomDateBox(
                                        //             //                             text: "Time",
                                        //             //                             isOptional: true,
                                        //             //                             errorText: timeError,
                                        //             //                             value: controllers.upCallTime.value,
                                        //             //                             width: 235,
                                        //             //                             onTap: () {
                                        //             //                               utils.timePicker(
                                        //             //                                   context: context,
                                        //             //                                   textEditingController:
                                        //             //                                   controllers.timeOfConCtr,
                                        //             //                                   pathVal: controllers.upCallTime);
                                        //             //                             },
                                        //             //                           ),
                                        //             //                           ),
                                        //             //                         ],
                                        //             //                       ),
                                        //             //                       10.height,
                                        //             //                       Row(
                                        //             //                         children: [
                                        //             //                           5.width,
                                        //             //                           Column(
                                        //             //                             crossAxisAlignment: CrossAxisAlignment.start,
                                        //             //                             children: [
                                        //             //                               Row(
                                        //             //                                 children: [
                                        //             //                                   CustomText(
                                        //             //                                     text:"Call Type",
                                        //             //                                     colors: colorsConst.textColor,
                                        //             //                                     size: 13,
                                        //             //                                     isCopy: false,
                                        //             //                                   ),
                                        //             //                                   const CustomText(
                                        //             //                                     text: "*",
                                        //             //                                     colors: Colors.red,
                                        //             //                                     size: 25,
                                        //             //                                     isCopy: false,
                                        //             //                                   )
                                        //             //                                 ],
                                        //             //                               ),
                                        //             //                               Row(
                                        //             //                                 children: controllers.callTypeList.map<Widget>((type) {
                                        //             //                                   return Row(
                                        //             //                                     mainAxisSize: MainAxisSize.min,
                                        //             //                                     children: [
                                        //             //                                       Radio<String>(
                                        //             //                                         value: type,
                                        //             //                                         groupValue: controllers.upCallType,
                                        //             //                                         activeColor: colorsConst.primary,
                                        //             //                                         onChanged: (value) {
                                        //             //                                           setState(() {
                                        //             //                                             controllers.upCallType = value!;
                                        //             //                                           });
                                        //             //                                         },
                                        //             //                                       ),
                                        //             //                                       CustomText(text:type,size: 14,isCopy: false),
                                        //             //                                       20.width, // space between options
                                        //             //                                     ],
                                        //             //                                   );
                                        //             //                                 }).toList(),
                                        //             //                               ),
                                        //             //                             ],
                                        //             //                           ),
                                        //             //                         ],
                                        //             //                       ),
                                        //             //                       10.height,
                                        //             //                       Row(
                                        //             //                         children: [
                                        //             //                           5.width,
                                        //             //                           Column(
                                        //             //                             crossAxisAlignment: CrossAxisAlignment.start,
                                        //             //                             children: [
                                        //             //                               Row(
                                        //             //                                 children: [
                                        //             //                                   CustomText(
                                        //             //                                     text:"Status",
                                        //             //                                     colors: colorsConst.textColor,
                                        //             //                                     size: 13,
                                        //             //                                     isCopy: false,
                                        //             //                                   ),
                                        //             //                                   const CustomText(
                                        //             //                                     text: "*",
                                        //             //                                     colors: Colors.red,
                                        //             //                                     size: 25,
                                        //             //                                     isCopy: false,
                                        //             //                                   )
                                        //             //                                 ],
                                        //             //                               ),
                                        //             //                               SizedBox(
                                        //             //                                 width: 510,
                                        //             //                                 height: 50,
                                        //             //                                 child: ListView.builder(
                                        //             //                                     shrinkWrap: true,
                                        //             //                                     scrollDirection: Axis.horizontal,
                                        //             //                                     itemCount: controllers.hCallStatusList.length,
                                        //             //                                     itemBuilder: (context,index){
                                        //             //                                       return Row(
                                        //             //                                         mainAxisSize: MainAxisSize.min,
                                        //             //                                         children: [
                                        //             //                                           Radio<String>(
                                        //             //                                             value: controllers.hCallStatusList[index]["value"],
                                        //             //                                             groupValue: controllers.upcallStatus,
                                        //             //                                             activeColor: colorsConst.primary,
                                        //             //                                             onChanged: (value) {
                                        //             //                                               setState(() {
                                        //             //                                                 controllers.upcallStatus = value!;
                                        //             //                                               });
                                        //             //                                             },
                                        //             //                                           ),
                                        //             //                                           CustomText(
                                        //             //                                             text: controllers.hCallStatusList[index]["value"],
                                        //             //                                             size: 14,
                                        //             //                                             isCopy: false,
                                        //             //                                           ),
                                        //             //                                           20.width,
                                        //             //                                         ],
                                        //             //                                       );
                                        //             //                                     }),
                                        //             //                               )
                                        //             //                             ],
                                        //             //                           ),
                                        //             //                         ],
                                        //             //                       ),
                                        //             //                       10.height,
                                        //             //                       Column(
                                        //             //                         crossAxisAlignment: CrossAxisAlignment.start,
                                        //             //                         children: [
                                        //             //                           CustomText(
                                        //             //                             text:"Notes",
                                        //             //                             colors: colorsConst.textColor,
                                        //             //                             size: 13,
                                        //             //                             isCopy: false,
                                        //             //                           ),
                                        //             //                           SizedBox(
                                        //             //                             width: 480,
                                        //             //                             height: 80,
                                        //             //                             child: TextField(
                                        //             //                               controller: controllers.upCallCommentCont,
                                        //             //                               maxLines: null,
                                        //             //                               expands: true,
                                        //             //                               textAlign: TextAlign.start,
                                        //             //                               decoration: InputDecoration(
                                        //             //                                 hintText: "Notes",
                                        //             //                                 border: OutlineInputBorder(
                                        //             //                                   borderRadius: BorderRadius.circular(5),
                                        //             //                                   borderSide: BorderSide(
                                        //             //                                     color: Color(0xffE1E5FA),
                                        //             //                                   ),
                                        //             //                                 ),
                                        //             //                                 focusedBorder: OutlineInputBorder(
                                        //             //                                   borderRadius: BorderRadius.circular(5),
                                        //             //                                   borderSide: BorderSide(
                                        //             //                                     color: Color(0xffE1E5FA),
                                        //             //                                   ),
                                        //             //                                 ),
                                        //             //                               ),
                                        //             //                             ),
                                        //             //                           ),
                                        //             //                         ],
                                        //             //                       )
                                        //             //                     ],
                                        //             //                   ),
                                        //             //                 ),
                                        //             //               ),
                                        //             //               actions: [
                                        //             //                 Row(
                                        //             //                   mainAxisAlignment: MainAxisAlignment.end,
                                        //             //                   children: [
                                        //             //                     Container(
                                        //             //                       decoration: BoxDecoration(
                                        //             //                           border: Border.all(color: colorsConst.primary),
                                        //             //                           color: Colors.white),
                                        //             //                       width: 80,
                                        //             //                       height: 25,
                                        //             //                       child: ElevatedButton(
                                        //             //                           style: ElevatedButton.styleFrom(
                                        //             //                             shape: const RoundedRectangleBorder(
                                        //             //                               borderRadius: BorderRadius.zero,
                                        //             //                             ),
                                        //             //                             backgroundColor: Colors.white,
                                        //             //                           ),
                                        //             //                           onPressed: () {
                                        //             //                             Navigator.pop(context);
                                        //             //                           },
                                        //             //                           child: CustomText(
                                        //             //                             text: "Cancel",
                                        //             //                             colors: colorsConst.primary,
                                        //             //                             size: 14,
                                        //             //                             isCopy: false,
                                        //             //                           )),
                                        //             //                     ),
                                        //             //                     10.width,
                                        //             //                     CustomLoadingButton(
                                        //             //                       callback: (){
                                        //             //                         if(controllers.selectedCustomerId.value.isEmpty) {
                                        //             //                           controllers.productCtr.reset();
                                        //             //                           setState(() {
                                        //             //                             customerError =
                                        //             //                             "Please select customer";
                                        //             //                           });
                                        //             //                           return;
                                        //             //                         }
                                        //             //                         if(controllers.upDate.value.isEmpty) {
                                        //             //                           controllers.productCtr.reset();
                                        //             //                           setState(() {
                                        //             //                             dateError =
                                        //             //                             "Please select date";
                                        //             //                           });
                                        //             //                           return;
                                        //             //                         }
                                        //             //                         if(controllers.upCallTime.value.isEmpty) {
                                        //             //                           controllers.productCtr.reset();
                                        //             //                           setState(() {
                                        //             //                             timeError = "Please select time";
                                        //             //                           });
                                        //             //                           return;
                                        //             //                         }
                                        //             //                         apiService.updateCallCommentAPI(context, "7",data.id);
                                        //             //                       },
                                        //             //                       height: 35,
                                        //             //                       isLoading: true,
                                        //             //                       backgroundColor: colorsConst.primary,
                                        //             //                       radius: 2,
                                        //             //                       width: 80,
                                        //             //                       controller: controllers.productCtr,
                                        //             //                       isImage: false,
                                        //             //                       text: "Save",
                                        //             //                       textColor: Colors.white,
                                        //             //                     ),
                                        //             //                     5.width
                                        //             //                   ],
                                        //             //                 ),
                                        //             //               ],
                                        //             //             );
                                        //             //           }
                                        //             //       );
                                        //             //     });
                                        //           },
                                        //           icon: SvgPicture.asset(
                                        //             "assets/images/a_edit.svg",
                                        //             width: 16,
                                        //             height: 16,
                                        //           )),
                                        //       IconButton(
                                        //           onPressed: (){
                                        //             showDialog(
                                        //               context: context,
                                        //               builder: (BuildContext context) {
                                        //                 return AlertDialog(
                                        //                   content: CustomText(
                                        //                     text: "Are you sure delete this Call records?",
                                        //                     size: 16,
                                        //                     isBold: true,
                                        //                     isCopy: true,
                                        //                     colors: colorsConst.textColor,
                                        //                   ),                                                                  actions: [
                                        //                   Row(
                                        //                     mainAxisAlignment: MainAxisAlignment.end,
                                        //                     children: [
                                        //                       Container(
                                        //                         decoration: BoxDecoration(
                                        //                             border: Border.all(color: colorsConst.primary),
                                        //                             color: Colors.white),
                                        //                         width: 80,
                                        //                         height: 25,
                                        //                         child: ElevatedButton(
                                        //                             style: ElevatedButton.styleFrom(
                                        //                               shape: const RoundedRectangleBorder(
                                        //                                 borderRadius: BorderRadius.zero,
                                        //                               ),
                                        //                               backgroundColor: Colors.white,
                                        //                             ),
                                        //                             onPressed: () {
                                        //                               Navigator.pop(context);
                                        //                             },
                                        //                             child: CustomText(
                                        //                               text: "Cancel",
                                        //                               colors: colorsConst.primary,
                                        //                               size: 14,
                                        //                               isCopy: false,
                                        //                             )),
                                        //                       ),
                                        //                       10.width,
                                        //                       CustomLoadingButton(
                                        //                         callback: ()async{
                                        //                           remController.selectedRecordCallIds.add(data.id.toString());
                                        //                           remController.deleteRecordCallAPI(context);
                                        //                         },
                                        //                         height: 35,
                                        //                         isLoading: true,
                                        //                         backgroundColor: colorsConst.primary,
                                        //                         radius: 2,
                                        //                         width: 80,
                                        //                         controller: controllers.productCtr,
                                        //                         isImage: false,
                                        //                         text: "Delete",
                                        //                         textColor: Colors.white,
                                        //                       ),
                                        //                     ],
                                        //                   ),
                                        //                 ],
                                        //                 );
                                        //               },
                                        //             );
                                        //           },
                                        //           icon: SvgPicture.asset(
                                        //             "assets/images/a_delete.svg",
                                        //             width: 16,
                                        //             height: 16,
                                        //           ))
                                        //     ],
                                        //   ),
                                        // ),
                                        Tooltip(
                                          message: data.orderId.toString()=="null"?"":data.orderId.toString(),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: CustomText(
                                              textAlign: TextAlign.left,
                                              text:data.orderId.toString()=="null"?"":data.orderId.toString(),
                                              size: 14,
                                              isCopy: true,
                                              colors: colorsConst.textColor,
                                            ),
                                          ),
                                        ),
                                        Tooltip(
                                          message: data.customerName.toString()=="null"?"":data.customerName.toString(),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: CustomText(
                                              textAlign: TextAlign.left,
                                              text: data.customerName.toString(),
                                              size: 14,
                                              isCopy: true,
                                              colors:colorsConst.textColor,
                                            ),
                                          ),
                                        ),
                                        Tooltip(
                                          message: productCtr.formatAmount(data.totalAmt.toString()),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: CustomText(
                                              textAlign: TextAlign.left,
                                              text: productCtr.formatAmount(data.totalAmt.toString()),
                                              size: 14,
                                              isCopy: true,
                                              colors:colorsConst.textColor,
                                            ),
                                          ),
                                        ),
                                        Tooltip(
                                          message: productCtr.formatDateTime(data.createdTs.toString()),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: CustomText(
                                              textAlign: TextAlign.left,
                                              text: productCtr.formatDateTime(data.createdTs.toString()),
                                              size: 14,
                                              isCopy: true,
                                              colors:colorsConst.textColor,
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap:(){
                                            showDialog(
                                              context: context,
                                              builder: (_) => OrderInvoiceDialog(order: data),
                                            );
                                          },
                                          child: SizedBox(
                                            // decoration: customDecoration.baseBackgroundDecoration(
                                            //   color: colorsConst.primary,radius: 10
                                            // ),
                                            height: 50,
                                            width:50,
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.print,color: colorsConst.primary),5.width,
                                                  CustomText(text: "Invoice", isCopy: false,colors: colorsConst.primary),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ]
                                  ),

                                ],
                              );
                            },
                          ),
                        );
                      })
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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/services/api_services.dart';
import 'package:get/get.dart';
import '../../common/constant/api.dart';
import '../../common/constant/colors_constant.dart';
import '../../components/Customtext.dart';
import '../../components/custom_search_textfield.dart';
import '../../components/date_filter_bar.dart';
import '../../controller/controller.dart';
import '../../controller/product_controller.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui;
import '../../controller/reminder_controller.dart';
class QuotationHistory extends StatefulWidget {
  const QuotationHistory({super.key, });

  @override
  State<QuotationHistory> createState() => _QuotationHistoryState();
}

class _QuotationHistoryState extends State<QuotationHistory> {
  var sizeInKB=0.0.obs;
  List<double> colWidths = [
    20,   // 0 Checkbox
    80,  // 1 Actions
    80,  // 1 Actions
    100,  // 2 Event Name
    100,  // 3 Type
    100,  // 4 Location
    100,  // 5 Employee Name
    100,  // 6 Customer Name
    100,  // 7 Start Date
  ];
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
    return SelectionArea(
      child: Scaffold(
        body: Obx(()=>Container(
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
                      controllers.searchText.value = value.toString().trim();
                      setState(() {
                        final suggestions=productCtr.quotationsList2.where(
                                (user){
                              final customerName = user.name.toString().toLowerCase();
                              final customerNo = user.number.toString().toLowerCase();
                              final bankName = user.totalAmt.toString().toLowerCase();
                              final input = value.toString().toLowerCase().trim();
                              return customerName.contains(input) || customerNo.contains(input)|| bankName.contains(input);
                            }).toList();
                        productCtr.quotationsList.value=suggestions;
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
                              productCtr.filterAndSortQuotations(
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
                        productCtr.filterAndSortQuotations(
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
              15.height,
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
                          // headerCell(0, Obx(() => Checkbox(
                          //   shape: RoundedRectangleBorder(
                          //     borderRadius: BorderRadius.circular(2.0),
                          //   ),
                          //   side: WidgetStateBorderSide.resolveWith(
                          //         (states) => const BorderSide(width: 1.0, color: Colors.white),
                          //   ),
                          //   value: remController.selectedRecordCallIds.length == productCtr.quotationsList.length && productCtr.quotationsList.isNotEmpty,
                          //   onChanged: (value) {
                          //     setState(() {
                          //       if (value == true) {
                          //         remController.selectAllCalls();
                          //       } else {
                          //         remController.unselectAllCalls();
                          //       }
                          //     });
                          //   },
                          //   activeColor: Colors.white,
                          //   checkColor: colorsConst.primary,
                          // ))),
                          // headerCell(1, CustomText(
                          //   textAlign: TextAlign.left,
                          //   text: "Actions",//1
                          //   size: 15,
                          //   isBold: true,
                          //   isCopy: false,
                          //   colors: Colors.white,
                          // ),),
                          headerCell(2,  CustomText(
                            textAlign: TextAlign.left,
                            text: "S.No",
                            size: 15,
                            isBold: true,
                            isCopy: true,
                            colors: Colors.white,
                          ),),
                          headerCell(2,  CustomText(
                            textAlign: TextAlign.left,
                            text: "Quotation No",
                            size: 15,
                            isBold: true,
                            isCopy: true,
                            colors: Colors.white,
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
                                  productCtr.filterAndSortQuotations(
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
                                text: "Customer Number",
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
                                  productCtr.filterAndSortQuotations(
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
                                  productCtr.filterAndSortQuotations(
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
                          headerCell(6, Row(
                            children: [
                              CustomText(//4
                                textAlign: TextAlign.left,
                                text: "Sent Date",
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
                                  productCtr.filterAndSortQuotations(
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
                              3.width,
                              GestureDetector(
                                onTap: (){
                                  if(controllers.sortFieldCallActivity.value=='status' && controllers.sortOrderCallActivity.value=='asc'){
                                    controllers.sortOrderCallActivity.value='desc';
                                  }else{
                                    controllers.sortOrderCallActivity.value='asc';
                                  }
                                  controllers.sortFieldCallActivity.value='status';
                                  productCtr.filterAndSortQuotations(
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
                          headerCell(8, CustomText(
                            textAlign: TextAlign.left,
                            text: "Invoice",
                            size: 15,
                            isBold: true,
                            isCopy: true,
                            colors: Colors.white,
                          ),),
                          headerCell(9, CustomText(
                            textAlign: TextAlign.left,
                            text: "Confirm Order",
                            size: 15,
                            isBold: true,
                            isCopy: true,
                            colors: Colors.white,
                          ),)
                        ]),
                  ],
                ),
              ),
              Expanded(
                  child: Obx((){
                    return productCtr.quotationsList.isEmpty? Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height/2,
                        alignment: Alignment.center,
                        child: SvgPicture.asset(
                            "assets/images/noDataFound.svg"))
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
                        itemCount: productCtr.quotationsList.length,
                        itemBuilder: (context, index) {
                          final data = productCtr.quotationsList[index];
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
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: CustomText(
                                        textAlign: TextAlign.left,
                                        text: "${index+1}",
                                        size: 14,
                                        isCopy: true,
                                        colors:colorsConst.textColor,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: CustomText(
                                        textAlign: TextAlign.left,
                                        text: data.quotationNo,
                                        size: 14,
                                        isCopy: true,
                                        colors:colorsConst.textColor,
                                      ),
                                    ),
                                    Tooltip(
                                      message: data.name.toString()=="null"?"":data.name.toString(),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: CustomText(
                                          textAlign: TextAlign.left,
                                          text:data.name.toString()=="null"?"":data.name.toString(),
                                          size: 14,
                                          isCopy: true,
                                          colors: colorsConst.textColor,
                                        ),
                                      ),
                                    ),
                                    Tooltip(
                                      message: data.number.toString()=="null"?"":data.number.toString(),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: CustomText(
                                          textAlign: TextAlign.left,
                                          text: data.number.toString(),
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
                                    Tooltip(
                                      message: data.status,
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: CustomText(
                                          textAlign: TextAlign.left,
                                          text: data.status,
                                          size: 14,
                                          isCopy: true,
                                          colors:colorsConst.textColor,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: InkWell(
                                        onTap: () {
                                          String url = "$getImage?path=${Uri.encodeComponent(data.invoicePdf)}";
                                          showPdfDialog(context, url);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
                                          child: CustomText(text: "View Invoice", isCopy: false,colors: colorsConst.primary,),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: InkWell(
                                          onTap: data.status=="Order Confirmed"?null:(){
                                            apiService.confirmOrderAPI(context,data.id.toString(),data.cusId.toString(),data.totalAmt.toString(),data.name.toString(),data.number.toString());
                                        }, child: Padding(
                                          padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
                                          child: CustomText(text: "CONFIRM ORDER", isCopy: false,isBold: true,colors: data.status=="Order Confirmed"?Colors.grey:Colors.green,),
                                        ),),
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
            ],
          ),
        )),
      ),
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
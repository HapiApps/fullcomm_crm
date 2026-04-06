import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fullcomm_crm/common/constant/colors_constant.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/common/utilities/utils.dart';
import 'package:flutter/material.dart';
import 'package:fullcomm_crm/controller/reminder_controller.dart';
import 'package:get/get.dart';
import '../../components/custom_search_textfield.dart';
import '../../components/custom_sidebar.dart';
import '../../components/date_filter_bar.dart';
import '../../components/custom_text.dart';
import '../../controller/controller.dart';
import '../../controller/product_controller.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key, });

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<double> colWidths = [
    20,   // 0 Checkbox
    80,  // 1 Actions
    100,  // 2 Event Name
    100,  // 2 Event Name
    100,  // 3 Type
    100,  // 4 Location
    100,  // 5 Employee Name
    100,  // 6 Customer Name
    100,  // 7 Start Date
    100,  // 7 Start Date
  ];
  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      productCtr.isSelectAll.value=false;
      productCtr.idsList.value.clear();
      productCtr.totalProspectPages.value=(productCtr.products.length / productCtr.itemsPerPage).ceil();
      _focusNode.requestFocus();
    });
    Future.delayed(Duration.zero,(){
      productCtr.filterAndSortProducts(
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
    return Scaffold(
      body: Row(
        children: [
          SideBar(),
          /// MAIN
          Container(
            width:controllers.isLeftOpen.value?MediaQuery.of(context).size.width - 150:MediaQuery.of(context).size.width - 60,
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.center,
            padding: EdgeInsets.fromLTRB(16, 5, 16, 16),
            child: Expanded(
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
                            text: "Products",
                            colors: colorsConst.textColor,
                            size: 20,
                            isBold: true,
                            isCopy: true,
                          ),
                          10.height,
                          CustomText(
                            text: "View all of your Products Details",
                            colors: colorsConst.textColor,
                            size: 14,
                            isCopy: true,
                          ),
                        ],
                      ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.end,
                      //   children: [
                      //     if(controllers.planType.value!="Business Essential"&&controllers.planType.value!="Business Fit")
                      //       SizedBox(
                      //         height: 40,
                      //         child: ElevatedButton(
                      //           onPressed: (){
                      //             Navigator.push(
                      //               context,
                      //               PageRouteBuilder(
                      //                 pageBuilder: (context, animation1, animation2) =>
                      //                 const ReminderCalender(),
                      //                 transitionDuration: Duration.zero,
                      //                 reverseTransitionDuration: Duration.zero,
                      //               ),
                      //             );
                      //           },
                      //           style: ElevatedButton.styleFrom(
                      //             backgroundColor: const Color(0xff0078D7),
                      //             padding: const EdgeInsets.symmetric(
                      //                 horizontal: 20, vertical: 12),
                      //             shape: RoundedRectangleBorder(
                      //               borderRadius: BorderRadius.circular(4),
                      //             ),
                      //           ),
                      //           child: Text(
                      //             'Reminder Calender',
                      //             style: GoogleFonts.lato(
                      //                 color: Colors.white,
                      //                 fontSize: 14,
                      //                 fontWeight: FontWeight.bold
                      //             ),
                      //           ),
                      //         ),
                      //       ),10.width,
                      //     SizedBox(
                      //       height: 40,
                      //       child: ElevatedButton(
                      //         onPressed: (){
                      //           // Navigator.push(
                      //           //   context,
                      //           //   PageRouteBuilder(
                      //           //     pageBuilder: (context, animation1, animation2) => AddReminder(),
                      //           //     transitionDuration: Duration.zero,
                      //           //     reverseTransitionDuration: Duration.zero,
                      //           //   ),
                      //           // );
                      //           reminderUtils.showAddReminderDialog(context);
                      //         },
                      //         style: ElevatedButton.styleFrom(
                      //           backgroundColor: const Color(0xff0078D7),
                      //           padding: const EdgeInsets.symmetric(
                      //               horizontal: 20, vertical: 12),
                      //           shape: RoundedRectangleBorder(
                      //             borderRadius: BorderRadius.circular(4),
                      //           ),
                      //         ),
                      //         child: Row(
                      //           children: [
                      //             const Icon(Icons.add,color: Colors.white),
                      //             const SizedBox(width: 5),
                      //             Text(
                      //               'Add Reminder',
                      //               style: GoogleFonts.lato(
                      //                   color: Colors.white,
                      //                   fontSize: 14,
                      //                   fontWeight: FontWeight.bold
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
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
                            final suggestions=productCtr.products2.where(
                                    (user){
                                  final customerName = user.pTitle.toString().toLowerCase();
                                  final customerNo = user.hsnCode.toString().toLowerCase();
                                  final bankName = user.skuId.toString().toLowerCase();
                                  final input = value.toString().toLowerCase().trim();
                                  return customerName.contains(input) || customerNo.contains(input)|| bankName.contains(input);
                                }).toList();
                            productCtr.products.value=suggestions;
                          });
                        },
                      ),
                      DateFilterBar(
                        selectedSortBy: productCtr.selectedCallSortBy,
                        selectedRange: productCtr.selectedCallRange,
                        selectedMonth: productCtr.selectedCallMonth,
                        focusNode: _focusNode,
                        onDaysSelected: () {
                          productCtr.filterAndSortProducts(
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
                                productCtr.filterAndSortProducts(
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
                            productCtr.filterAndSortProducts(
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
                              headerCell(2,  CustomText(
                                textAlign: TextAlign.left,
                                text: "S.No",
                                size: 15,
                                isBold: true,
                                isCopy: true,
                                colors: Colors.white,
                              ),),
                              headerCell(3, Row(
                                children: [
                                  CustomText(//2
                                    textAlign: TextAlign.left,
                                    text: "Product Name",
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
                                      productCtr.filterAndSortProducts(
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
                                    text: "MRP",
                                    size: 15,
                                    isBold: true,
                                    isCopy: true,
                                    colors: Colors.white,
                                  ),
                                  3.width,
                                  GestureDetector(
                                    onTap: (){
                                      if(controllers.sortFieldCallActivity.value=='mrp' && controllers.sortOrderCallActivity.value=='asc'){
                                        controllers.sortOrderCallActivity.value='desc';
                                      }else{
                                        controllers.sortOrderCallActivity.value='asc';
                                      }
                                      controllers.sortFieldCallActivity.value='mrp';
                                      productCtr.filterAndSortProducts(
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
                                    text: "Price",
                                    size: 15,
                                    isBold: true,
                                    isCopy: true,
                                    colors: Colors.white,
                                  ),
                                  3.width,
                                  GestureDetector(
                                    onTap: (){
                                      if(controllers.sortFieldCallActivity.value=='price' && controllers.sortOrderCallActivity.value=='asc'){
                                        controllers.sortOrderCallActivity.value='desc';
                                      }else{
                                        controllers.sortOrderCallActivity.value='asc';
                                      }
                                      controllers.sortFieldCallActivity.value='price';
                                      productCtr.filterAndSortProducts(
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
                                    text: "SKU ID",
                                    size: 15,
                                    isBold: true,
                                    isCopy: true,
                                    colors: Colors.white,
                                  ),
                                  3.width,
                                  GestureDetector(
                                    onTap: (){
                                      if(controllers.sortFieldCallActivity.value=='sku' && controllers.sortOrderCallActivity.value=='asc'){
                                        controllers.sortOrderCallActivity.value='desc';
                                      }else{
                                        controllers.sortOrderCallActivity.value='asc';
                                      }
                                      controllers.sortFieldCallActivity.value='sku';
                                      productCtr.filterAndSortProducts(
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
                                    text: "HSN Code",
                                    size: 15,
                                    isBold: true,
                                    isCopy: true,
                                    colors: Colors.white,
                                  ),
                                  3.width,
                                  GestureDetector(
                                    onTap: (){
                                      if(controllers.sortFieldCallActivity.value=='hsn' && controllers.sortOrderCallActivity.value=='asc'){
                                        controllers.sortOrderCallActivity.value='desc';
                                      }else{
                                        controllers.sortOrderCallActivity.value='asc';
                                      }
                                      controllers.sortFieldCallActivity.value='hsn';
                                      productCtr.filterAndSortProducts(
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
                              // headerCell(8, Row(
                              //   children: [
                              //     CustomText(//4
                              //       textAlign: TextAlign.left,
                              //       text: "Category",
                              //       size: 15,
                              //       isBold: true,
                              //       isCopy: true,
                              //       colors: Colors.white,
                              //     ),
                              //     3.width,
                              //     GestureDetector(
                              //       onTap: (){
                              //         if(controllers.sortFieldCallActivity.value=='cat' && controllers.sortOrderCallActivity.value=='asc'){
                              //           controllers.sortOrderCallActivity.value='desc';
                              //         }else{
                              //           controllers.sortOrderCallActivity.value='asc';
                              //         }
                              //         controllers.sortFieldCallActivity.value='cat';
                              //         productCtr.filterAndSortProducts(
                              //           searchText: controllers.searchText.value.toLowerCase(),
                              //           sortField: controllers.sortFieldCallActivity.value,
                              //           sortOrder: controllers.sortOrderCallActivity.value,
                              //           selectedMonth: productCtr.selectedCallMonth.value,
                              //           selectedRange: productCtr.selectedCallRange.value,
                              //           selectedDateFilter: productCtr.selectedCallSortBy.value,
                              //         );
                              //       },
                              //       child: Obx(() => Image.asset(
                              //         controllers.sortFieldCallActivity.value.isEmpty
                              //             ? "assets/images/arrow.png"
                              //             : controllers.sortOrderCallActivity.value == 'asc'
                              //             ? "assets/images/arrow_up.png"
                              //             : "assets/images/arrow_down.png",
                              //         width: 15,
                              //         height: 15,
                              //       ),
                              //       ),
                              //     ),
                              //   ],
                              // ),),
                              // headerCell(9, Row(
                              //   children: [
                              //     CustomText(//4
                              //       textAlign: TextAlign.left,
                              //       text: "Sub Category",
                              //       size: 15,
                              //       isBold: true,
                              //       isCopy: true,
                              //       colors: Colors.white,
                              //     ),
                              //     3.width,
                              //     GestureDetector(
                              //       onTap: (){
                              //         if(controllers.sortFieldCallActivity.value=='sub cat' && controllers.sortOrderCallActivity.value=='asc'){
                              //           controllers.sortOrderCallActivity.value='desc';
                              //         }else{
                              //           controllers.sortOrderCallActivity.value='asc';
                              //         }
                              //         controllers.sortFieldCallActivity.value='sub cat';
                              //         productCtr.filterAndSortProducts(
                              //           searchText: controllers.searchText.value.toLowerCase(),
                              //           sortField: controllers.sortFieldCallActivity.value,
                              //           sortOrder: controllers.sortOrderCallActivity.value,
                              //           selectedMonth: productCtr.selectedCallMonth.value,
                              //           selectedRange: productCtr.selectedCallRange.value,
                              //           selectedDateFilter: productCtr.selectedCallSortBy.value,
                              //         );
                              //       },
                              //       child: Obx(() => Image.asset(
                              //         controllers.sortFieldCallActivity.value.isEmpty
                              //             ? "assets/images/arrow.png"
                              //             : controllers.sortOrderCallActivity.value == 'asc'
                              //             ? "assets/images/arrow_up.png"
                              //             : "assets/images/arrow_down.png",
                              //         width: 15,
                              //         height: 15,
                              //       ),
                              //       ),
                              //     ),
                              //   ],
                              // ),),
                              // headerCell(10, Row(
                              //   children: [
                              //     CustomText(//4
                              //       textAlign: TextAlign.left,
                              //       text: "GST in %",
                              //       size: 15,
                              //       isBold: true,
                              //       isCopy: true,
                              //       colors: Colors.white,
                              //     ),
                              //     3.width,
                              //     GestureDetector(
                              //       onTap: (){
                              //         if(controllers.sortFieldCallActivity.value=='gst' && controllers.sortOrderCallActivity.value=='asc'){
                              //           controllers.sortOrderCallActivity.value='desc';
                              //         }else{
                              //           controllers.sortOrderCallActivity.value='asc';
                              //         }
                              //         controllers.sortFieldCallActivity.value='gst';
                              //         productCtr.filterAndSortProducts(
                              //           searchText: controllers.searchText.value.toLowerCase(),
                              //           sortField: controllers.sortFieldCallActivity.value,
                              //           sortOrder: controllers.sortOrderCallActivity.value,
                              //           selectedMonth: productCtr.selectedCallMonth.value,
                              //           selectedRange: productCtr.selectedCallRange.value,
                              //           selectedDateFilter: productCtr.selectedCallSortBy.value,
                              //         );
                              //       },
                              //       child: Obx(() => Image.asset(
                              //         controllers.sortFieldCallActivity.value.isEmpty
                              //             ? "assets/images/arrow.png"
                              //             : controllers.sortOrderCallActivity.value == 'asc'
                              //             ? "assets/images/arrow_up.png"
                              //             : "assets/images/arrow_down.png",
                              //         width: 15,
                              //         height: 15,
                              //       ),
                              //       ),
                              //     ),
                              //   ],
                              // ),),
                              headerCell(11, Row(
                                children: [
                                  CustomText(//4
                                    textAlign: TextAlign.left,
                                    text: "Added Date",
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
                                      productCtr.filterAndSortProducts(
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
                            ]),
                      ],
                    ),
                  ),
                  /// 🟢 TABLE BODY
                  Expanded(
                      child: Obx((){
                        return productCtr.products.isEmpty? Container(
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
                            itemCount: productCtr.products.length,
                            itemBuilder: (context, index) {
                              final data = productCtr.products[index];
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
                                        Tooltip(
                                          message: data.pTitle.toString()=="null"?"":data.pTitle.toString(),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: CustomText(
                                              textAlign: TextAlign.left,
                                              text:data.pTitle.toString()=="null"?"":data.pTitle.toString(),
                                              size: 14,
                                              isCopy: true,
                                              colors: colorsConst.textColor,
                                            ),
                                          ),
                                        ),
                                        Tooltip(
                                          message: data.mrp.toString()=="null"?"":data.mrp.toString(),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: CustomText(
                                              textAlign: TextAlign.left,
                                              text: data.mrp.toString(),
                                              size: 14,
                                              isCopy: true,
                                              colors:colorsConst.textColor,
                                            ),
                                          ),
                                        ),
                                        Tooltip(
                                          message: productCtr.formatAmount(data.outPrice.toString()),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: CustomText(
                                              textAlign: TextAlign.left,
                                              text: productCtr.formatAmount(data.outPrice.toString()),
                                              size: 14,
                                              isCopy: true,
                                              colors:colorsConst.textColor,
                                            ),
                                          ),
                                        ),
                                        Tooltip(
                                          message: data.skuId.toString()=="null"?"":data.skuId.toString(),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: CustomText(
                                              textAlign: TextAlign.left,
                                              text: data.skuId.toString()=="null"?"":data.skuId.toString(),
                                              size: 14,
                                              isCopy: true,
                                              colors:colorsConst.textColor,
                                            ),
                                          ),
                                        ),
                                        Tooltip(
                                          message: data.hsnCode.toString()=="null"?"":data.hsnCode.toString(),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: CustomText(
                                              textAlign: TextAlign.left,
                                              text: data.hsnCode.toString()=="null"?"":data.hsnCode.toString(),
                                              size: 14,
                                              isCopy: true,
                                              colors:colorsConst.textColor,
                                            ),
                                          ),
                                        ),
                                        // Tooltip(
                                        //   message: data.cat.toString()=="null"?"":data.cat.toString(),
                                        //   child: Padding(
                                        //     padding: const EdgeInsets.all(10.0),
                                        //     child: CustomText(
                                        //       textAlign: TextAlign.left,
                                        //       text: data.cat.toString()=="null"?"":data.cat.toString(),
                                        //       size: 14,
                                        //       isCopy: true,
                                        //       colors:colorsConst.textColor,
                                        //     ),
                                        //   ),
                                        // ),
                                        // Tooltip(
                                        //   message: data.subCat.toString()=="null"?"":data.subCat.toString(),
                                        //   child: Padding(
                                        //     padding: const EdgeInsets.all(10.0),
                                        //     child: CustomText(
                                        //       textAlign: TextAlign.left,
                                        //       text: data.subCat.toString()=="null"?"":data.subCat.toString(),
                                        //       size: 14,
                                        //       isCopy: true,
                                        //       colors:colorsConst.textColor,
                                        //     ),
                                        //   ),
                                        // ),
                                        // Tooltip(
                                        //   message: data.gst.toString()=="null"?"":data.gst.toString(),
                                        //   child: Padding(
                                        //     padding: const EdgeInsets.all(10.0),
                                        //     child: CustomText(
                                        //       textAlign: TextAlign.left,
                                        //       text: data.gst.toString()=="null"?"":data.gst.toString(),
                                        //       size: 14,
                                        //       isCopy: true,
                                        //       colors:colorsConst.textColor,
                                        //     ),
                                        //   ),
                                        // ),
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
                                      ]
                                  ),

                                ],
                              );
                            },
                          ),
                        );
                      })
                  ),
                  productCtr.products.isNotEmpty? Obx(() {
                      int totalPages = productCtr.totalProspectPages.value == 0 ? 1 : productCtr.totalProspectPages.value;
                      final currentPage = productCtr.currentProspectPage.value;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          utils.paginationButton(Icons.chevron_left, currentPage > 1, () {
                            _focusNode.requestFocus();
                            productCtr.currentProspectPage.value--;
                            productCtr.changeProductPage(productCtr.products,productCtr.products2);
                            print("controllers.currentProspectPage.value --- ${productCtr.currentProspectPage.value}");
                          }),
                          ...utils.buildPagination(totalPages, currentPage),
                          utils.paginationButton(Icons.chevron_right, currentPage < totalPages, () {
                            productCtr.currentProspectPage.value++;
                            _focusNode.requestFocus();
                            productCtr.changeProductPage(productCtr.products,productCtr.products2);
                            print("controllers.currentProspectPage.value +++ ${productCtr.currentProspectPage.value}");
                          }),
                        ],
                      );
                    }):0.height,
                  20.height
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  /// 🟢 VALUE CELL
  Widget valueCell(String text) {
    return Container(
      height: 45,
      alignment: Alignment.center,
      child: CustomText(
        text: text,
        isCopy: false,
      ),
    );
  }
}
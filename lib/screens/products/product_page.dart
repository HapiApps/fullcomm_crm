import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fullcomm_crm/common/constant/colors_constant.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/common/utilities/utils.dart';
import 'package:flutter/material.dart';
import 'package:fullcomm_crm/controller/reminder_controller.dart';
import 'package:get/get.dart';
import '../../billing/products/add_products.dart';
import '../../components/custom_loading_button.dart';
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
    80,  // 1 Actions
    100,  // 2 Event Name
    100,  // 2 Event Name
    100,  // 3 Type
    100,  // 4 Location
    100,  // 5 Employee Name
  ];
  late FocusNode _focusNode;
  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(); // ✅ ADD THIS LINE
    WidgetsBinding.instance.addPostFrameCallback((_) {
      productCtr.isSelectAll.value=false;
      productCtr.idsList.value.clear();
      productCtr.totalProspectPages.value=(productCtr.products.length / productCtr.itemsPerPage).ceil();
      _focusNode.requestFocus();
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
  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
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
  final ScrollController _controller = ScrollController();
  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: Scaffold(
        body: Row(
          children: [
            SideBar(),
            /// MAIN
            Container(
              width:controllers.isLeftOpen.value?MediaQuery.of(context).size.width - 150:MediaQuery.of(context).size.width - 60,
              height: MediaQuery.of(context).size.height,
              alignment: Alignment.center,
              padding: EdgeInsets.fromLTRB(16, 5, 16, 16),
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
                      CustomLoadingButton(
                        callback: (){
                          showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (_) => const AddProductDialog(),
                          );
                        },
                        isLoading: false,
                        height: 35,
                        backgroundColor: colorsConst.primary,
                        radius: 2,
                        width: MediaQuery.of(context).size.width*0.07,
                        isImage: false,
                        text: "Add Product",
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
                      columnWidths: const {
                        0: FixedColumnWidth(70),//s no
                        1: FlexColumnWidth(1),//sku
                        2: FlexColumnWidth(1),//HSN
                        3: FlexColumnWidth(3),//name
                        4: FlexColumnWidth(1),//var
                        5: FlexColumnWidth(1),//mrp
                        6: FlexColumnWidth(1),//op
                        7: FlexColumnWidth(1),//br
                        8: FlexColumnWidth(1.5),//cat
                        9: FlexColumnWidth(1.5),//subcat
                        10:FlexColumnWidth(1.5),//date
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
                              ),),//s.no
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
                              ),),//SKU
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
                              ),),//HSN
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
                              ),),//product name
                              headerCell(7, Row(
                                children: [
                                  CustomText(//4
                                    textAlign: TextAlign.left,
                                    text: "Variation",
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
                              ),),//Variation
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
                              ),),//MRP
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
                              ),),//Price
                              headerCell(3, Row(
                                children: [
                                  CustomText(//2
                                    textAlign: TextAlign.left,
                                    text: "Brand",
                                    size: 15,
                                    isBold: true,
                                    isCopy: true,
                                    colors: Colors.white,
                                  ),
                                  3.width,
                                  GestureDetector(
                                    onTap: (){
                                      if(controllers.sortFieldCallActivity.value=='brand' && controllers.sortOrderCallActivity.value=='asc'){
                                        controllers.sortOrderCallActivity.value='desc';
                                      }else{
                                        controllers.sortOrderCallActivity.value='asc';
                                      }
                                      controllers.sortFieldCallActivity.value='brand';
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
                              ),),//brand
                              headerCell(7, Row(
                                children: [
                                  CustomText(//4
                                    textAlign: TextAlign.left,
                                    text: "Category",
                                    size: 15,
                                    isBold: true,
                                    isCopy: true,
                                    colors: Colors.white,
                                  ),
                                  3.width,
                                  GestureDetector(
                                    onTap: (){
                                      if(controllers.sortFieldCallActivity.value=='cat' && controllers.sortOrderCallActivity.value=='asc'){
                                        controllers.sortOrderCallActivity.value='desc';
                                      }else{
                                        controllers.sortOrderCallActivity.value='asc';
                                      }
                                      controllers.sortFieldCallActivity.value='cat';
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
                              ),),//Cat
                              headerCell(7, Row(
                                children: [
                                  CustomText(//4
                                    textAlign: TextAlign.left,
                                    text: "Sub Category",
                                    size: 15,
                                    isBold: true,
                                    isCopy: true,
                                    colors: Colors.white,
                                  ),
                                  3.width,
                                  GestureDetector(
                                    onTap: (){
                                      if(controllers.sortFieldCallActivity.value=='subcat' && controllers.sortOrderCallActivity.value=='asc'){
                                        controllers.sortOrderCallActivity.value='desc';
                                      }else{
                                        controllers.sortOrderCallActivity.value='asc';
                                      }
                                      controllers.sortFieldCallActivity.value='subcat';
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
                              ),),//Sub Cat
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
                              ),),//Added Date
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
                                columnWidths: const {
                                  0: FixedColumnWidth(70),//s no
                                  1: FlexColumnWidth(1),//sku
                                  2: FlexColumnWidth(1),//HSN
                                  3: FlexColumnWidth(3),//name
                                  4: FlexColumnWidth(1),//var
                                  5: FlexColumnWidth(1),//mrp
                                  6: FlexColumnWidth(1),//op
                                  7: FlexColumnWidth(1),//br
                                  8: FlexColumnWidth(1.5),//cat
                                  9: FlexColumnWidth(1.5),//subcat
                                  10:FlexColumnWidth(1.5),//date
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
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: CustomText(
                                            textAlign: TextAlign.left,
                                            text: "${index+1}",
                                            size: 14,
                                            isCopy: true,
                                            colors:colorsConst.textColor,
                                          ),
                                        ),//S.no
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
                                        ),//sku
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
                                        ),//hsn
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
                                        ),//name
                                        Tooltip(
                                          message: data.pVariation.toString()=="null"?"":data.pVariation.toString(),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: CustomText(
                                              textAlign: TextAlign.left,
                                              text: "${data.pVariation.toString()=="null"?"":data.pVariation.toString()} ${data.unit.toString()=="null"?"":data.unit.toString()}",
                                              size: 14,
                                              isCopy: true,
                                              colors:colorsConst.textColor,
                                            ),
                                          ),
                                        ),//variation
                                        Tooltip(
                                          message: data.mrp.toString()=="null"?"":data.mrp.toString(),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: CustomText(
                                              textAlign: TextAlign.left,
                                              text: productCtr.formatAmount(data.mrp.toString()),
                                              size: 14,
                                              isCopy: true,
                                              colors:colorsConst.textColor,
                                            ),
                                          ),
                                        ),//mrp
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
                                        ),//outprice
                                        Tooltip(
                                          message: data.brand.toString()=="null"?"":data.brand.toString(),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: CustomText(
                                              textAlign: TextAlign.left,
                                              text:data.brand.toString()=="null"?"":data.brand.toString(),
                                              size: 14,
                                              isCopy: true,
                                              colors: colorsConst.textColor,
                                            ),
                                          ),
                                        ),//brand
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: CustomText(
                                            textAlign: TextAlign.left,
                                            text: data.category.toString()=="null"?"":data.category.toString(),
                                            size: 14,
                                            isCopy: true,
                                            colors:colorsConst.textColor,
                                          ),
                                        ),//cat
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: CustomText(
                                            textAlign: TextAlign.left,
                                            text: data.subCategory.toString()=="null"?"":data.subCategory.toString(),
                                            size: 14,
                                            isCopy: true,
                                            colors:colorsConst.textColor,
                                          ),
                                        ),//sub cat
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
                                        ),//added date
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
          ],
        ),
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
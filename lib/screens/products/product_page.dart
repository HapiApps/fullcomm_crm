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
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<double> colWidths = [
    70,   // S.No
    120,  // SKU
    120,  // HSN
    150,  // Barcode
    300,  // Name
    120,  // Variation
    100,  // MRP
    100,  // Price
    100,  // Brand
    150,  // Cat
    150,  // Subcat
    80,   // GST
    150,  // Date
  ];

  late FocusNode _focusNode;
  final ScrollController _controller = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      productCtr.isSelectAll.value = false;
      productCtr.idsList.value.clear();
      productCtr.totalProspectPages.value = (productCtr.products.length / productCtr.itemsPerPage).ceil();
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
  Widget headerCell(int index, Widget child) {
    return Container(
      width: colWidths[index],
      padding: const EdgeInsets.all(10),
      alignment: index == 0 ? Alignment.center : Alignment.centerLeft,
      child: child,
    );
  }

  Widget _dataCell(int index, String text, {Alignment align = Alignment.centerLeft}) {
    return Container(
      width: colWidths[index],
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      alignment: align,
      child: CustomText(text: text, size: 13, colors: colorsConst.textColor, isCopy: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Column widths mapped for the Table widget
    final Map<int, TableColumnWidth> tableWidthMap = {
      for (int i = 0; i < colWidths.length; i++) i: FixedColumnWidth(colWidths[i])
    };

    double totalTableWidth = colWidths.reduce((a, b) => a + b);

    return SelectionArea(
      child: Scaffold(
        body: Row(
          children: [
            SideBar(),
            Container(
              width: controllers.isLeftOpen.value
                  ? MediaQuery.of(context).size.width - 150
                  : MediaQuery.of(context).size.width - 60,
              height: MediaQuery.of(context).size.height,
              padding: const EdgeInsets.fromLTRB(16, 5, 16, 16),
              child: Column(
                children: [
                  // --- TITLE & ADD BUTTON ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(text: "Products", colors: colorsConst.textColor, size: 20, isBold: true,isCopy: true),
                          10.height,
                          CustomText(text: "View all of your Products Details", colors: colorsConst.textColor, size: 14,isCopy: true),
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
                  Divider(thickness: 1.5, color: colorsConst.secondary),
                  10.height,

                  // --- SEARCH & FILTERS ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomSearchTextField(
                        controller: controllers.search,
                        hintText: "Search Product Name",
                        onChanged: (value) {
                          controllers.searchText.value = value.toString().trim();
                          final input = value.toString().toLowerCase().trim();
                          productCtr.products.value = productCtr.products2.where((user) {
                            return user.pTitle.toString().toLowerCase().contains(input) ||
                                user.hsnCode.toString().toLowerCase().contains(input) ||
                                user.skuId.toString().toLowerCase().contains(input);
                          }).toList();
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

                  // --- SYNCED SCROLLABLE TABLE ---
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
                                          headerCell(0,  CustomText(
                                        textAlign: TextAlign.left,
                                        text: "S.No",
                                        size: 15,
                                        isBold: true,
                                        isCopy: true,
                                        colors: Colors.white,
                                      ),),//s.no
                                      headerCell(1, Row(
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
                                      headerCell(2, Row(
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
                                          CustomText(//4
                                            textAlign: TextAlign.left,
                                            text: "BarCode",
                                            size: 15,
                                            isBold: true,
                                            isCopy: true,
                                            colors: Colors.white,
                                          ),
                                          3.width,
                                          GestureDetector(
                                            onTap: (){
                                              if(controllers.sortFieldCallActivity.value=='barcode' && controllers.sortOrderCallActivity.value=='asc'){
                                                controllers.sortOrderCallActivity.value='desc';
                                              }else{
                                                controllers.sortOrderCallActivity.value='asc';
                                              }
                                              controllers.sortFieldCallActivity.value='barcode';
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
                                      headerCell(4, Row(
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
                                      headerCell(5, Row(
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
                                      headerCell(6, Row(
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
                                      headerCell(7, Row(
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
                                      headerCell(8, Row(
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
                                      headerCell(9, Row(
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
                                      headerCell(10, Row(
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
                                            text: "GST",
                                            size: 15,
                                            isBold: true,
                                            isCopy: true,
                                            colors: Colors.white,
                                          ),
                                          3.width,
                                          GestureDetector(
                                            onTap: (){
                                              if(controllers.sortFieldCallActivity.value=='gst' && controllers.sortOrderCallActivity.value=='asc'){
                                                controllers.sortOrderCallActivity.value='desc';
                                              }else{
                                                controllers.sortOrderCallActivity.value='asc';
                                              }
                                              controllers.sortFieldCallActivity.value='gst';
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
                                      ),),//GST
                                      headerCell(12, Row(
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
                                        ],
                                      ),
                                    ],
                                  ),
                                  // BODY LIST
                                  Expanded(
                                    child: Obx(() {
                                      if (productCtr.products.isEmpty) return const Center(child: Text("No Data Found"));
                                      return ListView.builder(
                                        controller: _controller,
                                        itemCount: productCtr.products.length,
                                        itemBuilder: (context, index) {
                                          var p = productCtr.products[index];
                                          return Table(
                                            columnWidths: tableWidthMap,
                                              border: TableBorder(
                                                horizontalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                                                verticalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                                                bottom:  BorderSide(width: 0.5, color: Colors.grey.shade400),
                                              ),
                                            children: [
                                              TableRow(
                                                decoration: BoxDecoration(
                                                  color: int.parse(index.toString()) % 2 == 0 ? Colors.white : colorsConst.backgroundColor,
                                                ),
                                                children: [
                                                  _dataCell(0, "${index + 1}", align: Alignment.center),
                                                  _dataCell(1, p.skuId ?? "-"),
                                                  _dataCell(2, p.hsnCode ?? "-"),
                                                  _dataCell(3, p.barcode ?? "-"),
                                                  _dataCell(4, p.pTitle ?? "-"),
                                                  _dataCell(5, p.pVariation ?? "-"),
                                                  _dataCell(6, p.mrp.toString()),
                                                  _dataCell(7, p.outPrice.toString()),
                                                  _dataCell(8, p.brand ?? "-"),
                                                  _dataCell(9, p.category ?? "-"),
                                                  _dataCell(10, p.subCategory ?? "-"),
                                                  _dataCell(11, "${p.cgst}%"),
                                                  _dataCell(12, p.createdTs.toString().split(' ')[0]),
                                                ],
                                              )
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
                        }),
                        ...utils.buildPagination(totalPages, currentPage),
                        utils.paginationButton(Icons.chevron_right, currentPage < totalPages, () {
                          productCtr.currentProspectPage.value++;
                          _focusNode.requestFocus();
                          productCtr.changeProductPage(productCtr.products,productCtr.products2);
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
}
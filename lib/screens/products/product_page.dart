import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fullcomm_crm/common/constant/colors_constant.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/common/styles/decoration.dart';
import 'package:fullcomm_crm/common/utilities/utils.dart';
import 'package:flutter/material.dart';
import 'package:fullcomm_crm/components/customer_name_tile.dart';
import 'package:fullcomm_crm/screens/products/add_product.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../common/constant/api.dart';
import '../../common/utilities/mail_utils.dart';
import '../../components/custom_filter_seaction.dart';
import '../../components/custom_header_seaction.dart';
import '../../components/custom_lead_tile.dart';
import '../../components/custom_loading_button.dart';
import '../../components/custom_no_data.dart';
import '../../components/custom_search_textfield.dart';
import '../../components/custom_sidebar.dart';
import '../../components/dynamic_table_header.dart';
import '../../components/custom_text.dart';
import '../../components/customer_name_header.dart';
import '../../controller/controller.dart';
import '../../controller/product_controller.dart';
import '../../controller/table_controller.dart';
import '../../models/new_lead_obj.dart';
import '../../services/api_services.dart';
import '../invoice/invoice.dart';
import '../order/order_page.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key, });

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final ScrollController _controller = ScrollController();
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _leftController = ScrollController();
  final ScrollController _rightController = ScrollController();
  late FocusNode _focusNode;
  // void searchBy(){
  //   controllers.searchProspects.value = controllers.search.text;
  //
  //   final input = controllers.search.text.toLowerCase().trim();
  //   final inputNoSpace = input.replaceAll(" ", "");
  //
  //   final suggestions = widget.list2.where((user) {
  //
  //     final phone = user.mobileNumber.toString().toLowerCase();
  //     final name = user.firstname.toString().toLowerCase();
  //     final company = user.companyName.toString().toLowerCase();
  //
  //     final phoneNoSpace = phone.replaceAll(" ", "");
  //     final nameNoSpace = name.replaceAll(" ", "");
  //     final companyNoSpace = company.replaceAll(" ", "");
  //
  //     return phone.contains(input) ||
  //         name.contains(input) ||
  //         company.contains(input) ||
  //         phoneNoSpace.contains(inputNoSpace) ||
  //         nameNoSpace.contains(inputNoSpace) ||
  //         companyNoSpace.contains(inputNoSpace);
  //
  //   }).toList();
  //
  //   widget.list.value = suggestions;
  //
  //   controllers.selectRadio(widget.list, widget.list2);
  // }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      productCtr.isSelectAll.value=false;
      productCtr.idsList.value.clear();
      productCtr.totalProspectPages.value=(productCtr.products.length / productCtr.itemsPerPage).ceil();
    });
    // Future.delayed(Duration.zero, () {
    //   apiService.changeList(widget.index);
    //   controllers.selectRadio(widget.list,widget.list2);
    //   apiService.currentVersion();
    //   controllers.groupController.selectIndex(0);
    //   setState(() {
    //     // controllers.search.clear();
    //     controllers.idList.clear();
    //     for (var lead in widget.list) {
    //       lead.select = false;
    //     }
    //     // apiService.newLeadList = [];
    //     // apiService.newLeadList.clear();
    //     // //Santhiya
    //     controllers.isAllSelected.value = false;
    //     // for (var item in controllers.isLeadsList) {
    //     //   item["isSelect"] = false;
    //     //
    //     //   widget.list.removeWhere(
    //     //         (e) => e.userId== item["lead_id"],
    //     //   );
    //     // }
    //   });
    //   controllers.searchProspects.value = "";
    // });
    _leftController.addListener(() {
      if (_rightController.hasClients &&
          (_rightController.offset != _leftController.offset)) {
        _rightController.jumpTo(_leftController.offset);
      }
    });
    _rightController.addListener(() {
      if (_leftController.hasClients &&
          (_leftController.offset != _rightController.offset)) {
        _leftController.jumpTo(_rightController.offset);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _horizontalController.dispose();
    _leftController.dispose();
    _rightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;
    double tableWidth;
    if (screenWidth >= 1600) {
      tableWidth = 4000;
    } else if (screenWidth >= 1200) {
      tableWidth = 3000;
    } else if (screenWidth >= 900) {
      tableWidth = 2400;
    } else {
      tableWidth = 2000;
    }
    var weWidth=MediaQuery.of(context).size.width;
    return SelectionArea(
      child: Scaffold(
        body: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SideBar(),
            Obx(() => Container(
              width:controllers.isLeftOpen.value?MediaQuery.of(context).size.width - 150:MediaQuery.of(context).size.width - 60,
                height: MediaQuery.of(context).size.height,
                alignment: Alignment.center,
                padding: EdgeInsets.fromLTRB(20, 5, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
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
                                  text: "Products",
                                  colors: colorsConst.textColor,
                                  size: 25,
                                  isBold: true,
                                  isCopy: true,
                                ),
                              ],
                            ),
                            10.height,
                            CustomText(
                              text: "View all of your Products Details\n\n\n",
                              colors: colorsConst.textColor,
                              size: 14,
                              isCopy: true,
                            ),
                          ],
                        ),
                        // Row(
                        //   children: [
                        //     // CustomLoadingButton(
                        //     //   callback: () async {
                        //     //     Get.to(AddOrderPage());
                        //     //   },
                        //     //   isLoading: false,
                        //     //   height: 35,
                        //     //   backgroundColor: colorsConst.primary,
                        //     //   radius: 2,
                        //     //   width: 150,
                        //     //   isImage: false,
                        //     //   text: "Invoice",
                        //     //   textColor: Colors.white,
                        //     // ),
                        //     // 10.width,
                        //     // CustomLoadingButton(
                        //     //   callback: () async {
                        //     //     Get.to(AddOrderPage());
                        //     //   },
                        //     //   isLoading: false,
                        //     //   height: 35,
                        //     //   backgroundColor: colorsConst.primary,
                        //     //   radius: 2,
                        //     //   width: 150,
                        //     //   isImage: false,
                        //     //   text: "Order",
                        //     //   textColor: Colors.white,
                        //     // ),
                        //     10.width,
                        //     CustomLoadingButton(
                        //       callback: () async {
                        //         // Get.to( AddProduct());
                        //       },
                        //       isLoading: false,
                        //       height: 35,
                        //       backgroundColor: colorsConst.primary,
                        //       radius: 2,
                        //       width: 150,
                        //       isImage: false,
                        //       text: "Add Product",
                        //       textColor: Colors.white,
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomSearchTextField(
                          controller: controllers.search,
                          hintText: "Search Name",
                          onChanged: (value) {
                            controllers.searchText.value = value.toString().trim();
                            setState(() {
                              final suggestions=productCtr.products2.where(
                                      (user){
                                    final customerName = user.title.toString().toLowerCase();
                                    final customerNo = user.hsnCode.toString().toLowerCase();
                                    final bankName = user.skuId.toString().toLowerCase();
                                    final input = value.toString().toLowerCase().trim();
                                    return customerName.contains(input) || customerNo.contains(input)|| bankName.contains(input);
                                  }).toList();
                              productCtr.products.value=suggestions;
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

                    Obx(() {
                      return Column(
                        children: [
                          /// 🔴 HEADER (Fixed)
                          Table(
                            border: TableBorder.all(color: Colors.grey.shade300),
                            columnWidths: {
                              0: FixedColumnWidth(weWidth / 3.5),
                              1: FixedColumnWidth(weWidth / 8),
                              2: FixedColumnWidth(weWidth / 8),
                              3: FixedColumnWidth(weWidth / 7),
                              4: FixedColumnWidth(weWidth / 9),
                              5: FixedColumnWidth(weWidth / 9)
                            },
                            children: [
                              TableRow(
                                decoration: BoxDecoration(
                                  color: colorsConst.primary,
                                ),
                                children: [
                                  headerCell("Name"),
                                  headerCell("SKU ID"),
                                  headerCell("HSN Code"),
                                  headerCell("Category"),
                                  headerCell("Sub Category"),
                                  headerCell("GST(in %)"),
                                ],
                              ),
                            ],
                          ),
                          productCtr.products.isEmpty?
                          Container(
                            alignment: Alignment.centerLeft,
                            height: MediaQuery.of(context).size.height*0.6,
                              child: CustomNoData()):
                          /// 🟢 BODY (Scrollable மட்டும்)
                          SizedBox(
                            height: MediaQuery.of(context).size.height*0.6, // 👈 scroll area
                            child: Obx(() {
                              if (productCtr.products.isEmpty) {
                                return const Center(
                                  child: CustomText(
                                    text: "No Orders Found",
                                    isCopy: false,
                                  ),
                                );
                              }

                              return SingleChildScrollView(
                                child: Table(
                                  border: TableBorder.all(color: Colors.grey.shade300),
                                  columnWidths: {
                                    0: FixedColumnWidth(weWidth / 3.5),
                                    1: FixedColumnWidth(weWidth / 8),
                                    2: FixedColumnWidth(weWidth / 8),
                                    3: FixedColumnWidth(weWidth / 7),
                                    4: FixedColumnWidth(weWidth / 9),
                                    5: FixedColumnWidth(weWidth / 9)
                                  },
                                  children: List.generate(productCtr.products.length, (index) {
                                    final e = productCtr.products[index];
                                    return TableRow(
                                      decoration: BoxDecoration(
                                        color: index % 2 == 0
                                            ? Colors.white
                                            : Colors.grey.shade50,
                                      ),
                                      children: [
                                        valueCell(e.title.toString()),
                                        valueCell(e.skuId.toString()),
                                        valueCell(e.hsnCode.toString()),
                                        valueCell(e.cat.toString()),
                                        valueCell(e.subCat.toString()),
                                        valueCell(e.gst.toString())
                                      ],
                                    );
                                  }),
                                ),
                              );
                            }),
                          ),
                        ],
                      );
                    }),
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
      ),
    );
  }
  Widget headerCell(String text) {
    return Container(
      height: 60, // 👈 heading height increase
      alignment: Alignment.centerLeft,
      child: Center(
        child: CustomText(
          text: text,size: 16,
          isCopy: false,
          isBold: true,
          colors: Colors.white,
        ),
      ),
    );
  }
  Widget valueCell(String text) {
    return Container(
      height: 50, // 👈 heading height increase
      alignment: Alignment.centerLeft,
      child: Center(
        child: CustomText(
          text: text,size: 16,
          isCopy: false,
        ),
      ),
    );
  }
}

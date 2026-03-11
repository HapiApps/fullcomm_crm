import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:fullcomm_crm/common/constant/colors_constant.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/common/styles/decoration.dart';
import 'package:fullcomm_crm/common/utilities/utils.dart';
import 'package:flutter/material.dart';
import 'package:fullcomm_crm/components/customer_name_tile.dart';
import 'package:fullcomm_crm/screens/products/add_product.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../common/utilities/mail_utils.dart';
import '../../components/custom_filter_seaction.dart';
import '../../components/custom_header_seaction.dart';
import '../../components/custom_lead_tile.dart';
import '../../components/custom_loading_button.dart';
import '../../components/custom_no_data.dart';
import '../../components/custom_sidebar.dart';
import '../../components/dynamic_table_header.dart';
import '../../components/custom_text.dart';
import '../../components/customer_name_header.dart';
import '../../controller/controller.dart';
import '../../controller/product_controller.dart';
import '../../controller/table_controller.dart';
import '../../models/new_lead_obj.dart';
import '../../services/api_services.dart';

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
                            CustomText(
                              text: "Products",
                              colors: colorsConst.textColor,
                              size: 25,
                              isBold: true,
                              isCopy: true,
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
                        Row(
                          children: [
                            // controllers.storage.read("role") != "See All Customer Records"
                            //     ? const SizedBox.shrink()
                            //     : CustomLoadingButton(
                            //   callback: () {
                            //     // if(widget.list.isEmpty){
                            //     //   mobileUtils.snackBar(
                            //     //       context: Get.context!,
                            //     //       msg: "No data available to export",
                            //     //       color: Colors.red);
                            //     // }else{
                            //     //   exportLeadsToExcel(widget.list, controllers.fields);
                            //     // }
                            //   },
                            //   isLoading: false,
                            //   height: 35,
                            //   backgroundColor: Colors.white,
                            //   radius: 2,
                            //   width: 100,
                            //   isImage: false,
                            //   text: "Export",
                            //   textColor: colorsConst.primary,
                            // ),
                            // 15.width,
                            // ---- Import button ----
                            // CustomLoadingButton(
                            //   callback: () {
                            //     utils.showImportDialogProduct(context);
                            //   },
                            //   isLoading: false,
                            //   height: 35,
                            //   backgroundColor: Colors.white,
                            //   radius: 2,
                            //   width: 100,
                            //   isImage: false,
                            //   text: "Import",
                            //   textColor: colorsConst.primary,
                            // ),
                            // 15.width,
                            // ---- Add Lead button ----
                            CustomLoadingButton(
                              callback: () async {
                                Get.to( AddProduct());
                              },
                              isLoading: false,
                              height: 35,
                              backgroundColor: colorsConst.primary,
                              radius: 2,
                              width: 150,
                              isImage: false,
                              text: "Add Product",
                              textColor: Colors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Obx(() {
                      if (productCtr.products.isEmpty) {
                        return const Center(
                          child: CustomText(
                            text: "No Products Found",
                            isCopy: false,
                          ),
                        );
                      }

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Table(
                          border: TableBorder.all(color: Colors.grey.shade300),
                          columnWidths: {
                            0: FixedColumnWidth(weWidth / 8),
                            1: FixedColumnWidth(weWidth / 8),
                            2: FixedColumnWidth(weWidth / 8),
                            3: FixedColumnWidth(weWidth / 8),
                            4: FixedColumnWidth(weWidth / 8),
                            5: FixedColumnWidth(weWidth / 8),
                            6: FixedColumnWidth(weWidth / 8),
                          },
                          children: [

                            /// HEADER
                            TableRow(
                              decoration: BoxDecoration(
                                color: colorsConst.primary,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                ),
                              ),
                              children: [
                                headerCell("Title"),
                                headerCell("Description"),
                                headerCell("Availability"),
                                headerCell("Condition"),
                                headerCell("Price"),
                                headerCell("Brand"),
                                headerCell("Image"),
                              ],
                            ),

                            /// DATA ROWS
                            ...List.generate(productCtr.products.length, (index) {
                              final e = productCtr.products[index];

                              return TableRow(
                                decoration: BoxDecoration(
                                  color: index % 2 == 0
                                      ? Colors.white
                                      : const Color(0xffF8FAFC), // alternate row color
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: CustomText(
                                      text: e.title ?? "",
                                      isCopy: true,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: CustomText(
                                      text: e.description ?? "",
                                      isCopy: true,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: CustomText(
                                      text: e.availability ?? "",
                                      isCopy: true,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: CustomText(
                                      text: e.condition.toString(),
                                      isCopy: true,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: CustomText(
                                      text: e.price.toString(),
                                      isCopy: true,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: CustomText(
                                      text: e.brand.toString(),
                                      isCopy: true,
                                    ),
                                  ),

                                  /// IMAGE COLUMN
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: e.imageLink == null || e.imageLink!.isEmpty
                                        ? const CustomText(
                                      text: "No Image",
                                      isCopy: false,
                                    )
                                        : ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: CachedNetworkImage(
                                            imageUrl: e.imageLink!,fit:BoxFit.cover ,
                                            imageBuilder: (context, imageProvider) =>
                                            Container(
                                              decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover,
                                              ),
                                              ),
                                            ),
                                            errorWidget: (context,url,error)=>Icon(Icons.error_outline,color: Colors.black,),
                                            placeholder: (context,url)=>Icon(Icons.error_outline,color: Colors.black,)
                                            )
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      );
                    }),
                    20.height,
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
}

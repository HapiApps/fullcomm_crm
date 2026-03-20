import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/common/utilities/utils.dart';
import 'package:fullcomm_crm/components/custom_loading_button.dart';
import 'package:fullcomm_crm/screens/invoice/invoice.dart';
import 'package:fullcomm_crm/screens/order/place_order.dart';
import 'package:get/get.dart';

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

class _OrderPageState extends State<OrderPage> {
  final ScrollController _controller = ScrollController();
  late FocusNode _focusNode;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      // productCtr.isSelectAll.value=false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    controllers.totalProspectPages.value=(productCtr.ordersList.length / controllers.itemsPerPage).ceil();
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
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CustomLoadingButton(
                        callback: () async {
                          Get.to(AddOrderPage());
                        },
                        isLoading: false,
                        height: 35,
                        backgroundColor: colorsConst.primary,
                        radius: 2,
                        width: 150,
                        isImage: false,
                        text: "Place Order",
                        textColor: Colors.white,
                      )
                    ],
                  ),
                  10.height,
                  Container(
                    alignment: Alignment.topLeft,
                    height: MediaQuery.of(context).size.height - 345,
                    child: Obx(() {
                      if (productCtr.ordersList.isEmpty) {
                        return const Center(
                          child: CustomText(
                            text: "No Orders Found",
                            isCopy: false,
                          ),
                        );
                      }

                      return Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            color: colorsConst.primary,
                            child: Row(
                              children: [
                                SizedBox(width: 80, child: headerText("Order No")),
                                SizedBox(width: 100, child: headerText("Customer")),
                                SizedBox(width: 90, child: headerText("Total Amount")),
                                SizedBox(width: 120, child: headerText("Order Date")),
                                SizedBox(width: 80, child: headerText("Invoice")),
                              ],
                            ),
                          ),
                          /// DATA ROWS
                          Expanded(
                            child: ListView.builder(
                              itemCount: productCtr.ordersList.length,
                              itemBuilder: (context, index) {
                                final e = productCtr.ordersList[index];

                                return Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: index % 2 == 0
                                        ? Colors.white
                                        : Colors.grey.shade100,
                                    border: Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Row(
                                    children: [

                                      /// Order No
                                      SizedBox(
                                        width: 80,
                                        child: CustomText(
                                          text: e.orderId,
                                          isCopy: true,
                                        ),
                                      ),

                                      /// Customer
                                      Expanded(
                                        child: CustomText(
                                          text: e.customerName,
                                          isCopy: true,
                                        ),
                                      ),

                                      /// Total Amount
                                      SizedBox(
                                        width: 120,
                                        child: CustomText(
                                          text: e.totalAmt,
                                          isCopy: true,
                                        ),
                                      ),

                                      /// Date
                                      SizedBox(
                                        width: 150,
                                        child: CustomText(
                                          text: e.createdTs,
                                          isCopy: true,
                                        ),
                                      ),

                                      /// Invoice Button
                                      SizedBox(
                                        width: 100,
                                        child: TextButton(
                                          onPressed: () {
                                            // TODO: invoice action
                                          },
                                          child: CustomText(
                                            text: "Invoice",
                                            colors: colorsConst.primary, isCopy: false,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          )
                        ],
                      );
                    }),
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
            ),
          ],
        ),
      ),
    );
  }
  Widget headerText(String text) {
    return CustomText(
      text: text,
      isBold: true,
      colors: Colors.white, isCopy: false,
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
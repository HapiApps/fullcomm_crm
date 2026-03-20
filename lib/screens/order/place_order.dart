import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/common/utilities/utils.dart';
import 'package:fullcomm_crm/components/custom_loading_button.dart';
import 'package:fullcomm_crm/screens/invoice/invoice.dart';
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

class AddOrderPage extends StatefulWidget {
  const AddOrderPage({super.key});

  @override
  State<AddOrderPage> createState() => _AddOrderPageState();
}

class _AddOrderPageState extends State<AddOrderPage> {
  TextEditingController searchCtr = TextEditingController();
  List<ProductModel> filteredList = [];
  bool showDropdown = false;
  @override
  void initState() {
    super.initState();
    filteredList = productCtr.products;
  }

  void filterProducts(String value) {
    setState(() {
      showDropdown = true;
      filteredList = productCtr.products
          .where((p) => (p.title ?? "")
          .toLowerCase()
          .contains(value.toLowerCase()))
          .toList();
    });
  }

  void selectProduct(ProductModel p) {
    productCtr.addProducts(p);
    searchCtr.clear();

    setState(() {
      showDropdown = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var webWidth=MediaQuery.of(context).size.width*7;
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
              padding: EdgeInsets.fromLTRB(16, 5, 16, 16),
              child: Column(
                children: [
                  22.height,
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
                                child: Icon(Icons.arrow_back),
                              ),10.width,
                              CustomText(
                                text:
                                "Orders",
                                colors: colorsConst.textColor,
                                size: 23,
                                isBold: true,
                                isCopy: true,
                              ),
                            ],
                          ),
                          5.height,
                          // CustomText(
                          //   text:
                          //   "Invoice Products Information\n\n",
                          //   colors: colorsConst.textColor,
                          //   size: 15,
                          //   isCopy: true,
                          // ),
                        ],
                      ),
                    ],
                  ),
                  /// 🔍 SEARCH FIELD
                  SizedBox(
                    width:MediaQuery.of(context).size.width*0.7,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width*0.33,
                          child: Column(
                            children: [
                              TextField(
                                controller: searchCtr,
                                decoration: const InputDecoration(
                                  hintText: "Search Product",
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: filterProducts,
                              ),

                              /// 🔽 DROPDOWN LIST
                              if (showDropdown)
                                Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                  ),
                                  child: ListView.builder(
                                    itemCount: filteredList.length,
                                    itemBuilder: (context, index) {
                                      final p = filteredList[index];

                                      bool alreadyAdded = productCtr.rows
                                          .any((e) => e.product?.id == p.id);

                                      return ListTile(
                                        title: Text(p.title ?? ""),
                                        subtitle: Text("₹ ${p.title}"),
                                        trailing: alreadyAdded
                                            ? const Text("Added",
                                            style: TextStyle(color: Colors.red))
                                            : null,
                                        onTap: alreadyAdded
                                            ? null
                                            : () => selectProduct(p),
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 50,
                          width: MediaQuery.of(context).size.width*0.33,
                          child: KeyboardDropdownField<AllCustomersObj>(
                            items: controllers.customers,
                            borderRadius: 5,
                            borderColor: Colors.black,
                            hintText: "Customers",
                            labelText: "Customers",

                            labelBuilder: (customer) =>
                            '${customer.name}${customer.companyName.toString().isEmpty ? "" : ", ${customer.companyName}"} ${customer.name.toString().isEmpty ? "" : "-"} ${customer.phoneNo} - ${customer.category}',

                            itemBuilder: (customer) {
                              return Container(
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: CustomText(
                                  text:
                                  '${customer.name}${customer.companyName.toString().isEmpty ? "" : ", ${customer.companyName}"} ${customer.name.toString().isEmpty ? "" : "-"} ${customer.phoneNo} - ${customer.category}',
                                  size: 14,
                                  isCopy: false,
                                ),
                              );
                            },

                            textEditingController: controllers.cusController,

                            onSelected: (value) {
                              controllers.selectCustomer(value);
                            },
                            onClear: () {
                              controllers.clearSelectedCustomer();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  10.height,

                  /// 📊 TABLE
                  SizedBox(
                    width:MediaQuery.of(context).size.width*0.7,
                    child: Obx(() => Table(
                      border: TableBorder.all(color: Colors.grey.shade300),
                      columnWidths: const {
                        0: FixedColumnWidth(10),
                        1: FixedColumnWidth(40),
                        2: FixedColumnWidth(35),
                        3: FixedColumnWidth(35),
                        4: FixedColumnWidth(35),
                        5: FixedColumnWidth(35),
                      },
                      children: [

                        /// HEADER
                        TableRow(
                          decoration: const BoxDecoration(color: Colors.blue),
                          children: [
                            headerCell("S.No"),
                            headerCell("Product"),
                            headerCell("Qty"),
                            headerCell("Price"),
                            headerCell("Amount"),
                            headerCell("Delete"),
                          ],
                        ),

                        /// ROWS
                        ...List.generate(productCtr.rows.length, (index) {
                          final row = productCtr.rows[index];

                          return TableRow(
                            children: [

                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: CustomText(text: "${index+1}",isCopy: false,),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: CustomText(text: row.product?.title ?? "",isCopy: false,),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: TextFormField(
                                  initialValue: row.qty.toString(),
                                  keyboardType: TextInputType.number,
                                  onChanged: (val) {
                                    productCtr.updateQty(
                                        index, int.tryParse(val) ?? 0);
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: CustomText(text: "₹ ${row.price}",isCopy: false,),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: CustomText(text:"₹ ${row.amount}",isCopy: false,),
                              ),
                              IconButton(
                                onPressed: () => productCtr.removeRow(index),
                                icon: Image.asset("assets/images/action_delete.png"),
                              ),
                            ],
                          );
                        }),
                      ],
                    )),
                  ),

                  20.height,
                  if(productCtr.rows.isNotEmpty)
                    Obx(() => SizedBox(
                      width:MediaQuery.of(context).size.width*0.7,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "Total: ₹ ${productCtr.getTotal()}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          20.width,
                          CustomLoadingButton(
                              callback: (){
                                if(productCtr.rows.isEmpty){
                                  utils.snackBar(context: context, msg: "Please add products", color: Colors.red);
                                  productCtr.saveCtr.reset();
                                }else if(controllers.selectedCustomerId.value==""){
                                  utils.snackBar(context: context, msg: "Please select customer", color: Colors.red);
                                  productCtr.saveCtr.reset();
                                }else{
                                  productCtr.insertOrder(context,"${productCtr.getTotal()}",controllers.selectedCustomerId.value);
                                }
                              }, isLoading: true,controller: productCtr.saveCtr,text: "Place Order",
                              backgroundColor: colorsConst.primary, radius: 5, width: 100)
                        ],
                      ),
                    )),
                ],
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
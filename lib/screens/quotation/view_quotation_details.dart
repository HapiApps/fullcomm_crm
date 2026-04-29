import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fullcomm_crm/common/styles/decoration.dart';
import 'package:fullcomm_crm/controller/controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:fullcomm_crm/screens/leads/update_lead.dart';
import 'package:fullcomm_crm/services/api_services.dart';
import '../../common/constant/api.dart';
import '../../common/constant/colors_constant.dart';
import '../../common/utilities/reminder_utils.dart';
import '../../common/utilities/utils.dart';
import '../../components/custom_loading_button.dart';
import '../../components/custom_sidebar.dart';
import '../../components/custom_text.dart';
import '../../controller/image_controller.dart';
import '../../controller/product_controller.dart';
import '../../models/customer_full_obj.dart';
import '../../models/new_lead_obj.dart';
import '../../models/order_model.dart';
import '../invoice/invoice.dart';

class ViewQuotationDetails extends StatefulWidget {
  final String id;
  final Quotations list;
  const ViewQuotationDetails({
    super.key,
    required this.id,required this.list,
  });

  @override
  State<ViewQuotationDetails> createState() => _ViewQuotationDetailsState();
}

class _ViewQuotationDetailsState extends State<ViewQuotationDetails> {

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      productCtr.getQuotationFullDetails(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return SelectionArea(
      child: Scaffold(
        backgroundColor: colorsConst.backgroundColor,
        body: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SideBar(),
            Container(
              width: screenWidth - 150,
              height: MediaQuery.of(context).size.height,
              alignment: Alignment.center,
              padding: EdgeInsets.all(20),
              child: Obx(
                    () => productCtr.dataRefresh.value==false
                    ? const CircularProgressIndicator()
                    : ListView.builder(
                      itemCount: productCtr.quotationsListDetail.length,
                        itemBuilder: (context,index){
                        var data = productCtr.quotationsListDetail[index];
                        var pName=widget.list.pName.toString().split("||");
                        var qty=widget.list.qty.toString().split("||");
                        // var mrp=widget.list.mrp.toString().split("||");
                        var price=widget.list.price.toString().split("||");
                        var amt=widget.list.amount.toString().split("||");
                        List<Map<String, dynamic>> products = [];
                        for (int i = 0; i < pName.length; i++) {
                          products.add({
                            "name": pName[i],
                            "qty": qty[i],
                            "price": price[i],
                            "amt": amt[i],
                          });
                        }
                        products.sort((a, b) =>a['name'].toLowerCase().compareTo(b['name'].toLowerCase()));
                        var pName2=data.pName.toString().split("||");
                        var qty2=data.qty.toString().split("||");
                        var mrp2=data.mrp.toString().split("||");
                        var price2=data.price.toString().split("||");
                        var amt2=data.amount.toString().split("||");
                        List<Map<String, dynamic>> products2 = [];
                        for (int i = 0; i < pName2.length; i++) {
                          products2.add({
                            "name": pName2[i],
                            "qty": qty2[i],
                            "price": price2[i],
                            "amt": amt2[i],
                          });
                        }
                        print("$getImage?path=${data.po}");
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              20.height,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: screenWidth / 2.5,
                                    child: Row(
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            Get.back();
                                          },
                                          icon: Icon(
                                            Icons.arrow_back,
                                            color: colorsConst.third,
                                          ),
                                        ),
                                        CustomText(
                                          text: "View Quotation Details",
                                          isCopy: true,
                                          colors: colorsConst.textColor,
                                          size: 20,
                                          isBold: true,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              10.height,
                              Divider(
                                color: Colors.grey.shade300,
                                thickness: 0.5,
                              ),
                              20.height,
                              Container(
                                    decoration: customDecoration.baseBackgroundDecoration(
                                        color: Colors.white,borderColor: Colors.grey.shade200,radius: 10
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CustomText(text: "Company Details",size: 16, isCopy: false,isBold: true,colors: colorsConst.primary,),
                                          10.height,
                                          Row(
                                            children: [
                                              rowText("Company Name",widget.list.company),
                                              20.width,
                                              rowText("Customer Name",widget.list.name),20.width,
                                              rowText("Phone Number",widget.list.number),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )),
                              10.height,
                              Container(
                                decoration: customDecoration.baseBackgroundDecoration(
                                  color: Colors.white,borderColor: Colors.grey.shade200,radius: 10
                                ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            CustomText(text: "Quotation Detail",size: 16, isCopy: false,isBold: true,colors: colorsConst.primary,),20.width,
                                            rowText("Quotation Number",widget.list.quotationNo),20.width,
                                            rowText("Quotation Status",widget.list.status),
                                            rowText("Send Date",productCtr.showCrtDate(widget.list.createdTs.toString())),
                                          ],
                                        ),
                                        10.height,
                                        Table(
                                          border: TableBorder(
                                            horizontalInside: BorderSide(
                                                width: 0.5,
                                                color: Colors.grey.shade400),
                                            verticalInside: BorderSide(width: 0.5,
                                                color: Colors.grey.shade400),
                                          ),
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
                                              decoration: BoxDecoration(
                                                  color: colorsConst.primary,
                                                  borderRadius: const BorderRadius.only(
                                                      topLeft: Radius.circular(5),
                                                      topRight: Radius.circular(5)
                                                  )),
                                              children: [
                                                header("S.No"),
                                                header("Product Name"),
                                                header("Qty"),
                                                header("Price"),
                                                header("Total"),
                                              ],
                                            ),

                                            /// DATA
                                            ...List.generate(products.length, (i) {
                                              return TableRow(
                                                decoration: BoxDecoration(
                                                  color: int.parse(
                                                      i.toString()) %
                                                      2 == 0 ? Colors
                                                      .white : colorsConst
                                                      .backgroundColor,
                                                ),
                                                children: [
                                                  cell("${i + 1}"),
                                                  cell(products[i]["name"]),
                                                  cell(products[i]["qty"]),
                                                  cell(productCtr.formatAmount(products[i]["price"])),
                                                  cell(productCtr.formatAmount(products[i]["amount"])),
                                                ],
                                              );
                                            }),
                                            TableRow(
                                              decoration: BoxDecoration(
                                                  color: Colors.grey.shade100,
                                                  borderRadius: const BorderRadius.only(
                                                      bottomLeft: Radius.circular(5),
                                                      bottomRight: Radius.circular(5)
                                                  )),
                                              children: [
                                                cell(""),
                                                cell("Total"),
                                                cell(widget.list.totalItem.toString()),
                                                cell(""),
                                                cell(productCtr.formatAmount(widget.list.totalAmt.toString())),
                                              ],
                                            ),
                                          ],
                                        ),
                                        10.height,
                                      ],
                                    ),
                                  )),
                              10.height,
                              if(widget.list.poNumber!="null"&&widget.list.poNumber!="")
                              Container(
                                  decoration: customDecoration.baseBackgroundDecoration(
                                      color: Colors.white,borderColor: Colors.grey.shade200,radius: 10
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CustomText(text: "PO Detail",size: 16, isCopy: false,isBold: true,colors: colorsConst.primary,),
                                        10.height,
                                        rowText("PO Date",widget.list.poDate),10.height,
                                        rowText("PO Number",widget.list.poNumber),10.height,
                                        if(data.po!="null"&&data.po!="")
                                        CachedNetworkImage(
                                            imageUrl: "$getImage?path=${data.po}",fit:BoxFit.cover ,
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
                                            errorWidget: (context,url,error)=>Icon(Icons.error_outline_sharp,color: Colors.black,),
                                            placeholder: (context,url)=>Icon(Icons.error_outline_sharp,color: Colors.black,)
                                        )
                                      ],
                                    ),
                                  )),
                              10.height,
                              if(products2[0]["name"]!="null"&&products2[0]["name"]!="")
                              Container(
                                  decoration: customDecoration.baseBackgroundDecoration(
                                      color: Colors.white,borderColor: Colors.grey.shade200,radius: 10
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            CustomText(text: "Invoice Detail",size: 16, isCopy: false,isBold: true,colors: colorsConst.primary,),20.width,
                                            rowText("Invoice Number",widget.list.iNo),
                                          ],
                                        ),
                                        10.height,
                                        Table(
                                          border: TableBorder(
                                            horizontalInside: BorderSide(
                                                width: 0.5,
                                                color: Colors.grey.shade400),
                                            verticalInside: BorderSide(width: 0.5,
                                                color: Colors.grey.shade400),
                                          ),
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
                                              decoration: BoxDecoration(
                                                  color: colorsConst.primary,
                                                  borderRadius: const BorderRadius.only(
                                                      topLeft: Radius.circular(5),
                                                      topRight: Radius.circular(5)
                                                  )),
                                              children: [
                                                header("S.No"),
                                                header("Product Name"),
                                                header("Qty"),
                                                header("Price"),
                                                header("Total"),
                                              ],
                                            ),

                                            /// DATA
                                            ...List.generate(products2.length, (i) {
                                              return TableRow(
                                                decoration: BoxDecoration(
                                                  color: int.parse(
                                                      i.toString()) %
                                                      2 == 0 ? Colors
                                                      .white : colorsConst
                                                      .backgroundColor,
                                                ),
                                                children: [
                                                  cell("${i + 1}"),
                                                  cell(products2[i]["name"]),
                                                  cell(products2[i]["qty"]),
                                                  cell(productCtr.formatAmount(products2[i]["price"])),
                                                  cell(productCtr.formatAmount(products2[i]["amount"])),
                                                ],
                                              );
                                            }),
                                            TableRow(
                                              decoration: BoxDecoration(
                                                  color: Colors.grey.shade100,
                                                  borderRadius: const BorderRadius.only(
                                                      bottomLeft: Radius.circular(5),
                                                      bottomRight: Radius.circular(5)
                                                  )),
                                              children: [
                                                cell(""),
                                                cell("Total"),
                                                cell(data.totalItem.toString()),
                                                cell(""),
                                                cell(productCtr.formatAmount(data.totalAmt.toString())),
                                              ],
                                            ),
                                          ],
                                        ),
                                        10.height,
                                      ],
                                    ),
                                  )),

                              10.height,
                            ],
                          );
                        }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
Widget header(String text) {
  return Padding(
    padding: const EdgeInsets.all(10),
    child: CustomText(
      text:text,isCopy: false,isBold: true,colors: Colors.white,size: 16,
      textAlign: TextAlign.center,
    ),
  );
}
Widget cell(String text) {
  return Padding(
    padding: const EdgeInsets.all(10),
    child: CustomText(text:text, textAlign: TextAlign.center,isCopy: true,size: 16),
  );
}
Widget rowText(String text,String value){
  return Row(
    children: [
      CustomText(text: text, isCopy: true,size: 16,isBold: true,),
      CustomText(text: value, isCopy: true,size: 16)
    ],
  );
}
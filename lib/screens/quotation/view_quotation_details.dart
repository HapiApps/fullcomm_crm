import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_line/dotted_line.dart';
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
                        var gst=widget.list.gst.toString().split("||");
                        var price=widget.list.price.toString().split("||");
                        var amt=widget.list.amount.toString().split("||");
                        List<Map<String, dynamic>> products = [];
                        for (int i = 0; i < pName.length; i++) {
                          products.add({
                            "name": pName[i],
                            "qty": qty[i],
                            "price": price[i],
                            "amount": amt[i],
                            "gst": gst[i],
                          });
                        }
                        products.sort((a, b) =>a['name'].toLowerCase().compareTo(b['name'].toLowerCase()));
                        var pName2=data.pName.toString().split("||");
                        var qty2=data.qty.toString().split("||");
                        var gst2=data.gst.toString().split("||");
                        var price2=data.price.toString().split("||");
                        var amt2=data.amount.toString().split("||");
                        List<Map<String, dynamic>> products2 = [];
                        for (int i = 0; i < pName2.length; i++) {
                          products2.add({
                            "name": pName2[i],
                            "qty": qty2[i],
                            "price": price2[i],
                            "amount": amt2[i],
                            "gst": gst2[i],
                          });
                        }
                        // print("$getImage?path=${data.po}");
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              20.height,
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Get.back();
                                    },
                                    child: Icon(
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomText(
                                    text: widget.list.quotationNo,
                                    isCopy: true,
                                    colors: colorsConst.textColor,
                                    size: 20,
                                  ),
                                  Container(
                                    decoration: customDecoration.baseBackgroundDecoration(
                                        color: widget.list.status=="Quotation Sent"?Colors.pink.shade50
                                            :widget.list.status=="PO Received"?Colors.blue.shade50
                                            :widget.list.status=="Proforma Invoice Sent"?Colors.orange.shade50:Colors.green.shade50,radius: 20
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Row(
                                        children: [
                                          CircleAvatar(radius: 5,backgroundColor: widget.list.status=="Quotation Sent"?Colors.pink
                                              :widget.list.status=="PO Received"?Colors.blue
                                              :widget.list.status=="Proforma Invoice Sent"?Colors.orange:Colors.green),5.width,
                                          CustomText(
                                            text: widget.list.status,
                                            isCopy: true,
                                            colors: widget.list.status=="Quotation Sent"?Colors.pink
                                                :widget.list.status=="PO Received"?Colors.blue
                                                :widget.list.status=="Proforma Invoice Sent"?Colors.orange:Colors.green,
                                            isBold: true,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              5.height,
                              Divider(
                                color: Colors.grey.shade300,
                                thickness: 0.5,
                              ),
                              20.height,
                              Center(
                                child: Container(
                                    width: screenWidth/1.5,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(20),
                                        bottomLeft: Radius.circular(20),
                                      ),
                                      border: Border.all(color: Colors.grey.shade200),
                                    ),
                                  child: Column(
                                    children: [
                                      Center(
                                        child: Container(
                                          width: screenWidth/1.5,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: colorsConst.primary,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(35),
                                              topRight: Radius.circular(35),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            CustomText(text: "QUOTATION LIFECYCLE", isCopy: true,isBold: true,size: 16,),
                                            10.height,
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                expandedStep(
                                                  width: screenWidth/5.6,
                                                  title: "Quotation Sent",
                                                  subTitle: DateFormat("dd MMM yyyy").format(DateTime.parse(widget.list.createdTs)),
                                                  isCompleted: true,
                                                  isLast: false,
                                                ),
                                                expandedStep(
                                                  width: screenWidth/5.6,
                                                  title: "PO Received",
                                                  subTitle: widget.list.poDate==""?"-":widget.list.poDate,
                                                  isCompleted: widget.list.poDate==""?false:true,
                                                  isLast: false,
                                                  isPending: widget.list.status=="Quotation Sent"?true:false,
                                                  stepNumber: "2",
                                                ),
                                                expandedStep(
                                                  width: screenWidth/5.6,
                                                  title: "Proforma Invoice",
                                                  subTitle: "Optional",
                                                  isCompleted: widget.list.status=="Invoice Sent"||widget.list.status=="Proforma Invoice Sent"?true:false,
                                                  isLast: false,
                                                  stepNumber: "3",
                                                  isPending: widget.list.status=="PO Received"&&
                                                      widget.list.status!="Invoice Sent"?true:false,
                                                ),
                                                expandedStep(
                                                  width: screenWidth/5.6,
                                                  title: "Invoice Sent",
                                                  subTitle: widget.list.status=="PO Received"?"In Progress":"-",
                                                  isCompleted: widget.list.status=="Invoice Sent"?true:false,
                                                  isLast: true,
                                                  stepNumber: "4",
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              20.height,
                              Center(
                                child: Container(
                                  width: screenWidth/1.5,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: colorsConst.primary,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      20.width,
                                      Image.asset("assets/images/company.png",width: 20,height: 20,),20.width,
                                      CustomText(text: "Company & Customer Details", isCopy: true,isBold: true,size: 16,colors: Colors.white,),
                                    ],
                                  ),
                                ),
                              ),
                              Center(
                                child: Container(
                                  width: screenWidth/1.5,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(20),
                                      bottomRight: Radius.circular(20),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            CustomText(text: "COMPANY NAME", isCopy: true),10.height,
                                            CustomText(text: widget.list.company, isCopy: true,isBold: true,),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            CustomText(text: "CUSTOMER NAME", isCopy: true),10.height,
                                            CustomText(text: widget.list.name, isCopy: true,isBold: true,),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            CustomText(text: "PHONE NUMBER", isCopy: true),10.height,
                                            CustomText(text: widget.list.number, isCopy: true,isBold: true,),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              10.height,
                              Center(
                                child: Container(
                                  width: screenWidth/1.5,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: colorsConst.primary,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      20.width,
                                      Image.asset("assets/images/document.png",width: 20,height: 20,),20.width,
                                      CustomText(text: "Quotation Details", isCopy: true,isBold: true,size: 16,colors: Colors.white,),
                                    ],
                                  ),
                                ),
                              ),
                              Center(
                                child: Container(
                                  width: screenWidth/1.5,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(20),
                                      bottomRight: Radius.circular(20),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                CustomText(text: "Quotation No", isCopy: true),10.height,
                                                CustomText(text: widget.list.quotationNo, isCopy: true,isBold: true,),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                CustomText(text: "Date", isCopy: true),10.height,
                                                CustomText(text: controllers.formatDateTime(widget.list.createdTs), isCopy: true,isBold: true,),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                CustomText(text: "Sent By", isCopy: true),10.height,
                                                CustomText(text: data.name, isCopy: true,isBold: true,),
                                              ],
                                            )
                                          ],
                                        ),
                                        Divider(color: Colors.grey.shade300,),
                                        10.height,
                                        Table(
                                          // border: TableBorder(
                                          //   horizontalInside: BorderSide(
                                          //       width: 0.5,
                                          //       color: Colors.grey.shade400),
                                          //   verticalInside: BorderSide(width: 0.5,
                                          //       color: Colors.grey.shade400),
                                          // ),
                                          columnWidths: const {
                                            0: FixedColumnWidth(60),
                                            1: FlexColumnWidth(),
                                            2: FixedColumnWidth(80),
                                            3: FixedColumnWidth(80),
                                            4: FixedColumnWidth(80),
                                            5: FixedColumnWidth(100),
                                          },
                                          children: [

                                            /// HEADER
                                            TableRow(
                                              decoration: BoxDecoration(
                                                  color: Color(0xFF9FD5FF),
                                                  // borderRadius: const BorderRadius.only(
                                                  //     topLeft: Radius.circular(5),
                                                  //     topRight: Radius.circular(5)
                                                  // )
                                              ),
                                              children: [
                                                header("S.NO"),
                                                header("PRODUCT NAME"),
                                                header("QTY"),
                                                header("PRICE"),
                                                header("GST"),
                                                header("TOTAL"),
                                              ],
                                            ),

                                            /// DATA
                                            ...List.generate(products.length, (i) {
                                              return TableRow(
                                                decoration: BoxDecoration(
                                                  // color: int.parse(
                                                  //     i.toString()) %
                                                  //     2 == 0 ? Colors
                                                  //     .white : colorsConst
                                                  //     .backgroundColor,
                                                  border: Border(
                                                    bottom: BorderSide(
                                                      color: Colors.grey.shade200,
                                                      width: 1.5,
                                                    ),
                                                  ),
                                                ),
                                                children: [
                                                  cell("${i + 1}"),
                                                  cell(products[i]["name"]),
                                                  cell(products[i]["qty"]),
                                                  cell(productCtr.formatAmount(products[i]["price"])),
                                                  cell(products[i]["gst"]),
                                                  cell(productCtr.formatAmount(products[i]["amount"])),
                                                ],
                                              );
                                            }),
                                            TableRow(
                                              // decoration: BoxDecoration(
                                              //     color: Colors.grey.shade100,
                                              //     borderRadius: const BorderRadius.only(
                                              //         bottomLeft: Radius.circular(5),
                                              //         bottomRight: Radius.circular(5)
                                              //     )),
                                              children: [
                                                cell(""),
                                                cell(""),
                                                // cell(widget.list.totalItem.toString()),
                                                cell(""),
                                                cell(""),
                                                cell("TOTAL",colors: colorsConst.primary),
                                                cell(productCtr.formatAmount(widget.list.totalAmt.toString()),colors: colorsConst.primary),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              20.height,
                              if(widget.list.poNumber!="null"&&widget.list.poNumber!="")
                              Column(
                                children: [
                                  Center(
                                    child: Container(
                                      width: screenWidth/1.5,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: colorsConst.primary,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          20.width,
                                          Image.asset("assets/images/document.png",width: 20,height: 20,),20.width,
                                          CustomText(text: "Purchase Order Details", isCopy: true,isBold: true,size: 16,colors: Colors.white,),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Container(
                                      width: screenWidth/1.5,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(20),
                                          bottomRight: Radius.circular(20),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    CustomText(text: "PO No", isCopy: true),10.height,
                                                    CustomText(text: widget.list.poNumber, isCopy: true,isBold: true,),
                                                  ],
                                                ),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    CustomText(text: "PO Date", isCopy: true),10.height,
                                                    CustomText(text: widget.list.poDate, isCopy: true,isBold: true,),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Divider(color: Colors.grey.shade300,),
                                            10.height,
                                            CustomText(text: "ATTACHED DOCUMENTS", isCopy: true,isBold: true,),
                                            10.height,
                                            Container(
                                              decoration: customDecoration.baseBackgroundDecoration(
                                                color: Colors.grey.shade50,
                                                borderColor: Colors.grey.shade200,radius: 10
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(15),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Image.asset("assets/images/pdf.png",width: 35,height: 35,),10.width,
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            CustomText(text: "PO_MTP_0031_Meridian_Jan_2026.pdf ", isCopy: true,isBold: true,),
                                                            Row(
                                                              children: [
                                                                CustomText(text: "2.4 MB", isCopy: true),5.width,
                                                                CircleAvatar(backgroundColor: Colors.black,radius: 2,),5.width,
                                                                CustomText(text: "Uploaded on 18 Jan 2026", isCopy: true),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Container(
                                                          decoration: customDecoration.baseBackgroundDecoration(
                                                              color: Colors.grey.shade50,
                                                              borderColor: Colors.grey.shade200,radius: 10
                                                          ),
                                                          child: Padding(
                                                            padding: const EdgeInsets.all(5),
                                                            child: Row(
                                                              children: [
                                                                Icon(Icons.remove_red_eye_outlined,color: Colors.grey,),5.width,
                                                                CustomText(text: "View", isCopy: true,isBold: true,colors: Colors.grey),
                                                              ],
                                                            ),
                                                          ),
                                                        ),20.width,
                                                        Container(
                                                          decoration: customDecoration.baseBackgroundDecoration(
                                                              color: Colors.grey.shade50,
                                                              borderColor: Colors.grey.shade200,radius: 10
                                                          ),
                                                          child: Padding(
                                                            padding: const EdgeInsets.all(5),
                                                            child: Row(
                                                              children: [
                                                                Icon(Icons.file_download_outlined,color: Colors.grey,),5.width,
                                                                CustomText(text: "Download", isCopy: true,isBold: true,colors: Colors.grey),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  20.height
                                ],
                              ),

                              if(widget.list.iNo!="null"&&widget.list.iNo!="")
                              Column(
                                children: [
                                  Center(
                                    child: Container(
                                      width: screenWidth/1.5,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: colorsConst.primary,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          20.width,
                                          Image.asset("assets/images/document.png",width: 20,height: 20,),20.width,
                                          CustomText(text: "Invoice Details", isCopy: true,isBold: true,size: 16,colors: Colors.white,),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Container(
                                      width: screenWidth/1.5,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(20),
                                          bottomRight: Radius.circular(20),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    CustomText(text: "Invoice No", isCopy: true),10.height,
                                                    CustomText(text: widget.list.iNo, isCopy: true,isBold: true,),
                                                  ],
                                                ),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    CustomText(text: "Invoice Date", isCopy: true),10.height,
                                                    CustomText(text: controllers.formatDateTime(widget.list.invoiceDate), isCopy: true,isBold: true,),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Divider(color: Colors.grey.shade300,),
                                            10.height,
                                            Table(
                                              // border: TableBorder(
                                              //   horizontalInside: BorderSide(
                                              //       width: 0.5,
                                              //       color: Colors.grey.shade400),
                                              //   verticalInside: BorderSide(width: 0.5,
                                              //       color: Colors.grey.shade400),
                                              // ),
                                              columnWidths: const {
                                                0: FixedColumnWidth(60),
                                                1: FlexColumnWidth(),
                                                2: FixedColumnWidth(80),
                                                3: FixedColumnWidth(80),
                                                4: FixedColumnWidth(80),
                                                5: FixedColumnWidth(100),
                                              },
                                              children: [

                                                /// HEADER
                                                TableRow(
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFF9FD5FF),
                                                    // borderRadius: const BorderRadius.only(
                                                    //     topLeft: Radius.circular(5),
                                                    //     topRight: Radius.circular(5)
                                                    // )
                                                  ),
                                                  children: [
                                                    header("S.NO"),
                                                    header("PRODUCT NAME"),
                                                    header("QTY"),
                                                    header("PRICE"),
                                                    header("GST"),
                                                    header("TOTAL"),
                                                  ],
                                                ),

                                                /// DATA
                                                ...List.generate(products.length, (i) {
                                                  return TableRow(
                                                    decoration: BoxDecoration(
                                                      // color: int.parse(
                                                      //     i.toString()) %
                                                      //     2 == 0 ? Colors
                                                      //     .white : colorsConst
                                                      //     .backgroundColor,
                                                      border: Border(
                                                        bottom: BorderSide(
                                                          color: Colors.grey.shade200,
                                                          width: 1.5,
                                                        ),
                                                      ),
                                                    ),
                                                    children: [
                                                      cell("${i + 1}"),
                                                      cell(products2[i]["name"]),
                                                      cell(products2[i]["qty"]),
                                                      cell(productCtr.formatAmount(products2[i]["price"])),
                                                      cell(products2[i]["gst"]),
                                                      cell(productCtr.formatAmount(products2[i]["amount"])),
                                                    ],
                                                  );
                                                }),
                                                TableRow(
                                                  // decoration: BoxDecoration(
                                                  //     color: Colors.grey.shade100,
                                                  //     borderRadius: const BorderRadius.only(
                                                  //         bottomLeft: Radius.circular(5),
                                                  //         bottomRight: Radius.circular(5)
                                                  //     )),
                                                  children: [
                                                    cell(""),
                                                    cell(""),
                                                    // cell(widget.list.totalItem.toString()),
                                                    cell(""),
                                                    cell(""),
                                                    cell("TOTAL",colors: colorsConst.primary),
                                                    cell(productCtr.formatAmount(data.totalAmt.toString()),colors: colorsConst.primary),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  10.height,
                                ],
                              ),
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

Widget expandedStep({
  required String title,
  required String subTitle,
  required bool isCompleted,
  required bool isLast,
  required double width,
  bool isPending = false,
  String? stepNumber,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: buildCircle(
              isCompleted: isCompleted,
              isPending: isPending,
              stepNumber: stepNumber,
            ),
          ),
          !isLast&&isCompleted?
          Container(
            height: 3,width: width,
            color: colorsConst.primary,
          ):!isLast?
          SizedBox(
            width: width,
            child: DottedLine(
              direction: Axis.horizontal,
              lineLength: width,
              lineThickness: 2,
              dashLength: 6,
              dashGapLength: 4,
              dashColor:Colors.grey.shade300,
            ),
          ):0.height,
        ],
      ),
      5.height,
      CustomText(
        text: title,isCopy: false,isBold: true,
        textAlign: TextAlign.center,
      ),
      5.height,
      CustomText(
        text: subTitle,isCopy: false,size: 13,
        textAlign: TextAlign.center,
        colors: Colors.grey.shade600,
      ),
    ],
  );
}

Widget buildCircle({
  required bool isCompleted,
  required bool isPending,
  String? stepNumber,
}) {
  if (isCompleted) {
    return Container(
      width: 34,
      height: 34,
      decoration: const BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.check,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  if (isPending) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.more_horiz,
        color: Colors.grey,
      ),
    );
  }

  return Container(
    width: 37,
    height: 37,
    decoration: BoxDecoration(
      color: colorsConst.primary.withOpacity(0.2),
      shape: BoxShape.circle,
    ),
    alignment: Alignment.center,
    child: CircleAvatar(
      radius: 11,
      backgroundColor: colorsConst.primary,
      child: CustomText(
        text: stepNumber ?? "",isCopy: false,colors: Colors.white,isBold: true,
      ),
    ),
  );
}

Widget header(String text) {
  return Padding(
    padding: const EdgeInsets.all(10),
    child: CustomText(
      text:text,isCopy: false,isBold: true,size: 16,
      textAlign: TextAlign.center,
    ),
  );
}
Widget cell(String text, {Color? colors=Colors.black}) {
  return Padding(
    padding: const EdgeInsets.all(10),
    child: CustomText(text:text, textAlign: TextAlign.center,isCopy: true,size: 16,colors: colors,),
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
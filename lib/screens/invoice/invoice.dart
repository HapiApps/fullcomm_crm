import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/constant/colors_constant.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/common/styles/decoration.dart';
import 'package:fullcomm_crm/components/custom_text.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
// void main() {
//   runApp(const InvoiceView(
//     cName: 'Santhiya',
//     address: 'Thoothukudi, Tamil Nadu, 628103'
//       , mail: 'info@hapiapps.com', number: '+91 9677 281 724',));
// }
class InvoiceView extends StatefulWidget {
  final String cName;
  final String address;
  final String mail;
  final String number;
  const InvoiceView({super.key, required this.cName, required this.address, required this.mail, required this.number});

  @override
  State<InvoiceView> createState() => _InvoiceViewState();
}

class _InvoiceViewState extends State<InvoiceView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Center(
              child: Container(
                // height: 500,
                width: kIsWeb?MediaQuery.of(context).size.width*0.5:MediaQuery.of(context).size.width*0.9,
                decoration: customDecoration.baseBackgroundDecoration(
                    color: Colors.white,radius: 5,
                    borderColor: colorsConst.primary
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          decoration: customDecoration.baseBackgroundDecoration(
                              color: Colors.white,radius: 5,borderColor: colorsConst.primary
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CustomText(text: "TAX INVOICE", isCopy: false,colors: colorsConst.primary,),
                          ),
                        ),
                      ),
                      Image.asset("assets/images/hapi_apps_logo.png",width: kIsWeb?100:50,height:  kIsWeb?100:50,),
                      Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(text: "Hapi Apps", isCopy: true,colors: colorsConst.primary,size: 23,isBold: true,),
                              CustomText(text: "7/38, East Street, Kulaiyankarisal", isCopy: true,colors: colorsConst.primary,size: 18,),
                              CustomText(text: "Thoothukudi, Tamil Nadu, 628103\n", isCopy: true,colors: colorsConst.primary,size: 18),
                              Row(
                                children: [
                                  CustomText(text: "Email : ", isCopy: true,colors: colorsConst.primary,size: 18),
                                  CustomText(text: "info@hapiapps.com", isCopy: true,colors: colorsConst.primary,size: 18),
                                ],
                              ),
                              Row(
                                children: [
                                  CustomText(text: "Mobile : ", isCopy: true,colors: colorsConst.primary,size: 18),
                                  CustomText(text: "+91 9677 281 724", isCopy: true,colors: colorsConst.primary,size: 18),
                                ],
                              ), Row(
                                children: [
                                  CustomText(text: "GSTIN : ", isCopy: true,colors: colorsConst.primary,size: 18),
                                  CustomText(text: "\n", isCopy: true,colors: colorsConst.primary,size: 18),
                                ],
                              ),
                            ],
                          ),25.width,
                          Container(
                            height: 150,
                              decoration: customDecoration.baseBackgroundDecoration(
                                  color: Colors.white,radius: 5,borderColor: colorsConst.primary
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(25.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Column(
                                      children: [
                                        CustomText(text: "InvoiceNo:", isCopy: false,colors: colorsConst.primary,size: 18),5.height,
                                        CustomText(text: "InvoiceDate:", isCopy: false,colors: colorsConst.primary,size: 18),5.height,
                                        CustomText(text: "OrderNo:", isCopy: false,colors: colorsConst.primary,size: 18),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        CustomText(text: "24", isCopy: false,colors: colorsConst.primary,size: 18),5.height,
                                        CustomText(text: DateFormat('d MMM yyyy').format(DateTime.now()), isCopy: false,colors: colorsConst.primary,size: 18),5.height,
                                        CustomText(text: ":", isCopy: false,colors: colorsConst.primary,size: 18),
                                      ],
                                    )
                                  ],
                                ),
                              )
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          CustomText(text: "M/S : ", isCopy: true,colors: colorsConst.primary,size: 18),
                          CustomText(text: widget.cName, isCopy: true,colors: colorsConst.primary,size: 18),
                        ],
                      ), Row(
                        children: [
                          CustomText(text: "Address : ", isCopy: true,colors: colorsConst.primary,size: 18),
                          CustomText(text: widget.address, isCopy: true,colors: colorsConst.primary,size: 18),
                        ],
                      ),
                      CustomText(text: "\nPARTY GSTIN : ", isCopy: true,colors: colorsConst.primary,size: 18),
                      _buildLineItemsTable(),
                      _buildFooterSection(),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLineItemsTable() {
    return Table(
      border: TableBorder.all(color: Colors.blue.shade200),
      columnWidths: {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(4),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(2),
      },
      children: [
        // Table Header
        TableRow(
          decoration: BoxDecoration(color: Colors.white),
          children: [
            _cell("S. No.", isHeader: true),
            _cell("Particulars", isHeader: true),
            _cell("Qty.", isHeader: true),
            _cell("Amount INR", isHeader: true),
          ],
        ),
        // Item Row
        TableRow(
          children: [
            _cell("1"),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(text: "Billing Software", isCopy: true,isBold: true,size: 15,),
                  SizedBox(height: 60), // Space for layout
                  CustomText(text:"SAC CODE: 998314", colors: Colors.blue.shade800, size: 15,isCopy: true,),
                ],
              ),
            ),
            _cell(""),
            _cell("15,000", align: TextAlign.right),
          ],
        ),
      ],
    );
  }

  Widget _buildFooterSection() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left side: Bank Details & Amount in words
          Expanded(
            flex: 6,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(border: Border(right: BorderSide(color: Colors.blue.shade200))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomText(text:"Amount in Words: ",size: 15, isCopy: true,colors: colorsConst.primary,),
                      CustomText(text:"INR Seventeen Thousand Seven Hundred Only",size: 15,isCopy: true),
                    ],
                  ),
                  Spacer(),
                  _bankDetailText("UPI ID:"),
                  _bankDetailText("Bank Account No:"),
                  _bankDetailText("Name: Hapi Apps"),
                  _bankDetailText("IFSC: ..."),
                  _bankDetailText("Kulaiyankarisal branch"),
                ],
              ),
            ),
          ),
          // Right side: Totals
          Expanded(
            flex: 4,
            child: Column(
              children: [
                _totalRow("Total Before\nTax SGST", "15,000"),
                _totalRow("CGST 9%", "1,350"),
                _totalRow("Round Off 9%", "1,350"),
                _totalRow("Total After", "1,350"),
                _totalRow("Tax for\nHapiApps", "17,700", isBold: true),
                Spacer(),
                CustomText(text:"Signature",size: 15,isCopy: false,),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cell(String text, {bool isHeader = false, TextAlign align = TextAlign.center}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomText(
        text:text,
        textAlign: align,
        isBold: isHeader ? true:false,
          // color: Colors.blue.shade900,
          size: 15,isCopy: true,
      ),
    );
  }

  Widget _totalRow(String label, String value, {bool isBold = false}) {
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.blue.shade200))),
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(text: label, size: 15, isBold: isBold ? true:false,colors: colorsConst.primary,isCopy: true,),
          CustomText(text: value, size: 15, isBold: isBold ? true:false,colors: colorsConst.primary,isCopy: true,),
        ],
      ),
    );
  }

  Widget _bankDetailText(String text) {
    return CustomText(text:text, size: 15, colors: Colors.blue.shade800,isCopy: true,);
  }
}

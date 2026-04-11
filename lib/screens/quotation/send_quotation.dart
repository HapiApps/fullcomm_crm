import 'dart:math';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/common/styles/decoration.dart';
import 'package:fullcomm_crm/common/utilities/utils.dart';
import 'package:fullcomm_crm/components/custom_loading_button.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../common/constant/app_colors.dart';
import '../../common/constant/colors_constant.dart';
import '../../components/Customtext.dart';
import '../../controller/controller.dart';
import '../../controller/product_controller.dart';
import '../../controller/settings_controller.dart';
import '../../models/all_customers_obj.dart';
import '../../models/product_model.dart';
import '../../services/api_services.dart';

class SendQuotation extends StatefulWidget {
  const SendQuotation({super.key, });

  @override
  State<SendQuotation> createState() => _SendQuotationState();
}

class _SendQuotationState extends State<SendQuotation> {
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();
  late FocusNode _focusNode;
  final ScrollController _headerHorizontalController = ScrollController();
  var sizeInKB=0.0.obs;
  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    productCtr.productsList.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      controllers.clearSelectedCustomer();
      productCtr.clearProduct();
      // controllers.totalProspectPages.value=(productCtr.ordersList.length / controllers.itemsPerPage).ceil();
    });
    /// 🔥 SYNC HEADER + BODY
    _horizontalController.addListener(() {
      if (_headerHorizontalController.hasClients &&
          _headerHorizontalController.offset != _horizontalController.offset) {
        _headerHorizontalController.jumpTo(_horizontalController.offset);
      }
    });

  }

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    _headerHorizontalController.dispose(); // ✅ add
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: Scaffold(
        body: Obx(()=>Container(
          width:controllers.isLeftOpen.value?MediaQuery.of(context).size.width - 150:MediaQuery.of(context).size.width - 60,
          height: MediaQuery.of(context).size.height,
          alignment: Alignment.center,
          padding: EdgeInsets.fromLTRB(20, 5, 20, 16),
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
                        text: "Send Quotation",
                        colors: colorsConst.textColor,
                        size: 20,
                        isBold: true,
                        isCopy: true,
                      ),
                      10.height,
                      CustomText(
                        text: "",
                        colors: colorsConst.textColor,
                        size: 14,
                        isCopy: true,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          onPressed: (){
                            if(controllers.selectedCustomerId.value==""){
                              utils.snackBar(context: context, msg: "Please select customer", color: Colors.red);
                              return;
                            }
                            if(productCtr.productsList.isEmpty){
                              utils.snackBar(context: context, msg: "Please select products", color: Colors.red);
                              return;
                            }
                            for(var i=0;i<productCtr.productsList.length;i++){
                              if(productCtr.productsList[i].qty.text.isEmpty){
                                utils.snackBar(context: context, msg: "Please fill quantity", color: Colors.red);
                                controllers.emailCtr.reset();
                                return;
                              }
                            }
                            printInvoice();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff0078D7),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: Text(
                            'Invoice',
                            style: GoogleFonts.lato(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ),10.width,
                      SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          onPressed: (){
                            if(controllers.selectedCustomerId.value==""){
                              utils.snackBar(context: context, msg: "Please select customer", color: Colors.red);
                            }else if(productCtr.productsList.isEmpty){
                              utils.snackBar(context: context, msg: "Please select products", color: Colors.red);
                            }else{
                              setState(() {
                                controllers.emailToCtr.text=controllers.selectedCustomerEmail.value;
                                controllers.isTemplate.value=false;
                                controllers.emailSubjectCtr.clear();
                                controllers.emailMessageCtr.clear();
                              });
                              showDialog(
                                  context: Get.context!,
                                  barrierDismissible: false,
                                  builder: (context) {
                                    return AlertDialog(
                                      actions: [
                                        Column(
                                          children: [
                                            Divider(
                                              color: Colors.grey.shade300,
                                              thickness: 1,
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                SizedBox(
                                                  child: Row(
                                                    children: [
                                                      TextButton(
                                                          onPressed: () {
                                                            Navigator.of(context).pop();
                                                            settingsController.showAddTemplateDialog(context);
                                                          },
                                                          child: CustomText(
                                                            text: "Add Template",
                                                            isCopy: false,
                                                            colors: colorsConst.third,
                                                            size: 18,
                                                            isBold: true,
                                                          )),
                                                    ],
                                                  ),
                                                ),
                                                CustomLoadingButton(
                                                  callback: () {
                                                    if(controllers.emailToCtr.text.trim().isEmpty){
                                                      utils.snackBar(context: context, msg: "To is empty!", color: Colors.red);
                                                      controllers.emailCtr.reset();
                                                      return;
                                                    }
                                                    if(!controllers.emailToCtr.text.trim().isEmail){
                                                      utils.snackBar(
                                                        context: context,
                                                        msg: "Invalid mail!",
                                                        color: Colors.red,
                                                      );
                                                      controllers.emailCtr.reset();
                                                      return;
                                                    }
                                                    if(controllers.emailSubjectCtr.text.trim().isEmpty){
                                                      utils.snackBar(context: context, msg: "Subject is empty!", color: Colors.red);
                                                      controllers.emailCtr.reset();
                                                      return;
                                                    }
                                                    if(controllers.emailMessageCtr.text.trim().isEmpty){
                                                      utils.snackBar(context: context, msg: "Message is empty!", color: Colors.red);
                                                      controllers.emailCtr.reset();
                                                      return;
                                                    }
                                                    for(var i=0;i<productCtr.productsList.length;i++){
                                                      if(productCtr.productsList[i].qty.text.isEmpty){
                                                        utils.snackBar(context: context, msg: "Please fill quantity", color: Colors.red);
                                                        controllers.emailCtr.reset();
                                                        return;
                                                      }
                                                    }
                                                    sendInvoice();
                                                  },
                                                  controller: controllers.emailCtr,
                                                  isImage: false,
                                                  isLoading: true,
                                                  backgroundColor: colorsConst.primary,
                                                  radius: 5,
                                                  width: 200,
                                                  height: 50,
                                                  text: "Send Quotation",
                                                  textColor: Colors.white,
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ],
                                      content: SizedBox(
                                          width: 600,
                                          height: 400,
                                          child: SingleChildScrollView(
                                            child: Column(
                                              children: [
                                                Align(
                                                    alignment: Alignment.topRight,
                                                    child: InkWell(
                                                        onTap: () {
                                                          Navigator.pop(context);
                                                        },
                                                        child: Icon(
                                                          Icons.clear,
                                                          size: 18,
                                                          color: colorsConst.textColor,
                                                        ))),
                                                Align(
                                                  alignment: Alignment.topRight,
                                                  child: TextButton(
                                                      onPressed: () {
                                                        controllers.isTemplate.value = !controllers.isTemplate.value;
                                                      },
                                                      child: CustomText(
                                                        text: "Get Form Template",
                                                        colors: colorsConst.third,
                                                        size: 18,
                                                        isCopy: false,
                                                        isBold: true,
                                                      )),
                                                ),
                                                Row(
                                                  children: [
                                                    CustomText(
                                                      textAlign: TextAlign.center,
                                                      text: "To",
                                                      colors: colorsConst.textColor,
                                                      size: 15,
                                                      isCopy: false,
                                                    ),
                                                    50.width,
                                                    SizedBox(
                                                      width: 500,
                                                      child: TextField(
                                                        controller: controllers.emailToCtr,
                                                        style: TextStyle(
                                                            fontSize: 15, color: colorsConst.textColor),
                                                        decoration: const InputDecoration(
                                                          border: InputBorder.none,
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                SizedBox(
                                                    width: 600,
                                                    child: SingleChildScrollView(
                                                      child: Column(
                                                        children: [
                                                          Divider(
                                                            color: Colors.grey.shade300,
                                                            thickness: 1,
                                                          ),
                                                          Row(
                                                            children: [
                                                              15.height,
                                                              CustomText(
                                                                text: "Subject",
                                                                colors: colorsConst.textColor,
                                                                size: 14,
                                                                isCopy: false,
                                                              ),
                                                              20.width,
                                                              SizedBox(
                                                                width: 500,
                                                                height: 50,
                                                                child: TextField(
                                                                  controller: controllers.emailSubjectCtr,
                                                                  maxLines: null,
                                                                  minLines: 1,
                                                                  style: TextStyle(
                                                                    color: colorsConst.textColor,
                                                                  ),
                                                                  decoration: const InputDecoration(
                                                                    border: InputBorder.none,
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                          Divider(
                                                            color: Colors.grey.shade300,
                                                            thickness: 1,
                                                          ),
                                                          Obx(() => controllers.isTemplate.value == false
                                                              ? SingleChildScrollView(
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                SizedBox(
                                                                  width: 600,
                                                                  height: 170,
                                                                  child: TextField(
                                                                    textInputAction: TextInputAction.newline,
                                                                    controller: controllers.emailMessageCtr,
                                                                    keyboardType: TextInputType.multiline,
                                                                    maxLines: 21,
                                                                    expands: false,
                                                                    style: TextStyle(
                                                                      color: colorsConst.textColor,
                                                                    ),
                                                                    decoration: InputDecoration(
                                                                      hintText: "Message",
                                                                      hintStyle: TextStyle(
                                                                          color: colorsConst.textColor,
                                                                          fontSize: 14,
                                                                          fontFamily: "Lato"),
                                                                      border: InputBorder.none,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                              :Obx(() => UnconstrainedBox(
                                                            child: Container(
                                                              width: 500,
                                                              alignment: Alignment.center,
                                                              decoration: BoxDecoration(
                                                                color: colorsConst.secondary,
                                                                borderRadius: BorderRadius.circular(10),
                                                              ),
                                                              child: SingleChildScrollView(
                                                                child: Column(
                                                                  children: [
                                                                    SizedBox(
                                                                      width: 500,
                                                                      height: 170,
                                                                      child: Table(
                                                                        defaultColumnWidth: const FixedColumnWidth(120.0),
                                                                        border: TableBorder.all(
                                                                          color: Colors.grey.shade300,
                                                                          style: BorderStyle.solid,
                                                                          borderRadius: BorderRadius.circular(10),
                                                                          width: 1,
                                                                        ),
                                                                        children: [
                                                                          // Header Row
                                                                          TableRow(
                                                                            children: [
                                                                              CustomText(
                                                                                textAlign: TextAlign.center,
                                                                                text: "\nTemplate Name\n",
                                                                                colors: colorsConst.textColor,
                                                                                size: 15,
                                                                                isBold: true,
                                                                                isCopy: false,
                                                                              ),
                                                                              CustomText(
                                                                                textAlign: TextAlign.center,
                                                                                text: "\nSubject\n",
                                                                                colors: colorsConst.textColor,
                                                                                size: 15,
                                                                                isBold: true,
                                                                                isCopy: false,
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          // Dynamic Rows
                                                                          for (var item in settingsController.templateList)
                                                                            utils.emailRow(
                                                                                context,
                                                                                isCheck: controllers.isAdd,
                                                                                templateName: item.templateName,
                                                                                msg: item.message,
                                                                                subject: item.subject,
                                                                                id: item.id
                                                                            ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ))),
                                                          Container(
                                                            width: MediaQuery.of(context).size.width*0.6,
                                                            decoration: customDecoration.baseBackgroundDecoration(
                                                              color: Colors.grey.shade50,radius: 5,
                                                            ),
                                                            child: Padding(
                                                              padding: const EdgeInsets.all(8.0),
                                                              child: CustomText(
                                                                textAlign: TextAlign.start,
                                                                text: "${controllers.selectedCustomerName.value.replaceAll(' ', '_')}_${DateFormat('dd-MM-yyyy').format(DateTime.now())} ( ${sizeInKB.toStringAsFixed(2)} KB ).pdf",
                                                                isCopy: false,colors: colorsConst.primary,isBold: true,),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    )),
                                              ],
                                            ),
                                          )),
                                    );
                                  });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff0078D7),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: Text(
                            'Send Quotation',
                            style: GoogleFonts.lato(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ),
                    ],
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
                  CustomerDropdown(
                    custList: controllers.customers,
                    onChanged: (AllCustomersObj? customer) {
                      setState(() {
                        controllers.selectCustomer(customer!);
                      });
                    },),
                  // ProductDropdown(
                  //   prdList: productCtr.products,
                  //   onChanged: (ProductModel? product) {
                  //     setState(() {
                  //       productCtr.selectProduct(product!);
                  //     });
                  //   },),
                  Container(
                    width: MediaQuery.of(context).size.width*0.1,
                    height: 40,
                    decoration: customDecoration.baseBackgroundDecoration(
                        color: Colors.green,radius: 5
                    ),
                    child: Center(
                      child: CustomText(
                        textAlign: TextAlign.center,
                        text: "Total Amount : ${productCtr.productsList.fold(0.0,(sum, item) => sum + (double.tryParse(item.amount.text) ?? 0.0),)}",
                        isCopy: false,colors: Colors.white,isBold: true,),
                    ),
                  )
                ],
              ),
              10.height,
              // Obx(()=>SizedBox(
              //   width:MediaQuery.of(context).size.width*0.7,
              //   height: 500,
              //   child: ListView.builder(
              //       itemCount: productCtr.productsList.length,
              //       itemBuilder: (context,index){
              //         ProductModel data =productCtr.productsList[index];
              //         return Column(
              //           children: [
              //             Container(
              //               decoration: customDecoration.baseBackgroundDecoration(
              //                 color: Colors.white,radius: 5,borderColor: Colors.grey.shade300
              //               ),
              //               child: Padding(
              //                 padding: const EdgeInsets.all(15.0),
              //                 child: Row(
              //                   children: [
              //                     CustomText(text: data.title.toString(), isCopy: false),
              //                     CustomText(text: data.cat.toString(), isCopy: false),
              //                     CustomText(text: data.subCat.toString(), isCopy: false),
              //                     CustomText(text: data.brand.toString(), isCopy: false),
              //                     CustomText(text: data.gst.toString(), isCopy: false),
              //                   ],
              //                 ),
              //               ),
              //             ),
              //             10.height
              //           ],
              //         );
              //       }),
              // )),
              Obx(() => Table(
                border: TableBorder(
                  horizontalInside:
                  BorderSide(width: 0.5, color: Colors.grey.shade300),
                  verticalInside:
                  BorderSide(width: 0.5, color: Colors.grey.shade300),
                ),
                // columnWidths: const {
                //   0: FixedColumnWidth(60),   // S.No
                //   1: FlexColumnWidth(50),     // Product
                //   2: FlexColumnWidth(30),   // Category
                //   3: FlexColumnWidth(30),   // Sub Category
                //   4: FlexColumnWidth(30),   // Brand
                //   5: FixedColumnWidth(70),   // GST
                //   6: FixedColumnWidth(70),   // GST
                //   7: FixedColumnWidth(70),   // GST
                //   8: FixedColumnWidth(100),   // GST
                // },
                children: [

                  /// 🔹 Header Row
                  TableRow(
                    decoration: BoxDecoration(
                      color: colorsConst.primary,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(5),
                        topRight: Radius.circular(5),
                      ),
                    ),
                    children: [
                      headerCell("S.No"),
                      headerCell("Product Name"),
                      headerCell("Quantity"),
                      headerCell("MRP"),
                      headerCell("Price"),
                      headerCell("Amount"),
                      headerCell("Category"),
                      headerCell("Sub Category"),
                      headerCell("Brand"),
                      headerCell("GST"),
                    ],
                  ),

                  /// 🔹 Data Rows
                  ...List.generate(
                    productCtr.productsList.length,
                        (index) {
                      final data = productCtr.productsList[index];

                      return TableRow(
                        decoration: customDecoration.baseBackgroundDecoration(
                            color: index % 2 == 0
                                ? Colors.white
                                : colorsConst.backgroundColor,radius: 0,borderColor: Colors.grey.shade300
                        ),
                        children: [
                          valueCell("${index + 1}"),
                          valueCell(data.title.toString()),
                          // valueCell(data.qty.toString()),
                          TextField(
                            controller: data.qty,
                            onChanged: (value) {
                              setState(() {
                                double qty = double.tryParse(data.qty.text) ?? 0;
                                double price = double.tryParse(data.outPrice.toString()) ?? 0;
                                data.amount.text = (qty * price).toStringAsFixed(2);
                              });
                            },
                            decoration: InputDecoration(
                                border: UnderlineInputBorder()
                            ),
                          ),
                          valueCell(data.mrp.toString()),
                          valueCell(data.outPrice.toString()),
                          valueCell(data.amount.text),
                          valueCell(data.cat.toString()),
                          valueCell(data.subCat.toString()),
                          valueCell(data.brand.toString()),
                          valueCell(data.gst.toString())
                        ],
                      );
                    },
                  )
                ],
              )),
              controllers.selectedCustomerName.value==""?
              CustomText(text: "\n\n\n\n\nSelect Customer Name", isCopy: false)
              :productCtr.productsList.isEmpty?
              CustomText(text: "\n\n\n\n\nSelect Products", isCopy: false):0.height,
              20.height,
            ],
          ),
        )),
      ),
    );
  }
  Widget headerCell(String text) {
    return Container(
      height: 45,
      alignment: Alignment.center,
      child: CustomText(
          text:text,isCopy: false,
          colors: Colors.white
      ),
    );
  }

  Widget valueCell(String text) {
    return Container(
      height: 45,
      alignment: Alignment.center,
      child: CustomText(
        text:text,isCopy: false,
      ),
    );
  }

  Future<pw.Document> generateInvoicePdf() async {
    print(".......printInvoice");
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [

                pw.SizedBox(height: 20),

                /// 🟢 HEADER ROW
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [

                    /// LEFT SIDE (Company)
                    pw.Expanded(
                      flex: 6,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("Hapi Apps",
                              style: pw.TextStyle(
                                  fontSize: 18,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.Text(
                              "7/38, East Street, Kulaiyankarisal\nThoothukudi, Tamil Nadu, 628103"),
                          pw.SizedBox(height: 5),
                          pw.Text("Email : info@hapiapps.com"),
                          pw.Text("Mobile : +91 9677 281 724"),
                          pw.Text("GSTIN : "),
                        ],
                      ),
                    ),

                    /// RIGHT BOX
                    pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(),
                        borderRadius: pw.BorderRadius.circular(5),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          rowText("InvoiceNo:", (10000 + Random().nextInt(90000)).toString()),
                          rowText("InvoiceDate:", DateFormat("dd-MM-yyyy").format(DateTime.now())),
                          // rowText("OrderNo:", data.id),
                        ],
                      ),
                    )
                  ],
                ),

                pw.SizedBox(height: 15),

                /// CUSTOMER
                pw.Text("M/S : ${controllers.selectedCustomerName}"),
                // pw.Text("Address : ${controllers.selectedc}"),

                pw.SizedBox(height: 10),

                pw.Text("PARTY GSTIN : "),

                pw.SizedBox(height: 10),

                /// 🔵 TABLE
                pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(1),
                    1: const pw.FlexColumnWidth(4),
                    2: const pw.FlexColumnWidth(1),
                    3: const pw.FlexColumnWidth(1),
                    4: const pw.FlexColumnWidth(2),
                  },
                  children: [

                    /// HEADER
                    pw.TableRow(
                      children: [
                        tableCell("S.No.", isHeader: true),
                        tableCell("Product Name", isHeader: true),
                        tableCell("Qty", isHeader: true),
                        tableCell("MRP", isHeader: true),
                        tableCell("Amount INR", isHeader: true),
                      ],
                    ),

                    /// DATA
                    ...List.generate(productCtr.productsList.length, (index) {
                      final p = productCtr.productsList[index];

                      return pw.TableRow(
                        children: [
                          tableCell("${index + 1}"),
                          tableCell(p.title.toString()),
                          tableCell(p.qty.text),
                          tableCell(p.mrp.toString()),
                          tableCell("Rs. ${p.amount.text}"),
                        ],
                      );
                    }),
                  ],
                ),

                pw.SizedBox(height: 10),

                /// 🔶 BOTTOM SECTION
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [

                    /// LEFT SIDE
                    pw.Expanded(
                      flex: 6,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          // pw.Text("Amount in Words: INR ${productCtr.numberToWords(int.parse(data.totalAmt))} Only"),
                          pw.SizedBox(height: 10),
                          pw.Text("UPI ID:"),
                          pw.Text("Bank Account No:"),
                          pw.Text("Name: Hapi Apps"),
                          pw.Text("IFSC: ..."),
                          pw.Text("Kulaiyankarisal branch"),
                        ],
                      ),
                    ),

                    /// RIGHT SIDE (TOTAL BOX)
                    pw.Expanded(
                      flex: 4,
                      child: pw.Container(
                        decoration:
                        pw.BoxDecoration(border: pw.Border.all()),
                        child: pw.Column(
                          children: [
                            totalRows("Total Before Tax SGST", "15,000"),
                            totalRows("CGST 9%", "1,350"),
                            totalRows("Round Off 9%", "1,350"),
                            totalRows("Total After", "1,350"),
                            // totalRows("Tax for HapiApps", data.totalAmt,isBold: true),
                            pw.SizedBox(height: 20),
                            pw.Text("Signature"),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
    final bytes = await pdf.save();
    sizeInKB.value = bytes.length / 1024;

    print("Size: ${sizeInKB.value}");
    return pdf;
  }

  Future<void> printInvoice() async {
    final pdf = await generateInvoicePdf();

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  Future<void> sendInvoice() async {
    final pdf = await generateInvoicePdf();

    apiService.insertQuotationAPI(context, pdf,"");
  }

  pw.Widget tableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight:
          isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
  pw.Widget rowText(String title, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.Text(title),
          pw.SizedBox(width: 5),
          pw.Text(value),
        ],
      ),
    );
  }
  pw.Widget totalRows(String title, String value,{bool isBold = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      decoration: pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide()),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(title,
              style: pw.TextStyle(
                  fontWeight: isBold
                      ? pw.FontWeight.bold
                      : pw.FontWeight.normal)),
          pw.Text(value,
              style: pw.TextStyle(
                  fontWeight: isBold
                      ? pw.FontWeight.bold
                      : pw.FontWeight.normal)),
        ],
      ),
    );
  }
  Widget totalRow(String title, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            text: title,
            isBold: isBold,
            isCopy: false,
          ),
          CustomText(
            text: value,
            isBold: isBold,
            isCopy: false,
          ),
        ],
      ),
    );
  }

}

class CustomerDropdown extends StatefulWidget {
  final List<AllCustomersObj> custList;
  final ValueChanged<AllCustomersObj?> onChanged;

  const CustomerDropdown({
    super.key,
    required this.custList,
    required this.onChanged,
  });

  @override
  State<CustomerDropdown> createState() => _CustomerDropdownState();
}

class _CustomerDropdownState extends State<CustomerDropdown> {
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  String _formatCustomer(AllCustomersObj customer) {
    return '${customer.name}'
        '${customer.companyName.toString().isEmpty ? "" : ", ${customer.companyName}"} '
        '${customer.name.toString().isEmpty ? "" : "-"} '
        '${customer.phoneNo} - ${customer.category}';
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth / 2.6,
      height: 47,
      decoration: customDecoration.baseBackgroundDecoration(
        color: Colors.white,
        radius: 20,
        borderColor: AppColors.black,
      ),
      child: DropdownSearch<AllCustomersObj>(
        items: widget.custList,

        /// Text format
        itemAsString: (customer) => _formatCustomer(customer),

        onChanged: widget.onChanged,

        /// Dropdown UI
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            hintText: "Search Customer Name",
            hintStyle: GoogleFonts.lato(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            contentPadding: const EdgeInsets.all(10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                width: 0,
                color: AppColors.black,
              ),
            ),
          ),
        ),

        /// 🔥 Popup with autofocus fix
        popupProps: PopupProps.menu(
          showSearchBox: true,
          fit: FlexFit.loose,

          /// ✅ AUTO FOCUS FIX
          searchFieldProps: TextFieldProps(
            focusNode: _searchFocusNode,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: "Type to search...",
            ),

            /// 🔥 Force focus (important for some devices)
            onTap: () {
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) {
                  FocusScope.of(context).requestFocus(_searchFocusNode);
                }
              });
            },
          ),

          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),

          itemBuilder:
              (context, AllCustomersObj customer, bool isSelected) {
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: CustomText(
                textAlign: TextAlign.start,
                colors: AppColors.black,
                text: _formatCustomer(customer),
                isCopy: false,
              ),
            );
          },
        ),
      ),
    );
  }
}

class ProductDropdown extends StatefulWidget {
  final List<ProductModel> prdList;
  final ValueChanged<ProductModel?> onChanged;
  const ProductDropdown({super.key, required this.prdList, required this.onChanged});

  @override
  State<ProductDropdown> createState() => _ProductDropdownState();
}

class _ProductDropdownState extends State<ProductDropdown> {
  @override
  Widget build(BuildContext context) {

    return Container(
      width: MediaQuery.of(context).size.width*0.35,
      height: 47,
      decoration: customDecoration.baseBackgroundDecoration(
        color: Colors.white,
        radius: 5,
      ),
      child: DropdownSearch<ProductModel>(
        items: widget.prdList,
        itemAsString: (ProductModel product) => '${product.title}${product.brand.toString().isEmpty ? "" : ", ${product.brand}"}',
        onChanged: widget.onChanged,
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
              hintText: "Search Product Name",
              contentPadding: const EdgeInsets.all(10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
              )
          ),
        ),
        popupProps: PopupProps.menu(
          showSearchBox: true,
          fit: FlexFit.loose,
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          itemBuilder: (context, ProductModel product, bool isSelected) {
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: CustomText(
                textAlign: TextAlign.start,
                text:'${product.title}${product.brand.toString().isEmpty ? "" : ", ${product.brand}"}', isCopy: false,),
            );
          },
        ),
      ),
    );
  }
}

class ProductSearchDropdown extends StatefulWidget {
  final List<ProductModel> products;
  final Function(ProductModel) onSelected;

  const ProductSearchDropdown({
    super.key,
    required this.products,
    required this.onSelected,
  });

  @override
  State<ProductSearchDropdown> createState() => _ProductSearchDropdownState();
}

class _ProductSearchDropdownState extends State<ProductSearchDropdown> {
  TextEditingController controller = TextEditingController();
  FocusNode focusNode = FocusNode();

  List<ProductModel> filtered = [];
  bool showList = false;

  @override
  void initState() {
    super.initState();
    filtered = widget.products;
  }

  void search(String value) {
    setState(() {
      showList = true;

      filtered = widget.products.where((c) {
        return (c.title ?? "")
            .toLowerCase()
            .contains(value.toLowerCase()) ||
            (c.brand ?? "")
                .toLowerCase()
                .contains(value.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          focusNode: focusNode,

          onTap: () {
            setState(() {
              showList = true;
              filtered = widget.products; // full list show
            });
          },

          onChanged: search,

          decoration: InputDecoration(
            suffixIcon: controller.text.isNotEmpty
                ? InkWell(
              onTap: () {
                setState(() {
                  controller.clear();
                  productCtr.clearProduct();
                  showList = false;
                });
              },
              child: const Icon(Icons.clear, color: Colors.grey),
            )
                : null,
            hintText: "Search Products",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),

        if (showList)
          Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final customer = filtered[index];

                return InkWell(
                  onTap: () {
                    controller.text =
                    '${customer.title}${customer.brand.toString().isEmpty ? "" : ", ${customer.brand}"}';

                    setState(() {
                      showList = false;
                    });

                    widget.onSelected(customer);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: CustomText(
                      textAlign: TextAlign.start,
                      text:
                      '${customer.title}${customer.brand.toString().isEmpty ? "" : ", ${customer.brand}"}',
                      size: 14,
                      isCopy: false,
                    ),
                  ),
                );
              },
            ),
          )
      ],
    );
  }
}
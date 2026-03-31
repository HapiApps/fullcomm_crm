import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/services/api_services.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../common/constant/api.dart';
import '../../common/constant/colors_constant.dart';
import '../../common/utilities/utils.dart';
import '../../components/Customtext.dart';
import '../../controller/controller.dart';
import '../../controller/product_controller.dart';

class QuotationHistory extends StatefulWidget {
  const QuotationHistory({super.key, });

  @override
  State<QuotationHistory> createState() => _QuotationHistoryState();
}

class _QuotationHistoryState extends State<QuotationHistory> {
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();
  late FocusNode _focusNode;
  final ScrollController _headerHorizontalController = ScrollController();
  var sizeInKB=0.0.obs;
  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      controllers.totalProspectPages.value=(productCtr.quotationsList.length / controllers.itemsPerPage).ceil();
    });
    /// 🔥 SYNC HEADER + BODY
    _horizontalController.addListener(() {
      if (_headerHorizontalController.hasClients &&
          _headerHorizontalController.offset != _horizontalController.offset) {
        _headerHorizontalController.jumpTo(_horizontalController.offset);
      }
    });
  }
  /// 🔥 COMMON SORT FUNCTION
  void sortList(Comparable Function(dynamic e) getField) {
    productCtr.products.sort((a, b) {
      final aVal = getField(a);
      final bVal = getField(b);

      return controllers.sortOrderN.value == 'asc'
          ? Comparable.compare(aVal, bVal)
          : Comparable.compare(bVal, aVal);
    });
  }

  /// 🔥 HANDLE SORT CLICK
  void onSort(String field, VoidCallback sortLogic) {
    setState(() {
      if (controllers.sortField.value == field) {
        controllers.sortOrderN.value =
        controllers.sortOrderN.value == 'asc' ? 'desc' : 'asc';
      } else {
        controllers.sortField.value = field;
        controllers.sortOrderN.value = 'asc';
      }
      sortLogic();
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
                        text: "Quotation Details",
                        colors: colorsConst.textColor,
                        size: 20,
                        isBold: true,
                        isCopy: true,
                      ),
                      10.height,
                      CustomText(
                        text: "View all quotation details",
                        colors: colorsConst.textColor,
                        size: 14,
                        isCopy: true,
                      ),
                    ],
                  ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.end,
                  //   children: [
                  //     SizedBox(
                  //         height: 40,
                  //         child: ElevatedButton(
                  //           onPressed: (){
                  //             if(controllers.selectedCustomerId.value==""){
                  //               utils.snackBar(context: context, msg: "Please select customer", color: Colors.red);
                  //               return;
                  //             }
                  //             if(productCtr.quotationsListList.isEmpty){
                  //               utils.snackBar(context: context, msg: "Please select products", color: Colors.red);
                  //               return;
                  //             }
                  //             for(var i=0;i<productCtr.quotationsListList.length;i++){
                  //               if(productCtr.quotationsListList[i].qty.text.isEmpty){
                  //                 utils.snackBar(context: context, msg: "Please fill quantity", color: Colors.red);
                  //                 controllers.emailCtr.reset();
                  //                 return;
                  //               }
                  //             }
                  //             printInvoice();
                  //           },
                  //           style: ElevatedButton.styleFrom(
                  //             backgroundColor: const Color(0xff0078D7),
                  //             padding: const EdgeInsets.symmetric(
                  //                 horizontal: 20, vertical: 12),
                  //             shape: RoundedRectangleBorder(
                  //               borderRadius: BorderRadius.circular(4),
                  //             ),
                  //           ),
                  //           child: Text(
                  //             'Invoice',
                  //             style: GoogleFonts.lato(
                  //                 color: Colors.white,
                  //                 fontSize: 14,
                  //                 fontWeight: FontWeight.bold
                  //             ),
                  //           ),
                  //         ),
                  //       ),10.width,
                  //     SizedBox(
                  //       height: 40,
                  //       child: ElevatedButton(
                  //         onPressed: (){
                  //           if(controllers.selectedCustomerId.value==""){
                  //             utils.snackBar(context: context, msg: "Please select customer", color: Colors.red);
                  //           }else if(productCtr.quotationsListList.isEmpty){
                  //             utils.snackBar(context: context, msg: "Please select products", color: Colors.red);
                  //           }else{
                  //             setState(() {
                  //               controllers.emailToCtr.text=controllers.selectedCustomerEmail.value;
                  //               controllers.isTemplate.value=false;
                  //               controllers.emailSubjectCtr.clear();
                  //               controllers.emailMessageCtr.clear();
                  //             });
                  //             invoiceSize();
                  //             showDialog(
                  //                 context: Get.context!,
                  //                 barrierDismissible: false,
                  //                 builder: (context) {
                  //                   return AlertDialog(
                  //                     actions: [
                  //                       Column(
                  //                         children: [
                  //                           Divider(
                  //                             color: Colors.grey.shade300,
                  //                             thickness: 1,
                  //                           ),
                  //                           Row(
                  //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //                             children: [
                  //                               SizedBox(
                  //                                 child: Row(
                  //                                   children: [
                  //                                     TextButton(
                  //                                         onPressed: () {
                  //                                           Navigator.of(context).pop();
                  //                                           settingsController.showAddTemplateDialog(context);
                  //                                         },
                  //                                         child: CustomText(
                  //                                           text: "Add Template",
                  //                                           isCopy: false,
                  //                                           colors: colorsConst.third,
                  //                                           size: 18,
                  //                                           isBold: true,
                  //                                         )),
                  //                                   ],
                  //                                 ),
                  //                               ),
                  //                               CustomLoadingButton(
                  //                                 callback: () {
                  //                                   if(controllers.emailToCtr.text.trim().isEmpty){
                  //                                     utils.snackBar(context: context, msg: "To is empty!", color: Colors.red);
                  //                                     controllers.emailCtr.reset();
                  //                                     return;
                  //                                   }
                  //                                   if(!controllers.emailToCtr.text.trim().isEmail){
                  //                                     utils.snackBar(
                  //                                       context: context,
                  //                                       msg: "Invalid mail!",
                  //                                       color: Colors.red,
                  //                                     );
                  //                                     controllers.emailCtr.reset();
                  //                                     return;
                  //                                   }
                  //                                   if(controllers.emailSubjectCtr.text.trim().isEmpty){
                  //                                     utils.snackBar(context: context, msg: "Subject is empty!", color: Colors.red);
                  //                                     controllers.emailCtr.reset();
                  //                                     return;
                  //                                   }
                  //                                   if(controllers.emailMessageCtr.text.trim().isEmpty){
                  //                                     utils.snackBar(context: context, msg: "Message is empty!", color: Colors.red);
                  //                                     controllers.emailCtr.reset();
                  //                                     return;
                  //                                   }
                  //                                   for(var i=0;i<productCtr.quotationsListList.length;i++){
                  //                                     if(productCtr.quotationsListList[i].qty.text.isEmpty){
                  //                                       utils.snackBar(context: context, msg: "Please fill quantity", color: Colors.red);
                  //                                       controllers.emailCtr.reset();
                  //                                       return;
                  //                                     }
                  //                                   }
                  //                                   sendInvoice();
                  //                                 },
                  //                                 controller: controllers.emailCtr,
                  //                                 isImage: false,
                  //                                 isLoading: true,
                  //                                 backgroundColor: colorsConst.primary,
                  //                                 radius: 5,
                  //                                 width: 200,
                  //                                 height: 50,
                  //                                 text: "Quotation",
                  //                                 textColor: Colors.white,
                  //                               ),
                  //                             ],
                  //                           )
                  //                         ],
                  //                       ),
                  //                     ],
                  //                     content: SizedBox(
                  //                         width: 600,
                  //                         height: 400,
                  //                         child: SingleChildScrollView(
                  //                           child: Column(
                  //                             children: [
                  //                               Align(
                  //                                   alignment: Alignment.topRight,
                  //                                   child: InkWell(
                  //                                       onTap: () {
                  //                                         Navigator.pop(context);
                  //                                       },
                  //                                       child: Icon(
                  //                                         Icons.clear,
                  //                                         size: 18,
                  //                                         color: colorsConst.textColor,
                  //                                       ))),
                  //                               Align(
                  //                                 alignment: Alignment.topRight,
                  //                                 child: TextButton(
                  //                                     onPressed: () {
                  //                                       controllers.isTemplate.value = !controllers.isTemplate.value;
                  //                                     },
                  //                                     child: CustomText(
                  //                                       text: "Get Form Template",
                  //                                       colors: colorsConst.third,
                  //                                       size: 18,
                  //                                       isCopy: false,
                  //                                       isBold: true,
                  //                                     )),
                  //                               ),
                  //                               Row(
                  //                                 children: [
                  //                                   CustomText(
                  //                                     textAlign: TextAlign.center,
                  //                                     text: "To",
                  //                                     colors: colorsConst.textColor,
                  //                                     size: 15,
                  //                                     isCopy: false,
                  //                                   ),
                  //                                   50.width,
                  //                                   SizedBox(
                  //                                     width: 500,
                  //                                     child: TextField(
                  //                                       controller: controllers.emailToCtr,
                  //                                       style: TextStyle(
                  //                                           fontSize: 15, color: colorsConst.textColor),
                  //                                       decoration: const InputDecoration(
                  //                                         border: InputBorder.none,
                  //                                       ),
                  //                                     ),
                  //                                   )
                  //                                 ],
                  //                               ),
                  //                               SizedBox(
                  //                                   width: 600,
                  //                                   child: SingleChildScrollView(
                  //                                     child: Column(
                  //                                       children: [
                  //                                         Divider(
                  //                                           color: Colors.grey.shade300,
                  //                                           thickness: 1,
                  //                                         ),
                  //                                         Row(
                  //                                           children: [
                  //                                             15.height,
                  //                                             CustomText(
                  //                                               text: "Subject",
                  //                                               colors: colorsConst.textColor,
                  //                                               size: 14,
                  //                                               isCopy: false,
                  //                                             ),
                  //                                             20.width,
                  //                                             SizedBox(
                  //                                               width: 500,
                  //                                               height: 50,
                  //                                               child: TextField(
                  //                                                 controller: controllers.emailSubjectCtr,
                  //                                                 maxLines: null,
                  //                                                 minLines: 1,
                  //                                                 style: TextStyle(
                  //                                                   color: colorsConst.textColor,
                  //                                                 ),
                  //                                                 decoration: const InputDecoration(
                  //                                                   border: InputBorder.none,
                  //                                                 ),
                  //                                               ),
                  //                                             )
                  //                                           ],
                  //                                         ),
                  //                                         Divider(
                  //                                           color: Colors.grey.shade300,
                  //                                           thickness: 1,
                  //                                         ),
                  //                                         Obx(() => controllers.isTemplate.value == false
                  //                                             ? SingleChildScrollView(
                  //                                           child: Column(
                  //                                             crossAxisAlignment: CrossAxisAlignment.start,
                  //                                             children: [
                  //                                               SizedBox(
                  //                                                 width: 600,
                  //                                                 height: 170,
                  //                                                 child: TextField(
                  //                                                   textInputAction: TextInputAction.newline,
                  //                                                   controller: controllers.emailMessageCtr,
                  //                                                   keyboardType: TextInputType.multiline,
                  //                                                   maxLines: 21,
                  //                                                   expands: false,
                  //                                                   style: TextStyle(
                  //                                                     color: colorsConst.textColor,
                  //                                                   ),
                  //                                                   decoration: InputDecoration(
                  //                                                     hintText: "Message",
                  //                                                     hintStyle: TextStyle(
                  //                                                         color: colorsConst.textColor,
                  //                                                         fontSize: 14,
                  //                                                         fontFamily: "Lato"),
                  //                                                     border: InputBorder.none,
                  //                                                   ),
                  //                                                 ),
                  //                                               ),
                  //                                             ],
                  //                                           ),
                  //                                         )
                  //                                         :Obx(() => UnconstrainedBox(
                  //                                           child: Container(
                  //                                             width: 500,
                  //                                             alignment: Alignment.center,
                  //                                             decoration: BoxDecoration(
                  //                                               color: colorsConst.secondary,
                  //                                               borderRadius: BorderRadius.circular(10),
                  //                                             ),
                  //                                             child: SingleChildScrollView(
                  //                                               child: Column(
                  //                                                 children: [
                  //                                                   SizedBox(
                  //                                                     width: 500,
                  //                                                     height: 170,
                  //                                                     child: Table(
                  //                                                       defaultColumnWidth: const FixedColumnWidth(120.0),
                  //                                                       border: TableBorder.all(
                  //                                                         color: Colors.grey.shade300,
                  //                                                         style: BorderStyle.solid,
                  //                                                         borderRadius: BorderRadius.circular(10),
                  //                                                         width: 1,
                  //                                                       ),
                  //                                                       children: [
                  //                                                         // Header Row
                  //                                                         TableRow(
                  //                                                           children: [
                  //                                                             CustomText(
                  //                                                               textAlign: TextAlign.center,
                  //                                                               text: "\nTemplate Name\n",
                  //                                                               colors: colorsConst.textColor,
                  //                                                               size: 15,
                  //                                                               isBold: true,
                  //                                                               isCopy: false,
                  //                                                             ),
                  //                                                             CustomText(
                  //                                                               textAlign: TextAlign.center,
                  //                                                               text: "\nSubject\n",
                  //                                                               colors: colorsConst.textColor,
                  //                                                               size: 15,
                  //                                                               isBold: true,
                  //                                                               isCopy: false,
                  //                                                             ),
                  //                                                           ],
                  //                                                         ),
                  //                                                         // Dynamic Rows
                  //                                                         for (var item in settingsController.templateList)
                  //                                                           utils.emailRow(
                  //                                                               context,
                  //                                                               isCheck: controllers.isAdd,
                  //                                                               templateName: item.templateName,
                  //                                                               msg: item.message,
                  //                                                               subject: item.subject,
                  //                                                               id: item.id
                  //                                                           ),
                  //                                                       ],
                  //                                                     ),
                  //                                                   ),
                  //                                                 ],
                  //                                               ),
                  //                                             ),
                  //                                           ),
                  //                                         ))),
                  //                                         Container(
                  //                                           width: MediaQuery.of(context).size.width*0.6,
                  //                                           decoration: customDecoration.baseBackgroundDecoration(
                  //                                             color: Colors.grey.shade50,radius: 5,
                  //                                           ),
                  //                                           child: Padding(
                  //                                             padding: const EdgeInsets.all(8.0),
                  //                                             child: CustomText(
                  //                                               textAlign: TextAlign.start,
                  //                                               text: "${controllers.selectedCustomerName.value.replaceAll(' ', '_')}_${DateFormat('dd-MM-yyyy').format(DateTime.now())} ( ${sizeInKB.toStringAsFixed(2)} KB ).pdf",
                  //                                               isCopy: false,colors: colorsConst.primary,isBold: true,),
                  //                                           ),
                  //                                         )
                  //                                       ],
                  //                                     ),
                  //                                   )),
                  //                             ],
                  //                           ),
                  //                         )),
                  //                   );
                  //                 });
                  //           }
                  //         },
                  //         style: ElevatedButton.styleFrom(
                  //           backgroundColor: const Color(0xff0078D7),
                  //           padding: const EdgeInsets.symmetric(
                  //               horizontal: 20, vertical: 12),
                  //           shape: RoundedRectangleBorder(
                  //             borderRadius: BorderRadius.circular(4),
                  //           ),
                  //         ),
                  //         child: Text(
                  //           'Send Quotation',
                  //           style: GoogleFonts.lato(
                  //               color: Colors.white,
                  //               fontSize: 14,
                  //               fontWeight: FontWeight.bold
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
              10.height,
              Divider(
                thickness: 1.5,
                color: colorsConst.secondary,
              ),
              10.height,
              /// 🔴 TABLE HEADER
              SingleChildScrollView(
                controller: _headerHorizontalController,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width:controllers.isLeftOpen.value?MediaQuery.of(context).size.width - 160:MediaQuery.of(context).size.width - 60,
                  child: Table(
                    border: TableBorder(
                      horizontalInside:
                      BorderSide(width: 0.5, color: Colors.grey.shade400),
                      verticalInside:
                      BorderSide(width: 0.5, color: Colors.grey.shade400),
                    ),
                    // columnWidths: {
                    //   0: FixedColumnWidth(60),
                    //   1: FixedColumnWidth(50),
                    //   2: FixedColumnWidth(100),
                    //   3: FixedColumnWidth(100)
                    // },
                    children: [
                      TableRow(
                        decoration: BoxDecoration(
                          color: colorsConst.primary,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(5),
                            topRight: Radius.circular(5),
                          ),
                        ),
                        children: [
                          headerCell("Customer Name", () {
                            onSort("name",
                                    () => sortList((e) => e.name.toString()));
                          }),
                          headerCell("Total Amount", () {
                            onSort("amt",
                                    () => sortList((e) => e.totalAmt.toString()));
                          }),
                          headerCell("Sent Date", () {
                            onSort("date",
                                    () => sortList((e) => e.createdTs.toString()));
                          }),
                          headerCell("Invoice", () {}),
                          headerCell("Confirm Order", () {}),
                        ],
                      )
                    ],
                  ),
                ),
              ),

              /// 🟢 TABLE BODY
              Expanded(
                child: Scrollbar(
                  controller: _horizontalController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _horizontalController,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width:controllers.isLeftOpen.value?MediaQuery.of(context).size.width - 160:MediaQuery.of(context).size.width - 60,
                      child: Scrollbar(
                        controller: _verticalController,
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          controller: _verticalController,
                          child: Obx(() => Table(
                            border: TableBorder.all(
                                color: Colors.grey.shade300),
                            // columnWidths: {
                            //   0: FixedColumnWidth(60),
                            //   1: FixedColumnWidth(50),
                            //   2: FixedColumnWidth(100),
                            //   3: FixedColumnWidth(100)
                            // },
                            children: List.generate(
                                productCtr.quotationsList.length, (index) {
                              final e = productCtr.quotationsList[index];
                              return TableRow(
                                children: [
                                  valueCell(e.name.toString()),
                                  valueCell(e.totalAmt.toString()),
                                  valueCell(e.createdTs.toString()),
                                  TextButton(
                                      onPressed: (){
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return Dialog(
                                              child: SizedBox(
                                                width: 800,
                                                height: 600,
                                                child: SfPdfViewer.network(
                                                  "$getImage?path=${e.invoicePdf}", // முக்கியம்
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                  }, child: CustomText(text: "View Invoice", isCopy: false)),
                                  TextButton(onPressed: (){
                                      apiService.confirmOrderAPI(context,e.id.toString(),e.cusId.toString(),e.totalAmt.toString(),e.name.toString());
                                  }, child: CustomText(text: "CONFIRM ORDER ${e.id.toString()}", isCopy: false,isBold: true,colors: Colors.green,),)
                                ],
                              );
                            }),
                          )),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              productCtr.quotationsList.isNotEmpty? Obx(() {
                int totalPages = productCtr.totalProspectPages.value == 0 ? 1 : productCtr.totalProspectPages.value;
                final currentPage = productCtr.currentProspectPage.value;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    utils.paginationButton(Icons.chevron_left, currentPage > 1, () {
                      _focusNode.requestFocus();
                      productCtr.currentProspectPage.value--;
                      productCtr.changeQuotationPage(productCtr.quotationsList,productCtr.quotationsList2);
                      print("controllers.currentProspectPage.value --- ${productCtr.currentProspectPage.value}");
                    }),
                    ...utils.buildPagination(totalPages, currentPage),
                    utils.paginationButton(Icons.chevron_right, currentPage < totalPages, () {
                      productCtr.currentProspectPage.value++;
                      _focusNode.requestFocus();
                      productCtr.changeQuotationPage(productCtr.quotationsList,productCtr.quotationsList2);
                      print("controllers.currentProspectPage.value +++ ${productCtr.currentProspectPage.value}");
                    }),
                  ],
                );
              }):0.height,
            ],
          ),
        )),
      ),
    );
  }

  /// 🔴 HEADER CELL
  Widget headerCell(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        child: Obx(() {
          bool isActive = controllers.sortField.value == text;

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomText(
                text: text,
                colors: Colors.white,
                isBold: true,
                isCopy: false,
              ),
              5.width,
              Image.asset(
                !isActive
                    ? "assets/images/arrow.png"
                    : controllers.sortOrderN.value == 'asc'
                    ? "assets/images/arrow_up.png"
                    : "assets/images/arrow_down.png",
                width: 15,
                height: 15,
                color: isActive ? Colors.white : Colors.grey,
              )
            ],
          );
        }),
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
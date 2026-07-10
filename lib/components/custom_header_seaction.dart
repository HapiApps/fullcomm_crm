import 'dart:convert';
import 'dart:html' as html;
import 'package:excel/excel.dart' hide Border;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fullcomm_crm/common/constant/api.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/controller/table_controller.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common/constant/colors_constant.dart';
import '../common/styles/styles.dart';
import '../common/utilities/mobile_snackbar.dart';
import '../common/utilities/utils.dart';
import '../controller/controller.dart';
import '../models/new_lead_obj.dart';
import '../models/user_heading_obj.dart';
import '../screens/leads/add_lead.dart';
import '../screens/leads/visitingCard_scan.dart';
import 'custom_loading_button.dart';
import 'custom_text.dart';

class HeaderSection extends StatefulWidget {
  final String title;
  final String subtitle;
  final bool isAction;
  final RxList<NewLeadObj> list;
  final RxList<NewLeadObj> list2;

  const HeaderSection({
    super.key,
    required this.title,
    required this.subtitle, required this.list,this.isAction = true, required this.list2
  });

  @override
  State<HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<HeaderSection> {
  Future<void> exportLeadsToExcel(
      List<NewLeadObj> leads,
      List<CustomerField> fields) async {

    print("excellllll ${leads.length} - ${fields.length}");

    final excel = Excel.createExcel();
    final sheet = excel.sheets[excel.getDefaultSheet()!];

    final headers = fields.map((f) => f.userHeading).toList();

    // Header row
    sheet?.appendRow(headers.map((h) => TextCellValue(h)).toList());

    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.blue,
      fontColorHex: ExcelColor.white,
    );

    for (var col = 0; col < headers.length; col++) {
      final cell = sheet?.cell(
        CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0),
      );
      cell?.cellStyle = headerStyle;
    }

    // Data rows
    for (final lead in leads) {
      final map = lead.toJson();

      final row = fields.map((f) {
        final value = map[f.systemField];

        return TextCellValue(
          (value == null || value.toString() == 'null')
              ? ''
              : value.toString(),
        );
      }).toList();

      sheet?.appendRow(row);
    }

    // Convert to bytes
    final fileBytes = excel.encode();

    if (fileBytes == null) {
      print("Excel encode failed");
      return;
    }

    final blob = html.Blob([fileBytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    // ✅ create download link
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "leads_export.xlsx")
      ..click();

    // ✅ delay revoke (important)
    Future.delayed(Duration(seconds: 2), () {
      html.Url.revokeObjectUrl(url);
    });
  }
  @override
  Widget build(BuildContext context) {
    final controllers = Get.find<Controller>();
    final FocusNode focusNode = FocusNode();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InkWell(
                    onTap: (){
                      Get.back();
                    }, child: Icon(Icons.arrow_back_rounded)),10.width,
                CustomText(
                  text: widget.title,
                  colors: colorsConst.textColor,
                  size: 25,
                  isBold: true,
                  isCopy: true,
                ),
              ],
            ),
            10.height,
            Padding(
              padding: const EdgeInsets.fromLTRB(35, 0, 0, 0),
              child: CustomText(
                text: widget.subtitle,
                colors: colorsConst.textColor,
                size: 14,
                isCopy: true,
              ),
            ),
          ],
        ),
        widget.isAction?Row(
          children: [
            // CustomLoadingButton(
            //   // callback: pickImageAndReadText,
            //   callback: (){
            //     Get.to(VisitingCardPage(), duration: Duration.zero);
            //     // VisitingCardScan
            //   },
            //   isLoading: false,
            //   height: 35,
            //   backgroundColor: Colors.white,
            //   radius: 2,
            //   width: 100,
            //   isImage: false,
            //   text: "V CARD",
            //   textColor: colorsConst.primary,
            // ),
            // 15.width,
            // ---- Export button ----
            controllers.storage.read("role") != "See All Customer Records"
                ? const SizedBox.shrink()
                : CustomLoadingButton(
              callback: () {
                focusNode.requestFocus();
                //Santhiya
                if(widget.list.isEmpty){
                  mobileUtils.snackBar(
                      context: Get.context!,
                      msg: "No data available to export",
                      color: Colors.red);
                }else{
                  RxList<NewLeadObj> storeList=<NewLeadObj>[].obs;
                  if(controllers.idList.isNotEmpty){
                    for(var i=0;i<controllers.idList.length;i++){
                      for(var j=0;j<widget.list.length;j++){
                        if(controllers.idList[i]==widget.list[j].userId){
                          storeList.add(widget.list[j]);
                        }
                      }
                    }
                  }
                  exportLeadsToExcel(controllers.idList.isNotEmpty?storeList:widget.list, controllers.fields);
                }
              },
              isLoading: false,
              height: 35,
              backgroundColor: Colors.white,
              radius: 2,
              width: 100,
              isImage: false,
              text: "Export",
              textColor: colorsConst.primary,
            ),
            15.width,
            // ---- Import button ----
            CustomLoadingButton(
              callback: () {
                focusNode.requestFocus();
                if(appName=="ARUU’s EasyCRM") {
                  utils.showImportDialog(
                      context, widget.title == "Target Leads" ? "0" : "1");
                }else if(appName=="Thirumal CRM"){
                  utils.showImportDialogThirumal(context, widget.title == "Target Leads" ? "0" : "1");
                }
              },
              isLoading: false,
              height: 35,
              backgroundColor: Colors.white,
              radius: 2,
              width: 100,
              isImage: false,
              text: "Import",
              textColor: colorsConst.primary,
            ),
            15.width,
            // ---- Add Lead button ----
            CustomLoadingButton(
              callback: () async {
                SharedPreferences sharedPref = await SharedPreferences.getInstance();
                final leadPersonalCount = sharedPref.getInt("leadCount") ?? 1;
                controllers.leadPersonalItems.value = leadPersonalCount;
                controllers.isMainPersonList.value = [];
                controllers.isCoMobileNumberList.value = [];
                for (int i = 0; i < leadPersonalCount; i++) {
                  controllers.isMainPersonList.add(false);
                  controllers.isCoMobileNumberList.add(false);
                }
                controllers.leadCoNameCrt.text = sharedPref.getString("leadCoName") ?? "";
                controllers.leadCoMobileCrt.text = sharedPref.getString("leadCoMobile") ?? "";
                setState(() {
                  controllers.visitType = null;
                });
                focusNode.requestFocus();
                controllers.empDOB.value = "${(controllers.dateTime.day.toString().padLeft(2, "0"))}.${(controllers.dateTime.month.toString().padLeft(2, "0"))}.${(controllers.dateTime.year.toString())}";
                Get.to( AddLead(list: widget.list,list2: widget.list2,), duration: Duration.zero);
              },
              isLoading: false,
              height: 35,
              backgroundColor: colorsConst.primary,
              radius: 2,
              width: 100,
              isImage: false,
              text: "Add Lead",
              textColor: Colors.white,
            ),
            15.width,
            // ---- Reorder Columns ----
            CustomLoadingButton(
              callback: () => showDragDropDialog(context),
              isLoading: false,
              height: 35,
              backgroundColor: Colors.white,
              radius: 2,
              width: 150,
              isImage: false,
              text: "Manage Columns",
              textColor: colorsConst.primary,
            ),
          ],
        ):SizedBox.shrink(),
      ],
    );
  }


  void showDragDropDialog(BuildContext context) {
    tableController.isLoading.value = false;
    Get.dialog(
      Dialog(
        child: Container(
          width: 400,
          height: 700,
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Manage Columns", style: TextStyle(fontSize: 18)),
                  IconButton(
                    tooltip: "Add Column",
                      onPressed: (){
                      // Navigator.of(context).pop();
                      utils.showAddColumnDialog(context);
                      },
                      icon: Icon(Icons.add))
                ],
              ),
              Divider(),
              Expanded(
                child: Obx(() {
                  return Stack(
                    children: [
                      ReorderableListView(
                        scrollController: tableController.scrollController,
                        onReorder: tableController.reorderWords,
                        children: [
                          for (int i = 0; i < tableController.headingFields.length; i++)
                            ListTile(
                              key: ValueKey(tableController.headingFields[i]),
                              leading: IconButton(
                                  onPressed: (){
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          content: CustomText(
                                            text: "Are you sure delete this column?",
                                            size: 16,
                                            isBold: true,
                                            isCopy: true,
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
                                                  callback: () async {
                                                  tableController.isLoading.value = true;
                                                  final id = controllers.fields[i].id;
                                                  final prefs = await SharedPreferences.getInstance();
                                                  tableController.headingFields.removeWhere((item) => item == controllers.fields[i].userHeading);
                                                  tableController.tableHeadings.removeWhere((item) => item == controllers.fields[i].userHeading);
                                                  await prefs.setString('tableHeadings', jsonEncode(tableController.headingFields.toList()));
                                                  tableController.deleteColumnAPI(context,id);
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
                                  icon: SvgPicture.asset(
                                    "assets/images/a_delete.svg",
                                    width: 16,
                                    height: 16,
                                  )),
                              title: TextFormField(
                                initialValue: tableController.headingFields[i],
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(40),
                                ],
                                onFieldSubmitted: (value) async {
                                  final oldValue = tableController.headingFields[i];
                                  if(value.trim().isNotEmpty){
                                    // Same value check
                                    for(var i=0;i<tableController.headingFields.length;i++){
                                      debugPrint("tableController.headingFields[i] ${tableController.headingFields[i]}");
                                      debugPrint("oldValue ${oldValue}");
                                      debugPrint("newValue ${value.trim()}");
                                      if (tableController.headingFields[i].trim().toLowerCase() ==value.trim()) {
                                        utils.showToast("This heading already exists", Colors.orange);
                                        break;
                                      }
                                    }
                                    tableController.isLoading.value = true;
                                    final id = controllers.fields[i].id;
                                    tableController.headingFields[i]=value;
                                    print(tableController.headingFields);
                                    final prefs = await SharedPreferences.getInstance();
                                    await prefs.setString('tableHeadings', jsonEncode(tableController.headingFields.toList()));
                                    tableController.updateColumnNameAPI(context, value, oldValue, id);
                                  }else{
                                    utils.showToast("Enter a value",Colors.red);
                                  }
                                },
                                decoration: InputDecoration(
                                  fillColor: Colors.purple,
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (tableController.isLoading.value)
                        Center(
                          child: CircularProgressIndicator(color: Colors.blue),
                        ),
                    ],
                  );
                }),
              ),
              // Expanded(
              //   child: Obx(() {
              //     return ReorderableListView(
              //       onReorder: tableController.reorderWords,
              //       children: [
              //         for (int i = 0; i < tableController.headingFields.length; i++)
              //           ListTile(
              //             key: ValueKey(tableController.headingFields[i]),
              //             title: TextFormField(
              //               initialValue: tableController.headingFields[i],
              //               inputFormatters: [
              //                 LengthLimitingTextInputFormatter(40),
              //               ],
              //               onChanged: (val) {
              //                 //tableController.headingFields[i] = val; // update the list
              //               },
              //               onFieldSubmitted: (value){
              //                 final id = controllers.fields[i].id;
              //                 tableController.updateColumnNameAPI(context, value, id);
              //               },
              //               decoration: InputDecoration(
              //                 border: InputBorder.none,
              //                 contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              //               ),
              //             ), // optional drag handle
              //           ),
              //       ],
              //     );
              //   }),
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomLoadingButton(
                    callback: () {
                      //Santhiya
                      // tableController.cancelChanges();
                      Get.back();
                    },
                    isLoading: false,
                    height: 35,
                    backgroundColor: Colors.white,
                    radius: 2,
                    width: 100,
                    isImage: false,
                    text: "Cancel",
                    textColor: colorsConst.primary,
                  ),
                  CustomLoadingButton(
                    callback: () {
                      tableController.applyChanges();
                      Get.back();
                    },
                    isLoading: false,
                    height: 35,
                    backgroundColor: colorsConst.primary,
                    radius: 2,
                    width: 100,
                    isImage: false,
                    text: "Apply",
                    textColor: Colors.white,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

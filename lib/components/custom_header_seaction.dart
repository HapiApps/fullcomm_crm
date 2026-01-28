import 'dart:html' as html;
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'custom_loading_button.dart';
import 'custom_text.dart';

class HeaderSection extends StatefulWidget {
  final String title;
  final String subtitle;
  final bool isAction;
  final RxList<NewLeadObj> list;

  const HeaderSection({
    super.key,
    required this.title,
    required this.subtitle, required this.list,this.isAction = true
  });

  @override
  State<HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<HeaderSection> {
  Future<void> exportLeadsToExcel(
      List<NewLeadObj> leads,
      List<CustomerField> fields,
      ) async {
    final excel = Excel.createExcel();
    final sheet = excel.sheets[excel.getDefaultSheet()!];
    final headers = fields.map((f) => f.userHeading).toList();
    sheet?.appendRow(headers.map((h) => TextCellValue(h)).toList());

    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.blue,
      fontColorHex: ExcelColor.white,
    );
    for (var col = 0; col < headers.length; col++) {
      final cell = sheet?.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0));
      cell?.cellStyle = headerStyle;
    }
    for (final lead in leads) {
      final map = lead.toJson();
      final row = fields.map((f) {
        final key = f.systemField;
        final value = map[key];
        return TextCellValue(
          (value == null || value.toString() == 'null') ? '' : value.toString(),
        );
      }).toList();
      sheet?.appendRow(row);
    }
    final fileBytes = excel.encode();
    final blob = html.Blob([fileBytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "leads_${DateTime.now().millisecondsSinceEpoch}.xlsx")
      ..click();
    html.Url.revokeObjectUrl(url);
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
            CustomText(
              text: widget.title,
              colors: colorsConst.textColor,
              size: 25,
              isBold: true,
              isCopy: true,
            ),
            10.height,
            CustomText(
              text: widget.subtitle,
              colors: colorsConst.textColor,
              size: 14,
              isCopy: true,
            ),
          ],
        ),
        widget.isAction?Row(
          children: [
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
                  exportLeadsToExcel(widget.list, controllers.fields);
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
                Get.to(const AddLead(), duration: Duration.zero);
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
              text: "Reorder Columns",
              textColor: colorsConst.primary,
            ),
          ],
        ):SizedBox.shrink(),
      ],
    );
  }
  void showAddColumnDialog(BuildContext context) {
    TextEditingController columnNameController = TextEditingController();
    var errorText;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context,setState){
          return AlertDialog(
            title: CustomText(
              text:'Add column name',
              colors: colorsConst.primary,
              isBold: true,
              isCopy: true,
            ),
            content: SizedBox(
              width: 300,
              height: 100,
              child: TextField(
                controller: columnNameController,
                autofocus: true,
                onEditingComplete: (){
                  if(columnNameController.text.isEmpty){
                    setState((){
                      errorText = "Please enter name";
                    });
                    return;
                  }
                  //Navigator.of(context).pop();
                  tableController.addColumnNameAPI(context, columnNameController.text);
                },
                decoration: customStyle.inputDecoration(
                    text: "Enter name here",
                    image: "",
                    isIcon: false,
                    isLogin: false,
                    errorText: errorText,
                    onPressed: (){}),
                onChanged: (value){
                  setState(() {
                    errorText = null;
                  });
                },
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  if(columnNameController.text.isEmpty){
                    setState((){
                      errorText = "Please enter name";
                    });
                    return;
                  }
                  //Navigator.of(context).pop();
                  tableController.addColumnNameAPI(context, columnNameController.text);

                },
              ),
            ],
          );
        });
      },
    );}

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
                  Text("Reorder Columns", style: TextStyle(fontSize: 18)),
                  IconButton(
                    tooltip: "Add Column",
                      onPressed: (){
                      Navigator.of(context).pop();
                      showAddColumnDialog(context);
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
                        onReorder: tableController.reorderWords,
                        children: [
                          for (int i = 0; i < tableController.headingFields.length; i++)
                            ListTile(
                              key: ValueKey(tableController.headingFields[i]),
                              title: TextFormField(
                                initialValue: tableController.headingFields[i],
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(40),
                                ],
                                onFieldSubmitted: (value) {
                                  tableController.isLoading.value = true;
                                  final id = controllers.fields[i].id;
                                  tableController.updateColumnNameAPI(context, value, id);
                                },
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (tableController.isLoading.value)
                        Container(
                          color: colorsConst.secondary,
                          child: Center(
                            child: CircularProgressIndicator(color: Colors.blue),
                          ),
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

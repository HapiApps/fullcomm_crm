import 'dart:html' as html;
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fullcomm_crm/common/constant/api.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/components/custom_textfield.dart';
import 'package:fullcomm_crm/controller/table_controller.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common/constant/colors_constant.dart';
import '../common/utilities/utils.dart';
import '../controller/controller.dart';
import '../models/new_lead_obj.dart';
import '../models/user_heading_obj.dart';
import '../screens/leads/add_lead.dart';
import 'custom_loading_button.dart';
import 'custom_text.dart';
import 'package:intl/intl.dart';

class HeaderSection extends StatefulWidget {
  final String title;
  final String subtitle;
  final RxList<NewLeadObj> list;

  const HeaderSection({
    super.key,
    required this.title,
    required this.subtitle, required this.list,
  });

  @override
  State<HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<HeaderSection> {
  dynamic getFieldValue(NewLeadObj lead, String field) {
    switch (field) {
      case 'name':
        var name = lead.firstname ?? '';
        if (name.contains('||')) name = name.split('||')[0].trim();
        return name;
      case 'company_name':
        return lead.companyName ?? '';
      case 'mobile_number':
        return lead.mobileNumber ?? '';
      case 'detailsOfServiceRequired':
        return lead.detailsOfServiceRequired ?? '';
      case 'source':
        return lead.source ?? '';
      case 'city':
        return lead.city ?? '';
      case 'status_update':
        return lead.statusUpdate ?? '';
      case 'prospect_enrollment_date':
      case 'date':
        DateTime parseDate(String? dateStr, String? fallback) {
          if (dateStr == null || dateStr.isEmpty || dateStr == "null") {
            dateStr = fallback;
          }
          if (dateStr == null || dateStr.isEmpty || dateStr == "null") {
            return DateTime(1900);
          }
          DateTime? parsed;
          try {
            parsed = DateFormat('dd.MM.yyyy').parse(dateStr);
          } catch (_) {
            parsed = DateTime.tryParse(dateStr);
          }
          return parsed ?? DateTime(1900);
        }
        final date = parseDate(lead.updatedTs, lead.prospectEnrollmentDate);
        return DateFormat('dd-MM-yyyy').format(date);
      default:
        final value = lead.asMap()[field];
        return value?.toString() ?? '';
    }
  }
  Future<void> exportLeadsToExcel(
      List<NewLeadObj> leads,
      List<CustomerField> fields,
      ) async {
    final excel = Excel.createExcel();
    final sheet = excel.sheets[excel.getDefaultSheet()!];
    String normalize(String s) =>
        s.replaceAll(RegExp(r'\s+'), ' ').trim().toLowerCase();
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

  // Future<void> exportLeadsToExcel(
  //     List<NewLeadObj> leads,
  //     List<CustomerField> fields, // your controllers.fields
  //     ) async {
  //   final excel = Excel.createExcel();
  //   excel.delete('Sheet1');
  //   final sheet = excel['Leads'];
  //
  //   String normalize(String s) =>
  //       s.replaceAll(RegExp(r'\s+'), ' ').trim().toLowerCase();
  //
  //   final headers = fields.map((f) => f.userHeading).toList();
  //   sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());
  //
  //   final headerStyle = CellStyle(
  //     bold: true,
  //     backgroundColorHex: ExcelColor.blue,
  //     fontColorHex: ExcelColor.white,
  //   );
  //   for (var col = 0; col < headers.length; col++) {
  //     final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0));
  //     cell.cellStyle = headerStyle;
  //   }
  //   for (final lead in leads) {
  //     // print("--------------------------------------------------");
  //     // print("Lead Object: ${lead.toJson()}");
  //     //
  //     // for (final f in fields) {
  //     //   final key = f.systemField;
  //     //   final heading = f.userHeading;
  //     //   final value = lead.toJson()[key];
  //     //   print("[$heading] key=$key => value=$value");
  //     // }
  //     final map = lead.toJson();
  //     final row = fields.map((f) {
  //       final key = f.systemField;
  //       final value = map[key];
  //       return TextCellValue(
  //         (value == null || value.toString() == 'null') ? '' : value.toString(),
  //       );
  //     }).toList();
  //     sheet.appendRow(row);
  //   }
  //   final fileBytes = excel.encode();
  //   final blob = html.Blob([fileBytes]);
  //   final url = html.Url.createObjectUrlFromBlob(blob);
  //   final anchor = html.AnchorElement(href: url)
  //     ..setAttribute("download", "leads_${DateTime.now().millisecondsSinceEpoch}.xlsx")
  //     ..click();
  //   html.Url.revokeObjectUrl(url);
  // }

  @override
  Widget build(BuildContext context) {
    final controllers = Get.find<Controller>();
    final FocusNode _focusNode = FocusNode();
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
            ),
            10.height,
            CustomText(
              text: widget.subtitle,
              colors: colorsConst.textColor,
              size: 14,
            ),
          ],
        ),
        Row(
          children: [
            // ---- Export button ----
            controllers.storage.read("role") != "See All Customer Records"
                ? const SizedBox.shrink()
                : CustomLoadingButton(
              callback: () {
                _focusNode.requestFocus();
                exportLeadsToExcel(widget.list, controllers.fields);
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
                _focusNode.requestFocus();
                if(appName=="ARUU’s EasyCRM") {
                  print("ARUU’s EasyCRM");
                  utils.showImportDialog(
                      context, widget.title == "Target Leads" ? "0" : "1");
                }else if(appName=="Thirumal CRM"){
                  print("Thirumal CRM");
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
                _focusNode.requestFocus();
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
        ),
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
            ),
            content: SizedBox(
              width: 300,
              height: 100,
              child: CustomTextField(
                text: "Name",
                controller: columnNameController,
                isOptional: true,
                hintText: "Enter name here",
                width: 300,
                onChanged: (value){
                  setState(() {
                    errorText = null;
                  });
                },
                errorText: errorText,
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
                  tableController.addColumnNameAPI(context, columnNameController.text);
                  Navigator.of(context).pop();
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
                      tableController.cancelChanges();
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

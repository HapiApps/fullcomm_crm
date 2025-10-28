import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/components/custom_textfield.dart';
import 'package:fullcomm_crm/controller/table_controller.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common/constant/colors_constant.dart';
import '../common/utilities/utils.dart';
import '../controller/controller.dart';
import '../screens/leads/add_lead.dart';
import 'custom_loading_button.dart';
import 'custom_text.dart';

class HeaderSection extends StatefulWidget {
  final String title;
  final String subtitle;

  const HeaderSection({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  State<HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<HeaderSection> {
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
            // ---- Import button ----
            CustomLoadingButton(
              callback: () {
                _focusNode.requestFocus();
                utils.showImportDialog(context);
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

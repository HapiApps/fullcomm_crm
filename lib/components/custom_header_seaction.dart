import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
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

  void showDragDropDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        child: Container(
          width: 400,
          height: 700,
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Text("Reorder Columns", style: TextStyle(fontSize: 18)),
              Divider(),
              Expanded(
                child: Obx(() {
                  return ReorderableListView(
                    onReorder: tableController.reorderWords,
                    children: [
                      for (int i = 0; i < tableController.headingFields.length; i++)
                        ListTile(
                          key: ValueKey(tableController.headingFields[i]),
                          title: Text(tableController.headingFields[i]),
                        ),
                    ],
                  );
                }),
              ),
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

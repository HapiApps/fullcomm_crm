import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common/constant/colors_constant.dart';
import '../common/utilities/utils.dart';
import '../controller/controller.dart';
import '../screens/leads/add_lead.dart';
import 'custom_loading_button.dart';
import 'custom_text.dart';

class HeaderSection extends StatelessWidget {
  final String title;
  final String subtitle;

  const HeaderSection({
    super.key,
    required this.title,
    required this.subtitle,
  });

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
              text: title,
              colors: colorsConst.textColor,
              size: 25,
              isBold: true,
            ),
            10.height,
            CustomText(
              text: subtitle,
              colors: colorsConst.textColor,
              size: 14,
            ),
          ],
        ),
        Row(
          children: [
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

                controllers.leadCoNameCrt.text =
                    sharedPref.getString("leadCoName") ?? "";
                controllers.leadCoMobileCrt.text =
                    sharedPref.getString("leadCoMobile") ?? "";

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
          ],
        ),
      ],
    );
  }
}

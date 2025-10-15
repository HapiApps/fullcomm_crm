import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:get/get.dart';
import '../../common/constant/colors_constant.dart';
import '../../common/utilities/utils.dart';
import '../../components/custom_loading_button.dart';
import '../../components/custom_search_textfield.dart';
import '../../components/custom_text.dart';
import '../../controller/controller.dart';
import '../../controller/reminder_controller.dart';

class AddOfficeHours extends StatefulWidget {
  const AddOfficeHours({super.key});

  @override
  State<AddOfficeHours> createState() => _AddOfficeHoursState();
}

class _AddOfficeHoursState extends State<AddOfficeHours> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          utils.sideBarFunction(context),
          Obx(()=> Container(
            width:controllers.isLeftOpen.value?MediaQuery.of(context).size.width - 150:MediaQuery.of(context).size.width - 60,
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.center,
            padding: EdgeInsets.fromLTRB(16, 5, 16, 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: "General Settings",
                          colors: colorsConst.textColor,
                          size: 20,
                          isBold: true,
                        ),
                        10.height,
                        CustomText(
                          text: "View all of your call activity Report",
                          colors: colorsConst.textColor,
                          size: 14,
                        ),
                      ],
                    ),
                  ],
                ),
                Divider(
                  thickness: 1.5,
                  color: colorsConst.secondary,
                ),
                20.height,
                CustomText(text: "Office Working Hours"),
                10.height,
                Row(
                  children: [

                  ],
                )
              ],
            ),
          ))
        ],
      ),
    );
  }
}

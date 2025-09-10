import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';

import '../common/constant/colors_constant.dart';
import '../controller/controller.dart';
import '../services/api_services.dart';
import 'custom_loading_button.dart';
import 'custom_text.dart';

class DisqualifiedButton extends StatelessWidget {
  final List leadList;
  final VoidCallback callback;
  final FocusNode focusNode;
  const DisqualifiedButton({super.key, required this.leadList, required this.callback, required this.focusNode});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: "Click here to disqualified the customer details",
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: colorsConst.backgroundColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                  side: BorderSide(color: colorsConst.primary)
              )
          ),
          onPressed: () {
            focusNode.requestFocus();
            if(leadList.isNotEmpty){

            }else{
              focusNode.requestFocus();
              apiService.errorDialog(
                  context, "Please select customers");
            }
          },
          child: CustomText(text: "Disqualified",colors: colorsConst.primary,)
      ),
    );
  }
}

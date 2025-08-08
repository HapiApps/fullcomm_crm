import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';

import '../common/constant/colors_constant.dart';
import '../controller/controller.dart';
import '../services/api_services.dart';
import 'custom_loading_button.dart';
import 'custom_text.dart';

class DeleteButton extends StatelessWidget {
  final List leadList;
  final VoidCallback callback;
  const DeleteButton(
      {super.key, required this.leadList, required this.callback});

  @override
  Widget build(BuildContext context) {
    return IconButton(
        tooltip: "Click here to delete the customer details",
        onPressed: () {
          if (leadList.isNotEmpty) {
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return AlertDialog(
                    backgroundColor: colorsConst.secondary,
                    content: CustomText(
                      text: "Are you sure delete this customers?",
                      size: 16,
                      isBold: true,
                      colors: colorsConst.textColor,
                    ),
                    actions: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: colorsConst.third),
                                color: colorsConst.primary),
                            width: 80,
                            height: 25,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero),
                                  backgroundColor: colorsConst.primary,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const CustomText(
                                  text: "Cancel",
                                  colors: Colors.white,
                                  size: 14,
                                )),
                          ),
                          10.width,
                          CustomLoadingButton(
                            callback: callback,
                            height: 35,
                            isLoading: true,
                            backgroundColor: colorsConst.third,
                            radius: 2,
                            width: 80,
                            controller: controllers.productCtr,
                            isImage: false,
                            text: "Delete",
                            textColor: colorsConst.primary,
                          ),
                          5.width
                        ],
                      ),
                    ],
                  );
                });
          } else {
            apiService.errorDialog(context, "Please select customers");
          }
        },
        icon: SvgPicture.asset("assets/images/delete.svg"));
  }
}

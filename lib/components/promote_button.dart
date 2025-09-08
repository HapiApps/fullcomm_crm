import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import '../common/constant/colors_constant.dart';
import '../controller/controller.dart';
import '../services/api_services.dart';
import 'custom_loading_button.dart';
import 'custom_text.dart';

class PromoteButton extends StatelessWidget {
  final String headText;
  final List leadList;
  final String text;
  final VoidCallback callback;
  const PromoteButton(
      {super.key,
      required this.headText,
      required this.leadList,
      required this.callback,
      required this.text});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: "$text To $headText",
      child: InkWell(
        onTap: () {
          if (leadList.isEmpty) {
            apiService.errorDialog(context, "Please select lead");
            //utils.snackBar(context: Get.context!, msg: "Please select lead",color:Colors.green,);
          } else {
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return AlertDialog(
                    content: CustomText(
                      text: "Are you moving to the next level?",
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
                                  colors: colorsConst.primary,
                                  size: 14,
                                )),
                          ),
                          10.width,
                          CustomLoadingButton(
                            callback: callback,
                            height: 35,
                            isLoading: true,
                            backgroundColor: colorsConst.primary,
                            radius: 2,
                            width: 80,
                            controller: controllers.productCtr,
                            isImage: false,
                            text: "Move",
                            textColor: Colors.white,
                          ),
                          5.width
                        ],
                      ),
                    ],
                  );
                });
          }
        },
        child: Container(
          width: 100,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: colorsConst.primary,
              borderRadius: BorderRadius.circular(10)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              text == "Promote"
                  ? 0.width
                  : IconButton(
                      tooltip: "$text To $headText",
                      onPressed: () {
                        if (leadList.isEmpty) {
                          apiService.errorDialog(context, "Please select lead");
                          //utils.snackBar(context: Get.context!, msg: "Please select lead",color:Colors.green,);
                        } else {
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) {
                                return AlertDialog(
                                  content: CustomText(
                                    text: "Are you moving to the next level?",
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
                                              border: Border.all(
                                                  color: colorsConst.primary),
                                              color: Colors.white),
                                          width: 80,
                                          height: 25,
                                          child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                shape: const RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.zero),
                                                backgroundColor: Colors.white,
                                              ),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: CustomText(
                                                text: "Cancel",
                                                colors: colorsConst.primary,
                                                size: 14,
                                              )),
                                        ),
                                        10.width,
                                        CustomLoadingButton(
                                          callback: callback,
                                          height: 35,
                                          isLoading: true,
                                          backgroundColor: colorsConst.primary,
                                          radius: 2,
                                          width: 80,
                                          controller: controllers.productCtr,
                                          isImage: false,
                                          text: "Move",
                                          textColor: Colors.white,
                                        ),
                                        5.width
                                      ],
                                    ),
                                  ],
                                );
                              });
                        }
                      },
                      icon: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(3.1416), // or math.pi
                        child: SvgPicture.asset(
                          "assets/images/move.svg",
                          height: 30,
                          width: 30,
                          color: Colors.white,
                        ),
                      )),
              Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              text == "Demote"
                  ? 0.width
                  : IconButton(
                      tooltip: "$text To $headText",
                      onPressed: () {
                        if (leadList.isEmpty) {
                          apiService.errorDialog(context, "Please select lead");
                          //utils.snackBar(context: Get.context!, msg: "Please select lead",color:Colors.green,);
                        } else {
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) {
                                return AlertDialog(
                                  content: CustomText(
                                    text: "Are you moving to the next level?",
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
                                              border: Border.all(
                                                  color: colorsConst.primary),
                                              color: Colors.white),
                                          width: 80,
                                          height: 25,
                                          child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                shape: const RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.zero),
                                                backgroundColor: Colors.white,
                                              ),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: CustomText(
                                                text: "Cancel",
                                                colors: colorsConst.primary,
                                                size: 14,
                                              )),
                                        ),
                                        10.width,
                                        CustomLoadingButton(
                                          callback: callback,
                                          height: 35,
                                          isLoading: true,
                                          backgroundColor: colorsConst.primary,
                                          radius: 2,
                                          width: 80,
                                          controller: controllers.productCtr,
                                          isImage: false,
                                          text: "Move",
                                          textColor: Colors.white,
                                        ),
                                        5.width
                                      ],
                                    ),
                                  ],
                                );
                              });
                        }
                      },
                      icon: SvgPicture.asset("assets/images/move.svg",color: Colors.white,)),
            ],
          ),
        ),
      ),
    );
  }
}

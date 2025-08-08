import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fullcomm_crm/common/constant/colors_constant.dart';
import 'package:fullcomm_crm/common/extentions/lib_extensions.dart';
import 'package:fullcomm_crm/components/custom_checkbox.dart';
import 'package:fullcomm_crm/components/custom_text.dart';
import 'package:fullcomm_crm/controller/controller.dart';
import '../common/constant/assets_constant.dart';

class CustomCustomerTile extends StatefulWidget {
  final String? customId;
  final String? fullName;
  final String? mobileNumber;
  final String? emailId;
  final String? companyName;

  const CustomCustomerTile(
      {super.key,
      this.customId,
      this.fullName,
      this.mobileNumber,
      this.emailId,
      this.companyName});

  @override
  State<CustomCustomerTile> createState() => _CustomCustomerTileState();
}

class _CustomCustomerTileState extends State<CustomCustomerTile> {
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    double minPartWidth =
        1230 > screenSize.width - 250 ? 980 : screenSize.width - 380.0;
    return Column(
      children: [
        20.height,
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SvgPicture.asset(
              assets.list,
              width: 23,
              height: 23,
            ),
            10.width,
            Container(
              width: 1230 > MediaQuery.of(context).size.width - 250
                  ? 1100
                  : MediaQuery.of(context).size.width - 280,
              height: 50,
              decoration: BoxDecoration(
                  color: Colors.white,
                  // border: Border.all(
                  //   color: colorsConst.secondary,
                  // ),
                  boxShadow: [
                    BoxShadow(
                      color: colorsConst.secondary,
                      blurRadius: 1,
                    )
                  ],
                  borderRadius: BorderRadius.circular(5)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: minPartWidth / 16,
                    alignment: Alignment.center,
                    child: CustomCheckBox(
                        text: "",
                        onChanged: (value) {
                          controllers.isMainPerson.value =
                              !controllers.isMainPerson.value;
                        },
                        saveValue: controllers.isMainPerson.value),
                  ),
                  SizedBox(
                    width: 1230 > screenSize.width - 250
                        ? 980
                        : screenSize.width - 380.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: minPartWidth / 6,
                          child: CustomText(
                            textAlign: TextAlign.start,
                            text: "    ${widget.customId}",
                            colors: Colors.black,
                            size: 14,
                          ),
                        ),
                        SizedBox(
                          width: minPartWidth / 5,
                          child: CustomText(
                            textAlign: TextAlign.start,
                            text: "          ${widget.fullName}",
                            colors: Colors.black,
                            size: 14,
                          ),
                        ),
                        SizedBox(
                          width: minPartWidth / 7,
                          child: CustomText(
                            textAlign: TextAlign.start,
                            text: widget.mobileNumber.toString(),
                            colors: Colors.black,
                            size: 14,
                          ),
                        ),
                        SizedBox(
                          width: minPartWidth / 5,
                          child: CustomText(
                            textAlign: TextAlign.center,
                            text: widget.emailId.toString(),
                            colors: Colors.black,
                            size: 14,
                          ),
                        ),
                        SizedBox(
                          width: minPartWidth / 5,
                          child: CustomText(
                            textAlign: TextAlign.center,
                            text: widget.companyName.toString(),
                            colors: Colors.black,
                            size: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

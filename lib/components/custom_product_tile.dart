
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fullcomm_crm/common/constant/colors_constant.dart';
import 'package:fullcomm_crm/common/extentions/lib_extensions.dart';
import 'package:fullcomm_crm/components/custom_checkbox.dart';
import 'package:fullcomm_crm/components/custom_text.dart';
import 'package:fullcomm_crm/controller/controller.dart';
import '../common/constant/assets_constant.dart';

class CustomProductTile extends StatefulWidget {
  final String? productName;
  final String? brand;
  final String? comparePrice;
  final String? discountPrice;
  final String? productPrice;

  const CustomProductTile({super.key,
    this.productName,this.brand,
    this.comparePrice,this.discountPrice,this.productPrice
  });

  @override
  State<CustomProductTile> createState() => _CustomProductTileState();
}

class _CustomProductTileState extends State<CustomProductTile> {
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    double minPartWidth = 1230>screenSize.width-250?980:screenSize.width-380.0;
    return Column(
      children: [
        20.height,
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children:[
            SvgPicture.asset(assets.list,width: 23,height: 23,),
            10.width,
            Container(
              width: 1230>MediaQuery.of(context).size.width-250?1100:MediaQuery.of(context).size.width-280,
              height: 50,
              decoration: BoxDecoration(
                  color: Colors.white,
                  // border: Border.all(
                  //   color: colorsConst.secondary,
                  // ),
                  boxShadow: [
                    BoxShadow(
                      color: colorsConst.secondary,
                      blurRadius:1,
                    )
                  ],
                  borderRadius: BorderRadius.circular(5)
              ),
              child:Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width:minPartWidth/16,
                    alignment: Alignment.center,
                    child: CustomCheckBox(

                        text: "",
                        onChanged: (value){
                          controllers.isMainPerson.value=!controllers.isMainPerson.value;
                        },
                        saveValue: controllers.isMainPerson.value),
                  ),

                  SizedBox(
                    width:1230>screenSize.width-250?980:MediaQuery.of(context).size.width-380,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width:minPartWidth / 6,
                          child: CustomText(
                            textAlign: TextAlign.start,
                            text:"    ${widget.productName}" ,
                            colors: Colors.black,
                            size: 14,
                          ),
                        ),
                        SizedBox(
                          width:minPartWidth / 6,
                          child: CustomText(
                            textAlign: TextAlign.start,
                            text:widget.brand.toString(),
                            colors: Colors.black,
                            size: 14,
                          ),
                        ),
                        SizedBox(
                          width:minPartWidth / 6,
                          child: CustomText(
                            textAlign: TextAlign.start,
                            text:widget.comparePrice.toString(),
                            colors: Colors.black,
                            size: 14,
                          ),
                        ),
                        SizedBox(
                          width:minPartWidth / 6,
                          child: CustomText(
                            textAlign: TextAlign.center,
                            text:widget.discountPrice.toString(),
                            colors: Colors.black,
                            size: 14,
                          ),
                        ),
                        SizedBox(
                          width:minPartWidth / 6,
                          child: CustomText(
                            textAlign: TextAlign.center,
                            text:widget.productPrice.toString(),
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

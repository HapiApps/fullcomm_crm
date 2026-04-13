import 'package:flutter/material.dart';

import '../../common/constant/colors_constant.dart';
import '../colors.dart';
import 'k_text.dart';

class BottomWidgets {

  // Bottom Card that shows Discount,Tax,SubTotal,etc.
  static Widget valueCard({required BuildContext context,required String title,required String value, required bool isBold}) {

    double screenHeight  = MediaQuery.of(context).size.height;
    double screenWidth   = MediaQuery.of(context).size.width;

    return Container(
      height: screenHeight*0.14,
      width: screenWidth*0.13,
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color:AppColors.black.withOpacity(0.25),
              spreadRadius: -5,
              blurRadius: 10,
              offset: const Offset(10, 0),
            ),
          ],
          color:AppColors.white,
          borderRadius: BorderRadius.circular(6)
      ),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              width: screenWidth,
              height: screenHeight*0.06,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                  color: colorsConst.primary
              ),
              child: MyText(text: title,color: Colors.white,textAlign: TextAlign.center,fontSize: 18,fontWeight: FontWeight.bold ,),
            ),
            Container(
              alignment: Alignment.center,
              height: screenHeight*0.05,
              child: MyText(text: value, color: isBold ? Colors.blueAccent : Colors.black,fontSize: isBold ? 15 : 15,textAlign: TextAlign.center,
                fontWeight:FontWeight.bold ),
            ),
          ]
      ),
    );

  }

  static Widget valueRight({required BuildContext context,required String title,required String value, required bool isBold}) {

    double screenHeight  = MediaQuery.of(context).size.height;
    double screenWidth   = MediaQuery.of(context).size.width;

    return Container(
      height: screenHeight*0.14,
      width: screenWidth*0.13,
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color:AppColors.black.withOpacity(0.25),
              spreadRadius: -5,
              blurRadius: 10,
              offset: const Offset(10, 0),
            ),
          ],
          color:AppColors.white,
          borderRadius: BorderRadius.circular(6)
      ),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              width: screenWidth,
              height: screenHeight*0.06,
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                  color: Colors.green
              ),
              child: MyText(text: title,color:Colors.white,textAlign: TextAlign.center,fontSize: 18,fontWeight: FontWeight.bold,),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Container(
                alignment: Alignment.centerRight,
                height: screenHeight*0.05,
                child: MyText(text: value, color: isBold ? Colors.blueAccent : Colors.black,fontSize: isBold ? 17 : 17,textAlign: TextAlign.center,
                  fontWeight:FontWeight.bold ),
              ),
            ),

          ]
      ),
    );

  }
}
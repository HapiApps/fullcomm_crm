import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/common/styles/decoration.dart';
import 'package:fullcomm_crm/common/utilities/utils.dart';
import 'package:fullcomm_crm/controller/settings_controller.dart';
import 'package:fullcomm_crm/screens/settings/terms_conditions.dart';
import 'package:get/get.dart';
import '../../common/constant/colors_constant.dart';
import '../../common/constant/key_constant.dart';
import '../../components/custom_loading_button.dart';
import '../../components/custom_search_textfield.dart';
import '../../components/custom_sidebar.dart';
import '../../components/custom_text.dart';
import '../../components/custom_textfield.dart';
import '../../components/keyboard_search.dart';
import '../../controller/controller.dart';
import '../../controller/dashboard_controller.dart';
import '../../controller/product_controller.dart';
import '../../models/all_customers_obj.dart';
import '../../services/api_services.dart';
import 'lead_categories.dart';

class QuotationSettings extends StatefulWidget {
  const QuotationSettings({super.key});

  @override
  State<QuotationSettings> createState() => _QuotationSettingsState();
}

class _QuotationSettingsState extends State<QuotationSettings> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () {
      controllers.insertSeriesNo();
    });
  }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SideBar(),
          Obx(()=> Container(
            width:controllers.isLeftOpen.value?MediaQuery.of(context).size.width - 150:MediaQuery.of(context).size.width - 60,
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.center,
            padding: EdgeInsets.fromLTRB(16, 5, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: "\nInvoice Settings",
                          colors: colorsConst.textColor,
                          size: 20,
                          isBold: true,
                          isCopy: true,
                        ),
                        10.height,
                        CustomText(
                          text: "Manage global settings across the application.  \n",
                          colors: colorsConst.textColor,
                          isCopy: true,
                          size: 14,
                        ),
                      ],
                    ),
                  ],
                ),
                10.height,
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                      InkWell(
                        onTap:(){
                          Navigator.push(context, MaterialPageRoute(builder: (_)=>TermsAndConditions()));
                        },
                        child: Container(
                          width:screenWidth/5,
                          decoration: customDecoration.baseBackgroundDecoration(
                              color: Colors.white,borderColor: Colors.grey.shade200,radius: 15,shadowColor: Colors.grey.shade300
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width:35,height:35,
                                        decoration: customDecoration.baseBackgroundDecoration(
                                            color: colorsConst.primary.withOpacity(0.2),radius: 5
                                        ),
                                        child: Center(child: Image.asset("assets/images/setting1.png"),)),10.width,
                                    CustomText(
                                      text: "1. Terms & Condition",
                                      colors: colorsConst.textColor,size: 20,
                                      isBold: true,
                                      isCopy: true,
                                    ),
                                  ],
                                ),10.height,
                                CustomText(
                                  text: "Manage the order and structure of categories used across the dashboard billing.",
                                  isCopy: true,textAlign: TextAlign.start,
                                ),5.height,
                                Divider(thickness: 0.2,color: Colors.grey,),5.height,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Image.asset("assets/images/setting4.png",width: 15,height: 15,),
                                        5.width,
                                        CustomText(
                                          text: "${productCtr.termsAndConditionsList.length} Conditions",
                                          isCopy: true,
                                        ),
                                      ],
                                    ),
                                    Container(
                                        decoration: customDecoration.baseBackgroundDecoration(
                                            color: colorsConst.primary.withOpacity(0.2),radius: 15
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: CustomText(text:"Manage Conditions >",colors: colorsConst.primary,isCopy: false,),
                                        ))
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),10.width,
                      InkWell(
                        onTap: (){
                          // utils.showFilterDialog(context);
                        },
                        child: Container(
                          width:screenWidth/5,
                          decoration: customDecoration.baseBackgroundDecoration(
                              color: Colors.white,borderColor: Colors.grey.shade200,radius: 15,shadowColor: Colors.grey.shade300
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width:35,height:35,
                                        decoration: customDecoration.baseBackgroundDecoration(
                                            color: colorsConst.primary.withOpacity(0.2),radius: 5
                                        ),
                                        child: Center(child: Icon(Icons.calendar_today_outlined,color: colorsConst.primary,size: 20,))),10.width,
                                    CustomText(
                                      text: "2. Quotation Series",
                                      colors: colorsConst.textColor,size: 20,
                                      isBold: true,
                                      isCopy: true,
                                    ),
                                  ],
                                ),10.height,
                                CustomText(
                                  text: "Choose the default time filter applied to dashboard records and analytics billing.",
                                  isCopy: true,textAlign: TextAlign.start,
                                ),5.height,
                                Divider(thickness: 0.2,color: Colors.grey,),5.height,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Image.asset("assets/images/setting3.png",width: 15,height: 15,),5.width,
                                        CustomText(
                                          text: "CQ0001",
                                          isCopy: true,
                                        )
                                      ],
                                    ),
                                    Container(
                                        decoration: customDecoration.baseBackgroundDecoration(
                                            color: colorsConst.primary.withOpacity(0.2),radius: 15
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: CustomText(text:"Configure Series >",colors: colorsConst.primary,isCopy: false,),
                                        ))
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ))
        ],
      ),
    );
  }
  Widget stepWidget(String number,String title,Color bg,Color textClr){
    return Row(
      children: [
        CircleAvatar(
          radius: 10,
          backgroundColor: bg,
          child: CustomText(text:number,size: 10,isCopy: false,colors: textClr,),
        ),
        const SizedBox(width:6),
        CustomText(text:title,size: 12, isCopy: false,colors: Colors.grey)
      ],
    );
  }

}

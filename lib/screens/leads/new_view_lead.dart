import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fullcomm_crm/common/constant/colors_constant.dart';
import 'package:fullcomm_crm/common/extentions/int_extensions.dart';
import 'package:fullcomm_crm/components/custom_text.dart';
import '../../common/constant/key_constant.dart';
import '../../common/styles/styles.dart';
import '../../components/custom_textfield.dart';
import '../../controller/controller.dart';


class CustomCard extends StatelessWidget {
  const CustomCard({super.key,});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                PersonalInfoCard(userName: 'Rohini', img: 'assets/images/hot.svg', amName: 'Rohini', date: 'August 20 2026', emailPressed: () {  }, callPressed: () {  }, whPressed: () {  },),
                LeadContactInformationCard(userNo: "91828483727", whNo: "91828483727", lin: "hafh", x: "dgfhr", emailId: "dhfjd", web: "dygfj"),
                CommonInfoCard(img:"assets/images/info.svg",heading:"Company Information",compName: 'qwertfghjlljhjgf', compEmail: 'drtfgcyt', compNo: 'ygyg', compIn: 'tftgfh',isText: false,onPressed: (){}, comHeading1: "Company Name", comHeading2: "Company Email", comHeading3: "Company Phone No.", comHeading4: 'Industry',),
                CommonInfoCard(img:"assets/images/distance.svg",heading:"Address Details",compName: 'qwertfghjlljhjgf', compEmail: 'drtfgcyt', compNo: 'ygyg', compIn: 'tftgfh',isText: true,onPressed: (){}, comHeading1: 'Door, Street', comHeading2: 'State', comHeading3: 'Area, City', comHeading4: 'Country',),
                CommonInfoCard(img:"assets/images/communication.svg",heading:"Discussion & Qualification",compName: 'qwertfghjlljhjgf', compEmail: 'drtfgcyt', compNo: 'ygyg', compIn: 'tftgfh',isText: false,onPressed: (){}, comHeading1: 'Quotation Required', comHeading2: 'Product Disscussed', comHeading3: 'Discussion Point', comHeading4: 'Additional Notes',),
              ],
            ),
            Column(
              children: [
                StatusCard( heading: "Urgent",),
                TimeLineCard(heading: 'August 1, 2024', heading1: 'August 1, 2024',),
                SizedBox(
                  width: MediaQuery.of(context).size.width*0.3,
                  child: Card(
                    color: colorsConst.secondary,
                    elevation: 0, // shadow height
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5), // rounded edges
                    ),
                    child: Padding(
                      padding:  const EdgeInsets.all(30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: "Status Update",
                            size: 15,
                            isBold: true,
                            colors: colorsConst.textColor,
                          ),
                          20.height,
                          CustomTextField(
                            hintText: "Status",
                            text: "Status",
                            controller: controllers.leadCoNameCrt,
                            width: 300,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            isOptional: false,
                            inputFormatters: constInputFormatters.textInput,
                            onChanged: (value) async {},
                          ),
                          20.height,

                        ],
                      ),
                    ),
                  ),
                ),

              ],
            )
          ],
        ),
      ),
    );
  }
}
class PersonalInfoCard extends StatelessWidget {
  final String userName;
  final String amName;
  final String date;
  final String img;
  final VoidCallback emailPressed;
  final VoidCallback callPressed;
  final VoidCallback whPressed;

  const PersonalInfoCard({super.key, required this.userName, required this.img, required this.amName, required this.date, required this.emailPressed, required this.callPressed, required this.whPressed});
  @override
  Widget build(BuildContext context) {
    return  SizedBox(
      width: MediaQuery.of(context).size.width*0.4,
      child: Card(
        color: colorsConst.secondary,
        elevation: 0, // shadow height
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5), // rounded edges
        ),
        child: Padding(
          padding:  const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: userName,
                size: 15,
                isBold: true,
                colors: colorsConst.textColor,
              ),
              20.height,
              SvgPicture.asset(
                img,
                height: 25,
                width: 40,
              ),
              20.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: "Account Manager",
                        size: 15,
                        isBold: false,
                        colors: colorsConst.textColor,
                      ),

                      CustomText(
                        text: amName,
                        size: 15,
                        isBold: true,
                        colors: colorsConst.textColor,
                      ),
                    ],
                  ),
                  60.width,
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      CustomText(
                        text: "Date of connection",
                        size: 15,
                        isBold: false,
                        colors: colorsConst.textColor,
                      ),
                      CustomText(
                        text: date,
                        size: 15,
                        isBold: true,
                        colors: colorsConst.textColor,
                      ),
                    ],
                  ),
                ],
              ),
              20.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                        style: customStyle.buttonStyle(color: colorsConst.primary, radius: 2),
                        onPressed: emailPressed,
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              "assets/images/white_email.svg",
                              height: 15,
                              width: 15,
                            ),
                            CustomText(
                              text: "Email",
                              isBold: true,
                              colors: colorsConst.textColor,
                            )
                          ],

                        )),
                  ),
                  15.width,
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                        style: customStyle.buttonStyle(color: colorsConst.primary, radius: 2),
                        onPressed: callPressed,
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              "assets/images/white_call.svg",
                              height: 15,
                              width: 15,
                            ),
                            CustomText(
                              text: "Call",
                              isBold: true,
                              colors: colorsConst.textColor,
                            )
                          ],
                        )),
                  ),
                  15.width,
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                        style: customStyle.buttonStyle(color: colorsConst.primary, radius: 2),
                        onPressed: whPressed,
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              "assets/images/whatsapp.svg",
                              height: 15,
                              width: 15,
                            ),
                            CustomText(
                              text: "Whatsapp",
                              isBold: true,
                              colors: colorsConst.textColor,
                            )
                          ],

                        )),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
class LeadContactInformationCard extends StatelessWidget {
  final String userNo;
  final String whNo;
  final String lin;
  final String x;
  final String emailId;
  final String web;

  const LeadContactInformationCard({super.key, required this.userNo, required this.whNo, required this.lin, required this.x, required this.emailId, required this.web});

  @override
  Widget build(BuildContext context) {
    return  SizedBox(
      width: MediaQuery.of(context).size.width*0.4,
      child: Card(
        color: colorsConst.secondary,
        elevation: 0, // shadow height
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5), // rounded edges
        ),
        child: Padding(
          padding:  const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    "assets/images/account_circle.svg",
                    height: 25,
                    width: 40,
                  ),
                  20.width,
                  CustomText(
                    text: "Lead Contact Information",
                    size: 15,
                    isBold: true,
                    colors: colorsConst.textColor,
                  ),
                ],
              ),

              20.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: "Mobile No.",
                        size: 15,
                        isBold: false,
                        colors: colorsConst.textColor,
                      ),
                      CustomText(
                        text: userNo,
                        size: 15,
                        isBold: true,
                        colors: colorsConst.textColor,
                      ),
                      20.height,

                      CustomText(
                        text: "Email ID",
                        size: 15,
                        isBold: false,
                        colors: colorsConst.textColor,
                      ),
                      CustomText(
                        text: emailId,
                        size: 15,
                        isBold: true,
                        colors: colorsConst.textColor,
                      ),
                      20.height,
                      CustomText(
                        text: "X",
                        size: 15,
                        isBold: false,
                        colors: colorsConst.textColor,
                      ),
                      CustomText(
                        text: x,
                        size: 15,
                        isBold: true,
                        colors: colorsConst.textColor,
                      ),
                    ],
                  ),
                  60.width,
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      CustomText(
                        text: "Whatsapp No.",
                        size: 15,
                        isBold: false,
                        colors: colorsConst.textColor,
                      ),
                      CustomText(
                        text: whNo,
                        size: 15,
                        isBold: true,
                        colors: colorsConst.textColor,
                      ),
                      20.height,
                      CustomText(
                        text: "Website",
                        size: 15,
                        isBold: false,
                        colors: colorsConst.textColor,
                      ),
                      CustomText(
                        text: web,
                        size: 15,
                        isBold: true,
                        colors: colorsConst.textColor,
                      ),
                      20.height,
                      CustomText(
                        text: "Linkedin",
                        size: 15,
                        isBold: false,
                        colors: colorsConst.textColor,
                      ),
                      CustomText(
                        text: lin,
                        size: 15,
                        isBold: true,
                        colors: colorsConst.textColor,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class CommonInfoCard extends StatelessWidget {
  const CommonInfoCard({super.key, required this.compName, required this.compNo, required this.compEmail, required this.compIn, required this.isText, required this.img, required this.heading, required this.onPressed, required this.comHeading1, required this.comHeading2, required this.comHeading3, required this.comHeading4 });
  final String heading;
  final String comHeading1;
  final String comHeading2;
  final String comHeading3;
  final String comHeading4;
  final String compName;
  final String compNo;
  final String compEmail;
  final String compIn;
  final String img;
  final bool isText;
  final VoidCallback onPressed;



  @override
  Widget build(BuildContext context) {
    return  SizedBox(
      width: MediaQuery.of(context).size.width*0.4,
      child: Card(
        color: colorsConst.secondary,
        elevation: 0, // shadow height
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5), // rounded edges
        ),
        child: Padding(
          padding:  const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    img,
                    height: 25,
                    width: 40,
                  ),
                  20.width,
                  CustomText(
                    text: heading,
                    size: 15,
                    isBold: true,
                    colors: colorsConst.textColor,
                  ),
                  50.width,
                  isText?TextButton(onPressed:isText?onPressed:null, child:Row(
                    children: [
                      SvgPicture.asset(
                        "assets/images/location_on.svg",
                        height: 25,
                        width: 40,
                      ),
                      7.width,
                      CustomText(
                        text: "View Map",
                        size: 15,
                        isBold: true,
                        colors: colorsConst.textColor,
                      ),


                    ],
                  ) )
                      :CustomText(
                    text: "",
                  ),


                ],
              ),

              20.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text:comHeading1 ,
                        size: 15,
                        isBold: false,
                        colors: colorsConst.textColor,
                      ),
                      CustomText(
                        text: compName,
                        size: 15,
                        isBold: true,
                        colors: colorsConst.textColor,
                      ),
                      20.height,
                      CustomText(
                        text: comHeading2 ,
                        size: 15,
                        isBold: false,
                        colors: colorsConst.textColor,
                      ),
                      CustomText(
                        text: compEmail,
                        size: 15,
                        isBold: true,
                        colors: colorsConst.textColor,
                      ),
                    ],
                  ),
                  60.width,
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: comHeading3,
                        size: 15,
                        isBold: false,
                        colors: colorsConst.textColor,
                      ),
                      CustomText(
                        text: compNo,
                        size: 15,
                        isBold: true,
                        colors: colorsConst.textColor,
                      ),
                      20.height,
                      CustomText(
                        text:comHeading4 ,
                        size: 15,
                        isBold: false,
                        colors: colorsConst.textColor,
                      ),
                      CustomText(
                        text: compIn,
                        size: 15,
                        isBold: true,
                        colors: colorsConst.textColor,
                      ),
                    ],
                  ),
                ],
              ),



            ],
          ),
        ),
      ),
    );
  }
}

class StatusCard extends StatelessWidget {
  final String heading;
  const StatusCard({super.key, required this.heading});
  @override
  Widget build(BuildContext context) {
    return  SizedBox(
      width: MediaQuery.of(context).size.width*0.3,
      child: Card(
        color: colorsConst.secondary,
        elevation: 0, // shadow height
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5), // rounded edges
        ),
        child: Padding(
          padding:  const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: "Status",
                size: 15,
                isBold: true,
                colors: colorsConst.textColor,
              ),
              20.height,
              ElevatedButton(
                  style: customStyle.buttonStyle(color: colorsConst.textColor, radius: 25),
                  onPressed:null,
                  child: CustomText(
                    text: heading,
                    isBold: true,
                    colors: colorsConst.headColor,
                  )
              ),
              20.height,

            ],
          ),
        ),
      ),
    );
  }
}

class TimeLineCard extends StatelessWidget {
  final String heading;
  final String heading1;
  const TimeLineCard({super.key, required this.heading, required this.heading1});
  @override
  Widget build(BuildContext context) {
    return  SizedBox(
      width: MediaQuery.of(context).size.width*0.3,
      child: Card(
        color: colorsConst.secondary,
        elevation: 0, // shadow height
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5), // rounded edges
        ),
        child: Padding(
          padding:  const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    "assets/images/search_activity.svg",
                    height: 25,
                    width: 40,
                  ),
                  15.width,
                  CustomText(
                    text: "Activity Timeline",
                    size: 15,
                    isBold: true,
                    colors: colorsConst.textColor,
                  ),
                ],
              ),
              CustomText(
                text: "Lead Created",
                size: 15,
                isBold: false,
                colors: colorsConst.textColor,
              ),
              CustomText(
                text: heading,
                size: 15,
                isBold: true,
                colors: colorsConst.textColor,
              ),
              20.height,
              CustomText(
                text: "Next Follow-up",
                size: 15,
                isBold: false,
                colors: colorsConst.textColor,
              ),

              CustomText(
                text: heading1,
                size: 15,
                isBold: true,
                colors: colorsConst.textColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class CustomerFieldCard extends StatelessWidget {
  final String heading;
  final String heading1;
  const CustomerFieldCard({super.key, required this.heading, required this.heading1});
  @override
  Widget build(BuildContext context) {
    return  SizedBox(
      width: MediaQuery.of(context).size.width*0.3,
      child: Card(
        color: colorsConst.secondary,
        elevation: 0, // shadow height
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5), // rounded edges
        ),
        child: Padding(
          padding:  const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    "assets/images/search_activity.svg",
                    height: 25,
                    width: 40,
                  ),
                  15.width,
                  CustomText(
                    text: "Activity Timeline",
                    size: 15,
                    isBold: true,
                    colors: colorsConst.textColor,
                  ),
                ],
              ),
              CustomText(
                text: "Lead Created",
                size: 15,
                isBold: false,
                colors: colorsConst.textColor,
              ),
              CustomText(
                text: heading,
                size: 15,
                isBold: true,
                colors: colorsConst.textColor,
              ),
              20.height,
              CustomText(
                text: "Next Follow-up",
                size: 15,
                isBold: false,
                colors: colorsConst.textColor,
              ),

              CustomText(
                text: heading1,
                size: 15,
                isBold: true,
                colors: colorsConst.textColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

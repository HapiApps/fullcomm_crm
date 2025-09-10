
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:fullcomm_crm/screens/leads/view_lead.dart';
import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/constant/colors_constant.dart';
import 'package:fullcomm_crm/components/custom_checkbox.dart';
import 'package:fullcomm_crm/components/custom_text.dart';
import 'package:fullcomm_crm/controller/controller.dart';
import 'package:get/get.dart';
import 'package:fullcomm_crm/screens/mail_comments.dart';
import '../services/api_services.dart';

class CustomLeadTile extends StatefulWidget {
  final String? id;
  final String? mainName;
  final String? mainMobile;
  final String? mainEmail;
  final String? mainWhatsApp;
  final String? companyName;
  final String? status;
  final String? rating;
  final String? emailUpdate;
  final String? name;
  final String? title;
  final String? mobileNumber;
  final String? whatsappNumber;
  final String? email;
  final String? mainTitle;
  final String? addressId;
  final String? companyWebsite;
  final String? companyNumber;
  final String? companyEmail;
  final String? industry;
  final String? productServices;
  final String? source;
  final String? owner;
  final String? budget;
  final String? timelineDecision;
  final String? serviceInterest;
  final String? description;
  final String? leadStatus;
  final String? active;
  final String? addressLine1;
  final String? addressLine2;
  final String? area;
  final String? city;
  final String? state;
  final String? country;
  final String? pinCode;
  final String? linkedin;
  final String? x;
  final int? index;
  final String? quotationStatus;
  final String? productDiscussion;
  final String? discussionPoint;
  final String? notes;
  final String? quotationRequired;
  final String? arpuValue;
  final String? sourceDetails;
  final String? prospectEnrollmentDate;
  final String? expectedConvertionDate;
  final String? statusUpdate;
  final String? numOfHeadcount;
  final String? expectedBillingValue;
  final String? visitType;
  final String? points;
  final String? detailsOfServiceReq;
  final String updatedTs;
  final void Function(bool?) onChanged;
  final bool saveValue;


  const CustomLeadTile({super.key,
    this.id,
    this.mainName,
    this.mainMobile,
    this.mainEmail,
    this.mainWhatsApp,
    this.companyName,
    this.status,
    this.rating,
    this.emailUpdate,
    this.name,
    this.title,
    this.mobileNumber,
    this.whatsappNumber,
    this.email,
    this.mainTitle,
    this.addressId,
    this.companyWebsite,
    this.companyNumber,
    this.companyEmail,
    this.industry,
    this.productServices,
    this.source,
    this.owner,
    this.budget,
    this.timelineDecision,
    this.serviceInterest,
    this.description,
    this.leadStatus,
    this.active,
    this.addressLine1,
    this.addressLine2,
    this.area,
    this.city,
    this.state,
    this.country,
    this.pinCode,
    this.quotationStatus,
    this.productDiscussion,
    this.discussionPoint,
    this.notes,
    this.index,this.linkedin,this.x,this.quotationRequired,
    this.arpuValue,
    this.expectedBillingValue,
    this.expectedConvertionDate,
    this.numOfHeadcount,
    this.prospectEnrollmentDate,
    this.sourceDetails,
    this.statusUpdate,
    required this.onChanged,
    required this.saveValue,
    required this.updatedTs, this.visitType, this.points,this.detailsOfServiceReq
  });

  @override
  State<CustomLeadTile> createState() => _CustomLeadTileState();
}

class _CustomLeadTileState extends State<CustomLeadTile> {
  String formatDate(String inputDate) {
    try {
      DateTime parsedDate = DateFormat("dd.MM.yyyy").parse(inputDate);
      return DateFormat("dd MMM yyyy").format(parsedDate);
    } catch (e) {
      return inputDate;
    }
  }
  late TextEditingController statusController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    statusController = TextEditingController(text: widget.statusUpdate.toString()=="null"?"":widget.statusUpdate.toString());
  }
  @override
  void didUpdateWidget(covariant CustomLeadTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.statusUpdate != widget.statusUpdate) {
      statusController.text = widget.statusUpdate.toString()=="null"?"":widget.statusUpdate.toString();
    }
  }


  @override
  void dispose() {
    statusController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context){
    return InkWell(
      onTap:(){
        Get.to(ViewLead(
          id:widget.id,
          linkedin: "",
          x: "",
          mainName:widget.mainName,
          mainMobile:widget.mainMobile,
          mainEmail:widget.mainEmail,
          mainWhatsApp: widget.mainWhatsApp,
          companyName:widget.companyName,
          status:widget.status,
          rating:widget.rating,
          emailUpdate:widget.emailUpdate,
          name:widget.name,
          title:"",
          mobileNumber:widget.mobileNumber,
          whatsappNumber:widget.whatsappNumber,
          email:widget.email,
          mainTitle:"",
          addressId:widget.addressId,
          companyWebsite:"",
          companyNumber:"",
          companyEmail:"",
          industry:"",
          productServices:"",
          source:"",
          owner:"",
          budget:"",
          timelineDecision:"",
          serviceInterest:"",
          description:"",
          leadStatus:widget.leadStatus,
          active:widget.active,
          addressLine1:widget.addressLine1,
          addressLine2:widget.addressLine2,
          area:widget.area,
          city:widget.city,
          state:widget.state,
          country:widget.country,
          pinCode:widget.pinCode,
          quotationStatus:widget.quotationStatus,
          productDiscussion:widget.productDiscussion,
          discussionPoint:widget.discussionPoint,
          notes:widget.notes.toString(),
          prospectEnrollmentDate: widget.prospectEnrollmentDate ?? "",
          expectedConvertionDate: widget.expectedConvertionDate ?? "",
          numOfHeadcount: widget.numOfHeadcount ?? "",
          expectedBillingValue: widget.expectedBillingValue ?? "",
          arpuValue: widget.arpuValue ?? "",
          updateTs: widget.updatedTs,
          sourceDetails: widget.sourceDetails.toString(),
        ),duration: Duration.zero
        );
      },
      child: Table(
        columnWidths:const {
          0: FlexColumnWidth(1),//check box
          1: FlexColumnWidth(3),//mail
          2: FlexColumnWidth(2),//N
          3: FlexColumnWidth(2.5),//CN
          4: FlexColumnWidth(2),//MN
          5: FlexColumnWidth(3),//Details of Service Required
          6: FlexColumnWidth(2),//Source of Prospect
          7: FlexColumnWidth(2),// Added DateTime
          8: FlexColumnWidth(2),// City
          9: FlexColumnWidth(3),// Status Update
        },
        border: TableBorder(
          horizontalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
          verticalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
          bottom:  BorderSide(width: 0.5, color: Colors.grey.shade400),
        ),
        children:[
          TableRow(
              decoration: BoxDecoration(
                color: int.parse(widget.index.toString()) % 2 == 0 ? Colors.white : colorsConst.backgroundColor,
              ),
              children:[
                    Container(
                      height: 45,
                      alignment: Alignment.center,
                      child: CustomCheckBox(
                          text: "",
                          onChanged: widget.onChanged,
                          saveValue: widget.saveValue),
                    ),

                Container(
                  height: 45,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                          onTap: (){},
                          child: SvgPicture.asset("assets/images/a_edit.svg",width: 16,height: 16,)),
                      InkWell(
                          onTap: (){},
                          child: SvgPicture.asset("assets/images/a_delete.svg",width: 16,height: 16,)),
                      InkWell(
                        onTap: (){
                          controllers.customMailFuture = apiService.mailCommentDetails(widget.id.toString());
                          Get.to(MailComments(
                            mainEmail: widget.mainEmail,
                            mainMobile: widget.mainMobile,
                            mainName: widget.mainName,
                            city: widget.city,
                            id: widget.id,
                            companyName: widget.companyName,
                          ));
                        },
                        child: SvgPicture.asset("assets/images/a_email.svg",width: 16,height: 16,),
                      ),
                      InkWell(
                          onTap: (){},
                          child: SvgPicture.asset("assets/images/a_qualified.svg",width: 16,height: 16,)),
                      InkWell(
                          onTap: (){},
                          child: SvgPicture.asset("assets/images/a_disqualified.svg",width: 16,height: 16,)),
                    ],
                  ),
                ),
                // SingleChildScrollView(
                //   scrollDirection: Axis.horizontal,
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children:[
                //       70.height,
                //       InkWell(
                //         onTap: (){
                //           controllers.customMailFuture = apiService.mailCommentDetails(widget.id.toString());
                //           Get.to(MailComments(
                //               mainEmail: widget.mainEmail,
                //               mainMobile: widget.mainMobile,
                //               mainName: widget.mainName,
                //               city: widget.city,
                //               id: widget.id,
                //               companyName: widget.companyName,
                //           ));
                //           // Get.to(Quotations(
                //           //   mainEmail: widget.mainEmail,
                //           //   mainMobile: widget.mainMobile,
                //           //   mainName: widget.mainName,
                //           //   city: widget.city,
                //           //   id: widget.id,
                //           //   companyName: widget.companyName,
                //           // ));
                //         },
                //         child: Row(
                //           children: [
                //             CircleAvatar(
                //               backgroundColor: const Color(0xffAFC8D9),
                //               radius: 13,
                //               child: Icon(Icons.call,
                //                 color: colorsConst.primary,
                //                 size: 15,),
                //
                //             ),
                //             4.width,
                //             Container(
                //               height: 30,
                //               width: 130,
                //               padding: const EdgeInsets.only(
                //                 left:10,
                //                 right: 10
                //               ),
                //               alignment: Alignment.center,
                //               decoration: BoxDecoration(
                //                   color:const Color(0xffAFC8D9),
                //                   borderRadius: BorderRadius.circular(15)
                //               ),
                //               child: Tooltip(
                //                 message:  widget.emailUpdate.toString().isEmpty||widget.emailUpdate=="null"?
                //                 "No Code Sent":widget.emailUpdate.toString(),
                //                 child: Text(
                //                     widget.emailUpdate.toString().isEmpty||widget.emailUpdate=="null"?
                //                     "No Code Sent":widget.emailUpdate.toString(),
                //                   overflow: TextOverflow.ellipsis,
                //                   maxLines: 1,
                //                   textAlign: TextAlign.center,
                //                   style: TextStyle(
                //                     color: colorsConst.primary,
                //                     fontSize: 12,
                //                     fontWeight:FontWeight.bold,
                //                     fontFamily:"Lato",
                //                   ),
                //                 ),
                //                 //child: Text(widget.updatedTs.toString()),
                //               ),
                //             )
                //           ],
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                Container(
                  height: 45,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 5,right: 5),
                  child: CustomText(
                    textAlign: TextAlign.left,
                    text: widget.mainName.toString()=="null"?"":widget.mainName.toString(),
                    size: 14,
                    colors: colorsConst.textColor,
                  ),
                ),
                Tooltip(
                  message: widget.companyName.toString()=="null"?"":widget.companyName.toString(),
                  child: Container(
                    height: 45,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 5,right: 5),
                    child: CustomText(
                      textAlign: TextAlign.left,
                      text: widget.companyName.toString()=="null"?"":widget.companyName.toString(),
                      size: 14,
                      colors:colorsConst.textColor,
                    ),
                  ),
                ),
                Container(
                  height: 45,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 5,right: 5),
                  child: CustomText(
                    textAlign: TextAlign.left,
                    text:widget.mainMobile.toString()=="null"?"":widget.mainMobile.toString(),
                    size: 14,
                    colors: colorsConst.textColor,
                  ),
                ),
                Tooltip(
                  message: widget.detailsOfServiceReq.toString()=="null"?"":widget.detailsOfServiceReq.toString(),
                  child: Container(
                    height: 45,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 5,right: 5),
                    child: CustomText(
                      textAlign: TextAlign.left,
                      text: widget.detailsOfServiceReq.toString(),
                      size: 14,
                      colors:colorsConst.textColor,
                    ),
                  ),
                ),
                Tooltip(
                  message: widget.source.toString()=="null"?"":widget.source.toString(),
                  child: Container(
                    height: 45,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 5,right: 5),
                    child: CustomText(
                      textAlign: TextAlign.left,
                      text: widget.source.toString(),
                      size: 14,
                      colors:colorsConst.textColor,
                    ),
                  ),
                ),
                Container(
                  height: 45,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 5,right: 5),
                  child: CustomText(
                    textAlign: TextAlign.left,
                    text: formatDate(widget.prospectEnrollmentDate.toString().isEmpty||widget.prospectEnrollmentDate.toString()=="null"?widget.updatedTs.toString():widget.prospectEnrollmentDate.toString()),
                    size: 14,
                    colors:colorsConst.textColor,
                  ),
                ),
                Tooltip(
                  message: widget.city.toString(),
                  child: Container(
                    height: 45,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 5,right: 5),
                    child: CustomText(
                      textAlign: TextAlign.left,
                      text: widget.city.toString()=="null"?"":widget.city.toString(),
                      size: 14,
                      colors:colorsConst.textColor,
                    ),
                  ),
                ),
                Tooltip(
                  message: widget.statusUpdate.toString()=="null"?"":widget.statusUpdate.toString(),
                  child: Container(
                    height: 45,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 6,right: 5,bottom: 5),
                    child: TextField(
                      controller: statusController,
                      textAlign: TextAlign.left,
                      cursorColor: colorsConst.textColor,
                      style: TextStyle(
                        color: colorsConst.textColor,
                        fontSize: 14,
                        fontFamily: "Lato",
                        fontWeight: FontWeight.normal,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      onSubmitted: (value) async {
                        apiService.updateLeadStatusUpdateAPI(
                          context,
                          widget.id.toString(),
                          widget.mainMobile.toString(),
                          value,
                        );
                      },
                    ),
                  ),
                ),
              ]
          ),

        ],
      ),
    );
  }
}

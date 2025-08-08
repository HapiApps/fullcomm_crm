
import 'package:intl/intl.dart';
import 'package:fullcomm_crm/screens/leads/view_lead.dart';
import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/constant/colors_constant.dart';
import 'package:fullcomm_crm/common/extentions/lib_extensions.dart';
import 'package:fullcomm_crm/components/custom_checkbox.dart';
import 'package:fullcomm_crm/components/custom_text.dart';
import 'package:fullcomm_crm/controller/controller.dart';
import 'package:get/get.dart';
import '../common/constant/api.dart';
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
  String updatedTs;


   CustomLeadTile({super.key,
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
     required this.updatedTs, this.visitType, this.points,this.detailsOfServiceReq
  });

  @override
  State<CustomLeadTile> createState() => _CustomLeadTileState();
}

class _CustomLeadTileState extends State<CustomLeadTile> {
  String formatDateTime(String inputDateTime) {
    DateTime dateTime;
    try {
      dateTime = DateFormat('yyyy-MM-dd HH:mm:ss').parseStrict(inputDateTime);
    } catch (_) {
      try {
        dateTime = DateFormat('dd.MM.yyyy').parseStrict(inputDateTime);
      } catch (_) {
        return 'Invalid date';
      }
    }

    bool hasTime = inputDateTime.contains(':');
    final outputFormat = hasTime
        ? DateFormat('yyyy-MM-dd hh:mm a')
        : DateFormat('yyyy-MM-dd');
    return outputFormat.format(dateTime);
  }
  @override
  Widget build(BuildContext context){
    return Column(
      children:[
        5.height,
        InkWell(
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
              1: FlexColumnWidth(2),//N
              2: FlexColumnWidth(2.5),//CN
              3: FlexColumnWidth(2),//MN
              4: FlexColumnWidth(3),//Details of Service Required
              5: FlexColumnWidth(2),//Source of Prospect
              6: FlexColumnWidth(2),// Added DateTime
              7: FlexColumnWidth(1.5),// Added DateTime
              8: FlexColumnWidth(3),
              // 9: FlexColumnWidth(3),
              // 10: FlexColumnWidth(3),
            },
            children:[
              TableRow(
                  decoration: BoxDecoration(
                    color: colorsConst.secondary,
                  ),
                  children:[
                    Row(
                      children: [
                        5.width,
                        Container(
                          height: 70,
                          alignment: Alignment.center,
                          child: Obx(() =>  CustomCheckBox(
                              text: "",
                              onChanged: (value){
                                setState(() {
                                  if(controllers.isNewLeadList[widget.index!]["isSelect"]==true){
                                    controllers.isNewLeadList[widget.index!]["isSelect"]=false;
                                    var i=apiService.prospectsList.indexWhere((element) => element["lead_id"]==widget.id.toString());
                                    apiService.prospectsList.removeAt(i);
                                  }else{
                                    controllers.isNewLeadList[widget.index!]["isSelect"]=true;
                                    apiService.prospectsList.add({
                                      "lead_id":widget.id.toString(),
                                      "user_id":controllers.storage.read("id"),
                                      "rating":widget.rating.toString(),
                                      "cos_id":cosId,
                                    });
                                  }
                                  print(apiService.prospectsList);
                                });
                              },
                              saveValue: controllers.isNewLeadList[widget.index!]["isSelect"]),
                          ),
                        ),
                      ],
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
                    Padding(
                      padding: const EdgeInsets.only(top: 25),
                      child: CustomText(
                        textAlign: TextAlign.center,
                        text: widget.mainName.toString()=="null"?"":widget.mainName.toString(),
                        size: 14,
                        colors: colorsConst.textColor,
                      ),
                    ),
                    Tooltip(
                      message: widget.companyName.toString()=="null"?"":widget.companyName.toString(),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 25),
                        child: CustomText(
                          textAlign: TextAlign.center,
                          text: widget.companyName.toString()=="null"?"":widget.companyName.toString(),
                          size: 14,
                          colors:colorsConst.textColor,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 25),
                      child: CustomText(
                        textAlign: TextAlign.center,
                        text:widget.mainMobile.toString()=="null"?"":widget.mainMobile.toString(),
                        size: 14,
                        colors: colorsConst.textColor,
                      ),
                    ),
                    Tooltip(
                      message: widget.detailsOfServiceReq.toString(),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 25),
                        child: CustomText(
                          textAlign: TextAlign.center,
                          text: widget.detailsOfServiceReq.toString(),
                          size: 14,
                          colors:colorsConst.textColor,
                        ),
                      ),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.only(top: 25),
                    //   child: CustomText(
                    //     textAlign: TextAlign.center,
                    //     text:widget.mainEmail.toString()=="null"?"":widget.mainEmail.toString(),
                    //     size: 14,
                    //     colors:colorsConst.textColor,
                    //   ),
                    // ),


                    // Padding(
                    //   padding: const EdgeInsets.only(top: 25),
                    //   child: CustomText(
                    //     textAlign: TextAlign.center,
                    //     text:widget.status.toString(),
                    //     size: 14,
                    //     colors: colorsConst.textColor,
                    //   ),
                    // ),

                    // Padding(
                    //   padding: const EdgeInsets.only(top: 25),
                    //   child: CustomText(
                    //     textAlign: TextAlign.center,
                    //     text: widget.visitType.toString(),
                    //     size: 14,
                    //     colors:colorsConst.textColor,
                    //   ),
                    // ),

                    Tooltip(
                      message: widget.source.toString(),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 25),
                        child: CustomText(
                          textAlign: TextAlign.center,
                          text: widget.source.toString(),
                          size: 14,
                          colors:colorsConst.textColor,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 25,right: 5),
                      child: CustomText(
                        textAlign: TextAlign.center,
                        text: controllers.formatDateTime(widget.prospectEnrollmentDate.toString().isEmpty||widget.prospectEnrollmentDate.toString()=="null"?widget.updatedTs.toString():widget.prospectEnrollmentDate.toString()),
                        size: 14,
                        colors:colorsConst.textColor,
                      ),
                    ),
                    Tooltip(
                      message: widget.city.toString(),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 25),
                        child: CustomText(
                          textAlign: TextAlign.center,
                          text: widget.city.toString()=="null"?"":widget.city.toString(),
                          size: 14,
                          colors:colorsConst.textColor,
                        ),
                      ),
                    ),
                    Tooltip(
                      message: widget.statusUpdate.toString(),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 25),
                        child: CustomText(
                          textAlign: TextAlign.center,
                          text: widget.statusUpdate.toString(),
                          size: 14,
                          colors:colorsConst.textColor,
                        ),
                      ),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.only(top: 25),
                    //   child: Center(
                    //     child: Container(
                    //       width: 65,
                    //       height: 20,
                    //       decoration: BoxDecoration(
                    //           color: widget.rating.toString().toLowerCase() == "cold"
                    //               ? const Color(0xffACF3E4)
                    //               : widget.rating.toString().toLowerCase() == "warm"
                    //               ? const Color(0xffCFE9FE)
                    //               : const Color(0xffFEDED8),
                    //           borderRadius: BorderRadius.circular(10),
                    //           border: Border.all(
                    //               color:widget.rating.toString().toLowerCase() == "cold"?const Color(0xff06A59A):widget.rating.toString().toLowerCase() == "warm"?const Color(0xff0D9DDA):const Color(0xffFE5C4C)
                    //           )
                    //       ),
                    //       alignment: Alignment.center,
                    //       child: CustomText(
                    //         text:widget.rating.toString(),
                    //         colors:widget.rating.toString().toLowerCase() == "cold"?const Color(0xff06A59A):widget.rating.toString().toLowerCase() == "warm"?const Color(0xff0D9DDA):const Color(0xffFE5C4C),
                    //         size: 12,
                    //         isBold: true,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // Padding(
                    //   padding: const EdgeInsets.only(top: 25,right: 5),
                    //   child: CustomText(
                    //     textAlign: TextAlign.center,
                    //     text: widget.prospectEnrollmentDate.toString(),
                    //     size: 14,
                    //     colors:colorsConst.textColor,
                    //   ),
                    // ),
                    // Padding(
                    //   padding: const EdgeInsets.only(top: 25,right: 5),
                    //   child: CustomText(
                    //     textAlign: TextAlign.center,
                    //     text: widget.expectedConvertionDate.toString(),
                    //     size: 14,
                    //     colors:colorsConst.textColor,
                    //   ),
                    // ),
                  ]
              ),

            ],
          ),
        ),
      ],
    );
  }
}

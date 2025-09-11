
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:intl/intl.dart';
import 'package:fullcomm_crm/screens/leads/view_lead.dart';
import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/constant/colors_constant.dart';
import 'package:fullcomm_crm/components/custom_checkbox.dart';
import 'package:fullcomm_crm/components/custom_text.dart';
import 'package:fullcomm_crm/controller/controller.dart';
import 'package:get/get.dart';
import 'package:fullcomm_crm/screens/mail_comments.dart';
import '../common/constant/api.dart';
import '../screens/leads/update_lead.dart';
import '../services/api_services.dart';
import 'custom_loading_button.dart';

class CustomLeadTile extends StatefulWidget {
  final bool showCheckbox;
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
    this.showCheckbox = true,
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
        columnWidths: widget.showCheckbox?{
          0: FlexColumnWidth(1),
          1: const FlexColumnWidth(3),
          2: const FlexColumnWidth(2),
          3: const FlexColumnWidth(2.5),
          4: const FlexColumnWidth(2),
          5: const FlexColumnWidth(3),
          6: const FlexColumnWidth(2),
          7: const FlexColumnWidth(2),
          8: const FlexColumnWidth(2),
          9: const FlexColumnWidth(3),
        }:{
          0: const FlexColumnWidth(3),
          1: const FlexColumnWidth(2),
          2: const FlexColumnWidth(2.5),
          3: const FlexColumnWidth(2),
          4: const FlexColumnWidth(3),
          5: const FlexColumnWidth(2),
          6: const FlexColumnWidth(2),
          7: const FlexColumnWidth(2),
          8: const FlexColumnWidth(3),
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
                if (widget.showCheckbox)
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
                          onTap: (){
                            Get.to( UpdateLead(
                              id:widget.id,
                              detailsOfRequired: "",
                              linkedin: "",
                              x: "",
                              mainName:widget.mainName,
                              mainMobile:widget.mobileNumber,
                              mainEmail:widget.email,
                              mainWhatsApp: widget.mobileNumber,
                              companyName:widget.companyName,
                              status:widget.status,
                              rating:widget.rating,
                              emailUpdate:widget.quotationRequired,
                              name:widget.mainName,
                              title:"",
                              mobileNumber:widget.mobileNumber,
                              whatsappNumber:widget.mobileNumber,
                              email:widget.email,
                              mainTitle:"",
                              addressId:widget.addressId,
                              companyWebsite:"",
                              companyNumber:"",
                              companyEmail:"",
                              industry:"",
                              productServices:"",
                              source:widget.source,
                              owner:widget.owner,
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
                              statusUpdate: widget.statusUpdate,
                              prospectEnrollmentDate: widget.prospectEnrollmentDate ?? "",
                              expectedConvertionDate: widget.expectedConvertionDate ?? "",
                              numOfHeadcount: widget.numOfHeadcount ?? "",
                              expectedBillingValue: widget.expectedBillingValue ?? "",
                              arpuValue: widget.arpuValue ?? "",
                              updateTs: widget.updatedTs.toString(),
                              sourceDetails: widget.sourceDetails.toString(),));
                          },
                          child: SvgPicture.asset("assets/images/a_edit.svg",width: 16,height: 16,)),
                      InkWell(
                          onTap: (){
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) {
                                  return AlertDialog(
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
                                            callback: ()async{
                                              final deleteData = {
                                                "lead_id": widget.id.toString(),
                                                "user_id": controllers.storage.read("id").toString(),
                                                "rating": (widget.rating ?? "Warm").toString(),
                                                "cos_id": cosId.toString(),
                                                "mail_id": widget.mainEmail.toString(),
                                              };

                                              await apiService.deleteCustomersAPI(context, [deleteData]);

                                            },
                                            height: 35,
                                            isLoading: true,
                                            backgroundColor: colorsConst.primary,
                                            radius: 2,
                                            width: 80,
                                            controller: controllers.productCtr,
                                            isImage: false,
                                            text: "Delete",
                                            textColor: Colors.white,
                                          ),
                                          5.width
                                        ],
                                      ),
                                    ],
                                  );
                                });
                          },
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
                          onTap: (){
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
                                            callback: ()async{
                                              final deleteData = {
                                                "lead_id": widget.id.toString(),
                                                "user_id": controllers.storage.read("id").toString(),
                                                "rating": (widget.rating ?? "Warm").toString(),
                                                "cos_id": cosId.toString(),
                                                "mail_id": widget.mainEmail.toString(),
                                              };
                                              await apiService.insertProspectsAPI(context, [deleteData]);

                                            },
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
                          },
                          child: SvgPicture.asset("assets/images/a_qualified.svg",width: 16,height: 16,)),
                      InkWell(
                          onTap: (){
                            showDialog(
                                context: context,
                                barrierDismissible: true,
                                builder: (context) {
                                  return AlertDialog(
                                    content: CustomText(
                                      text: "Are you sure disqualify this customers?",
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
                                            callback: (){
                                              final deleteData = {
                                                "lead_id": widget.id.toString(),
                                                "user_id": controllers.storage.read("id").toString(),
                                                "rating": (widget.rating ?? "Warm").toString(),
                                                "cos_id": cosId.toString(),
                                                "mail_id": widget.mainEmail.toString(),
                                              };
                                              apiService.disqualifiedCustomersAPI(context, [deleteData]);
                                            },
                                            height: 35,
                                            isLoading: true,
                                            backgroundColor:
                                            colorsConst.primary,
                                            radius: 2,
                                            width: 100,
                                            controller: controllers.productCtr,
                                            isImage: false,
                                            text: "Disqualified",
                                            textColor:Colors.white,
                                          ),
                                          5.width
                                        ],
                                      ),
                                    ],
                                  );
                                });
                          },
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

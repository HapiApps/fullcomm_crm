import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:fullcomm_crm/models/new_lead_obj.dart';
import 'package:fullcomm_crm/screens/leads/suspects.dart';
import 'package:fullcomm_crm/screens/leads/update_lead.dart';
import 'package:fullcomm_crm/services/api_services.dart';
import '../../common/constant/colors_constant.dart';
import '../../common/utilities/utils.dart';
import '../../components/custom_loading_button.dart';
import '../../components/custom_text.dart';
import '../../controller/controller.dart';
import '../../controller/image_controller.dart';

class ViewLead extends StatefulWidget {
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
  final String? quotationStatus;
  final String? productDiscussion;
  final String? discussionPoint;
  String notes;
  final String? quotationRequired;
  final String? arpuValue;
  String sourceDetails;
  final String? prospectEnrollmentDate;
  final String? expectedConvertionDate;
  final String? statusUpdate;
  final String? numOfHeadcount;
  final String? expectedBillingValue;
  String updateTs;
  ViewLead(
      {super.key,
        this.id,
        this.mainName,
        this.mainMobile,
        this.mainEmail,
        this.companyName,
        this.status,
        this.rating,
        this.mainWhatsApp,
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
        this.x,
        this.linkedin,
        this.quotationStatus,
        this.productDiscussion,
        this.discussionPoint,
        required this.notes,
        this.quotationRequired,
        this.arpuValue,
        this.expectedBillingValue,
        this.expectedConvertionDate,
        this.numOfHeadcount,
        this.prospectEnrollmentDate,
        required this.sourceDetails,
        this.statusUpdate,
        required this.updateTs});

  @override
  State<ViewLead> createState() => _ViewLeadState();
}

class _ViewLeadState extends State<ViewLead> {
  String formatDateTime(String inputDateTime) {
    final inputFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    final outputFormat = DateFormat('yyyy-MM-dd hh:mm a');

    final dateTime = inputFormat.parse(inputDateTime);
    return outputFormat.format(dateTime);
  }

  String formatDate(String inputDate) {
    final formats = [
      DateFormat('d/M/yyyy'),
      DateFormat('d/M/yy'),
      DateFormat('dd-MM-yyyy'),
      DateFormat('yyyy-MM-dd'),
      DateFormat('MM/dd/yyyy'),
      DateFormat('yyyy/MM/dd'),
    ];

    // Step 1: First, try DateTime.parse for ISO strings
    try {
      final dateTime = DateTime.parse(inputDate);
      return DateFormat('yyyy-MM-dd').format(dateTime);
    } catch (e) {
      // Not ISO format, try manual formats
    }

    // Step 2: Try custom formats
    for (var format in formats) {
      try {
        final dateTime = format.parseStrict(inputDate);
        return DateFormat('yyyy-MM-dd').format(dateTime);
      } catch (e) {
        // Parsing failed, try next
      }
    }

    // Step 3: If nothing works, return empty
    return "";
  }

  late FocusNode _focusNode;
  late ScrollController _controller;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = ScrollController();
    _focusNode = FocusNode();
    _focusNode.requestFocus();
    Future.delayed(Duration.zero, () {
      controllers.leadFuture = apiService.leadsDetails(widget.id.toString());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var count = 200 * widget.name.toString().split("||").length;
    double screenWidth = MediaQuery.of(context).size.width;
    return SelectionArea(
      child: Scaffold(
        backgroundColor: colorsConst.primary,
        body: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            utils.sideBarFunction(context),
            Container(
              width: screenWidth - 490,
              height: MediaQuery.of(context).size.height,
              alignment: Alignment.center,
              child: Obx(() => controllers.isLeadLoading.value
                  ? const CircularProgressIndicator()
                  : FutureBuilder<List<NewLeadObj>>(
                future: controllers.leadFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return RawKeyboardListener(
                      focusNode: _focusNode,
                      autofocus: true,
                      onKey: (event) {
                        if (event is RawKeyDownEvent) {
                          if (event.logicalKey ==
                              LogicalKeyboardKey.arrowDown) {
                            _controller.animateTo(
                              _controller.offset + 100,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                            );
                          } else if (event.logicalKey ==
                              LogicalKeyboardKey.arrowUp) {
                            _controller.animateTo(
                              _controller.offset - 100,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                            );
                          }
                        }
                      },
                      child: ListView.builder(
                          itemCount: snapshot.data?.length,
                          controller: _controller,
                          itemBuilder: (context, index) {
                            final leadData = snapshot.data![index];
                            return Column(
                              children: [
                                20.height,
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomText(
                                      text: "View Lead",
                                      colors: colorsConst.textColor,
                                      size: 20,
                                      isBold: true,
                                    ),
                                    // SizedBox(
                                    //   width: 200,
                                    //   child: Row(
                                    //     children: [
                                    //       TextButton(
                                    //           onPressed: (){
                                    //             //Get.to(const Suspects(),duration: Duration.zero);
                                    //             Get.to( UpdateLead(
                                    //               id:widget.id,
                                    //               linkedin: "",
                                    //               x: "",
                                    //               mainName:leadData.firstname,
                                    //               mainMobile:leadData.mobileNumber,
                                    //               mainEmail:leadData.emailId,
                                    //               mainWhatsApp: leadData.mobileNumber,
                                    //               companyName:leadData.companyName,
                                    //               status:leadData.status,
                                    //               rating:leadData.rating,
                                    //               emailUpdate:leadData.quotationRequired,
                                    //               name:leadData.firstname,
                                    //               title:"",
                                    //               mobileNumber:leadData.mobileNumber,
                                    //               whatsappNumber:leadData.mobileNumber,
                                    //               email:leadData.emailId,
                                    //               mainTitle:"",
                                    //               addressId:leadData.addressId,
                                    //               companyWebsite:"",
                                    //               companyNumber:"",
                                    //               companyEmail:"",
                                    //               industry:"",
                                    //               productServices:"",
                                    //               source:"",
                                    //               owner:"",
                                    //               budget:"",
                                    //               timelineDecision:"",
                                    //               serviceInterest:"",
                                    //               description:"",
                                    //               leadStatus:leadData.leadStatus,
                                    //               active:leadData.active,
                                    //               addressLine1:leadData.doorNo,
                                    //               addressLine2:leadData.landmark1,
                                    //               area:leadData.area,
                                    //               city:leadData.city,
                                    //               state:leadData.state,
                                    //               country:leadData.country,
                                    //               pinCode:leadData.pincode,
                                    //               quotationStatus:leadData.quotationStatus,
                                    //               productDiscussion:leadData.productDiscussion,
                                    //               discussionPoint:leadData.discussionPoint,
                                    //               notes:leadData.notes.toString(),
                                    //               prospectEnrollmentDate: leadData.prospectEnrollmentDate ?? "",
                                    //               expectedConvertionDate: leadData.expectedConvertionDate ?? "",
                                    //               numOfHeadcount: leadData.numOfHeadcount ?? "",
                                    //               expectedBillingValue: leadData.expectedBillingValue ?? "",
                                    //               arpuValue: leadData.arpuValue ?? "",
                                    //               updateTs: leadData.updatedTs.toString(),
                                    //               sourceDetails: leadData.sourceDetails.toString(),));
                                    //             print("address id ${leadData.addressId}");
                                    //           }, child: CustomText(text: "Edit",colors: colorsConst.headColor,)),
                                    //       CustomLoadingButton(
                                    //         callback:(){
                                    //           // controllers.mailReceivesList.value=[];
                                    //           // apiService.mailReceiveDetails(widget.id.toString());
                                    //           controllers.emailSubjectCtr.clear();
                                    //           controllers.emailMessageCtr.clear();
                                    //           imageController.photo1.value="";
                                    //           controllers.emailToCtr.text=widget.email.toString()=="null"?"":widget.email.toString();
                                    //           utils.sendEmailDialog(id: widget.id.toString(), name: widget.name.toString(),
                                    //               mobile: widget.mobileNumber.toString(), coName: widget.companyName.toString());
                                    //         },
                                    //         height: 35,
                                    //         isLoading: false,
                                    //         backgroundColor: colorsConst.third,
                                    //         radius: 2,
                                    //         width: 120,
                                    //         isImage: false,
                                    //         text: "Send Email",
                                    //         textColor: Colors.black,
                                    //       ),
                                    //     ],
                                    //   ),
                                    // ),
                                  ],
                                ),
                                10.height,
                                // Row(
                                //   mainAxisAlignment: MainAxisAlignment.end,
                                //   children:[
                                //     TextButton(
                                //         onPressed: (){
                                //           Get.to(UpdateLead(
                                //               id:widget.id,
                                //               linkedin: widget.linkedin,
                                //               x: widget.x,
                                //               mainName:widget.mainName,
                                //               mainMobile:widget.mainMobile,
                                //               mainEmail:widget.mainEmail,
                                //               mainWhatsApp: widget.mainWhatsApp,
                                //               companyName:widget.companyName,
                                //               status:widget.status,
                                //               rating:widget.rating,
                                //               emailUpdate:widget.emailUpdate,
                                //               name:widget.name,
                                //               title:widget.title,
                                //               mobileNumber:widget.mobileNumber,
                                //               whatsappNumber:widget.whatsappNumber,
                                //               email:widget.email,
                                //               mainTitle:widget.mainTitle,
                                //               addressId:widget.addressId,
                                //               companyWebsite:widget.companyWebsite,
                                //               companyNumber:widget.companyNumber,
                                //               companyEmail:widget.companyEmail,
                                //               industry:widget.industry,
                                //               productServices:widget.productServices,
                                //               source:widget.source,
                                //               owner:widget.owner,
                                //               budget:widget.budget,
                                //               timelineDecision:widget.timelineDecision,
                                //               serviceInterest:widget.serviceInterest,
                                //               description:widget.description,
                                //               leadStatus:widget.leadStatus,
                                //               active:widget.active,
                                //               addressLine1:widget.addressLine1,
                                //               addressLine2:widget.addressLine2,
                                //               area:widget.area,
                                //               city:widget.city,
                                //               state:widget.state,
                                //               country:widget.country,
                                //               pinCode:widget.pinCode
                                //           ),
                                //               duration: Duration.zero);
                                //         },
                                //         child: CustomText(
                                //           text: "Edit",
                                //           colors: colorsConst.textColor,
                                //           size: 12,
                                //         )
                                //     )
                                //   ],
                                // ),
                                Divider(
                                  color: colorsConst.textColor,
                                  thickness: 1,
                                ),
                                20.height,
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.end,
                                  children: [
                                    CustomText(
                                      text:
                                      "Added DateTime : ${formatDateTime(leadData.updatedTs.toString())}        ",
                                      colors: colorsConst.textColor,
                                      size: 12,
                                    )
                                  ],
                                ),
                                Container(
                                  height: 190,
                                  decoration: BoxDecoration(
                                      color: colorsConst.secondary,
                                      borderRadius:
                                      BorderRadius.circular(10)),
                                  child: Column(
                                    children: [
                                      15.height,
                                      Row(
                                        children: [
                                          20.width,
                                          SizedBox(
                                            width: screenWidth / 2.7,
                                            child: Row(
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                                  children: [
                                                    CustomText(
                                                      text: "New Lead",
                                                      colors: colorsConst
                                                          .textColor,
                                                      isBold: true,
                                                      size: 16,
                                                    ),
                                                    20.height,
                                                    utils.leadText(
                                                        text: "Name",
                                                        color: colorsConst
                                                            .headColor),
                                                    20.height,
                                                    utils.leadText(
                                                        text: "Mobile No",
                                                        color: colorsConst
                                                            .headColor),
                                                    20.height,
                                                    utils.leadText(
                                                        text: "Email id",
                                                        color: colorsConst
                                                            .headColor),
                                                    20.height,
                                                    utils.leadText(
                                                        text:
                                                        "Discussion Point",
                                                        color: colorsConst
                                                            .headColor),
                                                  ],
                                                ),
                                                30.width,
                                                Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                                  children: [
                                                    CustomText(
                                                      text: "",
                                                      colors: colorsConst
                                                          .textColor,
                                                      isBold: true,
                                                      size: 16,
                                                    ),
                                                    20.height,
                                                    utils.leadText(
                                                        text: leadData
                                                            .firstname
                                                            .toString() ==
                                                            "null"
                                                            ? ""
                                                            : leadData
                                                            .firstname
                                                            .toString()
                                                            .split(
                                                            "||")[
                                                        0],
                                                        color: colorsConst
                                                            .textColor),
                                                    20.height,
                                                    utils.leadText(
                                                        text: leadData
                                                            .mobileNumber
                                                            .toString() ==
                                                            "null"
                                                            ? ""
                                                            : leadData
                                                            .mobileNumber
                                                            .toString()
                                                            .split(
                                                            "||")[
                                                        0],
                                                        color: colorsConst
                                                            .textColor),
                                                    20.height,
                                                    utils.leadText(
                                                        text: leadData
                                                            .emailId
                                                            .toString() ==
                                                            "null"
                                                            ? ""
                                                            : leadData
                                                            .emailId
                                                            .toString()
                                                            .split(
                                                            "||")[
                                                        0],
                                                        color: colorsConst
                                                            .textColor),
                                                    20.height,
                                                    utils.leadText(
                                                        text: leadData
                                                            .discussionPoints
                                                            .toString() ==
                                                            "null"
                                                            ? ""
                                                            : leadData
                                                            .discussionPoints
                                                            .toString(),
                                                        color: colorsConst
                                                            .textColor),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          20.width,
                                          SizedBox(
                                            width: screenWidth / 4,
                                            child: Row(
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                                  children: [
                                                    CustomText(
                                                      text: "",
                                                      colors: colorsConst
                                                          .textColor,
                                                      isBold: true,
                                                      size: 16,
                                                    ),
                                                    20.height,
                                                    utils.leadText(
                                                        text:
                                                        "Account Manager",
                                                        color: colorsConst
                                                            .headColor),
                                                    20.height,
                                                    utils.leadText(
                                                        text:
                                                        "Whatsapp No",
                                                        color: colorsConst
                                                            .headColor),
                                                    20.height,
                                                    utils.leadText(
                                                        text:
                                                        "Quotation Required",
                                                        color: colorsConst
                                                            .headColor),
                                                    20.height,
                                                    utils.leadText(
                                                        text: "Source",
                                                        color: colorsConst
                                                            .headColor),
                                                  ],
                                                ),
                                                40.width,
                                                Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                                  children: [
                                                    CustomText(
                                                      text: "",
                                                      colors: colorsConst
                                                          .textColor,
                                                      isBold: true,
                                                      size: 16,
                                                    ),
                                                    20.height,
                                                    utils.leadText(
                                                        text: leadData
                                                            .owner
                                                            .toString() ==
                                                            "null"
                                                            ? ""
                                                            : leadData
                                                            .owner
                                                            .toString(),
                                                        color: colorsConst
                                                            .textColor),
                                                    20.height,
                                                    utils.leadText(
                                                        text: leadData
                                                            .mobileNumber
                                                            .toString() ==
                                                            "null"
                                                            ? ""
                                                            : leadData
                                                            .mobileNumber
                                                            .toString()
                                                            .split(
                                                            "||")[
                                                        0],
                                                        color: colorsConst
                                                            .textColor),
                                                    20.height,
                                                    utils.leadText(
                                                        text:
                                                        leadData.quotationRequired ==
                                                            "1"
                                                            ? "Yes"
                                                            : "No",
                                                        color: colorsConst
                                                            .textColor),
                                                    20.height,
                                                    utils.leadText(
                                                        text: leadData
                                                            .visitType,
                                                        color: colorsConst
                                                            .textColor),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          20.width
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                20.height,
                                // SizedBox(
                                //   height: count.toDouble(),
                                //   child: ListView.builder(
                                //     physics: const NeverScrollableScrollPhysics(),
                                //     itemCount: widget.name.toString().split("||").length,
                                //       itemBuilder: (context,index){
                                //       return Column(
                                //         children:[
                                //           Container(
                                //             height:180,
                                //             decoration: BoxDecoration(
                                //                 color: colorsConst.secondary,
                                //                 borderRadius: BorderRadius.circular(10)
                                //             ),
                                //             child: Column(
                                //               children:[
                                //                 15.height,
                                //                 Row(
                                //                   children:[
                                //                     20.width,
                                //                     SizedBox(
                                //                       width: screenWidth/2.7,
                                //                       child: Row(
                                //                         children: [
                                //                           Column(
                                //                             crossAxisAlignment: CrossAxisAlignment.start,
                                //                             children:[
                                //                               CustomText(
                                //                                 text: "New Lead",
                                //                                 colors: colorsConst.textColor,
                                //                                 isBold: true,
                                //                                 size: 16,
                                //                               ),
                                //                               20.height,
                                //                               utils.leadText(text: "Name",color: colorsConst.headColor),
                                //                               20.height,
                                //                               utils.leadText(text: "Mobile No",color: colorsConst.headColor),
                                //                               20.height,
                                //                               utils.leadText(text: "Email id",color: colorsConst.headColor),
                                //                             ],
                                //                           ),
                                //                           30.width,
                                //                           Column(
                                //                             crossAxisAlignment: CrossAxisAlignment.start,
                                //                             children:[
                                //                               CustomText(
                                //                                 text: "",
                                //                                 colors: colorsConst.textColor,
                                //                                 isBold: true,
                                //                                 size: 16,
                                //                               ),
                                //                               20.height,
                                //                               utils.leadText(text: widget.name.toString().split("||")[index],color: colorsConst.textColor),
                                //                               20.height,
                                //                               utils.leadText(text: widget.mobileNumber.toString().split("||")[index],color: colorsConst.textColor),
                                //                               20.height,
                                //                               utils.leadText(text: widget.email.toString().split("||")[index],color: colorsConst.textColor),
                                //                             ],
                                //                           ),
                                //                         ],
                                //                       ),
                                //                     ),
                                //                     20.width,
                                //                     SizedBox(
                                //                       width:screenWidth/4,
                                //                       child:Row(
                                //                         children:[
                                //                           Column(
                                //                             crossAxisAlignment: CrossAxisAlignment.start,
                                //                             children:[
                                //                               CustomText(
                                //                                 text: "",
                                //                                 colors: colorsConst.textColor,
                                //                                 isBold: true,
                                //                                 size: 16,
                                //                               ),
                                //                               20.height,
                                //                               utils.leadText(text: "Title",color: colorsConst.headColor),
                                //                               20.height,
                                //                               utils.leadText(text: "Whatsapp No",color: colorsConst.headColor),
                                //                               20.height,
                                //                               utils.leadText(text: "",color: colorsConst.headColor),
                                //                             ],
                                //                           ),
                                //                           40.width,
                                //                           Column(
                                //                             crossAxisAlignment: CrossAxisAlignment.start,
                                //                             children:[
                                //                               CustomText(
                                //                                 text: "",
                                //                                 colors: colorsConst.textColor,
                                //                                 isBold: true,
                                //                                 size: 16,
                                //                               ),
                                //                               20.height,
                                //                               utils.leadText(text: widget.title.toString().split("||")[index],color:colorsConst.textColor),
                                //                               20.height,
                                //                               utils.leadText(text: widget.whatsappNumber.toString().split("||")[index],color: colorsConst.textColor),
                                //                               20.height,
                                //                               utils.leadText(text: "",color: colorsConst.textColor),
                                //                             ],
                                //                           ),
                                //                         ],
                                //                       ),
                                //                     ),
                                //                     20.width
                                //                   ],
                                //                 )
                                //               ],
                                //             ),
                                //           ),
                                //           20.height,
                                //         ],
                                //       );
                                //       }),
                                // ),
                                Container(
                                  height: 180,
                                  decoration: BoxDecoration(
                                      color: colorsConst.secondary,
                                      borderRadius:
                                      BorderRadius.circular(10)),
                                  child: Column(
                                    children: [
                                      15.height,
                                      Row(
                                        children: [
                                          20.width,
                                          SizedBox(
                                            width: screenWidth / 2.7,
                                            child: Row(
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                                  children: [
                                                    CustomText(
                                                      text:
                                                      "Address Information",
                                                      colors: colorsConst
                                                          .textColor,
                                                      isBold: true,
                                                      size: 16,
                                                    ),
                                                    20.height,
                                                    utils.leadText(
                                                        text: "Door No",
                                                        color: colorsConst
                                                            .headColor),
                                                    20.height,
                                                    utils.leadText(
                                                        text: "Area",
                                                        color: colorsConst
                                                            .headColor),
                                                    20.height,
                                                    utils.leadText(
                                                        text: "State",
                                                        color: colorsConst
                                                            .headColor),
                                                  ],
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                                  children: [
                                                    CustomText(
                                                      text: "",
                                                      colors: colorsConst
                                                          .textColor,
                                                      isBold: true,
                                                      size: 16,
                                                    ),
                                                    20.height,
                                                    utils.leadText(
                                                        text: leadData
                                                            .doorNo
                                                            .toString() ==
                                                            "null"
                                                            ? ""
                                                            : leadData
                                                            .doorNo,
                                                        color: colorsConst
                                                            .textColor),
                                                    20.height,
                                                    utils.leadText(
                                                        text: leadData
                                                            .area
                                                            .toString() ==
                                                            "null"
                                                            ? ""
                                                            : leadData
                                                            .area,
                                                        color: colorsConst
                                                            .textColor),
                                                    20.height,
                                                    utils.leadText(
                                                        text: leadData
                                                            .state
                                                            .toString() ==
                                                            "null"
                                                            ? ""
                                                            : leadData
                                                            .state,
                                                        color: colorsConst
                                                            .textColor),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          20.width,
                                          SizedBox(
                                            width: screenWidth / 4,
                                            child: Row(
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                                  children: [
                                                    CustomText(
                                                      text: "",
                                                      colors: colorsConst
                                                          .textColor,
                                                      isBold: true,
                                                      size: 16,
                                                    ),
                                                    20.height,
                                                    utils.leadText(
                                                        text: "Street",
                                                        color: colorsConst
                                                            .headColor),
                                                    20.height,
                                                    utils.leadText(
                                                        text: "City",
                                                        color: colorsConst
                                                            .headColor),
                                                    20.height,
                                                    utils.leadText(
                                                        text: "Country",
                                                        color: colorsConst
                                                            .headColor),
                                                  ],
                                                ),
                                                40.width,
                                                Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                                  children: [
                                                    CustomText(
                                                      text: "",
                                                      colors: colorsConst
                                                          .textColor,
                                                      isBold: true,
                                                      size: 16,
                                                    ),
                                                    20.height,
                                                    utils.leadText(
                                                        text: leadData
                                                            .landmark1
                                                            .toString() ==
                                                            "null"
                                                            ? ""
                                                            : leadData
                                                            .landmark1,
                                                        color: colorsConst
                                                            .textColor),
                                                    20.height,
                                                    utils.leadText(
                                                        text: leadData
                                                            .city
                                                            .toString() ==
                                                            "null"
                                                            ? ""
                                                            : leadData
                                                            .city,
                                                        color: colorsConst
                                                            .textColor),
                                                    20.height,
                                                    utils.leadText(
                                                        text: leadData
                                                            .country
                                                            .toString() ==
                                                            "null"
                                                            ? ""
                                                            : leadData
                                                            .country,
                                                        color: colorsConst
                                                            .textColor),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          20.width
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                20.height,
                                Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                      color: colorsConst.secondary,
                                      borderRadius:
                                      BorderRadius.circular(10)),
                                  child: Column(
                                    children: [
                                      15.height,
                                      Row(
                                        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          20.width,
                                          SizedBox(
                                            width: screenWidth / 2.7,
                                            child: Row(
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                                  children: [
                                                    CustomText(
                                                      text:
                                                      "Company Information",
                                                      colors: colorsConst
                                                          .textColor,
                                                      isBold: true,
                                                      size: 16,
                                                    ),
                                                    20.height,
                                                    utils.leadText(
                                                        text:
                                                        "Company Name",
                                                        color: colorsConst
                                                            .headColor),
                                                    20.height,
                                                    utils.leadText(
                                                        text:
                                                        "Company Phone No.",
                                                        color: colorsConst
                                                            .headColor),
                                                    20.height,
                                                    utils.leadText(
                                                        text: "Industry",
                                                        color: colorsConst
                                                            .headColor),
                                                    20.height,
                                                    utils.leadText(
                                                        text: "Linkedin",
                                                        color: colorsConst
                                                            .headColor),
                                                  ],
                                                ),
                                                10.width,
                                                Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                                  children: [
                                                    CustomText(
                                                      text: "",
                                                      colors: colorsConst
                                                          .textColor,
                                                      isBold: true,
                                                      size: 16,
                                                    ),
                                                    20.height,
                                                    utils.leadText(
                                                        text: leadData
                                                            .companyName
                                                            .toString() ==
                                                            "null"
                                                            ? ""
                                                            : widget
                                                            .companyName,
                                                        color: colorsConst
                                                            .textColor),
                                                    20.height,
                                                    utils.leadText(
                                                        text: widget.companyNumber
                                                            .toString() ==
                                                            "null"
                                                            ? ""
                                                            : widget
                                                            .companyNumber,
                                                        color: colorsConst
                                                            .textColor),
                                                    20.height,
                                                    utils.leadText(
                                                        text: widget.industry
                                                            .toString() ==
                                                            "null"
                                                            ? ""
                                                            : widget
                                                            .industry,
                                                        color: colorsConst
                                                            .textColor),
                                                    20.height,
                                                    utils.leadText(
                                                        text: widget.linkedin
                                                            .toString() ==
                                                            "null"
                                                            ? ""
                                                            : widget
                                                            .linkedin,
                                                        color: colorsConst
                                                            .textColor),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          20.width,
                                          SizedBox(
                                            width: screenWidth / 4,
                                            child: Row(
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                                  children: [
                                                    CustomText(
                                                      text: "",
                                                      colors: colorsConst
                                                          .textColor,
                                                      isBold: true,
                                                      size: 16,
                                                    ),
                                                    20.height,
                                                    utils.leadText(
                                                        text: "Website",
                                                        color: colorsConst
                                                            .headColor),
                                                    20.height,
                                                    utils.leadText(
                                                        text:
                                                        "Company Email",
                                                        color: colorsConst
                                                            .headColor),
                                                    20.height,
                                                    utils.leadText(
                                                        text:
                                                        "Product/Services",
                                                        color: colorsConst
                                                            .headColor),
                                                    20.height,
                                                    utils.leadText(
                                                        text: "X",
                                                        color: colorsConst
                                                            .headColor),
                                                  ],
                                                ),
                                                30.width,
                                                Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                                  children: [
                                                    CustomText(
                                                      text: "",
                                                      colors: colorsConst
                                                          .textColor,
                                                      isBold: true,
                                                      size: 16,
                                                    ),
                                                    20.height,
                                                    utils.leadText(
                                                        text: widget.companyWebsite
                                                            .toString() ==
                                                            "null"
                                                            ? ""
                                                            : widget
                                                            .companyWebsite,
                                                        color: colorsConst
                                                            .textColor),
                                                    20.height,
                                                    utils.leadText(
                                                        text: widget.companyEmail
                                                            .toString() ==
                                                            "null"
                                                            ? ""
                                                            : widget
                                                            .companyEmail,
                                                        color: colorsConst
                                                            .textColor),
                                                    20.height,
                                                    utils.leadText(
                                                        text: widget.productServices
                                                            .toString() ==
                                                            "null"
                                                            ? ""
                                                            : widget
                                                            .productServices,
                                                        color: colorsConst
                                                            .textColor),
                                                    20.height,
                                                    utils.leadText(
                                                        text: widget.x
                                                            .toString() ==
                                                            "null"
                                                            ? ""
                                                            : widget.x,
                                                        color: colorsConst
                                                            .textColor),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          20.width
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                20.height,
                                // Container(
                                //   height: 150,
                                //   decoration: BoxDecoration(
                                //       color: colorsConst.secondary,
                                //       borderRadius: BorderRadius.circular(10)
                                //   ),
                                //   child: Column(
                                //     children: [
                                //       15.height,
                                //       Row(
                                //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                //         children:[
                                //           20.width,
                                //           Column(
                                //             crossAxisAlignment: CrossAxisAlignment.start,
                                //             children:[
                                //               CustomText(
                                //                 text: "Lead Details",
                                //                 colors: colorsConst.textColor,
                                //                 isBold: true,
                                //                 size: 16,
                                //               ),
                                //               20.height,
                                //               utils.leadText(text: "Source",color: colorsConst.headColor),
                                //               20.height,
                                //               utils.leadText(text: "Status",color: colorsConst.headColor),
                                //             ],
                                //           ),
                                //           30.width,
                                //           Column(
                                //             crossAxisAlignment: CrossAxisAlignment.start,
                                //             children: [
                                //               CustomText(
                                //                 text: "",
                                //                 colors: colorsConst.textColor,
                                //                 isBold: true,
                                //                 size: 16,
                                //               ),
                                //               20.height,
                                //               utils.leadText(text: widget.source,color: colorsConst.textColor),
                                //               20.height,
                                //               utils.leadText(text: widget.status,color: colorsConst.textColor),
                                //
                                //             ],
                                //           ),
                                //           SizedBox(
                                //             width: MediaQuery.of(context).size.width/5,
                                //           ),
                                //           Column(
                                //             crossAxisAlignment: CrossAxisAlignment.start,
                                //             children:[
                                //               CustomText(
                                //                 text: "",
                                //                 colors: colorsConst.textColor,
                                //                 isBold: true,
                                //                 size: 16,
                                //               ),
                                //               20.height,
                                //               utils.leadText(text: "Lead Owner",color: colorsConst.headColor),
                                //               20.height,
                                //               utils.leadText(text: "Rating",color: colorsConst.headColor),
                                //
                                //             ],
                                //           ),
                                //           40.width,
                                //           Column(
                                //             crossAxisAlignment: CrossAxisAlignment.start,
                                //             children:[
                                //               CustomText(
                                //                 text: "",
                                //                 colors: colorsConst.textColor,
                                //                 isBold: true,
                                //                 size: 16,
                                //               ),
                                //               20.height,
                                //               utils.leadText(text: widget.owner,color:colorsConst.textColor),
                                //               20.height,
                                //               utils.leadText(text: widget.rating,color: colorsConst.textColor),
                                //
                                //             ],
                                //           ),
                                //           20.width
                                //         ],
                                //       ),
                                //     ],
                                //   ),
                                // ),
                                20.height,
                                Container(
                                  height: 380,
                                  decoration: BoxDecoration(
                                      color: colorsConst.secondary,
                                      borderRadius:
                                      BorderRadius.circular(10)),
                                  child: Column(
                                    children: [
                                      15.height,
                                      Row(
                                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          20.width,
                                          SizedBox(
                                            width: screenWidth / 2.7,
                                            child: Row(
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                                  children: [
                                                    CustomText(
                                                      text:
                                                      "Customer Fields",
                                                      colors: colorsConst
                                                          .textColor,
                                                      isBold: true,
                                                      size: 16,
                                                    ),
                                                    20.height,
                                                    utils.leadText(
                                                        text:
                                                        "Product Discussed",
                                                        color: colorsConst
                                                            .headColor),
                                                    20.height,
                                                    // utils.leadText(text: "Details Of Services Required",color: colorsConst.headColor),
                                                    // 20.height,
                                                    utils.leadText(
                                                        text: "Status",
                                                        color: colorsConst
                                                            .headColor),
                                                    20.height,
                                                    utils.leadText(
                                                        text:
                                                        "Expected Monthly Billing Value",
                                                        color: colorsConst
                                                            .headColor),
                                                    20.height,
                                                    utils.leadText(
                                                        text:
                                                        "Total Number Of Head Count",
                                                        color: colorsConst
                                                            .headColor),
                                                    20.height,
                                                    utils.leadText(
                                                        text:
                                                        "Details of Service Required",
                                                        color: colorsConst
                                                            .headColor),
                                                    20.height,
                                                    utils.leadText(
                                                        text:
                                                        "Prospect Grading",
                                                        color: colorsConst
                                                            .headColor),
                                                    20.height,
                                                    utils.leadText(
                                                        text:
                                                        "PROSPECT SOURCE DETAILS",
                                                        color: colorsConst
                                                            .headColor),
                                                  ],
                                                ),
                                                40.width,
                                                Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                                  children: [
                                                    CustomText(
                                                      text: "",
                                                      colors: colorsConst
                                                          .textColor,
                                                      isBold: true,
                                                      size: 16,
                                                    ),
                                                    20.height,
                                                    utils.leadText(
                                                        text: leadData
                                                            .productDiscussion
                                                            .toString() ==
                                                            "null"
                                                            ? ""
                                                            : leadData
                                                            .productDiscussion,
                                                        color: colorsConst
                                                            .textColor),
                                                    20.height,
                                                    // utils.leadText(text: widget.notes.toString()=="null"?"":widget.notes,color: colorsConst.textColor),
                                                    // 20.height,
                                                    utils.leadText(
                                                        text: leadData
                                                            .leadStatus
                                                            .toString() ==
                                                            "null"
                                                            ? ""
                                                            : leadData.leadStatus ==
                                                            "1"
                                                            ? "Suspects"
                                                            : leadData.leadStatus ==
                                                            "2"
                                                            ? "Prospects"
                                                            : leadData.leadStatus ==
                                                            "3"
                                                            ? "Qualified"
                                                            : "Customers",
                                                        color: colorsConst
                                                            .textColor),
                                                    20.height,
                                                    utils.leadText(
                                                        text: leadData
                                                            .expectedBillingValue
                                                            .toString() ==
                                                            "null"
                                                            ? ""
                                                            : leadData
                                                            .expectedBillingValue,
                                                        color: colorsConst
                                                            .textColor),
                                                    20.height,
                                                    utils.leadText(
                                                        text: leadData
                                                            .numOfHeadcount
                                                            .toString() ==
                                                            "null"
                                                            ? ""
                                                            : leadData
                                                            .numOfHeadcount,
                                                        color: colorsConst
                                                            .textColor),
                                                    20.height,
                                                    utils.leadText(
                                                        text: leadData
                                                            .detailsOfServiceRequired
                                                            .toString() ==
                                                            "null"
                                                            ? ""
                                                            : leadData
                                                            .detailsOfServiceRequired,
                                                        color: colorsConst
                                                            .textColor),
                                                    20.height,
                                                    utils.leadText(
                                                        text: leadData
                                                            .rating
                                                            .toString() ==
                                                            "null"
                                                            ? ""
                                                            : leadData
                                                            .rating,
                                                        color: colorsConst
                                                            .textColor),
                                                    20.height,
                                                    utils.leadText(
                                                        text: leadData
                                                            .sourceDetails
                                                            .toString() ==
                                                            "null"
                                                            ? ""
                                                            : leadData
                                                            .sourceDetails,
                                                        color: colorsConst
                                                            .textColor),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          20.width,
                                          SizedBox(
                                            width: screenWidth / 4,
                                            child: Row(
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                                  children: [
                                                    CustomText(
                                                      text: "",
                                                      colors: colorsConst
                                                          .textColor,
                                                      isBold: true,
                                                      size: 16,
                                                    ),
                                                    20.height,
                                                    utils.leadText(
                                                        text:
                                                        "Additional Notes",
                                                        color: colorsConst
                                                            .headColor),
                                                    20.height,
                                                    utils.leadText(
                                                        text:
                                                        "Response Priority",
                                                        color: colorsConst
                                                            .headColor),
                                                    20.height,
                                                    utils.leadText(
                                                        text:
                                                        "ARPU Value",
                                                        color: colorsConst
                                                            .headColor),
                                                    20.height,
                                                    utils.leadText(
                                                        text:
                                                        "Expected Conversion Date",
                                                        color: colorsConst
                                                            .headColor),
                                                    20.height,
                                                    utils.leadText(
                                                        text:
                                                        "Prospect Enrollment Date",
                                                        color: colorsConst
                                                            .headColor),
                                                    10.height,
                                                    utils.leadText(
                                                        text:
                                                        "SOURCE OF PROSPECT \n (either BNI or social)",
                                                        color: colorsConst
                                                            .headColor),
                                                    20.height,
                                                    utils.leadText(
                                                        text:
                                                        "Status Update",
                                                        color: colorsConst
                                                            .headColor),
                                                    25.height,
                                                  ],
                                                ),
                                                20.width,
                                                Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                                  children: [
                                                    CustomText(
                                                      text: "",
                                                      colors: colorsConst
                                                          .textColor,
                                                      isBold: true,
                                                      size: 16,
                                                    ),
                                                    20.height,
                                                    utils.leadText(
                                                        text: leadData
                                                            .notes
                                                            .toString() ==
                                                            "null"
                                                            ? ""
                                                            : leadData
                                                            .notes,
                                                        color: colorsConst
                                                            .textColor),
                                                    20.height,
                                                    utils.leadText(
                                                        text: leadData
                                                            .quotationStatus ==
                                                            "1"
                                                            ? "Normal"
                                                            : leadData.quotationStatus ==
                                                            "2"
                                                            ? "Critical"
                                                            : "Urgent",
                                                        color: colorsConst
                                                            .textColor),
                                                    20.height,
                                                    utils.leadText(
                                                        text: leadData
                                                            .arpuValue
                                                            .toString() ==
                                                            "null"
                                                            ? ""
                                                            : leadData
                                                            .arpuValue,
                                                        color: colorsConst
                                                            .textColor),
                                                    20.height,
                                                    utils.leadText(
                                                        text: leadData
                                                            .expectedConvertionDate
                                                            .toString() ==
                                                            "null"
                                                            ? ""
                                                            : leadData
                                                            .expectedConvertionDate
                                                            .toString(),
                                                        color: colorsConst
                                                            .textColor),
                                                    20.height,
                                                    utils.leadText(
                                                        text: leadData
                                                            .prospectEnrollmentDate
                                                            .toString() ==
                                                            "null"
                                                            ? ""
                                                            : leadData
                                                            .prospectEnrollmentDate
                                                            .toString(),
                                                        color: colorsConst
                                                            .textColor),
                                                    20.height,
                                                    utils.leadText(
                                                        text: leadData
                                                            .source
                                                            .toString() ==
                                                            "null"
                                                            ? ""
                                                            : leadData
                                                            .source
                                                            .toString(),
                                                        color: colorsConst
                                                            .textColor),
                                                    20.height,
                                                    Tooltip(
                                                      message: leadData
                                                          .statusUpdate
                                                          .toString(),
                                                      child: utils.leadText(
                                                          text: leadData
                                                              .statusUpdate
                                                              .toString() ==
                                                              "null"
                                                              ? ""
                                                              : leadData
                                                              .statusUpdate
                                                              .toString(),
                                                          color: colorsConst
                                                              .textColor),
                                                    ),
                                                    25.height,
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          20.width
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                20.height
                              ],
                            );
                          }),
                    );
                  } else if (snapshot.hasError) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        120.height,
                        Center(
                            child: SvgPicture.asset(
                                "assets/images/noDataFound.svg")),
                      ],
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              )),
            ),
            // utils.funnelContainer(context),
          ],
        ),
      ),
    );
  }
}
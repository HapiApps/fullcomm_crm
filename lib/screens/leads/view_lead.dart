import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:fullcomm_crm/models/new_lead_obj.dart';
import 'package:fullcomm_crm/screens/leads/update_lead.dart';
import 'package:fullcomm_crm/services/api_services.dart';
import '../../common/constant/api.dart';
import '../../common/constant/colors_constant.dart';
import '../../common/constant/default_constant.dart';
import '../../common/utilities/utils.dart';
import '../../components/custom_loading_button.dart';
import '../../components/custom_sidebar.dart';
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
  ViewLead({super.key,
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
    this.pinCode,this.x,this.linkedin,
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
    required this.updateTs
  });

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
  String _formatHeading(String heading) {
    String cleaned = heading.replaceAll(",", "").trim();
    return cleaned
        .split(" ")
        .map((word) => word.isNotEmpty
        ? word[0].toUpperCase() + word.substring(1).toLowerCase()
        : "")
        .join(" ");
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = ScrollController();
    _focusNode = FocusNode();
    _focusNode.requestFocus();
    Future.delayed(Duration.zero,(){
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
  Widget build(BuildContext context){
    var count=200*widget.name.toString().split("||").length;
    double screenWidth=MediaQuery.of(context).size.width;
    return SelectionArea(
      child: Scaffold(
        body: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SideBar(
              controllers: controllers,
              colorsConst: colorsConst,
              logo: logo,
              constValue: constValue,
              versionNum: versionNum,
            ),
            Container(
              width: screenWidth-150,
              height: MediaQuery.of(context).size.height,
              alignment: Alignment.center,
              padding: EdgeInsets.all(20),
              child:Obx(()=>controllers.isLeadLoading.value?const CircularProgressIndicator():
              FutureBuilder<List<NewLeadObj>>(
                future: controllers.leadFuture,
                builder: (context,snapshot){
                  if(snapshot.hasData){
                    return GestureDetector(
                      onTap: () {
                        _focusNode.requestFocus();
                      },
                      child: RawKeyboardListener(
                        focusNode: _focusNode,
                        autofocus: true,
                        onKey: (event) {
                          if (event is RawKeyDownEvent) {
                            if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                              _controller.animateTo(
                                _controller.offset + 100,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                              );
                            } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
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
                            itemBuilder: (context,index){
                              final leadData = snapshot.data![index];
                              print("pincode ${leadData.pincode}");
                              List<String> additionalInfoList = [];
                              if (leadData.additionalInfo != null && leadData.additionalInfo.toString().isNotEmpty) {
                                additionalInfoList = leadData.additionalInfo.toString().split("||");
                              }
                              // return Column(
                              //   crossAxisAlignment: CrossAxisAlignment.start,
                              //   children: controllers.fields.map((fm) {
                              //     final key = fm.systemField;
                              //     final heading = fm.userHeading;
                              //     final value = leadData.asMap()[key]  ?? '';
                              //     return Padding(
                              //       padding: const EdgeInsets.symmetric(vertical: 4.0),
                              //       child: Row(
                              //         crossAxisAlignment: CrossAxisAlignment.start,
                              //         children: [
                              //           Expanded(
                              //             flex: 3,
                              //             child: Text(
                              //               heading ?? '',
                              //               style: const TextStyle(
                              //                 fontWeight: FontWeight.bold,
                              //               ),
                              //             ),
                              //           ),
                              //           8.width,
                              //           Expanded(
                              //             flex: 7,
                              //             child: Text(
                              //               value.toString(),
                              //             ),
                              //           ),
                              //         ],
                              //       ),
                              //     );
                              //   }).toList(),
                              // );
                              return Column(
                                children:[
                                  20.height,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children:[
                                      SizedBox(
                                          width: screenWidth/2.5,
                                          child: Row(
                                            children: [
                                              IconButton(
                                                  onPressed: (){
                                                    Get.back();
                                                  },
                                                  icon: Icon(Icons.arrow_back,color: colorsConst.third,)),
                                              CustomText(
                                                text: "View Lead",
                                                colors: colorsConst.textColor,
                                                size: 20,
                                                isBold: true,
                                              ),
                                            ],
                                          )
                                      ),
                                      SizedBox(
                                        width: 300,
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width : 120,
                                              height: 35,
                                              child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    shadowColor: Colors.transparent,
                                                    backgroundColor: colorsConst.primary,),
                                                  onPressed: (){
                                                    controllers.leadNameCrt.add(TextEditingController());
                                                    controllers.leadMobileCrt.add(TextEditingController());
                                                    controllers.leadTitleCrt.add(TextEditingController());
                                                    controllers.leadEmailCrt.add(TextEditingController());
                                                    controllers.leadWhatsCrt.add(TextEditingController());
                                                    //Get.to(const Suspects(),duration: Duration.zero);
                                                    Get.to(UpdateLead(
                                                      visitType: leadData.visitType.toString(),
                                                      id:widget.id,
                                                      detailsOfRequired: leadData.detailsOfServiceRequired,
                                                      linkedin: "",
                                                      x: "",
                                                      mainName:leadData.firstname.toString()=="null"?"":leadData.firstname.toString().split("||")[0],
                                                      mainMobile:leadData.mobileNumber.toString()=="null"?"":leadData.mobileNumber.toString().split("||")[0],
                                                      mainEmail:leadData.email.toString()=="null"?"":leadData.email.toString().split("||")[0],
                                                      mainWhatsApp:leadData.mobileNumber.toString()=="null"?"":leadData.mobileNumber.toString().split("||")[0],
                                                      companyName:leadData.companyName,
                                                      status:leadData.status,
                                                      rating:leadData.rating,
                                                      emailUpdate:leadData.quotationRequired,
                                                      name:leadData.firstname,
                                                      title:"",
                                                      mobileNumber:leadData.mobileNumber,
                                                      whatsappNumber:leadData.mobileNumber,
                                                      email:leadData.email,
                                                      mainTitle:"",
                                                      addressId:leadData.addressId,
                                                      companyWebsite:"",
                                                      companyNumber:"",
                                                      companyEmail:"",
                                                      industry:"",
                                                      productServices:"",
                                                      source:leadData.source,
                                                      owner:leadData.owner,
                                                      budget:"",
                                                      timelineDecision:"",
                                                      serviceInterest:"",
                                                      description:"",
                                                      leadStatus:leadData.leadStatus,
                                                      active:leadData.active,
                                                      addressLine1:leadData.doorNo,
                                                      addressLine2:leadData.landmark1,
                                                      area:leadData.area,
                                                      city:leadData.city,
                                                      state:leadData.state,
                                                      country:leadData.country,
                                                      pinCode:leadData.pincode,
                                                      quotationStatus:leadData.quotationStatus,
                                                      productDiscussion:leadData.productDiscussion,
                                                      discussionPoint:leadData.discussionPoint,
                                                      notes:leadData.notes.toString(),
                                                      statusUpdate: leadData.statusUpdate,
                                                      prospectEnrollmentDate: leadData.prospectEnrollmentDate ?? "",
                                                      expectedConvertionDate: leadData.expectedConvertionDate ?? "",
                                                      numOfHeadcount: leadData.numOfHeadcount ?? "",
                                                      expectedBillingValue: leadData.expectedBillingValue ?? "",
                                                      arpuValue: leadData.arpuValue ?? "",
                                                      updateTs: leadData.updatedTs.toString(),
                                                      sourceDetails: leadData.sourceDetails.toString(),));
                                                    print("address id ${leadData.addressId}");
                                                  },
                                                  child: MouseRegion(
                                                    cursor: SystemMouseCursors.click,
                                                    child: Text(
                                                      "Edit",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  )),
                                            ),
                                            10.width,
                                            CustomLoadingButton(
                                              callback:(){
                                                // controllers.mailReceivesList.value=[];
                                                // apiService.mailReceiveDetails(widget.id.toString());
                                                controllers.emailSubjectCtr.clear();
                                                controllers.emailMessageCtr.clear();
                                                imageController.photo1.value="";
                                                controllers.emailToCtr.text=widget.email.toString()=="null"?"":widget.email.toString();
                                                utils.sendEmailDialog(id: widget.id.toString(), name: widget.name.toString(),
                                                    mobile: widget.mobileNumber.toString(), coName: widget.companyName.toString());
                                              },
                                              height: 35,
                                              isLoading: false,
                                              backgroundColor: colorsConst.third,
                                              radius: 2,
                                              width: 120,
                                              isImage: false,
                                              text: "Send Email",
                                              textColor: Colors.white,
                                            ),
                                          ],
                                        ),
                                      ),
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
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      CustomText(
                                        text: "Added : ${formatDateTime(leadData.updatedTs.toString())}",
                                        colors: colorsConst.textColor,
                                        size: 12,
                                      )
                                    ],
                                  ),
                                  Container(
                                    height:190,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: Colors.black
                                        ),
                                        borderRadius: BorderRadius.circular(10)
                                    ),
                                    child: Column(
                                      children:[
                                        15.height,
                                        Row(
                                          children:[
                                            20.width,
                                            SizedBox(
                                              width: screenWidth/2.7,
                                              child: Row(
                                                children: [
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children:[
                                                      CustomText(
                                                        text: "New Lead",
                                                        colors: colorsConst.textColor,
                                                        isBold: true,
                                                        size: 16,
                                                      ),
                                                      20.height,
                                                      utils.leadText(text: _formatHeading(controllers.getUserHeading("name") ??"Name"),
                                                          color: colorsConst.primary),
                                                      20.height,
                                                      utils.leadText(text: _formatHeading(controllers.getUserHeading("mobile_name") ??"Mobile No"),
                                                          color: colorsConst.primary),
                                                      20.height,
                                                      utils.leadText(text: _formatHeading(controllers.getUserHeading("email") ??"Email id"),
                                                          color: colorsConst.primary),
                                                      // 20.height,
                                                      // utils.leadText(text: _formatHeading(
                                                      //     controllers.getUserHeading("discussion_point") ??"Discussion Point"),
                                                      //     color: colorsConst.primary),
                                                    ],
                                                  ),
                                                  30.width,
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children:[
                                                      CustomText(
                                                        text: "",
                                                        colors: colorsConst.textColor,
                                                        isBold: true,
                                                        size: 16,
                                                      ),
                                                      20.height,
                                                      utils.leadText(text: leadData.firstname.toString()=="null"?"":leadData.firstname.toString().split("||")[0],color: colorsConst.textColor),
                                                      20.height,
                                                      utils.leadText(text: leadData.mobileNumber.toString()=="null"?"":leadData.mobileNumber.toString().split("||")[0],color: colorsConst.textColor),
                                                      20.height,
                                                      utils.leadText(text: leadData.email.toString()=="null"?"":leadData.email.toString().split("||")[0],color: colorsConst.textColor),
                                                      // 20.height,
                                                      // utils.leadText(text: leadData.discussionPoints.toString()=="null"?"":leadData.discussionPoints.toString(),color: colorsConst.textColor),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            20.width,
                                            SizedBox(
                                              width:screenWidth/4,
                                              child:Row(
                                                children:[
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children:[
                                                      CustomText(
                                                        text: "",
                                                        colors: colorsConst.textColor,
                                                        isBold: true,
                                                        size: 16,
                                                      ),
                                                      20.height,
                                                      utils.leadText(text: _formatHeading(controllers.getUserHeading("owner") ??"Account Manager"),color: colorsConst.primary),
                                                      20.height,
                                                      utils.leadText(text: "Whatsapp No",color: colorsConst.primary),
                                                      20.height,
                                                      utils.leadText(text: "Quotation Required",color: colorsConst.primary),
                                                      20.height,
                                                      utils.leadText(text: "Visit Type",color: colorsConst.primary),
                                                    ],
                                                  ),
                                                  40.width,
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children:[
                                                      CustomText(
                                                        text: "",
                                                        colors: colorsConst.textColor,
                                                        isBold: true,
                                                        size: 16,
                                                      ),
                                                      20.height,
                                                      utils.leadText(text: leadData.owner.toString()=="null"?"":leadData.owner.toString(),color:colorsConst.textColor),
                                                      20.height,
                                                      utils.leadText(text: leadData.mobileNumber.toString()=="null"?"":leadData.mobileNumber.toString().split("||")[0],color: colorsConst.textColor),
                                                      20.height,
                                                      utils.leadText(text: leadData.quotationRequired=="1"?"Yes":"No",color: colorsConst.textColor),
                                                      20.height,
                                                      utils.leadText(text: leadData.visitType,color: colorsConst.textColor),
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
                                  //                               utils.leadText(text: "Name",color: colorsConst.primary),
                                  //                               20.height,
                                  //                               utils.leadText(text: "Mobile No",color: colorsConst.primary),
                                  //                               20.height,
                                  //                               utils.leadText(text: "Email id",color: colorsConst.primary),
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
                                  //                               utils.leadText(text: "Title",color: colorsConst.primary),
                                  //                               20.height,
                                  //                               utils.leadText(text: "Whatsapp No",color: colorsConst.primary),
                                  //                               20.height,
                                  //                               utils.leadText(text: "",color: colorsConst.primary),
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
                                        color: Colors.white,
                                        border: Border.all(
                                            color: Colors.black
                                        ),
                                        borderRadius: BorderRadius.circular(10)
                                    ),
                                    child: Column(
                                      children: [
                                        15.height,
                                        Row(
                                          children:[
                                            20.width,
                                            SizedBox(
                                              width:screenWidth/2.7,
                                              child: Row(
                                                children: [
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children:[
                                                      CustomText(
                                                        text: "Address Information",
                                                        colors: colorsConst.textColor,
                                                        isBold: true,
                                                        size: 16,
                                                      ),
                                                      20.height,
                                                      utils.leadText(text: "Door No",color: colorsConst.primary),
                                                      20.height,
                                                      utils.leadText(text: "Area",color: colorsConst.primary),
                                                      20.height,
                                                      utils.leadText(text: "State",color: colorsConst.primary),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      CustomText(
                                                        text: "",
                                                        colors: colorsConst.textColor,
                                                        isBold: true,
                                                        size: 16,
                                                      ),
                                                      20.height,
                                                      utils.leadText(text: leadData.doorNo.toString()=="null"?"":leadData.doorNo,color: colorsConst.textColor),
                                                      20.height,
                                                      utils.leadText(text: leadData.area.toString()=="null"?"":leadData.area,color: colorsConst.textColor),
                                                      20.height,
                                                      utils.leadText(text: leadData.state.toString()=="null"?"":leadData.state,color: colorsConst.textColor),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            20.width,
                                            SizedBox(
                                              width:screenWidth/4,
                                              child: Row(
                                                children: [
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children:[
                                                      CustomText(
                                                        text: "",
                                                        colors: colorsConst.textColor,
                                                        isBold: true,
                                                        size: 16,
                                                      ),
                                                      20.height,
                                                      utils.leadText(text: "Pincode",color: colorsConst.primary),
                                                      20.height,
                                                      utils.leadText(text: "City",color: colorsConst.primary),
                                                      20.height,
                                                      utils.leadText(text: "Country",color: colorsConst.primary),
                                                    ],
                                                  ),
                                                  40.width,
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children:[
                                                      CustomText(
                                                        text: "",
                                                        colors: colorsConst.textColor,
                                                        isBold: true,
                                                        size: 16,
                                                      ),
                                                      20.height,
                                                      utils.leadText(text: leadData.pincode.toString()=="null"?"":leadData.pincode,color:colorsConst.textColor),
                                                      20.height,
                                                      utils.leadText(text: leadData.city.toString()=="null"?"":
                                                      leadData.city,color: colorsConst.textColor),
                                                      20.height,
                                                      utils.leadText(text: leadData.country.toString()=="null"?"":leadData.country,color: colorsConst.textColor),
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
                                        color: Colors.white,
                                        border: Border.all(
                                            color: Colors.black
                                        ),
                                        borderRadius: BorderRadius.circular(10)
                                    ),
                                    child: Column(
                                      children:[
                                        15.height,
                                        Row(
                                          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children:[
                                            20.width,
                                            SizedBox(
                                              width: screenWidth/2.7,
                                              child: Row(
                                                children:[
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children:[
                                                      CustomText(
                                                        text: "Company Information",
                                                        colors: colorsConst.textColor,
                                                        isBold: true,
                                                        size: 16,
                                                      ),
                                                      20.height,
                                                      utils.leadText(text: _formatHeading(controllers.getUserHeading("company_name") ??"Company Name"),color: colorsConst.primary),
                                                      20.height,
                                                      utils.leadText(text: "Company Phone No.",color: colorsConst.primary),
                                                      20.height,
                                                      utils.leadText(text: "Industry",color: colorsConst.primary),
                                                      20.height,
                                                      utils.leadText(text: "Linkedin",color: colorsConst.primary),
                                                    ],
                                                  ),
                                                  10.width,
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children:[
                                                      CustomText(
                                                        text: "",
                                                        colors: colorsConst.textColor,
                                                        isBold: true,
                                                        size: 16,
                                                      ),
                                                      20.height,
                                                      utils.leadText(text: leadData.companyName.toString()=="null"?"":leadData.companyName.toString(),color: colorsConst.textColor),
                                                      20.height,
                                                      utils.leadText(text: leadData.companyNumber.toString()=="null"?"":leadData.companyNumber,color: colorsConst.textColor),
                                                      20.height,
                                                      utils.leadText(text: leadData.industry.toString()=="null"?"":leadData.industry,color: colorsConst.textColor),
                                                      20.height,
                                                      utils.leadText(text: leadData.linkedin.toString()=="null"?"":leadData.linkedin,color: colorsConst.textColor),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            20.width,
                                            SizedBox(
                                              width: screenWidth/4,
                                              child: Row(
                                                children: [
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children:[
                                                      CustomText(
                                                        text: "",
                                                        colors: colorsConst.textColor,
                                                        isBold: true,
                                                        size: 16,
                                                      ),
                                                      20.height,
                                                      utils.leadText(text: "Website",color: colorsConst.primary),
                                                      20.height,
                                                      utils.leadText(text: "Company Email",color: colorsConst.primary),
                                                      20.height,
                                                      utils.leadText(text: "Product/Services",color: colorsConst.primary),
                                                      20.height,
                                                      utils.leadText(text: "X",color: colorsConst.primary),
                                                    ],
                                                  ),
                                                  30.width,
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children:[
                                                      CustomText(
                                                        text: "",
                                                        colors: colorsConst.textColor,
                                                        isBold: true,
                                                        size: 16,
                                                      ),
                                                      20.height,
                                                      utils.leadText(text: leadData.companyWebsite.toString()=="null"?"":leadData.companyWebsite,color:colorsConst.textColor),
                                                      20.height,
                                                      utils.leadText(text: leadData.companyEmail.toString()=="null"?"":leadData.companyEmail,color: colorsConst.textColor),
                                                      20.height,
                                                      utils.leadText(text: leadData.product.toString()=="null"?"":leadData.product,color: colorsConst.textColor),
                                                      20.height,
                                                      utils.leadText(text: leadData.x.toString()=="null"?"":leadData.x,color: colorsConst.textColor),
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
                                    height: 380,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            color: Colors.black
                                        ),
                                        borderRadius: BorderRadius.circular(10)
                                    ),
                                    child: Column(
                                      children: [
                                        15.height,
                                        Row(
                                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children:[
                                            20.width,
                                            SizedBox(
                                              width: screenWidth/2.7,
                                              child: Row(
                                                children: [
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children:[
                                                      CustomText(
                                                        text: "Customer Fields",
                                                        colors: colorsConst.textColor,
                                                        isBold: true,
                                                        size: 16,
                                                      ),
                                                      20.height,
                                                      utils.leadText(text: _formatHeading(controllers.getUserHeading("product_discussion") ??"Product Discussed"),color: colorsConst.primary),
                                                      20.height,
                                                      // utils.leadText(text: "Details Of Services Required",color: colorsConst.primary),
                                                      // 20.height,
                                                      utils.leadText(text: _formatHeading(controllers.getUserHeading("status") ??"Status"),color: colorsConst.primary),
                                                      20.height,
                                                      utils.leadText(text: _formatHeading(controllers.getUserHeading("expected_billing_value") ??"Expected Monthly Billing Value"),color: colorsConst.primary),
                                                      20.height,
                                                      utils.leadText(text: _formatHeading(controllers.getUserHeading("num_of_headcount") ??"Total Number Of Head Count"),color: colorsConst.primary),
                                                      20.height,
                                                      utils.leadText(text: _formatHeading(controllers.getUserHeading("details_of_service_required") ??"Details of Service Required"),color: colorsConst.primary),
                                                      20.height,
                                                      utils.leadText(text: _formatHeading(controllers.getUserHeading("rating") ??"Prospect Grading"),color: colorsConst.primary),
                                                      // 20.height,
                                                      // utils.leadText(text: _formatHeading(controllers.getUserHeading("source_details") ??"PROSPECT SOURCE DETAILS"),color: colorsConst.primary),
                                                    ],
                                                  ),
                                                  40.width,
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children:[
                                                      CustomText(
                                                        text: "",
                                                        colors: colorsConst.textColor,
                                                        isBold: true,
                                                        size: 16,
                                                      ),
                                                      20.height,
                                                      utils.leadText(text:leadData.productDiscussion.toString()=="null"?"":leadData.productDiscussion,color: colorsConst.textColor),
                                                      20.height,
                                                      // utils.leadText(text: widget.notes.toString()=="null"?"":widget.notes,color: colorsConst.textColor),
                                                      // 20.height,
                                                      utils.leadText(
                                                          text: leadData.leadStatus.toString()=="null"?"":leadData.leadStatus=="1"?"Suspects":leadData.leadStatus=="2"?"Prospects":leadData.leadStatus=="3"?"Qualified":"Customers",
                                                          color: colorsConst.textColor),
                                                      20.height,
                                                      utils.leadText(text: leadData.expectedBillingValue.toString()=="null"?"":leadData.expectedBillingValue,color: colorsConst.textColor),
                                                      20.height,
                                                      utils.leadText(text: leadData.numOfHeadcount.toString()=="null"?"":leadData.numOfHeadcount,color: colorsConst.textColor),
                                                      20.height,
                                                      utils.leadText(text: leadData.detailsOfServiceRequired.toString()=="null"?"":leadData.detailsOfServiceRequired,color: colorsConst.textColor),
                                                      20.height,
                                                      utils.leadText(text: leadData.rating.toString()=="null"?"":leadData.rating,color: colorsConst.textColor),
                                                      // 20.height,
                                                      // utils.leadText(text: leadData.sourceDetails.toString()=="null"?"":leadData.sourceDetails,color: colorsConst.textColor),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            20.width,
                                            SizedBox(
                                              width: screenWidth/4,
                                              child: Row(
                                                children: [
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children:[
                                                      CustomText(
                                                        text: "",
                                                        colors: colorsConst.textColor,
                                                        isBold: true,
                                                        size: 16,
                                                      ),
                                                      20.height,
                                                      utils.leadText(text: "Additional Notes",color: colorsConst.primary),
                                                      20.height,
                                                      utils.leadText(text: "Response Priority",color: colorsConst.primary),
                                                      20.height,
                                                      utils.leadText(text: _formatHeading(controllers.getUserHeading("arpu_value") ??"ARPU Value"),color: colorsConst.primary),
                                                      20.height,
                                                      utils.leadText(text: _formatHeading(controllers.getUserHeading("expected_convertion_date") ??"Expected Conversion Date"),color: colorsConst.primary),
                                                      20.height,
                                                      utils.leadText(text: _formatHeading(controllers.getUserHeading("prospect_enrollment_date") ??"Prospect Enrollment Date"),color: colorsConst.primary),
                                                      10.height,
                                                      utils.leadText(text: _formatHeading(controllers.getUserHeading("source") ??"SOURCE OF PROSPECT"),color: colorsConst.primary),
                                                      20.height,
                                                      utils.leadText(text: _formatHeading(controllers.getUserHeading("status_update") ??"Status Update"),color: colorsConst.primary),
                                                      25.height,
                                                    ],
                                                  ),
                                                  20.width,
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children:[
                                                      CustomText(
                                                        text: "",
                                                        colors: colorsConst.textColor,
                                                        isBold: true,
                                                        size: 16,
                                                      ),
                                                      20.height,
                                                      utils.leadText(text: leadData.notes.toString() =="null"?"":leadData.notes,color:colorsConst.textColor),
                                                      20.height,
                                                      utils.leadText(text:leadData.quotationStatus=="1"?"Normal":leadData.quotationStatus=="2"?"Critical":"Urgent",color: colorsConst.textColor),
                                                      20.height,
                                                      utils.leadText(text:leadData.arpuValue.toString()=="null"?"":leadData.arpuValue,color: colorsConst.textColor),
                                                      20.height,
                                                      utils.leadText(text:leadData.expectedConvertionDate.toString()=="null"?"":leadData.expectedConvertionDate.toString(),color: colorsConst.textColor),
                                                      20.height,
                                                      utils.leadText(text:leadData.prospectEnrollmentDate.toString()=="null"?"":leadData.prospectEnrollmentDate.toString(),color: colorsConst.textColor),
                                                      20.height,
                                                      utils.leadText(text:leadData.source.toString()=="null"?"":leadData.source.toString(),color: colorsConst.textColor),
                                                      20.height,
                                                      Tooltip(
                                                        message: leadData.statusUpdate.toString(),
                                                        child: utils.leadText(text:leadData.statusUpdate.toString()=="null"?"":
                                                        leadData.statusUpdate.toString(),color: colorsConst.textColor),
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
                                  20.height,
                                  additionalInfoList.contains("NULL:")?0.height:SizedBox(
                                    width: screenWidth / 2.7,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            CustomText(
                                              text: "Additional Information",
                                              colors: colorsConst.textColor,
                                              isBold: true,
                                              size: 16,
                                            ),
                                            20.height,
                                            ...additionalInfoList.map((info) {
                                              String key = "";
                                              String value = "";
                                              if (info.contains(":")) {
                                                var parts = info.split(":");
                                                key = parts[0].trim();
                                                value = parts.sublist(1).join(":").trim(); // in case value has :
                                              }
                                              return Padding(
                                                padding: const EdgeInsets.only(bottom: 15),
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    utils.leadText(text: key, color: colorsConst.primary),
                                                    10.width,
                                                    utils.leadText(text: value, color: colorsConst.textColor),
                                                  ],
                                                ),
                                              );
                                            }),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  20.height
                                ],
                              );
                            }),
                      ),
                    );
                  }else if(snapshot.hasError){
                    return  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:[
                        120.height,
                        Center(
                            child: SvgPicture.asset("assets/images/noDataFound.svg")
                        ),
                      ],
                    );
                  }
                  return const Center(child:CircularProgressIndicator());
                },
              )),
            ),
          ],
        ),
      ),
    );
  }
}

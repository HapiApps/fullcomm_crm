import 'dart:convert';
import 'package:excel/excel.dart' as excel;
import 'package:fullcomm_crm/screens/leads/prospects.dart';
import 'package:fullcomm_crm/screens/leads/qualified.dart';
import 'package:fullcomm_crm/screens/leads/suspects.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/screens/customer/view_customer.dart';
import '../../components/custom_loading_button.dart';
import '../../components/custom_text.dart';
import '../../components/dialog_button.dart';
import '../../components/keyboard_search.dart';
import '../../controller/controller.dart';
import '../../controller/image_controller.dart';
import '../../controller/reminder_controller.dart';
import '../../main.dart';
import '../../models/all_customers_obj.dart';
import '../../provider/reminder_provider.dart';
import '../../services/api_services.dart';
import '../constant/api.dart';
import '../constant/assets_constant.dart';
import '../constant/colors_constant.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

final Utils utils = Utils._();

class Utils {
  Utils._();
  // void bulkEmailDialog(FocusNode focusNode, {required List<Map<String, String>> list}) {
  //   int total = list.length;
  //   int withMail = list.where((e) => (e["mail_id"] != null && e["mail_id"]!.trim().isNotEmpty && e["mail_id"]!.trim() != "null")).length;
  //   int withoutMail = total - withMail;
  //   var selectedRange = "".obs;
  //   void selectRange(String range, List<NewLeadObj> allLeads) {
  //     selectedRange.value = range;
  //     final parts = range.split("-");
  //     final start = int.parse(parts[0].trim()) - 1; // index start
  //     final end = int.parse(parts[1].trim());       // index end
  //     final subList = allLeads.sublist(start, end);
  //     total = subList.length;
  //     withMail = subList.where((e) =>
  //     e.email != null &&
  //         e.email!.trim().isNotEmpty &&
  //         e.email!.trim() != "null").length;
  //     withoutMail = total - withMail;
  //     apiService.prospectsList.addAll(
  //       subList.where((data) =>
  //       data.email != null &&
  //           data.email!.trim().isNotEmpty &&
  //           data.email!.trim() != "null") // mail check
  //           .map((data) => {
  //         "lead_id": data.userId.toString(),
  //         "user_id": controllers.storage.read("id"),
  //         "rating": data.rating ?? "Warm",
  //         "cos_id": controllers.storage.read("cos_id"),
  //         "mail_id": data.email!.split("||")[0]
  //       }),
  //     );
  //   }
  //   showDialog(
  //       context: Get.context!,
  //       barrierDismissible: false,
  //       builder: (context) {
  //         return StatefulBuilder(
  //             builder: (context,setState){
  //               return AlertDialog(
  //                 actions: [
  //                   Column(
  //                     children: [
  //                       Divider(
  //                         color: Colors.grey.shade300,
  //                         thickness: 1,
  //                       ),
  //                       Row(
  //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                         children: [
  //                           SizedBox(
  //                             child: Row(
  //                               children: [
  //                                 IconButton(
  //                                     onPressed: () {},
  //                                     icon: SvgPicture.asset(assets.b,
  //                                         color: colorsConst.primary,
  //                                         width: 17, height: 17)),
  //                                 IconButton(
  //                                     onPressed: () {},
  //                                     icon: SvgPicture.asset(
  //                                       assets.i,
  //                                       width: 15,
  //                                       height: 15,
  //                                       color: colorsConst.primary,
  //                                     )),
  //                                 IconButton(
  //                                     onPressed: () {},
  //                                     icon: SvgPicture.asset(
  //                                       assets.u,
  //                                       width: 19,
  //                                       height: 19,
  //                                       color: colorsConst.primary,
  //                                     )),
  //                                 IconButton(
  //                                     onPressed: () {},
  //                                     icon: SvgPicture.asset(
  //                                       assets.fileFilter,
  //                                       width: 17,
  //                                       height: 17,
  //                                       color: colorsConst.primary,
  //                                     )),
  //                                 // IconButton(
  //                                 //     onPressed: (){},
  //                                 //     icon:SvgPicture.asset(assets.textFilter,width: 17,height: 17,)
  //                                 // ),
  //                                 IconButton(
  //                                     onPressed: () {
  //                                       utils.chooseFile(mediaDataV:imageController.empMediaData,
  //                                           fileName:imageController.empFileName,
  //                                           pathName:imageController.photo1);
  //                                     },
  //                                     icon: SvgPicture.asset(assets.file,color: colorsConst.primary,)),
  //                                 IconButton(
  //                                     onPressed: () {},
  //                                     icon: SvgPicture.asset(
  //                                       assets.layer,
  //                                       width: 17,
  //                                       height: 17,
  //                                       color: colorsConst.primary,
  //                                     )),
  //                                 IconButton(
  //                                     onPressed: () {},
  //                                     icon: SvgPicture.asset(assets.a,color: colorsConst.primary,)),
  //                               ],
  //                             ),
  //                           ),
  //                           Obx(() => CustomLoadingButton(
  //                             callback: () {
  //                               if(apiService.prospectsList.isEmpty){
  //                                 apiService.errorDialog(
  //                                     context, "Please Select range to send email.");
  //                                 controllers.emailCtr.reset();
  //                                 return;
  //                               }
  //                               List<Map<String, String>> withMail = apiService.prospectsList.where((e) {
  //                                 final mail = e["mail_id"];
  //                                 return mail != null && mail.trim().isNotEmpty && mail.trim() != "null";
  //                               }).toList();
  //                               // if(withMail.length>100){
  //                               //   Navigator.of(context).pop();
  //                               //   apiService.errorDialog(
  //                               //       context, "Select only 100 customers at a time for email.");
  //                               //   return;
  //                               // }
  //                               apiService.bulkEmailAPI(context, withMail, imageController.photo1.value);
  //                               focusNode.requestFocus();
  //                             },
  //                             controller: controllers.emailCtr,
  //                             isImage: false,
  //                             isLoading: true,
  //                             backgroundColor: colorsConst.primary,
  //                             radius: 5,
  //                             width: controllers.emailCount.value == 0 ||
  //                                 controllers.emailCount.value == 1
  //                                 ? 90
  //                                 : 200,
  //                             height: 50,
  //                             text: controllers.emailCount.value == 0
  //                                 ? "Quotation"
  //                                 : controllers.emailCount.value == 1
  //                                 ? "Reply"
  //                                 : "Reply & Quotation",
  //                             textColor: Colors.white,
  //                           ),
  //                           )
  //                         ],
  //                       )
  //                     ],
  //                   ),
  //                 ],
  //                 content: SizedBox(
  //                     width: 650,
  //                     height: 400,
  //                     child: SingleChildScrollView(
  //                       child: Column(
  //                         children: [
  //                           Align(
  //                               alignment: Alignment.topRight,
  //                               child: InkWell(
  //                                   onTap: () {
  //                                     Navigator.pop(context);
  //                                   },
  //                                   child: Icon(
  //                                     Icons.clear,
  //                                     size: 18,
  //                                     color: colorsConst.textColor,
  //                                   ))),
  //                           // Align(
  //                           //   alignment: Alignment.topRight,
  //                           //   child: TextButton(
  //                           //       onPressed: () {
  //                           //         controllers.isTemplate.value =
  //                           //         !controllers.isTemplate.value;
  //                           //       },
  //                           //       child: CustomText(
  //                           //         text: "Get Form Template",
  //                           //         colors: colorsConst.third,
  //                           //         size: 18,
  //                           //         isBold: true,
  //                           //       )),
  //                           // ),
  //                           // Row(
  //                           //   children: [
  //                           //     CustomText(
  //                           //       textAlign: TextAlign.center,
  //                           //       text: "To",
  //                           //       colors: colorsConst.textColor,
  //                           //       size: 15,
  //                           //     ),
  //                           //     50.width,
  //                           //     SizedBox(
  //                           //       width: 500,
  //                           //       child: TextField(
  //                           //         controller: controllers.emailToCtr,
  //                           //         style: TextStyle(
  //                           //             fontSize: 15, color: colorsConst.textColor),
  //                           //         decoration: const InputDecoration(
  //                           //           border: InputBorder.none,
  //                           //         ),
  //                           //       ),
  //                           //     )
  //                           //   ],
  //                           // ),
  //
  //                           SizedBox(
  //                               width: 650,
  //                               child: SingleChildScrollView(
  //                                 child: Column(
  //                                   children: [
  //                                     SizedBox(
  //                                       height: 40,
  //                                       width: 650,
  //                                       child: Obx(() {
  //                                         final ranges = controllers.leadRanges;
  //                                         if (ranges.isEmpty) {
  //                                           return const Center(child: Text("No leads found"));
  //                                         }
  //                                         return ListView.builder(
  //                                           itemCount: ranges.length,
  //                                           scrollDirection: Axis.horizontal,
  //                                           itemBuilder: (context, index) {
  //                                             final range = ranges[index];
  //                                             final isSelected = selectedRange.value == range;
  //                                             return InkWell(
  //                                               onTap: () {
  //                                                 setState((){
  //                                                   selectRange(range, controllers.allNewLeadFuture);
  //                                                 }
  //                                                 );
  //                                                 final leads = controllers.getLeadsByRange(index);
  //                                                 // here open another dialog to show leads
  //                                                 // showDialog(
  //                                                 //   context: context,
  //                                                 //   builder: (context) {
  //                                                 //     return AlertDialog(
  //                                                 //       title: Text("Leads in $range"),
  //                                                 //       content: SizedBox(
  //                                                 //         height: 300,
  //                                                 //         width: 400,
  //                                                 //         child: ListView.builder(
  //                                                 //           itemCount: leads.length,
  //                                                 //           itemBuilder: (context, i) {
  //                                                 //             final lead = leads[i];
  //                                                 //             return ListTile(
  //                                                 //               title: Text(lead.firstname ?? ""),
  //                                                 //               subtitle: Text(lead.mobileNumber ?? ""),
  //                                                 //             );
  //                                                 //           },
  //                                                 //         ),
  //                                                 //       ),
  //                                                 //     );
  //                                                 //   },
  //                                                 // );
  //                                               },
  //                                               child: Container(
  //                                                 height: 44,
  //                                                 margin: const EdgeInsets.all(5),
  //                                                 padding: const EdgeInsets.all(5),
  //                                                 decoration: BoxDecoration(
  //                                                   color: isSelected ? Colors.blue : Colors.transparent,
  //                                                   borderRadius: BorderRadius.circular(8),
  //                                                   border: Border.all(color: Colors.blue),
  //                                                 ),
  //                                                 child: Center(child: CustomText(text: range,colors: isSelected ?Colors.white:colorsConst.textColor,)),
  //                                               ),
  //                                             );
  //                                           },
  //                                         );
  //                                       }),
  //                                     ),
  //                                     10.height,
  //                                     Row(
  //                                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                                       children: [
  //                                         CustomText(
  //                                           text: "Total Selected Customers: $total",
  //                                           colors: colorsConst.textColor,
  //                                           size: 16,
  //                                           isBold: true,
  //                                         ),
  //                                         CustomText(
  //                                           text: "Customers with Mail: $withMail",
  //                                           colors: colorsConst.textColor,
  //                                           size: 16,
  //                                           isBold: true,
  //                                         ),
  //                                         CustomText(
  //                                           text: "Customers without Mail: $withoutMail",
  //                                           colors: colorsConst.textColor,
  //                                           size: 16,
  //                                           isBold: true,
  //                                         ),
  //                                       ],
  //                                     ),
  //                                     10.height,
  //                                     Divider(
  //                                       color: Colors.grey.shade300,
  //                                       thickness: 1,
  //                                     ),
  //                                     Row(
  //                                       children: [
  //                                         15.height,
  //                                         CustomText(
  //                                           text: "Subject",
  //                                           colors: colorsConst.textColor,
  //                                           size: 14,
  //                                         ),
  //                                         10.width,
  //                                         SizedBox(
  //                                           width: 500,
  //                                           height: 50,
  //                                           child: TextField(
  //                                             controller: controllers.emailSubjectCtr,
  //                                             maxLines: null,
  //                                             minLines: 1,
  //                                             style: TextStyle(
  //                                               color: colorsConst.textColor,
  //                                             ),
  //                                             decoration: const InputDecoration(
  //                                               border: InputBorder.none,
  //                                             ),
  //                                           ),
  //                                         )
  //                                       ],
  //                                     ),
  //                                     Divider(
  //                                       color: Colors.grey.shade300,
  //                                       thickness: 1,
  //                                     ),
  //                                     SingleChildScrollView(
  //                                       child: Column(
  //                                         children: [
  //                                           Obx(()=>imageController.photo1.value.isEmpty?0.height:
  //                                           Image.memory(base64Decode(imageController.photo1.value),
  //                                             fit: BoxFit.cover,width: 80,height: 80,),),
  //                                           SizedBox(
  //                                             width: 650,
  //                                             height: 223,
  //                                             child: TextField(
  //                                               textInputAction: TextInputAction.newline,
  //                                               controller: controllers.emailMessageCtr,
  //                                               keyboardType: TextInputType.multiline,
  //                                               maxLines: 21,
  //                                               expands: false,
  //                                               style: TextStyle(
  //                                                 color: colorsConst.textColor,
  //                                               ),
  //                                               decoration: InputDecoration(
  //                                                 hintText: "Message",
  //                                                 hintStyle: TextStyle(
  //                                                     color: colorsConst.textColor,
  //                                                     fontSize: 14,
  //                                                     fontFamily: "Lato"),
  //                                                 border: InputBorder.none,
  //                                               ),
  //                                             ),
  //                                           ),
  //                                         ],
  //                                       ),
  //                                     )
  //                                     //     : UnconstrainedBox(
  //                                     //   child: Container(
  //                                     //     width: 500,
  //                                     //     alignment: Alignment.center,
  //                                     //     decoration: BoxDecoration(
  //                                     //       color: colorsConst.secondary,
  //                                     //       borderRadius:
  //                                     //       BorderRadius.circular(10),
  //                                     //     ),
  //                                     //     child: SingleChildScrollView(
  //                                     //       child: Column(
  //                                     //         children: [
  //                                     //           SizedBox(
  //                                     //             width: 500,
  //                                     //             height: 210,
  //                                     //             child: Table(
  //                                     //               defaultColumnWidth:
  //                                     //               const FixedColumnWidth(
  //                                     //                   120.0),
  //                                     //               border: TableBorder.all(
  //                                     //                   color: Colors
  //                                     //                       .grey.shade300,
  //                                     //                   style:
  //                                     //                   BorderStyle.solid,
  //                                     //                   borderRadius:
  //                                     //                   BorderRadius
  //                                     //                       .circular(10),
  //                                     //                   width: 1),
  //                                     //               children: [
  //                                     //                 TableRow(
  //                                     //                     children: [
  //                                     //                       CustomText(
  //                                     //                         textAlign: TextAlign.center,
  //                                     //                         text: "\nTemplate Name\n",
  //                                     //                         colors: colorsConst.textColor,
  //                                     //                         size: 15,
  //                                     //                         isBold: true,
  //                                     //                       ),
  //                                     //                       CustomText(
  //                                     //                         textAlign:
  //                                     //                         TextAlign.center,
  //                                     //                         text: "\nSubject\n",
  //                                     //                         colors: colorsConst
  //                                     //                             .textColor,
  //                                     //                         size: 15,
  //                                     //                         isBold: true,
  //                                     //                       ),
  //                                     //                     ]),
  //                                     //                 utils.emailRow(
  //                                     //                     context,
  //                                     //                     isCheck: controllers.isAdd,
  //                                     //                     templateName:
  //                                     //                     "Promotional",
  //                                     //                     msg:
  //                                     //                     "Dear $name,\n \nWe hope this email finds you in good spirits.\n \nWe are excited to announce a special promotion exclusively for you! [Briefly describe the promotion, e.g., discount, free trial, bundle offer, etc.]. This offer is available for a limited time only, so be sure to take advantage of it while you can!\n \nAt $coName, we strive to provide our valued customers with exceptional value and service. We believe this promotion will further enhance your experience with us.\n \nDo not miss out on this fantastic opportunity! [Include a call-to-action, e.g., \"Shop now,\" \"Learn more,\" etc.]\n \nThank you for your continued support. We look forward to serving you.\n \nWarm regards,\n \nAnjali\nManager\n$mobile",
  //                                     //                     subject:
  //                                     //                     "Exclusive Promotion for You - \nLimited Time Offer!"),
  //                                     //                 utils.emailRow(
  //                                     //                     context,
  //                                     //                     isCheck: controllers.isAdd,
  //                                     //                     templateName: "Follow-Up",
  //                                     //                     msg: "Dear $name,\n \nI hope this email finds you well.\n \nI wanted to follow up on our recent interaction regarding [briefly mention the nature of the interaction, e.g., service request, inquiry, etc.]. We value your feedback and are committed to ensuring your satisfaction.\n \nPlease let us know if everything is proceeding smoothly on your end, or if there are any further questions or concerns you like to address. Our team is here to assist you every step of the way.\n \nThank you for choosing $coName. We appreciate the opportunity to serve you.\n \nBest regards,\n \nAnjali\nManager\n$mobile",
  //                                     //                     subject: "Follow-up on Recent Service Interaction"),
  //                                     //                 utils.emailRow(context,
  //                                     //                     msg:
  //                                     //                     "Dear $name,\n \nWe hope this email finds you well.\n \nWe are writing to inform you of an update regarding our services. [Briefly describe the update or enhancement]. We believe this will [mention the benefit or improvement for the customer].\n \nPlease feel free to [contact us/reach out] if you have any questions or need further assistance regarding this update.\n \nThank you for choosing $coName. We appreciate your continued support.\n \nBest regards,\n \nAnjali\nManager\n$mobile",
  //                                     //                     isCheck:
  //                                     //                     controllers.isAdd,
  //                                     //                     templateName:
  //                                     //                     "Service Update",
  //                                     //                     subject:
  //                                     //                     "Service Update - [Brief Description]"),
  //                                     //               ],
  //                                     //             ),
  //                                     //           ),
  //                                     //           // 10.height,
  //                                     //           // CustomLoadingButton(
  //                                     //           //   callback: (){},
  //                                     //           //   isImage: false,
  //                                     //           //   isLoading: false,
  //                                     //           //   backgroundColor: colorsConst.primary,
  //                                     //           //   radius: 20,
  //                                     //           //   width: 70,
  //                                     //           //   height: 30,
  //                                     //           //   text: "Done",
  //                                     //           //   textColor: Colors.white,
  //                                     //           //
  //                                     //           // ),
  //                                     //         ],
  //                                     //       ),
  //                                     //     ),
  //                                     //   ),
  //                                     // ),
  //
  //                                   ],
  //                                 ),
  //                               )),
  //                         ],
  //                       ),
  //                     )),
  //               );
  //             });
  //       });
  // }


  void sendEmailDialog(
      {required String id,
      required String name,
      required String mobile,
      required String coName}) {
    showDialog(
        context: Get.context!,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            actions: [
              Column(
                children: [
                  Divider(
                    color: Colors.grey.shade300,
                    thickness: 1,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Row(
                          children: [
                            IconButton(
                                onPressed: () {},
                                icon: SvgPicture.asset(assets.b,
                                    width: 17, height: 17)),
                            IconButton(
                                onPressed: () {},
                                icon: SvgPicture.asset(
                                  assets.i,
                                  width: 15,
                                  height: 15,
                                )),
                            IconButton(
                                onPressed: () {},
                                icon: SvgPicture.asset(
                                  assets.u,
                                  width: 19,
                                  height: 19,
                                )),
                            IconButton(
                                onPressed: () {},
                                icon: SvgPicture.asset(
                                  assets.fileFilter,
                                  width: 17,
                                  height: 17,
                                )),
                            // IconButton(
                            //     onPressed: (){},
                            //     icon:SvgPicture.asset(assets.textFilter,width: 17,height: 17,)
                            // ),
                            IconButton(
                                onPressed: () {
                                  utils.chooseFile(
                                      mediaDataV: imageController.empMediaData,
                                      fileName: imageController.empFileName,
                                      pathName: imageController.photo1);
                                },
                                icon: SvgPicture.asset(assets.file)),
                            IconButton(
                                onPressed: () {},
                                icon: SvgPicture.asset(
                                  assets.layer,
                                  width: 17,
                                  height: 17,

                                )),
                            IconButton(
                                onPressed: () {},
                                icon: SvgPicture.asset(assets.a)),
                          ],
                        ),
                      ),
                      Obx(
                        () => CustomLoadingButton(
                          callback: () {
                            apiService.insertEmailAPI(context, id.toString(),
                                imageController.photo1.value);
                          },
                          controller: controllers.emailCtr,
                          isImage: false,
                          isLoading: true,
                          backgroundColor: colorsConst.primary,
                          radius: 5,
                          width: controllers.emailCount.value == 0 ||
                                  controllers.emailCount.value == 1
                              ? 90
                              : 200,
                          height: 50,
                          text: controllers.emailCount.value == 0
                              ? "Quotation"
                              : controllers.emailCount.value == 1
                                  ? "Reply"
                                  : "Reply & Quotation",
                          textColor: Colors.white,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ],
            content: SizedBox(
                width: 600,
                height: 400,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Align(
                          alignment: Alignment.topRight,
                          child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(
                                Icons.clear,
                                size: 18,
                                color: colorsConst.textColor,
                              ))),
                      Align(
                        alignment: Alignment.topRight,
                        child: TextButton(
                            onPressed: () {
                              controllers.isTemplate.value =
                                  !controllers.isTemplate.value;
                            },
                            child: CustomText(
                              text: "Get Form Template",
                              colors: colorsConst.third,
                              size: 18,
                              isBold: true,
                            )),
                      ),
                      Row(
                        children: [
                          CustomText(
                            textAlign: TextAlign.center,
                            text: "To",
                            colors: colorsConst.textColor,
                            size: 15,
                          ),
                          50.width,
                          SizedBox(
                            width: 500,
                            child: TextField(
                              controller: controllers.emailToCtr,
                              style: TextStyle(
                                  fontSize: 15, color: colorsConst.textColor),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                          width: 600,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Divider(
                                  color: Colors.grey.shade300,
                                  thickness: 1,
                                ),
                                Row(
                                  children: [
                                    15.height,
                                    CustomText(
                                      text: "Subject",
                                      colors: colorsConst.textColor,
                                      size: 14,
                                    ),
                                    20.width,
                                    SizedBox(
                                      width: 500,
                                      height: 50,
                                      child: TextField(
                                        controller: controllers.emailSubjectCtr,
                                        maxLines: null,
                                        minLines: 1,
                                        style: TextStyle(
                                          color: colorsConst.textColor,
                                        ),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Divider(
                                  color: Colors.grey.shade300,
                                  thickness: 1,
                                ),
                                Obx(() => controllers.isTemplate.value == false
                                      ? SingleChildScrollView(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Obx(() => imageController.photo1.value.isEmpty
                                                    ? 0.height
                                                    :Container(
                                                  height: 40,
                                                  padding: EdgeInsets.fromLTRB(8, 5, 8, 5),
                                                  child: Row(
                                                    children: [
                                                      Obx(()=>CustomText(text: imageController.empFileName.value))
                                                    ],
                                                  ),
                                                )
                                                    // : Image.memory(
                                                    //     base64Decode(
                                                    //         imageController
                                                    //             .photo1.value),
                                                    //     fit: BoxFit.cover,
                                                    //     width: 80,
                                                    //     height: 80,
                                                    //   ),
                                              ),
                                              SizedBox(
                                                width: 600,
                                                height: 223,
                                                child: TextField(
                                                  textInputAction: TextInputAction.newline,
                                                  controller: controllers.emailMessageCtr,
                                                  keyboardType: TextInputType.multiline,
                                                  maxLines: 21,
                                                  expands: false,
                                                  style: TextStyle(
                                                    color: colorsConst.textColor,
                                                  ),
                                                  decoration: InputDecoration(
                                                    hintText: "Message",
                                                    hintStyle: TextStyle(
                                                        color: colorsConst
                                                            .textColor,
                                                        fontSize: 14,
                                                        fontFamily: "Lato"),
                                                    border: InputBorder.none,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : UnconstrainedBox(
                                          child: Container(
                                            width: 500,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: colorsConst.secondary,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: SingleChildScrollView(
                                              child: Column(
                                                children: [
                                                  SizedBox(
                                                    width: 500,
                                                    height: 210,
                                                    child: Table(
                                                      defaultColumnWidth:
                                                          const FixedColumnWidth(
                                                              120.0),
                                                      border: TableBorder.all(
                                                          color: Colors
                                                              .grey.shade300,
                                                          style: BorderStyle.solid,
                                                          borderRadius: BorderRadius.circular(10),
                                                          width: 1),
                                                      children: [
                                                        TableRow(
                                                            children: [
                                                          CustomText(
                                                            textAlign: TextAlign.center,
                                                            text: "\nTemplate Name\n",
                                                            colors: colorsConst.textColor,
                                                            size: 15,
                                                            isBold: true,
                                                          ),
                                                          CustomText(
                                                            textAlign: TextAlign.center,
                                                            text: "\nSubject\n",
                                                            colors: colorsConst.textColor,
                                                            size: 15,
                                                            isBold: true,
                                                          ),
                                                        ]),
                                                        utils.emailRow(context,
                                                            isCheck: controllers.isAdd,
                                                            templateName: "Promotional",
                                                            msg: "Dear $name,\n \nWe hope this email finds you in good spirits.\n \nWe are excited to announce a special promotion exclusively for you! [Briefly describe the promotion, e.g., discount, free trial, bundle offer, etc.]. This offer is available for a limited time only, so be sure to take advantage of it while you can!\n \nAt $coName, we strive to provide our valued customers with exceptional value and service. We believe this promotion will further enhance your experience with us.\n \nDo not miss out on this fantastic opportunity! [Include a call-to-action, e.g., \"Shop now,\" \"Learn more,\" etc.]\n \nThank you for your continued support. We look forward to serving you.\n \nWarm regards,\n \nAnjali\nManager\n$mobile",
                                                            subject: "Exclusive Promotion for You - \nLimited Time Offer!"),
                                                        utils.emailRow(context,
                                                            isCheck: controllers.isAdd,
                                                            templateName: "Follow-Up",
                                                            msg: "Dear $name,\n \nI hope this email finds you well.\n \nI wanted to follow up on our recent interaction regarding [briefly mention the nature of the interaction, e.g., service request, inquiry, etc.]. We value your feedback and are committed to ensuring your satisfaction.\n \nPlease let us know if everything is proceeding smoothly on your end, or if there are any further questions or concerns you like to address. Our team is here to assist you every step of the way.\n \nThank you for choosing $coName. We appreciate the opportunity to serve you.\n \nBest regards,\n \nAnjali\nManager\n$mobile",
                                                            subject: "Follow-up on Recent Service Interaction"),
                                                        utils.emailRow(context,
                                                            msg: "Dear $name,\n \nWe hope this email finds you well.\n \nWe are writing to inform you of an update regarding our services. [Briefly describe the update or enhancement]. We believe this will [mention the benefit or improvement for the customer].\n \nPlease feel free to [contact us/reach out] if you have any questions or need further assistance regarding this update.\n \nThank you for choosing $coName. We appreciate your continued support.\n \nBest regards,\n \nAnjali\nManager\n$mobile",
                                                            isCheck: controllers.isAdd,
                                                            templateName: "Service Update",
                                                            subject: "Service Update - [Brief Description]"),
                                                      ],
                                                    ),
                                                  ),
                                                  // 10.height,
                                                  // CustomLoadingButton(
                                                  //   callback: (){},
                                                  //   isImage: false,
                                                  //   isLoading: false,
                                                  //   backgroundColor: colorsConst.primary,
                                                  //   radius: 20,
                                                  //   width: 70,
                                                  //   height: 30,
                                                  //   text: "Done",
                                                  //   textColor: Colors.white,
                                                  //
                                                  // ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                )
                              ],
                            ),
                          )),
                    ],
                  ),
                )),
          );
        });
  }

  void showComposeMail(BuildContext context) {
    controllers.emailSubjectCtr.clear();
    final formatProvider = Provider.of<ReminderProvider>(context, listen: false);
    formatProvider.resetFormatting();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          child: Consumer<ReminderProvider>(
            builder: (context, formatProvider, child) {
              return Container(
                width: 650,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Compose Mail",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 15, color: Colors.black),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    Divider(color: Colors.grey.shade300),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const SizedBox(
                            width: 70,
                            child: Text("To",
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold))),
                        Expanded(
                          child: TextFormField(
                            controller: controllers.emailToCtr,
                            style: const TextStyle(fontSize: 14),
                            decoration: const InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              hintText: "",
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                    10.height,
                    Divider(color: Colors.grey.shade300),
                    10.height,
                    Row(
                      children: [
                        const SizedBox(
                            width: 70,
                            child: Text("CC",
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold))),
                        Expanded(
                          child: TextFormField(
                            style: const TextStyle(fontSize: 14),
                            decoration: const InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              hintText: "",
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                    10.height,
                    Divider(color: Colors.grey.shade300),
                    10.height,
                    Row(
                      children: [
                        const SizedBox(
                          width: 70,
                          child: Text(
                            "Subject",
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: Stack(
                            alignment: Alignment.centerRight,
                            children: [
                              InkWell(
                                onTap: () async {
                                  if (formatProvider.isLink && controllers.emailSubjectCtr.text.isNotEmpty) {
                                    final text = controllers.emailSubjectCtr.text.trim();
                                    final url = text.startsWith("http") ? text : "https://$text";
                                    final uri = Uri.parse(url);
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                                    }
                                  }
                                },
                                child: IgnorePointer(
                                  ignoring: formatProvider.isLink,
                                  child: TextFormField(
                                    controller: controllers.emailSubjectCtr,
                                    readOnly: formatProvider.isLink,
                                    style: formatProvider.subjectTextStyle,
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      border: InputBorder.none,
                                      hintText: "",
                                      contentPadding: EdgeInsets.only(right: 30),
                                    ),
                                  ),
                                ),
                              ),
                              if (formatProvider.isLink)
                                IconButton(
                                  icon: const Icon(Icons.close, size: 18, color: Colors.red),
                                  onPressed: () {
                                    controllers.emailSubjectCtr.clear();
                                    formatProvider.removeLink();
                                  },
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    10.height,
                    Divider(color: Colors.grey.shade300),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.format_bold,
                            size: 20,
                            color: Colors.black87, // always black
                          ),
                          onPressed: () {
                            formatProvider.toggleBold();
                          },
                        ),

                        IconButton(
                          icon: Icon(
                            Icons.format_italic,
                            size: 20,
                            color: Colors.black87,
                          ),
                          onPressed: () => formatProvider.toggleItalic(),
                        ),

                        IconButton(
                          icon: Icon(
                            Icons.format_underline,
                            size: 20,
                            color: Colors.black87,
                          ),
                          onPressed: () => formatProvider.toggleUnderline(),
                        ),

                        IconButton(
                          icon: const Icon(Icons.link, size: 20, color: Colors.black87),
                          onPressed: () {
                            if (controllers.emailSubjectCtr.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Subject is empty!")),
                              );
                              return;
                            }
                            formatProvider.toggleLink();
                          },
                        ),

                      ],
                    ),
                    10.height,
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextField(
                        maxLines: null,
                        expands: true,
                        controller: controllers.emailMessageCtr,
                        style: TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(8),
                          border: InputBorder.none,
                          hintText: "",
                        ),
                      ),
                    ),
                   14.height,
                     InkWell(
                       onTap: (){
                          utils.chooseFile(
                              mediaDataV: imageController.empMediaData,
                              fileName: imageController.empFileName,
                              pathName: imageController.photo1);
                       },
                       child: Row(
                        children: [
                          Icon(Icons.attach_file, size: 18, color: Colors.black),
                          SizedBox(width: 6),
                          Text("Attach File",
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                                           ),
                     ),
                    10.height,
                    Obx(() => imageController.photo1.value.isEmpty
                        ? 0.height
                        :  Container( padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xff86BAE3FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Obx(()=>CustomText(text: imageController.empFileName.value)),
                          SizedBox(width: 10,),
                          IconButton( padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              imageController.photo1.value = "";
                            }, icon: const Icon(Icons.close, size: 10),
                          ),
                        ],
                      ),
                    ),),
                    Divider(color: Colors.grey.shade300),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        10.width,
                        Row(
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.black87,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                              ),
                              child: const Text("Discard",
                                  style: TextStyle(
                                      fontSize: 13, fontWeight: FontWeight.bold)),
                            ),
                            8.width,
                            CustomLoadingButton(
                              callback: () {
                                if(controllers.emailSubjectCtr.text.trim().isEmpty){
                                  snackBar(context: context, msg: "Subject is empty!", color: Colors.red);
                                  return;
                                }
                                if(controllers.emailMessageCtr.text.trim().isEmpty){
                                  snackBar(context: context, msg: "Message is empty!", color: Colors.red);
                                  return;
                                }
                                apiService.insertEmailAPI(context, "1",
                                    imageController.photo1.value);
                              },
                              controller: controllers.emailCtr,
                              isImage: false,
                              isLoading: true,
                              backgroundColor: colorsConst.primary,
                              radius: 5,
                              width: controllers.emailCount.value == 0 ||
                                  controllers.emailCount.value == 1
                                  ? 90
                                  : 200,
                              height: 50,
                              text:"Save",
                              textColor: Colors.white,
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  makingWebsite({String? web}) async {
    final url = Uri.parse('https://www.$web.com');
    if (!await launchUrl(url, mode: LaunchMode.inAppWebView)) {
      throw Exception('Could not launch $url');
    }
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> snackBar({required BuildContext context,
  required String msg,
  required Color color}) {
    var snack = SnackBar(
      width: 500,
      content: Center(child: Text(msg)),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 4),
      backgroundColor: color,
      elevation: 5,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    );
    return rootScaffoldMessengerKey.currentState!.showSnackBar(snack);
  }
  Future<bool> showExitDialog(BuildContext context) async {
    bool? exit = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text("Do you want to exit?", style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: colorsConst.textColor,
        ),),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              side: BorderSide(
                  color: colorsConst.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: Text(
              "No",
              style: TextStyle(
                color: colorsConst.primary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorsConst.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: const Text(
              "Yes",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    return exit ?? false;
  }

  Widget paginationButton(IconData icon, bool isEnabled, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        icon: Icon(icon, color: colorsConst.textColor),
        onPressed: isEnabled ? onPressed : null,
        // onLongPress: (){
        //   _focusNode.requestFocus();
        // },
      ),
    );
  }

  List<Widget> buildPagination(int totalPages, int currentPage) {
    const maxVisiblePages = 5;
    List<Widget> pageButtons = [];

    int startPage = (currentPage - (maxVisiblePages ~/ 2)).clamp(1, totalPages);
    int endPage = (startPage + maxVisiblePages - 1).clamp(1, totalPages);

    if (startPage > 1) {
      pageButtons.add(pageButton(1, currentPage));
      if (startPage > 2) {
        pageButtons.add(ellipsis());
      }
    }

    for (int i = startPage; i <= endPage; i++) {
      pageButtons.add(pageButton(i, currentPage));
    }

    if (endPage < totalPages) {
      if (endPage < totalPages - 1) {
        pageButtons.add(ellipsis());
      }
      pageButtons.add(pageButton(totalPages, currentPage));
    }

    return pageButtons;
  }

  Widget pageButton(int pageNum, int currentPage) {
    bool isCurrent = pageNum == currentPage;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          controllers.currentPage.value = pageNum;
        },
        onLongPress: (){
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isCurrent ? colorsConst.primary : colorsConst.secondary,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            //pageNum.toString().padLeft(2, '0'),
            pageNum.toString(),
            style: TextStyle(
              color: isCurrent ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget ellipsis() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Text('...', style: TextStyle(fontSize: 18, color: Colors.black)),
    );
  }

  Widget selectHeatingType(
      String text,
      bool isSelected,
      VoidCallback onTap,
      bool isLast,
      RxString count,
      ) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          CustomText(
            text: text,
            colors: isSelected ? colorsConst.primary : colorsConst.textColor,
            isBold: true,
            size: 15,
          ),
          10.width,
          CircleAvatar(
            backgroundColor:
            isSelected ? colorsConst.primary : colorsConst.secondary,
            radius: 15,
            child: Obx(
                  () => CustomText(
                text: count.value,
                colors: isSelected ? Colors.white : colorsConst.primary,
                size: 15,
              ),
            ),
          ),
          10.width,
          isLast
              ? 0.height
              : Container(
            width: 1,
            height: 22,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
  Widget leadText({String? text, Color? color}) {
    return CustomText(
      textAlign: TextAlign.start,
      text: text.toString(),
      size: 14,
      colors: color,
      isBold: true,
    );
  }

  Widget textFieldNearText(String text, bool isOptional) {
    return Container(
      height: 50,
      alignment: Alignment.center,
      child: Row(
        children: [
          CustomText(
            text: text,
            textAlign: TextAlign.start,
            colors: colorsConst.headColor,
            size: 15,
          ),
          isOptional == true
              ? const CustomText(
                  text: "*",
                  colors: Colors.red,
                  size: 25,
                )
              : 0.width
        ],
      ),
    );
  }

  Widget funnelContainer(BuildContext context) {
    return Obx(()=>controllers.isRightOpen.value?SizedBox(
      width: 250,
      height: MediaQuery.of(context).size.height,
      child: Row(
        children: [
          VerticalDivider(
            thickness: 2,
            color: colorsConst.secondary,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 150.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Tooltip(
                      message: "Click to close the side panel.",
                      child: Obx(() => InkWell(
                        focusColor: Colors.transparent,
                        onTap: () {
                          controllers.isRightOpen.value = !controllers.isRightOpen.value;
                        },
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: colorsConst.secondary,
                          child: Icon(
                            controllers.isRightOpen.value
                                ? Icons.chevron_right
                                : Icons.chevron_left,
                            color: Colors.black,
                            size: 18,
                          ),
                        ),
                      )),
                    ),
                    40.width,

                  ],
                ),
              ),
              IgnorePointer(
                child: CustomText(
                  text: "Lead Stages",
                  colors: Colors.black,
                  size: 16,
                  isBold: true,
                ),
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: (){
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                        const Suspects(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  },
                  child: Stack(
                    children: [
                      Obx(() => Image.asset(
                          controllers.selectedIndex.value == 1
                              ? "assets/images/sSuspects.png"
                              : "assets/images/suspects.png",
                              width: 220,
                        ),
                      ),
                      Positioned(
                          left: 85,
                          bottom: 15,
                          child: Obx(() => Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IgnorePointer(
                                child: CustomText(
                                    text: "${controllers.leadCategoryList.isEmpty ? "" : controllers.leadCategoryList[0]["value"]}",
                                    colors: controllers.selectedIndex.value == 1
                                        ? Colors.black
                                        : colorsConst.textColor,
                                    size: 15,
                                    //isBold: true,
                                  ),
                              ),
                              IgnorePointer(
                                child: CustomText(
                                  text: "${controllers.allNewLeadsLength.value}",
                                  colors: controllers.selectedIndex.value == 1
                                      ? colorsConst.primary
                                      : colorsConst.primary,
                                  size: 16,
                                  isBold: true,
                                ),
                              ),
                            ],
                          ),
                          )
                      )
                    ],
                  ),
                ),
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: (){
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                        const Prospects(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  },
                  child: Stack(
                    children: [
                      Obx(() => Image.asset(
                          controllers.selectedIndex.value == 2
                              ? "assets/images/sProspects.png"
                              : "assets/images/prospects.png",

                        ),
                      ),
                      Positioned(
                          left: 75,
                          bottom: 15,
                          child: Obx(() => Column(
                            children: [
                              IgnorePointer(
                                child: CustomText(
                                    text: "${controllers.leadCategoryList.isEmpty ? "" : controllers.leadCategoryList[1]["value"]}",
                                    colors: controllers.selectedIndex.value == 2
                                        ? Colors.black
                                        : colorsConst.textColor,
                                    size: 15,
                                    //isBold: true,
                                  ),
                              ),
                              IgnorePointer(
                                child: CustomText(
                                  text: "${controllers.allLeadsLength.value}",
                                  colors: controllers.selectedIndex.value == 2
                                      ? colorsConst.primary
                                      : colorsConst.primary,
                                  size: 16,
                                  isBold: true,
                                ),
                              ),
                            ],
                          ),
                          ))
                    ],
                  ),
                ),
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: (){
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                        const Qualified(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  },
                  child: Stack(
                    children: [
                      Obx(() => Image.asset(
                          controllers.selectedIndex.value == 3
                              ? "assets/images/sQualified.png"
                              : "assets/images/qualified.png",
                              width: 200,
                        ),
                      ),
                      Positioned(
                          left: 70,
                          bottom: 30,
                          child: Obx(
                                () => Column(
                                  children: [
                                    IgnorePointer(
                                      child: CustomText(text:
                                      "${controllers.leadCategoryList.isEmpty ? "" : controllers.leadCategoryList[2]["value"]}",
                                                                colors: controllers.selectedIndex.value == 3
                                        ? Colors.black
                                        : colorsConst.textColor,
                                                                size: 15,
                                                                //isBold: true,
                                                              ),
                                    ),
                                    IgnorePointer(
                                      child: CustomText(text:
                                      "${controllers.allGoodLeadsLength.value}",
                                        colors: controllers.selectedIndex.value == 3
                                            ? colorsConst.primary
                                            : colorsConst.primary,
                                        size: 16,
                                        isBold: true,
                                      ),
                                    ),
                                  ],
                                ),
                          ))
                    ],
                  ),
                ),
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: (){
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                        const ViewCustomer(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  },
                  child: Stack(
                    children: [
                      Obx(() => Image.asset(
                          controllers.selectedIndex.value == 4
                              ? "assets/images/sCustomer.png"
                              : "assets/images/customer.png",
                        ),
                      ),
                      Positioned(
                          left: 20,
                          bottom: 35,
                          child: Obx(() => Column(
                            children: [
                              IgnorePointer(
                                child: CustomText(
                                    text: "Customers",
                                    colors: controllers.selectedIndex.value == 4
                                        ? Colors.black
                                        : colorsConst.textColor,
                                    size: 13,
                                    //isBold: true,
                                  ),
                              ),
                              IgnorePointer(
                                child: CustomText(
                                  text: "${controllers.allCustomerLength.value}",
                                  colors: controllers.selectedIndex.value == 4
                                      ? colorsConst.primary
                                      : colorsConst.primary,
                                  size: 13,
                                  isBold: true,
                                ),
                              ),
                            ],
                          ),
                          ))
                    ],
                  ),
                ),
              ),
              15.height
            ],
          )
        ],
      ),
    ):Container(
      width: 60,
      height: MediaQuery.of(context).size.height,
      color: colorsConst.backgroundColor,
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.fromLTRB(0, 10, 5, 0),
      child:Tooltip(
        message: "Click to view the side panel",
        child: InkWell(
            focusColor: Colors.transparent,
            onTap: (){
              controllers.isRightOpen.value=!controllers.isRightOpen.value;
            },
          child: CircleAvatar(
            backgroundColor: colorsConst.secondary,
            child: Icon(Icons.chevron_left,color: Colors.black,),
          ),
        ),
      ),
    ));
  }

  Future<void> timePicker({
    BuildContext? context,
    TextEditingController? textEditingController,
    RxString? pathVal,
  }) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context!,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      final String formattedTime =
      MaterialLocalizations.of(context).formatTimeOfDay(
        pickedTime,
        alwaysUse24HourFormat: false,
      );

      textEditingController?.text = formattedTime;
      pathVal?.value = formattedTime;
    }
  }
  Future<void> datePicker(
      {BuildContext? context,
      TextEditingController? textEditingController,
      RxString? pathVal}) async {
    controllers.dateTime =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    showDatePicker(
      context: context!,
      initialDate: controllers.dateTime,
      firstDate: DateTime(2010),
      lastDate: DateTime(2030),
    ).then((value) {
      controllers.dateTime = value!;
      textEditingController?.text =
          "${(controllers.dateTime.day.toString().padLeft(2, "0"))}.${(controllers.dateTime.month.toString().padLeft(2, "0"))}.${(controllers.dateTime.year.toString())}";
      pathVal?.value =
          "${(controllers.dateTime.day.toString().padLeft(2, "0"))}.${(controllers.dateTime.month.toString().padLeft(2, "0"))}.${(controllers.dateTime.year.toString())}";
    });
  }
  Future<void> chooseFile({RxList? mediaDataV, RxString? fileName, RxString? pathName}) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpeg', 'jpg'],
    );
    if (result != null) {
      fileName?.value = result.files.single.name;
      print("file name ${result.files.single.name}");
      mediaDataV?.value = result.files.single.bytes!.toList();
      pathName?.value = base64.encode(result.files.single.bytes!.toList());
    } else {
      print('No file selected');
    }
  }
  TableRow emailRow(BuildContext context,
      {RxBool? isCheck, String? templateName, String? subject, String? msg}) {
    return TableRow(
        decoration: BoxDecoration(color: colorsConst.secondary),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              10.width,
              SizedBox(
                width: 15,
                height: 15,
                child: Checkbox(
                  //materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  side: MaterialStateBorderSide.resolveWith(
                    (states) =>
                        BorderSide(width: 1.0, color: colorsConst.textColor),
                  ),
                  checkColor: Colors.white,
                  activeColor: colorsConst.third,
                  value: isCheck?.value,
                  onChanged: (value) {
                    controllers.isTemplate.value = false;
                    //Navigator.pop(context);
                    controllers.emailSubjectCtr.text =
                        subject.toString().replaceAll('\n', ' ');
                    //controllers.emailMessageCtr.text += "\n${msg.toString()}";
                    controllers.emailMessageCtr.text = msg.toString();
                    controllers.emailQuotationCtr.text =
                        templateName.toString();
                  },
                ),
              ),
              20.width,
              Container(
                alignment: Alignment.center,
                height: 50,
                child: CustomText(
                  textAlign: TextAlign.center,
                  text: templateName.toString(),
                  colors: colorsConst.textColor,
                  size: 13,
                ),
              ),
            ],
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
            height: 50,
            child: CustomText(
              textAlign: TextAlign.center,
              text: subject.toString(),
              colors: colorsConst.textColor,
              size: 13,
            ),
          ),
        ]);
  }

  void pickAndReadExcelFile(BuildContext context,String leadStatus) {
    final html.FileUploadInputElement input = html.FileUploadInputElement()
      ..accept = '.xlsx, .xls';
    input.click();
    input.onChange.listen((event) {
      if (input.files == null || input.files!.isEmpty) {
        debugPrint("User cancelled file selection.");
        controllers.customerCtr.reset();
        return;
      }

      final file = input.files!.first;
      final reader = html.FileReader();

      reader.readAsArrayBuffer(file);
      reader.onLoadEnd.listen((event) {
        Uint8List bytes = reader.result as Uint8List;
        parseExcelFile(bytes, context, leadStatus);
      });
    });
  }


  List<Map<String, dynamic>> customerData = [];
  List<Map<String, dynamic>> mCustomerData = [];

  void parseExcelFile(Uint8List bytes, BuildContext context, String leadStatus) async {
    customerData = [];
    controllers.customerCtr.start();
    var excelD = excel.Excel.decodeBytes(bytes);

    for (var table in excelD.tables.keys) {
      var rows = excelD.tables[table]!.rows;

      if (rows.length < 6) {
        Navigator.of(context).pop();
        apiService.errorDialog(context, "Excel format is invalid. Needs min 6 rows (3 empty, system, display, data).");
        return;
      }
      const expectedKeys = [
        "name", "phone_no", "email", "city", "owner", "designation", "department",
        "company_name", "source", "source_details", "lead_status", "prospect_enrollment_date",
        "expected_convertion_date", "details_of_service_required", "discussion_point",
        "product_discussion", "rating", "status_update", "status",
        "num_of_headcount", "expected_billing_value", "arpu_value", "expected_billing_value",
      ];
      // ✅ Row 4 = system keys
      List<String> systemKeys = rows[3]
          .map((c) => (c?.value?.toString().trim() ?? ""))
          .toList();

      if (systemKeys.every((e) => e.isEmpty)) {
        Navigator.of(context).pop();
        apiService.errorDialog(context, "Excel format invalid. Row 4 (system fields) cannot be empty.");
        return;
      }
      final missing = expectedKeys.where((key) => !systemKeys.contains(key)).toList();
      if (missing.isNotEmpty) {
        Navigator.of(context).pop();
        apiService.errorDialog(
          context,
          "Please enter correct system fields. Missing or incorrect: ${missing.join(', ')}",
        );
        return;
      }
      // ✅ Row 5 = display names
      List<String> displayNames = rows[4]
          .map((c) => (c?.value?.toString().trim() ?? ""))
          .toList();

      if (displayNames.every((e) => e.isEmpty)) {
        Navigator.of(context).pop();
        apiService.errorDialog(context, "Excel format invalid. Row 5 (display headings) cannot be empty.");
        return;
      }

      // 🔽 Build field mappings
      List<Map<String, String>> fieldMappings = [];
      for (int i = 0; i < systemKeys.length; i++) {
        if (systemKeys[i].isNotEmpty) {
          fieldMappings.add({
            "cos_id": controllers.storage.read("cos_id"),
            "system_field": systemKeys[i],
            "display_name": (i < displayNames.length && displayNames[i].isNotEmpty)
                ? displayNames[i]
                : systemKeys[i],
            "created_by": controllers.storage.read("id").toString(),
          });
        }
      }

      // 🔽 Parse data rows (from row 6 → index 5 onwards)
      for (var i = 5; i < rows.length; i++) {
        var row = rows[i];
        bool isRowEmpty = row.every((cell) =>
        cell == null || cell.value == null || cell.value.toString().trim().isEmpty);
        if (isRowEmpty) continue;

        Map<String, dynamic> formattedData = {};
        List<Map<String, String>> additionalFields = [];

        for (int j = 0; j < systemKeys.length; j++) {
          String key = systemKeys[j];
          var value = row[j]?.value?.toString().trim() ?? "";

          if (key.isNotEmpty) {
            formattedData[key] = value;
          } else {
            additionalFields.add({
              "field_name": (j < displayNames.length) ? displayNames[j] : "",
              "field_value": value,
            });
          }
        }

        formattedData["user_id"] = controllers.storage.read("id");
        formattedData["cos_id"] = controllers.storage.read("cos_id");
        formattedData["lead_status"] = leadStatus=="0"?"0":formattedData["lead_status"] ?? leadStatus;
        formattedData["additional_fields"] = additionalFields;

        customerData.add(formattedData);
      }

      // 🔽 Final Payload
      Map<String, dynamic> finalPayload = {
        "field_mappings": fieldMappings,
        "cusList": customerData,
      };

     // print("Payload: ${jsonEncode(finalPayload)}");

      await apiService.insertCustomersAPI(context, customerData, fieldMappings, bytes, "CRMSheet");
    }
  }

  Future<void> downloadSampleExcel() async {
    final data = await rootBundle.load("assets/easycrm_data_upload_template.xlsx");
    final blob = html.Blob([data.buffer.asUint8List()]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'easycrm_data_upload_template.xlsx')
      ..click();

    // Revoke after a short delay
    Future.delayed(const Duration(seconds: 1), () {
      html.Url.revokeObjectUrl(url);
    });
  }

  Future<void> downloadSheetImplementation(String fileName, Uint8List bodyBytes) async {
    final blob = html.Blob([bodyBytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();

    Future.delayed(const Duration(seconds: 1), () {
      html.Url.revokeObjectUrl(url);
    });
  }


  Future<void> downloadSheetFromNetwork(String fileUrl, String fileName) async {
    try {
      final response = await http.get(Uri.parse(fileUrl));
      if (response.statusCode == 200) {
        Uint8List bodyBytes = response.bodyBytes;
        await downloadSheetImplementation(fileName, bodyBytes);
      } else {
        downloadSampleExcel();
        print('Download failed: ${response.statusCode}');
      }
    } catch (e) {
      downloadSampleExcel();
      print('Error downloading file: $e');
    }
  }

  Future<void> showImportDialog(BuildContext context,String leadStatus) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.all(5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: SizedBox(
            width: 350,
            height: 340,
            child: SelectionArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: "File format: .xlsx, .xls",
                    colors: colorsConst.textColor,
                    size: 17,
                    isBold: true,
                  ),
                  10.height,
                  SizedBox(
                    width: 340,
                    child: Text(
                      "In this CRM template, \n\n1. Place your column names on Row 5. This will appear in EasyCRM as Heading.\n\n2. Place your data from Row 6. \n\n3. Pick the CRM internal field designators from Row 4 and place it over correct heading on Row 5.\n\n4. Save the sheet and upload to EasyCRM and start managing your Leads and Customers.",
                      style: TextStyle(
                        color: colorsConst.textColor,
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  10.height,
                  SizedBox(
                    width: 250,
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(40),
                          backgroundColor: colorsConst.third,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                              side: BorderSide(color: colorsConst.third))),
                      onPressed: () {
                       // if(controllers.serverSheet.value.isEmpty){
                          print("Local Download");
                          downloadSampleExcel();
                        // }else{
                        //   print("Network Download");
                        //   downloadSheetFromNetwork(controllers.serverSheet.value, "easycrm_data_upload_template.xlsx");
                        // }
                      },
                      child: const CustomText(
                        text: "Download Sample Excel Sheet",
                        colors: Colors.white,
                        isBold: true,
                        size: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 120,
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(40),
                        backgroundColor: colorsConst.third,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                            side: BorderSide(color: colorsConst.third))),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const CustomText(
                      text: "Cancel",
                      colors: Colors.white,
                      isBold: true,
                      size: 15,
                    ),
                  ),
                ),
                10.width,
                CustomLoadingButton(
                  callback: () {
                    pickAndReadExcelFile(context,leadStatus);
                    controllers.customerCtr.reset();
                  },
                  isLoading: true,
                  backgroundColor: colorsConst.secondary,
                  radius: 5,
                  width: 120,
                  controller: controllers.customerCtr,
                  text: "Import",
                  isImage: false,
                  textColor: colorsConst.primary,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void updateDialog(){
    showDialog(
        context: Get.context!,
        barrierDismissible: false,
        builder:(context){
          return WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: AlertDialog(
              shape:  RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
              ),
              backgroundColor: Colors.white,
              title:  Text(
                "Update Available?",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color:colorsConst.textColor,
                  fontFamily: "Lato",
                ),
              ),
              content: SizedBox(
                //height: 300,
                width: 300,
                child:Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Obx(()=>Text(
                      "A new version of CRM is available! \nCurrent:$versionNum -> Latest:${controllers.serverVersion}",
                      style: TextStyle(
                          fontSize:15,
                          fontWeight: FontWeight.w500,
                          color:colorsConst.textColor,
                        fontFamily: "Lato",
                      ),
                      textAlign: TextAlign.start,
                    ),
                    ),
                    10.height,
                        Text(
                          "Update now to enjoy the latest \nfeatures and improvements.",
                          style: TextStyle(
                              fontSize:15,
                              fontWeight: FontWeight.w500,
                              color:colorsConst.textColor
                          ),
                          textAlign: TextAlign.start,
                        ),
                    20.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        DialogButton(
                            text: "IGNORE",
                            width: 90,
                            onPress: (){
                              SystemNavigator.pop();
                            }),
                        DialogButton(
                            text: "LATER",
                            width: 90,
                            onPress: (){
                              Navigator.pop(Get.context!);
                            }),
                        DialogButton(
                            text: "UPDATE",
                            width: 90,
                            onPress: (){
                              // utils.makingWebsite(web: "https://play.google.com/store/apps/details?id=com.hapiapps.anpace6");
                              utils.makingWebsite(web: controllers.currentApk.value);
                            }),
                      ],
                    ),

                  ],
                ),
              ),
            ),
          );
        }
    );
  }

  void expiredDateDialog(String date){
    showDialog(
        context: Get.context!,
        barrierDismissible: false,
        builder:(context){
          return WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: AlertDialog(
              shape:  RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
              ),
              backgroundColor: Colors.white,
              title:  Row(
                children: [
                  Image.asset("assets/images/warning.png",height: 30,width: 30,),
                  Text(
                    "App Expired",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color:colorsConst.textColor,
                      fontFamily: "Lato",
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                //height: 300,
                width: 330,
                child:Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "This app version expired on ",
                      style: TextStyle(
                          fontSize:17,
                          fontWeight: FontWeight.w500,
                          color:colorsConst.textColor,
                        fontFamily: "Lato",
                      ),
                      textAlign: TextAlign.start,
                    ),
                    5.height,
                    Text(
                      date,
                      style: TextStyle(
                        fontSize:17,
                        fontWeight: FontWeight.w500,
                        color:colorsConst.textColor,
                        fontFamily: "Lato",
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),
            ),
          );
        }
    );
  }

  void expiredEmpDialog(){
    showDialog(
        context: Get.context!,
        barrierDismissible: true,
        builder:(context){
          return WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: AlertDialog(
              shape:  RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
              ),
              backgroundColor: Colors.white,
              title:  Row(
                children: [
                  Image.asset("assets/images/warning.png",height: 30,width: 30,),
                  Text(
                    "Employee Not Add",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color:colorsConst.textColor,
                      fontFamily: "Lato",
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                //height: 300,
                width: 330,
                child:Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Only after making a payment, you can add employees.",
                      style: TextStyle(
                          fontSize:17,
                          fontWeight: FontWeight.w500,
                          color:colorsConst.textColor,
                        fontFamily: "Lato",
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),
            ),
          );
        }
    );
  }

  bool showFollowUpCalendar = false;
  bool showMeetingCalendar = false;

  DateTime followUpSelectedDay = DateTime.now();
  DateTime meetingSelectedDay = DateTime.now();

// State for dropdown & repeat
  Map<DateTime, TimeOfDay> _selectedStartDatesTimes = {};
  Map<DateTime, TimeOfDay> _selectedEndDatesTimes = {};
  TimeOfDay _selectedTime = TimeOfDay.now();

  Future<void> _selectDateTime({
    required BuildContext context,
    required bool isStart,
  })
  async {
    Map<DateTime, TimeOfDay> selectedDatesTimes = isStart ? _selectedStartDatesTimes : _selectedEndDatesTimes;
    TextEditingController controller = isStart ? remController.startController : remController.endController;
    TimeOfDay dialogSelectedTime = selectedDatesTimes.values.isNotEmpty
        ? selectedDatesTimes.values.first
        : _selectedTime;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              insetPadding: const EdgeInsets.all(20),
              contentPadding: const EdgeInsets.all(8),
              title: Text(
                isStart ? "Select Start Date & Time" : "Select End Date & Time",
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                height: 630,
                width: 700,
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: SfDateRangePicker(
                        backgroundColor: Colors.white,
                        view: DateRangePickerView.month,
                        selectionMode: DateRangePickerSelectionMode.single,
                        extendableRangeSelectionDirection: ExtendableRangeSelectionDirection.none,
                        selectionColor: colorsConst.primary,
                        startRangeSelectionColor: colorsConst.primary,
                        endRangeSelectionColor: colorsConst.primary,
                        rangeSelectionColor: const Color(0xffD9ECFF),
                        todayHighlightColor: colorsConst.primary,
                        headerStyle: DateRangePickerHeaderStyle(
                          backgroundColor: Colors.white,
                          textStyle: TextStyle(color: colorsConst.primary, fontSize: 16,),
                        ),
                        onSelectionChanged: (args) {
                          if (args.value is DateTime) {
                            DateTime selectedDate = args.value;
                            setDialogState(() {
                              selectedDatesTimes.clear();
                              selectedDatesTimes[selectedDate] = dialogSelectedTime;
                            });
                          }
                        },
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 600,
                      color: Colors.grey.shade300,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 500,
                            child: Center(
                                child: SizedBox(
                                    width: 330,
                                    child: Theme(
                                      data: Theme.of(context).copyWith(
                                        timePickerTheme: TimePickerThemeData(
                                          backgroundColor: const Color(0xFFE7EEF8),
                                          hourMinuteShape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(8)),
                                            side: BorderSide(color: Colors.black26),
                                          ),
                                          hourMinuteColor: WidgetStateColor.resolveWith((states) {
                                            if (states.contains(WidgetState.selected)) {
                                              return const Color(0xff0078D7);
                                            }
                                            return Colors.white;
                                          }),
                                          hourMinuteTextColor: WidgetStateColor.resolveWith((states) {
                                            if (states.contains(WidgetState.selected)) {
                                              return Colors.white;
                                            }
                                            return colorsConst.primary;
                                          }),
                                          timeSelectorSeparatorColor:  WidgetStateColor.resolveWith((states) {
                                            if (states.contains(WidgetState.selected)) {
                                              return Colors.white;
                                            }
                                            return Colors.black;
                                          }),
                                          dayPeriodShape:  RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(6)),
                                            side: BorderSide(color: colorsConst.primary),
                                          ),
                                          dayPeriodColor: WidgetStateColor.resolveWith((states) {
                                            if (states.contains(WidgetState.selected)) {
                                              return colorsConst.primary;
                                            }
                                            return Colors.white;
                                          }),
                                          dayPeriodTextColor: WidgetStateColor.resolveWith((states) {
                                            if (states.contains(WidgetState.selected)) {
                                              return Colors.white;
                                            }
                                            return Colors.black;
                                          }),
                                          dialBackgroundColor: Colors.white,
                                          dialHandColor:colorsConst.primary,
                                          dialTextColor: Colors.black, // unselected numbers
                                          dialTextStyle: WidgetStateTextStyle.resolveWith((states) {
                                            if (states.contains(WidgetState.selected)) {
                                              return const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              );
                                            }
                                            return const TextStyle(
                                              color: Colors.black,
                                              fontSize: 18,
                                            );
                                          }),
                                          hourMinuteTextStyle: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 50,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      child: TimePickerDialog(
                                        initialTime: dialogSelectedTime,
                                        orientation: Orientation.portrait,
                                        cancelText: "",
                                        confirmText:"",
                                        onEntryModeChanged: (value){
                                          print("Time $value");
                                          // _selectedTime=value;
                                        },
                                      ),
                                    )
                                )
                            ),
                          ),
                          const SizedBox(height: 12),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _quickButton("+15 min", () {
                                    final t = dialogSelectedTime.replacing(
                                      minute:
                                      (dialogSelectedTime.minute + 15) % 60,
                                      hour: (dialogSelectedTime.hour +
                                          (dialogSelectedTime.minute +
                                              15) ~/
                                              60) %
                                          24,
                                    );
                                    setDialogState(
                                            () => dialogSelectedTime = t);
                                  }),
                                  _quickButton("+30 min", () {
                                    final t = dialogSelectedTime.replacing(
                                      minute:
                                      (dialogSelectedTime.minute + 30) % 60,
                                      hour: (dialogSelectedTime.hour +
                                          (dialogSelectedTime.minute +
                                              30) ~/
                                              60) %
                                          24,
                                    );
                                    setDialogState(
                                            () => dialogSelectedTime = t);
                                  }),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _quickButton("+1 hour", () {
                                    setDialogState(() {
                                      dialogSelectedTime = TimeOfDay(
                                        hour:
                                        (dialogSelectedTime.hour + 1) % 24,
                                        minute: dialogSelectedTime.minute,
                                      );
                                    });
                                  }),
                                  _quickButton("End of Day", () {
                                    setDialogState(() => dialogSelectedTime =
                                    const TimeOfDay(hour: 23, minute: 59));
                                  }),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 25, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 116,
                        height: 40,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE7EEF8),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                              side: const BorderSide(color: Color(0xff0078D7)),
                            ),
                            padding: EdgeInsets.zero,
                            elevation: 0,
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 116,
                        height: 40,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff0078D7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context, dialogSelectedTime);
                              selectedDatesTimes.updateAll(
                                    (key, value) => dialogSelectedTime,
                              );
                              if (selectedDatesTimes.isNotEmpty) {
                                final selectedDate = selectedDatesTimes.keys.first;
                                controller.text = "${selectedDate.day}-${selectedDate.month}-${selectedDate.year} "
                                    "${dialogSelectedTime.format(context)}";
                              }
                              print("Selected ${isStart ? "start" : "end"} dates & times: $selectedDatesTimes");
                          },
                          child: const Text(
                            "Set Time",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _quickButton(String text, VoidCallback onTap) {
    return Container(
      width: 120,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: BorderSide(color: Colors.grey.shade300),
          foregroundColor: Colors.black,
        ),
        child: Text(text, style: const TextStyle(fontSize: 13)),
      ),
    );
  }

  final DateFormat formatter = DateFormat("yyyy-MM-dd HH:mm");

  void showAddReminderDialog(BuildContext context) {
    String? titleError;
    String? startError;
    String? endError;
    String? employeeError;
    String? customerError;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 80, vertical: 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: EdgeInsets.zero,
              content: Container(
                width: 630,
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Add Reminder",
                            style: GoogleFonts.lato(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Text(
                              "×",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Divider(thickness: 1, color: Colors.grey.shade300),
                      const SizedBox(height: 8),
                      const Text("Reminder Type",
                          style: TextStyle(fontSize: 18, color: Colors.black)),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Consumer<ReminderProvider>(
                          builder: (context, cp, child) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: Checkbox(
                                        value: cp.email,
                                        onChanged: cp.toggleEmail,
                                        materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                        side: const BorderSide(
                                          color: Color(0xFF757575),
                                        ),
                                        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                                          if (states.contains(WidgetState.selected)) {
                                            return Color(0xFF0078D7);
                                          }
                                          return Colors.white;
                                        }),
                                        checkColor: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Email",
                                      style: GoogleFonts.lato(
                                          fontSize: 16, color: Colors.black
                                        // fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: Checkbox(
                                        value: cp.sms,
                                        onChanged: cp.toggleSms,
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        side: const BorderSide(
                                          color: Color(0xFF757575),
                                        ),
                                        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                                          if (states.contains(WidgetState.selected)) {
                                            return Color(0xFF0078D7);
                                          }
                                          return Colors.white;
                                        }),
                                        checkColor: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "SMS",
                                      style: GoogleFonts.lato(
                                          fontSize: 16, color: Colors.black
                                        // fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 10,
                                      height: 10,
                                      child: Checkbox(
                                        value: cp.web,
                                        onChanged: null,
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        side: const BorderSide(
                                          color: Color(0xFFBDBDBD),
                                        ),
                                        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                                          return Colors.grey.shade200;
                                        }),
                                        checkColor: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Web",
                                      style: GoogleFonts.lato(
                                        color: Colors.black,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: Checkbox(
                                        value: cp.app,
                                        onChanged: null,
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        side: const BorderSide(
                                          color: Color(0xFFBDBDBD),
                                        ),
                                        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                                          return Colors.grey.shade200;
                                        }),
                                        checkColor: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "App",
                                      style: GoogleFonts.lato(
                                          fontSize: 16, color: Colors.black
                                        // fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text("Default Time (Optional)",
                            style: GoogleFonts.lato(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      DropdownButtonFormField<String>(
                        value: remController.defaultTime,
                        isExpanded: true,
                        dropdownColor: Colors.white,
                        style: GoogleFonts.lato(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        items: ["Immediately", "5 mins", "10 mins", "30 mins"].map(
                              (e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              e,
                              style: GoogleFonts.lato(
                                color: Colors.black,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ).toList(),
                        onChanged: (v) => setState(() => remController.defaultTime = v!),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor:
                          Colors.white, // white background for input box
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.black, // 👈 dropdown arrow color
                        ),
                      ),
                      const SizedBox(height: 10),
                      /// Reminder title
                      Row(
                        children: [
                          Text("Reminder Title",
                              style: GoogleFonts.lato(
                                  fontSize: 17, color: Color(0xff737373))),
                          const CustomText(
                            text: "*",
                            colors: Colors.red,
                            size: 25,
                          )
                        ],
                      ),
                      5.height,
                      TextFormField(
                        textCapitalization: TextCapitalization.sentences,
                        controller: remController.titleController,
                        onChanged: (value){
                            if (value.toString().isNotEmpty) {
                              String newValue = value.toString()[0].toUpperCase() + value.toString().substring(1);
                              if (newValue != value) {
                                remController.titleController.value = remController.titleController.value.copyWith(
                                  text: newValue,
                                  selection: TextSelection.collapsed(offset: newValue.length),
                                );
                              }
                            }
                          if(remController.titleController.text.trim().isNotEmpty){
                            setState(() {
                              titleError = null;
                            });
                          }
                        },
                        style: GoogleFonts.lato(
                          color: Colors.black,
                          fontSize: 17,
                        ),
                        decoration: InputDecoration(
                          hintText: "Reminder title",
                          errorText: titleError,
                          hintStyle: TextStyle(
                            color: Color(0xFFCCCCCC),
                            fontSize: 17,
                            fontFamily: GoogleFonts.lato().fontFamily,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      Text("Notification Type",
                          style: GoogleFonts.lato(
                              fontSize: 17, color: const Color(0xff737373))),
                      Consumer<ReminderProvider>(
                        builder: (context, provider, _) {
                          return Row(
                            children: [
                              Expanded(
                                child: RadioListTile(
                                  title: Text(
                                    "Follow-up Reminder",
                                    style: GoogleFonts.lato(
                                      color: Colors.black,
                                      fontSize: 17,
                                    ),
                                  ),
                                  value: "followup",
                                  groupValue: provider.selectedNotification,
                                  activeColor: const Color(0xFF0078D7),
                                  onChanged: (v) =>
                                      provider.setNotification(v as String),
                                ),
                              ),
                              Expanded(
                                child: RadioListTile(
                                  title: Text(
                                    "Appointment Reminder",
                                    style: GoogleFonts.lato(
                                      color: Colors.black,
                                      fontSize: 17,
                                    ),
                                  ),
                                  value: "meeting",
                                  groupValue: provider.selectedNotification,
                                  activeColor: const Color(0xFF0078D7),
                                  onChanged: (v) =>
                                      provider.setNotification(v as String),
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      8.height,
                      Consumer<ReminderProvider>(
                        builder: (context, provider, _) {
                          if (provider.selectedNotification == "task") {
                            return const SizedBox.shrink();
                          }
                          return Column(
                            children: [
                              /// Location
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text("Location",
                                            style: GoogleFonts.lato(
                                                fontSize: 17,
                                                color: const Color(0xff737373))),
                                        const SizedBox(height: 5),
                                        DropdownButtonFormField<String>(
                                          value: remController.location,
                                          dropdownColor: Colors.white,
                                          style: GoogleFonts.lato(
                                            color: Colors.black,
                                            fontSize: 14,
                                          ),
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                              BorderRadius.circular(4),
                                              borderSide: BorderSide(
                                                  color: Colors.grey.shade300),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                              BorderRadius.circular(4),
                                              borderSide: BorderSide(
                                                  color: Colors.grey.shade300),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                              BorderRadius.circular(4),
                                              borderSide: BorderSide(
                                                  color: Colors.grey.shade300),
                                            ),
                                            contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 10),
                                          ),
                                          items: ["Online", "Office"]
                                              .map(
                                                (e) => DropdownMenuItem(
                                              value: e,
                                              child: Text(
                                                e,
                                                style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 17,
                                                ),
                                              ),
                                            ),
                                          )
                                              .toList(),
                                          onChanged: (v) => setState(
                                                  () => remController.location = v),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              13.height,

                              /// Employee and Customer fields
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "Employees",
                                              style: GoogleFonts.lato(
                                                fontSize: 17,
                                                color: const Color(0xff737373),
                                              ),
                                            ),
                                            const CustomText(
                                              text: "*",
                                              colors: Colors.red,
                                              size: 25,
                                            )
                                          ],
                                        ),
                                        5.height,
                                        KeyboardDropdownField<AllEmployeesObj>(
                                          items: controllers.employees,
                                          borderRadius: 5,
                                          borderColor: Colors.grey.shade300,
                                          hintText: "Employees",
                                          labelText: "",
                                          labelBuilder: (customer) =>
                                          '${customer.name} ${customer.name.isEmpty ? "" : "-"} ${customer.phoneNo}',
                                          itemBuilder: (customer) {
                                            return Container(
                                              width: 300,
                                              alignment: Alignment.topLeft,
                                              padding: const EdgeInsets.fromLTRB(
                                                  10, 5, 10, 5),
                                              child: CustomText(
                                                text:
                                                '${customer.name} ${customer.name.isEmpty ? "" : "-"} ${customer.phoneNo}',
                                                colors: Colors.black,
                                                size: 14,
                                                textAlign: TextAlign.start,
                                              ),
                                            );
                                          },
                                          textEditingController: controllers.empController,
                                          onSelected: (value) {
                                            setState((){
                                              employeeError=null;
                                            });
                                            controllers.selectEmployee(value);
                                          },
                                          onClear: () {
                                            controllers.clearSelectedCustomer();
                                          },
                                        ),
                                        if (employeeError != null)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 4.0),
                                            child: Text(
                                              employeeError!,
                                              style: const TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 13),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  20.width,
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "Assigned Customer",
                                              style: GoogleFonts.lato(
                                                fontSize: 17,
                                                color: const Color(0xff737373),
                                              ),
                                            ),
                                            const CustomText(
                                              text: "*",
                                              colors: Colors.red,
                                              size: 25,
                                            )
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        KeyboardDropdownField<AllCustomersObj>(
                                          items: controllers.customers,
                                          borderRadius: 5,
                                          borderColor: Colors.grey.shade300,
                                          hintText: "Customers",
                                          labelText: "",
                                          labelBuilder: (customer) =>
                                          '${customer.name} ${customer.name.isEmpty ? "" : "-"} ${customer.phoneNo}',
                                          itemBuilder: (customer) {
                                            return Container(
                                              width: 300,
                                              alignment: Alignment.topLeft,
                                              padding: const EdgeInsets.fromLTRB(
                                                  10, 5, 10, 5),
                                              child: CustomText(
                                                text:
                                                '${customer.name} ${customer.name.isEmpty ? "" : "-"} ${customer.phoneNo}',
                                                colors: Colors.black,
                                                size: 14,
                                                textAlign: TextAlign.start,
                                              ),
                                            );
                                          },
                                          textEditingController: controllers.cusController,
                                          onSelected: (value) {
                                            setState((){
                                              customerError=null;
                                            });
                                            controllers.selectCustomer(value);
                                          },
                                          onClear: () {
                                            controllers.clearSelectedCustomer();
                                          },
                                        ),
                                        if (customerError != null)
                                          Padding(
                                            padding:
                                            const EdgeInsets.only(top: 4.0),
                                            child: Text(
                                              customerError!,
                                              style: const TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 13),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 18),

                              /// Start & End Date/Time
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text("Start Date & Time",
                                                style: GoogleFonts.lato(
                                                    fontSize: 17,
                                                    color:
                                                    const Color(0xff737373))),
                                            const CustomText(
                                              text: "*",
                                              colors: Colors.red,
                                              size: 25,
                                            )
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        TextFormField(
                                          controller:
                                          remController.startController,
                                          readOnly: true,

                                          onTap: () => _selectDateTime(
                                              context: context, isStart: true),
                                          style: GoogleFonts.lato(
                                            color: Colors.black,
                                            fontSize: 17,
                                          ),
                                          decoration: InputDecoration(
                                            suffixIcon: const Icon(
                                              Icons.calendar_today_outlined,
                                              size: 20,
                                              color: Colors.grey,
                                            ),
                                            errorText: startError,
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(4),
                                              borderSide: BorderSide(
                                                color: Colors.grey.shade300,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text("End Date & Time",
                                                style: GoogleFonts.lato(
                                                    fontSize: 17,
                                                    color:
                                                    const Color(0xff737373))),
                                            const CustomText(
                                              text: "*",
                                              colors: Colors.red,
                                              size: 25,
                                            )
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        TextFormField(
                                          controller: remController.endController,
                                          readOnly: true,
                                          onTap: () => _selectDateTime(
                                              context: context, isStart: false),
                                          style: GoogleFonts.lato(
                                            color: Colors.black,
                                            fontSize: 17,
                                          ),
                                          decoration: InputDecoration(
                                            suffixIcon: const Icon(
                                              Icons.calendar_today_outlined,
                                              size: 20,
                                              color: Colors.grey,
                                            ),
                                            errorText: endError,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                              BorderRadius.circular(4),
                                              borderSide: BorderSide(
                                                color: Colors.grey.shade300,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              10.height,
                              /// Details field
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Details",
                                      style: GoogleFonts.lato(
                                          fontSize: 17,
                                          color: Color(0xff737373))),
                                  const SizedBox(height: 5),
                                  TextFormField(
                                    textCapitalization:
                                    TextCapitalization.sentences,
                                    controller:
                                    remController.detailsController,
                                    maxLines: 2,
                                    style: GoogleFonts.lato(
                                      color: Colors.black,
                                      fontSize: 17,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: "Appointment Points",
                                      hintStyle: GoogleFonts.lato(
                                        color: const Color(0xFFCCCCCC),
                                        fontSize: 17,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),

                      13.height,

                      /// Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: 80,
                            height: 30,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7),
                                  side: const BorderSide(color: Color(0xff0078D7)),
                                ),
                                padding: EdgeInsets.zero,
                                elevation: 0,
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                "Cancel",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          CustomLoadingButton(
                            callback: ()async{
                              setState(() {
                                titleError = remController.titleController.text.trim().isEmpty
                                    ? "Please enter reminder title"
                                    : null;
                                startError = remController.startController.text.trim().isEmpty
                                    ? "Please select start date & time"
                                    : null;
                                endError = remController.endController.text.trim().isEmpty
                                    ? "Please select end date & time"
                                    : null;
                                employeeError = controllers.selectedEmployeeId.value.isEmpty
                                    ? "Please select employee"
                                    : null;
                                customerError = controllers.selectedCustomerId.value.isEmpty
                                    ? "Please select customer"
                                    : null;
                              });
                              if (titleError == null &&
                                  startError == null &&
                                  endError == null &&
                                  employeeError == null &&
                                  customerError == null) {
                                final provider = Provider.of<ReminderProvider>(context, listen: false);
                                remController.insertReminderAPI(context, provider.selectedNotification);
                              }else{
                                controllers.productCtr.reset();
                              }
                            },
                            height: 40,
                            isLoading: true,
                            backgroundColor: colorsConst.primary,
                            radius: 7,
                            width: 150,
                            controller: controllers.productCtr,
                            isImage: false,
                            text: "Save Reminder",
                            textColor: Colors.white,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void showUpdateReminderDialog(String id,BuildContext context) {
    String? titleError;
    String? startError;
    String? endError;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 80, vertical: 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: EdgeInsets.zero,
              content: Container(
                width: 630,
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Update Reminder",
                            style: GoogleFonts.lato(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Text(
                              "×",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Divider(thickness: 1, color: Colors.grey.shade300),
                      const SizedBox(height: 8),

                      /// Reminder title
                      Text("Reminder Title",
                          style: GoogleFonts.lato(
                              fontSize: 17, color: Color(0xff737373))),
                      const SizedBox(height: 5),
                      TextFormField(
                        textCapitalization: TextCapitalization.sentences,
                        controller: remController.updateTitleController,
                        onChanged: (value) {
                          if (value.toString().isNotEmpty) {
                            String newValue = value.toString()[0].toUpperCase() + value.toString().substring(1);
                            if (newValue != value) {
                              remController.updateTitleController.value = remController.updateTitleController.value.copyWith(
                                text: newValue,
                                selection: TextSelection.collapsed(offset: newValue.length),
                              );
                            }
                          }
                          if (value.trim().isNotEmpty) {
                            setState(() {
                              titleError = null;
                            });
                          }
                        },
                        style: GoogleFonts.lato(
                          color: Colors.black,
                          fontSize: 17,
                        ),
                        decoration: InputDecoration(
                          hintText: "Reminder title",
                          errorText: titleError,
                          hintStyle: TextStyle(
                            color: Color(0xFFCCCCCC),
                            fontSize: 17,
                            fontFamily: GoogleFonts.lato().fontFamily,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      Text("Notification Type",
                          style: GoogleFonts.lato(
                              fontSize: 17, color: const Color(0xff737373))),
                      Consumer<ReminderProvider>(
                        builder: (context, provider, _) {
                          return Row(
                            children: [
                              Expanded(
                                child: RadioListTile(
                                  title: Text(
                                    "Follow-up Reminder",
                                    style: GoogleFonts.lato(
                                      color: Colors.black,
                                      fontSize: 17,
                                    ),
                                  ),
                                  value: "followup",
                                  groupValue: provider.selectedNotification,
                                  activeColor: const Color(0xFF0078D7),
                                  onChanged: (v) =>
                                      provider.setNotification(v as String),
                                ),
                              ),
                              Expanded(
                                child: RadioListTile(
                                  title: Text(
                                    "Appointment Reminder",
                                    style: GoogleFonts.lato(
                                      color: Colors.black,
                                      fontSize: 17,
                                    ),
                                  ),
                                  value: "meeting",
                                  groupValue: provider.selectedNotification,
                                  activeColor: const Color(0xFF0078D7),
                                  onChanged: (v) =>
                                      provider.setNotification(v as String),
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      8.height,
                      Consumer<ReminderProvider>(
                        builder: (context, provider, _) {
                          if (provider.selectedNotification == "task") {
                            return const SizedBox.shrink();
                          }
                          return Column(
                            children: [
                              /// Location
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text("Location",
                                            style: GoogleFonts.lato(
                                                fontSize: 17,
                                                color: const Color(0xff737373))),
                                        const SizedBox(height: 5),
                                        DropdownButtonFormField<String>(
                                          value: remController.updateLocation,
                                          dropdownColor: Colors.white,
                                          style: GoogleFonts.lato(
                                            color: Colors.black,
                                            fontSize: 14,
                                          ),
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                              BorderRadius.circular(4),
                                              borderSide: BorderSide(
                                                  color: Colors.grey.shade300),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                              BorderRadius.circular(4),
                                              borderSide: BorderSide(
                                                  color: Colors.grey.shade300),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                              BorderRadius.circular(4),
                                              borderSide: BorderSide(
                                                  color: Colors.grey.shade300),
                                            ),
                                            contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 10),
                                          ),
                                          items: ["Online", "Office"]
                                              .map(
                                                (e) => DropdownMenuItem(
                                              value: e,
                                              child: Text(
                                                e,
                                                style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 17,
                                                ),
                                              ),
                                            ),
                                          )
                                              .toList(),
                                          onChanged: (v) => setState(
                                                  () => remController.updateLocation = v),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              /// Start & End Date/Time
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text("Start Date & Time",
                                            style: GoogleFonts.lato(
                                                fontSize: 17,
                                                color:
                                                const Color(0xff737373))),
                                        const SizedBox(height: 5),
                                        TextFormField(
                                          controller:
                                          remController.updateStartController,
                                          readOnly: true,
                                          onTap: () => _selectDateTime(
                                              context: context, isStart: true),
                                          style: GoogleFonts.lato(
                                            color: Colors.black,
                                            fontSize: 17,
                                          ),
                                          decoration: InputDecoration(
                                            suffixIcon: const Icon(
                                              Icons.calendar_today_outlined,
                                              size: 20,
                                              color: Colors.grey,
                                            ),
                                            errorText: startError,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                              BorderRadius.circular(4),
                                              borderSide: BorderSide(
                                                color: Colors.grey.shade300,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text("End Date & Time",
                                            style: GoogleFonts.lato(
                                                fontSize: 17,
                                                color:
                                                const Color(0xff737373))),
                                        const SizedBox(height: 5),
                                        TextFormField(
                                          controller: remController.updateEndController,
                                          readOnly: true,
                                          onTap: () => _selectDateTime(
                                              context: context, isStart: false),
                                          style: GoogleFonts.lato(
                                            color: Colors.black,
                                            fontSize: 17,
                                          ),
                                          decoration: InputDecoration(
                                            suffixIcon: const Icon(
                                              Icons.calendar_today_outlined,
                                              size: 20,
                                              color: Colors.grey,
                                            ),
                                            errorText: endError,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                              BorderRadius.circular(4),
                                              borderSide: BorderSide(
                                                color: Colors.grey.shade300,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              10.height,

                              /// Details field
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Details",
                                      style: GoogleFonts.lato(
                                          fontSize: 17,
                                          color: Color(0xff737373))),
                                  const SizedBox(height: 5),
                                  TextFormField(
                                    textCapitalization:
                                    TextCapitalization.sentences,
                                    controller: remController.updateDetailsController,
                                    maxLines: 2,
                                    style: GoogleFonts.lato(
                                      color: Colors.black,
                                      fontSize: 17,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: "Appointment Points",
                                      hintStyle: GoogleFonts.lato(
                                        color: const Color(0xFFCCCCCC),
                                        fontSize: 17,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),

                      13.height,

                      /// Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: 80,
                            height: 30,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7),
                                  side: const BorderSide(color: Color(0xff0078D7)),
                                ),
                                padding: EdgeInsets.zero,
                                elevation: 0,
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                "Cancel",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          CustomLoadingButton(
                            callback: ()async{
                              setState(() {
                                titleError = remController.updateTitleController.text.trim().isEmpty
                                    ? "Please enter reminder title"
                                    : null;
                                startError = remController.updateStartController.text.trim().isEmpty
                                    ? "Please select start date & time"
                                    : null;
                                endError = remController.updateEndController.text.trim().isEmpty
                                    ? "Please select end date & time"
                                    : null;
                              });
                              if (titleError == null && startError == null && endError == null) {
                                final provider = Provider.of<ReminderProvider>(context, listen: false);
                                remController.updateReminderAPI(context, provider.selectedNotification,id);
                              }else{
                                controllers.productCtr.reset();
                              }
                            },
                            height: 40,
                            isLoading: true,
                            backgroundColor: colorsConst.primary,
                            radius: 7,
                            width: 150,
                            controller: controllers.productCtr,
                            isImage: false,
                            text: "Update Reminder",
                            textColor: Colors.white,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

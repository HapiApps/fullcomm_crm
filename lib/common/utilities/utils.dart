import 'dart:convert';
import 'package:excel/excel.dart' as excel;
import 'package:fullcomm_crm/controller/settings_controller.dart';
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
import 'package:fullcomm_crm/screens/leads/view_customer.dart';
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
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  settingsController.showAddTemplateDialog(context);
                                },
                                child: CustomText(
                                  text: "Add Template",
                                  colors: colorsConst.third,
                                  size: 18,
                                  isBold: true,
                                )),
                            // IconButton(
                            //     onPressed: () {},
                            //     icon: SvgPicture.asset(assets.b,
                            //         width: 17, height: 17)),
                            // IconButton(
                            //     onPressed: () {},
                            //     icon: SvgPicture.asset(
                            //       assets.i,
                            //       width: 15,
                            //       height: 15,
                            //     )),
                            // IconButton(
                            //     onPressed: () {},
                            //     icon: SvgPicture.asset(
                            //       assets.u,
                            //       width: 19,
                            //       height: 19,
                            //     )),
                            // IconButton(
                            //     onPressed: () {},
                            //     icon: SvgPicture.asset(
                            //       assets.fileFilter,
                            //       width: 17,
                            //       height: 17,
                            //     )),
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
                            // IconButton(
                            //     onPressed: () {},
                            //     icon: SvgPicture.asset(
                            //       assets.layer,
                            //       width: 17,
                            //       height: 17,
                            //
                            //     )),
                            // IconButton(
                            //     onPressed: () {},
                            //     icon: SvgPicture.asset(assets.a)),
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
                              controllers.isTemplate.value = !controllers.isTemplate.value;
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
                                                        color: colorsConst.textColor,
                                                        fontSize: 14,
                                                        fontFamily: "Lato"),
                                                    border: InputBorder.none,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                    :Obx(() => UnconstrainedBox(
                                  child: Container(
                                    width: 500,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: colorsConst.secondary,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            width: 500,
                                            height: 210,
                                            child: Table(
                                              defaultColumnWidth: const FixedColumnWidth(120.0),
                                              border: TableBorder.all(
                                                color: Colors.grey.shade300,
                                                style: BorderStyle.solid,
                                                borderRadius: BorderRadius.circular(10),
                                                width: 1,
                                              ),
                                              children: [
                                                // Header Row
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
                                                  ],
                                                ),
                                                // Dynamic Rows
                                                for (var item in settingsController.templateList)
                                                  utils.emailRow(
                                                    context,
                                                    isCheck: controllers.isAdd,
                                                    templateName: item.templateName,
                                                    msg: item.message,
                                                    subject: item.subject,
                                                    id: item.id
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ))
                                  // : UnconstrainedBox(
                                      //     child: Container(
                                      //       width: 500,
                                      //       alignment: Alignment.center,
                                      //       decoration: BoxDecoration(
                                      //         color: colorsConst.secondary,
                                      //         borderRadius:
                                      //             BorderRadius.circular(10),
                                      //       ),
                                      //       child: SingleChildScrollView(
                                      //         child: Column(
                                      //           children: [
                                      //             SizedBox(
                                      //               width: 500,
                                      //               height: 210,
                                      //               child: Table(
                                      //                 defaultColumnWidth: const FixedColumnWidth(
                                      //                         120.0),
                                      //                 border: TableBorder.all(
                                      //                     color: Colors
                                      //                         .grey.shade300,
                                      //                     style: BorderStyle.solid,
                                      //                     borderRadius: BorderRadius.circular(10),
                                      //                     width: 1),
                                      //                 children: [
                                      //                   TableRow(
                                      //                       children: [
                                      //                     CustomText(
                                      //                       textAlign: TextAlign.center,
                                      //                       text: "\nTemplate Name\n",
                                      //                       colors: colorsConst.textColor,
                                      //                       size: 15,
                                      //                       isBold: true,
                                      //                     ),
                                      //                     CustomText(
                                      //                       textAlign: TextAlign.center,
                                      //                       text: "\nSubject\n",
                                      //                       colors: colorsConst.textColor,
                                      //                       size: 15,
                                      //                       isBold: true,
                                      //                     ),
                                      //                   ]),
                                      //                   utils.emailRow(context,
                                      //                       isCheck: controllers.isAdd,
                                      //                       templateName: "Promotional",
                                      //                       msg: "Dear $name,\n \nWe hope this email finds you in good spirits.\n \nWe are excited to announce a special promotion exclusively for you! [Briefly describe the promotion, e.g., discount, free trial, bundle offer, etc.]. This offer is available for a limited time only, so be sure to take advantage of it while you can!\n \nAt $coName, we strive to provide our valued customers with exceptional value and service. We believe this promotion will further enhance your experience with us.\n \nDo not miss out on this fantastic opportunity! [Include a call-to-action, e.g., \"Shop now,\" \"Learn more,\" etc.]\n \nThank you for your continued support. We look forward to serving you.\n \nWarm regards,\n \nAnjali\nManager\n$mobile",
                                      //                       subject: "Exclusive Promotion for You - \nLimited Time Offer!"),
                                      //                   utils.emailRow(context,
                                      //                       isCheck: controllers.isAdd,
                                      //                       templateName: "Follow-Up",
                                      //                       msg: "Dear $name,\n \nI hope this email finds you well.\n \nI wanted to follow up on our recent interaction regarding [briefly mention the nature of the interaction, e.g., service request, inquiry, etc.]. We value your feedback and are committed to ensuring your satisfaction.\n \nPlease let us know if everything is proceeding smoothly on your end, or if there are any further questions or concerns you like to address. Our team is here to assist you every step of the way.\n \nThank you for choosing $coName. We appreciate the opportunity to serve you.\n \nBest regards,\n \nAnjali\nManager\n$mobile",
                                      //                       subject: "Follow-up on Recent Service Interaction"),
                                      //                   utils.emailRow(context,
                                      //                       msg: "Dear $name,\n \nWe hope this email finds you well.\n \nWe are writing to inform you of an update regarding our services. [Briefly describe the update or enhancement]. We believe this will [mention the benefit or improvement for the customer].\n \nPlease feel free to [contact us/reach out] if you have any questions or need further assistance regarding this update.\n \nThank you for choosing $coName. We appreciate your continued support.\n \nBest regards,\n \nAnjali\nManager\n$mobile",
                                      //                       isCheck: controllers.isAdd,
                                      //                       templateName: "Service Update",
                                      //                       subject: "Service Update - [Brief Description]"),
                                      //                 ],
                                      //               ),
                                      //             ),
                                      //             // 10.height,
                                      //             // CustomLoadingButton(
                                      //             //   callback: (){},
                                      //             //   isImage: false,
                                      //             //   isLoading: false,
                                      //             //   backgroundColor: colorsConst.primary,
                                      //             //   radius: 20,
                                      //             //   width: 70,
                                      //             //   height: 30,
                                      //             //   text: "Done",
                                      //             //   textColor: Colors.white,
                                      //             //
                                      //             // ),
                                      //           ],
                                      //         ),
                                      //       ),
                                      //     ),
                                      //   ),
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
                                    text: controllers.leadCategoryList[3]["value"],
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
      allowedExtensions: ['pdf', 'png', 'jpeg', 'jpg', 'ppt', 'pptx', 'doc', 'docx', 'xls', 'xlsx'],
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
      {RxBool? isCheck, String? templateName, String? subject, String? msg, String? id}) {
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
                    controllers.emailSubjectCtr.text = subject.toString().replaceAll('\n', ' ');
                    controllers.emailMessageCtr.text = msg.toString();
                    controllers.emailQuotationCtr.text = templateName.toString();
                  },
                ),
              ),
              InkWell(
                onTap: (){
                  Navigator.of(context).pop();
                  settingsController.addNameController.text = templateName.toString();
                  settingsController.addSubjectController.text = subject.toString();
                  settingsController.addMessageController.text = msg.toString();
                  settingsController.showAddTemplateDialog(context, isEdit: true,id: id.toString());
                },
                child: SvgPicture.asset(
                  "assets/images/a_edit.svg",
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

      //print("Payload: ${jsonEncode(finalPayload)}");

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
  Future<void> showImportDialogThirumal(BuildContext context,String leadStatus) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.all(5),
          backgroundColor: colorsConst.secondary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: SizedBox(
            width: 350,
            height: 500,
            child: SelectionArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    colors: colorsConst.third,
                    text: "Your uploaded Excel file should have columns matching the required fields exactly as listed below to ensure correct data insertion:",
                    isBold: true,
                    size: 15,
                    textAlign: TextAlign.start,
                  ),
                  10.height,
                  CustomText(
                    text: "Column Names:",
                    colors: colorsConst.textColor,
                    size: 15,
                    isBold: true,
                  ),
                  5.height,
                  dialogText("NAME OF THE ACCOUNT MANAGER"),
                  dialogText("NAME OF THE CUSTOMER"),
                  dialogText("KEY CONTACT PERSON"),
                  dialogText("CONTACT NUMBER"),
                  dialogText("EMAIL ID"),
                  dialogText("SITE LOCATION DETAILS"),
                  dialogText("SOURCE OF PROSPECT (either BNI or social)"),
                  dialogText("LEAD / PROSPECT"),
                  dialogText("PROSPECT SOURCE DETAILS"),
                  dialogText("PROSPECT ENROLLMENT DATE"),
                  dialogText("EXPECTED CONVERSION DATE"),
                  dialogText("DETAILS OF SERVICES REQUIRED"),
                  dialogText("PROSPECT GRADING"),
                  dialogText("STATUS UPDATE"),
                  dialogText("TOTAL NUMBER OF HEAD COUNT"),
                  dialogText("EXPECTED MONTHLY BILLING VALUE"),
                  dialogText("ARPU VALUE"),
                  dialogText("CURRENT STATUS"),
                  10.height,
                  CustomText(
                    text: "File format:",
                    colors: colorsConst.textColor,
                    size: 15,
                    isBold: true,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(17, 5, 5, 5),
                    child: CustomText(
                      textAlign: TextAlign.start,
                      text: '.xlsx, .xls',
                      colors: colorsConst.textColor,
                      size: 14,
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
                    thiPickAndReadExcelFile(context,leadStatus);
                  },
                  isLoading: true,
                  backgroundColor: colorsConst.secondary,
                  radius: 5,
                  width: 120,
                  controller: controllers.customerCtr,
                  text: "Import",
                  isImage: false,
                  textColor: colorsConst.textColor,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget dialogText(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(17, 2, 5, 2),
      child: CustomText(
        textAlign: TextAlign.start,
        text: text,
        colors: colorsConst.textColor,
        size: 13,
      ),
    );
  }
  void thiPickAndReadExcelFile(BuildContext context,String leadStatus) {
    final html.FileUploadInputElement input = html.FileUploadInputElement()
      ..accept = '.xlsx, .xls';
    input.click();

    input.onChange.listen((event) {
      final file = input.files!.first;
      final reader = html.FileReader();

      reader.readAsArrayBuffer(file);
      reader.onLoadEnd.listen((event) {
        Uint8List bytes = reader.result as Uint8List;
        thiParseExcelFile(bytes, context, leadStatus);
      });
    });
  }

  List<Map<String, dynamic>> thiCustomerData = [];
  List<Map<String, dynamic>> thiMCustomerData = [];

  void thiParseExcelFile(Uint8List bytes, BuildContext context, String leadStatus) async {
    thiCustomerData = [];
    var excelD = excel.Excel.decodeBytes(bytes);

    Map<String, String> keyMapping = {
      "SITE LOCATION DETAILS": "city",
      "LEAD / PROSPECT": "lead_status",
      "CURRENT STATUS": "status",
      "NAME OF THE CUSTOMER": "company_name",
      "DETAILS OF SERVICES REQUIRED": "details_of_service_required",
      "NAME OF THE ACCOUNT MANAGER": "owner",
      "PROSPECT ENROLLMENT DATE": "prospect_enrollment_date",
      "EXPECTED CONVERSION DATE": "expected_convertion_date",
      "STATUS UPDATE": "status_update",
      "TOTAL NUMBER OF HEAD COUNT": "num_of_headcount",
      "EXPECTED MONTHLY BILLING VALUE": "expected_billing_value",
      "ARPU VALUE": "arpu_value",
      "KEY CONTACT PERSON": "name",
      "EMAIL ID": "email",
      "CONTACT NUMBER": "phone_no",
      "SOURCE OF PROSPECT (either BNI or social)": "source",
      "PROSPECT SOURCE DETAILS": "source_details",
      "PROSPECT GRADING": "rating"
    };

    for (var table in excelD.tables.keys) {
      var rows = excelD.tables[table]!.rows;

      List<String> headers = rows.first.map((cell) => (cell?.value.toString().trim().toUpperCase()) ?? "").toList();

      List<String> missingColumns = [];

      for (var key in keyMapping.keys) {
        if (!headers.contains(key.toUpperCase().trim())) {
          missingColumns.add(key);
        }
      }

      print("missingColumns: $missingColumns");

      if (missingColumns.isNotEmpty) {
        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: colorsConst.primary,
            title: CustomText(
              text: "Missing Columns",
              colors: colorsConst.textColor,
              size: 18,
              isBold: true,
            ),
            content: CustomText(
              text: "The following columns are missing:\n\n${missingColumns.join(", ")}",
              colors: colorsConst.textColor,
              size: 16,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: CustomText(
                  text: "OK",
                  colors: colorsConst.textColor,
                  size: 16,
                ),
              ),
            ],
          ),
        );
        return;
      }

      for (var i = 1; i < rows.length; i++) {
        var row = rows[i];
        Map<String, dynamic> rowData = {};
        Map<String, dynamic> formattedData = {};
        bool isRowEmpty = row.every((cell) =>
        cell == null || cell.value == null || cell.value.toString().trim().isEmpty);

        if (isRowEmpty) continue;

        for (var j = 0; j < headers.length; j++) {
          String header = headers[j];
          rowData[header] = row[j]?.value;
        }

        rowData.forEach((key, value) {
          String matchedKey = keyMapping.keys.firstWhere(
                (mappedKey) => mappedKey.toUpperCase().trim() == key.toUpperCase().trim(),
            orElse: () => "",
          );
          if (matchedKey.isNotEmpty) {
            String mappedField = keyMapping[matchedKey]!;
            if (mappedField == "rating") {
              formattedData[mappedField] = value != null && value.toString().isNotEmpty ? value : "WARM";
            }else if (mappedField == "lead_status") {
              formattedData[mappedField] = leadStatus!="0" ? value : "0";
            } else {
              formattedData[mappedField] = value;
            }
          }
        });

        if (rowData.containsKey("CONTACT NUMBER")) {
          formattedData["whatsapp_no"] = rowData["CONTACT NUMBER"];
        }

        // Add extra fields
        formattedData["user_id"] = controllers.storage.read("id");
        formattedData["cos_id"] = controllers.storage.read("cos_id");
        formattedData["door_no"] = "";
        formattedData["area"] = "";
        formattedData["country"] = "India";
        formattedData["state"] = "Tamil Nadu";
        formattedData["pincode"] = "";
        formattedData["product_discussion"] = "";
        formattedData["discussion_point"] = "";
        formattedData["points"] = "";
        formattedData["department"] = "";
        formattedData["designation"] = "";
        if (!formattedData.containsKey("source")) {
          formattedData["source"] = "";
        }

        if ((formattedData["phone_no"] != null && formattedData["phone_no"].toString().isNotEmpty) ||
            (formattedData["name"] != null && formattedData["name"].toString().isNotEmpty)) {
          thiCustomerData.add(formattedData);
        } else {
          if (formattedData["email"] != null && formattedData["email"].toString().isNotEmpty) {
            thiCustomerData.add(formattedData);
          } else {
            thiMCustomerData.add(formattedData);
          }
        }
      }
    }

    print("mCustomerData ${thiMCustomerData.length}");
    print("customerData ${thiCustomerData.length}");

    if (thiCustomerData.isEmpty) {
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: colorsConst.primary,
          content: CustomText(
            text: "Some entries under KEY CONTACT PERSON and CONTACT NUMBER are empty in your Excel sheet. Please check and re-upload.",
            colors: colorsConst.textColor,
            size: 16,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: CustomText(
                text: "OK",
                colors: colorsConst.textColor,
                size: 16,
              ),
            ),
          ],
        ),
      );
      return;
    } else {
      await apiService.insertThirumalCustomersAPI(context, thiCustomerData);
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
                        isCopy: false,
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
                      isCopy :false,
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
  void showLeadCategoryDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomText(
                text: "Change Labels",
                colors: colorsConst.textColor,
                isBold: true,
                size: 18,
              ),
              10.height,
              SizedBox(
                width: 300,
                child: Obx(() => ListView.builder(
                  shrinkWrap: true,
                  itemCount: controllers.leadCategoryList.length,
                  itemBuilder: (context, index) {
                    final item = controllers.leadCategoryList[index];
                    return ListTile(
                      title: TextField(                         // Editable TextField
                        controller: TextEditingController(
                          text: item["value"].toString(),
                        ),
                        onChanged: (val) {
                          controllers.leadCategoryList[index]["value"] = val;
                          controllers.editMode[index]=true;
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                      trailing: SvgPicture.asset(
                        "assets/images/a_edit.svg",
                        width: 16,
                        height: 16,
                      ),
                    );
                  },
                )),
              ),

              20.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                    child: const Text("Cancel", style: TextStyle(color: Colors.black)),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      bool anyEdit = controllers.editMode.contains(true);
                      if (!anyEdit) {
                        utils.snackBar(
                          context: context,
                          msg: "No changes to update",
                          color: Colors.red,
                        );
                        return;
                      }
                      for (int i = 0; i < controllers.leadCategoryList.length; i++) {
                        final item = controllers.leadCategoryList[i];
                        if (controllers.editMode[i] == true) {
                          await apiService.updateCategoryAPI(
                            context, item["id"],item["value"],
                          );
                        }
                      }
                      Navigator.of(context).pop();
                    },
                    child: const Text("Save"),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void showFilterDialog(BuildContext context) {
    List<String> items = [
      "Today",
      "Yesterday",
      "Last 7 Days",
      "Last 30 Days",
      "All"
    ];

    RxString selectedValue = items.last.obs;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select Date Range"),
          content: Obx(() => SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...items.map((value) {
                  return RadioListTile<String>(
                    title: Text(value),
                    value: value,
                    groupValue: selectedValue.value,
                    onChanged: (newValue) {
                      selectedValue.value = newValue!;
                    },
                  );
                }).toList(),
              ],
            ),
          )),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                controllers.storage.write("selectedSortBy", selectedValue.value);
                remController.loadSavedFilters();
                Navigator.pop(context, selectedValue.value);
              },
              child: const Text("Apply"),
            ),
          ],
        );
      },
    ).then((selected) {
      if (selected != null) {
        print("Selected filter: $selected");
        // Use the selected filter here
      }
    });
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

}

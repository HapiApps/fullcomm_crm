import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/common/utilities/utils.dart';
import 'package:get/get.dart';

import '../../components/custom_loading_button.dart';
import '../../components/custom_text.dart';
import '../../controller/controller.dart';
import '../../controller/image_controller.dart';
import '../../models/new_lead_obj.dart';
import '../../services/api_services.dart';
import '../constant/assets_constant.dart';
import '../constant/colors_constant.dart';

final MailUtils mailUtils = MailUtils._();

class MailUtils {
  MailUtils._();
  void bulkEmailDialog(FocusNode focusNode, {required List<Map<String, String>> list, bool isTarget = false}) {
    controllers.emailSubjectCtr.clear();
    controllers.emailMessageCtr.clear();
    imageController.photo1.value="";
    int total = list.length;
    int withMail = list.where((e) => (e["mail_id"] != null && e["mail_id"]!.trim().isNotEmpty && e["mail_id"]!.trim() != "null")).length;
    int withoutMail = total - withMail;
    var selectedRange = "".obs;
    void selectRange(String range, List<NewLeadObj> allLeads) {
      selectedRange.value = range;
      final parts = range.split("-");
      final start = int.parse(parts[0].trim()) - 1; // index start
      final end = int.parse(parts[1].trim());       // index end
      final subList = allLeads.sublist(start, end);
      total = subList.length;
      withMail = subList.where((e) =>
      e.email != null &&
          e.email!.trim().isNotEmpty &&
          e.email!.trim() != "null").length;
      withoutMail = total - withMail;
      apiService.prospectsList.addAll(
        subList.where((data) =>
        data.email != null &&
            data.email!.trim().isNotEmpty &&
            data.email!.trim() != "null") // mail check
            .map((data) => {
          "lead_id": data.userId.toString(),
          "user_id": controllers.storage.read("id"),
          "rating": data.rating ?? "Warm",
          "cos_id": controllers.storage.read("cos_id"),
          "mail_id": data.email!.split("||")[0]
        }),
      );
    }
    showDialog(
        context: Get.context!,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(
              builder: (context,setState){
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
                                        utils.chooseFile(mediaDataV:imageController.empMediaData,
                                            fileName:imageController.empFileName,
                                            pathName:imageController.photo1);
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
                            Obx(() => CustomLoadingButton(
                              callback: () {
                                if(apiService.prospectsList.isEmpty){
                                  apiService.errorDialog(context, "Please Select range to send email.");
                                  controllers.emailCtr.reset();
                                  return;
                                }
                                if(controllers.emailSubjectCtr.text.isEmpty){
                                  apiService.errorDialog(context, "Please fill subject.");
                                  controllers.emailCtr.reset();
                                  return;
                                }
                                if(controllers.emailMessageCtr.text.isEmpty){
                                  apiService.errorDialog(context, "Please fill message.");
                                  controllers.emailCtr.reset();
                                  return;
                                }
                                List<Map<String, String>> withMail = apiService.prospectsList.where((e) {
                                  final mail = e["mail_id"];
                                  return mail != null && mail.trim().isNotEmpty && mail.trim() != "null";
                                }).toList();
                                print("Mail $withMail");
                                // if(withMail.length>100){
                                //   Navigator.of(context).pop();
                                //   apiService.errorDialog(
                                //       context, "Select only 100 customers at a time for email.");
                                //   return;
                                // }
                                apiService.bulkEmailAPI(context, withMail, imageController.photo1.value);
                                focusNode.requestFocus();
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
                      width: 650,
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
                            // Align(
                            //   alignment: Alignment.topRight,
                            //   child: TextButton(
                            //       onPressed: () {
                            //         controllers.isTemplate.value =
                            //         !controllers.isTemplate.value;
                            //       },
                            //       child: CustomText(
                            //         text: "Get Form Template",
                            //         colors: colorsConst.third,
                            //         size: 18,
                            //         isBold: true,
                            //       )),
                            // ),
                            // Row(
                            //   children: [
                            //     CustomText(
                            //       textAlign: TextAlign.center,
                            //       text: "To",
                            //       colors: colorsConst.textColor,
                            //       size: 15,
                            //     ),
                            //     50.width,
                            //     SizedBox(
                            //       width: 500,
                            //       child: TextField(
                            //         controller: controllers.emailToCtr,
                            //         style: TextStyle(
                            //             fontSize: 15, color: colorsConst.textColor),
                            //         decoration: const InputDecoration(
                            //           border: InputBorder.none,
                            //         ),
                            //       ),
                            //     )
                            //   ],
                            // ),
                            SizedBox(
                                width: 650,
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 40,
                                        width: 650,
                                        child: Obx(() {
                                          final ranges = isTarget?controllers.leadTargetRanges:controllers.leadRanges;
                                          if (ranges.isEmpty) {
                                            return const Center(child: Text("No leads found"));
                                          }
                                          return ListView.builder(
                                            itemCount: ranges.length,
                                            scrollDirection: Axis.horizontal,
                                            itemBuilder: (context, index) {
                                              final range = ranges[index];
                                              final isSelected = selectedRange.value == range;
                                              return InkWell(
                                                onTap: () {
                                                  setState((){
                                                    selectRange(range, isTarget?controllers.targetLeadsFuture:controllers.allNewLeadFuture);
                                                  }
                                                  );
                                                  final leads = controllers.getLeadsByRange(index);
                                                  // here open another dialog to show leads
                                                  // showDialog(
                                                  //   context: context,
                                                  //   builder: (context) {
                                                  //     return AlertDialog(
                                                  //       title: Text("Leads in $range"),
                                                  //       content: SizedBox(
                                                  //         height: 300,
                                                  //         width: 400,
                                                  //         child: ListView.builder(
                                                  //           itemCount: leads.length,
                                                  //           itemBuilder: (context, i) {
                                                  //             final lead = leads[i];
                                                  //             return ListTile(
                                                  //               title: Text(lead.firstname ?? ""),
                                                  //               subtitle: Text(lead.mobileNumber ?? ""),
                                                  //             );
                                                  //           },
                                                  //         ),
                                                  //       ),
                                                  //     );
                                                  //   },
                                                  // );
                                                },
                                                child: Container(
                                                  height: 40,
                                                  margin: const EdgeInsets.all(5),
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                  decoration: BoxDecoration(
                                                    color: isSelected ? Colors.blue : Colors.transparent,
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(color: Colors.blue),
                                                  ),
                                                  child: Center(child: CustomText(text: range,colors: colorsConst.textColor,isCopy: false,)),
                                                ),
                                              );
                                            },
                                          );
                                        }),
                                      ),
                                      10.height,
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          CustomText(
                                            text: "Total Selected Customers: $total",
                                            colors: colorsConst.textColor,
                                            size: 16,
                                            isBold: true,
                                            isCopy: true,
                                          ),
                                          CustomText(
                                            text: "Customers with Mail: $withMail",
                                            colors: colorsConst.textColor,
                                            size: 16,
                                            isBold: true,
                                            isCopy: true,
                                          ),
                                          CustomText(
                                            text: "Customers without Mail: $withoutMail",
                                            colors: colorsConst.textColor,
                                            size: 16,
                                            isBold: true,
                                            isCopy: true,
                                          ),
                                        ],
                                      ),
                                      10.height,
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
                                            isCopy: false,
                                          ),
                                          10.width,
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
                                      SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            Obx(()=>imageController.photo1.value.isEmpty?0.height:
                                            Image.memory(base64Decode(imageController.photo1.value),
                                              fit: BoxFit.cover,width: 80,height: 80,),),
                                            SizedBox(
                                              width: 650,
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
                                      //     : UnconstrainedBox(
                                      //   child: Container(
                                      //     width: 500,
                                      //     alignment: Alignment.center,
                                      //     decoration: BoxDecoration(
                                      //       color: colorsConst.secondary,
                                      //       borderRadius:
                                      //       BorderRadius.circular(10),
                                      //     ),
                                      //     child: SingleChildScrollView(
                                      //       child: Column(
                                      //         children: [
                                      //           SizedBox(
                                      //             width: 500,
                                      //             height: 210,
                                      //             child: Table(
                                      //               defaultColumnWidth:
                                      //               const FixedColumnWidth(
                                      //                   120.0),
                                      //               border: TableBorder.all(
                                      //                   color: Colors
                                      //                       .grey.shade300,
                                      //                   style:
                                      //                   BorderStyle.solid,
                                      //                   borderRadius:
                                      //                   BorderRadius
                                      //                       .circular(10),
                                      //                   width: 1),
                                      //               children: [
                                      //                 TableRow(
                                      //                     children: [
                                      //                       CustomText(
                                      //                         textAlign: TextAlign.center,
                                      //                         text: "\nTemplate Name\n",
                                      //                         colors: colorsConst.textColor,
                                      //                         size: 15,
                                      //                         isBold: true,
                                      //                       ),
                                      //                       CustomText(
                                      //                         textAlign:
                                      //                         TextAlign.center,
                                      //                         text: "\nSubject\n",
                                      //                         colors: colorsConst
                                      //                             .textColor,
                                      //                         size: 15,
                                      //                         isBold: true,
                                      //                       ),
                                      //                     ]),
                                      //                 utils.emailRow(
                                      //                     context,
                                      //                     isCheck: controllers.isAdd,
                                      //                     templateName:
                                      //                     "Promotional",
                                      //                     msg:
                                      //                     "Dear $name,\n \nWe hope this email finds you in good spirits.\n \nWe are excited to announce a special promotion exclusively for you! [Briefly describe the promotion, e.g., discount, free trial, bundle offer, etc.]. This offer is available for a limited time only, so be sure to take advantage of it while you can!\n \nAt $coName, we strive to provide our valued customers with exceptional value and service. We believe this promotion will further enhance your experience with us.\n \nDo not miss out on this fantastic opportunity! [Include a call-to-action, e.g., \"Shop now,\" \"Learn more,\" etc.]\n \nThank you for your continued support. We look forward to serving you.\n \nWarm regards,\n \nAnjali\nManager\n$mobile",
                                      //                     subject:
                                      //                     "Exclusive Promotion for You - \nLimited Time Offer!"),
                                      //                 utils.emailRow(
                                      //                     context,
                                      //                     isCheck: controllers.isAdd,
                                      //                     templateName: "Follow-Up",
                                      //                     msg: "Dear $name,\n \nI hope this email finds you well.\n \nI wanted to follow up on our recent interaction regarding [briefly mention the nature of the interaction, e.g., service request, inquiry, etc.]. We value your feedback and are committed to ensuring your satisfaction.\n \nPlease let us know if everything is proceeding smoothly on your end, or if there are any further questions or concerns you like to address. Our team is here to assist you every step of the way.\n \nThank you for choosing $coName. We appreciate the opportunity to serve you.\n \nBest regards,\n \nAnjali\nManager\n$mobile",
                                      //                     subject: "Follow-up on Recent Service Interaction"),
                                      //                 utils.emailRow(context,
                                      //                     msg:
                                      //                     "Dear $name,\n \nWe hope this email finds you well.\n \nWe are writing to inform you of an update regarding our services. [Briefly describe the update or enhancement]. We believe this will [mention the benefit or improvement for the customer].\n \nPlease feel free to [contact us/reach out] if you have any questions or need further assistance regarding this update.\n \nThank you for choosing $coName. We appreciate your continued support.\n \nBest regards,\n \nAnjali\nManager\n$mobile",
                                      //                     isCheck:
                                      //                     controllers.isAdd,
                                      //                     templateName:
                                      //                     "Service Update",
                                      //                     subject:
                                      //                     "Service Update - [Brief Description]"),
                                      //               ],
                                      //             ),
                                      //           ),
                                      //           // 10.height,
                                      //           // CustomLoadingButton(
                                      //           //   callback: (){},
                                      //           //   isImage: false,
                                      //           //   isLoading: false,
                                      //           //   backgroundColor: colorsConst.primary,
                                      //           //   radius: 20,
                                      //           //   width: 70,
                                      //           //   height: 30,
                                      //           //   text: "Done",
                                      //           //   textColor: Colors.white,
                                      //           //
                                      //           // ),
                                      //         ],
                                      //       ),
                                      //     ),
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      )),
                );
              });
        });
  }

  Future<void> showPromoteDialog({
    required BuildContext context,
    required String pageName,
    required VoidCallback onSubmit,
  }) {
    return showDialog(
      context: context,
      builder: (context) {
        TextEditingController reasonController = TextEditingController();
        String dropValue = pageName == "Prospects"
            ? "Qualified"
            : pageName == "Qualified"
            ? "Customers"
            : "Prospects";
        String selectedStage = dropValue;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                "Move to Next Level",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Select Stage", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: DropdownButton<String>(
                      value: selectedStage,
                      isExpanded: true,
                      underline: SizedBox(),
                      items: [
                        "Prospects",
                        "Qualified",
                        "Customers"
                      ].map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                      onChanged: (value) {
                        setState(() => selectedStage = value!);
                      },
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: reasonController,
                    decoration: InputDecoration(
                      labelText: "Reason",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
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
                            isCopy: false,
                            colors: colorsConst.primary,
                            size: 14,
                          )),
                    ),
                    10.width,
                    CustomLoadingButton(
                      callback: onSubmit,
                      height: 35,
                      isLoading: true,
                      backgroundColor:
                      colorsConst.primary,
                      radius: 2,
                      width: 80,
                      controller:
                      controllers.productCtr,
                      isImage: false,
                      text: "Promote",
                      textColor: Colors.white,
                    ),
                  ],
                )
              ],
            );
          },
        );
      },
    );
  }



// void bulkTargetEmailDialog(FocusNode focusNode, {required List<Map<String, String>> list}) {
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
  //                 backgroundColor: colorsConst.primary,
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
  //                                         width: 17, height: 17)),
  //                                 IconButton(
  //                                     onPressed: () {},
  //                                     icon: SvgPicture.asset(
  //                                       assets.i,
  //                                       width: 15,
  //                                       height: 15,
  //                                     )),
  //                                 IconButton(
  //                                     onPressed: () {},
  //                                     icon: SvgPicture.asset(
  //                                       assets.u,
  //                                       width: 19,
  //                                       height: 19,
  //                                     )),
  //                                 IconButton(
  //                                     onPressed: () {},
  //                                     icon: SvgPicture.asset(
  //                                       assets.fileFilter,
  //                                       width: 17,
  //                                       height: 17,
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
  //                                     icon: SvgPicture.asset(assets.file)),
  //                                 IconButton(
  //                                     onPressed: () {},
  //                                     icon: SvgPicture.asset(
  //                                       assets.layer,
  //                                       width: 17,
  //                                       height: 17,
  //                                     )),
  //                                 IconButton(
  //                                     onPressed: () {},
  //                                     icon: SvgPicture.asset(assets.a)),
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
  //                                         final ranges = controllers.targetLeadRanges;
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
  //                                                   selectRange(range, controllers.targetLeadsFuture);
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
  //                                                 height: 40,
  //                                                 margin: const EdgeInsets.all(5),
  //                                                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  //                                                 decoration: BoxDecoration(
  //                                                   color: isSelected ? Colors.blue : Colors.transparent,
  //                                                   borderRadius: BorderRadius.circular(8),
  //                                                   border: Border.all(color: Colors.blue),
  //                                                 ),
  //                                                 child: Center(child: CustomText(text: range,colors: colorsConst.textColor,)),
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
}
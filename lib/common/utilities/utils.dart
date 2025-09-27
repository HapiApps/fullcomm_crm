import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:csc_picker_plus/dropdown_with_search.dart';
import 'package:excel/excel.dart' as excel;
import 'package:fullcomm_crm/common/styles/styles.dart';
import 'package:fullcomm_crm/common/widgets/log_in.dart';
import 'package:fullcomm_crm/screens/call_comments.dart';
import 'package:fullcomm_crm/screens/employee/employee_screen.dart';
import 'package:fullcomm_crm/screens/leads/prospects.dart';
import 'package:fullcomm_crm/screens/leads/qualified.dart';
import 'package:fullcomm_crm/screens/leads/suspects.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fullcomm_crm/screens/mail_comments.dart';
import 'package:fullcomm_crm/screens/meeting_comments.dart';
import 'package:fullcomm_crm/screens/new_dashboard.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unique_simple_bar_chart/data_models.dart';
import 'package:unique_simple_bar_chart/simple_bar_chart.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/screens/customer/view_customer.dart';
import '../../components/custom_alert_dialog.dart';
import '../../components/custom_loading_button.dart';
import '../../components/custom_sidebar_text.dart';
import '../../components/custom_text.dart';
import '../../components/dialog_button.dart';
import '../../controller/controller.dart';
import '../../controller/image_controller.dart';
import '../../models/new_lead_obj.dart';
import '../../screens/leads/disqualified_lead.dart';
import '../../services/api_services.dart';
import '../constant/assets_constant.dart';
import '../constant/colors_constant.dart';
import '../constant/default_constant.dart';
import '../widgets/camera.dart';
import 'dart:html' as html;

final Utils utils = Utils._();

class Utils {
  Utils._();
  Widget headingBox({double? width, String? text}) {
    return Container(
      alignment: Alignment.center,
      width: width,
      height: 50,
      decoration: BoxDecoration(
          color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8)),
      child: CustomText(
        textAlign: TextAlign.center,
        colors: colorsConst.primary,
        size: 18,
        isBold: true,
        text: text.toString(),
      ),
    );
  }
  void bulkEmailDialog(FocusNode focusNode, {required List<Map<String, String>> list}) {
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
      e.emailId != null &&
          e.emailId!.trim().isNotEmpty &&
          e.emailId!.trim() != "null").length;
      withoutMail = total - withMail;
      apiService.prospectsList.addAll(
        subList.where((data) =>
        data.emailId != null &&
            data.emailId!.trim().isNotEmpty &&
            data.emailId!.trim() != "null") // mail check
            .map((data) => {
          "lead_id": data.userId.toString(),
          "user_id": controllers.storage.read("id"),
          "rating": data.rating ?? "Warm",
          "cos_id": controllers.storage.read("cos_id"),
          "mail_id": data.emailId!.split("||")[0]
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
                                          color: colorsConst.primary,
                                          width: 17, height: 17)),
                                  IconButton(
                                      onPressed: () {},
                                      icon: SvgPicture.asset(
                                        assets.i,
                                        width: 15,
                                        height: 15,
                                        color: colorsConst.primary,
                                      )),
                                  IconButton(
                                      onPressed: () {},
                                      icon: SvgPicture.asset(
                                        assets.u,
                                        width: 19,
                                        height: 19,
                                        color: colorsConst.primary,
                                      )),
                                  IconButton(
                                      onPressed: () {},
                                      icon: SvgPicture.asset(
                                        assets.fileFilter,
                                        width: 17,
                                        height: 17,
                                        color: colorsConst.primary,
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
                                      icon: SvgPicture.asset(assets.file,color: colorsConst.primary,)),
                                  IconButton(
                                      onPressed: () {},
                                      icon: SvgPicture.asset(
                                        assets.layer,
                                        width: 17,
                                        height: 17,
                                        color: colorsConst.primary,
                                      )),
                                  IconButton(
                                      onPressed: () {},
                                      icon: SvgPicture.asset(assets.a,color: colorsConst.primary,)),
                                ],
                              ),
                            ),
                            Obx(() => CustomLoadingButton(
                              callback: () {
                                if(apiService.prospectsList.isEmpty){
                                  apiService.errorDialog(
                                      context, "Please Select range to send email.");
                                  controllers.emailCtr.reset();
                                  return;
                                }
                                List<Map<String, String>> withMail = apiService.prospectsList.where((e) {
                                  final mail = e["mail_id"];
                                  return mail != null && mail.trim().isNotEmpty && mail.trim() != "null";
                                }).toList();
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
                                          final ranges = controllers.leadRanges;
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
                                                    selectRange(range, controllers.allNewLeadFuture);
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
                                                  height: 44,
                                                  margin: const EdgeInsets.all(5),
                                                  padding: const EdgeInsets.all(5),
                                                  decoration: BoxDecoration(
                                                    color: isSelected ? Colors.blue : Colors.transparent,
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(color: Colors.blue),
                                                  ),
                                                  child: Center(child: CustomText(text: range,colors: isSelected ?Colors.white:colorsConst.textColor,)),
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
                                          ),
                                          CustomText(
                                            text: "Customers with Mail: $withMail",
                                            colors: colorsConst.textColor,
                                            size: 16,
                                            isBold: true,
                                          ),
                                          CustomText(
                                            text: "Customers without Mail: $withoutMail",
                                            colors: colorsConst.textColor,
                                            size: 16,
                                            isBold: true,
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
                                                            isCheck: controllers
                                                                .isAdd,
                                                            templateName:
                                                                "Follow-Up",
                                                            msg:
                                                                "Dear $name,\n \nI hope this email finds you well.\n \nI wanted to follow up on our recent interaction regarding [briefly mention the nature of the interaction, e.g., service request, inquiry, etc.]. We value your feedback and are committed to ensuring your satisfaction.\n \nPlease let us know if everything is proceeding smoothly on your end, or if there are any further questions or concerns you like to address. Our team is here to assist you every step of the way.\n \nThank you for choosing $coName. We appreciate the opportunity to serve you.\n \nBest regards,\n \nAnjali\nManager\n$mobile",
                                                            subject:
                                                                "Follow-up on Recent Service Interaction"),
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

  Widget barChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 10,
        barGroups: [
          makeGroupData(0, 5),
          makeGroupData(1, 6),
          makeGroupData(2, 8),
          makeGroupData(3, 2),
          makeGroupData(4, 5),
          makeGroupData(5, 7),
        ],
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                const style = TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                );
                var conData = "";
                Widget text(String text) {
                  return CustomText(
                    text: text,
                    colors: Colors.black,
                    size: 12,
                  );
                }

                ;
                switch (value.toInt()) {
                  case 0:
                    conData = 'Mon';
                    break;
                  case 1:
                    conData = 'Tue';
                    break;
                  case 2:
                    conData = 'Wed';
                    break;
                  case 3:
                    conData = 'Thur';
                    break;
                  case 4:
                    conData = 'Fri';
                    break;
                  case 5:
                    conData = 'Sat';
                    break;
                  default:
                    conData = '';
                    break;
                }
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8.0, // margin between the chart and the titles
                  child: text(conData),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipPadding: const EdgeInsets.all(5),
            tooltipBorder: const BorderSide(color: Colors.grey),
          ),
        ),
        gridData: const FlGridData(show: false),
      ),
    );
  }

  BarChartGroupData makeGroupData(int x, double y) {
    return BarChartGroupData(
      barsSpace: 4,
      x: x,
      barRods: [
        BarChartRodData(
          color: Colors.cyanAccent,
          width: 20,
          toY: y,
        )
      ],
    );
  }

  makingWebsite({String? web}) async {
    final url = Uri.parse('https://www.$web.com');
    if (!await launchUrl(url, mode: LaunchMode.inAppWebView)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> pickImage() async {
    XFile? pickedFile;
    try {
      pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    } on Exception catch (e) {
      // Handle exception
      log('Image capture failed: $e');
    }

    if (pickedFile != null) {
      imageController.photo1.value = pickedFile.path;
    }
  }

  Widget imageContainer(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        showImagePickerDialog(context);
      },
      child: Stack(
        children: [
          Obx(
            () => Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.all(8),
                child: imageController.photo1.value == ""
                    ? Image.asset(assets.addStall)
                    : Image.file(
                        File(imageController.photo1.value),
                        fit: BoxFit.fill,
                      )),
          ),
          Obx(
            () => imageController.photo1.value == ""
                ? const SizedBox()
                : Positioned(
                    bottom: 100,
                    right: 0.7,
                    left: 100,
                    child: Card(
                      color: Colors.white,
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(35.0),
                      ),
                      child: ClipOval(
                        child: Material(
                          color: Colors.red,
                          child: InkWell(
                            splashColor: Colors.redAccent,
                            child: const SizedBox(
                              width: 35,
                              height: 35,
                              child: Icon(
                                Icons.remove_circle_outline,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            onTap: () {
                              imageController.photo1.value = "";
                              imageController.imagePath1 = "";
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
          const Positioned(
            bottom: 5,
            right: 5,
            child: Icon(
              Icons.camera_alt,
              size: 25,
            ),
          )
        ],
      ),
    );
  }

  // String _formatTime12Hour(TimeOfDay time,BuildContext context){
  //   int hour = time.hourOfPeriod;
  //   String period = time.period == DayPeriod.am ? 'AM' : 'PM';
  //
  //   String hourStr = hour.toString().padLeft(2, '0');
  //   String minuteStr = time.minute.toString().padLeft(2, '0');
  //
  //   return '$hourStr:$minuteStr $period';
  // }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> snackBar(
      {required BuildContext context,
      required String msg,
      required Color color}) {
    var snack = SnackBar(
        width: 500,
        content: Center(child: Text(msg)),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        backgroundColor: color,
        //margin: const EdgeInsets.all(50),
        elevation: 30,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))));
    return ScaffoldMessenger.of(context).showSnackBar(
      snack,
    );
  }

  // Widget leadCon(
  //     BuildContext context,int index,String id,String mainName,String mainMobile,String mainEmail,String companyName,
  // String status,String rating,String emailUpdate,String name,String title,String mobileNumber,String whatsappNumber,
  // String email,String mainTitle,String addressId,String companyWebsite,String companyNumber,String companyEmail,
  // String industry,String productServices,String source,String owner,String budget,String timelineDecision,
  // String serviceInterest,String description,String leadStatus,String active,String addressLine1,String addressLine2,
  // String area,String city,String state,String country,String pinCode){
  //   return Container(
  //     width: MediaQuery.of(context).size.width/4.5,
  //     height: 245,
  //     decoration: BoxDecoration(
  //       color: colorsConst.secondary,
  //       borderRadius: BorderRadius.circular(2)
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children:[
  //         10.height,
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children:[
  //             CustomText(
  //               text: "       $mainName",
  //               isBold: true,
  //               colors: colorsConst.textColor,
  //               size: 18,
  //             ),
  //             Container(
  //               width:32,
  //               alignment: Alignment.center,
  //               child: CustomCheckBox(
  //                   text: "",
  //                   onChanged: (value){
  //                     setState(() {
  //                       if(controllers.isNewLeadList[widget.index!]==true){
  //                         controllers.isNewLeadList[widget.index!]=false;
  //                         var i=apiService.prospectsList.indexWhere((element) => element["lead_id"]==widget.id.toString());
  //                         apiService.prospectsList.removeAt(i);
  //                       }else{
  //                         controllers.isNewLeadList[widget.index!]=true;
  //                         apiService.prospectsList.add({
  //                           "lead_id":widget.id.toString(),
  //                           "user_id":controllers.storage.read("id"),
  //                           "rating":widget.rating.toString(),
  //                           "cos_id":cosId,
  //                         });
  //                       }
  //                       print(apiService.prospectsList);
  //                     });
  //                     },
  //                   saveValue: controllers.isNewLeadList[widget.index!]),
  //             ),
  //           ],
  //         ),
  //         CustomText(
  //           text: "       $mainMobile",
  //           colors: colorsConst.textColor,
  //           size: 16,
  //         ),
  //         10.height,
  //         CustomText(
  //           text: "       $mainEmail",
  //           colors: colorsConst.textColor,
  //           size: 16,
  //         ),
  //         10.height,
  //         CustomText(
  //           text: "       $city",
  //           colors: colorsConst.textColor,
  //           size: 16,
  //         ),
  //         10.height,
  //         CustomText(
  //           text: "        $companyName",
  //           colors: colorsConst.textColor,
  //           size: 15,
  //           isBold: true,
  //         ),
  //         10.height,
  //         CustomText(
  //           text: "        $status",
  //           colors: colorsConst.third,
  //           size: 16,
  //           isBold: true,
  //         ),
  //         10.height,
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.end,
  //           children:[
  //             Container(
  //               width: 150,
  //               height: 25,
  //               alignment: Alignment.center,
  //               decoration: BoxDecoration(
  //                 color: Color(0xffAFC8D9),
  //                 borderRadius: BorderRadius.circular(10)
  //               ),
  //               child: CustomText(
  //                 text: emailUpdate,
  //                 colors: colorsConst.primary,
  //                 size: 12,
  //                 isBold: true,
  //               ),
  //             ),
  //             5.width,
  //             const CircleAvatar(
  //               radius: 15,
  //               backgroundColor: Color(0xffAFC8D9),
  //               child: Icon(Icons.call,color: Colors.black,size: 18,),
  //             ),
  //             5.width
  //           ],
  //         ),
  //         10.height
  //       ],
  //     ),
  //   );
  // }
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

  Widget sideBarFunction(BuildContext context) {
    return Obx(() => controllers.isLeftOpen.value
        ? Container(
      width: 145,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            //spreadRadius: 10,
            blurRadius: 2,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            5.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Tooltip(
                  message: "Click to close the side panel.",
                  child: InkWell(
                    focusColor: Colors.transparent,
                    onTap: (){
                      controllers.isLeftOpen.value=!controllers.isLeftOpen.value;
                    },
                    child: CircleAvatar(
                      backgroundColor: colorsConst.secondary,
                      child: Icon(Icons.chevron_left,color: Colors.black,),
                    ),
                  ),
                ),
              ],
            ),
           Image.asset("assets/images/logo.png"),
           // Text(
           //    appName,
           //    style: TextStyle(
           //      color: colorsConst.primary,
           //      fontWeight: FontWeight.bold,
           //      fontSize: 20,
           //      fontFamily: "Lato",
           //    ),
           //  ),
            //20.height,
            Obx(() => CustomSideBarText(
                  text: constValue.dashboard,
                  boxColor: controllers.selectedIndex.value == 0
                    ? const Color(0xffF3F8FD)
                    : Colors.white,
                  textColor: controllers.selectedIndex.value == 0
                      ? colorsConst.primary
                      : Colors.black,
                  onClicked: () {
                    controllers.oldIndex.value = controllers.selectedIndex.value;
                    controllers.selectedIndex.value = 0;
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                        const NewDashboard(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  }),
            ),
            Obx(() => CustomSideBarText(
                boxColor: controllers.selectedIndex.value == 1
                    ? const Color(0xffF3F8FD)
                    : Colors.white,
                  textColor: controllers.selectedIndex.value == 1
                      ? colorsConst.primary
                      : Colors.black,
                  text: "Suspects",
                  onClicked: () {
                    controllers.isLead.value = true;
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                        const Suspects(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                    controllers.oldIndex.value = controllers.selectedIndex.value;
                    controllers.selectedIndex.value = 1;
                  }),
            ),
            Obx(() => CustomSideBarText(
                boxColor: controllers.selectedIndex.value == 2
                    ? const Color(0xffF3F8FD)
                    : Colors.white,
                  textColor: controllers.selectedIndex.value == 2
                      ? colorsConst.primary
                      : Colors.black,
                  text: "Prospects",
                  onClicked: () {
                    //controllers.isLead.value=true;
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                        const Prospects(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                    controllers.oldIndex.value = controllers.selectedIndex.value;
                    controllers.selectedIndex.value = 2;
                  }),
            ),
            Obx(() => CustomSideBarText(
                      boxColor: controllers.selectedIndex.value == 3
                          ? const Color(0xffF3F8FD)
                          : Colors.white,
                  textColor: controllers.selectedIndex.value == 3
                      ? colorsConst.primary
                      : Colors.black,
                  text: "Qualified",
                  onClicked: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                        const Qualified(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                    controllers.isEmployee.value = true;
                    controllers.oldIndex.value = controllers.selectedIndex.value;
                    controllers.selectedIndex.value = 3;
                  }),
            ),
            Obx(() => CustomSideBarText(
                boxColor: controllers.selectedIndex.value == 4
                    ? const Color(0xffF3F8FD)
                    : Colors.white,
                  textColor: controllers.selectedIndex.value == 4
                      ? colorsConst.primary
                      : Colors.black,
                  text: constValue.customer,
                  onClicked: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                        const ViewCustomer(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                    controllers.isCustomer.value = true;
                    controllers.oldIndex.value = controllers.selectedIndex.value;
                    controllers.selectedIndex.value = 4;
                  }),
            ),
            Obx(() => CustomSideBarText(
                      boxColor: controllers.selectedIndex.value == 5
                          ? const Color(0xffF3F8FD)
                          : Colors.white,
                  textColor: controllers.selectedIndex.value == 5
                      ? colorsConst.primary
                      : Colors.black,
                  text: "Disqualified",
                  onClicked: () {
                    Navigator.push(context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                        const DisqualifiedLead(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                    //controllers.isDisqualified.value = true;
                    controllers.oldIndex.value = controllers.selectedIndex.value;
                    controllers.selectedIndex.value = 5;
                  }),
            ),
            Obx(() => CustomSideBarText(
                boxColor: controllers.selectedIndex.value == 6
                    ? const Color(0xffF3F8FD)
                    : Colors.white,
                textColor: controllers.selectedIndex.value == 6
                    ? colorsConst.primary
                    : Colors.black,
                text: "Call Records",
                onClicked: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                      const CallComments(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                  controllers.oldIndex.value = controllers.selectedIndex.value;
                  controllers.selectedIndex.value = 6;
                }),
            ),
            Obx(() => CustomSideBarText(
                boxColor: controllers.selectedIndex.value == 7
                    ? const Color(0xffF3F8FD)
                    : Colors.white,
                textColor: controllers.selectedIndex.value == 7
                    ? colorsConst.primary
                    : Colors.black,
                text: "Mail Records",
                onClicked: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                      const MailComments(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                  controllers.oldIndex.value = controllers.selectedIndex.value;
                  controllers.selectedIndex.value = 7;
                }),
            ),
            Obx(() => CustomSideBarText(
                boxColor: controllers.selectedIndex.value == 8
                    ? const Color(0xffF3F8FD)
                    : Colors.white,
                textColor: controllers.selectedIndex.value == 8
                    ? colorsConst.primary
                    : Colors.black,
                text: "Meeting Records",
                onClicked: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                      const MeetingComments(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                  controllers.oldIndex.value = controllers.selectedIndex.value;
                  controllers.selectedIndex.value = 8;
                }),
            ),
            Obx(() => CustomSideBarText(
                boxColor: controllers.selectedIndex.value == 9
                    ? const Color(0xffF3F8FD)
                    : Colors.white,
                textColor: controllers.selectedIndex.value == 9
                    ? colorsConst.primary
                    : Colors.black,
                text: "Employees",
                onClicked: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                      const EmployeeScreen(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                  controllers.oldIndex.value = controllers.selectedIndex.value;
                  controllers.selectedIndex.value = 9;
                }),
            ),
            Obx(() => CustomSideBarText(
                      boxColor: controllers.selectedIndex.value == 10
                          ? const Color(0xffF3F8FD)
                          : Colors.white,
                  textColor: controllers.selectedIndex.value == 10
                      ? colorsConst.primary
                      : Colors.black,
                  text: "LogOut",
                  onClicked: () async {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                               Text(
                                "Do you want to log out?",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: colorsConst.textColor,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
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
                                      final prefs = await SharedPreferences.getInstance();
                                      prefs.setBool("loginScreen${controllers.versionNum}", false);
                                      prefs.setBool("isAdmin", false);
                                      Get.to(const LoginPage(), duration: Duration.zero);
                                      //controllers.isEmployee.value=true;
                                      controllers.selectedIndex.value = 7;
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
                            ],
                          ),
                        );
                      },
                    );
                  }),
            ),
            //100.height
          ],
        ),
      ),
    )
        : Container(
            width: 60,
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.fromLTRB(6, 8, 0, 0),
            alignment: Alignment.topCenter,
            color: Colors.white,
            child: Tooltip(
              message: "Click to view the side panel",
              child: InkWell(
                focusColor: Colors.transparent,
                onTap: () {
                  controllers.isLeftOpen.value = !controllers.isLeftOpen.value;
                },
               child: CircleAvatar(
                 backgroundColor: colorsConst.secondary,
                 child: Icon(Icons.menu,color: Colors.black,),
               ),
              ),
            ),
          ));
  }
  void showBlockedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Screenshot Blocked"),
        content: const Text("Screenshots are not allowed on this website."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
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


  Widget leadFirstCon(String image, String count, String day) {
    return Container(
      width: 150,
      height: 140,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: Colors.transparent, borderRadius: BorderRadius.circular(10)),
      child: Column(
        //crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                width: 75,
                height: 75,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: colorsConst.primary,
                    borderRadius: BorderRadius.circular(50),
                    border:
                        Border.all(color: const Color(0xff5D5FEF), width: 2.4)),
                child: CustomText(
                  text: count,
                  colors: colorsConst.textColor,
                  size: 20,
                  isBold: true,
                ),
              ),
              const Positioned(
                bottom: 1,
                right: 15,
                child: CircleAvatar(
                  radius: 5,
                  backgroundColor: Color(0xff5D5FEF),
                ),
              )
            ],
          ),
          // Row(
          //   children:[
          //     10.width,
          //     CustomText(
          //       text: count,
          //       size: 25,
          //       isBold: true,
          //       colors: colorsConst.textColor,
          //     ),
          //   ],
          // ),
          5.height,
          CustomText(
            text: day,
            size: 15,
            colors: colorsConst.textColor,
          ),
          10.height,
          // Row(
          //   children:[
          //     10.width,
          //     const CustomText(
          //       text: "+8% from yesterday",
          //       size: 14,
          //       colors: Color(0xff5D5FEF),
          //     ),
          //   ],
          // ),
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
                padding: const EdgeInsets.fromLTRB(0, 10, 180, 0),
                child: Tooltip(
                  message: "Click to close the side panel.",
                  child: Obx(()=>InkWell(
                      focusColor: Colors.transparent,
                      onTap: (){
                        controllers.isRightOpen.value=!controllers.isRightOpen.value;
                      },
                      // icon: Icon(controllers.isRightOpen.value?Icons.arrow_forward_ios:Icons.arrow_back_ios,
                      //   color: colorsConst.third,)
                    child: CircleAvatar(
                      backgroundColor: colorsConst.secondary,
                      child: Icon(controllers.isRightOpen.value?Icons.chevron_right:
                      Icons.chevron_left,color: Colors.black,),
                    )
                  ),
                  ),
                ),
              ),
              Stack(
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
                      child: Obx(() => CustomText(
                          text: "${controllers.leadCategoryList.isEmpty ? "" : controllers.leadCategoryList[0]["value"]}\n${controllers.allNewLeadsLength.value}",
                          colors: controllers.selectedIndex.value == 1
                              ? Colors.black
                              : colorsConst.textColor,
                          size: 15,
                          isBold: true,
                        ),
                      ))
                ],
              ),
              Stack(
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
                      child: Obx(
                            () => CustomText(
                          text:
                          "${controllers.leadCategoryList.isEmpty ? "" : controllers.leadCategoryList[1]["value"]}\n${controllers.allLeadsLength.value}",
                          colors: controllers.selectedIndex.value == 2
                              ? Colors.black
                              : colorsConst.textColor,
                          size: 15,
                          isBold: true,
                        ),
                      ))
                ],
              ),
              Stack(
                children: [
                  Obx(
                        () => Image.asset(
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
                            () => CustomText(
                          text:
                          "${controllers.leadCategoryList.isEmpty ? "" : controllers.leadCategoryList[2]["value"]}\n${controllers.allGoodLeadsLength.value}",
                          colors: controllers.selectedIndex.value == 3
                              ? Colors.black
                              : colorsConst.textColor,
                          size: 15,
                          isBold: true,
                        ),
                      ))
                ],
              ),
              Stack(
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
                      child: Obx(
                            () => CustomText(
                          text:
                          "Customers\n${controllers.allCustomerLength.value}",
                          colors: controllers.selectedIndex.value == 4
                              ? Colors.black
                              : colorsConst.textColor,
                          size: 13,
                          isBold: true,
                        ),
                      ))
                ],
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

      // controllers.empDOB.value=;
      // controllers.empDOJ.value=;
      // if(utils.isAdult()==false){
      //   controllers.empDOB.value="";
      // }

      // date.value= ("${(controllers.dateTime.year.toString())}-"
      //     "${(controllers.dateTime.month.toString().padLeft(2,"0"))}-"
      //     "${(controllers.dateTime.day.toString().padLeft(2,"0"))}");
    });
  }

  bool isAdult() {
    String birthDateString = controllers.emDOBController.text;

    String datePattern = "dd-mm-yyyy";

    DateTime birthDate = DateFormat(datePattern).parse(birthDateString);
    DateTime today = DateTime.now();

    int yearDiff = today.year - birthDate.year;
    int monthDiff = today.month - birthDate.month;
    int dayDiff = today.day - birthDate.day;

    return yearDiff > 18 || yearDiff == 18 && monthDiff >= 0 && dayDiff >= 0;
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

  //Add a country to country list
  void addCountryToList(data) {
    // var model = Country();
    // model.name = data['name'];
    // model.emoji = data['emoji'];
    // //if (!mounted) return;
    // //setState(() {
    //   CountryFlag.DISABLE == CountryFlag.ENABLE ||
    //       CountryFlag.DISABLE == CountryFlag.SHOW_IN_DROP_DOWN_ONLY
    //       ? controllers.allCountry.add("${model.emoji!}    ${model.name!}") /* : _country.add(model.name)*/
    //       : controllers.allCountry.add(model.name);
    // });
  }

  Future<dynamic> getResponse() async {
    var res = await rootBundle
        .loadString('packages/csc_picker/lib/assets/country.json');
    return jsonDecode(res);
  }

  //get countries from json response
  Future<List<String?>> getCountries() async {
    controllers.allCountry.clear();
    var countries = await getResponse() as List;
    for (var data in countries) {
      addCountryToList(data);
    }
    return controllers.allCountry;
  }

  ///get states from json response
  Future<List<String?>> getStates() async {
    controllers.allStates.clear();
    //print(_selectedCountry);
    var response = await getResponse();
    // var takeState = CountryFlag.DISABLE == CountryFlag.ENABLE ||
    //     CountryFlag.DISABLE == CountryFlag.SHOW_IN_DROP_DOWN_ONLY
    //     ? response
    //     .map((map) => Country.fromJson(map))
    //     .where(
    //         (item) => item.emoji + "    " + item.name == controllers.selectedCountry.value)
    //     .map((item) => item.state)
    //     .toList()
    //     : response
    //     .map((map) => Country.fromJson(map))
    //     .where((item) => item.name == controllers.selectedCountry.value)
    //     .map((item) => item.state)
    //     .toList();
    var states = [];
    for (var f in states) {
      // setState(() {
      var name = f.map((item) => item.name).toList();
      for (var stateName in name) {
        //print(stateName.toString());
        controllers.allStates.add(stateName.toString());
      }
      //});
    }
    controllers.allStates.sort((a, b) => a!.compareTo(b!));
    return controllers.allStates;
  }

  ///get cities from json response
  Future<List<String?>> getCities() async {
    controllers.allCities.clear();
    var response = await getResponse();
    // var takeCity = CountryFlag.DISABLE == CountryFlag.ENABLE ||
    //     CountryFlag.DISABLE == CountryFlag.SHOW_IN_DROP_DOWN_ONLY
    //     ? response
    //     .map((map) => Country.fromJson(map))
    //     .where(
    //         (item) => item.emoji + "    " + item.name == controllers.selectedCountry.value)
    //     .map((item) => item.state)
    //     .toList()
    //     : response
    //     .map((map) => Country.fromJson(map))
    //     .where((item) => item.name == controllers.selectedCountry.value)
    //     .map((item) => item.state)
    //     .toList();
    var cities = [];
    for (var f in cities) {
      var name =
          f.where((item) => item.name == controllers.selectedState.value);
      var cityName = name.map((item) => item.city).toList();
      cityName.forEach((ci) {
        var citiesName = ci.map((item) => item.name).toList();
        for (var cityName in citiesName) {
          //print(cityName.toString());
          controllers.allCities.add(cityName.toString());
        }
      });
    }
    controllers.allCities.sort((a, b) => a!.compareTo(b!));
    return controllers.allCities;
  }

  void _onSelectedCountry(
      String value,
      TextEditingController cityController,
      TextEditingController stateController,
      TextEditingController countryController) {
    // if (CountryFlag.DISABLE == CountryFlag.SHOW_IN_DROP_DOWN_ONLY) {
    //   try {
    //     value.substring(6).trim();
    //   } catch (e) {print(e);}
    // } else {
    //   value;
    // }
    //code added in if condition
    if (value != controllers.selectedCountry.value) {
      controllers.allStates.clear();
      controllers.allCities.clear();
      controllers.selectedState.value = "State";
      controllers.selectedCity.value = "City";
      null;
      null;
      controllers.selectedCountry.value = value;
      countryController.text = controllers.selectedCountry.value;
      print("country ${controllers.selectedCountry}");
      stateController.text = "";
      cityController.text = "";
      getStates();
    } else {
      controllers.selectedState;
      controllers.selectedCity;
      stateController.text = controllers.selectedState.value;
      cityController.text = controllers.selectedCity.value;
    }
  }

  Future<void> _onSelectedState(
      String value,
      TextEditingController cityController,
      TextEditingController stateController) async {
    value;
    try {
      if (value != controllers.selectedState.value) {
        controllers.allCities.clear();
        null;
        controllers.selectedState.value = value;
        stateController.text = controllers.selectedState.value;
        cityController.text = "";
        await getCities();
        controllers.selectedCity.value = controllers.allCities.first.toString();
      } else {
        controllers.selectedCity.value;
        cityController.text = controllers.selectedCity.value;
      }
    } catch (e) {
      print("e $e");
    }
  }

  void onSelectedCity(String value, TextEditingController cityController) {
    if (value != controllers.selectedCity.value) {
      controllers.selectedCity.value = value;
      cityController.text = controllers.selectedCity.value;
      print(controllers.coCityController.text);
      value;
      // controllers.selectPinCodeList = controllers.pinCodeList
      //     .where((location) =>
      // location["STATE"] == controllers.selectedState &&
      //     location["DISTRICT"] == controllers.selectedCity)
      //     .map((location) => location["PINCODE"])
      //     .toList();
    }
  }

  Widget headerCell({
    required double width,
    required String text,
    required bool isSortable,
    required String fieldName,
    void Function()? onSortAsc,
    void Function()? onSortDesc,
    required RxString sortField,
    required RxString sortOrder,
  }) {
    return Container(
      width: width,
      height: 50,
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomText(
            text: text,
            size: 15,
            isBold: true,
            colors: Colors.white,
          ),
          if (isSortable) ...[
            Obx(() => GestureDetector(
              onTap: onSortAsc,
              child: Icon(
                Icons.arrow_upward,
                size: 16,
                color: (sortField.value == fieldName &&
                    sortOrder.value == 'asc')
                    ? colorsConst.third // highlight color
                    : Colors.grey, // default color
              ),
            )),
            Obx(() => GestureDetector(
              onTap: onSortDesc,
              child: Icon(
                Icons.arrow_downward,
                size: 16,
                color: (sortField.value == fieldName &&
                    sortOrder.value == 'desc')
                    ? colorsConst.third
                    : Colors.grey,
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget dataCell({required double width, required String text}) {
    return Tooltip(
      message: text=="null"?"":text,
      child: Container(
        width: width,
        height: 50,
        padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
        alignment: Alignment.center,
        child: CustomText(
          text: text,
          size: 14,
          colors: colorsConst.textColor,
        ),
      ),
    );
  }
  ///Country Dropdown Widget

  Widget countryDropdown(
      double width,
      TextEditingController cityController,
      TextEditingController stateController,
      TextEditingController countryController) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        25.width,
        SizedBox(
          width: width,
          height: 50,
          child: Obx(() => DropdownWithSearch(
                title: "",
                placeHolder: "",
                selectedItemStyle:
                    customStyle.textStyle(colors: Colors.white, size: 14),
                dropdownHeadingStyle: customStyle.textStyle(
                  colors: Colors.white,
                  size: 17,
                  isBold: true,
                ),
                itemStyle:
                    customStyle.textStyle(colors: Colors.white, size: 14),
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                    color: Colors.transparent,
                    border: Border.all(color: Colors.grey.shade200, width: 1)),
                disabledDecoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                    color: Colors.transparent,
                    border: Border.all(color: Colors.grey.shade200, width: 1)),
                disabled: false,
                dialogRadius: 10.0,
                searchBarRadius: 10.0,
                label: "Country",
                items: controllers.allCountry.map((String? dropDownStringItem) {
                  return dropDownStringItem;
                }).toList(),
                selected: controllers.selectedCountry.value,
                //selected: _selectedCountry != null ? _selectedCountry : "Country",
                //onChanged: (value) => _onSelectedCountry(value),
                onChanged: (value) {
                  if (value != null) {
                    _onSelectedCountry(value, cityController, stateController,
                        countryController);
                  }
                },
              )),
        ),
      ],
    );
  }

  ///State Dropdown Widget
  Widget stateDropdown(
      double width,
      TextEditingController cityController,
      TextEditingController stateController,
      TextEditingController countryController) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        25.width,
        SizedBox(
            width: width,
            height: 50,
            child: Obx(
              () => DropdownWithSearch(
                title: "",
                placeHolder: "",
                disabled: controllers.allStates.isEmpty ? true : false,
                items: controllers.allStates.map((String? dropDownStringItem) {
                  return dropDownStringItem;
                }).toList(),
                selectedItemStyle:
                    customStyle.textStyle(colors: Colors.white, size: 14),
                dropdownHeadingStyle: customStyle.textStyle(
                    colors: Colors.white, size: 17, isBold: true),
                itemStyle:
                    customStyle.textStyle(colors: Colors.black, size: 14),
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                    color: Colors.transparent,
                    border: Border.all(color: Colors.grey.shade200, width: 1)),
                disabledDecoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                    color: Colors.transparent,
                    border: Border.all(color: Colors.grey.shade200, width: 1)),
                dialogRadius: 10.0,
                searchBarRadius: 10.0,
                selected: controllers.selectedState.value,
                label: "",
                //onChanged: (value) => _onSelectedState(value),
                onChanged: (value) {
                  //print("stateChanged $value $_selectedState");
                  value != null
                      ? _onSelectedState(value, cityController, stateController)
                      : _onSelectedState(controllers.selectedState.value,
                          cityController, stateController);
                },
              ),
            )),
      ],
    );
  }

  ///City Dropdown Widget
  Widget cityDropdown(
      double width,
      TextEditingController cityController,
      TextEditingController stateController,
      TextEditingController countryController,
      ValueChanged<String?>? onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        25.width,
        SizedBox(
            width: width,
            height: 50,
            child: Obx(
              () => DropdownWithSearch(
                  title: "",
                  placeHolder: "",
                  disabled: controllers.allCities.isEmpty ? true : false,
                  items:
                      controllers.allCities.map((String? dropDownStringItem) {
                    return dropDownStringItem;
                  }).toList(),
                  selectedItemStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  dropdownHeadingStyle: customStyle.textStyle(
                      colors: Colors.white, isBold: true, size: 17),
                  itemStyle:
                      customStyle.textStyle(colors: Colors.black, size: 14),
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      color: Colors.transparent,
                      border:
                          Border.all(color: Colors.grey.shade200, width: 1)),
                  disabledDecoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      color: Colors.transparent,
                      border:
                          Border.all(color: Colors.grey.shade200, width: 1)),
                  dialogRadius: 10.0,
                  searchBarRadius: 10.0,
                  selected: controllers.selectedCity.value,
                  label: "",
                  //onChanged: (value) => _onSelectedCity(value),
                  onChanged: onChanged!),
            )),
      ],
    );
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

  Future<void> showImagePickerDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: constValue.img,
          onPressed: () async {
            imageController.imagePath1 = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const CameraWidget(
                        cameraPosition: CameraType.back,
                      )),
            );
            imageController.photo1.value = imageController.imagePath1;
            Get.back(); // Close the dialog
          },
          positiveBtnText: constValue.gallery,
          cancelOnPressed: () async {
            pickImage();
            Navigator.pop(context); // Close the dialog
          },
        );
      },
    );
  }

  void pickAndReadExcelFile(BuildContext context) {
    final html.FileUploadInputElement input = html.FileUploadInputElement()
      ..accept = '.xlsx, .xls';
    input.click();

    input.onChange.listen((event) {
      final file = input.files!.first;
      final reader = html.FileReader();

      reader.readAsArrayBuffer(file);
      reader.onLoadEnd.listen((event) {
        Uint8List bytes = reader.result as Uint8List;
        parseExcelFile(bytes, context);
      });
    });
  }

  List<Map<String, dynamic>> customerData = [];
  List<Map<String, dynamic>> mCustomerData = [];

  // void parseExcelFile(Uint8List bytes, BuildContext context) async {
  //   customerData = [];
  //   var excelD = excel.Excel.decodeBytes(bytes);
  //
  //   Map<String, List<String>> keyMapping = {
  //     "company_name": ["NAME OF THE CUSTOMER", "CUSTOMER NAME", "CLIENT NAME", "CUSTOMER"],
  //     "city": ["SITE LOCATION DETAILS", "City", "Location"],
  //     "lead_status": ["LEAD / PROSPECT"],
  //     "status": ["CURRENT STATUS"],
  //     "details_of_service_required": ["DETAILS OF SERVICES REQUIRED"],
  //     "owner": ["NAME OF THE ACCOUNT MANAGER", "Owner"],
  //     "prospect_enrollment_date": ["PROSPECT ENROLLMENT DATE"],
  //     "expected_convertion_date": ["EXPECTED CONVERSION DATE"],
  //     "status_update": ["STATUS UPDATE"],
  //     "num_of_headcount": ["TOTAL NUMBER OF HEAD COUNT"],
  //     "expected_billing_value": ["EXPECTED MONTHLY BILLING VALUE"],
  //     "arpu_value": ["ARPU VALUE"],
  //     "name": ["KEY CONTACT PERSON", "Name"],
  //     "email": ["EMAIL ID", "Email"],
  //     "phone_no": ["CONTACT NUMBER", "Phone No", "Mobile No", "Number"],
  //     "source": ["SOURCE OF PROSPECT (either BNI or social)"],
  //     "source_details": ["PROSPECT SOURCE DETAILS"],
  //     "rating": ["PROSPECT GRADING"],
  //   };
  //
  //   for (var table in excelD.tables.keys) {
  //     var rows = excelD.tables[table]!.rows;
  //     List<String> headers = rows.first
  //         .map((cell) => (cell?.value.toString().trim().toUpperCase()) ?? "")
  //         .toList();
  //
  //     for (var i = 1; i < rows.length; i++) {
  //       var row = rows[i];
  //       Map<String, dynamic> rowData = {};
  //       Map<String, dynamic> formattedData = {};
  //       List<Map<String, String>> additionalFields = [];
  //
  //       bool isRowEmpty = row.every((cell) =>
  //       cell == null || cell.value == null || cell.value.toString().trim().isEmpty);
  //       if (isRowEmpty) continue;
  //
  //       // Fill rowData with header→value mapping
  //       for (var j = 0; j < headers.length; j++) {
  //         String header = headers[j];
  //         rowData[header] = row[j]?.value;
  //       }
  //
  //       // Map fields into formattedData + capture extras
  //       rowData.forEach((key, value) {
  //         bool matched = false;
  //         for (var entry in keyMapping.entries) {
  //           if (entry.value
  //               .map((e) => e.toUpperCase().trim())
  //               .contains(key.toUpperCase().trim())) {
  //             matched = true;
  //
  //             if (entry.key == "rating") {
  //               formattedData[entry.key] = (value != null && value.toString().trim().isNotEmpty)
  //                   ? value.toString().trim()
  //                   : "WARM";
  //             } else if (entry.key == "prospect_enrollment_date") {
  //               if (value == null ||
  //                   value.toString().trim().isEmpty ||
  //                   value.toString().trim().toLowerCase() == "null") {
  //                 formattedData[entry.key] =
  //                     DateFormat('dd.MM.yyyy').format(DateTime.now());
  //               } else {
  //                 formattedData[entry.key] = value.toString().trim();
  //               }
  //             } else {
  //               formattedData[entry.key] =
  //               (value == null || value.toString().trim().isEmpty || value.toString().trim().toLowerCase() == "null")
  //                   ? ""
  //                   : value.toString().trim();
  //             }
  //           }
  //         }
  //
  //         // Extra field → additional_fields
  //         if (!matched) {
  //           additionalFields.add({
  //             "field_name": key,
  //             "field_value": value?.toString().trim() ?? "",
  //           });
  //         }
  //       });
  //
  //       if (rowData.keys.any((k) => k.toUpperCase().trim() == "CONTACT NUMBER")) {
  //         formattedData["whatsapp_no"] = rowData.entries.firstWhere(
  //               (e) => e.key.toUpperCase().trim() == "CONTACT NUMBER",
  //           orElse: () => const MapEntry("", null),
  //         ).value;
  //       }
  //
  //       // Extra fields common
  //       formattedData["user_id"] = controllers.storage.read("id");
  //       formattedData["cos_id"] = cosId;
  //       formattedData["door_no"] = "";
  //       formattedData["area"] = "";
  //       formattedData["country"] = "India";
  //       formattedData["state"] = "Tamil Nadu";
  //       formattedData["pincode"] = "";
  //       formattedData["product_discussion"] = "";
  //       formattedData["discussion_point"] = "";
  //       formattedData["points"] = "";
  //       formattedData["department"] = "";
  //       formattedData["designation"] = "";
  //       if (!formattedData.containsKey("source")) {
  //         formattedData["source"] = "";
  //       }
  //
  //       // Attach additional fields
  //       formattedData["additional_fields"] = additionalFields;
  //
  //       // Validate and add to list
  //       if ((formattedData["phone_no"] != null &&
  //           formattedData["phone_no"].toString().isNotEmpty) ||
  //           (formattedData["name"] != null &&
  //               formattedData["name"].toString().isNotEmpty)) {
  //         customerData.add(formattedData);
  //       } else {
  //         if (formattedData["email"] != null &&
  //             formattedData["email"].toString().isNotEmpty) {
  //           customerData.add(formattedData);
  //         } else {
  //           mCustomerData.add(formattedData);
  //         }
  //       }
  //     }
  //   }
  //
  //   print("mCustomerData ${mCustomerData.length}");
  //   print("customerData ${customerData.length}");
  //
  //   if (customerData.isEmpty) {
  //     Navigator.of(context).pop();
  //     showDialog(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //         backgroundColor: colorsConst.primary,
  //         content: SingleChildScrollView(
  //           child: Text(
  //             "Some entries under KEY CONTACT PERSON and CONTACT NUMBER are empty in your Excel sheet. Please check and re-upload.",
  //             style: TextStyle(
  //               color: colorsConst.textColor,
  //               fontSize: 16,
  //             ),
  //             textAlign: TextAlign.left,
  //             softWrap: true,
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.of(context).pop(),
  //             child: CustomText(
  //               text: "OK",
  //               colors: colorsConst.textColor,
  //               size: 16,
  //             ),
  //           ),
  //         ],
  //       ),
  //     );
  //     return;
  //   } else {
  //     await apiService.insertCustomersAPI(context, customerData);
  //   }
  // }
  void parseExcelFile(Uint8List bytes, BuildContext context) async {
    customerData = [];
    var excelD = excel.Excel.decodeBytes(bytes);

    for (var table in excelD.tables.keys) {
      var rows = excelD.tables[table]!.rows;

      if (rows.length < 6) {
        Navigator.of(context).pop();
        apiService.errorDialog(context, "Excel format is invalid. Needs min 6 rows (3 empty, system, display, data).");
        return;
      }

      // ✅ Check first 3 rows are empty
      for (int i = 0; i < 3; i++) {
        bool isRowEmpty = rows[i].every((cell) =>
        cell == null || cell.value == null || cell.value.toString().trim().isEmpty);
        if (!isRowEmpty) {
          Navigator.of(context).pop();
          apiService.errorDialog(context, "Excel format invalid. First 3 rows must be empty.");
          return;
        }
      }

      // ✅ Row 4 = system keys
      List<String> systemKeys = rows[3]
          .map((c) => (c?.value?.toString().trim() ?? ""))
          .toList();

      if (systemKeys.every((e) => e.isEmpty)) {
        Navigator.of(context).pop();
        apiService.errorDialog(context, "Excel format invalid. Row 4 (system fields) cannot be empty.");
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
        formattedData["additional_fields"] = additionalFields;

        customerData.add(formattedData);
      }

      // 🔽 Final Payload
      Map<String, dynamic> finalPayload = {
        "field_mappings": fieldMappings,
        "cusList": customerData,
      };

      print("Payload: ${jsonEncode(finalPayload)}");

      await apiService.insertCustomersAPI(context, customerData, fieldMappings);
    }
  }

  // void parseExcelFile(Uint8List bytes, BuildContext context) async {
  //   customerData = [];
  //   var excelD = excel.Excel.decodeBytes(bytes);
  //
  //   for (var table in excelD.tables.keys) {
  //     var rows = excelD.tables[table]!.rows;
  //
  //     if (rows.length < 6) {
  //       print("Excel needs min 6 rows (3 empty, system, display, data)");
  //       return;
  //     }
  //
  //     // Row 4 = system keys (index 3)
  //     List<String> systemKeys = rows[3]
  //         .map((c) => (c?.value?.toString().trim() ?? ""))
  //         .toList();
  //
  //     // Row 5 = display names (index 4)
  //     List<String> displayNames = rows[4]
  //         .map((c) => (c?.value?.toString().trim() ?? ""))
  //         .toList();
  //
  //     // Build field mappings
  //     List<Map<String, String>> fieldMappings = [];
  //     for (int i = 0; i < systemKeys.length; i++) {
  //       if (systemKeys[i].isNotEmpty) {
  //         fieldMappings.add({
  //           "cos_id": controllers.storage.read("cos_id"),
  //           "system_field": systemKeys[i],
  //           "display_name": (i < displayNames.length && displayNames[i].isNotEmpty)
  //               ? displayNames[i]
  //               : systemKeys[i],
  //           "created_by": controllers.storage.read("id").toString(),
  //         });
  //       }
  //     }
  //
  //     // Parse data rows (from row 6 → index 5 onwards)
  //     for (var i = 5; i < rows.length; i++) {
  //       var row = rows[i];
  //       bool isRowEmpty = row.every((cell) =>
  //       cell == null || cell.value == null || cell.value.toString().trim().isEmpty);
  //       if (isRowEmpty) continue;
  //
  //       Map<String, dynamic> formattedData = {};
  //       List<Map<String, String>> additionalFields = [];
  //
  //       for (int j = 0; j < systemKeys.length; j++) {
  //         String key = systemKeys[j];
  //         var value = row[j]?.value?.toString().trim() ?? "";
  //
  //         if (key.isNotEmpty) {
  //           formattedData[key] = value;
  //         } else {
  //           additionalFields.add({
  //             "field_name": (j < displayNames.length) ? displayNames[j] : "",
  //             "field_value": value,
  //           });
  //         }
  //       }
  //
  //       formattedData["user_id"] = controllers.storage.read("id");
  //       formattedData["cos_id"] = controllers.storage.read("cos_id");
  //       formattedData["additional_fields"] = additionalFields;
  //
  //       customerData.add(formattedData);
  //     }
  //
  //     // Final Payload
  //     Map<String, dynamic> finalPayload = {
  //       "field_mappings": fieldMappings,
  //       "cusList": customerData,
  //     };
  //
  //     print("Payload: ${jsonEncode(finalPayload)}");
  //
  //     await apiService.insertCustomersAPI(context, customerData, fieldMappings);
  //   }
  // }
  Future<void> downloadSampleExcel() async {
    final data = await rootBundle.load("assets/easycrm_data_upload_template.xlsx");
    final blob = html.Blob([data.buffer.asUint8List()]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "easycrm_data_upload_template.xlsx")
      ..click();

    html.Url.revokeObjectUrl(url);
  }

  Future<void> showImportDialog(BuildContext context) async {
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
                      "In this CRM template, \n1. Place your column names on Row 5. This will appear in EasyCRM as Heading.\n2. Place your data from Row 6. \n3. Pick the CRM internal field designators from Row 4 and place it over correct heading on Row 5.\n4. Save the sheet and upload to EasyCRM and start managing your Leads and Customers.",
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
                        downloadSampleExcel();
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
                    pickAndReadExcelFile(context);
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
                      "A new version of CRM is available! \nCurrent:${controllers.versionNum} -> Latest:${controllers.serverVersion}",
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

}

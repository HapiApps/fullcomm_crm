import 'dart:convert';
import 'package:http/http.dart'as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/common/utilities/utils.dart';
import 'package:intl/intl.dart';
import 'package:fullcomm_crm/screens/leads/view_lead.dart';
import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/constant/colors_constant.dart';
import 'package:fullcomm_crm/components/custom_checkbox.dart';
import 'package:fullcomm_crm/components/custom_text.dart';
import 'package:fullcomm_crm/controller/controller.dart';
import 'package:get/get.dart';
import 'package:fullcomm_crm/screens/records/mail_comments.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common/constant/api.dart';
import '../common/utilities/jwt_storage.dart';
import '../controller/table_controller.dart';
import '../screens/records/cus_mail_comments.dart';
import '../screens/leads/update_lead.dart';
import '../screens/records/records.dart';
import '../services/api_services.dart';
import 'custom_loading_button.dart';

class CustomLeadTile extends StatefulWidget {
  final bool showCheckbox;
  final String pageName;
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

  const CustomLeadTile(
      {super.key,
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
      this.index,
      this.linkedin,
      this.x,
      this.quotationRequired,
      this.arpuValue,
      this.expectedBillingValue,
      this.expectedConvertionDate,
      this.numOfHeadcount,
      this.prospectEnrollmentDate,
      this.sourceDetails,
      this.statusUpdate,
      required this.onChanged,
      required this.saveValue,
      required this.updatedTs,
      this.visitType,
      this.points,
      this.detailsOfServiceReq,
      required this.pageName});

  @override
  State<CustomLeadTile> createState() => _CustomLeadTileState();
}

class _CustomLeadTileState extends State<CustomLeadTile> {
  String formatDate(String inputDate) {
    try {
      DateTime parsedDate = DateFormat("yyyy-MM-dd HH:mm:ss").parse(inputDate);
      return DateFormat("dd MMM yyyy h:mm a").format(parsedDate);
    } catch (e1) {
      try {
        DateTime parsedDate = DateFormat("dd.MM.yyyy").parse(inputDate);
        return DateFormat("dd MMM yyyy h:mm a").format(parsedDate);
      } catch (e2) {
        return inputDate;
      }
    }
  }


  Map<String, dynamic> toJson() {
    return {
      "id": widget.id,
      "mainName": widget.mainName,
      "mainMobile": widget.mainMobile,
      "mainEmail": widget.mainEmail,
      "mainWhatsApp": widget.mainWhatsApp,
      "company_name": widget.companyName,
      "status": widget.status,
      "rating": widget.rating,
      "emailUpdate": widget.emailUpdate,
      "name": widget.mainName,
      "title": widget.title,
      "mobile_number": widget.mainMobile,
      "whatsappNumber": widget.whatsappNumber,
      "email": widget.email,
      "mainTitle": widget.mainTitle,
      "addressId": widget.addressId,
      "companyWebsite": widget.companyWebsite,
      "companyNumber": widget.companyNumber,
      "companyEmail": widget.companyEmail,
      "industry": widget.industry,
      "productServices": widget.productServices,
      "source": widget.source,
      "owner": widget.owner,
      "budget": widget.budget,
      "timelineDecision": widget.timelineDecision,
      "serviceInterest": widget.serviceInterest,
      "description": widget.description,
      "lead_status": widget.leadStatus == "1"
          ? "Suspects"
          : widget.leadStatus == "2"
          ? "Prospects"
          : widget.leadStatus == "3"
          ? "Qualified"
          : "Customers",
      "active": widget.active,
      "addressLine1": widget.addressLine1,
      "addressLine2": widget.addressLine2,
      "area": widget.area,
      "city": widget.city,
      "state": widget.state,
      "country": widget.country,
      "pinCode": widget.pinCode,
      "linkedin": widget.linkedin,
      "x": widget.x,
      "quotationStatus": widget.quotationStatus,
      "product_discussion": widget.productDiscussion,
      "discussion_point": widget.discussionPoint,
      "notes": widget.notes,
      "quotationRequired": widget.quotationRequired,
      "arpu_value": widget.arpuValue,
      "source_details": widget.sourceDetails,
      "prospect_enrollment_date": widget.prospectEnrollmentDate,
      "expected_convertion_date": widget.expectedConvertionDate,
      "status_update": widget.statusUpdate,
      "num_of_headcount": widget.numOfHeadcount,
      "expected_billing_value": widget.expectedBillingValue,
      "visit_type": widget.visitType,
      "points": widget.points,
      "details_of_service_required": widget.detailsOfServiceReq,
      "updatedTs": widget.updatedTs,
    };
  }

  late TextEditingController statusController;
  late Map<String, TextEditingController> fieldControllers;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    statusController = TextEditingController(
        text: widget.statusUpdate.toString() == "null"
            ? ""
            : widget.statusUpdate.toString());
        final data = toJson();

        fieldControllers = {};

        data.forEach((key, value) {
          fieldControllers[key] =
              TextEditingController(text: value?.toString() ?? "");
        });
  }

  @override
  void didUpdateWidget(covariant CustomLeadTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.statusUpdate != widget.statusUpdate) {
      statusController.text = widget.statusUpdate.toString() == "null"
          ? ""
          : widget.statusUpdate.toString();
    }
  }

  @override
  void dispose() {
    for (final c in fieldControllers.values) {
      c.dispose();
    }
    statusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final int totalColumns = tableController.tableHeadings.length + 1 + (widget.showCheckbox ? 1 : 0);
    // final Map<int, TableColumnWidth> columnWidths = {}; // Company / next
    // for (int i = 0; i < totalColumns; i++) {
    //   columnWidths[i] = const FlexColumnWidth(2);
    // }
    return Obx((){
      final headings = tableController.tableHeadings;
      final displayHeadings = headings.skip(1).toList();
      final Map<int, TableColumnWidth> columnWidths = {};
      int idx = 0;
      for (final h in displayHeadings) {
        final w = tableController.colWidth[h] ?? 150.0;
        columnWidths[idx++] = FixedColumnWidth(w.toDouble());
      }
      if (tableController.isTableLoading.value) {
        return SizedBox(
          height: 60,
          child: Center(child: CircularProgressIndicator()),
        );
      }
      return tableController.isTableLoading.value?CircularProgressIndicator():
      InkWell(
        onTap: () {
          Get.to(
              ViewLead(
                pageName: widget.pageName,
                id: widget.id,
                companyName: widget.companyName,
                status: widget.status,
                rating: widget.rating,
                name: widget.name,
                mobileNumber: widget.mobileNumber,
                whatsAppNo: widget.whatsappNumber.toString(),
                email: widget.email,
                addressId: widget.addressId,
                source: "",
                owner: "",
                addressLine1: widget.addressLine1,
                addressLine2: widget.addressLine2,
                area: widget.area,
                city: widget.city,
                state: widget.state,
                country: widget.country,
                pinCode: widget.pinCode,
                notes: widget.notes.toString(),
                updateTs: widget.updatedTs,
                sourceDetails: widget.sourceDetails.toString(),
              ),
              duration: Duration.zero);
        },
        child: Table(
          columnWidths: columnWidths,
          border: TableBorder(
            horizontalInside: BorderSide(width: 0.5, color: Colors.grey.shade400),
            verticalInside: BorderSide(width: 0.5, color: Colors.grey.shade400),
            bottom: BorderSide(width: 0.5, color: Colors.grey.shade400),
          ),
          children: [
            TableRow(
                decoration: BoxDecoration(
                  color: int.parse(widget.index.toString()) % 2 == 0
                      ? Colors.white
                      : colorsConst.backgroundColor,
                ),
                children: [
                  ...displayHeadings.map((heading) {
                    if (heading.toLowerCase() == "added date" ||
                        heading.toLowerCase() == "prospect enrollment date") {
                      return Container(
                        height: 45,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: CustomText(
                          textAlign: TextAlign.left,
                          text: formatDate(widget.updatedTs.toString()),
                          size: 14,
                          colors: colorsConst.textColor,
                          isCopy: false,
                        ),
                      );
                    }
                    // else if (heading.toLowerCase() == "status update") {
                    //   return Tooltip(
                    //     message: widget.statusUpdate.toString() == "null"
                    //         ? ""
                    //         : widget.statusUpdate.toString(),
                    //     child: Container(
                    //       height: 45,
                    //       alignment: Alignment.centerLeft,
                    //       padding:
                    //       const EdgeInsets.only(left: 6, right: 5, bottom: 5),
                    //       child: TextField(
                    //         controller: statusController,
                    //         cursorColor: colorsConst.textColor,
                    //         style: TextStyle(
                    //           color: colorsConst.textColor,
                    //           fontSize: 14,
                    //           fontFamily: "Lato",
                    //         ),
                    //         decoration: const InputDecoration(border: InputBorder.none),
                    //         onSubmitted: (value) async {
                    //           apiService.updateLeadStatusUpdateAPI(
                    //             context,
                    //             widget.id.toString(),
                    //             widget.mainMobile.toString(),
                    //             value,
                    //           );
                    //         },
                    //       ),
                    //     ),
                    //   );
                    // }
                    else {
                      String normalize(String s) =>
                          s.replaceAll(RegExp(r'\s+'), ' ').trim().toLowerCase();
                      final key = controllers.fields
                          .firstWhereOrNull((f) => normalize(f.userHeading) == normalize(heading))
                          ?.systemField;
                      final column = controllers.fields
                          .firstWhereOrNull((f) => normalize(f.systemField) == normalize(heading))
                          ?.systemField;
                      // print(controllers.fields.first.systemField);
                      final controller =key != null ? fieldControllers[key] : null;
                      return Tooltip(
                        message: controller?.text ?? "",
                        // child: Container(
                        //   height: 45,
                        //   alignment: Alignment.centerLeft,
                        //   padding: const EdgeInsets.symmetric(horizontal: 5),
                        //   child: CustomText(
                        //     textAlign: TextAlign.left,
                        //     text: value.toString() == "null" ? "" : value.toString(),
                        //     size: 14,
                        //     colors: colorsConst.textColor,
                        //     isCopy: false,
                        //   ),
                        // ),
                        child:  Container(
                          height: 45,
                          alignment: Alignment.centerLeft,
                          padding:
                          const EdgeInsets.only(left: 6, right: 5, bottom: 5),
                          child: TextField(
                            controller: controller,
                            cursorColor: colorsConst.textColor,
                            style: TextStyle(
                              color: colorsConst.textColor,
                              fontSize: 14,
                              fontFamily: "Lato",
                            ),
                            decoration: const InputDecoration(border: InputBorder.none),
                            onSubmitted: (value) async {
                              var send="";
                              for (var i=0;i<controllers.defaultFields.length;i++){
                                if(column==controllers.defaultFields[i]["system_field"]){
                                  send=controllers.defaultFields[i]["system_field"].toString();
                                  break;
                                }
                              }
                                  if(controller!.text.isNotEmpty){
                                    // apiService.updateInstantChanges(
                                    //   context,
                                    //   leadId: widget.id.toString(),
                                    //   column: column.toString(),
                                    //   value:
                                    //   controller.text,
                                    // );
                                    updateLeadAPI(context);
                                  }else{
                                    utils.snackBar(context: context, msg: "Enter a value", color: Colors.red);
                                  }

                            },
                          ),
                        ),
                      );
                    }
                  }),
                ]),
          ],
        ),
      );
    }
    );
  }
  String getVal(String key) {
    return fieldControllers[key]?.text.trim() ?? "";
  }

  Future updateLeadAPI(BuildContext context) async {
    try {
      // Map data = {
      //   "cos_id": controllers.storage.read("cos_id"),
      //   "city": widget.city,
      //   "source": widget.source,
      //   "source_details": widget.sourceDetails,
      //   "product_discussion": widget.productDiscussion,
      //   "linkedin": widget.linkedin,
      //   "x": widget.x,
      //   "door_no": widget.addressLine1,
      //   "area": widget.area,
      //   "country": widget.country,
      //   "state": widget.state,
      //   "pincode": widget.pinCode,
      //   "industry": widget.industry,
      //   "points": widget.points,
      //   'status_update': widget.statusUpdate,
      //   'details_of_service_required': widget.detailsOfServiceReq,
      //   "expected_billing_value": widget.expectedBillingValue,
      //   "arpu_value": widget.arpuValue,
      //   "num_of_headcount": widget.numOfHeadcount,
      //   'prospect_enrollment_date': widget.prospectEnrollmentDate,
      //   'expected_convertion_date': widget.expectedConvertionDate,
      //   'owner': widget.owner,
      //   "status": widget.status,
      //   'rating': widget.rating,
      //   "name": widget.mainName,
      //   "title": widget.title,
      //   "phone_no": widget.mainMobile,
      //   "whatsapp_number": widget.whatsappNumber,
      //   "email": widget.email,
      //   "action": "update_customer",
      //
      //   // "product": controllers.leadProduct.text.trim(),
      //   "company_name": widget.companyName,
      //   "co_website": widget.companyWebsite,
      //   "co_number": widget.companyNumber,
      //   "co_email": widget.companyEmail,
      //   "address_id": widget.addressId,
      //   "lead_id": widget.id,
      // };
      Map data = {
        "cos_id": controllers.storage.read("cos_id"),

        "city": getVal("city"),
        "source": getVal("source"),
        "source_details": getVal("source_details"),
        "product_discussion": getVal("product_discussion"),
        "linkedin": getVal("linkedin"),
        "x": getVal("x"),

        "door_no": getVal("addressLine1"),
        "area": getVal("area"),
        "country": getVal("country"),
        "state": getVal("state"),
        "pincode": getVal("pinCode"),

        "industry": getVal("industry"),
        "points": getVal("points"),
        "status_update": getVal("status_update"),
        "details_of_service_required": getVal("details_of_service_required"),

        "expected_billing_value": getVal("expected_billing_value"),
        "arpu_value": getVal("arpu_value"),
        "num_of_headcount": getVal("num_of_headcount"),

        "prospect_enrollment_date": getVal("prospect_enrollment_date"),
        "expected_convertion_date": getVal("expected_convertion_date"),

        "owner": getVal("owner"),
        "status": getVal("status"),
        "rating": getVal("rating"),

        "name": getVal("mainName"),
        "title": getVal("title"),
        "phone_no": getVal("mainMobile"),
        "whatsapp_number": getVal("whatsappNumber"),
        "email": getVal("email"),

        "company_name": getVal("company_name"),
        "co_website": getVal("companyWebsite"),
        "co_number": getVal("companyNumber"),
        "co_email": getVal("companyEmail"),

        "address_id": widget.addressId,
        "lead_id": widget.id,
        "action": "update_customer",
      };
      final request = await http.post(
        Uri.parse(scriptApi),
        body: jsonEncode(data),
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
      );
      // print("update_customer");
      // print(request.body);
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return updateLeadAPI(context);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200 &&
          response["message"] == "Customer updated successfully") {
        utils.snackBar(msg: "Your Lead is updated successfully !",
            color: Colors.green,context:Get.context!);
        Get.back();
        apiService.allNewLeadsDetails();
        apiService.allLeadsDetails();
        apiService.allGoodLeadsDetails();
        controllers.leadCtr.reset();
      } else {
        Navigator.of(context).pop();
        utils.snackBar(context:Get.context!,msg:"Failed", color: Colors.red);
        controllers.leadCtr.reset();
      }
    } catch (e) {
      Navigator.of(context).pop();
      utils.snackBar(context:Get.context!,msg:"Something went wrong, Please try again later", color: Colors.red);
      controllers.leadCtr.reset();
    }
  }

}

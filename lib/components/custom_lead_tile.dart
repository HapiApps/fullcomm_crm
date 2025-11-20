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
import '../common/constant/api.dart';
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
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    statusController = TextEditingController(
        text: widget.statusUpdate.toString() == "null"
            ? ""
            : widget.statusUpdate.toString());
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
                id: widget.id,
                companyName: widget.companyName,
                status: widget.status,
                rating: widget.rating,
                name: widget.name,
                mobileNumber: widget.mobileNumber,
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
                  ...displayHeadings.skip(1).map((heading) {
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
                        ),
                      );
                    } else if (heading.toLowerCase() == "status update") {
                      return Tooltip(
                        message: widget.statusUpdate.toString() == "null"
                            ? ""
                            : widget.statusUpdate.toString(),
                        child: Container(
                          height: 45,
                          alignment: Alignment.centerLeft,
                          padding:
                          const EdgeInsets.only(left: 6, right: 5, bottom: 5),
                          child: TextField(
                            controller: statusController,
                            cursorColor: colorsConst.textColor,
                            style: TextStyle(
                              color: colorsConst.textColor,
                              fontSize: 14,
                              fontFamily: "Lato",
                            ),
                            decoration: const InputDecoration(border: InputBorder.none),
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
                      );
                    } else {
                      String normalize(String s) =>
                          s.replaceAll(RegExp(r'\s+'), ' ').trim().toLowerCase();
                      final key = controllers.fields
                          .firstWhereOrNull((f) => normalize(f.userHeading) == normalize(heading))
                          ?.systemField;
                      final value = key != null ? toJson()[key] ?? "" : "";
                      return Tooltip(
                        message: value.toString() == "null" ? "" : value.toString(),
                        child: Container(
                          height: 45,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: CustomText(
                            textAlign: TextAlign.left,
                            text: value.toString() == "null" ? "" : value.toString(),
                            size: 14,
                            colors: colorsConst.textColor,
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
}

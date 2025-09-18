import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/screens/leads/view_lead.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../common/constant/api.dart';
import '../common/constant/colors_constant.dart';
import '../controller/controller.dart';
import '../services/api_services.dart';
import 'custom_checkbox.dart';
import 'custom_text.dart';

class LeadCon extends StatefulWidget {
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
  String updateTs;
  LeadCon(
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
      this.index,
      this.linkedin,
      this.x,
      this.quotationStatus,
      this.productDiscussion,
      this.discussionPoint,
      this.notes,
      this.quotationRequired,
      this.arpuValue,
      this.sourceDetails,
      this.prospectEnrollmentDate,
      this.expectedConvertionDate,
      this.statusUpdate,
      this.numOfHeadcount,
      this.expectedBillingValue,
      required this.updateTs});

  @override
  State<LeadCon> createState() => _LeadConState();
}

class _LeadConState extends State<LeadCon> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.to(
            ViewLead(
              id: widget.id,
              mainName: widget.mainName,
              linkedin: widget.linkedin,
              x: widget.x,
              mainMobile: widget.mainMobile,
              mainEmail: widget.mainEmail,
              mainWhatsApp: widget.mainWhatsApp,
              companyName: widget.companyName,
              status: widget.status,
              rating: widget.rating,
              emailUpdate: widget.emailUpdate,
              name: widget.name,
              title: widget.title,
              mobileNumber: widget.mobileNumber,
              whatsappNumber: widget.whatsappNumber,
              email: widget.email,
              mainTitle: widget.mainTitle,
              addressId: widget.addressId,
              companyWebsite: widget.companyWebsite,
              companyNumber: widget.companyNumber,
              companyEmail: widget.companyEmail,
              industry: widget.industry,
              productServices: widget.productServices,
              source: widget.source,
              owner: widget.owner,
              budget: widget.budget,
              timelineDecision: widget.timelineDecision,
              serviceInterest: widget.serviceInterest,
              description: widget.description,
              leadStatus: widget.leadStatus,
              active: widget.active,
              addressLine1: widget.addressLine1,
              addressLine2: widget.addressLine2,
              area: widget.area,
              city: widget.city,
              state: widget.state,
              country: widget.country,
              pinCode: widget.pinCode,
              quotationStatus: widget.quotationStatus,
              productDiscussion: widget.productDiscussion,
              discussionPoint: widget.discussionPoint,
              notes: widget.notes.toString(),
              prospectEnrollmentDate: widget.prospectEnrollmentDate ?? "",
              expectedConvertionDate: widget.expectedConvertionDate ?? "",
              numOfHeadcount: widget.numOfHeadcount ?? "",
              expectedBillingValue: widget.expectedBillingValue ?? "",
              arpuValue: widget.arpuValue ?? "",
              updateTs: widget.updateTs,
              sourceDetails: widget.sourceDetails.toString(),
            ),
            duration: Duration.zero);
      },
      child: UnconstrainedBox(
        child: Container(
          width: MediaQuery.of(context).size.width / 4.6,
          //height: 245,
          padding: const EdgeInsets.fromLTRB(10, 5, 5, 5),
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(2)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              10.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    text: widget.mainName == "null"
                        ? ""
                        : widget.mainName.toString(),
                    isBold: true,
                    colors: colorsConst.textColor,
                    size: 18,
                  ),
                  Obx(
                    () => CustomCheckBox(
                        text: "",
                        onChanged: (value) {
                          setState(() {
                            if (widget.leadStatus == "2") {
                              if (controllers.isLeadsList[widget.index!]
                                      ["isSelect"] ==
                                  true) {
                                controllers.isLeadsList[widget.index!]
                                    ["isSelect"] = false;
                                var i = apiService.qualifiedList.indexWhere(
                                    (element) =>
                                        element["lead_id"] ==
                                        widget.id.toString());
                                apiService.qualifiedList.removeAt(i);
                              } else {
                                controllers.isLeadsList[widget.index!]["isSelect"] = true;
                                apiService.qualifiedList.add({
                                  "lead_id": widget.id.toString(),
                                  "user_id": controllers.storage.read("id"),
                                  "rating": widget.rating.toString(),
                                  "cos_id": controllers.storage.read("cos_id"),
                                });
                              }
                              print(apiService.qualifiedList);
                            } else {
                              if (controllers.isGoodLeadList[widget.index!]["isSelect"] == true) {
                                controllers.isGoodLeadList[widget.index!]["isSelect"] = false;
                                var i = apiService.customerList.indexWhere(
                                    (element) => element["lead_id"] == widget.id.toString());
                                apiService.customerList.removeAt(i);
                              } else {
                                controllers.isGoodLeadList[widget.index!]["isSelect"] = true;
                                apiService.customerList.add({
                                  "lead_id": widget.id.toString(),
                                  "user_id": controllers.storage.read("id"),
                                  "rating": widget.rating.toString(),
                                  "cos_id": controllers.storage.read("cos_id"),
                                });
                              }
                              //print(apiService.qualifiedList);
                            }
                          });
                        },
                        saveValue: widget.leadStatus.toString().trim() == "2"
                            ? controllers.isLeadsList.isEmpty
                                ? false
                                : controllers.isLeadsList[widget.index!]["isSelect"]
                            : controllers.isGoodLeadList.isEmpty
                                ? false
                                : controllers.isGoodLeadList[widget.index!]["isSelect"]),
                  )
                ],
              ),
              CustomText(
                text: widget.mainMobile.toString() == "null"
                    ? ""
                    : widget.mainMobile.toString(),
                colors: colorsConst.textColor,
                size: 16,
              ),
              10.height,
              // CustomText(
              //   text: widget.mainEmail=="null"?"":widget.mainEmail.toString(),
              //   colors: colorsConst.textColor,
              //   size: 16,
              // ),

              CustomText(
                text: widget.city == "null" ? "" : widget.city.toString(),
                colors: colorsConst.textColor,
                size: 16,
              ),
              10.height,
              CustomText(
                text: widget.companyName == "null"
                    ? ""
                    : widget.companyName.toString(),
                colors: colorsConst.textColor,
                size: 15,
                isBold: true,
              ),
              10.height,
              CustomText(
                text: controllers.formatDateTime(widget.updateTs.toString()),
                colors: colorsConst.textColor,
                size: 16,
              ),
              10.height,
              widget.emailUpdate == null ||
                      widget.emailUpdate.toString().isEmpty
                  ? 0.height
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 65,
                          height: 20,
                          decoration: BoxDecoration(
                              color: widget.rating.toString().toLowerCase() ==
                                      "cold"
                                  ? const Color(0xffACF3E4)
                                  : widget.rating.toString().toLowerCase() ==
                                          "warm"
                                      ? const Color(0xffCFE9FE)
                                      : const Color(0xffFEDED8),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color:
                                      widget.rating.toString().toLowerCase() ==
                                              "cold"
                                          ? const Color(0xff06A59A)
                                          : widget.rating
                                                      .toString()
                                                      .toLowerCase() ==
                                                  "warm"
                                              ? const Color(0xff0D9DDA)
                                              : const Color(0xffFE5C4C))),
                          alignment: Alignment.center,
                          child: CustomText(
                            text: widget.rating.toString(),
                            colors:
                                widget.rating.toString().toLowerCase() == "cold"
                                    ? const Color(0xff06A59A)
                                    : widget.rating.toString().toLowerCase() ==
                                            "warm"
                                        ? const Color(0xff0D9DDA)
                                        : const Color(0xffFE5C4C),
                            size: 12,
                            isBold: true,
                          ),
                        ),
                        10.width,
                        Container(
                          width: 150,
                          height: 25,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: const Color(0xffAFC8D9),
                              borderRadius: BorderRadius.circular(10)),
                          child: CustomText(
                            text: widget.emailUpdate.toString().isEmpty ||
                                    widget.emailUpdate == "null"
                                ? "No Code Sent"
                                : widget.emailUpdate.toString(),
                            colors: colorsConst.primary,
                            size: 12,
                            isBold: true,
                          ),
                        ),
                        5.width,
                        const CircleAvatar(
                          radius: 15,
                          backgroundColor: Color(0xffAFC8D9),
                          child: Icon(
                            Icons.call,
                            color: Colors.black,
                            size: 18,
                          ),
                        ),
                        5.width
                      ],
                    ),

              10.height
            ],
          ),
        ),
      ),
    );
  }
}

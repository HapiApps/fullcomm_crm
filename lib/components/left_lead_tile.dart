import 'package:flutter_svg/flutter_svg.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/common/utilities/reminder_utils.dart';
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
import '../controller/reminder_controller.dart';
import '../controller/table_controller.dart';
import '../screens/records/cus_mail_comments.dart';
import '../screens/leads/update_lead.dart';
import '../screens/records/records.dart';
import '../services/api_services.dart';
import 'custom_date_box.dart';
import 'custom_loading_button.dart';

class LeftLeadTile extends StatefulWidget {
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

  const LeftLeadTile(
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
  State<LeftLeadTile> createState() => _LeftLeadTileState();
}

class _LeftLeadTileState extends State<LeftLeadTile> {
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
  void didUpdateWidget(covariant LeftLeadTile oldWidget) {
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
    final headings = tableController.tableHeadings;
    final int totalColumns = tableController.tableHeadings.length + 1 + (widget.showCheckbox ? 1 : 0);
    final Map<int, TableColumnWidth> columnWidths = {
      0: FlexColumnWidth(0.6),//santhiya
      1: const FlexColumnWidth(2),
      2: FixedColumnWidth(tableController.colWidth[headings.first] ?? 150),
    };
    //  final Map<int, TableColumnWidth> columnWidths = {};
    // int colIndex = 2;
    // for (int hIndex = 0; hIndex < tableController.tableHeadings.length; hIndex++) {
    //   final heading = tableController.tableHeadings[hIndex];
    //   final width = tableController.colWidth[heading] ?? 150;
    //   columnWidths[colIndex] = FixedColumnWidth(width);
    //   colIndex++;
    // }

    // columnWidths[0] =  widget.showCheckbox?FlexColumnWidth(1):FlexColumnWidth(3); // Actions / checkbox
    // columnWidths[1] = const FlexColumnWidth(1.5); // Name
    // columnWidths[2] = const FlexColumnWidth(2); // Company / next
    // for (int i = 3; i < totalColumns; i++) {
    //   columnWidths[i] = const FlexColumnWidth(2);
    // }
    return Obx(()=>tableController.isTableLoading.value?CircularProgressIndicator():InkWell(
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
            right: BorderSide(width: 0.5, color: Colors.grey.shade400)
        ),
        children: [
          TableRow(
              decoration: BoxDecoration(
                color: int.parse(widget.index.toString()) % 2 == 0
                    ? Colors.white
                    : colorsConst.backgroundColor,
              ),
              children: [
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
                      Tooltip(
                        message: "Edit this customer",
                        child: InkWell(
                            onTap: () {
                              Get.to(UpdateLead(
                                visitType: widget.visitType.toString(),
                                id: widget.id,
                                detailsOfRequired: widget.detailsOfServiceReq,
                                linkedin: widget.linkedin,
                                x: widget.x,
                                mainName: widget.mainName,
                                mainMobile: widget.mobileNumber,
                                mainEmail: widget.email,
                                mainWhatsApp: widget.whatsappNumber,
                                companyName: widget.companyName,
                                status: widget.status,
                                rating: widget.rating,
                                emailUpdate: widget.quotationRequired,
                                name: widget.mainName,
                                title: widget.title,
                                mobileNumber: widget.mobileNumber,
                                whatsappNumber: widget.mobileNumber,
                                email: widget.email,
                                mainTitle: widget.title,
                                addressId: widget.addressId,
                                companyWebsite: widget.companyWebsite,
                                companyNumber: widget.companyNumber,
                                companyEmail: widget.companyEmail,
                                industry: widget.industry,
                                productServices: widget.productServices,
                                source: widget.source,
                                owner: widget.owner,
                                budget: widget.budget,
                                points: widget.points,
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
                                statusUpdate: widget.statusUpdate,
                                prospectEnrollmentDate: widget.prospectEnrollmentDate ?? "",
                                expectedConvertionDate: widget.expectedConvertionDate ?? "",
                                numOfHeadcount: widget.numOfHeadcount ?? "",
                                expectedBillingValue: widget.expectedBillingValue ?? "",
                                arpuValue: widget.arpuValue ?? "",
                                updateTs: widget.updatedTs.toString(),
                                sourceDetails: widget.sourceDetails.toString(),
                              ));
                            },
                            child: SvgPicture.asset(
                              "assets/images/a_edit.svg",
                            )
                        ),
                      ),
                      Tooltip(
                        message: "Set a reminder for this Customer.",
                        child: InkWell(
                            onTap: (){
                              controllers.selectNCustomer(widget.id.toString(), widget.mainName.toString(), widget.mainEmail.toString(),
                                  widget.mainMobile.toString());
                              reminderUtils.showAddReminderDialog(context);
                            },
                            child: SvgPicture.asset(
                              "assets/images/reminder.svg",
                            )),
                      ),
                      /// Extra call icon santhiya
                      Tooltip(
                        message: "Add call log for this Customer.",
                        child: InkWell(
                            onTap: (){
                              controllers.empDOB.value = "";
                              controllers.callTime.value = "";
                              setState(() {
                                controllers.clearSelectedCustomer();
                                controllers.cusController.text = "";
                                controllers.callType = "Outgoing";
                                controllers.callStatus = "Completed";
                              });
                              controllers.callCommentCont.text = "";
                              showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) {
                                    var customerError;
                                    var dateError;
                                    var timeError;
                                    return StatefulBuilder(
                                        builder: (BuildContext context, StateSetter setState){
                                          return  AlertDialog(
                                            title: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                CustomText(
                                                  text: "Add Call log",
                                                  size: 16,
                                                  isBold: true,
                                                  colors: colorsConst.textColor,
                                                  isCopy: true,
                                                ),
                                                IconButton(
                                                    onPressed: (){
                                                      Navigator.of(context).pop();
                                                    },
                                                    icon: Icon(Icons.clear,
                                                      color: Colors.black,
                                                    ))
                                              ],
                                            ),
                                            content: SizedBox(
                                              width: 500,
                                              height: 450,
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    // Divider(),
                                                    // Column(
                                                    //   crossAxisAlignment: CrossAxisAlignment.start,
                                                    //   children: [
                                                    //     Row(
                                                    //       children: [
                                                    //         CustomText(
                                                    //           text:"Customer Name",
                                                    //           colors: colorsConst.textColor,
                                                    //           size: 13,
                                                    //           isCopy: false,
                                                    //         ),
                                                    //         const CustomText(
                                                    //           text: "*",
                                                    //           colors: Colors.red,
                                                    //           size: 25,
                                                    //           isCopy: false,
                                                    //         )
                                                    //       ],
                                                    //     ),
                                                    //     SizedBox(
                                                    //       width: 480,
                                                    //       height: 50,
                                                    //       child: KeyboardDropdownField<AllCustomersObj>(
                                                    //         items: controllers.customers,
                                                    //         borderRadius: 5,
                                                    //         borderColor: Colors.grey.shade300,
                                                    //         hintText: "Customers",
                                                    //         labelText: "",
                                                    //         labelBuilder: (customer) =>'${customer.name}${customer.companyName.isEmpty ? "" : " ,${customer.companyName}"} ${customer.name.isEmpty?"":"-"} ${customer.phoneNo}',
                                                    //         itemBuilder: (customer) {
                                                    //           return Container(
                                                    //             width: 300,
                                                    //             alignment: Alignment.topLeft,
                                                    //             padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                                    //             child: CustomText(
                                                    //               text: '${customer.name}${customer.companyName.isEmpty ? "" : " ,${customer.companyName}"} ${customer.name.isEmpty?"":"-"} ${customer.phoneNo}',
                                                    //               colors: Colors.black,
                                                    //               size: 14,
                                                    //               isCopy: false,
                                                    //               textAlign: TextAlign.start,
                                                    //             ),
                                                    //           );
                                                    //         },
                                                    //         textEditingController: controllers.cusController,
                                                    //         onSelected: (value) {
                                                    //           controllers.selectCustomer(value);
                                                    //         },
                                                    //         onClear: () {
                                                    //           controllers.clearSelectedCustomer();
                                                    //         },
                                                    //       ),
                                                    //     ),
                                                    //     if (customerError != null)
                                                    //       Padding(
                                                    //         padding: const EdgeInsets.only(top: 4.0),
                                                    //         child: Text(
                                                    //           customerError!,
                                                    //           style: const TextStyle(
                                                    //               color: Colors.red,
                                                    //               fontSize: 13),
                                                    //         ),
                                                    //       ),
                                                    //   ],
                                                    // ),
                                                    // 10.height,
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Obx(() => CustomDateBox(
                                                          text: "Date",
                                                          isOptional: true,
                                                          errorText: dateError,
                                                          value: controllers.empDOB.value,
                                                          width: 235,
                                                          onTap: () {
                                                            utils.datePicker(
                                                                context: context,
                                                                textEditingController: controllers.dateOfConCtr,
                                                                pathVal: controllers.empDOB);
                                                          },
                                                        ),
                                                        ),
                                                        15.width,
                                                        Obx(() => CustomDateBox(
                                                          text: "Time",
                                                          isOptional: true,
                                                          errorText: timeError,
                                                          value: controllers.callTime.value,
                                                          width: 235,
                                                          onTap: () {
                                                            utils.timePicker(
                                                                context: context,
                                                                textEditingController:
                                                                controllers.timeOfConCtr,
                                                                pathVal: controllers.callTime);
                                                          },
                                                        ),
                                                        ),
                                                      ],
                                                    ),
                                                    10.height,
                                                    Row(
                                                      children: [
                                                        5.width,
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                CustomText(
                                                                  text:"Call Type",
                                                                  colors: colorsConst.textColor,
                                                                  size: 13,
                                                                  isCopy: false,
                                                                ),
                                                                const CustomText(
                                                                  text: "*",
                                                                  colors: Colors.red,
                                                                  size: 25,
                                                                  isCopy: false,
                                                                )
                                                              ],
                                                            ),
                                                            Row(
                                                              children: controllers.callTypeList.map<Widget>((type) {
                                                                return Row(
                                                                  mainAxisSize: MainAxisSize.min,
                                                                  children: [
                                                                    Radio<String>(
                                                                      value: type,
                                                                      groupValue: controllers.callType,
                                                                      activeColor: colorsConst.primary,
                                                                      onChanged: (value) {
                                                                        setState(() {
                                                                          controllers.callType = value!;
                                                                        });
                                                                      },
                                                                    ),
                                                                    CustomText(text:type,size: 14,isCopy: false,),
                                                                    20.width,
                                                                  ],
                                                                );
                                                              }).toList(),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    10.height,
                                                    Row(
                                                      children: [
                                                        5.width,
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                CustomText(
                                                                  text:"Status",
                                                                  colors: colorsConst.textColor,
                                                                  size: 13,
                                                                  isCopy: false,
                                                                ),
                                                                const CustomText(
                                                                  text: "*",
                                                                  colors: Colors.red,
                                                                  size: 25,
                                                                  isCopy: false,
                                                                )
                                                              ],
                                                            ),
                                                            Row(
                                                              children: controllers.callStatusList.map<Widget>((type) {
                                                                return Row(
                                                                  mainAxisSize: MainAxisSize.min,
                                                                  children: [
                                                                    Radio<String>(
                                                                      value: type,
                                                                      groupValue: controllers.callStatus,
                                                                      activeColor: colorsConst.primary,
                                                                      onChanged: (value) {
                                                                        setState(() {
                                                                          controllers.callStatus = value!;
                                                                        });
                                                                      },
                                                                    ),
                                                                    CustomText(text:type,size: 14,isCopy: false,),
                                                                    20.width
                                                                  ],
                                                                );
                                                              }).toList(),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    10.height,
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        CustomText(
                                                          text:"Notes",
                                                          colors: colorsConst.textColor,
                                                          size: 13,
                                                          isCopy: false,
                                                        ),
                                                        SizedBox(
                                                          width: 480,
                                                          height: 80,
                                                          child: TextField(
                                                            controller: controllers.callCommentCont,
                                                            maxLines: null,
                                                            expands: true,
                                                            textAlign: TextAlign.start,
                                                            decoration: InputDecoration(
                                                              hintText: "Notes",
                                                              border: OutlineInputBorder(
                                                                borderRadius: BorderRadius.circular(5),
                                                                borderSide: BorderSide(
                                                                  color: Color(0xffE1E5FA),
                                                                ),
                                                              ),
                                                              focusedBorder: OutlineInputBorder(
                                                                borderRadius: BorderRadius.circular(5),
                                                                borderSide: BorderSide(
                                                                  color: Color(0xffE1E5FA),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
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
                                                    callback: (){
                                                      // if(controllers.selectedCustomerId.value.isEmpty) {
                                                      //   controllers.productCtr.reset();
                                                      //   setState(() {
                                                      //     customerError =
                                                      //     "Please select customer";
                                                      //   });
                                                      //   return;
                                                      // }
                                                      if(controllers.empDOB.value.isEmpty) {
                                                        controllers.productCtr.reset();
                                                        setState(() {
                                                          dateError =
                                                          "Please select date";
                                                        });
                                                        return;
                                                      }
                                                      if(controllers.callTime.value.isEmpty) {
                                                        controllers.productCtr.reset();
                                                        setState(() {
                                                          timeError = "Please select time";
                                                        });
                                                        return;
                                                      }
                                                      remController.titleController.text = controllers.callCommentCont.text;
                                                      controllers.selectedCustomerId.value=widget.id.toString();
                                                      controllers.selectedCustomerMobile.value=widget.mobileNumber.toString();
                                                      controllers.selectedCustomerName.value=widget.name.toString();
                                                      apiService.insertCallCommentAPI(context, "7");
                                                    },
                                                    height: 35,
                                                    isLoading: true,
                                                    backgroundColor: colorsConst.primary,
                                                    radius: 2,
                                                    width: 80,
                                                    controller: controllers.productCtr,
                                                    isImage: false,
                                                    text: "Save",
                                                    textColor: Colors.white,
                                                  ),
                                                  5.width
                                                ],
                                              ),
                                            ],
                                          );
                                        }
                                    );
                                  });
                            },
                            child: SvgPicture.asset(
                              "assets/images/call.svg",width: 20,height: 20,
                            )),
                      ),
                      PopupMenuButton<String>(
                          offset: const Offset(0, 40),
                          color: const Color(0xffE7EEF8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2),
                          ),
                          onSelected: (value) {
                            if(value=="Delete") {
                              showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: CustomText(
                                        text:
                                        "Are you sure delete this customers?",
                                        size: 16,
                                        isBold: true,
                                        colors: colorsConst.textColor,
                                        isCopy: true,
                                      ),
                                      actions: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: colorsConst.primary),
                                                  color: Colors.white),
                                              width: 80,
                                              height: 25,
                                              child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    shape: const RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadius.zero,
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
                                                    isCopy: false,
                                                  )),
                                            ),
                                            10.width,
                                            CustomLoadingButton(
                                              callback: () async {
                                                final deleteData = {
                                                  "lead_id": widget.id.toString(),
                                                  "user_id": controllers.storage
                                                      .read("id")
                                                      .toString(),
                                                  "rating":
                                                  (widget.rating ?? "Warm")
                                                      .toString(),
                                                  "cos_id": controllers.storage
                                                      .read("cos_id")
                                                      .toString(),
                                                  "mail_id":
                                                  widget.mainEmail.toString(),
                                                };

                                                await apiService.deleteCustomersAPI(context, [deleteData]);
                                              },
                                              height: 35,
                                              isLoading: true,
                                              backgroundColor:
                                              colorsConst.primary,
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
                            }else if(value=="Set a reminder"){
                              controllers.selectNCustomer(widget.id.toString(), widget.mainName.toString(), widget.mainEmail.toString(),
                                  widget.mainMobile.toString());
                              reminderUtils.showAddReminderDialog(context);
                            }else if(value=="View appointment"){
                              apiService.getAllMeetingActivity(widget.id.toString());
                              controllers.changeTab(2);
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation1, animation2) =>
                                  const Records(isReload: "false",),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              );
                              controllers.oldIndex.value = controllers.selectedIndex.value;
                              controllers.selectedIndex.value = 6;
                            }else if(value=="View call records") {
                              apiService.getAllCallActivity(widget.id.toString());
                              controllers.changeTab(0);
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation1, animation2) =>
                                  const Records(isReload: "false",),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              );
                              controllers.oldIndex.value =
                                  controllers.selectedIndex.value;
                              controllers.selectedIndex.value = 6;
                            }else if(value=="View email record") {
                              controllers.customMailFuture =
                                  apiService.mailCommentDetails(
                                      widget.id.toString());
                              Get.to(CusMailComments(
                                mainEmail: widget.mainEmail,
                                mainMobile: widget.mainMobile,
                                mainName: widget.mainName,
                                city: widget.city,
                                id: widget.id,
                                companyName: widget.companyName,
                              ));
                            }else if(value=="Promote"){
                              showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: CustomText(
                                        text:
                                        "Are you moving to the next level?",
                                        size: 16,
                                        isBold: true,
                                        colors: colorsConst.textColor,
                                        isCopy: true,
                                      ),
                                      actions: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.end,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: colorsConst
                                                          .primary),
                                                  color: Colors.white),
                                              width: 80,
                                              height: 25,
                                              child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    shape: const RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadius.zero,
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
                                                    isCopy: false,
                                                  )),
                                            ),
                                            10.width,
                                            CustomLoadingButton(
                                              callback: () async {
                                                final deleteData = {
                                                  "lead_id":
                                                  widget.id.toString(),
                                                  "user_id": controllers
                                                      .storage
                                                      .read("id")
                                                      .toString(),
                                                  "rating": (widget.rating ??
                                                      "Warm")
                                                      .toString(),
                                                  "cos_id": controllers
                                                      .storage
                                                      .read("cos_id")
                                                      .toString(),
                                                  "mail_id": widget.mainEmail
                                                      .toString(),
                                                };
                                                if (widget.pageName ==
                                                    "Prospects") {
                                                  await apiService
                                                      .insertQualifiedAPI(
                                                      context,
                                                      [deleteData]);
                                                } else if (widget.pageName ==
                                                    "Qualified") {
                                                  await apiService
                                                      .insertPromoteCustomerAPI(
                                                      context,
                                                      [deleteData]);
                                                } else if (widget.pageName ==
                                                    "Disqualified") {
                                                  await apiService
                                                      .qualifiedCustomersAPI(
                                                      context,
                                                      [deleteData]);
                                                } else {
                                                  await apiService
                                                      .insertProspectsAPI(
                                                      context,
                                                      [deleteData]);
                                                }
                                              },
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
                                            5.width
                                          ],
                                        ),
                                      ],
                                    );
                                  });
                            }else if(value=="Disqualify"){
                              showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: CustomText(
                                        text:
                                        "Are you sure to disqualify this lead?",
                                        size: 16,
                                        isBold: true,
                                        colors: colorsConst.textColor,
                                        isCopy: true,
                                      ),
                                      actions: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.end,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: colorsConst
                                                          .primary),
                                                  color: Colors.white),
                                              width: 80,
                                              height: 25,
                                              child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    shape: const RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadius.zero,
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
                                                    isCopy: false,
                                                  )),
                                            ),
                                            10.width,
                                            CustomLoadingButton(
                                              callback: () async {
                                                final deleteData = {
                                                  "lead_id": widget.id.toString(),
                                                  "user_id": controllers.storage.read("id").toString(),
                                                  "rating": (widget.rating ?? "Warm").toString(),
                                                  "cos_id": controllers.storage.read("cos_id").toString(),
                                                  "mail_id": widget.mainEmail.toString(),
                                                };
                                                apiService.disqualifiedCustomersAPI(context, [deleteData]);
                                              },
                                              height: 35,
                                              isLoading: true,
                                              backgroundColor:
                                              colorsConst.primary,
                                              radius: 2,
                                              width: 80,
                                              controller:
                                              controllers.productCtr,
                                              isImage: false,
                                              text: "Disqualify",
                                              textColor: Colors.white,
                                            ),
                                            5.width
                                          ],
                                        ),
                                      ],
                                    );
                                  });
                            }
                          },
                          // onCanceled: () {
                          //   isMenuOpen.value = false;
                          // },
                          // onOpened: () {
                          //   isMenuOpen.value = true;
                          // },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                                value: "Promote",
                                child: Text("Promote",
                                    style:
                                    TextStyle(color: colorsConst.textColor))),
                            PopupMenuItem(
                                value: "Set a Reminder",
                                child: Text("Set a Reminder",
                                    style: TextStyle(color: colorsConst.textColor))),
                            PopupMenuItem(
                                value: "View appointment",
                                child: Text("View appointment",
                                    style:
                                    TextStyle(color: colorsConst.textColor))),
                            PopupMenuItem(
                                value: "View call records",
                                child: Text("View call records",
                                    style:
                                    TextStyle(color: colorsConst.textColor))),
                            PopupMenuItem(
                                value: "View email record",
                                child: Text("View email record",
                                    style:
                                    TextStyle(color: colorsConst.textColor))),
                            PopupMenuItem(
                                value: "Disqualify",
                                child: Text("Disqualify",
                                    style:
                                    TextStyle(color: colorsConst.textColor))),
                            PopupMenuItem(
                                value: "Delete",
                                child: Text("Delete",
                                    style: TextStyle(color: colorsConst.textColor))),
                          ],
                          child: Icon((Icons.more_horiz),color: colorsConst.primary,)
                      ),
                    ],
                  ),
                ),
                ...tableController.tableHeadings.take(1).map((heading) {
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
                        isCopy: false,
                      ),
                    ),
                  );
                }),
              ]),
        ],
      ),
    ));
  }
}

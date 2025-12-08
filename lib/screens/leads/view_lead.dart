import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fullcomm_crm/controller/controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:fullcomm_crm/screens/leads/update_lead.dart';
import 'package:fullcomm_crm/services/api_services.dart';
import '../../common/constant/colors_constant.dart';
import '../../common/utilities/reminder_utils.dart';
import '../../common/utilities/utils.dart';
import '../../components/custom_loading_button.dart';
import '../../components/custom_sidebar.dart';
import '../../components/custom_text.dart';
import '../../controller/image_controller.dart';
import '../../models/customer_full_obj.dart';

class ViewLead extends StatefulWidget {
  final String? id;
  final String pageName;
  final String? name;
  final String? mobileNumber;
  final String? email;
  final String? companyName;
  final String? status;
  final String? rating;
  final String? source;
  final String? owner;
  final String? addressId;
  final String? addressLine1;
  final String? addressLine2;
  final String? area;
  final String? city;
  final String? state;
  final String? country;
  final String? pinCode;
  final String updateTs;
  String notes;
  String sourceDetails;

  ViewLead({
    super.key,
    this.id,
    required this.pageName,
    this.name,
    this.mobileNumber,
    this.email,
    this.companyName,
    this.status,
    this.rating,
    this.source,
    this.owner,
    this.addressId,
    this.addressLine1,
    this.addressLine2,
    this.area,
    this.city,
    this.state,
    this.country,
    this.pinCode,
    required this.updateTs,
    required this.notes,
    required this.sourceDetails,
  });

  @override
  State<ViewLead> createState() => _ViewLeadState();
}

class _ViewLeadState extends State<ViewLead> {
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

  String formatDateTime(String? input) {
    if (input == null || input.isEmpty) return "";
    try {
      final inputFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
      final dt = inputFormat.parse(input);
      return DateFormat('yyyy-MM-dd hh:mm a').format(dt);
    } catch (e) {
      return input;
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _focusNode = FocusNode();
    _focusNode.requestFocus();
    // call API to fetch CustomerFullDetails - ensure apiService has this method
    Future.delayed(Duration.zero, () {
      controllers.leadFuture =
          apiService.leadsDetailsForCustomer(widget.id.toString());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Widget _emptyBox(double height) => SizedBox(height: height);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return SelectionArea(
      child: Scaffold(
        body: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SideBar(),
            Container(
              width: screenWidth - 150,
              height: MediaQuery.of(context).size.height,
              alignment: Alignment.center,
              padding: EdgeInsets.all(20),
              child: Obx(
                    () => controllers.isLeadLoading.value
                    ? const CircularProgressIndicator()
                    : FutureBuilder<CustomerFullDetails>(
                  future: controllers.leadFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final data = snapshot.data!;
                      final cust = data.customer;
                      final addr = data.address;
                      final persons = data.customerPersons;
                      final primaryPerson = persons.isNotEmpty ? persons[0] : null;
                      final additional = data.additionalInfo;
                      final calls = data.callRecords;
                      final mails = data.mailRecords;
                      final meetings = data.meetings;
                      final reminders = data.reminders;

                      // fallback values from widget props if API missing fields
                      final displayName =
                          primaryPerson?.name ?? cust?.companyName ?? widget.name ?? "";
                      final displayMobile =
                          primaryPerson?.phone ?? widget.mobileNumber ?? "";
                      final displayEmail =
                          primaryPerson?.email ?? widget.email ?? "";

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
                          child: ListView(
                            controller: _controller,
                            padding: EdgeInsets.zero,
                            children: [
                              20.height,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: screenWidth / 2.5,
                                    child: Row(
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            Get.back();
                                          },
                                          icon: Icon(
                                            Icons.arrow_back,
                                            color: colorsConst.third,
                                          ),
                                        ),
                                        CustomText(
                                          text: "View Lead",
                                          isCopy: true,
                                          colors: colorsConst.textColor,
                                          size: 20,
                                          isBold: true,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 120,
                                    height: 35,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shadowColor: Colors.transparent,
                                        backgroundColor: colorsConst.primary,
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            TextEditingController reasonController = TextEditingController();
                                            String dropValue = widget.pageName == "Prospects"
                                                ? "Qualified"
                                                : widget.pageName == "Qualified"
                                                ? "Customers"
                                                : widget.pageName == "Suspects"
                                                ? "Prospects"
                                                : "Disqualified";
                                            print(dropValue);
                                            String selectedStage = dropValue;
                                            return StatefulBuilder(
                                              builder: (context, setState) {
                                                return AlertDialog(
                                                  title: CustomText(
                                                    text: "Move to Next Level",
                                                    size: 18,
                                                    isBold: true,
                                                    isCopy: false,
                                                    colors: colorsConst.textColor,
                                                  ),
                                                  content: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      CustomText(
                                                        text: "Select Stage",
                                                        size: 14,
                                                        isBold: true,
                                                        isCopy: false,
                                                      ),
                                                      8.height,
                                                      Container(
                                                        padding: EdgeInsets.symmetric(horizontal: 8),
                                                        decoration: BoxDecoration(
                                                          border: Border.all(color: colorsConst.primary),
                                                          borderRadius: BorderRadius.circular(4),
                                                        ),
                                                        child: DropdownButton<String>(
                                                          value: selectedStage,
                                                          isExpanded: true,
                                                          focusColor: Colors.transparent,
                                                          underline: SizedBox(),
                                                          items: [
                                                            "Prospects",
                                                            "Qualified",
                                                            "Customers",
                                                            "Disqualified"
                                                          ].map((value) {
                                                            return DropdownMenuItem(
                                                              value: value,
                                                              child: Text(value),
                                                            );
                                                          }).toList(),
                                                          onChanged: (value) {
                                                            setState(() {
                                                              selectedStage = value!;
                                                            });
                                                          },
                                                        ),
                                                      ),
                                                      15.height,
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
                                                          callback: () async {
                                                            final deleteData = {
                                                              "lead_id": widget.id.toString(),
                                                              "user_id": controllers.storage.read("id").toString(),
                                                              "rating": (widget.rating ?? "Warm").toString(),
                                                              "cos_id": controllers.storage.read("cos_id").toString(),
                                                              "mail_id": widget.email.toString(),
                                                            };
                                                            if (selectedStage == "Prospects") {
                                                              await apiService.insertQualifiedAPI(context, [deleteData]);
                                                            } else if (selectedStage == "Qualified") {
                                                              await apiService.insertPromoteCustomerAPI(context, [deleteData]);
                                                            } else if (selectedStage == "Disqualified") {
                                                              await apiService.qualifiedCustomersAPI(context, [deleteData]);
                                                            } else {
                                                              await apiService.insertProspectsAPI(context, [deleteData]);
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
                                                      ],
                                                    )
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        );

                                        // showDialog(
                                        //     context: context,
                                        //     barrierDismissible: false,
                                        //     builder: (context) {
                                        //       return AlertDialog(
                                        //         content: CustomText(
                                        //           text: "Are you moving to the next level?",
                                        //           isCopy: true,
                                        //           size: 16,
                                        //           isBold: true,
                                        //           colors: colorsConst.textColor,
                                        //         ),
                                        //         actions: [
                                        //           Row(
                                        //             mainAxisAlignment: MainAxisAlignment.end,
                                        //             children: [
                                        //               Container(
                                        //                 decoration: BoxDecoration(
                                        //                     border: Border.all(
                                        //                         color: colorsConst.primary),
                                        //                     color: Colors.white),
                                        //                 width: 80,
                                        //                 height: 25,
                                        //                 child: ElevatedButton(
                                        //                     style: ElevatedButton.styleFrom(
                                        //                       shape: const RoundedRectangleBorder(
                                        //                         borderRadius:
                                        //                         BorderRadius.zero,
                                        //                       ),
                                        //                       backgroundColor: Colors.white,
                                        //                     ),
                                        //                     onPressed: () {
                                        //                       Navigator.pop(context);
                                        //                     },
                                        //                     child: CustomText(
                                        //                       text: "Cancel",
                                        //                       colors: colorsConst.primary,
                                        //                       size: 14,
                                        //                       isCopy: false,
                                        //                     )),
                                        //               ),
                                        //               10.width,
                                        //               CustomLoadingButton(
                                        //                 callback: () async {
                                        //                   final deleteData = {
                                        //                     "lead_id": widget.id.toString(),
                                        //                     "user_id": controllers.storage.read("id").toString(),
                                        //                     "rating": (widget.rating ?? "Warm").toString(),
                                        //                     "cos_id": controllers.storage.read("cos_id").toString(),
                                        //                     "mail_id": widget.email.toString(),
                                        //                   };
                                        //                   if (widget.pageName == "Prospects") {
                                        //                     await apiService.insertQualifiedAPI(context, [deleteData]);
                                        //                   } else if (widget.pageName == "Qualified") {
                                        //                     await apiService.insertPromoteCustomerAPI(context, [deleteData]);
                                        //                   } else if (widget.pageName == "Disqualified") {
                                        //                     await apiService.qualifiedCustomersAPI(context, [deleteData]);
                                        //                   } else {
                                        //                     await apiService.insertProspectsAPI(context, [deleteData]);
                                        //                   }
                                        //                 },
                                        //                 height: 35,
                                        //                 isLoading: true,
                                        //                 backgroundColor:
                                        //                 colorsConst.primary,
                                        //                 radius: 2,
                                        //                 width: 80,
                                        //                 controller:
                                        //                 controllers.productCtr,
                                        //                 isImage: false,
                                        //                 text: "Promote",
                                        //                 textColor: Colors.white,
                                        //               ),
                                        //               5.width
                                        //             ],
                                        //           ),
                                        //         ],
                                        //       );
                                        //     });
                                      },
                                      child: MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: Text(
                                          "Promote",
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  10.width,
                                  SizedBox(
                                    width: 120,
                                    height: 35,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shadowColor: Colors.transparent,
                                        backgroundColor: colorsConst.primary,
                                      ),
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (context) {
                                              return AlertDialog(
                                                content: CustomText(
                                                  text:
                                                  "Are you sure to disqualify this lead?",
                                                  size: 16,
                                                  isCopy: true,
                                                  isBold: true,
                                                  colors: colorsConst.textColor,
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
                                                            "mail_id": widget.email.toString(),
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
                                      },
                                      child: MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: Text(
                                          "Disqualify",
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  10.width,
                                  SizedBox(
                                    width: 160,
                                    height: 35,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shadowColor: Colors.transparent,
                                        backgroundColor: colorsConst.primary,
                                      ),
                                      onPressed: () {
                                        controllers.selectNCustomer(widget.id.toString(), widget.name.toString(), widget.email.toString(),
                                            widget.mobileNumber.toString());
                                        reminderUtils.showAddReminderDialog(context);
                                      },
                                      child: MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: Text(
                                          "Set a reminder",
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  10.width,
                                  SizedBox(
                                    width: 120,
                                    height: 35,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shadowColor: Colors.transparent,
                                        backgroundColor: colorsConst.primary,
                                      ),
                                      onPressed: () {
                                        // prepare values for UpdateLead
                                        Get.to(
                                          UpdateLead(
                                            id: widget.id,
                                            mainName: displayName,
                                            mainMobile: displayMobile,
                                            mainEmail: displayEmail,
                                            companyName: cust?.companyName ?? widget.companyName,
                                            status: cust?.status?.toString(),
                                            rating: cust?.rating,
                                            detailsOfRequired: cust?.detailsOfServiceRequired,
                                            visitType: cust?.visitType ?? "",
                                            owner: cust?.owner,
                                            addressId: addr?.id?.toString(),
                                            addressLine1: addr?.doorNo ?? widget.addressLine1 ?? "",
                                            area: addr?.area ?? widget.area ?? "",
                                            city: addr?.city ?? widget.city ?? "",
                                            state: addr?.state ?? widget.state ?? "",
                                            country: addr?.country ?? widget.country ?? "",
                                            pinCode: addr?.pincode ?? widget.pinCode ?? "",
                                            statusUpdate: cust?.statusUpdate,
                                            prospectEnrollmentDate: cust?.prospectEnrollmentDate,
                                            expectedConvertionDate: cust?.expectedConvertionDate,
                                            numOfHeadcount: cust?.numOfHeadcount,
                                            expectedBillingValue: cust?.expectedBillingValue,
                                            arpuValue: cust?.arpuValue,
                                            productDiscussion: cust?.product,
                                            discussionPoint: cust?.discussionPoint,
                                            notes: widget.notes,
                                            sourceDetails: widget.sourceDetails,
                                            updateTs: cust?.updatedTs ?? widget.updateTs,
                                          ),
                                          duration: Duration.zero,
                                        );
                                      },
                                      child: MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: Text(
                                          "Edit",
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  10.width,
                                  CustomLoadingButton(
                                    callback: () {
                                      controllers.emailSubjectCtr.clear();
                                      controllers.emailMessageCtr.clear();
                                      imageController.photo1.value = "";
                                      controllers.emailToCtr.text =
                                      displayEmail.isEmpty ? "" : displayEmail;
                                      utils.sendEmailDialog(
                                        id: widget.id.toString(),
                                        name: displayName,
                                        mobile: displayMobile,
                                        coName: cust?.companyName ?? widget.companyName ?? "",
                                      );
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
                              10.height,
                              Divider(
                                color: colorsConst.textColor,
                                thickness: 1,
                              ),
                              20.height,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  CustomText(
                                    text: "Added : ${formatDateTime(cust?.updatedTs ?? widget.updateTs)}",
                                    colors: colorsConst.textColor,
                                    size: 12,
                                    isCopy: true,
                                  ),
                                ],
                              ),
                              // Top summary card
                              Container(
                                height: 190,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(10),
                                ),
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
                                                CrossAxisAlignment.start,
                                                children: [
                                                  CustomText(
                                                    text: "New Lead",
                                                    colors: colorsConst.textColor,
                                                    isBold: true,
                                                    size: 16,
                                                    isCopy: true,
                                                  ),
                                                  20.height,
                                                  utils.leadText(
                                                    text: _formatHeading(
                                                        controllers.getUserHeading(
                                                            "name") ??
                                                            "Name"),
                                                    color: colorsConst.primary,
                                                  ),
                                                  20.height,
                                                  utils.leadText(
                                                    text: _formatHeading(
                                                        controllers.getUserHeading(
                                                            "mobile_name") ??
                                                            "Mobile No"),
                                                    color: colorsConst.primary,
                                                  ),
                                                  20.height,
                                                  utils.leadText(
                                                    text: _formatHeading(
                                                        controllers.getUserHeading(
                                                            "email") ??
                                                            "Email id"),
                                                    color: colorsConst.primary,
                                                  ),
                                                ],
                                              ),
                                              30.width,
                                              Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  CustomText(
                                                    text: "",
                                                    colors: colorsConst.textColor,
                                                    isBold: true,
                                                    isCopy: true,
                                                    size: 16,
                                                  ),
                                                  20.height,
                                                  utils.leadText(
                                                      text: displayName,
                                                      color: colorsConst.textColor),
                                                  20.height,
                                                  utils.leadText(
                                                      text: displayMobile,
                                                      color: colorsConst.textColor),
                                                  20.height,
                                                  utils.leadText(
                                                      text: displayEmail,
                                                      color: colorsConst.textColor),
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
                                                CrossAxisAlignment.start,
                                                children: [
                                                  CustomText(
                                                    text: "",
                                                    isCopy: true,
                                                    colors: colorsConst.textColor,
                                                    isBold: true,
                                                    size: 16,
                                                  ),
                                                  20.height,
                                                  utils.leadText(
                                                    text: _formatHeading(
                                                        controllers.getUserHeading(
                                                            "owner") ??
                                                            "Account Manager"),
                                                    color: colorsConst.primary,
                                                  ),
                                                  20.height,
                                                  utils.leadText(
                                                      text: "Whatsapp No",
                                                      color: colorsConst.primary),
                                                  20.height,
                                                  utils.leadText(
                                                      text: "Quotation Required",
                                                      color: colorsConst.primary),
                                                  20.height,
                                                  utils.leadText(
                                                      text: "Visit Type",
                                                      color: colorsConst.primary),
                                                ],
                                              ),
                                              40.width,
                                              Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  CustomText(
                                                    text: "",
                                                    colors: colorsConst.textColor,
                                                    isBold: true,
                                                    size: 16,
                                                    isCopy: true,
                                                  ),
                                                  20.height,
                                                  utils.leadText(
                                                      text: cust?.owner ?? widget.owner ?? "",
                                                      color: colorsConst.textColor),
                                                  20.height,
                                                  utils.leadText(
                                                      text: displayMobile,
                                                      color: colorsConst.textColor),
                                                  20.height,
                                                  utils.leadText(
                                                      text: (cust?.product ?? "").isNotEmpty
                                                          ? (cust!.product == "1" ? "Yes" : "No")
                                                          : "No",
                                                      color: colorsConst.textColor),
                                                  20.height,
                                                  utils.leadText(
                                                      text: cust?.visitType ?? "",
                                                      color: colorsConst.textColor),
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
                              // Address card
                              Container(
                                height: 180,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(10),
                                ),
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
                                                CrossAxisAlignment.start,
                                                children: [
                                                  CustomText(
                                                    text: "Address Information",
                                                    colors: colorsConst.textColor,
                                                    isBold: true,
                                                    size: 16,
                                                    isCopy: true,
                                                  ),
                                                  20.height,
                                                  utils.leadText(
                                                      text: "Door No",
                                                      color: colorsConst.primary),
                                                  20.height,
                                                  utils.leadText(
                                                      text: "Area",
                                                      color: colorsConst.primary),
                                                  20.height,
                                                  utils.leadText(
                                                      text: "State",
                                                      color: colorsConst.primary),
                                                ],
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  CustomText(
                                                    text: "",
                                                    colors: colorsConst.textColor,
                                                    isBold: true,
                                                    size: 16,
                                                    isCopy: true,
                                                  ),
                                                  20.height,
                                                  utils.leadText(
                                                      text: addr?.doorNo ?? "",
                                                      color: colorsConst.textColor),
                                                  20.height,
                                                  utils.leadText(
                                                      text: addr?.area ?? "",
                                                      color: colorsConst.textColor),
                                                  20.height,
                                                  utils.leadText(
                                                      text: addr?.state ?? "",
                                                      color: colorsConst.textColor),
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
                                                CrossAxisAlignment.start,
                                                children: [
                                                  CustomText(
                                                    text: "",
                                                    colors: colorsConst.textColor,
                                                    isBold: true,
                                                    size: 16,
                                                    isCopy: true,
                                                  ),
                                                  20.height,
                                                  utils.leadText(
                                                      text: "Pincode",
                                                      color: colorsConst.primary),
                                                  20.height,
                                                  utils.leadText(
                                                      text: "City",
                                                      color: colorsConst.primary),
                                                  20.height,
                                                  utils.leadText(
                                                      text: "Country",
                                                      color: colorsConst.primary),
                                                ],
                                              ),
                                              40.width,
                                              Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  CustomText(
                                                    text: "",
                                                    colors: colorsConst.textColor,
                                                    isBold: true,
                                                    size: 16,
                                                    isCopy: true,
                                                  ),
                                                  20.height,
                                                  utils.leadText(
                                                      text: addr?.pincode ?? "",
                                                      color: colorsConst.textColor),
                                                  20.height,
                                                  utils.leadText(
                                                      text: addr?.city ?? "",
                                                      color: colorsConst.textColor),
                                                  20.height,
                                                  utils.leadText(
                                                      text: addr?.country ?? "",
                                                      color: colorsConst.textColor),
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
                              // Company info
                              Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(10),
                                ),
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
                                                CrossAxisAlignment.start,
                                                children: [
                                                  CustomText(
                                                    text: "Company Information",
                                                    colors: colorsConst.textColor,
                                                    isBold: true,
                                                    size: 16,
                                                    isCopy: true,
                                                  ),
                                                  20.height,
                                                  utils.leadText(
                                                      text: _formatHeading(controllers
                                                          .getUserHeading(
                                                          "company_name") ??
                                                          "Company Name"),
                                                      color: colorsConst.primary),
                                                  20.height,
                                                  utils.leadText(
                                                      text: "Company Phone No.",
                                                      color: colorsConst.primary),
                                                  20.height,
                                                  utils.leadText(
                                                      text: "Industry",
                                                      color: colorsConst.primary),
                                                  20.height,
                                                  utils.leadText(
                                                      text: "Linkedin",
                                                      color: colorsConst.primary),
                                                ],
                                              ),
                                              10.width,
                                              Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  CustomText(
                                                    text: "",
                                                    colors: colorsConst.textColor,
                                                    isBold: true,
                                                    size: 16,
                                                    isCopy: true,
                                                  ),
                                                  20.height,
                                                  utils.leadText(
                                                      text: cust?.companyName ?? "",
                                                      color: colorsConst.textColor),
                                                  20.height,
                                                  utils.leadText(
                                                      text: (cust?.companyNumber ?? ""),
                                                      color: colorsConst.textColor),
                                                  20.height,
                                                  utils.leadText(
                                                      text: cust?.industry ?? "",
                                                      color: colorsConst.textColor),
                                                  20.height,
                                                  utils.leadText(
                                                      text: cust?.linkedin ?? "",
                                                      color: colorsConst.textColor),
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
                                                CrossAxisAlignment.start,
                                                children: [
                                                  CustomText(
                                                    text: "",
                                                    colors: colorsConst.textColor,
                                                    isBold: true,
                                                    isCopy: true,
                                                    size: 16,
                                                  ),
                                                  20.height,
                                                  utils.leadText(
                                                      text: "Website",
                                                      color: colorsConst.primary),
                                                  20.height,
                                                  utils.leadText(
                                                      text: "Company Email",
                                                      color: colorsConst.primary),
                                                  20.height,
                                                  utils.leadText(
                                                      text: "Product/Services",
                                                      color: colorsConst.primary),
                                                  20.height,
                                                  utils.leadText(text: "X", color: colorsConst.primary),
                                                ],
                                              ),
                                              30.width,
                                              Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  CustomText(
                                                    text: "",
                                                    colors: colorsConst.textColor,
                                                    isBold: true,
                                                    size: 16,
                                                    isCopy: true,
                                                  ),
                                                  20.height,
                                                  utils.leadText(
                                                      text: cust?.companyWebsite ?? "",
                                                      color: colorsConst.textColor),
                                                  20.height,
                                                  utils.leadText(
                                                      text: cust?.companyEmail ?? "",
                                                      color: colorsConst.textColor),
                                                  20.height,
                                                  utils.leadText(
                                                      text: cust?.product ?? "",
                                                      color: colorsConst.textColor),
                                                  20.height,
                                                  utils.leadText(
                                                      text: cust?.x ?? "",
                                                      color: colorsConst.textColor),
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
                              // Customer fields & additional info
                              Container(
                                height: 380,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(10),
                                ),
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
                                                CrossAxisAlignment.start,
                                                children: [
                                                  CustomText(
                                                    text: "Customer Fields",
                                                    colors: colorsConst.textColor,
                                                    isBold: true,
                                                    size: 16,
                                                    isCopy: true,
                                                  ),
                                                  20.height,
                                                  utils.leadText(
                                                      text: _formatHeading(controllers
                                                          .getUserHeading(
                                                          "product_discussion") ??
                                                          "Product Discussed"),
                                                      color: colorsConst.primary),
                                                  20.height,
                                                  utils.leadText(
                                                      text: _formatHeading(controllers
                                                          .getUserHeading("status") ??
                                                          "Status"),
                                                      color: colorsConst.primary),
                                                  20.height,
                                                  utils.leadText(
                                                      text: _formatHeading(controllers
                                                          .getUserHeading(
                                                          "expected_billing_value") ??
                                                          "Expected Monthly Billing Value"),
                                                      color: colorsConst.primary),
                                                  20.height,
                                                  utils.leadText(
                                                      text: _formatHeading(controllers
                                                          .getUserHeading(
                                                          "num_of_headcount") ??
                                                          "Total Number Of Head Count"),
                                                      color: colorsConst.primary),
                                                  20.height,
                                                  utils.leadText(
                                                      text: _formatHeading(controllers
                                                          .getUserHeading(
                                                          "details_of_service_required") ??
                                                          "Details of Service Required"),
                                                      color: colorsConst.primary),
                                                  20.height,
                                                  utils.leadText(
                                                      text: _formatHeading(controllers
                                                          .getUserHeading("rating") ??
                                                          "Prospect Grading"),
                                                      color: colorsConst.primary),
                                                ],
                                              ),
                                              40.width,
                                              Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  CustomText(
                                                    text: "",
                                                    colors: colorsConst.textColor,
                                                    isBold: true,
                                                    size: 16,
                                                    isCopy: true,
                                                  ),
                                                  20.height,
                                                  utils.leadText(
                                                      text: cust?.product ?? "",
                                                      color: colorsConst.textColor),
                                                  20.height,
                                                  utils.leadText(
                                                    text: (() {
                                                      final ls = cust?.leadStatus;
                                                      if (ls == null) return "";
                                                      if (ls == 1) return "Suspects";
                                                      if (ls == 2) return "Prospects";
                                                      if (ls == 3) return "Qualified";
                                                      return "Customers";
                                                    })(),
                                                    color: colorsConst.textColor,
                                                  ),
                                                  20.height,
                                                  utils.leadText(
                                                      text: cust?.expectedBillingValue ?? "",
                                                      color: colorsConst.textColor),
                                                  20.height,
                                                  utils.leadText(
                                                      text: cust?.numOfHeadcount ?? "",
                                                      color: colorsConst.textColor),
                                                  20.height,
                                                  utils.leadText(
                                                      text: cust?.detailsOfServiceRequired ?? "",
                                                      color: colorsConst.textColor),
                                                  20.height,
                                                  utils.leadText(
                                                      text: cust?.rating ?? "",
                                                      color: colorsConst.textColor),
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
                                                CrossAxisAlignment.start,
                                                children: [
                                                  CustomText(
                                                    text: "",
                                                    colors: colorsConst.textColor,
                                                    isBold: true,
                                                    size: 16,
                                                    isCopy: true,
                                                  ),
                                                  20.height,
                                                  utils.leadText(
                                                      text: "Additional Notes",
                                                      color: colorsConst.primary),
                                                  20.height,
                                                  utils.leadText(
                                                      text: "Response Priority",
                                                      color: colorsConst.primary),
                                                  20.height,
                                                  utils.leadText(
                                                      text: _formatHeading(controllers
                                                          .getUserHeading("arpu_value") ??
                                                          "ARPU Value"),
                                                      color: colorsConst.primary),
                                                  20.height,
                                                  utils.leadText(
                                                      text:
                                                      _formatHeading(controllers.getUserHeading(
                                                          "expected_convertion_date") ??
                                                          "Expected Conversion Date"),
                                                      color: colorsConst.primary),
                                                  20.height,
                                                  utils.leadText(
                                                      text: _formatHeading(controllers
                                                          .getUserHeading(
                                                          "prospect_enrollment_date") ??
                                                          "Prospect Enrollment Date"),
                                                      color: colorsConst.primary),
                                                  10.height,
                                                  utils.leadText(
                                                      text: _formatHeading(controllers
                                                          .getUserHeading("source") ??
                                                          "SOURCE OF PROSPECT"),
                                                      color: colorsConst.primary),
                                                  20.height,
                                                  utils.leadText(
                                                      text: _formatHeading(controllers
                                                          .getUserHeading("status_update") ??
                                                          "Status Update"),
                                                      color: colorsConst.primary),
                                                  25.height,
                                                ],
                                              ),
                                              20.width,
                                              Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  CustomText(
                                                    text: "",
                                                    colors: colorsConst.textColor,
                                                    isBold: true,
                                                    size: 16,
                                                    isCopy: true,
                                                  ),
                                                  20.height,
                                                  utils.leadText(
                                                      text: widget.notes ?? "",
                                                      color: colorsConst.textColor),
                                                  20.height,
                                                  utils.leadText(
                                                      text:"Normal",
                                                      color: colorsConst.textColor),
                                                  20.height,
                                                  utils.leadText(
                                                      text: cust?.arpuValue ?? "",
                                                      color: colorsConst.textColor),
                                                  20.height,
                                                  utils.leadText(
                                                      text: cust?.expectedConvertionDate ?? "",
                                                      color: colorsConst.textColor),
                                                  20.height,
                                                  utils.leadText(
                                                      text: cust?.prospectEnrollmentDate ?? "",
                                                      color: colorsConst.textColor),
                                                  20.height,
                                                  utils.leadText(
                                                      text: cust?.source ?? "",
                                                      color: colorsConst.textColor),
                                                  20.height,
                                                  Tooltip(
                                                    message: cust?.statusUpdate ?? "",
                                                    child: utils.leadText(
                                                        text: cust?.statusUpdate ?? "",
                                                        color: colorsConst.textColor),
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
                              // Additional info list (from structured additionalInfo)
                              if (additional.isNotEmpty)
                                SizedBox(
                                  width: screenWidth / 2.7,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CustomText(
                                        text: "Additional Information",
                                        colors: colorsConst.textColor,
                                        isBold: true,
                                        size: 16,
                                        isCopy: true,
                                      ),
                                      20.height,
                                      ...additional.map((info) => Padding(
                                        padding: const EdgeInsets.only(bottom: 15),
                                        child: Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            utils.leadText(
                                                text: info.fieldName ?? "",
                                                color: colorsConst.primary),
                                            10.width,
                                            utils.leadText(
                                                text: info.fieldValue ?? "",
                                                color: colorsConst.textColor),
                                          ],
                                        ),
                                      )),
                                    ],
                                  ),
                                ),
                              20.height,
                              if (calls.isNotEmpty) ...[
                                _buildCallRecords(calls),
                                20.height,
                              ],
                              if (meetings.isNotEmpty) ...[
                                _buildMeetingRecords(meetings),
                                20.height,
                              ],
                              if (reminders.isNotEmpty) ...[
                                _buildReminderRecords(reminders),
                                20.height,
                              ],
                              40.height,
                            ],
                          ),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          120.height,
                          Center(child: SvgPicture.asset("assets/images/noDataFound.svg")),
                          10.height,
                          Text(snapshot.error.toString()),
                        ],
                      );
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildCallRecords(List<CallRecord> calls) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(text: "Call Records (${calls.length})", colors: colorsConst.textColor, isBold: true,isCopy: true, size: 14),
          10.height,
          ...calls.map((c) => InkWell(
            onTap: () => _showRecordDialog(
              title: "Call Detail",
              fields: {
                "Type": c.callType ?? "",
                "Status": c.callStatus ?? "",
                "To": c.toData ?? "",
                "From": c.fromData ?? "",
                "Message": c.message ?? "",
                "Sent Date": c.sentDate ?? "",
                "Created By": c.createdBy?.toString() ?? "",
                "Created Ts": c.createdTs ?? "",
              },
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(child: Text("${c.callType ?? ''} • ${c.callStatus ?? ''}", style: TextStyle(fontSize: 13))),
                  Text(c.sentDate ?? "", style: TextStyle(fontSize: 12)),
                  10.width,
                  Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                ],
              ),
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildMeetingRecords(List<Meeting> meetings) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(text: "Meetings (${meetings.length})", colors: colorsConst.textColor,isCopy: true, isBold: true, size: 14),
          10.height,
          ...meetings.map((m) => InkWell(
            onTap: () => _showRecordDialog(
              title: "Meeting Detail",
              fields: {
                "Title": m.title ?? "",
                "Venue": m.venue ?? "",
                "Dates": m.dates ?? "",
                "Time": m.time ?? "",
                "Notes": m.notes ?? "",
                "Status": m.status ?? "",
                "Created": m.createdTs ?? "",
                "Updated": m.updatedTs ?? "",
              },
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(child: Text("${m.title ?? ''} • ${m.status ?? ''}", style: TextStyle(fontSize: 13))),
                  Text(m.dates ?? "", style: TextStyle(fontSize: 12)),
                  10.width,
                  Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                ],
              ),
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildReminderRecords(List<Reminder> reminders) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(text: "Reminders (${reminders.length})", colors: colorsConst.textColor, isBold: true,isCopy: true, size: 14),
          10.height,
          ...reminders.map((r) => InkWell(
            onTap: () => _showRecordDialog(
              title: "Reminder Detail",
              fields: {
                "Title": r.title ?? "",
                "Type": r.type ?? "",
                "Location": r.location ?? "",
                "Start": r.startDt ?? "",
                "End": r.endDt ?? "",
                "Details": r.details ?? "",
                "Set Type": r.setType ?? "",
                "Set Time": r.setTime ?? "",
                "Created": r.createdTs ?? "",
              },
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(child: Text("${r.title ?? ''} • ${r.setType ?? ''}", style: TextStyle(fontSize: 13))),
                  Text(r.startDt ?? "", style: TextStyle(fontSize: 12)),
                  10.width,
                  Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                ],
              ),
            ),
          )).toList(),
        ],
      ),
    );
  }

  /// Generic dialog to show key-value fields
  void _showRecordDialog({ required String title, required Map<String, String> fields }) {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: fields.entries.map((e) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 120,
                          child: Text(e.key, style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Expanded(child: Text(e.value.isNotEmpty ? e.value : "-")),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text("Close")),
            ],
          );
        }
    );
  }

}

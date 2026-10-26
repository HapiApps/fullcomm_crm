import 'package:flutter_svg/flutter_svg.dart';
import 'package:fullcomm_crm/billing/billing_view/new_billing_screen.dart';
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
import '../controller/image_controller.dart';
import '../controller/reminder_controller.dart';
import '../controller/table_controller.dart';
import '../models/all_customers_obj.dart';
import '../models/customer_full_obj.dart';
import '../models/new_lead_obj.dart';
import '../screens/leads/customer_audio_dialog.dart';
import '../screens/records/cus_mail_comments.dart';
import '../screens/leads/update_lead.dart';
import '../screens/records/records.dart';
import '../services/api_services.dart';
import 'custom_loading_button.dart';

class CustomerNameTile extends StatefulWidget {
  final bool showCheckbox;
  final String leadIndex;
  final String pageName;
  final int listIndex;
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
  final String refBy;
  final void Function(bool?) onChanged;
  final bool saveValue;
  final RxList<NewLeadObj> list;
  final RxList<NewLeadObj> list2;
  final List<AdditionalInfo> additional;
  final Map<String, dynamic>? lastCall;
  final Map<String, dynamic>? lastMail;
  final Map<String, dynamic>? lastMeeting;
  final Map<String, dynamic>? lastReminder;

  const CustomerNameTile(
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
        this.lastCall, this.lastMail, this.lastMeeting, this.lastReminder,
        required this.pageName, required this.leadIndex,
        required this.list, required this.list2,
        required this.listIndex, required this.refBy,
        required this.additional});

  @override
  State<CustomerNameTile> createState() => _CustomerNameTileState();
}

class _CustomerNameTileState extends State<CustomerNameTile> {
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
      "phone_no": widget.mainMobile,
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

  late Map<String, TextEditingController> fieldControllers;

  String timeAgo(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.isNegative || diff.inMinutes < 1) return "just now";
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return "$m ${m == 1 ? 'minute' : 'minutes'} ago";
    }
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return "$h ${h == 1 ? 'hour' : 'hours'} ago";
    }

    final days = DateTime(now.year, now.month, now.day)
        .difference(DateTime(dt.year, dt.month, dt.day))
        .inDays;

    if (days == 1) return "yesterday";
    if (days < 7) return "$days days ago";
    if (days < 30) {
      final w = (days / 7).floor();
      return "$w ${w == 1 ? 'week' : 'weeks'} ago";
    }
    if (days < 365) {
      final mo = (days / 30).floor();
      return "$mo ${mo == 1 ? 'month' : 'months'} ago";
    }
    final y = (days / 365).floor();
    return "$y ${y == 1 ? 'year' : 'years'} ago";
  }

  String getLastActivityText() {
    final List<Map<String, dynamic>> items = [];

    void add(String label, Map<String, dynamic>? m) {
      if (m == null) return;
      final dt = DateTime.tryParse(m['created_ts']?.toString() ?? '');
      if (dt == null) return;
      items.add({"label": label, "dt": dt});
    }

    final callType = widget.lastCall?['call_type']?.toString().toLowerCase();
    final callLabel = callType == "incoming"
        ? "Last call received"
        : callType == "outgoing"
        ? "Last call made"
        : "Last call";

    add("Last mail sent", widget.lastMail);
    add(callLabel, widget.lastCall);
    add("Last meeting added", widget.lastMeeting);
    add("Last reminder added", widget.lastReminder);

    if (items.isEmpty) return "No interaction yet";

    items.sort((a, b) => (b["dt"] as DateTime).compareTo(a["dt"] as DateTime));
    final latest = items.first;

    return "${latest["label"]} ${timeAgo(latest["dt"] as DateTime)}";
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
  void didUpdateWidget(covariant CustomerNameTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.statusUpdate != widget.statusUpdate) {
      statusController.text = widget.statusUpdate.toString() == "null"
          ? ""
          : widget.statusUpdate.toString();
    }
  }
  bool isEditing = false;

  @override
  void dispose() {
    statusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final headings = tableController.tableHeadings;
    final Map<int, TableColumnWidth> columnWidths = {
      0: FlexColumnWidth(0.6),
      1: FlexColumnWidth(0.6),
      2: const FlexColumnWidth(2),
      3: FixedColumnWidth(tableController.colWidth[headings.first] ?? 150),
    };
    return Obx(()=>tableController.isTableLoading.value?CircularProgressIndicator():InkWell(
      onTap: () {
        Get.to(
            ViewLead(
              listIndex: widget.listIndex,
              list: widget.list,list2: widget.list2,
              leadIndex: widget.leadIndex,
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
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: CustomText(text: "${int.parse(widget.index.toString())+1}", isCopy: false),
                ),
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
                                additional: widget.additional,
                                refBy: widget.refBy,
                                pageName: widget.pageName,
                                index: widget.listIndex,
                                list: widget.list,list2: widget.list2,
                                type:"1",
                                visitType: widget.visitType.toString(),
                                id: widget.id.toString(),
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
                                points: widget.points.toString(),
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
                      Tooltip(
                        message: "Add call log for this Customer.",
                        child: InkWell(
                            onTap: (){
                              controllers.empDOB.value = DateFormat('dd-MM-yyyy').format(DateTime.now());
                              controllers.callTime.value = DateFormat('hh.mm a').format(DateTime.now().subtract(const Duration(minutes: 15)));
                              setState(() {
                                controllers.clearSelectedCustomer();
                                controllers.cusController.text = "";
                                controllers.callType = "Outgoing";
                                controllers.callStatus = controllers.hCallStatusList[0]["value"];
                                controllers.callCommentCont.text = "";
                                remController.titleController.text = controllers.callCommentCont.text;
                                controllers.selectedCustomerId.value=widget.id.toString();
                                controllers.selectedCustomerMobile.value=widget.mobileNumber.toString();
                                controllers.selectedCustomerName.value=widget.name.toString();
                              });
                              utils.showCallDialog(
                                  context,"Add Call Log",
                                      (){
                                    apiService.insertCallCommentAPI(context, "7");
                                  },true
                              );
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
                              utils.showDeleteDialog(
                                  context: context, name: 'delete this ${widget.pageName}',
                                  isDelete: true,
                                  callBack: ()async{
                                    await apiService.deleteCustomersAPI(context, [widget.id],widget.list,widget.list2);
                                  },
                                  controller: controllers.productCtr);
                            }
                            else if(value=="Set a Reminder"){
                              controllers.selectNCustomer(widget.id.toString(), widget.mainName.toString(), widget.mainEmail.toString(),
                                  widget.mainMobile.toString());
                              reminderUtils.showAddReminderDialog(context);
                            }
                            else if(value=="mail"){
                              controllers.emailSubjectCtr.clear();
                              controllers.emailMessageCtr.clear();
                              imageController.images.clear();
                              imageController.photo1.value = "";
                              controllers.emailToCtr.text =widget.email.toString()=="null"?"":widget.email.toString();
                              utils.sendEmailDialog(
                                id: widget.id.toString(),
                                name: widget.name.toString(),
                                mobile: widget.mobileNumber.toString(),
                                coName: widget.companyName.toString()=="null"?"":widget.companyName.toString(),
                              );
                            }
                            else if(value=="View appointment"){
                              controllers.selectedIndex.value = 101;
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
                            }else if(value=="View call records") {
                              apiService.getAllCallActivity(widget.id.toString());
                              controllers.changeTab(0);
                              controllers.selectedIndex.value = 101;
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
                            }else if(value=="View email record") {
                              controllers.customMailFuture =
                                  apiService.mailCommentDetails(
                                      widget.id.toString());
                              controllers.selectedIndex.value = 101;
                              Get.to(CusMailComments(
                                mainEmail: widget.mainEmail,
                                mainMobile: widget.mainMobile,
                                mainName: widget.mainName,
                                city: widget.city,
                                id: widget.id,
                                companyName: widget.companyName,
                              ));
                            }else if(value=="Promote"){
                              debugPrint("onTap");
                              showDialog(
                                context: context,
                                builder: (context) {
                                  String? stageId;
                                  String? selectedStage;

                                  TextEditingController reasonController = TextEditingController();
                                  RxList<LeadStatusModel> categoryList=<LeadStatusModel>[].obs;
                                  for(var i=0;i<controllers.leadCategoryList.length;i++){
                                    if(controllers.leadCategoryList[i].value!=widget.pageName){
                                      categoryList.add(controllers.leadCategoryList[i]);
                                    }
                                  }
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
                                              text: "New Stage",
                                              size: 14,
                                              isBold: true,
                                              isCopy: false,
                                            ),
                                            const SizedBox(height: 8),

                                            /// DROPDOWN
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8),
                                              decoration: BoxDecoration(
                                                border: Border.all(color: colorsConst.primary),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: DropdownButton<String>(
                                                value: stageId,
                                                hint: const Text("New Stage"),
                                                isExpanded: true,
                                                underline: const SizedBox(),
                                                items: categoryList.map((item) {
                                                  return DropdownMenuItem<String>(
                                                    value: item.leadStatus,
                                                    child: Text(item.value),
                                                  );
                                                }).toList(),
                                                onChanged: (value) {
                                                  setState(() {
                                                    stageId = value;
                                                    selectedStage = categoryList
                                                        .firstWhere((e) => e.leadStatus == value)
                                                        .value;
                                                  });
                                                },
                                              ),
                                            ),

                                            const SizedBox(height: 15),

                                            /// REASON FIELD
                                            TextField(
                                              controller: reasonController,
                                              onChanged: (value){
                                                controllers.firstCaps(value, reasonController);
                                              },
                                              decoration: const InputDecoration(
                                                labelText: "Reason",
                                                border: OutlineInputBorder(),
                                              ),
                                            ),
                                          ],
                                        ),

                                        /// ACTIONS
                                        actions: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              /// CANCEL
                                              Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: colorsConst.primary),
                                                  color: Colors.white,
                                                ),
                                                width: 80,
                                                height: 30,
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    shape: const RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.zero,
                                                    ),
                                                    backgroundColor: Colors.white,
                                                    elevation: 0,
                                                  ),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: CustomText(
                                                    text: "Cancel",
                                                    isCopy: false,
                                                    colors: colorsConst.primary,
                                                    size: 14,
                                                  ),
                                                ),
                                              ),

                                              const SizedBox(width: 10),

                                              /// PROMOTE BUTTON
                                              CustomLoadingButton(
                                                callback: () async {
                                                  if (stageId == null) return;

                                                  controllers.idList.add(widget.id.toString());

                                                  await apiService.insertPromoteListAPI(
                                                    context,reasonController.text,
                                                    stageId!,
                                                    selectedStage ?? "",
                                                    widget.list,
                                                    widget.list2,
                                                  );

                                                  Navigator.pop(context);
                                                },
                                                height: 35,
                                                isLoading: true,
                                                backgroundColor: colorsConst.primary,
                                                radius: 2,
                                                width: 90,
                                                controller: controllers.productCtr,
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
                            }else if(value=="edit"){
                              Get.to(UpdateLead(
                                additional: widget.additional,
                                refBy: widget.refBy,
                                pageName: widget.pageName,
                                index: widget.listIndex,
                                list: widget.list,list2: widget.list2,
                                type:"1",
                                visitType: widget.visitType.toString(),
                                id: widget.id.toString(),
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
                                points: widget.points.toString(),
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
                            }else if(value=="call log"){
                              controllers.empDOB.value = DateFormat('dd-MM-yyyy').format(DateTime.now());
                              controllers.callTime.value = DateFormat('hh.mm a').format(DateTime.now().subtract(const Duration(minutes: 15)));
                              setState(() {
                                controllers.clearSelectedCustomer();
                                controllers.cusController.text = "";
                                controllers.callType = "Outgoing";
                                controllers.callStatus = controllers.hCallStatusList[0]["value"];
                                controllers.callCommentCont.text = "";
                                remController.titleController.text = controllers.callCommentCont.text;
                                controllers.selectedCustomerId.value=widget.id.toString();
                                controllers.selectedCustomerMobile.value=widget.mobileNumber.toString();
                                controllers.selectedCustomerName.value=widget.name.toString();
                              });
                              utils.showCallDialog(
                                  context,"Add Call Log",
                                      (){
                                    apiService.insertCallCommentAPI(context, "7");
                                  },true
                              );
                            }
                            else if(value=="No Matches"){
                              showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: CustomText(
                                        text:
                                        "Are you sure to No Matches this lead?",
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
                                              text: "No Matches",
                                              textColor: Colors.white,
                                            ),
                                            5.width
                                          ],
                                        ),
                                      ],
                                    );
                                  });
                            }
                            else if(value=="Create Quotation"){
                              controllers.cusController.text="${widget.name} - ${widget.companyName}- ${widget.mobileNumber}";
                              controllers.selectCustomer(AllCustomersObj(
                              id: widget.id.toString(), name: widget.name.toString(),
                              companyName: widget.companyName.toString(), phoneNo: widget.mobileNumber.toString(),
                              email: widget.companyEmail.toString(), leadStatus: "", category: ""));
                              controllers.directNavigate.value=true;
                              controllers.qId.value=widget.id.toString();
                              controllers.selectedIndex.value=107;
                              Get.to(NewBillingScreen());
                            }
                            else if (value == "Customer Audio") {
                              showCustomerAudioDialog(
                                context,
                                customerId: widget.id.toString(),
                                customerName: widget.name.toString(),
                              );
                            }
                          },
                          // onCanceled: () {
                          //   isMenuOpen.value = false;
                          // },
                          // onOpened: () {
                          //   isMenuOpen.value = true;
                          // },
                          itemBuilder: (context) => [
                            if(widget.pageName.toString()!="Customers")
                            PopupMenuItem(
                                value: "Promote",
                                child: Text("Promote",
                                    style: TextStyle(
                                        color: colorsConst.textColor))),
                            // PopupMenuItem(
                            //     value: "edit",
                            //     child: Text("Edit ${widget.pageName}",
                            //         style: TextStyle(color: colorsConst.textColor))),
                            PopupMenuItem(
                                value: "mail",
                                child: Text("Send Email",
                                    style: TextStyle(
                                        color: colorsConst.textColor))),
                            PopupMenuItem(
                                value: "Create Quotation",
                                child: Text("Create Quotation",
                                    style: TextStyle(
                                        color: colorsConst.textColor
                                    ))),
                            // PopupMenuItem(
                            //     value: "Set a Reminder",
                            //     child: Text("Set a Reminder",
                            //         style: TextStyle(color: colorsConst.textColor))),
                            // PopupMenuItem(
                            //     value: "call log",
                            //     child: Text("Add Call Log",
                            //         style: TextStyle(color: colorsConst.textColor))),
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
                            // PopupMenuItem(
                            //     value: "No Matches",
                            //     child: Text("No Matches",
                            //         style:
                            //         TextStyle(color: colorsConst.textColor))),
                            PopupMenuItem(
                                value: "Delete",
                                child: Text("Delete",
                                    style: TextStyle(color: colorsConst.textColor))),
                            PopupMenuItem(
                                value: "Customer Audio",
                                child: Text("Customer Audio",
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
                  final text = value.toString() == "null" ? "" : value.toString();

                  final isNameColumn = key == "mainName" || key == "name";
                  final summary = getLastActivityText();
                  final hasActivity = summary != "No interaction yet";

                  return GestureDetector(
                    onDoubleTap: () {
                      setState(() {
                        isEditing = true;
                      });
                    },
                    onTap: () {
                      setState(() {
                        isEditing = false;
                      });
                    },
                    child: Container(
                      height: 52,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: isNameColumn
                          ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: text,
                            isCopy: false,
                            textAlign: TextAlign.start,
                          ),
                          const SizedBox(height: 2),
                          Tooltip(
                            message: summary,
                            child: Text(
                              summary,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: hasActivity
                                    ? Colors.green.shade700
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      )
                          : CustomText(
                        text: text,
                        isCopy: false,
                        textAlign: TextAlign.start,
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


class ReasonTile extends StatefulWidget {
  final String history;
  final int? index;

  const ReasonTile(
      {super.key,required this.history, this.index});

  @override
  State<ReasonTile> createState() => _ReasonTileState();
}

class _ReasonTileState extends State<ReasonTile> {

  @override
  Widget build(BuildContext context) {
    final Map<int, TableColumnWidth> columnWidths = {
      0: FlexColumnWidth(0.6),
    };
    return Obx(()=>tableController.isTableLoading.value?CircularProgressIndicator():Table(
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
              Container(
                height: 45,
                // color: Colors.yellow,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: CustomText(text:"Reason", isCopy: false,textAlign: TextAlign.start,),
              )
            ]),
      ],
    ));
  }
}

import 'dart:convert';
import 'package:http/http.dart'as http;
import 'package:fullcomm_crm/common/utilities/utils.dart';
import 'package:intl/intl.dart';
import 'package:fullcomm_crm/screens/leads/view_lead.dart';
import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/constant/colors_constant.dart';
import 'package:fullcomm_crm/components/custom_text.dart';
import 'package:fullcomm_crm/controller/controller.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../common/constant/api.dart';
import '../common/utilities/jwt_storage.dart';
import '../controller/table_controller.dart';
import '../models/new_lead_obj.dart';
import '../res/components/audio_message_player.dart';
import '../services/api_services.dart';

class CustomLeadTile extends StatefulWidget {
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
  final String? department;
  final String? designation;
  final String updatedTs;
  final void Function(bool?) onChanged;
  final bool saveValue;
  final RxList<NewLeadObj> list;
  final RxList<NewLeadObj> list2;
  final Map<String, dynamic>? lastCall;
  final Map<String, dynamic>? lastMail;
  final Map<String, dynamic>? lastMeeting;
  final Map<String, dynamic>? lastReminder;
  final List additional;
  final String promoteReason;
  final String? audioUrl;

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
      this.department,
      this.designation,
      required this.onChanged,
      required this.saveValue,
      required this.updatedTs,
      this.visitType,
      this.points,
      this.detailsOfServiceReq,
      this.audioUrl,
        this.lastCall, this.lastMail, this.lastMeeting, this.lastReminder,
      required this.pageName, required this.list, required this.list2,
        required this.listIndex, required this.leadIndex, required this.additional,
        required this.promoteReason});

  @override
  State<CustomLeadTile> createState() => _CustomLeadTileState();
}

///
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
    Map<String, dynamic> data = {
      "id": widget.id,
      "designation": widget.designation,
      "department": widget.department,
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
      "prospect_enrollment_date": widget.updatedTs,
      "expected_convertion_date": widget.expectedConvertionDate,
      "status_update": widget.statusUpdate,
      "num_of_headcount": widget.numOfHeadcount,
      "expected_billing_value": widget.expectedBillingValue,
      "visit_type": widget.visitType,
      "points": widget.points,
      "details_of_service_required": widget.detailsOfServiceReq,
      "updatedTs": widget.updatedTs,
      "Promote Reason": widget.promoteReason,
      "audio_url": widget.audioUrl,
    };

    if (widget.additional != null) {
      for (var item in widget.additional) {
        if (item is Map<String, dynamic>) {
          item.forEach((key, value) {
            data[key] = value;
          });
        }
      }
    }
    return data;
  }

  late TextEditingController statusController;
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(tableController.tableHeadings.isEmpty){
      apiService.getHeading();
    }
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
  String formatShortDateTime(String dateTime) {
    final dt = DateTime.tryParse(dateTime);
    if (dt == null) return "";
    final now = DateTime.now();
    return dt.year == now.year
        ? DateFormat("d MMM, hh:mm a").format(dt)
        : DateFormat("d MMM yyyy, hh:mm a").format(dt);
  }

  String getCategoryReason(dynamic input) {
    List data = [];

    if (input is List) {
      data = input;
    } else if (input is String && input.trim().isNotEmpty && input != "null") {
      try {
        final decoded = jsonDecode(input);
        if (decoded is List) data = decoded;
      } catch (_) {
        return "";
      }
    }

    return data.map((e) {
      final category = e["category"] ?? "";
      final reason = e["reason"] ?? "";
      final date = formatShortDateTime(e["created_ts"]?.toString() ?? "");

      return reason.toString().trim().isEmpty
          ? "$category ($date)"
          : "$category - $reason ($date)";
    }).join("\n");
  }

  String getActivityTooltip(String name) {
    String ago(Map<String, dynamic>? m) {
      final dt = DateTime.tryParse(m?['created_ts']?.toString() ?? '');
      return dt == null ? '' : timeAgo(dt);
    }

    String clean(dynamic v) {
      final s = v?.toString().trim() ?? '';
      return s == 'null' ? '' : s;
    }

    String row(String label, Map<String, dynamic>? m, String detail) {
      if (m == null) return '$label: -';
      final d = detail.isEmpty ? '' : ' - $detail';
      return '$label: ${ago(m)}$d';
    }

    final call = widget.lastCall;
    final mail = widget.lastMail;
    final meet = widget.lastMeeting;
    final rem = widget.lastReminder;

    final callDetail = [clean(call?['call_type']), clean(call?['call_status'])]
        .where((e) => e.isNotEmpty)
        .join(', ');
    final meetDetail = [clean(meet?['title']), clean(meet?['status'])]
        .where((e) => e.isNotEmpty)
        .join(', ');

    return [
      name,
      '',
      row('Call', call, callDetail),
      row('Mail', mail, clean(mail?['subject'])),
      row('Meeting', meet, meetDetail),
      row('Reminder', rem, clean(rem?['title'])),
    ].join('\n');
  }

  @override
  Widget build(BuildContext context) {
    return Obx((){
      final headings = List<String>.from(tableController.tableHeadings);

      if (!headings.contains("Promote Reason")) {
        headings.add("Promote Reason");
      }
      final displayHeadings = headings.skip(1).toList();
      final Map<int, TableColumnWidth> columnWidths = {};
      int idx = 0;
      for (final h in displayHeadings) {
        final w = tableController.colWidth[h] ?? 155;
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
                leadIndex: widget.leadIndex,
                listIndex: widget.listIndex,
                list: widget.list,list2: widget.list2,
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
                  ...displayHeadings.asMap().entries.map((entry) {
                    final index = entry.key;
                    final heading = entry.value;

                    final isLastColumn = index == displayHeadings.length - 1;

                    if (isLastColumn) {
                      return Container(
                        height: 52,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: CustomText(
                          text: getCategoryReason(widget.promoteReason),
                          isCopy: false,
                          textAlign: TextAlign.start,
                        ),
                      );
                    }

                    if (heading.toLowerCase() == "added date" ||
                        heading.toLowerCase() == "prospect enrollment date") {
                      return Container(
                        height: 52,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: CustomText(
                          text: formatDate(widget.updatedTs.toString()),
                          size: 14,
                          colors: colorsConst.textColor,
                          isCopy: false,
                          textAlign: TextAlign.start,
                        ),
                      );
                    }
                    if (heading.trim().toLowerCase() == "audio") {
                      final audio = (widget.audioUrl ?? "").trim();
                      final hasAudio = audio.isNotEmpty && audio != "null";
                      return Container(
                        height: 45,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: hasAudio
                            ? AudioMessagePlayer(url: audioFullUrl(audio))
                            : const SizedBox(),
                      );
                    }
                    // Existing code...
                    String normalize(String s) =>
                        s.replaceAll(RegExp(r'\s+'), ' ').trim().toLowerCase();

                    final key = controllers.fields
                        .firstWhereOrNull(
                            (f) => normalize(f.userHeading) == normalize(heading))
                        ?.systemField;

                    final controller = key != null ? fieldControllers[key] : null;

                    final isNameColumn = key == "mainName" || key == "name";

                    if (isNameColumn) {
                      final summary = getLastActivityText();
                      final hasActivity = summary != "No interaction yet";
                      final fullName = controller?.text.trim() ?? "";
                      return Tooltip(
                        message: getActivityTooltip(fullName),
                        waitDuration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(10),
                        textAlign: TextAlign.left,
                        textStyle: const TextStyle(fontSize: 12, color: Colors.white, height: 1.4),
                        child: Container(
                          height: 52,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  text: fullName,
                                  isCopy: false,
                                  textAlign: TextAlign.start,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  summary,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: hasActivity ? Colors.green.shade700 : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    return Container(
                      height: 52,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: CustomText(
                        text: controller?.text.trim() ?? "",
                        isCopy: false,
                        textAlign: TextAlign.start,
                      ),
                    );
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
        // apiService.allNewLeadsDetails();
        // apiService.allLeadsDetails();
        // apiService.allGoodLeadsDetails();
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

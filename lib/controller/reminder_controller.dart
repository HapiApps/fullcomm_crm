
import 'dart:convert';
import 'dart:developer';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/constant/colors_constant.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/common/styles/decoration.dart';
import 'package:fullcomm_crm/common/utilities/utils.dart';
import 'package:fullcomm_crm/services/api_services.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../common/constant/api.dart';
import '../common/utilities/jwt_storage.dart';
import '../common/utilities/mobile_snackbar.dart';
import '../components/Customtext.dart';
import '../models/all_customers_obj.dart';
import '../models/customer_activity.dart';
import '../models/meeting_obj.dart';
import '../models/reminder_obj.dart';
import '../provider/reminder_provider.dart';
import 'controller.dart';
import 'dashboard_controller.dart';

class AddReminderModel {
  final TextEditingController titleController = TextEditingController();
  RxMap<String, RxBool> remindVia = {
    "Desktop": false.obs,
    "Email": true.obs,
    "SMS": false.obs,
    "WhatsApp": false.obs,
    "App Notification": false.obs,
  }.obs;

  RxString selectedTime = "1 Min".obs;
  RxString customTime = "1 Day".obs;
  List<String> otherTimes = ["1 Day", "2 Days", "3 Days", "1 Week","1 Month"];
}

final remController = Get.put(ReminderController());

void showMeetingDialog(
    BuildContext context,
    List<MeetingObj> meetings,
    int index,
    ) {
  PageController controller = PageController(initialPage: index);

  if (meetings.isEmpty) return;

  showDialog(
    context: context,
    builder: (context) {
      int currentPage = index;
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Container(
              width: 420,
              // height: 400,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// 🔵 HEADER
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: colorsConst.primary,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomText(
                            text: "Appointment Details",
                            size: 16,
                            isBold: true,
                            colors: Colors.white,
                            isCopy: false,
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Color(0XFFE2E8F0),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              InkWell(
                                child: const Icon(Icons.arrow_back_ios, size: 15),
                                onTap: () {
                                  controller.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.ease,
                                  );
                                },
                              ),5.width,
                              CustomText(
                                text: "${currentPage + 1} / ${meetings.length}",
                                size: 14,isBold: true,
                                isCopy: false,
                              ),5.width,
                              InkWell(
                                child: const Icon(Icons.arrow_forward_ios_sharp, size: 15),
                                onTap: () {
                                  controller.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.ease,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        8.width,

                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.close, color: Colors.white),
                        )
                      ],
                    ),
                  ),
                  /// 📄 BODY
                  SizedBox(
                    height: 350, // ✅ மட்டும் இங்க height
                    child: PageView.builder(
                      controller: controller,
                      itemCount: meetings.length,
                      onPageChanged: (i) {
                        setState((){
                          currentPage = i;
                        });
                      },
                      itemBuilder: (context, i) {
                        final m = meetings[i];
                        String? selectedValue=m.status;

                        return SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      // color: Colors.pink,
                                      width:MediaQuery.of(context).size.width*0.05,
                                      child: CustomText(text: "COMPANY", isCopy: false,isBold: true,
                                      textAlign: TextAlign.start,),
                                    ),
                                    SizedBox(
                                      // color: Colors.yellow,
                                      width:MediaQuery.of(context).size.width*0.15,
                                      child: Row(
                                        children: [
                                          Image.asset("assets/images/alert2.png",width: 20,height: 20,),10.width,
                                          CustomText(text: m.comName, isCopy: false,textAlign: TextAlign.start,),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),10.height,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      // color: Colors.pink,
                                      width:MediaQuery.of(context).size.width*0.05,
                                      child: CustomText(text: "CUSTOMER", isCopy: false,isBold: true,
                                      textAlign: TextAlign.start,),
                                    ),
                                    SizedBox(
                                      // color: Colors.yellow,
                                      width:MediaQuery.of(context).size.width*0.15,
                                      child: Row(
                                        children: [
                                          Image.asset("assets/images/alert.png",width: 20,height: 20,),10.width,
                                          CustomText(text: m.cusName, isCopy: false,textAlign: TextAlign.start,),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),10.height,
                                Row(
                                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      // color: Colors.pink,
                                      width:MediaQuery.of(context).size.width*0.05,
                                      child: CustomText(text: "TITLE", isCopy: false,isBold: true,
                                      textAlign: TextAlign.start,),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width*0.005,
                                    ),
                                    Container(
                                      // alignment: Alignment.centerLeft,
                                      decoration: customDecoration.baseBackgroundDecoration(
                                        color: Color(0xFFE2E8F0),radius: 5
                                      ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: CustomText(text: m.title, isCopy: false,textAlign: TextAlign.start,),
                                        )),
                                  ],
                                ),10.height,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      // color: Colors.pink,
                                      width:MediaQuery.of(context).size.width*0.05,
                                      child: CustomText(text: "VENUE", isCopy: false,isBold: true,
                                      textAlign: TextAlign.start,),
                                    ),
                                    SizedBox(
                                      // color: Colors.yellow,
                                      width:MediaQuery.of(context).size.width*0.15,
                                      child: CustomText(text: m.venue, isCopy: false,textAlign: TextAlign.start,),
                                    ),
                                  ],
                                ),10.height,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      // color: Colors.pink,
                                      width:MediaQuery.of(context).size.width*0.05,
                                      child: CustomText(text: "DATE & TIME", isCopy: false,isBold: true,
                                      textAlign: TextAlign.start,),
                                    ),
                                    SizedBox(
                                      // color: Colors.yellow,
                                      width:MediaQuery.of(context).size.width*0.15,
                                      child: CustomText(text: utils.formatDateTime(m.dates,m.time), isBold: true,
                                        isCopy: false,textAlign: TextAlign.start,),
                                    ),
                                  ],
                                ),
                                10.height,
                                if(m.notes!="")
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      // color: Colors.pink,
                                      width:MediaQuery.of(context).size.width*0.05,
                                      child: CustomText(text: "NOTES", isCopy: false,isBold: true,
                                      textAlign: TextAlign.start,),
                                    ),
                                    SizedBox(
                                      // color: Colors.yellow,
                                      width:MediaQuery.of(context).size.width*0.15,
                                      child: Container(
                                        width: double.infinity,
                                        margin: const EdgeInsets.only(top: 10),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Color(0xFFF4F6F8),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border(
                                            left: BorderSide(color: colorsConst.primary, width: 3),
                                          ),
                                        ),
                                        child: CustomText(
                                          textAlign: TextAlign.start,
                                          text: m.notes ?? "",isStyle: true,
                                          isCopy: false,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if(m.notes!="")
                                10.height,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      // color: Colors.pink,
                                      width:MediaQuery.of(context).size.width*0.05,
                                      child: CustomText(text: "STATUS", isCopy: false,isBold: true,
                                      textAlign: TextAlign.start,),
                                    ),
                                    Container(
                                      decoration: customDecoration.baseBackgroundDecoration(
                                        color: Color(0xFFF4F6F8),radius: 5,shadowColor: Colors.grey.shade50,isShadow: true
                                      ),
                                      height: 35,
                                      width:MediaQuery.of(context).size.width*0.15,
                                      child: DropdownButtonFormField<String>(
                                        value: selectedValue,icon:Icon(Icons.keyboard_arrow_down_outlined),
                                        hint: CustomText(text: "Select",isCopy: false,),
                                        isExpanded: true,
                                        items: ["Scheduled", "Completed", "Cancelled"]
                                            .map((e) => DropdownMenuItem(
                                          value: e,
                                          child: CustomText(text: e,isCopy: false,),
                                        ))
                                            .toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            selectedValue = value;
                                          });
                                        },
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.grey.shade50),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.grey.shade50),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.grey.shade50),
                                          ),
                                          focusedErrorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.grey.shade50),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),10.height,
                                Divider(
                                  color: Colors.grey.shade100,
                                ),
                                10.height,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    InkWell(
                                      onTap: () => Navigator.pop(context),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        alignment: Alignment.center,
                                        child: CustomText(
                                          text: "Cancel",isBold: true,
                                          isCopy: false,colors: Colors.grey,
                                        ),
                                      ),
                                    ),10.width,
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: colorsConst.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      onPressed: () {
                                        remController.selectedMeetingIds.add(m.id);
                                        Navigator.pop(context);
                                        utils.appointmentStatus(context, m.status);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            Icon(Icons.done_all,size: 15,),5.width,
                                            CustomText(
                                              text: "Update Status",
                                              colors: Colors.white,
                                              isCopy: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

void showReminderDialog(
    BuildContext context,
    List<ReminderModel> list,
    int index,
    ) {
  PageController controller = PageController(initialPage: index);

  if (list.isEmpty) return;

  showDialog(
    context: context,
    builder: (context) {
      int currentPage = index;
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Container(
              width: 420,
              // height: 400,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// 🔵 HEADER
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: colorsConst.primary,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomText(
                            text: "Reminders Details",
                            size: 16,
                            isBold: true,
                            colors: Colors.white,
                            isCopy: false,
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Color(0XFFE2E8F0),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              InkWell(
                                child: const Icon(Icons.arrow_back_ios, size: 15),
                                onTap: () {
                                  controller.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.ease,
                                  );
                                },
                              ),5.width,
                              CustomText(
                                text: "${currentPage + 1} / ${list.length}",
                                size: 14,isBold: true,
                                isCopy: false,
                              ),5.width,
                              InkWell(
                                child: const Icon(Icons.arrow_forward_ios_sharp, size: 15),
                                onTap: () {
                                  controller.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.ease,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        8.width,

                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.close, color: Colors.white),
                        )
                      ],
                    ),
                  ),
                  /// 📄 BODY
                  SizedBox(
                    height: 350,
                    child: PageView.builder(
                      controller: controller,
                      itemCount: list.length,
                      onPageChanged: (i) {
                        setState((){
                          currentPage = i;
                        });
                      },
                      itemBuilder: (context, i) {
                        final m = list[i];

                        return SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      // color: Colors.pink,
                                      width:MediaQuery.of(context).size.width*0.05,
                                      child: CustomText(text: "CUSTOMER", isCopy: false,isBold: true,
                                        textAlign: TextAlign.start,),
                                    ),
                                    SizedBox(
                                      // color: Colors.yellow,
                                      width:MediaQuery.of(context).size.width*0.15,
                                      child: Row(
                                        children: [
                                          Image.asset("assets/images/alert.png",width: 20,height: 20,),10.width,
                                          CustomText(text: m.customerName, isCopy: false,textAlign: TextAlign.start,),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),10.height,
                                Row(
                                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      // color: Colors.pink,
                                      width:MediaQuery.of(context).size.width*0.05,
                                      child: CustomText(text: "EVENT NAME", isCopy: false,isBold: true,
                                        textAlign: TextAlign.start,),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width*0.005,
                                    ),
                                    Container(
                                      // alignment: Alignment.centerLeft,
                                        decoration: customDecoration.baseBackgroundDecoration(
                                            color: Color(0xFFE2E8F0),radius: 5
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: CustomText(text: m.title, isCopy: false,textAlign: TextAlign.start,),
                                        )),
                                  ],
                                ),10.height,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      // color: Colors.pink,
                                      width:MediaQuery.of(context).size.width*0.05,
                                      child: CustomText(text: "TYPE", isCopy: false,isBold: true,
                                        textAlign: TextAlign.start,),
                                    ),
                                    SizedBox(
                                      // color: Colors.yellow,
                                      width:MediaQuery.of(context).size.width*0.15,
                                      child: CustomText(text: m.type.toString()=="1"?"Follow-up":"Appointment", isCopy: false,textAlign: TextAlign.start,),
                                    ),
                                  ],
                                ),10.height,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      // color: Colors.pink,
                                      width:MediaQuery.of(context).size.width*0.05,
                                      child: CustomText(text: "EMPLOYEE", isCopy: false,isBold: true,
                                        textAlign: TextAlign.start,),
                                    ),
                                    SizedBox(
                                      // color: Colors.yellow,
                                      width:MediaQuery.of(context).size.width*0.15,
                                      child: CustomText(text: m.employeeName,
                                        isCopy: false,textAlign: TextAlign.start,),
                                    ),
                                  ],
                                ),
                                10.height,
                                if(m.location!="")
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        // color: Colors.pink,
                                        width:MediaQuery.of(context).size.width*0.05,
                                        child: CustomText(text: "LOCATION", isCopy: false,isBold: true,
                                          textAlign: TextAlign.start,),
                                      ),
                                      SizedBox(
                                        // color: Colors.yellow,
                                        width:MediaQuery.of(context).size.width*0.15,
                                        child: Container(
                                          width: double.infinity,
                                          margin: const EdgeInsets.only(top: 10),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Color(0xFFF4F6F8),
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border(
                                              left: BorderSide(color: colorsConst.primary, width: 3),
                                            ),
                                          ),
                                          child: CustomText(
                                            textAlign: TextAlign.start,
                                            text: m.location ?? "",isStyle: true,
                                            isCopy: false,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                if(m.location!="")
                                10.height,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      // color: Colors.pink,
                                      width:MediaQuery.of(context).size.width*0.05,
                                      child: CustomText(text: "START DATE", isCopy: false,isBold: true,
                                        textAlign: TextAlign.start,),
                                    ),
                                    SizedBox(
                                      // color: Colors.yellow,
                                      width:MediaQuery.of(context).size.width*0.15,
                                      child: CustomText(text: m.startDt,
                                        isCopy: false,textAlign: TextAlign.start,),
                                    ),
                                  ],
                                ),10.height,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      // color: Colors.pink,
                                      width:MediaQuery.of(context).size.width*0.05,
                                      child: CustomText(text: "END DATE", isCopy: false,isBold: true,
                                        textAlign: TextAlign.start,),
                                    ),
                                    SizedBox(
                                      // color: Colors.yellow,
                                      width:MediaQuery.of(context).size.width*0.15,
                                      child: CustomText(text: m.endDt,
                                        isCopy: false,textAlign: TextAlign.start,),
                                    ),
                                  ],
                                ),10.height,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      // color: Colors.pink,
                                      width:MediaQuery.of(context).size.width*0.05,
                                      child: CustomText(text: "DETAILS", isCopy: false,isBold: true,
                                        textAlign: TextAlign.start,),
                                    ),
                                    SizedBox(
                                      // color: Colors.yellow,
                                      width:MediaQuery.of(context).size.width*0.15,
                                      child: CustomText(text: m.details,
                                        isCopy: false,textAlign: TextAlign.start,),
                                    ),
                                  ],
                                ),10.height,
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

void showCallDialog(BuildContext context,List<CustomerActivity> list,int index) {
  PageController controller = PageController(initialPage: index);
  if (list.isEmpty) return;
  showDialog(
    context: context,
    builder: (context) {
      int currentPage = index;
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Container(
              width: 420,
              // height: 400,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// 🔵 HEADER
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: colorsConst.primary,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomText(
                            text: "Communication Details",
                            size: 16,
                            isBold: true,
                            colors: Colors.white,
                            isCopy: false,
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Color(0XFFE2E8F0),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              InkWell(
                                child: const Icon(Icons.arrow_back_ios, size: 15),
                                onTap: () {
                                  controller.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.ease,
                                  );
                                },
                              ),5.width,
                              CustomText(
                                text: "${currentPage + 1} / ${list.length}",
                                size: 14,isBold: true,
                                isCopy: false,
                              ),5.width,
                              InkWell(
                                child: const Icon(Icons.arrow_forward_ios_sharp, size: 15),
                                onTap: () {
                                  controller.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.ease,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        8.width,

                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.close, color: Colors.white),
                        )
                      ],
                    ),
                  ),
                  /// 📄 BODY
                  SizedBox(
                    height: 350,
                    child: PageView.builder(
                      controller: controller,
                      itemCount: list.length,
                      onPageChanged: (i) {
                        setState((){
                          currentPage = i;
                        });
                      },
                      itemBuilder: (context, i) {
                        final m = list[i];

                        return SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      // color: Colors.pink,
                                      width:MediaQuery.of(context).size.width*0.05,
                                      child: CustomText(text: "CUSTOMER", isCopy: false,isBold: true,
                                        textAlign: TextAlign.start,),
                                    ),
                                    SizedBox(
                                      // color: Colors.yellow,
                                      width:MediaQuery.of(context).size.width*0.15,
                                      child: Row(
                                        children: [
                                          Image.asset("assets/images/alert.png",width: 20,height: 20,),10.width,
                                          CustomText(text: m.customerName, isCopy: false,textAlign: TextAlign.start,),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),10.height,
                                Row(
                                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      // color: Colors.pink,
                                      width:MediaQuery.of(context).size.width*0.05,
                                      child: CustomText(text: "COMPANY", isCopy: false,isBold: true,
                                        textAlign: TextAlign.start,),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width*0.005,
                                    ),
                                    Container(
                                      // alignment: Alignment.centerLeft,
                                        decoration: customDecoration.baseBackgroundDecoration(
                                            color: Color(0xFFE2E8F0),radius: 5
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: CustomText(text: m.companyName.toString(), isCopy: false,textAlign: TextAlign.start,),
                                        )),
                                  ],
                                ),10.height,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      // color: Colors.pink,
                                      width:MediaQuery.of(context).size.width*0.05,
                                      child: CustomText(text: "CALL DATA", isCopy: false,isBold: true,
                                        textAlign: TextAlign.start,),
                                    ),
                                    SizedBox(
                                      // color: Colors.yellow,
                                      width:MediaQuery.of(context).size.width*0.15,
                                      child: CustomText(text: "${m.sentDate.toString().split(" ")[1]} ${m.sentDate.toString().split(" ")[2]}", isCopy: false,textAlign: TextAlign.start,),
                                    ),
                                  ],
                                ),10.height,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      // color: Colors.pink,
                                      width:MediaQuery.of(context).size.width*0.05,
                                      child: CustomText(text: "CALL TYPE", isCopy: false,isBold: true,
                                        textAlign: TextAlign.start,),
                                    ),
                                    SizedBox(
                                      // color: Colors.yellow,
                                      width:MediaQuery.of(context).size.width*0.15,
                                      child: CustomText(text: m.callType,
                                        isCopy: false,textAlign: TextAlign.start,),
                                    ),
                                  ],
                                ),
                                10.height,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      // color: Colors.pink,
                                      width:MediaQuery.of(context).size.width*0.05,
                                      child: CustomText(text: "TYPE", isCopy: false,isBold: true,
                                        textAlign: TextAlign.start,),
                                    ),
                                    SizedBox(
                                      // color: Colors.yellow,
                                      width:MediaQuery.of(context).size.width*0.15,
                                      child: CustomText(text: m.callStatus=="null"||m.callStatus==""?"Mail":"Call",
                                        isCopy: false,textAlign: TextAlign.start,colors: Colors.green,),
                                    ),
                                  ],
                                ),10.height,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      // color: Colors.pink,
                                      width:MediaQuery.of(context).size.width*0.05,
                                      child: CustomText(text: "ADDED BY", isCopy: false,isBold: true,
                                        textAlign: TextAlign.start,),
                                    ),
                                    SizedBox(
                                      // color: Colors.yellow,
                                      width:MediaQuery.of(context).size.width*0.15,
                                      child: CustomText(text: m.name,
                                        isCopy: false,textAlign: TextAlign.start,),
                                    ),
                                  ],
                                ),
                                10.height,
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

class ReminderController extends GetxController with GetSingleTickerProviderStateMixin {
  // late CalendarDataSource dataSource;
  late CalendarDataSource dataSource;
  var filterCall = "All".obs;
  var filterRem = "All".obs;
  var filterApp = "All".obs;

  bool hasAppointment(DateTime date) {
    return dataSource.appointments!.any((appt) =>
    appt.startTime.year == date.year &&
        appt.startTime.month == date.month &&
        appt.startTime.day == date.day);
  }
  bool hasStatus(DateTime date, String status) {
    return dataSource.appointments!.any((appt) =>
    appt.startTime.year == date.year &&
        appt.startTime.month == date.month &&
        appt.startTime.day == date.day &&
        (appt.subject?.toLowerCase() ?? '') == status.toLowerCase());
  }
  TextEditingController titleController       = TextEditingController();
  TextEditingController detailsController     = TextEditingController();
  TextEditingController startController       = TextEditingController();
  TextEditingController endController         = TextEditingController();
  String? location;
  String? repeat;
  String? repeatOn;
  String repeatWise = "Never";
  String? repeatEvery;

  var stDate = "".obs;
  var stTime = "".obs;
  var enDate = "".obs;
  var enTime = "".obs;

  String defaultTime = "Immediately";
  RxList<AddReminderModel> reminders = <AddReminderModel>[AddReminderModel()].obs;
  final listKey = GlobalKey<AnimatedListState>();
  //Santhiya
  void addReminder() {
    bool allFilled = true;
    for (var i = 0; i < reminders.length; i++) {
      if (reminders[i].titleController.text.isEmpty) {
        allFilled = false;
        break;
      }
    }
    if (allFilled) {
      reminders.add(AddReminderModel());
    }else{
      mobileUtils.snackBar(
          context: Get.context!,
          msg: "Please enter reminder title",
          color: Colors.red);
    }
  }

  void removeReminder(int index) {
    reminders.removeAt(index);
  }
  DateTime selectedDate = DateTime.now();
  var filterDate = "".obs;
  void filterDateList(String value,DateTime dateTime){
    filterDate.value=value;
    selectedDate = dateTime;
  }
  var assignedIds="".obs;
  var assignedNames="".obs;
  var assignedNumbers="".obs;
  var assignedEmail="".obs;
  void changeAssignedIs(context, List<dynamic> names) {
    List<String> ids = [];
    List<String> selectedNames = [];
    List<String> numbers = [];
    List<String> mails = [];


    for (var name in names) {
      var found = controllers.employees.firstWhere(
            (element) => element.name.toString().trim().toLowerCase() == name.toString().trim().toLowerCase(),
        orElse: () => AllEmployeesObj(id: "0", name: '', phoneNo: '', email: ''),
      );

      if (found.id != "0") {
        ids.add(found.id.toString());
        selectedNames.add(found.name.toString());
        numbers.add(found.phoneNo.toString());
        mails.add(found.email.toString());
      }
    }

    assignedIds.value = ids.join(",");
    assignedNames.value = selectedNames.join(", ");
    assignedNumbers.value = numbers.join(", ");
    assignedEmail.value = mails.join(", ");
    controllers.selectedEmployeeId.value = assignedIds.value;
    controllers.selectedEmployeeName.value = assignedNames.value;
    controllers.selectedEmployeeMobile.value = assignedNumbers.value;
    controllers.selectedEmployeeEmail.value = assignedEmail.value;
    // print("Assigned IDs: $_assignedId");
    // print("Assigned Names: $_assignedNames");
  }

  TextEditingController updateTitleController   = TextEditingController();
  TextEditingController updateDetailsController = TextEditingController();
  TextEditingController updateStartController   = TextEditingController();
  TextEditingController updateEndController     = TextEditingController();
  String? updateLocation;
  String? updateRepeat;

  var sortFieldCallActivity = ''.obs;
  var setType = ''.obs;
  var sortOrderCallActivity = 'asc'.obs;
  var searchText = ''.obs;
  final Rxn<DateTime> selectedCallMonth = Rxn<DateTime>();
  final Rxn<DateTime> selectedMailMonth = Rxn<DateTime>();
  final Rxn<DateTime> selectedMeetMonth = Rxn<DateTime>();
  final Rxn<DateTime> selectedReminderMonth = Rxn<DateTime>();
  RxString selectedCallSortBy = "Today".obs;
  RxString selectedMailSortBy = "All".obs;
  RxString selectedMeetSortBy = "Today".obs;
  RxString selectedReminderSortBy = "Today".obs;

  void loadSavedFilters() {
    final storage = controllers.storage.read("selectedSortBy");
    dashController.selectedSortBy.value = storage ?? "Today";
    controllers.selectedProspectSortBy.value = storage ?? "All";
    controllers.selectedQualifiedSortBy.value = storage ?? "All";
    controllers.selectedCustomerSortBy.value = storage ?? "All";
    selectedCallSortBy.value = storage ?? "All";
    selectedMailSortBy.value = storage ?? "All";
    selectedMeetSortBy.value = storage ?? "All";
    selectedReminderSortBy.value = storage ?? "All";
  }

  var selectedCallRange = Rxn<DateTimeRange>();
  var selectedMailRange = Rxn<DateTimeRange>();
  var selectedMeetRange = Rxn<DateTimeRange>();
  var selectedReminderRange = Rxn<DateTimeRange>();
  var reminderList = <ReminderModel>[].obs;
  var selectedReminderIds = <String>[].obs;
  var selectedMeetingIds = <String>[].obs;
  var selectedRecordMailIds = <String>[].obs;
  var selectedRecordCallIds = <String>[].obs;
  RxList<CustomerActivity> callMailsDetailsList  = <CustomerActivity>[].obs;
  RxList<CustomerActivity> callMailsDetailsList2  = <CustomerActivity>[].obs;
  RxList<CustomerActivity> callFilteredList  = <CustomerActivity>[].obs;
  RxList<CustomerActivity> mailFilteredList  = <CustomerActivity>[].obs;
  RxList<MeetingObj> meetingFilteredList     = <MeetingObj>[].obs;
  RxList<ReminderModel> reminderFilteredList = <ReminderModel>[].obs;

  void selectMonth(BuildContext context, RxString sortByKey, Rxn<DateTime> selectedMonthTarget,VoidCallback onMonthSelected) {
    final now = DateTime.now();
    showMonthPicker(
      context: context,
      monthStylePredicate: (month) {
        if (month.month == now.month && month.year == now.year) {
          return ButtonStyle(
            foregroundColor: WidgetStateProperty.all(Colors.white),
            backgroundColor:
            WidgetStateProperty.all(Colors.blue.withOpacity(0.2)),
          );
        }
        return null;
      },
      initialDate: selectedMonthTarget.value ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year, now.month + 1, 0),
    ).then((selected) {
      if (selected != null) {
        sortByKey.value = 'Custom Month';
        selectedMonthTarget.value = selected;
        onMonthSelected();
      }
    });
  }

  var reminderTitleController = TextEditingController();
  var remindVia = {
    "Desktop": true.obs,
    "Email": true.obs,
    "SMS": true.obs,
    "WhatsApp": false.obs,
    "App": false.obs,
  };

  var selectedTime = "Other".obs;
  var customTime = "1 Day".obs;

  List<String> otherTimes = ["1 Day", "2 Days", "3 Days", "1 Week"];

  void showDatePickerDialog(BuildContext context,void Function(DateTimeRange)? onDateSelected) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        dynamic tempRange;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xffFFFCF9),
              title: const Text(
                'Select Date',
                style: TextStyle(
                  color: Color(0xFF004AAD),
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SizedBox(
                height: 300,
                width: 350,
                child: SfDateRangePicker(
                  backgroundColor: const Color(0xffFFFCF9),
                  minDate: DateTime(2023),
                  maxDate: DateTime.now(),
                  selectionMode: DateRangePickerSelectionMode.extendableRange,
                  selectionShape: DateRangePickerSelectionShape.circle,
                  selectionRadius: 18,
                  selectionColor: const Color(0xFF004AAD),
                  startRangeSelectionColor: const Color(0xFF004AAD),
                  endRangeSelectionColor: const Color(0xFF004AAD),
                  rangeSelectionColor: const Color(0x22004AAD),
                  monthCellStyle: const DateRangePickerMonthCellStyle(
                    textStyle: TextStyle(
                      fontSize: 14,
                      height: 1.0,
                      color: Colors.black87,
                    ),
                    todayTextStyle: TextStyle(
                      fontSize: 14,
                      height: 1.0,
                      color: Colors.black87,
                    ),
                  ),
                  monthViewSettings: const DateRangePickerMonthViewSettings(
                    dayFormat: 'EEE',
                    viewHeaderHeight: 28,
                  ),
                  selectionTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    height: 1.0,
                  ),
                  onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                    setState(() {
                      if (args.value is PickerDateRange) {
                        tempRange = args.value;
                      } else if (args.value is DateTime) {
                        tempRange = PickerDateRange(args.value, args.value);
                      }
                    });
                  },
                ),
              ),
              actions: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Center(
                    child: Text(
                      'Click and drag to select multiple dates',
                      style: TextStyle(
                        color: Color(0xFF004AAD),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                      //   if (tempRange != null) {
                      //     if (onDateSelected != null) {
                      //       onDateSelected(
                      //         DateTimeRange(
                      //           start: tempRange.startDate!,
                      //           end: tempRange.endDate!,
                      //         ),
                      //       );
                      //     }
                      //   }
                      //   Navigator.pop(context);
                        if (tempRange != null) {

                          DateTime start = tempRange!.startDate!;
                          DateTime end =
                              tempRange!.endDate ?? tempRange!.startDate!;

                          if (onDateSelected != null) {

                            onDateSelected(
                              DateTimeRange(
                                start: start,
                                end: end,
                              ),
                            );
                          }
                        }

                        Navigator.pop(context);
                      },
                      child: const Text(
                        'OK',
                        style: TextStyle(
                          color: Color(0xFF004AAD),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  // void filterAndSortCalls({
  //   required List<CustomerActivity> allCalls,
  //   required String searchText,
  //   required String callType,
  //   required String sortField,
  //   required String sortOrder,
  //   required String selectedDateFilter, // Today, Yesterday, etc.
  //   required DateTime? selectedMonth,
  //   required DateTimeRange? selectedRange,
  // }) {
  //   DateTime parseDate(String dateStr) {
  //     try {
  //       return DateFormat("dd.MM.yyyy hh:mm a").parse(dateStr);
  //     } catch (e) {
  //       return DateTime(1900);
  //     }
  //   }
  //   final now = DateTime.now();
  //   final today = DateTime(now.year, now.month, now.day);
  //   final filtered = allCalls.where((activity) {
  //     final matchesCallType =
  //         callType.isEmpty || callType == "All" || activity.callStatus == callType;
  //     final matchesSearch = searchText.isEmpty ||
  //         activity.customerName.toLowerCase().contains(searchText.toLowerCase()) ||
  //         activity.sentDate.toLowerCase().contains(searchText.toLowerCase());
  //
  //     final activityDate = parseDate(activity.sentDate);
  //     bool matchesDate = true;
  //     if (selectedDateFilter == "Today") {
  //       matchesDate = activityDate.isAfter(today) && activityDate.isBefore(today.add(const Duration(days: 1)));
  //     } else if (selectedDateFilter == "Yesterday") {
  //       final yesterday = today.subtract(const Duration(days: 1));
  //       matchesDate = activityDate.isAfter(yesterday) && activityDate.isBefore(today);
  //     } else if (selectedDateFilter == "Last 7 Days") {
  //       final sevenDaysAgo = today.subtract(const Duration(days: 7));
  //       matchesDate = activityDate.isAfter(sevenDaysAgo);
  //     } else if (selectedDateFilter == "Last 30 Days") {
  //       final thirtyDaysAgo = today.subtract(const Duration(days: 30));
  //       matchesDate = activityDate.isAfter(thirtyDaysAgo);
  //     }
  //     if (selectedRange != null) {
  //       matchesDate = activityDate.isAfter(selectedRange.start.subtract(const Duration(seconds: 1))) &&
  //           activityDate.isBefore(selectedRange.end.add(const Duration(seconds: 1)));
  //     }
  //     if (selectedMonth != null) {
  //       matchesDate = (activityDate.month == selectedMonth.month &&
  //           activityDate.year == selectedMonth.year);
  //     }
  //
  //     return matchesCallType && matchesSearch && matchesDate;
  //   }).toList();
  //   if (sortField == 'customerName') {
  //     filtered.sort((a, b) {
  //       final nameA = a.customerName.toLowerCase();
  //       final nameB = b.customerName.toLowerCase();
  //       final comparison = nameA.compareTo(nameB);
  //       return sortOrder == 'asc' ? comparison : -comparison;
  //     });
  //   } else if (sortField == 'mobile') {
  //     filtered.sort((a, b) {
  //       final nameA = a.toData.toLowerCase();
  //       final nameB = b.toData.toLowerCase();
  //       final comparison = nameA.compareTo(nameB);
  //       return sortOrder == 'asc' ? comparison : -comparison;
  //     });
  //   } else if (sortField == 'type') {
  //     filtered.sort((a, b) {
  //       final nameA = a.callType.toLowerCase();
  //       final nameB = b.callType.toLowerCase();
  //       final comparison = nameA.compareTo(nameB);
  //       return sortOrder == 'asc' ? comparison : -comparison;
  //     });
  //   } else if (sortField == 'status') {
  //     filtered.sort((a, b) {
  //       final nameA = a.callStatus.toLowerCase();
  //       final nameB = b.callStatus.toLowerCase();
  //       final comparison = nameA.compareTo(nameB);
  //       return sortOrder == 'asc' ? comparison : -comparison;
  //     });
  //   } else if (sortField == 'message') {
  //     filtered.sort((a, b) {
  //       final nameA = a.message.toLowerCase();
  //       final nameB = b.message.toLowerCase();
  //       final comparison = nameA.compareTo(nameB);
  //       return sortOrder == 'asc' ? comparison : -comparison;
  //     });
  //   } else if (sortField == 'leadStatus') {
  //     filtered.sort((a, b) {
  //       final nameA = a.leadStatus.toLowerCase();
  //       final nameB = b.leadStatus.toLowerCase();
  //       final comparison = nameA.compareTo(nameB);
  //       return sortOrder == 'asc' ? comparison : -comparison;
  //     });
  //   } else if (sortField == 'date') {
  //     filtered.sort((a, b) {
  //       final dateA = parseDate(a.sentDate);
  //       final dateB = parseDate(b.sentDate);
  //       final comparison = dateA.compareTo(dateB);
  //       return sortOrder == 'asc' ? comparison : -comparison;
  //     });
  //   }
  //   callFilteredList.assignAll(filtered);
  // }

  void filterAndSortCalls({
    required List<CustomerActivity> allCalls,
    required String searchText,
    required String callType,
    required String sortField,
    required String sortOrder,
    required String selectedDateFilter,
    required DateTime? selectedMonth,
    required DateTimeRange? selectedRange,
  }) {
    DateTime parseDate(String dateStr) {
      try {
        return DateFormat("dd-MM-yyyy hh.mm a").parse(dateStr);
      } catch (e) {
        print("❌ Date parse error: $dateStr");
        return DateTime(1900);
      }
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final filtered = allCalls.where((activity) {

      final matchesCallType =
          callType.isEmpty || callType == "All" || activity.callStatus == callType;

      final matchesFilterType =
          filterCall.value == "All" ||
              (filterCall.value == "Mine" &&
                  activity.name == controllers.storage.read("f_name")) ||
              (filterCall.value == "Team" &&
                  activity.name != controllers.storage.read("f_name"));

      final matchesSearch =
          searchText.isEmpty ||
              activity.customerName.toLowerCase().contains(searchText.toLowerCase()) ||
              activity.sentDate.toLowerCase().contains(searchText.toLowerCase());

      final activityDate = parseDate(activity.sentDate);

      bool matchesDate = true;

      /// Today
      if (selectedDateFilter == "Today") {
        matchesDate = activityDate.year == now.year &&
            activityDate.month == now.month &&
            activityDate.day == now.day;
      }

      /// Yesterday
      else if (selectedDateFilter == "Yesterday") {
        final yesterday = today.subtract(const Duration(days: 1));
        matchesDate = activityDate.isAfter(yesterday.subtract(const Duration(seconds: 1))) &&
            activityDate.isBefore(today);
      }

      /// Last 7 Days
      else if (selectedDateFilter == "Last 7 Days") {
        final sevenDaysAgo = today.subtract(const Duration(days: 7));
        matchesDate = activityDate.isAfter(sevenDaysAgo.subtract(const Duration(seconds: 1)));
      }

      /// Last 30 Days
      else if (selectedDateFilter == "Last 30 Days") {
        final thirtyDaysAgo = today.subtract(const Duration(days: 30));
        matchesDate = activityDate.isAfter(thirtyDaysAgo.subtract(const Duration(seconds: 1)));
      }

      /// Date Range Filter (same date issue fixed)
      if (selectedRange != null) {

        final start = DateTime(
          selectedRange.start.year,
          selectedRange.start.month,
          selectedRange.start.day,
        );

        final end = DateTime(
          selectedRange.end.year,
          selectedRange.end.month,
          selectedRange.end.day,
          23, 59, 59,
        );

        matchesDate = activityDate.isAfter(start.subtract(const Duration(seconds: 1))) &&
            activityDate.isBefore(end.add(const Duration(seconds: 1)));
      }

      /// Month Filter
      if (selectedMonth != null) {
        matchesDate = activityDate.month == selectedMonth.month &&
            activityDate.year == selectedMonth.year;
      }

      return matchesCallType && matchesSearch && matchesDate && matchesFilterType;

    }).toList();

    /// Sorting
    if (sortField == 'customerName') {
      filtered.sort((a, b) {
        final comparison =
        a.customerName.toLowerCase().compareTo(b.customerName.toLowerCase());
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }

    else if (sortField == 'mobile') {
      filtered.sort((a, b) {
        final comparison =
        a.toData.toLowerCase().compareTo(b.toData.toLowerCase());
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }

    else if (sortField == 'type') {
      filtered.sort((a, b) {
        final comparison =
        a.callType.toLowerCase().compareTo(b.callType.toLowerCase());
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }

    else if (sortField == 'status') {
      filtered.sort((a, b) {
        final comparison =
        a.callStatus.toLowerCase().compareTo(b.callStatus.toLowerCase());
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }

    else if (sortField == 'message') {
      filtered.sort((a, b) {
        final comparison =
        a.message.toLowerCase().compareTo(b.message.toLowerCase());
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }

    else if (sortField == 'leadStatus') {
      filtered.sort((a, b) {
        final comparison =
        a.leadStatus.toLowerCase().compareTo(b.leadStatus.toLowerCase());
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }
    else if (sortField == 'addedBy') {
      filtered.sort((a, b) {
        final comparison =
        a.name.toLowerCase().compareTo(b.name.toLowerCase());
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }
    else if (sortField == 'company') {
      filtered.sort((a, b) {
        final comparison =
        a.companyName.toLowerCase().compareTo(b.companyName.toLowerCase());
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }

    else if (sortField == 'date') {
      filtered.sort((a, b) {
        final dateA = parseDate(a.sentDate);
        final dateB = parseDate(b.sentDate);
        final comparison = dateA.compareTo(dateB);
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }

    callFilteredList.assignAll(filtered);
    // apiService.mergeStatusWithCount();
  }

  // void dashboardCommunicationFilterList({
  //   required List<CustomerActivity> dataList,
  //   required String searchText,
  //   required String callType,
  //   required String sortField,
  //   required String sortOrder,
  //   required String selectedDateFilter,
  //   required DateTime? selectedMonth,
  //   required DateTimeRange? selectedRange,
  // }) {
  //   log("dataList: ${dataList.length}");
  //   DateTime parseDate(String dateStr) {
  //     final formats = [
  //       "dd.MM.yyyy h:mm a",  // 17.03.2026 12:14 PM
  //       "dd-MM-yyyy h.mm a",  // 17-03-2026 12.09 PM
  //       "dd-MM-yyyy h:mm a",  // safety
  //       "dd.MM.yyyy h.mm a",  // safety
  //     ];
  //
  //     for (var format in formats) {
  //       try {
  //         return DateFormat(format).parseStrict(dateStr.trim());
  //       } catch (_) {}
  //     }
  //
  //     print("❌ Date parse error: $dateStr");
  //     return DateTime(1900);
  //   }
  //
  //   final now = DateTime.now();
  //   final today = DateTime(now.year, now.month, now.day);
  //
  //   final filtered = dataList.where((activity) {
  //
  //     final matchesCallType =
  //         callType.isEmpty || callType == "All" || activity.callStatus == callType;
  //
  //     final matchesFilterType =
  //         filterCall.value == "All" ||
  //             (filterCall.value == "Mine" &&
  //                 activity.name == controllers.storage.read("f_name")) ||
  //             (filterCall.value == "Team" &&
  //                 activity.name != controllers.storage.read("f_name"));
  //
  //     final matchesSearch =
  //         searchText.isEmpty ||
  //             activity.customerName.toLowerCase().contains(searchText.toLowerCase()) ||
  //             activity.sentDate.toLowerCase().contains(searchText.toLowerCase());
  //
  //     final activityDate = parseDate(activity.sentDate);
  //
  //     bool matchesDate = true;
  //
  //     /// Today
  //     if (selectedDateFilter == "Today") {
  //       matchesDate = activityDate.year == now.year &&
  //           activityDate.month == now.month &&
  //           activityDate.day == now.day;
  //     }
  //
  //     /// Yesterday
  //     else if (selectedDateFilter == "Yesterday") {
  //       final yesterday = today.subtract(const Duration(days: 1));
  //       matchesDate = activityDate.isAfter(yesterday.subtract(const Duration(seconds: 1))) &&
  //           activityDate.isBefore(today);
  //     }
  //
  //     /// Last 7 Days
  //     else if (selectedDateFilter == "Last 7 Days") {
  //       final sevenDaysAgo = today.subtract(const Duration(days: 7));
  //       matchesDate = activityDate.isAfter(sevenDaysAgo.subtract(const Duration(seconds: 1)));
  //     }
  //
  //     /// Last 30 Days
  //     else if (selectedDateFilter == "Last 30 Days") {
  //       final thirtyDaysAgo = today.subtract(const Duration(days: 30));
  //       matchesDate = activityDate.isAfter(thirtyDaysAgo.subtract(const Duration(seconds: 1)));
  //     }
  //
  //     /// Date Range Filter (same date issue fixed)
  //     if (selectedRange != null) {
  //
  //       final start = DateTime(
  //         selectedRange.start.year,
  //         selectedRange.start.month,
  //         selectedRange.start.day,
  //       );
  //
  //       final end = DateTime(
  //         selectedRange.end.year,
  //         selectedRange.end.month,
  //         selectedRange.end.day,
  //         23, 59, 59,
  //       );
  //
  //       matchesDate = activityDate.isAfter(start.subtract(const Duration(seconds: 1))) &&
  //           activityDate.isBefore(end.add(const Duration(seconds: 1)));
  //     }
  //
  //     /// Month Filter
  //     if (selectedMonth != null) {
  //       matchesDate = activityDate.month == selectedMonth.month &&
  //           activityDate.year == selectedMonth.year;
  //     }
  //
  //     return matchesCallType && matchesSearch && matchesDate && matchesFilterType;
  //
  //   }).toList();
  //
  //   /// Sorting
  //   if (sortField == 'customerName') {
  //     filtered.sort((a, b) {
  //       final comparison =
  //       a.customerName.toLowerCase().compareTo(b.customerName.toLowerCase());
  //       return sortOrder == 'asc' ? comparison : -comparison;
  //     });
  //   }
  //
  //   else if (sortField == 'mobile') {
  //     filtered.sort((a, b) {
  //       final comparison =
  //       a.toData.toLowerCase().compareTo(b.toData.toLowerCase());
  //       return sortOrder == 'asc' ? comparison : -comparison;
  //     });
  //   }
  //
  //   else if (sortField == 'type') {
  //     filtered.sort((a, b) {
  //       final comparison =
  //       a.callType.toLowerCase().compareTo(b.callType.toLowerCase());
  //       return sortOrder == 'asc' ? comparison : -comparison;
  //     });
  //   }
  //
  //   else if (sortField == 'status') {
  //     filtered.sort((a, b) {
  //       final comparison =
  //       a.callStatus.toLowerCase().compareTo(b.callStatus.toLowerCase());
  //       return sortOrder == 'asc' ? comparison : -comparison;
  //     });
  //   }
  //
  //   else if (sortField == 'message') {
  //     filtered.sort((a, b) {
  //       final comparison =
  //       a.message.toLowerCase().compareTo(b.message.toLowerCase());
  //       return sortOrder == 'asc' ? comparison : -comparison;
  //     });
  //   }
  //
  //   else if (sortField == 'leadStatus') {
  //     filtered.sort((a, b) {
  //       final comparison =
  //       a.leadStatus.toLowerCase().compareTo(b.leadStatus.toLowerCase());
  //       return sortOrder == 'asc' ? comparison : -comparison;
  //     });
  //   }
  //   else if (sortField == 'addedBy') {
  //     filtered.sort((a, b) {
  //       final comparison =
  //       a.name.toLowerCase().compareTo(b.name.toLowerCase());
  //       return sortOrder == 'asc' ? comparison : -comparison;
  //     });
  //   }
  //   else if (sortField == 'company') {
  //     filtered.sort((a, b) {
  //       final comparison =
  //       a.companyName.toLowerCase().compareTo(b.companyName.toLowerCase());
  //       return sortOrder == 'asc' ? comparison : -comparison;
  //     });
  //   }
  //
  //   else if (sortField == 'date') {
  //     filtered.sort((a, b) {
  //       final dateA = parseDate(a.sentDate);
  //       final dateB = parseDate(b.sentDate);
  //       final comparison = dateA.compareTo(dateB);
  //       return sortOrder == 'asc' ? comparison : -comparison;
  //     });
  //   }
  //
  //   callMailsFilterList.assignAll(filtered);
  //   debugPrint("callMailsFilterList ${callMailsFilterList.length}");
  //   // apiService.mergeStatusWithCount();
  // }
  ///
  // void dashboardCommunicationFilterList({
  //   required List<CustomerActivity> dataList,
  //   required String searchText,
  //   required String callType,
  //   required String sortField,
  //   required String sortOrder,
  //   required String selectedDateFilter,
  //   required DateTime? selectedMonth,
  //   required DateTimeRange? selectedRange,
  // }) {
  //   print("dataList length: ${dataList.length}");
  //
  //   DateTime parseDate(String dateStr) {
  //     final formats = [
  //       "dd.MM.yyyy h:mm a",
  //       "dd-MM-yyyy h.mm a",
  //       "dd-MM-yyyy h:mm a",
  //       "dd.MM.yyyy h.mm a",
  //     ];
  //
  //     for (var format in formats) {
  //       try {
  //         return DateFormat(format).parseStrict(dateStr.trim());
  //       } catch (_) {}
  //     }
  //
  //     print("❌ Date parse error: $dateStr");
  //     return DateTime(1900);
  //   }
  //
  //   final now = DateTime.now();
  //   final today = DateTime(now.year, now.month, now.day);
  //
  //   final filtered = dataList.where((activity) {
  //     print("\n----------------------------");
  //     print("Customer: ${activity.customerName}");
  //     print("Raw Date: ${activity.sentDate}");
  //
  //     /// Mine / Team Filter
  //     final matchesFilterType =
  //         filterCall.value == "All" ||
  //             (filterCall.value == "Mine" &&
  //                 activity.name == controllers.storage.read("f_name")) ||
  //             (filterCall.value == "Team" &&
  //                 activity.name != controllers.storage.read("f_name"));
  //     print("matchesFilterType: $matchesFilterType");
  //
  //     /// Search
  //     final matchesSearch =
  //         searchText.isEmpty ||
  //             activity.customerName.toLowerCase().contains(searchText.toLowerCase()) ||
  //             activity.sentDate.toLowerCase().contains(searchText.toLowerCase());
  //     print("matchesSearch: $matchesSearch");
  //
  //     final activityDate = parseDate(activity.sentDate);
  //     print("Parsed Date: $activityDate");
  //
  //     bool matchesDate = true;
  //
  //     /// 🔥 Priority: Range > Month > Quick Filters
  //
  //     /// Date Range
  //     if (selectedRange != null) {
  //       final start = DateTime(
  //         selectedRange.start.year,
  //         selectedRange.start.month,
  //         selectedRange.start.day,
  //       );
  //
  //       final end = DateTime(
  //         selectedRange.end.year,
  //         selectedRange.end.month,
  //         selectedRange.end.day,
  //         23, 59, 59,
  //       );
  //
  //       matchesDate = activityDate.isAfter(start.subtract(const Duration(seconds: 1))) &&
  //           activityDate.isBefore(end.add(const Duration(seconds: 1)));
  //
  //       print("Filter: Range → $matchesDate");
  //       print("Start: $start | End: $end");
  //     }
  //
  //     /// Month Filter
  //     else if (selectedMonth != null) {
  //       matchesDate = activityDate.month == selectedMonth.month &&
  //           activityDate.year == selectedMonth.year;
  //
  //       print("Filter: Month → $matchesDate");
  //     }
  //
  //     /// Quick Filters
  //     else {
  //       if (selectedDateFilter == "Today") {
  //         matchesDate = activityDate.year == now.year &&
  //             activityDate.month == now.month &&
  //             activityDate.day == now.day;
  //
  //         print("Filter: Today → $matchesDate");
  //       }
  //
  //       else if (selectedDateFilter == "Yesterday") {
  //         final yesterday = today.subtract(const Duration(days: 1));
  //
  //         matchesDate = activityDate.isAfter(yesterday.subtract(const Duration(seconds: 1))) &&
  //             activityDate.isBefore(today);
  //
  //         print("Filter: Yesterday → $matchesDate");
  //       }
  //
  //       else if (selectedDateFilter == "Last 7 Days") {
  //         final sevenDaysAgo = today.subtract(const Duration(days: 7));
  //
  //         matchesDate = activityDate.isAfter(sevenDaysAgo.subtract(const Duration(seconds: 1)));
  //
  //         print("Filter: Last 7 Days → $matchesDate");
  //       }
  //
  //       else if (selectedDateFilter == "Last 30 Days") {
  //         final thirtyDaysAgo = today.subtract(const Duration(days: 30));
  //
  //         matchesDate = activityDate.isAfter(thirtyDaysAgo.subtract(const Duration(seconds: 1)));
  //
  //         print("Filter: Last 30 Days → $matchesDate");
  //       }
  //     }
  //
  //     print("FINAL matchesDate: $matchesDate");
  //
  //     final finalResult =
  //         matchesSearch &&
  //         matchesDate &&
  //         matchesFilterType;
  //
  //     if (!finalResult) {
  //       print("❌ Rejected: ${activity.customerName}");
  //     } else {
  //       print("✅ Included: ${activity.customerName}");
  //     }
  //
  //     return finalResult;
  //
  //   }).toList();
  //
  //   /// 🔽 Sorting
  //   if (sortField == 'customerName') {
  //     filtered.sort((a, b) {
  //       final cmp = a.customerName.toLowerCase().compareTo(b.customerName.toLowerCase());
  //       return sortOrder == 'asc' ? cmp : -cmp;
  //     });
  //   } else if (sortField == 'mobile') {
  //     filtered.sort((a, b) {
  //       final cmp = a.toData.toLowerCase().compareTo(b.toData.toLowerCase());
  //       return sortOrder == 'asc' ? cmp : -cmp;
  //     });
  //   } else if (sortField == 'type') {
  //     filtered.sort((a, b) {
  //       final cmp = a.callType.toLowerCase().compareTo(b.callType.toLowerCase());
  //       return sortOrder == 'asc' ? cmp : -cmp;
  //     });
  //   } else if (sortField == 'status') {
  //     filtered.sort((a, b) {
  //       final cmp = a.callStatus.toLowerCase().compareTo(b.callStatus.toLowerCase());
  //       return sortOrder == 'asc' ? cmp : -cmp;
  //     });
  //   } else if (sortField == 'message') {
  //     filtered.sort((a, b) {
  //       final cmp = a.message.toLowerCase().compareTo(b.message.toLowerCase());
  //       return sortOrder == 'asc' ? cmp : -cmp;
  //     });
  //   } else if (sortField == 'leadStatus') {
  //     filtered.sort((a, b) {
  //       final cmp = a.leadStatus.toLowerCase().compareTo(b.leadStatus.toLowerCase());
  //       return sortOrder == 'asc' ? cmp : -cmp;
  //     });
  //   } else if (sortField == 'addedBy') {
  //     filtered.sort((a, b) {
  //       final cmp = a.name.toLowerCase().compareTo(b.name.toLowerCase());
  //       return sortOrder == 'asc' ? cmp : -cmp;
  //     });
  //   } else if (sortField == 'company') {
  //     filtered.sort((a, b) {
  //       final cmp = a.companyName.toLowerCase().compareTo(b.companyName.toLowerCase());
  //       return sortOrder == 'asc' ? cmp : -cmp;
  //     });
  //   } else if (sortField == 'date') {
  //     filtered.sort((a, b) {
  //       final dateA = parseDate(a.sentDate);
  //       final dateB = parseDate(b.sentDate);
  //       final cmp = dateA.compareTo(dateB);
  //       return sortOrder == 'asc' ? cmp : -cmp;
  //     });
  //   }
  //
  //   callMailsFilterList.assignAll(filtered);
  //
  //   print("\n============================");
  //   print("FINAL COUNT: ${callMailsFilterList.length}");
  // }
  void dashboardCommunicationFilterList({
    required List<CustomerActivity> dataList,
    required String searchText,
    required String callType,
    required String sortField,
    required String sortOrder,
    required String selectedDateFilter,
    required DateTime? selectedMonth,
    required DateTimeRange? selectedRange,
  }) {
    print("dataList length: ${dataList.length}");

    DateTime parseDate(String dateStr) {
      final formats = [
        "dd.MM.yyyy h:mm a",
        "dd-MM-yyyy h.mm a",
        "dd-MM-yyyy h:mm a",
        "dd.MM.yyyy h.mm a",
      ];

      for (var format in formats) {
        try {
          return DateFormat(format).parseStrict(dateStr.trim());
        } catch (_) {}
      }

      print("❌ Date parse error: $dateStr");
      return DateTime(1900);
    }

    DateTime _startOfDay(DateTime date) {
      return DateTime(date.year, date.month, date.day);
    }

    DateTime _endOfDay(DateTime date) {
      return DateTime(date.year, date.month, date.day, 23, 59, 59);
    }

    final now = DateTime.now();

    // final filtered = dataList.where((activity) {
    //
    //   /// 👤 Mine / Team
    //   final matchesFilterType =
    //       filterCall.value == "All" ||
    //           (filterCall.value == "Mine" &&
    //               activity.name == controllers.storage.read("f_name")) ||
    //           (filterCall.value == "Team" &&
    //               activity.name != controllers.storage.read("f_name"));
    //
    //   /// 🔍 Search
    //   final matchesSearch =
    //       searchText.isEmpty ||
    //           activity.customerName.toLowerCase().contains(searchText.toLowerCase()) ||
    //           activity.sentDate.toLowerCase().contains(searchText.toLowerCase());
    //
    //   final activityDate = parseDate(activity.sentDate);
    //
    //   bool matchesDate = true;
    //
    //   /// 🔥 Priority: Range > Month > Quick
    //
    //   /// 📅 Custom Range
    //   if (selectedRange != null) {
    //     final start = _startOfDay(selectedRange.start);
    //     final end = _endOfDay(selectedRange.end);
    //
    //     matchesDate = !activityDate.isBefore(start) &&
    //         !activityDate.isAfter(end);
    //   }
    //
    //   /// 📅 Month
    //   else if (selectedMonth != null) {
    //     matchesDate = activityDate.year == selectedMonth.year &&
    //         activityDate.month == selectedMonth.month;
    //   }
    //
    //   /// ⚡ Quick Filters
    //   else {
    //     switch (selectedDateFilter) {
    //
    //       case "Today":
    //         matchesDate = activityDate.year == now.year &&
    //             activityDate.month == now.month &&
    //             activityDate.day == now.day;
    //         break;
    //
    //       case "Yesterday":
    //         final yesterday = now.subtract(const Duration(days: 1));
    //         matchesDate = activityDate.year == yesterday.year &&
    //             activityDate.month == yesterday.month &&
    //             activityDate.day == yesterday.day;
    //         break;
    //
    //       case "Last 7 Days": // 👉 future
    //         final start = _startOfDay(now);
    //         final end = _endOfDay(now.subtract(const Duration(days: 7)));
    //
    //         matchesDate = !activityDate.isBefore(start) &&
    //             !activityDate.isAfter(end);
    //         break;
    //
    //       case "Last 30 Days": // 👉 future
    //         final start = _startOfDay(now);
    //         final end = _endOfDay(now.subtract(const Duration(days: 30)));
    //
    //         matchesDate = !activityDate.isBefore(start) &&
    //             !activityDate.isAfter(end);
    //         break;
    //
    //       default:
    //         matchesDate = true;
    //     }
    //   }
    //
    //   return matchesSearch && matchesDate && matchesFilterType;
    //
    // }).toList();
    final filtered = dataList.where((activity) {

      /// 👤 Mine / Team
      final matchesFilterType =
          filterCall.value == "All" ||
              (filterCall.value == "Mine" &&
                  activity.name == controllers.storage.read("f_name")) ||
              (filterCall.value == "Team" &&
                  activity.name != controllers.storage.read("f_name"));

      /// 🔍 Search
      final matchesSearch =
          searchText.isEmpty ||
              (activity.customerName ?? "")
                  .toLowerCase()
                  .contains(searchText.toLowerCase()) ||
              (activity.sentDate ?? "")
                  .toLowerCase()
                  .contains(searchText.toLowerCase());

      /// 📅 Parse Date (SAFE)
      final activityDate = parseDate(activity.sentDate);

      bool matchesDate = true;

      /// 🔥 Priority: Range > Month > Quick

      /// 📅 Custom Range
      if (selectedRange != null) {
        final start = _startOfDay(selectedRange.start);
        final end = _endOfDay(selectedRange.end);

        matchesDate = !activityDate.isBefore(start) &&
            !activityDate.isAfter(end);
      }

      /// 📅 Month
      else if (selectedMonth != null) {
        matchesDate = activityDate.year == selectedMonth.year &&
            activityDate.month == selectedMonth.month;
      }

      /// ⚡ Quick Filters
      else {
        switch (selectedDateFilter) {

          case "Today":
            matchesDate = activityDate.year == now.year &&
                activityDate.month == now.month &&
                activityDate.day == now.day;
            break;

          case "Yesterday":
            final yesterday = now.subtract(const Duration(days: 1));
            matchesDate = activityDate.year == yesterday.year &&
                activityDate.month == yesterday.month &&
                activityDate.day == yesterday.day;
            break;

        /// ✅ FIXED
          case "Last 7 Days":
            final start = _startOfDay(now.subtract(const Duration(days: 7)));
            final end = _endOfDay(now);

            matchesDate = !activityDate.isBefore(start) &&
                !activityDate.isAfter(end);
            break;

        /// ✅ FIXED
          case "Last 30 Days":
            final start = _startOfDay(now.subtract(const Duration(days: 30)));
            final end = _endOfDay(now);

            matchesDate = !activityDate.isBefore(start) &&
                !activityDate.isAfter(end);
            break;

          default:
            matchesDate = true;
        }
      }

      return matchesSearch && matchesDate && matchesFilterType;

    }).toList();
    /// 🔽 Sorting
    filtered.sort((a, b) {
      dynamic aValue;
      dynamic bValue;

      switch (sortField) {
        case 'customerName':
          aValue = (a.customerName ?? '').toLowerCase();
          bValue = (b.customerName ?? '').toLowerCase();
          break;

        case 'mobile':
          aValue = (a.toData ?? '').toLowerCase();
          bValue = (b.toData ?? '').toLowerCase();
          break;

        case 'type':
          aValue = (a.callType ?? '').toLowerCase();
          bValue = (b.callType ?? '').toLowerCase();
          break;

        case 'status':
          aValue = (a.callStatus ?? '').toLowerCase();
          bValue = (b.callStatus ?? '').toLowerCase();
          break;

        case 'message':
          aValue = (a.message ?? '').toLowerCase();
          bValue = (b.message ?? '').toLowerCase();
          break;

        case 'leadStatus':
          aValue = (a.leadStatus ?? '').toLowerCase();
          bValue = (b.leadStatus ?? '').toLowerCase();
          break;

        case 'addedBy':
          aValue = (a.name ?? '').toLowerCase();
          bValue = (b.name ?? '').toLowerCase();
          break;

        case 'company':
          aValue = (a.companyName ?? '').toLowerCase();
          bValue = (b.companyName ?? '').toLowerCase();
          break;

        case 'date':
          aValue = parseDate(a.sentDate);
          bValue = parseDate(b.sentDate);
          break;

        default:
          aValue = '';
          bValue = '';
      }

      int result;
      if (aValue is String && bValue is String) {
        result = aValue.compareTo(bValue);
      } else if (aValue is DateTime && bValue is DateTime) {
        result = aValue.compareTo(bValue);
      } else {
        result = 0;
      }

      return sortOrder == 'asc' ? result : -result;
    });

    remController.callMailsDetailsList.assignAll(filtered);

    print("FINAL COUNT: ${remController.callMailsDetailsList.length}");
  }
  // void filterAndSortMeetings({
  //   required String searchText,
  //   required String callType,
  //   required String sortField,
  //   required String sortOrder,
  // }) {
  //   var filtered = [...controllers.meetingActivity];
  //
  //   final now = DateTime.now();
  //   if (selectedMeetSortBy.value.isNotEmpty) {
  //     filtered = filtered.where((activity) {
  //       final date = _parseMeetingDate(activity.dates ?? '');
  //       switch (selectedMeetSortBy.value) {
  //         case 'Today':
  //           return _isSameDay(date, now);
  //         case 'Yesterday':
  //           final yesterday = now.subtract(const Duration(days: 1));
  //           return _isSameDay(date, yesterday);
  //         case 'Last 7 Days':
  //           final last7 = now.subtract(const Duration(days: 7));
  //           return date.isAfter(last7);
  //         case 'Last 30 Days':
  //           final last30 = now.subtract(const Duration(days: 30));
  //           return date.isAfter(last30);
  //         case 'Custom Month':
  //           if (selectedMeetMonth.value != null) {
  //             final selected = selectedMeetMonth.value!;
  //             return date.year == selected.year && date.month == selected.month;
  //           }
  //           return true;
  //         case 'Custom Range':
  //           if (selectedMeetRange.value != null) {
  //             final range = selectedMeetRange.value!;
  //             return date.isAfter(range.start.subtract(const Duration(days: 1))) &&
  //                 date.isBefore(range.end.add(const Duration(days: 1)));
  //           }
  //           return true;
  //         default:
  //           return true;
  //       }
  //     }).toList();
  //   }
  //   filtered = filtered.where((activity) {
  //     final matchesCallType = controllers.selectMeetingType.value.isEmpty ||
  //         activity.status == controllers.selectMeetingType.value;
  //     final matchesFilterType =
  //         filterApp.value == "All" ||
  //             (filterApp.value == "Mine" &&
  //                 activity.employeeName.contains(controllers.storage.read("f_name"))) ||
  //             (filterApp.value == "Team" &&
  //                 !activity.employeeName.contains(controllers.storage.read("f_name")));
  //
  //     final matchesSearch = searchText.isEmpty ||
  //         (activity.comName.toLowerCase().contains(searchText)) ||
  //         (activity.employeeName.toLowerCase().contains(searchText)) ||
  //         (activity.title.toLowerCase().contains(searchText)) ||
  //         (activity.venue.toLowerCase().contains(searchText)) ||
  //         (activity.notes.toLowerCase().contains(searchText)) ||
  //         (activity.cusName.toLowerCase().contains(searchText));
  //
  //     return matchesCallType && matchesSearch && matchesFilterType;
  //   }).toList();
  //
  //   String field = controllers.sortFieldMeetingActivity.value;
  //   String order = controllers.sortOrderMeetingActivity.value;
  //
  //   int compareString(String a, String b) {
  //     final comparison = a.toLowerCase().compareTo(b.toLowerCase());
  //     return order == 'asc' ? comparison : -comparison;
  //   }
  //
  //   if (field == 'customerName') {
  //     filtered.sort((a, b) => compareString(a.cusName ?? '', b.cusName ?? ''));
  //   } else if (field == 'companyName') {
  //     filtered.sort((a, b) => compareString(a.comName ?? '', b.comName ?? ''));
  //   } else if (field == 'title') {
  //     filtered.sort((a, b) => compareString(a.title ?? '', b.title ?? ''));
  //   } else if (field == 'venue') {
  //     filtered.sort((a, b) => compareString(a.venue ?? '', b.venue ?? ''));
  //   } else if (field == 'notes') {
  //     filtered.sort((a, b) => compareString(a.notes ?? '', b.notes ?? ''));
  //   } else if (field == 'emp') {
  //     filtered.sort((a, b) => compareString(a.employeeName ?? '', b.employeeName ?? ''));
  //   }  else if (field == 'status') {
  //     filtered.sort((a, b) => compareString(a.status ?? '', b.status ?? ''));
  //   } else if (field == 'date') {
  //     filtered.sort((a, b) {
  //       final dateA = _parseMeetingDate(a.dates ?? '');
  //       final dateB = _parseMeetingDate(b.dates ?? '');
  //       final comparison = dateA.compareTo(dateB);
  //       return order == 'asc' ? comparison : -comparison;
  //     });
  //   }
  //   meetingFilteredList.assignAll(filtered);
  // }
  // void dashboardMeetings({
  //   required String searchText,
  //   required String callType,
  //   required String sortField,
  //   required String sortOrder,
  // }) {
  //   var filtered = [...controllers.meetingActivity];
  //
  //   final now = DateTime.now();
  //
  //   DateTime _startOfDay(DateTime date) {
  //     return DateTime(date.year, date.month, date.day);
  //   }
  //
  //   DateTime _endOfDay(DateTime date) {
  //     return DateTime(date.year, date.month, date.day, 23, 59, 59);
  //   }
  //
  //   if (selectedMeetSortBy.value.isNotEmpty) {
  //     filtered = filtered.where((activity) {
  //       final date = _parseMeetingDate(activity.dates ?? '');
  //
  //       switch (selectedMeetSortBy.value) {
  //         case 'Today':
  //           return _isSameDay(date, now);
  //
  //         case 'Yesterday':
  //           final yesterday = now.subtract(const Duration(days: 1));
  //           return _isSameDay(date, yesterday);
  //
  //         case 'Last 7 Days': // 👉 future 7 days
  //           final endDate = now.add(const Duration(days: 7));
  //           return !date.isBefore(_startOfDay(now)) &&
  //               !date.isAfter(_endOfDay(endDate));
  //
  //         case 'Last 30 Days': // 👉 future 30 days
  //           final endDate = now.add(const Duration(days: 30));
  //           return !date.isBefore(_startOfDay(now)) &&
  //               !date.isAfter(_endOfDay(endDate));
  //
  //         case 'Custom Month':
  //           if (selectedMeetMonth.value != null) {
  //             final selected = selectedMeetMonth.value!;
  //             return date.year == selected.year &&
  //                 date.month == selected.month;
  //           }
  //           return true;
  //
  //         case 'Custom Range':
  //           if (selectedMeetRange.value != null) {
  //             final range = selectedMeetRange.value!;
  //             return !date.isBefore(_startOfDay(range.start)) &&
  //                 !date.isAfter(_endOfDay(range.end));
  //           }
  //           return true;
  //
  //         default:
  //           return true;
  //       }
  //     }).toList();
  //   }
  //
  //   // 🔍 Search + Filter
  //   filtered = filtered.where((activity) {
  //     final matchesCallType = controllers.selectMeetingType.value.isEmpty ||
  //         activity.status == controllers.selectMeetingType.value;
  //
  //     final matchesFilterType =
  //         filterApp.value == "All" ||
  //             (filterApp.value == "Mine" &&
  //                 activity.employeeName.contains(
  //                     controllers.storage.read("f_name"))) ||
  //             (filterApp.value == "Team" &&
  //                 !activity.employeeName.contains(
  //                     controllers.storage.read("f_name")));
  //
  //     final matchesSearch = searchText.isEmpty ||
  //         (activity.comName.toLowerCase().contains(searchText)) ||
  //         (activity.employeeName.toLowerCase().contains(searchText)) ||
  //         (activity.title.toLowerCase().contains(searchText)) ||
  //         (activity.venue.toLowerCase().contains(searchText)) ||
  //         (activity.notes.toLowerCase().contains(searchText)) ||
  //         (activity.cusName.toLowerCase().contains(searchText));
  //
  //     return matchesCallType && matchesSearch && matchesFilterType;
  //   }).toList();
  //
  //   // 🔃 Sorting
  //   String field = controllers.sortFieldMeetingActivity.value;
  //   String order = controllers.sortOrderMeetingActivity.value;
  //
  //   int compareString(String a, String b) {
  //     final comparison = a.toLowerCase().compareTo(b.toLowerCase());
  //     return order == 'asc' ? comparison : -comparison;
  //   }
  //
  //   if (field == 'customerName') {
  //     filtered.sort((a, b) =>
  //         compareString(a.cusName ?? '', b.cusName ?? ''));
  //   } else if (field == 'companyName') {
  //     filtered.sort((a, b) =>
  //         compareString(a.comName ?? '', b.comName ?? ''));
  //   } else if (field == 'title') {
  //     filtered.sort((a, b) =>
  //         compareString(a.title ?? '', b.title ?? ''));
  //   } else if (field == 'venue') {
  //     filtered.sort((a, b) =>
  //         compareString(a.venue ?? '', b.venue ?? ''));
  //   } else if (field == 'notes') {
  //     filtered.sort((a, b) =>
  //         compareString(a.notes ?? '', b.notes ?? ''));
  //   } else if (field == 'emp') {
  //     filtered.sort((a, b) =>
  //         compareString(a.employeeName ?? '', b.employeeName ?? ''));
  //   } else if (field == 'status') {
  //     filtered.sort((a, b) =>
  //         compareString(a.status ?? '', b.status ?? ''));
  //   } else if (field == 'date') {
  //     filtered.sort((a, b) {
  //       final dateA = _parseMeetingDate(a.dates ?? '');
  //       final dateB = _parseMeetingDate(b.dates ?? '');
  //       final comparison = dateA.compareTo(dateB);
  //       return order == 'asc' ? comparison : -comparison;
  //     });
  //   }
  //
  //   meetingFilteredList.assignAll(filtered);
  // }
  List<DateTime> _parseMeetingDateRange(String input) {
    try {
      if (input.isEmpty) return [];

      // 👉 Split start & end
      final parts = input.split("||");

      DateTime parse(String date) {
        try {
          return DateFormat("dd.MM.yyyy").parse(date);
        } catch (e) {
          try {
            return DateFormat("dd-MM-yyyy").parse(date);
          } catch (e) {
            print("❌ Date parse error: $date");
            return DateTime(2000);
          }
        }
      }

      if (parts.length == 2) {
        return [parse(parts[0]), parse(parts[1])];
      } else {
        return [parse(parts[0])];
      }

    } catch (e) {
      print("❌ Range parse error: $input");
      return [];
    }
  }
  void dashboardMeetings({
    required String searchText,
    required String callType,
    required String sortField,
    required String sortOrder,
  }) {
    var filtered = [...controllers.meetingActivity];

    final now = DateTime.now();

    // ✅ Normalize date (remove time)
    DateTime normalize(DateTime d) {
      return DateTime(d.year, d.month, d.day);
    }

    // ✅ Safe Date Parsing
    DateTime _parseMeetingDate(String input) {
      print("input");
      print(input);
      try {
        // ✅ 24-hour format (your current data)
        return DateFormat("dd-MM-yyyy HH:mm").parse(input);
      } catch (e) {
        try {
          // ✅ fallback (if AM/PM data வந்தா)
          return DateFormat("dd-MM-yyyy hh:mm a").parse(input);
        } catch (e) {
          try {
            // ✅ another fallback (dot format)
            return DateFormat("dd-MM-yyyy hh.mm a").parse(input);
          } catch (e) {
            print("❌ Date parse error: $input");
            return DateTime(2000);
          }
        }
      }
    }
    // ✅ DATE FILTER
    if (selectedMeetSortBy.value.isNotEmpty) {
      filtered = filtered.where((activity) {

        final dates = _parseMeetingDateRange(activity.dates ?? '');
        final today = normalize(now);

        bool match = false;

        for (var rawDate in dates) {
          final date = normalize(rawDate);

          switch (selectedMeetSortBy.value) {

            case 'Today':
              if (date == today) match = true;
              break;

            case 'Yesterday':
              final yesterday = normalize(now.subtract(const Duration(days: 1)));
              if (date == yesterday) match = true;
              break;

          /// ✅ FUTURE 7 DAYS
            case 'Last 7 Days':
              final start = today;
              final end = normalize(now.add(const Duration(days: 7)));

              if (!date.isBefore(start) && !date.isAfter(end)) {
                match = true;
              }
              break;

          /// ✅ FUTURE 30 DAYS
            case 'Last 30 Days':
              final start = today;
              final end = normalize(now.add(const Duration(days: 30)));

              if (!date.isBefore(start) && !date.isAfter(end)) {
                match = true;
              }
              break;

            case 'Custom Month':
              if (selectedMeetMonth.value != null) {
                final selected = selectedMeetMonth.value!;
                if (date.year == selected.year &&
                    date.month == selected.month) {
                  match = true;
                }
              }
              break;

            case 'Custom Range':
              if (selectedMeetRange.value != null) {
                final range = selectedMeetRange.value!;
                final start = normalize(range.start);
                final end = normalize(range.end);

                if (!date.isBefore(start) && !date.isAfter(end)) {
                  match = true;
                }
              }
              break;

            default:
              match = true;
          }

          if (match) break; // ✅ stop early if matched
        }

        return match;

      }).toList();
    }
    // 🔍 SEARCH + FILTER
    filtered = filtered.where((activity) {
      final matchesCallType = controllers.selectMeetingType.value.isEmpty ||
          activity.status == controllers.selectMeetingType.value;

      final matchesFilterType =
          filterApp.value == "All" ||
              (filterApp.value == "Mine" &&
                  (activity.employeeName ?? '')
                      .toLowerCase()
                      .contains((controllers.storage.read("f_name") ?? '')
                      .toLowerCase())) ||
              (filterApp.value == "Team" &&
                  !(activity.employeeName ?? '')
                      .toLowerCase()
                      .contains((controllers.storage.read("f_name") ?? '')
                      .toLowerCase()));

      final search = searchText.toLowerCase();

      final matchesSearch = search.isEmpty ||
          (activity.comName ?? '').toLowerCase().contains(search) ||
          (activity.employeeName ?? '').toLowerCase().contains(search) ||
          (activity.title ?? '').toLowerCase().contains(search) ||
          (activity.venue ?? '').toLowerCase().contains(search) ||
          (activity.notes ?? '').toLowerCase().contains(search) ||
          (activity.cusName ?? '').toLowerCase().contains(search);

      return matchesCallType && matchesSearch && matchesFilterType;
    }).toList();

    // 🔃 SORTING
    String field = controllers.sortFieldMeetingActivity.value;
    String order = controllers.sortOrderMeetingActivity.value;

    int compareString(String a, String b) {
      final comparison = a.toLowerCase().compareTo(b.toLowerCase());
      return order == 'asc' ? comparison : -comparison;
    }

    if (field == 'customerName') {
      filtered.sort((a, b) =>
          compareString(a.cusName ?? '', b.cusName ?? ''));
    } else if (field == 'companyName') {
      filtered.sort((a, b) =>
          compareString(a.comName ?? '', b.comName ?? ''));
    } else if (field == 'title') {
      filtered.sort((a, b) =>
          compareString(a.title ?? '', b.title ?? ''));
    } else if (field == 'venue') {
      filtered.sort((a, b) =>
          compareString(a.venue ?? '', b.venue ?? ''));
    } else if (field == 'notes') {
      filtered.sort((a, b) =>
          compareString(a.notes ?? '', b.notes ?? ''));
    } else if (field == 'emp') {
      filtered.sort((a, b) =>
          compareString(a.employeeName ?? '', b.employeeName ?? ''));
    } else if (field == 'status') {
      filtered.sort((a, b) =>
          compareString(a.status ?? '', b.status ?? ''));
    } else if (field == 'date') {
      filtered.sort((a, b) {
        final dateA = normalize(_parseMeetingDate(a.dates ?? ''));
        final dateB = normalize(_parseMeetingDate(b.dates ?? ''));
        final comparison = dateA.compareTo(dateB);
        return order == 'asc' ? comparison : -comparison;
      });
    }

    meetingFilteredList.assignAll(filtered);
  }
  ///
  DateTime _parseMeetingDate(String dateStr) {
    try {
      final parts = dateStr.split('||');
      final mainPart = parts.first.trim();
      if (mainPart.contains(RegExp(r'[APMapm]'))) {
        return DateFormat("dd.MM.yyyy hh:mm a").parse(mainPart);
      } else {
        return DateFormat("dd.MM.yyyy").parse(mainPart);
      }
    } catch (e) {
      return DateTime(1900);
    }
  }

  var sortBy = ''.obs;
  var ascending = true.obs;
  void sortReminders() {
    var filteredList = [...reminderList];
    final dateFormatter = DateFormat("dd-MM-yyyy h:mm a");
    final now = DateTime.now();
    if (selectedReminderSortBy.value.isNotEmpty) {
      switch (selectedReminderSortBy.value) {
        case 'All':
          filteredList = [...reminderList];
          break;
        case 'Today':
          filteredList = filteredList.where((r) {
            // print("r.updatedTs ${r.updatedTs}");
            final date = _parseReminderDate(r.updatedTs, dateFormatter);
            return _isSameDay(date, now);
          }).toList();
          break;

        case 'Yesterday':
          final yesterday = now.subtract(const Duration(days: 1));
          filteredList = filteredList.where((r) {
            final date = _parseReminderDate(r.updatedTs, dateFormatter);
            return _isSameDay(date, yesterday);
          }).toList();
          break;

        case 'Last 7 Days':
          final last7 = now.subtract(const Duration(days: 7));
          filteredList = filteredList.where((r) {
            final date = _parseReminderDate(r.updatedTs, dateFormatter);
            return date.isAfter(last7);
          }).toList();
          break;

        case 'Last 30 Days':
          final last30 = now.subtract(const Duration(days: 30));
          filteredList = filteredList.where((r) {
            final date = _parseReminderDate(r.updatedTs, dateFormatter);
            return date.isAfter(last30);
          }).toList();
          break;

        case 'Custom Month':
          if (selectedReminderMonth.value != null) {
            final selected = selectedReminderMonth.value!;
            filteredList = filteredList.where((r) {
              final date = _parseReminderDate(r.startDt, dateFormatter);
              return date.year == selected.year && date.month == selected.month;
            }).toList();
          }
          break;

        case 'Custom Range':
          if (selectedReminderRange.value != null) {
            final range = selectedReminderRange.value!;
            filteredList = filteredList.where((r) {
              final date = _parseReminderDate(r.startDt, dateFormatter);
              return date.isAfter(range.start.subtract(const Duration(days: 1))) &&
                  date.isBefore(range.end.add(const Duration(days: 1)));
            }).toList();
          }
          break;
      }
    }
    filteredList = filteredList.where((a) {
      return filterReminder.value == "All" ||
          (filterReminder.value == "Follow" && a.type == "1") ||
          (filterReminder.value == "Appointment" && a.type == "2");
    }).toList();
    filteredList = filteredList.where((a) {
      String currentUser = controllers.storage.read("f_name") ?? "";

      return filterRem.value == "All" ||
          (filterRem.value == "Mine" &&
              (a.employeeName ?? "").toLowerCase().contains(currentUser.toLowerCase())) ||
          (filterRem.value == "Team" &&
              !(a.employeeName ?? "").toLowerCase().contains(currentUser.toLowerCase()));
    }).toList();

    filteredList.sort((a, b) {
      dynamic aValue;
      dynamic bValue;

      switch (sortFieldCallActivity.value) {
        case 'customerName':
          aValue = a.customerName.toLowerCase();
          bValue = b.customerName.toLowerCase();
          break;
        case 'employeeName':
          aValue = a.employeeName.toLowerCase();
          bValue = b.employeeName.toLowerCase();
          break;
        case 'details':
          aValue = a.details.toLowerCase();
          bValue = b.details.toLowerCase();
          break;
        case 'location':
          aValue = a.location.toLowerCase();
          bValue = b.location.toLowerCase();
          break;
        case 'type':
          aValue = a.type.toLowerCase();
          bValue = b.type.toLowerCase();
          break;
        case 'title':
          aValue = a.title.toLowerCase();
          bValue = b.title.toLowerCase();
          break;
        case 'startDate':
          aValue = _parseReminderDate(a.startDt, dateFormatter);
          bValue = _parseReminderDate(b.startDt, dateFormatter);
          break;
        case 'endDate':
          aValue = _parseReminderDate(a.endDt, dateFormatter);
          bValue = _parseReminderDate(b.endDt, dateFormatter);
          break;
        default:
          aValue = '';
          bValue = '';
      }

      int result;
      if (aValue is String && bValue is String) {
        result = aValue.compareTo(bValue);
      } else if (aValue is DateTime && bValue is DateTime) {
        result = aValue.compareTo(bValue);
      } else {
        result = 0;
      }

      return sortOrderCallActivity.value == 'asc' ? result : -result;
    });

    reminderFilteredList.assignAll(filteredList);
  }
  // void dashboardSortReminders() {
  //   var filteredList = [...reminderList];
  //   final dateFormatter = DateFormat("dd-MM-yyyy h:mm a");
  //   final now = DateTime.now();
  //   if (selectedReminderSortBy.value.isNotEmpty) {
  //     switch (selectedReminderSortBy.value) {
  //       case 'All':
  //         filteredList = [...reminderList];
  //         break;
  //       case 'Today':
  //         filteredList = filteredList.where((r) {
  //           print("r.updatedTs ${r.updatedTs}");
  //           final date = _parseReminderDate(r.updatedTs, dateFormatter);
  //           return _isSameDay(date, now);
  //         }).toList();
  //         break;
  //
  //       case 'Yesterday':
  //         final yesterday = now.subtract(const Duration(days: 1));
  //         filteredList = filteredList.where((r) {
  //           final date = _parseReminderDate(r.updatedTs, dateFormatter);
  //           return _isSameDay(date, yesterday);
  //         }).toList();
  //         break;
  //
  //     // case 'Last 7 Days':
  //     //   final last7 = now.subtract(const Duration(days: 7));
  //     //   filteredList = filteredList.where((r) {
  //     //     final date = _parseReminderDate(r.updatedTs, dateFormatter);
  //     //     return date.isAfter(last7);
  //     //   }).toList();
  //     //   break;
  //     //
  //     // case 'Last 30 Days':
  //     //   final last30 = now.subtract(const Duration(days: 30));
  //     //   filteredList = filteredList.where((r) {
  //     //     final date = _parseReminderDate(r.updatedTs, dateFormatter);
  //     //     return date.isAfter(last30);
  //     //   }).toList();
  //     //   break;
  //       case 'Last 7 Days':
  //         final start = DateTime(now.year, now.month, now.day); // today start
  //         final end = start.add(const Duration(days: 7));
  //
  //         filteredList = filteredList.where((r) {
  //           final date = _parseReminderDate(r.updatedTs, dateFormatter);
  //           return !date.isBefore(start) && !date.isAfter(end);
  //         }).toList();
  //         break;
  //
  //       case 'Last 30 Days':
  //         final start = DateTime(now.year, now.month, now.day);
  //         final end = start.add(const Duration(days: 30));
  //
  //         filteredList = filteredList.where((r) {
  //           final date = _parseReminderDate(r.updatedTs, dateFormatter);
  //           return !date.isBefore(start) && !date.isAfter(end);
  //         }).toList();
  //         break;
  //
  //       case 'Custom Month':
  //         if (selectedReminderMonth.value != null) {
  //           final selected = selectedReminderMonth.value!;
  //           filteredList = filteredList.where((r) {
  //             final date = _parseReminderDate(r.startDt, dateFormatter);
  //             return date.year == selected.year && date.month == selected.month;
  //           }).toList();
  //         }
  //         break;
  //
  //       case 'Custom Range':
  //         if (selectedReminderRange.value != null) {
  //           final range = selectedReminderRange.value!;
  //           filteredList = filteredList.where((r) {
  //             final date = _parseReminderDate(r.startDt, dateFormatter);
  //             return date.isAfter(range.start.subtract(const Duration(days: 1))) &&
  //                 date.isBefore(range.end.add(const Duration(days: 1)));
  //           }).toList();
  //         }
  //         break;
  //     }
  //   }
  //   filteredList = filteredList.where((a) {
  //     return filterReminder.value == "All" ||
  //         (filterReminder.value == "Follow" && a.type == "1") ||
  //         (filterReminder.value == "Appointment" && a.type == "2");
  //   }).toList();
  //   filteredList = filteredList.where((a) {
  //     String currentUser = controllers.storage.read("f_name") ?? "";
  //
  //     return filterRem.value == "All" ||
  //         (filterRem.value == "Mine" &&
  //             (a.employeeName ?? "").toLowerCase().contains(currentUser.toLowerCase())) ||
  //         (filterRem.value == "Team" &&
  //             !(a.employeeName ?? "").toLowerCase().contains(currentUser.toLowerCase()));
  //   }).toList();
  //
  //   filteredList.sort((a, b) {
  //     dynamic aValue;
  //     dynamic bValue;
  //
  //     switch (sortFieldCallActivity.value) {
  //       case 'customerName':
  //         aValue = a.customerName.toLowerCase();
  //         bValue = b.customerName.toLowerCase();
  //         break;
  //       case 'employeeName':
  //         aValue = a.employeeName.toLowerCase();
  //         bValue = b.employeeName.toLowerCase();
  //         break;
  //       case 'details':
  //         aValue = a.details.toLowerCase();
  //         bValue = b.details.toLowerCase();
  //         break;
  //       case 'location':
  //         aValue = a.location.toLowerCase();
  //         bValue = b.location.toLowerCase();
  //         break;
  //       case 'type':
  //         aValue = a.type.toLowerCase();
  //         bValue = b.type.toLowerCase();
  //         break;
  //       case 'title':
  //         aValue = a.title.toLowerCase();
  //         bValue = b.title.toLowerCase();
  //         break;
  //       case 'startDate':
  //         aValue = _parseReminderDate(a.startDt, dateFormatter);
  //         bValue = _parseReminderDate(b.startDt, dateFormatter);
  //         break;
  //       case 'endDate':
  //         aValue = _parseReminderDate(a.endDt, dateFormatter);
  //         bValue = _parseReminderDate(b.endDt, dateFormatter);
  //         break;
  //       default:
  //         aValue = '';
  //         bValue = '';
  //     }
  //
  //     int result;
  //     if (aValue is String && bValue is String) {
  //       result = aValue.compareTo(bValue);
  //     } else if (aValue is DateTime && bValue is DateTime) {
  //       result = aValue.compareTo(bValue);
  //     } else {
  //       result = 0;
  //     }
  //
  //     return sortOrderCallActivity.value == 'asc' ? result : -result;
  //   });
  //
  //   reminderFilteredList.assignAll(filteredList);
  // }
  void dashboardSortReminders() {
    print("reminderList.....length ${reminderList.length}");
    var filteredList = [...reminderList];
    final dateFormatter = DateFormat("dd-MM-yyyy h:mm a");
    final now = DateTime.now();

    DateTime _startOfDay(DateTime date) {
      return DateTime(date.year, date.month, date.day);
    }

    DateTime _endOfDay(DateTime date) {
      return DateTime(date.year, date.month, date.day, 23, 59, 59);
    }

    if (selectedReminderSortBy.value.isNotEmpty) {
      switch (selectedReminderSortBy.value) {

        case 'All':
          filteredList = [...reminderList];
          break;

        case 'Today':
          filteredList = filteredList.where((r) {
            final date = _parseReminderDate(r.updatedTs, dateFormatter);
            return _isSameDay(date, now);
          }).toList();
          break;

        case 'Yesterday':
          final yesterday = now.subtract(const Duration(days: 1));
          filteredList = filteredList.where((r) {
            final date = _parseReminderDate(r.updatedTs, dateFormatter);
            return _isSameDay(date, yesterday);
          }).toList();
          break;

        case 'Last 7 Days': // 👉 future 7 days
          final start = _startOfDay(now);
          final end = _endOfDay(now.add(const Duration(days: 7)));

          filteredList = filteredList.where((r) {
            final date = _parseReminderDate(r.updatedTs, dateFormatter);
            return !date.isBefore(start) && !date.isAfter(end);
          }).toList();
          break;

        case 'Last 30 Days': // 👉 future 30 days
          final start = _startOfDay(now);
          final end = _endOfDay(now.add(const Duration(days: 30)));

          filteredList = filteredList.where((r) {
            final date = _parseReminderDate(r.updatedTs, dateFormatter);
            return !date.isBefore(start) && !date.isAfter(end);
          }).toList();
          break;

        case 'Custom Month':
          if (selectedReminderMonth.value != null) {
            final selected = selectedReminderMonth.value!;
            filteredList = filteredList.where((r) {
              final date = _parseReminderDate(r.startDt, dateFormatter);
              return date.year == selected.year &&
                  date.month == selected.month;
            }).toList();
          }
          break;

        case 'Custom Range':
          if (selectedReminderRange.value != null) {
            final range = selectedReminderRange.value!;

            filteredList = filteredList.where((r) {
              final date = _parseReminderDate(r.startDt, dateFormatter);
              return !date.isBefore(_startOfDay(range.start)) &&
                  !date.isAfter(_endOfDay(range.end));
            }).toList();
          }
          break;
      }
    }

    // 🔍 Type Filter
    filteredList = filteredList.where((a) {
      return filterReminder.value == "All" ||
          (filterReminder.value == "Follow" && a.type == "1") ||
          (filterReminder.value == "Appointment" && a.type == "2");
    }).toList();

    // 👤 Mine / Team Filter
    filteredList = filteredList.where((a) {
      String currentUser = controllers.storage.read("f_name") ?? "";

      return filterRem.value == "All" ||
          (filterRem.value == "Mine" &&
              (a.employeeName ?? "")
                  .toLowerCase()
                  .contains(currentUser.toLowerCase())) ||
          (filterRem.value == "Team" &&
              !(a.employeeName ?? "")
                  .toLowerCase()
                  .contains(currentUser.toLowerCase()));
    }).toList();

    // 🔃 Sorting
    filteredList.sort((a, b) {
      dynamic aValue;
      dynamic bValue;

      switch (sortFieldCallActivity.value) {
        case 'customerName':
          aValue = (a.customerName ?? '').toLowerCase();
          bValue = (b.customerName ?? '').toLowerCase();
          break;

        case 'employeeName':
          aValue = (a.employeeName ?? '').toLowerCase();
          bValue = (b.employeeName ?? '').toLowerCase();
          break;

        case 'details':
          aValue = (a.details ?? '').toLowerCase();
          bValue = (b.details ?? '').toLowerCase();
          break;

        case 'location':
          aValue = (a.location ?? '').toLowerCase();
          bValue = (b.location ?? '').toLowerCase();
          break;

        case 'type':
          aValue = (a.type ?? '').toLowerCase();
          bValue = (b.type ?? '').toLowerCase();
          break;

        case 'title':
          aValue = (a.title ?? '').toLowerCase();
          bValue = (b.title ?? '').toLowerCase();
          break;

        case 'startDate':
          aValue = _parseReminderDate(a.startDt, dateFormatter);
          bValue = _parseReminderDate(b.startDt, dateFormatter);
          break;

        case 'endDate':
          aValue = _parseReminderDate(a.endDt, dateFormatter);
          bValue = _parseReminderDate(b.endDt, dateFormatter);
          break;

        default:
          aValue = '';
          bValue = '';
      }

      int result;
      if (aValue is String && bValue is String) {
        result = aValue.compareTo(bValue);
      } else if (aValue is DateTime && bValue is DateTime) {
        result = aValue.compareTo(bValue);
      } else {
        result = 0;
      }

      return sortOrderCallActivity.value == 'asc' ? result : -result;
    });

    reminderFilteredList.assignAll(filteredList);
  }

  // DateTime _parseReminderDate(String dateStr, DateFormat fallbackFormatter) {
  //   try {
  //     print("dateStr");
  //     print(dateStr);
  //     final cleaned = dateStr.trim().replaceAll(RegExp(r'[^0-9:\-\sT]'), '');
  //     // Try direct parse first (handles yyyy-MM-dd HH:mm:ss and ISO)
  //     final parsed = DateTime.tryParse(cleaned);
  //     if (parsed != null) {
  //       return parsed;
  //     }
  //     final parsed2 = fallbackFormatter.parse(cleaned);
  //     return parsed2;
  //   } catch (e) {
  //     return DateTime(1900);
  //   }
  // }
  DateTime _parseReminderDate(String dateStr, DateFormat fallbackFormatter) {
    try {

      final cleaned = dateStr.trim();

      // 1️⃣ Try direct parse (ISO formats)
      final parsed = DateTime.tryParse(cleaned);
      if (parsed != null) {
        return parsed;
      }

      // 2️⃣ Try fallback formatter
      try {
        return fallbackFormatter.parse(cleaned);
      } catch (_) {}

      // 3️⃣ Try common formats
      final formats = [
        DateFormat("dd.MM.yyyy h:mm a"),
        DateFormat("dd.MM.yyyy hh:mm a"),
        DateFormat("dd-MM-yyyy h:mm a"),
        DateFormat("dd-MM-yyyy hh:mm a"),
        DateFormat("yyyy-MM-dd HH:mm:ss"),
        DateFormat("yyyy-MM-dd HH:mm"),
      ];

      for (var f in formats) {
        try {
          return f.parse(cleaned);
        } catch (_) {}
      }

      // 4️⃣ Last fallback
      return DateTime(1900);
    } catch (e) {
      print("Date parse error: $e");
      return DateTime(1900);
    }
  }


  // void sortMails() {
  //   var filteredList = [...controllers.mailActivity];
  //   final dateFormatter = DateFormat("dd-MM-yyyy h:mm a");
  //   final now = DateTime.now();
  //   if (selectedMailSortBy.value.isNotEmpty) {
  //     switch (selectedMailSortBy.value) {
  //       case 'Today':
  //         filteredList = filteredList.where((mail) {
  //           final date = _parseMailDate(mail.sentDate, dateFormatter);
  //           return _isSameDay(date, now);
  //         }).toList();
  //         break;
  //
  //       case 'Yesterday':
  //         final yesterday = now.subtract(const Duration(days: 1));
  //         filteredList = filteredList.where((mail) {
  //           final date = _parseMailDate(mail.sentDate, dateFormatter);
  //           return _isSameDay(date, yesterday);
  //         }).toList();
  //         break;
  //
  //       case 'Last 7 Days':
  //         final last7 = now.subtract(const Duration(days: 7));
  //         filteredList = filteredList.where((mail) {
  //           final date = _parseMailDate(mail.sentDate, dateFormatter);
  //           return date.isAfter(last7);
  //         }).toList();
  //         break;
  //
  //       case 'Last 30 Days':
  //         final last30 = now.subtract(const Duration(days: 30));
  //         filteredList = filteredList.where((mail) {
  //           final date = _parseMailDate(mail.sentDate, dateFormatter);
  //           return date.isAfter(last30);
  //         }).toList();
  //         break;
  //
  //       case 'Custom Month':
  //         if (selectedMailMonth.value != null) {
  //           final selected = selectedMailMonth.value!;
  //           filteredList = filteredList.where((mail) {
  //             final date = _parseMailDate(mail.sentDate, dateFormatter);
  //             return date.year == selected.year && date.month == selected.month;
  //           }).toList();
  //         }
  //         break;
  //       case 'Custom Range':
  //         if (selectedMailRange.value != null) {
  //           final range = selectedMailRange.value!;
  //           filteredList = filteredList.where((mail) {
  //             final date = _parseMailDate(mail.sentDate, dateFormatter);
  //             return date.isAfter(range.start.subtract(const Duration(days: 1))) &&
  //                 date.isBefore(range.end.add(const Duration(days: 1)));
  //           }).toList();
  //         }
  //         break;
  //     }
  //   }
  //   filteredList.sort((a, b) {
  //     dynamic aValue;
  //     dynamic bValue;
  //     switch (sortFieldCallActivity.value) {
  //       case 'customerName':
  //         aValue = (a.customerName ?? '').toLowerCase();
  //         bValue = (b.customerName ?? '').toLowerCase();
  //         break;
  //       case 'mail':
  //         aValue = (a.toData ?? '').toLowerCase();
  //         bValue = (b.toData ?? '').toLowerCase();
  //         break;
  //       case 'subject':
  //         aValue = (a.subject ?? '').toLowerCase();
  //         bValue = (b.subject ?? '').toLowerCase();
  //         break;
  //       case 'msg':
  //         aValue = (a.message ?? '').toLowerCase();
  //         bValue = (b.message ?? '').toLowerCase();
  //         break;
  //       case 'date':
  //         aValue = _parseMailDate(a.sentDate, dateFormatter);
  //         bValue = _parseMailDate(b.sentDate, dateFormatter);
  //         break;
  //       default:
  //         aValue = '';
  //         bValue = '';
  //     }
  //     int result;
  //     if (aValue is String && bValue is String) {
  //       result = aValue.compareTo(bValue);
  //     } else if (aValue is DateTime && bValue is DateTime) {
  //       result = aValue.compareTo(bValue);
  //     } else {
  //       result = 0;
  //     }
  //     return sortOrderCallActivity.value == 'asc' ? result : -result;
  //   });
  //   mailFilteredList.assignAll(filteredList);
  //   print("selectedMailMonth.value");
  //   print(selectedMailMonth.value);
  // }
  ///
  // void sortMails() {
  //
  //   var filteredList = [...controllers.mailActivity];
  //
  //   final dateFormatter = DateFormat("dd-MM-yyyy HH:mm"); // FIXED
  //
  //   final now = DateTime.now();
  //
  //   if (selectedMailSortBy.value.isNotEmpty) {
  //
  //     switch (selectedMailSortBy.value) {
  //
  //       case 'Today':
  //         filteredList = filteredList.where((mail) {
  //           final date = _parseMailDate(mail.sentDate, dateFormatter);
  //           return _isSameDay(date, now);
  //         }).toList();
  //         break;
  //
  //       case 'Yesterday':
  //         final yesterday = now.subtract(const Duration(days: 1));
  //         filteredList = filteredList.where((mail) {
  //           final date = _parseMailDate(mail.sentDate, dateFormatter);
  //           return _isSameDay(date, yesterday);
  //         }).toList();
  //         break;
  //
  //       case 'Last 7 Days':
  //         final last7 = now.subtract(const Duration(days: 7));
  //         filteredList = filteredList.where((mail) {
  //           final date = _parseMailDate(mail.sentDate, dateFormatter);
  //           return date.isAfter(last7);
  //         }).toList();
  //         break;
  //
  //       case 'Last 30 Days':
  //         final last30 = now.subtract(const Duration(days: 30));
  //         filteredList = filteredList.where((mail) {
  //           final date = _parseMailDate(mail.sentDate, dateFormatter);
  //           return date.isAfter(last30);
  //         }).toList();
  //         break;
  //
  //       case 'Custom Month':
  //
  //         if (selectedMailMonth.value != null) {
  //
  //           final selected = selectedMailMonth.value!;
  //
  //           filteredList = filteredList.where((mail) {
  //
  //             final date = _parseMailDate(mail.sentDate, dateFormatter);
  //
  //             return date.year == selected.year &&
  //                 date.month == selected.month;
  //
  //           }).toList();
  //
  //         }
  //
  //         break;
  //
  //       case 'Custom Range':
  //
  //         if (selectedMailRange.value != null) {
  //
  //           final range = selectedMailRange.value!;
  //
  //           filteredList = filteredList.where((mail) {
  //
  //             final date = _parseMailDate(mail.sentDate, dateFormatter);
  //
  //             return date.isAfter(range.start.subtract(const Duration(days: 1))) &&
  //                 date.isBefore(range.end.add(const Duration(days: 1)));
  //
  //           }).toList();
  //
  //         }
  //
  //         break;
  //     }
  //   }
  //
  //   filteredList.sort((a, b) {
  //
  //     dynamic aValue;
  //     dynamic bValue;
  //
  //     switch (sortFieldCallActivity.value) {
  //
  //       case 'customerName':
  //         aValue = (a.customerName ?? '').toLowerCase();
  //         bValue = (b.customerName ?? '').toLowerCase();
  //         break;
  //
  //       case 'mail':
  //         aValue = (a.toData ?? '').toLowerCase();
  //         bValue = (b.toData ?? '').toLowerCase();
  //         break;
  //
  //       case 'subject':
  //         aValue = (a.subject ?? '').toLowerCase();
  //         bValue = (b.subject ?? '').toLowerCase();
  //         break;
  //
  //       case 'msg':
  //         aValue = (a.message ?? '').toLowerCase();
  //         bValue = (b.message ?? '').toLowerCase();
  //         break;
  //
  //       case 'date':
  //         aValue = _parseMailDate(a.sentDate, dateFormatter);
  //         bValue = _parseMailDate(b.sentDate, dateFormatter);
  //         break;
  //
  //       default:
  //         aValue = '';
  //         bValue = '';
  //     }
  //
  //     int result;
  //
  //     if (aValue is String && bValue is String) {
  //       result = aValue.compareTo(bValue);
  //     }
  //     else if (aValue is DateTime && bValue is DateTime) {
  //       result = aValue.compareTo(bValue);
  //     }
  //     else {
  //       result = 0;
  //     }
  //
  //     return sortOrderCallActivity.value == 'asc' ? result : -result;
  //
  //   });
  //
  //   mailFilteredList.assignAll(filteredList);
  //
  // }
  void sortMails() {
    mailFilteredList.clear();
    var filteredList = [...controllers.mailActivity];

    final dateFormatter = DateFormat("dd-MM-yyyy hh:mm a");

    final now = DateTime.now();

    if (selectedMailSortBy.value.isNotEmpty) {

      switch (selectedMailSortBy.value) {

        case 'Today':
          filteredList = filteredList.where((mail) {
            final date = _parseMailDate(mail.sentDate, dateFormatter);
            return _isSameDay(date, now);
          }).toList();
          break;

        case 'Yesterday':
          final yesterday = now.subtract(const Duration(days: 1));
          filteredList = filteredList.where((mail) {
            final date = _parseMailDate(mail.sentDate, dateFormatter);
            return _isSameDay(date, yesterday);
          }).toList();
          break;

        case 'Last 7 Days':
          final last7 = now.subtract(const Duration(days: 7));
          filteredList = filteredList.where((mail) {
            final date = _parseMailDate(mail.sentDate, dateFormatter);
            return date.isAfter(last7);
          }).toList();
          break;

        case 'Last 30 Days':
          final last30 = now.subtract(const Duration(days: 30));
          filteredList = filteredList.where((mail) {
            final date = _parseMailDate(mail.sentDate, dateFormatter);
            return date.isAfter(last30);
          }).toList();
          break;

        case 'Custom Month':
          if (selectedMailMonth.value != null) {
            final selected = selectedMailMonth.value!;

            filteredList = filteredList.where((mail) {
              final date = _parseMailDate(mail.sentDate, dateFormatter);
              return date.year == selected.year &&
                  date.month == selected.month;
            }).toList();
          }
          break;

        case 'Custom Range':
          if (selectedMailRange.value != null) {

            final range = selectedMailRange.value!;

            filteredList = filteredList.where((mail) {

              final date = _parseMailDate(mail.sentDate, dateFormatter);

              return date.isAfter(range.start.subtract(const Duration(days: 1))) &&
                  date.isBefore(range.end.add(const Duration(days: 1)));

            }).toList();
          }
          break;
      }
    }

    filteredList.sort((a, b) {

      dynamic aValue;
      dynamic bValue;

      switch (sortFieldCallActivity.value) {

        case 'name':
          aValue = (a.customerName ?? '').toLowerCase();
          bValue = (b.customerName ?? '').toLowerCase();
          break;

        case 'company':
          aValue = (a.companyName ?? '').toLowerCase();
          bValue = (b.companyName ?? '').toLowerCase();
          break;

        case 'mail':
          aValue = (a.toData ?? '').toLowerCase();
          bValue = (b.toData ?? '').toLowerCase();
          break;

        case 'subject':
          aValue = (a.subject ?? '').toLowerCase();
          bValue = (b.subject ?? '').toLowerCase();
          break;

        case 'msg':
          aValue = (a.message ?? '').toLowerCase();
          bValue = (b.message ?? '').toLowerCase();
          break;

        case 'date':
          aValue = _parseMailDate(a.sentDate, dateFormatter);
          bValue = _parseMailDate(b.sentDate, dateFormatter);
          break;

        default:
          aValue = '';
          bValue = '';
      }

      int result;

      if (aValue is String && bValue is String) {
        result = aValue.compareTo(bValue);
      }
      else if (aValue is DateTime && bValue is DateTime) {
        result = aValue.compareTo(bValue);
      }
      else {
        result = 0;
      }

      return sortOrderCallActivity.value == 'asc' ? result : -result;

    });

    mailFilteredList.assignAll(filteredList);

 // debugPrint("remController.selectedMailSortBy.value ${remController.selectedMailSortBy.value}");
 // debugPrint("controllers.mailActivity ${controllers.mailActivity}");
 // debugPrint("mailFilteredList ${mailFilteredList.length}");
  }

  DateTime _parseMailDate(String? date, DateFormat formatter) {
    try {
      return formatter.parse(date ?? '');
    } catch (e) {
      // log("Date parse failed for: $date -> $e");
      return DateTime(2000);
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }
  // DateTime _parseMailDate(String? dateStr, DateFormat formatter) {
  //   if (dateStr == null || dateStr.trim().isEmpty) return DateTime(1900);
  //   try {
  //     final clean = dateStr.trim().replaceAll(RegExp(r'\s+'), ' ').toUpperCase();
  //     return formatter.parseStrict(clean);
  //   } catch (e) {
  //     print("Date parse failed for: $dateStr -> $e");
  //     return DateTime(1900);
  //   }
  // }
  //
  // bool _isSameDay(DateTime a, DateTime b) {
  //   return a.year == b.year && a.month == b.month && a.day == b.day;
  // }



  bool isCheckedReminder(String id) {
    return selectedReminderIds.contains(id);
  }
  void toggleReminderSelection(String id) {
    if (selectedReminderIds.contains(id)) {
      selectedReminderIds.remove(id);
    } else {
      selectedReminderIds.add(id);
    }
  }
  void toggleSelectAllReminder() {
    bool allSelected = reminderFilteredList.every((office) => selectedReminderIds.contains(office.id));
    if (allSelected) {
      selectedReminderIds.clear();
    } else {
      selectedReminderIds.assignAll(reminderFilteredList.map((office) => office.id));
    }
  }

  bool isCheckedMeeting(String id) {
    return selectedMeetingIds.contains(id);
  }
  void selectAllCalls() {
    selectedRecordCallIds.assignAll(callFilteredList.map((e) => e.id.toString()).toList());
  }
  void selectAllAppointments() {
    print("selectedMeetingIds....${selectedMeetingIds}");
    selectedMeetingIds.assignAll(meetingFilteredList.map((e) => e.id.toString()).toList());
    print("selectedMeetingIds....${selectedMeetingIds}");
  }
void unSelectAllAppointments() {
    selectedMeetingIds.clear();
  }

  void unselectAllCalls() {
    selectedRecordCallIds.clear();
  }
  void toggleMeetingSelection(String id) {
    if (selectedMeetingIds.contains(id)) {
      selectedMeetingIds.remove(id);
    } else {
      selectedMeetingIds.add(id);
    }
  }

  bool isCheckedRecordCall(String id) {
    return selectedRecordCallIds.contains(id);
  }
  void toggleRecordSelectionCall(String id) {
    if (selectedRecordCallIds.contains(id)) {
      selectedRecordCallIds.remove(id);
    } else {
      selectedRecordCallIds.add(id);
    }
  }

  bool isCheckedRecordMAil(String id) {
    return selectedRecordMailIds.contains(id);
  }
  void toggleRecordSelectionMail(String id) {
    if (selectedRecordMailIds.contains(id)) {
      selectedRecordMailIds.remove(id);
    } else {
      selectedRecordMailIds.add(id);
    }
  }
  var isLoadingReminders = false.obs;
  var followUpReminderCount = 0.obs;
  var meetingReminderCount = 0.obs;
  var defaultMonth=DateTime.now().month.obs;
  var thisMonthLeave = "0".obs;
  var filterReminder = "All".obs;

  Future<void> allReminders(String type) async {
    isLoadingReminders.value = true;
    thisMonthLeave.value = "0";

    dataSource.dispose();
    dataSource.appointments?.clear();

    final url = Uri.parse(scriptApi);

    try {
      final response = await http.post(
        url,
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "action": "get_data",
          "type": type,
          "cos_id": controllers.storage.read("cos_id"),
          "search_type": "allReminders"
        }),
      );
      print("allReminders");
      print(response.body);
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return allReminders(type);
        } else {
          controllers.setLogOut();
        }
      }
      if (response.statusCode == 200) {

        final data = jsonDecode(response.body);

        if (data is List) {

          reminderList.value =
              data.map((e) => ReminderModel.fromJson(e)).toList();

          // ---------- COUNTS ----------
          followUpReminderCount.value =
              reminderList.where((r) => r.type.toString() == '1').length;

          meetingReminderCount.value =
              reminderList.where((r) => r.type.toString() == '2').length;

          int monthCount = 0;

          // ---------- LOOP ----------
          for (var i = 0; i < reminderList.length; i++) {

            String dateStr = reminderList[i].startDt ?? '';

            // Skip empty dates
            if (dateStr.trim().isEmpty) {
              print("Empty date skipped");
              continue;
            }

            DateTime? parsedDate;

            // ---------- SAFE DATE PARSE ----------
            try {
              // Format: 03.02.2026 11:00 AM
              parsedDate = DateFormat('dd.MM.yyyy hh:mm a').parse(dateStr);
            } catch (e) {
              try {
                // Format: 26-10-2025 09:50 PM
                parsedDate = DateFormat('dd-MM-yyyy hh:mm a').parse(dateStr);
              } catch (e) {
                print("Date parse failed => $dateStr");
                continue;
              }
            }

            DateTime dateOnly = DateTime(
              parsedDate.year,
              parsedDate.month,
              parsedDate.day,
            );

            // ---------- CALENDAR APPOINTMENT ----------
            Appointment app = Appointment(
              startTime: dateOnly,
              endTime: dateOnly,
              subject: reminderList[i].title ?? '',
              color: Colors.redAccent,
            );

            dataSource.appointments!.add(app);
            dataSource.notifyListeners(
                CalendarDataSourceAction.add, <Appointment>[app]);

            // ---------- MONTH COUNT ----------
            if (defaultMonth.value.toString().padLeft(2, "0") ==
                parsedDate.month.toString().padLeft(2, "0")) {
              monthCount++;
            }
          }

          thisMonthLeave.value = monthCount.toString();

        } else {
          reminderList.value = [];
          followUpReminderCount.value = 0;
          meetingReminderCount.value = 0;
        }
        remController.dashboardSortReminders();
      } else {
        reminderList.value = [];
        followUpReminderCount.value = 0;
        meetingReminderCount.value = 0;
        print("Failed API Response: ${response.body}");
      }

    } catch (e) {
      reminderList.value = [];
      followUpReminderCount.value = 0;
      meetingReminderCount.value = 0;
      print("Reminder API Error: $e");
    } finally {
      isLoadingReminders.value = false;
    }
  }

  Future insertReminderAPI(BuildContext context,String type) async {
    try{
      Map data = {
        "action": "insert_reminder",
        "title": titleController.text.trim(),
        "type": type,
        "location": location,
        "repeat_type": repeat,
        "employee": controllers.selectedEmployeeId.value,
        "customer": controllers.selectedCustomerId.value,
        "start_dt": "${stDate.value} ${stTime.value}",
        "end_dt": "${enDate.value} ${enTime.value}",
        "details": detailsController.text.trim(),
        "set_time": defaultTime,
        "set_type": "Email",
        "repeat_on": repeatOn,
        "repeat_wise": repeatWise,
        "repeat_every": repeatEvery,
        "created_by": controllers.storage.read("id"),
        "cos_id": controllers.storage.read("cos_id"),
        "reminders": reminders.map((reminder) {
          return {
            "remind_via": reminder.remindVia.entries
                .where((entry) => entry.value.value)
                .map((entry) => entry.key)
                .toList(),
            "before_ts": reminder.selectedTime.value == "Other"
                ? reminder.customTime.value
                : reminder.selectedTime.value,
            "title": reminder.titleController.text.trim(),
          };
        }).toList(),
      };
      print("Reminder billing_data $data");
      final request = await http.post(Uri.parse(scriptApi),
          // headers: {
          //   "Accept": "application/text",
          //   "Content-Type": "application/x-www-form-urlencoded"
          // },
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8")
      );
      print("request ${request.body}");
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return insertReminderAPI(context,type);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200 && response["message"]=="Reminder added successfully"){
        titleController.clear();
        location=null;
        repeat=null;
        controllers.clearSelectedEmployee();
        controllers.clearSelectedCustomer();
        startController.clear();
        endController.clear();
        detailsController.clear();
        reminders.clear();
        reminders.add(AddReminderModel());
        stDate.value="";
        stTime.value="";
        enDate.value="";
        enTime.value="";
        repeatOn=null;
        final provider = Provider.of<ReminderProvider>(context, listen: false);
        provider.selectedNotification = "followup";
        apiService.getAllCallActivity("");
        allReminders(type);
        Navigator.pop(context);
        utils.snackBar(context: context, msg: "Reminder added successfully", color: Colors.green);
        controllers.productCtr.reset();
      } else {
        apiService.errorDialog(Get.context!,request.body);
        controllers.productCtr.reset();
      }
    }catch(e){
      apiService.errorDialog(Get.context!,e.toString());
      controllers.productCtr.reset();
    }
  }

  Future updateReminderAPI(BuildContext context,String type,String id) async {
    try{
      Map data = {
        "action": "update_reminder",
        "id": id,
        "title": updateTitleController.text.trim(),
        "type": type,
        "location": updateLocation,
        "repeat_type": updateRepeat,
        "employee": controllers.selectedEmployeeId.value,
        "customer": controllers.selectedCustomerId.value,
        "start_dt": updateStartController.text.trim(),
        "end_dt": updateEndController.text.trim(),
        "details": updateDetailsController.text.trim(),
        "updated_by": controllers.storage.read("id"),
        "cos_id": controllers.storage.read("cos_id")
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8")
      );
      print("request ${request.body}");
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return updateReminderAPI(context,type,id);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200 && response["message"]=="Reminder updated successfully"){
        allReminders(type);
        Navigator.pop(context);
        utils.snackBar(context: context, msg: "Reminder updated successfully", color: Colors.green);
        controllers.productCtr.reset();
      } else {
        apiService.errorDialog(Get.context!,request.body);
        controllers.productCtr.reset();
      }
    }catch(e){
      apiService.errorDialog(Get.context!,e.toString());
      controllers.productCtr.reset();
    }
  }

  Future insertSettingsReminderAPI(BuildContext context,String time) async {
    try{
      Map data = {
        "action": "insert_settings_reminder",
        "type": "Email",
        "time": time,
        "created_by": controllers.storage.read("id"),
        "cos_id": controllers.storage.read("cos_id")
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8")
      );
      print("request ${request.body}");
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return insertSettingsReminderAPI(context,time);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200 && response["message"]=="Settings added successfully"){
        Navigator.pop(context);
        utils.snackBar(context: context, msg: "Settings added successfully", color: Colors.green);
        controllers.productCtr.reset();
      } else {
        apiService.errorDialog(Get.context!,request.body);
        controllers.productCtr.reset();
      }
    }catch(e){
      apiService.errorDialog(Get.context!,e.toString());
      controllers.productCtr.reset();
    }
  }

  Future deleteReminderAPI(BuildContext context) async {
    try{
      Map data = {
        "action": "delete_reminder",
        "user_id": controllers.storage.read("id"),
        "cos_id": controllers.storage.read("cos_id"),
        "empList": selectedReminderIds,
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8")
      );
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return deleteReminderAPI(context);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200 && response["message"]=="OK"){
        allReminders("type");
        Navigator.pop(context);
        utils.snackBar(context: context, msg: "Reminder deleted successfully.", color: Colors.green);
        controllers.productCtr.reset();
        selectedReminderIds.clear();
      } else {
        apiService.errorDialog(Get.context!,request.body);
        controllers.productCtr.reset();
      }
    }catch(e){
      apiService.errorDialog(Get.context!,e.toString());
      controllers.productCtr.reset();
    }
  }

  Future<void> deleteMeetingAPI(BuildContext context) async {
    try {
      Map<String, dynamic> data = {
        "user_id": controllers.storage.read("id"),
        "cos_id": controllers.storage.read("cos_id"),
        "meetingList": selectedMeetingIds,
        "action": "delete_meeting",
      };
      print("Request: ${jsonEncode(data)}");
      final response = await http.post(
        Uri.parse(scriptApi), // your endpoint for delete_meeting.php
        // headers: {
        //   "Accept": "application/json",
        //   "Content-Type": "application/json",
        // },
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      Map<String, dynamic> result = json.decode(response.body);
      print("Response: ${response.body}");
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return deleteMeetingAPI(context);
        } else {
          controllers.setLogOut();
        }
      }
      if (response.statusCode == 200 && result["message"] == "OK") {
        apiService.getAllMeetingActivity("");
        Navigator.pop(context);
        utils.snackBar(
          context: context,
          msg: "Meeting deleted successfully.",
          color: Colors.green,
        );
        controllers.productCtr.reset();
        selectedMeetingIds.clear();
      } else {
        apiService.errorDialog(Get.context!, result["message"] ?? "Failed to delete meeting.");
        controllers.productCtr.reset();
      }
    } catch (e) {
      apiService.errorDialog(Get.context!, e.toString());
      controllers.productCtr.reset();
    }
  }


  Future<void> deleteRecordCallAPI(BuildContext context) async {
    try {
      Map<String, dynamic> data = {
        "action": "delete_record",
        "user_id": controllers.storage.read("id"),
        "cos_id": controllers.storage.read("cos_id"),
        "recordList": selectedRecordCallIds,
      };
      print("delete record $data");
      final response = await http.post(
        Uri.parse(scriptApi),
        // headers: {
        //   "Accept": "application/json",
        //   "Content-Type": "application/json",
        // },
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
      print("Response body: ${response.body}");
      Map<String, dynamic> result = json.decode(response.body);
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return deleteRecordCallAPI(context);
        } else {
          controllers.setLogOut();
        }
      }
      if (response.statusCode == 200 && result["message"] == "OK") {
        Navigator.pop(context);
        apiService.getAllCallActivity("");
        apiService.getAllMailActivity();
        utils.snackBar(
          context: context,
          msg: "Call Record deleted successfully.",
          color: Colors.green,
        );
        controllers.productCtr.reset();
        selectedRecordCallIds.clear();

      } else {
        apiService.errorDialog(
          Get.context!,
          result["message"] ?? "Failed to delete call record.",
        );
        controllers.productCtr.reset();
      }
    } catch (e) {
      apiService.errorDialog(Get.context!, e.toString());
      controllers.productCtr.reset();
    }
  }


  Future<void> deleteRecordMailAPI(BuildContext context) async {
    try {
      Map<String, dynamic> data = {
        "action": "delete_record",
        "user_id": controllers.storage.read("id"),
        "cos_id": controllers.storage.read("cos_id"),
        "recordList": selectedRecordMailIds,
      };
      print("Response bodyjsonEncode(billing_data): ${jsonEncode(data)}");
      final response = await http.post(
        Uri.parse(scriptApi),
        // headers: {
        //   "Accept": "application/json",
        //   "Content-Type": "application/json",
        // },
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      print("Response body: ${response.body}");

      Map<String, dynamic> result = json.decode(response.body);
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return deleteRecordMailAPI(context);
        } else {
          controllers.setLogOut();
        }
      }
      if (response.statusCode == 200 && result["message"] == "OK") {
        Navigator.pop(context);
        utils.snackBar(
          context: context,
          msg: "Mail Record deleted successfully.",
          color: Colors.green,
        );
        controllers.productCtr.reset();
        selectedRecordMailIds.clear();
      } else {
        apiService.errorDialog(
          Get.context!,
          result["message"] ?? "Failed to delete mail record.",
        );
        controllers.productCtr.reset();
      }
    } catch (e) {
      apiService.errorDialog(Get.context!, e.toString());
      controllers.productCtr.reset();
    }
  }


}
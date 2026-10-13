import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fullcomm_crm/common/utilities/utils.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../billing_utils/sized_box.dart';
import '../../components/Customtext.dart';
import '../../controller/reminder_controller.dart';
import '../../models/customer_activity.dart';
import '../../models/meeting_obj.dart';
import '../../models/reminder_obj.dart';
import '../constant/api.dart';
import '../constant/colors_constant.dart';
import '../styles/decoration.dart';


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
                    height: 350,
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

void showMailImageDialog(
    BuildContext context,
    List images,
    int index,
    ) {
  PageController controller = PageController(initialPage: index);

  if (images.isEmpty) return;

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
                            text: "Attachments",
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
                                text: "${currentPage + 1} / ${images.length}",
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
                      itemCount: images.length,
                      onPageChanged: (i) {
                        setState((){
                          currentPage = i;
                        });
                      },
                      itemBuilder: (context, i) {
                        final m = images[i];
                        return Builder(
                          builder: (context) {
                            final file = m.toLowerCase();
                            final pdfUrl = "$getImage?path=${Uri.encodeComponent(m)}";
                            if (file.endsWith(".pdf")) {
                              return InkWell(
                                onTap: () async {
                                  if (await canLaunchUrl(Uri.parse(pdfUrl))) {
                                    await launchUrl(Uri.parse(pdfUrl), mode: LaunchMode.platformDefault);
                                  } else {
                                    utils.snackBar(context: context, msg: 'Could not launch $pdfUrl', color: Colors.red);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.picture_as_pdf, color: Colors.red, size: 40),
                                      const SizedBox(height: 5),
                                      const Text("View PDF", style: TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                ),
                              );
                            } else if(file.endsWith(".svg")){
                              return SvgPicture.network(
                                "$getImage?path=$m",
                                height: 50,width: 50,
                                fit: BoxFit.cover,
                                placeholderBuilder: (context) =>
                                const CircularProgressIndicator(),
                              );
                            }else {
                              // else if (file.endsWith(".jpg"
                              //   }) ||
                              //   file.endsWith(".jpeg") ||
                              //   file.endsWith(".png")) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Column(
                                  children: [
                                    Image.network(
                                      "$getImage?path=${Uri.encodeComponent(m)}",
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  ],
                                ),
                              );
                            }
                            // else {
                            //   return ListTile(
                            //     title: Text("Unsupported file"),
                            //   );
                            // }
                          },
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


void showImageDialog(
    BuildContext context,
    List<String> images,
    int index,
    ) {
  if (images.isEmpty) return;

  final PageController controller = PageController(initialPage: index);

  showDialog(
    context: context,
    barrierColor: Colors.black87,
    builder: (context) {
      int currentPage = index;

      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: Colors.black,
            insetPadding: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * .9,
              height: MediaQuery.of(context).size.height * .8,
              child: Stack(
                children: [

                  /// Images
                  PageView.builder(
                    controller: controller,
                    itemCount: images.length,
                    onPageChanged: (i) {
                      setState(() {
                        currentPage = i;
                      });
                    },
                    itemBuilder: (context, i) {
                      return InteractiveViewer(
                        minScale: 1,
                        maxScale: 5,
                        child: Center(
                          child: Image.network(
                            "$getImage?path=${Uri.encodeComponent(images[i])}",
                            fit: BoxFit.contain,
                            loadingBuilder:
                                (context, child, progress) {
                              if (progress == null) return child;

                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                            errorBuilder:
                                (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.white,
                                  size: 70,
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),

                  /// Close Button
                  Positioned(
                    top: 10,
                    right: 10,
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),

                  /// Image Count
                  Positioned(
                    bottom: 15,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${currentPage + 1} / ${images.length}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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
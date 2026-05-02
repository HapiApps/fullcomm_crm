import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fullcomm_crm/common/styles/decoration.dart';
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
import '../../controller/product_controller.dart';
import '../../models/all_customers_obj.dart';
import '../../models/customer_full_obj.dart';
import '../../models/new_lead_obj.dart';
import '../invoice/invoice.dart';
import '../quotation/quotation_page.dart';

class ViewLead extends StatefulWidget {
  final int listIndex;
  final String? id;
  final String leadIndex;
  final String pageName;
  final String? name;
  final String? mobileNumber;
  final String whatsAppNo;
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
  final RxList<NewLeadObj> list;
  final RxList<NewLeadObj> list2;
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
    required this.sourceDetails, required this.whatsAppNo, required this.leadIndex, required this.list, required this.list2, required this.listIndex,
  });

  @override
  State<ViewLead> createState() => _ViewLeadState();
}

class _ViewLeadState extends State<ViewLead> {
  var type;

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
      return DateFormat('dd-MM-yyyy hh:mm a').format(dt);
    } catch (e) {
      return input;
    }
  }
void checkType(){
  debugPrint("type... $type");
  for (var i=0;i<controllers.leadCategoryList.length;i++){
    debugPrint("widget.leadIndex... ${widget.leadIndex}");
    debugPrint("controllers.leadCategoryList[i].leadStatus... ${controllers.leadCategoryList[i].leadStatus}");
    debugPrint("controllers.leadCategoryList[i].leadStatus... ${controllers.leadCategoryList[i].displayOrder}");
    if(controllers.leadCategoryList[i].leadStatus==widget.leadIndex){
      type=controllers.leadCategoryList[i].displayOrder;
      debugPrint("type... $type");
      break;
    }
  }
}
  @override
  void initState() {
    super.initState();
    checkType();
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


  @override
  Widget build(BuildContext context) {
    debugPrint("widget.id");
    debugPrint(widget.id);
    double screenWidth = MediaQuery.of(context).size.width;
    return SelectionArea(
      child: Scaffold(
        body: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SideBar(),
            Container(
              width: screenWidth-150,
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
                      final displayName = primaryPerson?.name ?? cust?.companyName ?? widget.name ?? "";
                      final displayMobile = primaryPerson?.phone ?? widget.mobileNumber ?? "";
                      final displayEmail = primaryPerson?.email ?? widget.email ?? "";
                      // debugPrint("data.customer ${data.customer}");
                      // debugPrint("primaryPerson?.name ${primaryPerson?.name}");
                      // debugPrint("cust?.companyName ${cust?.companyName}");
                      // debugPrint("widget.name ${widget.name}");
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
                              } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                                _controller.animateTo(
                                  _controller.offset - 100,
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                );
                              }
                            }
                          },
                          child: SizedBox(
                            // color: Colors.blue,
                            width: screenWidth/1.2,
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
                                            text: "View ${widget.pageName} Details",
                                            isCopy: true,
                                            colors: colorsConst.textColor,
                                            size: 20,
                                            isBold: true,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                10.height,
                                Divider(
                                  color: colorsConst.textColor,
                                  thickness: 1,
                                ),
                                20.height,
                                Container(
                                  width: screenWidth/3,
                                  decoration: customDecoration.baseBackgroundDecoration(
                                    color: Colors.white,radius: 10,borderColor: Colors.grey.shade200
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      children: [
                                        Row(
                                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                              width: screenWidth/5,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  CustomText(text: "COMPANY",colors: colorsConst.textColor,isCopy: true),10.height,
                                                  CustomText(text: cust?.companyName ?? "",colors: colorsConst.textColor,isCopy: true,isBold: true,),
                                                ],
                                              ),
                                            ),
                                            10.width,
                                            Container(width: 2,height: 40,color: Colors.grey.shade200,),
                                            30.width,
                                            SizedBox(
                                              width: screenWidth/5,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  CustomText(text: "LEAD SOURCE",colors: colorsConst.textColor,isCopy: true),10.height,
                                                  CustomText(text: cust?.visitType ?? "",colors: colorsConst.textColor,isCopy: true,isBold: true,),
                                                ],
                                              ),
                                            ),
                                            10.width,
                                            Container(width: 2,height: 40,color: Colors.grey.shade200,),
                                            30.width,
                                            SizedBox(
                                              width: screenWidth/5,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  CustomText(text: "STATUS",colors: colorsConst.textColor,isCopy: true),10.height,
                                                  CustomText(text: cust?.rating ?? "",colors: colorsConst.textColor,isCopy: true,isBold: true,),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),5.height,
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            CustomText(
                                              text: "Added on ${formatDateTime(cust?.updatedTs ?? widget.updateTs)}",
                                              colors: colorsConst.textColor,
                                              isCopy: true,
                                            ),
                                            Row(
                                              children: [
                                                SizedBox(
                                                  width: 170,
                                                  height: 35,
                                                  child: ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                      shadowColor: Colors.transparent,
                                                      backgroundColor: colorsConst.primary,
                                                    ),
                                                    onPressed: () {
                                                      controllers.cusController.text="${widget.name} - ${widget.companyName}- ${widget.mobileNumber}";
                                                      controllers.selectCustomer(AllCustomersObj(
                                                          id: widget.id.toString(), name: widget.name.toString(),
                                                          companyName: widget.companyName.toString(), phoneNo: widget.mobileNumber.toString(),
                                                          email: widget.email.toString(), leadStatus: "", category: ""));
                                                      controllers.directNavigate.value=true;
                                                      controllers.qId.value=widget.id.toString();
                                                      controllers.selectedIndex.value=107;
                                                      productCtr.changeTab(1);
                                                      Get.to(QuotationPage());
                                                    },
                                                    child: MouseRegion(
                                                      cursor: SystemMouseCursors.click,
                                                      child: Row(
                                                        children: [
                                                          Icon(Icons.folder_copy_outlined,color: Colors.white,size: 20,),10.width,
                                                          CustomText(
                                                            text:"Create Quotation",colors: Colors.white, isCopy: false,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),10.width,
                                                if(type!=controllers.leadCategoryList.length)
                                                SizedBox(
                                                    width: 100,
                                                    height: 35,
                                                    child: ElevatedButton(
                                                      style: ElevatedButton.styleFrom(
                                                        shadowColor: Colors.transparent,
                                                        backgroundColor: colorsConst.primary,
                                                      ),
                                                      onPressed: (){
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            String? stageId;
                                                            String? selectedStage;
                                                            bool isEdit = false;

                                                            TextEditingController reasonController = TextEditingController();

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
                                                                          items: controllers.leadCategoryList.map((item) {
                                                                            return DropdownMenuItem<String>(
                                                                              value: item.leadStatus,
                                                                              child: Text(item.value),
                                                                            );
                                                                          }).toList(),
                                                                          onChanged: (value) {
                                                                            setState(() {
                                                                              stageId = value;
                                                                              selectedStage = controllers.leadCategoryList
                                                                                  .firstWhere((e) => e.leadStatus == value)
                                                                                  .value;


                                                                              isEdit = true;
                                                                            });
                                                                          },
                                                                        ),
                                                                      ),

                                                                      const SizedBox(height: 15),

                                                                      /// REASON FIELD
                                                                      TextField(
                                                                        controller: reasonController,
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
                                                                              context,
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
                                                      },
                                                      child: MouseRegion(
                                                        cursor: SystemMouseCursors.click,
                                                        child: Row(
                                                          children: [
                                                            Icon(Icons.move_up,color: Colors.white,size: 20),10.width,
                                                            CustomText(
                                                              text:"Promote",colors: Colors.white, isCopy: false,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),10.width,
                                                SizedBox(
                                                  width: 150,
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
                                                      child: Row(
                                                        children: [
                                                          Icon(Icons.alarm,color: Colors.white,size: 20,),10.width,
                                                          CustomText(
                                                            text:"Set Reminder",colors: Colors.white, isCopy: false,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),10.width,
                                                SizedBox(
                                                  width: 100,
                                                  height: 35,
                                                  child: ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                      shadowColor: Colors.transparent,
                                                      backgroundColor: colorsConst.primary,
                                                    ),
                                                    onPressed: () {
                                                      Get.to(
                                                        UpdateLead(
                                                          x: cust?.x,
                                                          pageName: widget.pageName,
                                                          index: widget.listIndex,
                                                          list: widget.list,list2: widget.list2,
                                                          type: "2",
                                                          id: widget.id.toString(),
                                                          mainName: widget.name,
                                                          mainMobile: displayMobile,
                                                          mainEmail: displayEmail,
                                                          mainWhatsApp: widget.whatsAppNo,
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
                                                      child: Row(
                                                        children: [
                                                          Icon(Icons.edit,color: Colors.white,size: 20,),10.width,
                                                          CustomText(
                                                            text:"Edit",colors: Colors.white, isCopy: false,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),10.width,
                                                SizedBox(
                                                  width: 140,
                                                  height: 35,
                                                  child: ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                      shadowColor: Colors.transparent,
                                                      backgroundColor: colorsConst.primary,
                                                    ),
                                                    onPressed: () {
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
                                                    child: MouseRegion(
                                                      cursor: SystemMouseCursors.click,
                                                      child: Row(
                                                        children: [
                                                          Icon(Icons.email_outlined,color: Colors.white,size: 20,),10.width,
                                                          CustomText(
                                                            text:"Send Email",colors: Colors.white, isCopy: false,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                20.height,
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      children: [
                                        Container(
                                          width: screenWidth/2.5,
                                          decoration: customDecoration.baseBackgroundDecoration(
                                            color: Colors.white,radius: 10,borderColor: Colors.grey.shade200
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    CircleAvatar(
                                                      backgroundColor: Colors.grey.shade100,radius: 15,
                                                      child: Icon(Icons.person_outlined,color: Colors.black,),
                                                    ),10.width,
                                                    CustomText(text: "Customer Overview",isCopy: true,isBold: true,size: 17),
                                                  ],
                                                ),
                                                10.height,
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        CustomText(text: "FULL NAME",isCopy: true,),5.height,
                                                        CustomText(text: widget.name.toString(),isCopy: true,isBold: true,),
                                                        10.height,
                                                        CustomText(text: _formatHeading(controllers.getUserHeading("email") ??"Email id").toUpperCase(),isCopy: true,),5.height,
                                                        CustomText(text: displayEmail,isCopy: true,isBold: true,),
                                                        10.height,
                                                        CustomText(text: _formatHeading(
                                                          controllers.getUserHeading(
                                                              "owner") ??
                                                              "Account Manager").toUpperCase(),isCopy: true,),5.height,
                                                        Row(
                                                          children: [
                                                            CircleAvatar(
                                                              backgroundColor: Colors.grey.shade100,radius: 10,
                                                              child: CustomText(text: getInitials(cust?.owner ?? widget.owner ?? ""),colors: Colors.black, isCopy: false,isBold: true,),
                                                            ),10.width,
                                                            CustomText(text: cust?.owner ?? widget.owner ?? "",isCopy: true,isBold: true,colors: Colors.black,),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        CustomText(text: _formatHeading(
                                                            controllers.getUserHeading(
                                                                "mobile_name") ??
                                                                "Mobile No").toUpperCase(),isCopy: true,),5.height,
                                                        CustomText(text: (displayMobile)
                                                            .toString()
                                                            .split("||")
                                                            .where((e) => e.isNotEmpty)
                                                            .join(", "),isCopy: true,isBold: true,),
                                                        10.height,
                                                        CustomText(text: "WHATSAPP",isCopy: true,),5.height,
                                                        CustomText(text: widget.whatsAppNo,isCopy: true,isBold: true,),
                                                        10.height,
                                                        Row(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                CustomText(text: "VISIT TYPE",isCopy: true,),
                                                                5.height,
                                                                Container(
                                                                    decoration: customDecoration.baseBackgroundDecoration(
                                                                        color: Colors.grey.shade50,radius: 5
                                                                    ),
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.all(3),
                                                                      child: CustomText(text: cust?.visitType ?? "",isCopy: true,isBold: true,),
                                                                    )),
                                                              ],
                                                            ),
                                                            Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                CustomText(text: "QUOTATION REQUIRED",isCopy: true,),
                                                                5.height,
                                                                Container(
                                                                    decoration: customDecoration.baseBackgroundDecoration(
                                                                        color: Color(0xFFFCDEB5),radius: 5
                                                                    ),
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.all(3),
                                                                      child: CustomText(text: (cust?.product ?? "").isNotEmpty
                                                                          ? (cust!.product == "1" ? "Yes" : "No")
                                                                          : "No",isCopy: true,isBold: true,),
                                                                    )),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),20.height,
                                        Container(
                                          width: screenWidth/2.5,
                                          padding: const EdgeInsets.all(18),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(18),
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF0D5EA8),
                                                Color(0xFF0B74D1),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(.12),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [

                                              /// TOP ROW
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets.all(8),
                                                        decoration: BoxDecoration(
                                                          color: Colors.white.withOpacity(.12),
                                                          shape: BoxShape.circle,
                                                        ),
                                                        child: const Icon(
                                                          Icons.insights,
                                                          color: Colors.white,
                                                          size: 18,
                                                        ),
                                                      ),
                                                      12.width,
                                                      CustomText(
                                                        text: "Business Insights",
                                                        isCopy: true,
                                                        isBold: true,
                                                        colors: Colors.white,
                                                        size: 18,
                                                      ),
                                                    ],
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white.withOpacity(.15),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                    child: CustomText(
                                                      text: "CONFIDENTIAL",
                                                      isCopy: true,
                                                      isBold: true,
                                                      colors: Colors.white70,
                                                      size: 10,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              20.height,
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [

                                                        CustomText(
                                                          text: _formatHeading(controllers
                                                              .getUserHeading(
                                                              "product_discussion") ??
                                                              "Product Discussed").toUpperCase(),
                                                          isCopy: true,
                                                          isBold: true,
                                                          colors: Colors.white60,
                                                          size: 10,
                                                        ),

                                                        const SizedBox(height: 5),

                                                        CustomText(
                                                          text: cust?.product ?? "",
                                                          isCopy: true,
                                                          isBold: true,
                                                          colors: Colors.white,
                                                          size: 15,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  10.width,
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [

                                                        CustomText(
                                                          text: "DEAL VALUE",
                                                          isCopy: true,
                                                          isBold: true,
                                                          colors: Colors.white60,
                                                          size: 10,
                                                        ),

                                                        5.height,

                                                        CustomText(
                                                          text: "\$42,500.00",
                                                          isCopy: true,
                                                          isBold: true,
                                                          colors: Colors.white,
                                                          size: 24,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  10.width,
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [

                                                        CustomText(
                                                          text: "PRIORITY",
                                                          isCopy: true,
                                                          isBold: true,
                                                          colors: Colors.white60,
                                                          size: 10,
                                                        ),

                                                        7.height,

                                                        Row(
                                                          children: [
                                                            Container(
                                                              width: 8,
                                                              height: 8,
                                                              decoration: const BoxDecoration(
                                                                color: Colors.red,
                                                                shape: BoxShape.circle,
                                                              ),
                                                            ),
                                                            6.width,
                                                            CustomText(
                                                              text: "Normal",
                                                              isCopy: true,
                                                              isBold: true,
                                                              colors: Colors.white,
                                                              size: 13,
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              18.height,
                                              Container(
                                                width: double.infinity,
                                                padding: const EdgeInsets.all(14),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(.08),
                                                  borderRadius: BorderRadius.circular(14),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [

                                                    CustomText(
                                                      text: "ADDITIONAL NOTES",
                                                      isCopy: true,
                                                      isBold: true,
                                                      colors: Colors.white60,
                                                      size: 10,
                                                    ),

                                                    const SizedBox(height: 8),

                                                    CustomText(
                                                      text:widget.notes ?? "",
                                                      isCopy: true,
                                                      colors: Colors.white,
                                                      size: 13,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),20.height,
                                        Container(
                                          width: screenWidth/2.5,
                                          decoration: customDecoration.baseBackgroundDecoration(
                                              color: Colors.white,radius: 10,borderColor: Colors.grey.shade200
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    CircleAvatar(
                                                      backgroundColor: Colors.grey.shade100,radius: 15,
                                                      child: Icon(Icons.grid_view,color: Colors.black,),
                                                    ),10.width,
                                                    CustomText(text: "Company Information",isCopy: true,isBold: true,size: 17,),
                                                  ],
                                                ),
                                                10.height,
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        CustomText(text: _formatHeading(controllers.getUserHeading
                                                          ("company_name") ?? "Company Name").toUpperCase(),isCopy: true,),5.height,
                                                        CustomText(text: cust?.companyName ?? "",isCopy: true,isBold: true,),
                                                        10.height,
                                                        CustomText(text: "COMPANY NUMBER",isCopy: true,),5.height,
                                                        CustomText(text: (cust?.companyNumber ?? "")
                                                            .toString()
                                                            .split("||")
                                                            .where((e) => e.isNotEmpty)
                                                            .join(", "),isCopy: true,isBold: true,),
                                                        10.height,
                                                        CustomText(text: "Industry".toUpperCase(),isCopy: true,),5.height,
                                                        CustomText(text: cust?.industry ?? "",isCopy: true,isBold: true,),
                                                      10.height,
                                                        CustomText(text: "ADDRESS",isCopy: true,),5.height,
                                                        CustomText(text: "${addr?.doorNo},${addr?.area},${addr?.city}",isCopy: true,isBold: true,),
                                                        CustomText(text: "${addr?.state},${addr?.country},${addr?.pincode}",isCopy: true,isBold: true,),
                                                      ],
                                                    ),
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        CustomText(text: "Linkedin".toUpperCase(),isCopy: true,),5.height,
                                                        CustomText(text: cust?.linkedin ?? "",isCopy: true,isBold: true,),
                                                        10.height,
                                                        CustomText(text: "Website".toUpperCase(),isCopy: true,),5.height,
                                                        CustomText(text: cust?.companyWebsite ?? "",isCopy: true,isBold: true,),
                                                        10.height,
                                                        CustomText(text: "Email".toUpperCase(),isCopy: true,),5.height,
                                                        CustomText(text: cust?.companyEmail ?? "",isCopy: true,isBold: true,),
                                                        10.height,
                                                        CustomText(text: "Product/Services".toUpperCase(),isCopy: true,),5.height,
                                                        CustomText(text: cust?.product ?? "",isCopy: true,isBold: true,),
                                                        10.height,
                                                        CustomText(text: "X",isCopy: true,),5.height,
                                                        CustomText(text: cust?.x ?? "",isCopy: true,isBold: true,),
                                                        10.height,
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),20.height,
                                        Container(
                                          width: screenWidth/2.5,
                                          decoration: customDecoration.baseBackgroundDecoration(
                                              color: Colors.white,radius: 10,borderColor: Colors.grey.shade200
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    CircleAvatar(
                                                      backgroundColor: Colors.grey.shade100,radius: 15,
                                                      child: Icon(Icons.person_outline_sharp,color: Colors.black,),
                                                    ),10.width,
                                                    CustomText(text: "Customer Fields",isCopy: true,isBold: true,size: 17,),
                                                  ],
                                                ),
                                                10.height,
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        CustomText(text: _formatHeading(controllers
                                                            .getUserHeading(
                                                            "product_discussion") ??
                                                            "Product Discussed").toUpperCase(),isCopy: true,),5.height,
                                                        CustomText(text: cust?.product ?? "",isCopy: true,isBold: true,),
                                                        10.height,
                                                        CustomText(text: _formatHeading(controllers
                                                            .getUserHeading("status") ??
                                                            "Status").toUpperCase(),isCopy: true,),5.height,
                                                        CustomText(text: widget.pageName,isCopy: true,isBold: true,),
                                                        10.height,
                                                        CustomText(text: _formatHeading(controllers
                                                            .getUserHeading(
                                                            "expected_billing_value") ??
                                                            "Expected Monthly Billing Value").toUpperCase(),isCopy: true,),5.height,
                                                        CustomText(text: cust?.expectedBillingValue ?? "",isCopy: true,isBold: true,),
                                                        ],
                                                    ),
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        CustomText(text: _formatHeading(controllers
                                                            .getUserHeading(
                                                            "num_of_headcount") ??
                                                            "Total Number Of Head Count").toUpperCase(),isCopy: true,),5.height,
                                                        CustomText(text: cust?.numOfHeadcount ?? "",isCopy: true,isBold: true,),
                                                        10.height,
                                                        CustomText(text: _formatHeading(controllers
                                                            .getUserHeading(
                                                            "details_of_service_required") ??
                                                            "Details of Service Required").toUpperCase(),isCopy: true,),5.height,
                                                        CustomText(text: cust?.detailsOfServiceRequired ?? "",isCopy: true,isBold: true,),
                                                        10.height,
                                                        CustomText(text: _formatHeading(controllers
                                                            .getUserHeading("rating") ??
                                                            "Prospect Grading").toUpperCase(),isCopy: true,),5.height,
                                                        CustomText(text: cust?.rating ?? "",isCopy: true,isBold: true,),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        20.height,
                                        if (additional.isNotEmpty)
                                        Container(
                                          width: screenWidth/2.5,
                                          decoration: customDecoration.baseBackgroundDecoration(
                                              color: Colors.white,radius: 10,borderColor: Colors.grey.shade200
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Column(
                                              children: [
                                                CustomText(text: "Additional Information",isCopy: true,isBold: true,size: 17,),
                                                10.height,
                                                ...additional.map((info) => Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    CustomText(text: info.fieldName ?? "".toUpperCase(),isCopy: true,),5.height,
                                                    CustomText(text: info.fieldValue ?? "",isCopy: true,isBold: true,),
                                                  ],
                                                )),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      width: screenWidth/2.5,
                                      decoration: customDecoration.baseBackgroundDecoration(
                                          color: Colors.white,radius: 10,borderColor: Colors.grey.shade200
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                          children: [
                                            CustomText(text: "Activity Timeline",isCopy: true,isBold: true,size: 17),
                                            5.height,
                                            Container(
                                              decoration: customDecoration.baseBackgroundDecoration(
                                               color: colorsConst.primary,radius: 5
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(10),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    CustomText(text: "Total Activities",isCopy: true,colors: Colors.white,),10.width,
                                                    CustomText(text: "${calls.length+meetings.length+reminders.length}",isCopy: true,isBold: true,size: 17,colors: Colors.white),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            if (calls.isNotEmpty) ...[
                                              SizedBox(
                                                  width: screenWidth / 4.5,
                                                  child: _buildCallRecords(calls)),
                                              20.height,
                                            ],
                                            if (meetings.isNotEmpty) ...[
                                              SizedBox(
                                                  width: screenWidth / 4.5,
                                                  child: _buildMeetingRecords(meetings)),
                                              20.height,
                                            ],
                                            if (reminders.isNotEmpty) ...[
                                              SizedBox(
                                                  width: screenWidth / 4.5,
                                                  child: _buildReminderRecords(reminders)),
                                              20.height,
                                            ]
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                // Row(
                                //   crossAxisAlignment: CrossAxisAlignment.start,
                                //   children: [
                                //     Column(
                                //       children: [
                                //         Container(
                                //           height: 190,
                                //           decoration: BoxDecoration(
                                //             color: Colors.white,
                                //             border: Border.all(color: Colors.black),
                                //             borderRadius: BorderRadius.circular(10),
                                //           ),
                                //           child: Column(
                                //             children: [
                                //               15.height,
                                //               Row(
                                //                 children: [
                                //                   20.width,
                                //                   SizedBox(
                                //                     width: screenWidth / 3.5,
                                //                     child: Row(
                                //                       children: [
                                //                         Column(
                                //                           crossAxisAlignment:
                                //                           CrossAxisAlignment.start,
                                //                           children: [
                                //                             CustomText(
                                //                               text: "New Lead",
                                //                               colors: colorsConst.textColor,
                                //                               isBold: true,
                                //                               size: 16,
                                //                               isCopy: true,
                                //                             ),
                                //                             20.height,
                                //                             utils.leadText(
                                //                               text: _formatHeading(
                                //                                   controllers.getUserHeading(
                                //                                       "name") ??
                                //                                       "Name"),
                                //                               color: colorsConst.primary,
                                //                             ),
                                //                             20.height,
                                //                             utils.leadText(
                                //                               text: _formatHeading(
                                //                                   controllers.getUserHeading(
                                //                                       "mobile_name") ??
                                //                                       "Mobile No"),
                                //                               color: colorsConst.primary,
                                //                             ),
                                //                             20.height,
                                //                             utils.leadText(
                                //                               text: _formatHeading(
                                //                                   controllers.getUserHeading(
                                //                                       "email") ??
                                //                                       "Email id"),
                                //                               color: colorsConst.primary,
                                //                             ),
                                //                           ],
                                //                         ),
                                //                         30.width,
                                //                         Column(
                                //                           crossAxisAlignment:
                                //                           CrossAxisAlignment.start,
                                //                           children: [
                                //                             CustomText(
                                //                               text: "",
                                //                               colors: colorsConst.textColor,
                                //                               isBold: true,
                                //                               isCopy: true,
                                //                               size: 16,
                                //                             ),
                                //                             20.height,
                                //                             utils.leadText(
                                //                                 text: widget.name,
                                //                                 color: colorsConst.textColor),
                                //                             20.height,
                                //                             utils.leadText(
                                //                                 text: (displayMobile)
                                //                                     .toString()
                                //                                     .split("||")
                                //                                     .where((e) => e.isNotEmpty)
                                //                                     .join(", "),
                                //                                 color: colorsConst.textColor),
                                //                             // utils.leadText(
                                //                             //     text: displayMobile,
                                //                             //     color: colorsConst.textColor),
                                //                             20.height,
                                //                             utils.leadText(
                                //                                 text: displayEmail,
                                //                                 color: colorsConst.textColor),
                                //                           ],
                                //                         ),
                                //                       ],
                                //                     ),
                                //                   ),
                                //                   20.width,
                                //                   SizedBox(
                                //                     width: screenWidth / 3.5,
                                //                     child: Row(
                                //                       children: [
                                //                         Column(
                                //                           crossAxisAlignment:
                                //                           CrossAxisAlignment.start,
                                //                           children: [
                                //                             CustomText(
                                //                               text: "",
                                //                               isCopy: true,
                                //                               colors: colorsConst.textColor,
                                //                               isBold: true,
                                //                               size: 16,
                                //                             ),
                                //                             20.height,
                                //                             utils.leadText(
                                //                               text: _formatHeading(
                                //                                   controllers.getUserHeading(
                                //                                       "owner") ??
                                //                                       "Account Manager"),
                                //                               color: colorsConst.primary,
                                //                             ),
                                //                             20.height,
                                //                             utils.leadText(
                                //                                 text: "Whatsapp No",
                                //                                 color: colorsConst.primary),
                                //                             20.height,
                                //                             utils.leadText(
                                //                                 text: "Quotation Required",
                                //                                 color: colorsConst.primary),
                                //                             20.height,
                                //                             utils.leadText(
                                //                                 text: "Visit Type",
                                //                                 color: colorsConst.primary),
                                //                           ],
                                //                         ),
                                //                         40.width,
                                //                         Column(
                                //                           crossAxisAlignment: CrossAxisAlignment.start,
                                //                           children: [
                                //                             CustomText(
                                //                               text: "",
                                //                               colors: colorsConst.textColor,
                                //                               isBold: true,
                                //                               size: 16,
                                //                               isCopy: true,
                                //                             ),
                                //                             20.height,
                                //                             utils.leadText(
                                //                                 text: cust?.owner ?? widget.owner ?? "",
                                //                                 color: colorsConst.textColor),
                                //                             20.height,
                                //                             utils.leadText(
                                //                                 text: widget.whatsAppNo,
                                //                                 color: colorsConst.textColor),
                                //                             20.height,
                                //                             utils.leadText(
                                //                                 text: (cust?.product ?? "").isNotEmpty
                                //                                     ? (cust!.product == "1" ? "Yes" : "No")
                                //                                     : "No",
                                //                                 color: colorsConst.textColor),
                                //                             20.height,
                                //                             utils.leadText(
                                //                                 text: cust?.visitType ?? "",
                                //                                 color: colorsConst.textColor),
                                //                           ],
                                //                         ),
                                //                       ],
                                //                     ),
                                //                   ),
                                //                   20.width
                                //                 ],
                                //               ),
                                //             ],
                                //           ),
                                //         ),
                                //         20.height,
                                //         // Address card
                                //         Container(
                                //           height: 180,
                                //           decoration: BoxDecoration(
                                //             color: Colors.white,
                                //             border: Border.all(color: Colors.black),
                                //             borderRadius: BorderRadius.circular(10),
                                //           ),
                                //           child: Column(
                                //             children: [
                                //               15.height,
                                //               Row(
                                //                 children: [
                                //                   20.width,
                                //                   SizedBox(
                                //                     width: screenWidth / 3.5,
                                //                     child: Row(
                                //                       children: [
                                //                         Column(
                                //                           crossAxisAlignment:
                                //                           CrossAxisAlignment.start,
                                //                           children: [
                                //                             CustomText(
                                //                               text: "Address Information",
                                //                               colors: colorsConst.textColor,
                                //                               isBold: true,
                                //                               size: 16,
                                //                               isCopy: true,
                                //                             ),
                                //                             20.height,
                                //                             utils.leadText(
                                //                                 text: "Door No",
                                //                                 color: colorsConst.primary),
                                //                             20.height,
                                //                             utils.leadText(
                                //                                 text: "Area",
                                //                                 color: colorsConst.primary),
                                //                             20.height,
                                //                             utils.leadText(
                                //                                 text: "State",
                                //                                 color: colorsConst.primary),
                                //                           ],
                                //                         ),
                                //                         Column(
                                //                           crossAxisAlignment:
                                //                           CrossAxisAlignment.start,
                                //                           children: [
                                //                             CustomText(
                                //                               text: "",
                                //                               colors: colorsConst.textColor,
                                //                               isBold: true,
                                //                               size: 16,
                                //                               isCopy: true,
                                //                             ),
                                //                             20.height,
                                //                             utils.leadText(
                                //                                 text: addr?.doorNo ?? "",
                                //                                 color: colorsConst.textColor),
                                //                             20.height,
                                //                             utils.leadText(
                                //                                 text: addr?.area ?? "",
                                //                                 color: colorsConst.textColor),
                                //                             20.height,
                                //                             utils.leadText(
                                //                                 text: addr?.state ?? "",
                                //                                 color: colorsConst.textColor),
                                //                           ],
                                //                         ),
                                //                       ],
                                //                     ),
                                //                   ),
                                //                   20.width,
                                //                   SizedBox(
                                //                     width: screenWidth / 3.5,
                                //                     child: Row(
                                //                       children: [
                                //                         Column(
                                //                           crossAxisAlignment:
                                //                           CrossAxisAlignment.start,
                                //                           children: [
                                //                             CustomText(
                                //                               text: "",
                                //                               colors: colorsConst.textColor,
                                //                               isBold: true,
                                //                               size: 16,
                                //                               isCopy: true,
                                //                             ),
                                //                             20.height,
                                //                             utils.leadText(
                                //                                 text: "Pincode",
                                //                                 color: colorsConst.primary),
                                //                             20.height,
                                //                             utils.leadText(
                                //                                 text: "City",
                                //                                 color: colorsConst.primary),
                                //                             20.height,
                                //                             utils.leadText(
                                //                                 text: "Country",
                                //                                 color: colorsConst.primary),
                                //                           ],
                                //                         ),
                                //                         40.width,
                                //                         Column(
                                //                           crossAxisAlignment:
                                //                           CrossAxisAlignment.start,
                                //                           children: [
                                //                             CustomText(
                                //                               text: "",
                                //                               colors: colorsConst.textColor,
                                //                               isBold: true,
                                //                               size: 16,
                                //                               isCopy: true,
                                //                             ),
                                //                             20.height,
                                //                             utils.leadText(
                                //                                 text: addr?.pincode ?? "",
                                //                                 color: colorsConst.textColor),
                                //                             20.height,
                                //                             utils.leadText(
                                //                                 text: addr?.city ?? "",
                                //                                 color: colorsConst.textColor),
                                //                             20.height,
                                //                             utils.leadText(
                                //                                 text: addr?.country ?? "",
                                //                                 color: colorsConst.textColor),
                                //                           ],
                                //                         ),
                                //                       ],
                                //                     ),
                                //                   ),
                                //                   20.width
                                //                 ],
                                //               ),
                                //             ],
                                //           ),
                                //         ),
                                //         20.height,
                                //         // Company info
                                //         Container(
                                //           height: 200,
                                //           decoration: BoxDecoration(
                                //             color: Colors.white,
                                //             border: Border.all(color: Colors.black),
                                //             borderRadius: BorderRadius.circular(10),
                                //           ),
                                //           child: Column(
                                //             children: [
                                //               15.height,
                                //               Row(
                                //                 children: [
                                //                   20.width,
                                //                   SizedBox(
                                //                     width: screenWidth / 3.5,
                                //                     child: Row(
                                //                       children: [
                                //                         Column(
                                //                           crossAxisAlignment:
                                //                           CrossAxisAlignment.start,
                                //                           children: [
                                //                             CustomText(
                                //                               text: "Company Information",
                                //                               colors: colorsConst.textColor,
                                //                               isBold: true,
                                //                               size: 16,
                                //                               isCopy: true,
                                //                             ),
                                //                             20.height,
                                //                             utils.leadText(
                                //                                 text: _formatHeading(controllers.getUserHeading
                                //                                   ("company_name") ?? "Company Name"),
                                //                                 color: colorsConst.primary),
                                //                             20.height,
                                //                             utils.leadText(
                                //                                 text: "Company Phone No.",
                                //                                 color: colorsConst.primary),
                                //                             20.height,
                                //                             utils.leadText(
                                //                                 text: "Industry",
                                //                                 color: colorsConst.primary),
                                //                             20.height,
                                //                             utils.leadText(
                                //                                 text: "Linkedin",
                                //                                 color: colorsConst.primary),
                                //                           ],
                                //                         ),
                                //                         10.width,
                                //                         Column(
                                //                           crossAxisAlignment: CrossAxisAlignment.start,
                                //                           children: [
                                //                             CustomText(
                                //                               text: "",
                                //                               colors: colorsConst.textColor,
                                //                               isBold: true,
                                //                               size: 16,
                                //                               isCopy: true,
                                //                             ),
                                //                             20.height,
                                //                             utils.leadText(
                                //                                 text: cust?.companyName ?? "",
                                //                                 color: colorsConst.textColor),
                                //                             20.height,
                                //                             utils.leadText(
                                //                                 text: (cust?.companyNumber ?? "")
                                //                                     .toString()
                                //                                     .split("||")
                                //                                     .where((e) => e.isNotEmpty)
                                //                                     .join(", "),
                                //                                 color: colorsConst.textColor),
                                //                             20.height,
                                //                             utils.leadText(
                                //                                 text: cust?.industry ?? "",
                                //                                 color: colorsConst.textColor),
                                //                             20.height,
                                //                             utils.leadText(
                                //                                 text: cust?.linkedin ?? "",
                                //                                 color: colorsConst.textColor),
                                //                           ],
                                //                         ),
                                //                       ],
                                //                     ),
                                //                   ),
                                //                   20.width,
                                //                   SizedBox(
                                //                     width: screenWidth / 3.5,
                                //                     child: Row(
                                //                       children: [
                                //                         Column(
                                //                           crossAxisAlignment:
                                //                           CrossAxisAlignment.start,
                                //                           children: [
                                //                             CustomText(
                                //                               text: "",
                                //                               colors: colorsConst.textColor,
                                //                               isBold: true,
                                //                               isCopy: true,
                                //                               size: 16,
                                //                             ),
                                //                             20.height,
                                //                             utils.leadText(
                                //                                 text: "Website",
                                //                                 color: colorsConst.primary),
                                //                             20.height,
                                //                             utils.leadText(
                                //                                 text: "Company Email",
                                //                                 color: colorsConst.primary),
                                //                             20.height,
                                //                             utils.leadText(
                                //                                 text: "Product/Services",
                                //                                 color: colorsConst.primary),
                                //                             20.height,
                                //                             utils.leadText(text: "X", color: colorsConst.primary),
                                //                           ],
                                //                         ),
                                //                         30.width,
                                //                         Column(
                                //                           crossAxisAlignment:
                                //                           CrossAxisAlignment.start,
                                //                           children: [
                                //                             CustomText(
                                //                               text: "",
                                //                               colors: colorsConst.textColor,
                                //                               isBold: true,
                                //                               size: 16,
                                //                               isCopy: true,
                                //                             ),
                                //                             20.height,
                                //                             utils.leadText(
                                //                                 text: cust?.companyWebsite ?? "",
                                //                                 color: colorsConst.textColor),
                                //                             20.height,
                                //                             utils.leadText(
                                //                                 text: cust?.companyEmail ?? "",
                                //                                 color: colorsConst.textColor),
                                //                             20.height,
                                //                             utils.leadText(
                                //                                 text: cust?.product ?? "",
                                //                                 color: colorsConst.textColor),
                                //                             20.height,
                                //                             utils.leadText(
                                //                                 text: cust?.x ?? "",
                                //                                 color: colorsConst.textColor),
                                //                           ],
                                //                         ),
                                //                       ],
                                //                     ),
                                //                   ),
                                //                   20.width
                                //                 ],
                                //               ),
                                //             ],
                                //           ),
                                //         ),
                                //         20.height,
                                //         // Customer fields & additional info
                                //         Container(
                                //           height: 380,
                                //           decoration: BoxDecoration(
                                //             color: Colors.white,
                                //             border: Border.all(color: Colors.black),
                                //             borderRadius: BorderRadius.circular(10),
                                //           ),
                                //           child: Column(
                                //             children: [
                                //               15.height,
                                //               Row(
                                //                 children: [
                                //                   20.width,
                                //                   SizedBox(
                                //                     width: screenWidth /3.5,
                                //                     child: Row(
                                //                       children: [
                                //                         Column(
                                //                           crossAxisAlignment:
                                //                           CrossAxisAlignment.start,
                                //                           children: [
                                //                             CustomText(
                                //                               text: "Customer Fields",
                                //                               colors: colorsConst.textColor,
                                //                               isBold: true,
                                //                               size: 16,
                                //                               isCopy: true,
                                //                             ),
                                //                             20.height,
                                //                             utils.leadText(
                                //                                 text: _formatHeading(controllers
                                //                                     .getUserHeading(
                                //                                     "product_discussion") ??
                                //                                     "Product Discussed"),
                                //                                 color: colorsConst.primary),
                                //                             20.height,
                                //                             utils.leadText(
                                //                                 text: _formatHeading(controllers
                                //                                     .getUserHeading("status") ??
                                //                                     "Status"),
                                //                                 color: colorsConst.primary),
                                //                             20.height,
                                //                             utils.leadText(
                                //                                 text: _formatHeading(controllers
                                //                                     .getUserHeading(
                                //                                     "expected_billing_value") ??
                                //                                     "Expected Monthly Billing Value"),
                                //                                 color: colorsConst.primary),
                                //                             20.height,
                                //                             utils.leadText(
                                //                                 text: _formatHeading(controllers
                                //                                     .getUserHeading(
                                //                                     "num_of_headcount") ??
                                //                                     "Total Number Of Head Count"),
                                //                                 color: colorsConst.primary),
                                //                             20.height,
                                //                             utils.leadText(
                                //                                 text: _formatHeading(controllers
                                //                                     .getUserHeading(
                                //                                     "details_of_service_required") ??
                                //                                     "Details of Service Required"),
                                //                                 color: colorsConst.primary),
                                //                             20.height,
                                //                             utils.leadText(
                                //                                 text: _formatHeading(controllers
                                //                                     .getUserHeading("rating") ??
                                //                                     "Prospect Grading"),
                                //                                 color: colorsConst.primary),
                                //                           ],
                                //                         ),
                                //                         40.width,
                                //                         Column(
                                //                           crossAxisAlignment:
                                //                           CrossAxisAlignment.start,
                                //                           children: [
                                //                             CustomText(
                                //                               text: "",
                                //                               colors: colorsConst.textColor,
                                //                               isBold: true,
                                //                               size: 16,
                                //                               isCopy: true,
                                //                             ),
                                //                             20.height,
                                //                             utils.leadText(
                                //                                 text: cust?.product ?? "",
                                //                                 color: colorsConst.textColor),
                                //                             20.height,
                                //                             utils.leadText(
                                //                               text: (() {
                                //                                 final ls = cust?.leadStatus;
                                //                                 if (ls == null) return "";
                                //                                 if (ls == 1) return "Suspects";
                                //                                 if (ls == 2) return "Prospects";
                                //                                 if (ls == 3) return "Qualified";
                                //                                 return "Customers";
                                //                               })(),
                                //                               color: colorsConst.textColor,
                                //                             ),
                                //                             20.height,
                                //                             utils.leadText(
                                //                                 text: cust?.expectedBillingValue ?? "",
                                //                                 color: colorsConst.textColor),
                                //                             20.height,
                                //                             utils.leadText(
                                //                                 text: cust?.numOfHeadcount ?? "",
                                //                                 color: colorsConst.textColor),
                                //                             20.height,
                                //                             utils.leadText(
                                //                                 text: cust?.detailsOfServiceRequired ?? "",
                                //                                 color: colorsConst.textColor),
                                //                             20.height,
                                //                             utils.leadText(
                                //                                 text: cust?.rating ?? "",
                                //                                 color: colorsConst.textColor),
                                //                           ],
                                //                         ),
                                //                       ],
                                //                     ),
                                //                   ),
                                //                   20.width,
                                //                   SizedBox(
                                //                     width: screenWidth / 3.5,
                                //                     child: SingleChildScrollView(
                                //                       scrollDirection: Axis.horizontal,
                                //                       child: Row(
                                //                         children: [
                                //                           Column(
                                //                             crossAxisAlignment: CrossAxisAlignment.start,
                                //                             children: [
                                //                               CustomText(
                                //                                 text: "",
                                //                                 colors: colorsConst.textColor,
                                //                                 isBold: true,
                                //                                 size: 16,
                                //                                 isCopy: true,
                                //                               ),
                                //                               20.height,
                                //                               utils.leadText(
                                //                                   text: "Additional Notes",
                                //                                   color: colorsConst.primary),
                                //                               20.height,
                                //                               utils.leadText(
                                //                                   text: "Response Priority",
                                //                                   color: colorsConst.primary),
                                //                               20.height,
                                //                               utils.leadText(
                                //                                   text: _formatHeading(controllers
                                //                                       .getUserHeading("arpu_value") ??
                                //                                       "ARPU Value"),
                                //                                   color: colorsConst.primary),
                                //                               20.height,
                                //                               utils.leadText(
                                //                                   text:
                                //                                   _formatHeading(controllers.getUserHeading(
                                //                                       "expected_convertion_date") ??
                                //                                       "Expected Conversion Date"),
                                //                                   color: colorsConst.primary),
                                //                               20.height,
                                //                               utils.leadText(
                                //                                   text: _formatHeading(controllers
                                //                                       .getUserHeading(
                                //                                       "prospect_enrollment_date") ??
                                //                                       "Prospect Enrollment Date"),
                                //                                   color: colorsConst.primary),
                                //                               10.height,
                                //                               utils.leadText(
                                //                                   text: _formatHeading(controllers
                                //                                       .getUserHeading("source") ??
                                //                                       "SOURCE OF PROSPECT"),
                                //                                   color: colorsConst.primary),
                                //                               20.height,
                                //                               utils.leadText(
                                //                                   text: _formatHeading(controllers
                                //                                       .getUserHeading("status_update") ??
                                //                                       "Status Update"),
                                //                                   color: colorsConst.primary),
                                //                               25.height,
                                //                             ],
                                //                           ),
                                //                           20.width,
                                //                           Column(
                                //                             crossAxisAlignment: CrossAxisAlignment.start,
                                //                             children: [
                                //                               CustomText(
                                //                                 text: "",
                                //                                 colors: colorsConst.textColor,
                                //                                 isBold: true,
                                //                                 size: 16,
                                //                                 isCopy: true,
                                //                               ),
                                //                               20.height,
                                //                               utils.leadText(
                                //                                   text: widget.notes ?? "",
                                //                                   color: colorsConst.textColor),
                                //                               20.height,
                                //                               utils.leadText(
                                //                                   text:"Normal",
                                //                                   color: colorsConst.textColor),
                                //                               20.height,
                                //                               utils.leadText(
                                //                                   text: cust?.arpuValue ?? "",
                                //                                   color: colorsConst.textColor),
                                //                               20.height,
                                //                               utils.leadText(
                                //                                   text: cust?.expectedConvertionDate ?? "",
                                //                                   color: colorsConst.textColor),
                                //                               20.height,
                                //                               utils.leadText(
                                //                                   text: cust?.prospectEnrollmentDate ?? "",
                                //                                   color: colorsConst.textColor),
                                //                               20.height,
                                //                               utils.leadText(
                                //                                   text: cust?.source ?? "",
                                //                                   color: colorsConst.textColor),
                                //                               20.height,
                                //                               Tooltip(
                                //                                 message: cust?.statusUpdate ?? "",
                                //                                 child: utils.leadText(
                                //                                     text: cust?.statusUpdate ?? "",
                                //                                     color: colorsConst.textColor),
                                //                               ),
                                //                               25.height,
                                //                             ],
                                //                           ),
                                //                         ],
                                //                       ),
                                //                     ),
                                //                   ),
                                //                   20.width
                                //                 ],
                                //               ),
                                //             ],
                                //           ),
                                //         ),
                                //       ],
                                //     ),
                                //     10.width,
                                //     Column(
                                //       crossAxisAlignment: CrossAxisAlignment.start,
                                //       mainAxisAlignment: MainAxisAlignment.start,
                                //       children: [
                                //         if (additional.isNotEmpty)
                                //           SizedBox(
                                //             width: screenWidth / 4.5,
                                //             child: Column(
                                //               crossAxisAlignment: CrossAxisAlignment.start,
                                //               children: [
                                //                 CustomText(
                                //                   text: "Additional Information",
                                //                   colors: colorsConst.textColor,
                                //                   isBold: true,
                                //                   size: 16,
                                //                   isCopy: true,
                                //                 ),
                                //                 20.height,
                                //                 ...additional.map((info) => Padding(
                                //                   padding: const EdgeInsets.only(bottom: 15),
                                //                   child: Row(
                                //                     crossAxisAlignment:
                                //                     CrossAxisAlignment.start,
                                //                     children: [
                                //                       utils.leadText(
                                //                           text: info.fieldName ?? "",
                                //                           color: colorsConst.primary),
                                //                       10.width,
                                //                       utils.leadText(
                                //                           text: info.fieldValue ?? "",
                                //                           color: colorsConst.textColor),
                                //                     ],
                                //                   ),
                                //                 )),
                                //               ],
                                //             ),
                                //           ),
                                //         20.height,
                                //         if(calls.isNotEmpty||meetings.isNotEmpty||meetings.isNotEmpty)
                                //         CustomText(text:"Customer Journey", isCopy: false,isBold: true,colors: colorsConst.primary,size: 16,),
                                //         if (calls.isNotEmpty) ...[
                                //           SizedBox(
                                //               width: screenWidth / 4.5,
                                //               child: _buildCallRecords(calls)),
                                //           20.height,
                                //         ],
                                //         if (meetings.isNotEmpty) ...[
                                //           SizedBox(
                                //               width: screenWidth / 4.5,
                                //               child: _buildMeetingRecords(meetings)),
                                //           20.height,
                                //         ],
                                //         if (reminders.isNotEmpty) ...[
                                //           SizedBox(
                                //               width: screenWidth / 4.5,
                                //               child: _buildReminderRecords(reminders)),
                                //           20.height,
                                //         ]
                                //       ],
                                //     )
                                //   ],
                                // ),
                                40.height,
                              ],
                            ),
                          ),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(child: SvgPicture.asset("assets/images/noDataFound.svg",width: 100,height: 100,)),
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

  String getInitials(String text) {
    if (text.trim().isEmpty) return "";

    List<String> words = text.trim().split(" ");

    if (words.length >= 2) {
      return "${words[0][0]}${words[1][0]}".toUpperCase();
    } else {
      return words[0][0].toUpperCase();
    }
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(text:c.createdBy ?? "", size: 12,colors: Colors.black,isCopy: false,isBold: true,),
                  Row(
                    children: [
                      Expanded(child: Text("${c.callType ?? ''} • ${c.callStatus ?? ''}", style: TextStyle(fontSize: 13))),
                      Text(c.sentDate ?? "", style: TextStyle(fontSize: 12)),
                      10.width,
                      Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                    ],
                  ),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(text:m.createdBy ?? "", size: 12,colors: Colors.black,isCopy: false,isBold: true,),
                  Row(
                    children: [
                      Expanded(child: Text("${m.title ?? ''} • ${m.status ?? ''}", style: TextStyle(fontSize: 13))),
                      Text(m.dates ?? "", style: TextStyle(fontSize: 12)),
                      10.width,
                      Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                    ],
                  ),
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
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CustomText(text:"Employee : ", size: 12,colors: Colors.grey,isCopy: false,),
                          CustomText(text:r.employee ?? "", size: 12,colors: Colors.black,isCopy: false,isBold: true,),
                        ],
                      ),
                      CustomText(text:r.createdBy ?? "", size: 12,colors: Colors.black,isCopy: false,isBold: true,),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: Text("${r.title ?? ''} • ${r.setType ?? ''}", style: TextStyle(fontSize: 13))),
                      Text(r.startDt ?? "", style: TextStyle(fontSize: 12)),
                      10.width,
                      Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                    ],
                  ),
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

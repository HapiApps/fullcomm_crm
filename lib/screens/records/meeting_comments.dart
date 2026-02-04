import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fullcomm_crm/models/all_customers_obj.dart';
import 'package:fullcomm_crm/services/api_services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import '../../common/constant/colors_constant.dart';
import '../../common/utilities/utils.dart';
import '../../components/custom_date_box.dart';
import '../../components/custom_loading_button.dart';
import '../../components/custom_search_textfield.dart';
import '../../components/custom_text.dart';
import '../../components/custom_textfield.dart';
import '../../components/date_filter_bar.dart';
import '../../components/keyboard_search.dart';
import '../../controller/controller.dart';
import '../../controller/reminder_controller.dart';


class MeetingComments extends StatefulWidget {
  const MeetingComments({super.key});

  @override
  State<MeetingComments> createState() => _MeetingCommentsState();
}

class _MeetingCommentsState extends State<MeetingComments> {
  bool dateCheck() {
    return controllers.stDate.value !=
        "${DateTime.now().day.toString().padLeft(2, "0")}"
            "-${DateTime.now().month.toString().padLeft(2, "0")}"
            "-${DateTime.now().year.toString()}";
  }

  String searchText = "";
  late FocusNode _focusNode;
  final ScrollController _controller = ScrollController();
  String formatFirstDate(String input) {
    try {
      List<String> parts = input.split("||").map((e) => e.trim()).toList();
      String datePart = parts.isNotEmpty ? parts.first : "";
      String? timePart;
      if (parts.length >= 2) {
        for (String p in parts.reversed) {
          if (p.contains(':') ||
              p.toLowerCase().contains('am') ||
              p.toLowerCase().contains('pm')) {
            timePart = p;
            break;
          }
        }
      }
      datePart = datePart.replaceAll('.', '-');
      String combined = timePart != null && timePart.isNotEmpty
          ? "$datePart $timePart"
          : datePart;
      DateTime parsedDate;
      if (combined.contains(':') ||
          combined.toLowerCase().contains('am') ||
          combined.toLowerCase().contains('pm')) {
        parsedDate = DateFormat("dd-MM-yyyy h:mm a").parse(combined);
        return DateFormat("dd-MM-yyyy h:mm a").format(parsedDate);
      } else {
        parsedDate = DateFormat("dd-MM-yyyy").parse(combined);
        return DateFormat("dd-MM-yyyy").format(parsedDate);
      }
    } catch (e) {
      print("Error parsing: $e");
      return "";
    }
  }
  List<double> colWidths = [
    50,   // 0 Checkbox
    80,  // 1 Actions
    150,  // 2 Event Name
    150,  // 3 Type
    150,  // 4 Location
    150,  // 5 Employee Name
    150,  // 6 Customer Name
    150,  // 7 Start Date
  ];
  Widget headerCell(int index, Widget child) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          alignment: index==0?Alignment.center:Alignment.centerLeft,
          child: child,
        ),
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          width: 10,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragUpdate: (details) {
              setState(() {
                colWidths[index] += details.delta.dx;
                if (colWidths[index] < 60) colWidths[index] = 60;
              });
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.resizeColumn,
              child: Container(color: Colors.transparent),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    Future.delayed(Duration.zero,(){
      apiService.currentVersion();
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
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          controllers.selectedIndex.value = controllers.oldIndex.value;
        }
      },
      child: SelectionArea(
        child: Scaffold(
          body: Container(
            width: MediaQuery.of(context).size.width - 150,
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.center,
            padding: EdgeInsets.fromLTRB(16, 5, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: "Appointments",
                          colors: colorsConst.textColor,
                          size: 20,
                          isBold: true,
                          isCopy: true,
                        ),
                        5.height,
                        CustomText(
                          text: "View all Appointment Activity Report ",
                          colors: colorsConst.textColor,
                          size: 14,
                          isCopy: true,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 40,
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.calendar_today,color: Colors.white,),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorsConst.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        onPressed: (){
                          controllers.fDate.value = "";
                          controllers.fTime.value = "";
                          controllers.toDate.value = "";
                          controllers.toTime.value = "";

                          setState(() {
                            controllers.clearSelectedCustomer();
                            controllers.cusController.text = "";
                            controllers.callType = "Outgoing";
                            controllers.callStatus = "Contacted";
                          });
                          controllers.callCommentCont.text = "";
                          controllers.meetingTitleCrt.text = "";
                          controllers.meetingVenueCrt.text = "";
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) {
                                var titleError;
                                var venueError;
                                var stDateError;
                                var enDateError;
                                var stTimeError;
                                var enTimeError;
                                var customerError;
                                return StatefulBuilder(
                                    builder: (context,setState){
                                      return AlertDialog(
                                        title: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            CustomText(
                                              text: "New Appointment",
                                              size: 14,
                                              isBold: true,
                                              isCopy: true,
                                              colors: colorsConst.textColor,
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
                                          height: 460,
                                          child: SingleChildScrollView(
                                            child: Column(
                                              children: [
                                                CustomTextField(
                                                  hintText: "Appointment Title",
                                                  text: "Appointment Title",
                                                  controller: controllers.meetingTitleCrt,
                                                  width: 480,
                                                  keyboardType: TextInputType.text,
                                                  textInputAction: TextInputAction.next,
                                                  isOptional: true,
                                                  errorText: titleError,
                                                  onChanged: (value) {
                                                    if (value.toString().isNotEmpty) {
                                                      setState(() {
                                                        titleError = null;
                                                      });
                                                    }
                                                  },
                                                ),
                                                CustomTextField(
                                                  hintText: "Appointment Venue",
                                                  text: "Appointment Venue",
                                                  controller: controllers.meetingVenueCrt,
                                                  width: 480,
                                                  keyboardType: TextInputType.text,
                                                  textInputAction: TextInputAction.next,
                                                  isOptional: true,
                                                  errorText: venueError,
                                                  onChanged: (value) {
                                                    if (value.toString().isNotEmpty) {
                                                      setState(() {
                                                        venueError = null; // clear error on typing
                                                      });
                                                    }
                                                  },
                                                ),
                                                Row(
                                                  //mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Obx(() => CustomDateBox(
                                                      text: "From Date",
                                                      value: controllers.fDate.value,
                                                      isOptional: true,
                                                      errorText: stDateError,
                                                      width: 230,
                                                      onTap: () {
                                                        utils.datePicker(
                                                            context: context,
                                                            textEditingController: controllers.dateOfConCtr,
                                                            pathVal: controllers.fDate);
                                                        if (stDateError != null) {
                                                          setState(() {
                                                            stDateError = null; // clear error on typing
                                                          });
                                                        }
                                                      },
                                                    ),
                                                    ),
                                                    19.width,
                                                    Obx(() => CustomDateBox(
                                                      text: "From Time",
                                                      isOptional: true,
                                                      value: controllers.fTime.value,
                                                      width: 230,
                                                      errorText: stTimeError,
                                                      onTap: () {
                                                        utils.timePicker(
                                                            context: context,
                                                            textEditingController:
                                                            controllers.timeOfConCtr,
                                                            pathVal: controllers.fTime);
                                                        if (stTimeError != null) {
                                                          setState(() {
                                                            stTimeError = null; // clear error on typing
                                                          });
                                                        }
                                                      },
                                                    ),
                                                    ),
                                                  ],
                                                ),
                                                10.height,
                                                Row(
                                                  //mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Obx(() => CustomDateBox(
                                                      text: "To Date",
                                                      isOptional: true,
                                                      value: controllers.toDate.value,
                                                      width: 230,
                                                      errorText: enDateError,
                                                      onTap: () {
                                                        utils.datePicker(
                                                            context: context,
                                                            textEditingController:
                                                            controllers.dateOfConCtr,
                                                            pathVal: controllers.toDate);
                                                        if (enDateError != null) {
                                                          setState(() {
                                                            enDateError = null; // clear error on typing
                                                          });
                                                        }
                                                      },
                                                    ),
                                                    ),
                                                    19.width,
                                                    Obx(() => CustomDateBox(
                                                      text: "To Time",
                                                      isOptional: true,
                                                      value: controllers.toTime.value,
                                                      errorText: enTimeError,
                                                      width: 230,
                                                      onTap: () {
                                                        utils.timePicker(
                                                            context: context,
                                                            textEditingController:
                                                            controllers.timeOfConCtr,
                                                            pathVal: controllers.toTime);
                                                        if (enTimeError != null) {
                                                          setState(() {
                                                            enTimeError = null; // clear error on typing
                                                          });
                                                        }
                                                      },
                                                    ),
                                                    ),
                                                  ],
                                                ),
                                                10.height,
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        CustomText(
                                                          text:"Customer Name",
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
                                                    SizedBox(
                                                      width: 480,
                                                      height: 50,
                                                      child: KeyboardDropdownField<AllCustomersObj>(
                                                        items: controllers.customers,
                                                        borderRadius: 5,
                                                        borderColor: Colors.grey.shade300,
                                                        hintText: "Customers",
                                                        labelText: "",
                                                        labelBuilder: (customer) =>'${customer.name}${customer.companyName.isEmpty ? "" : " ,${customer.companyName}"} ${customer.name.isEmpty?"":"-"} ${customer.phoneNo}',
                                                        itemBuilder: (customer) =>
                                                            Container(
                                                              width: 300,
                                                              alignment: Alignment.topLeft,
                                                              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                                              child: CustomText(
                                                                text: '${customer.name}${customer.companyName.isEmpty ? "" : " ,${customer.companyName}"} ${customer.name.isEmpty?"":"-"} ${customer.companyName}',
                                                                colors: Colors.black,
                                                                size: 14,
                                                                isCopy: false,
                                                                textAlign: TextAlign.start,
                                                              ),
                                                            ),
                                                        textEditingController: controllers.cusController,
                                                        onSelected: (value) {
                                                          customerError = null;
                                                          controllers.selectCustomer(value);
                                                          print("mail ${value.email}");
                                                        },
                                                        onClear: () {
                                                          controllers.clearSelectedCustomer();
                                                        },
                                                      ),
                                                    ),
                                                    if (customerError != null)
                                                      Padding(
                                                        padding: const EdgeInsets.only(top: 4.0),
                                                        child: Text(
                                                          customerError!,
                                                          style: const TextStyle(
                                                              color: Colors.red,
                                                              fontSize: 13),
                                                        ),
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
                                                          enabledBorder: OutlineInputBorder(
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
                                                      colors: colorsConst.primary,
                                                      size: 14,
                                                      isCopy: false,
                                                    )),
                                              ),
                                              10.width,
                                              CustomLoadingButton(
                                                callback: (){
                                                  if(controllers.meetingTitleCrt.text.isEmpty){
                                                    controllers.productCtr.reset();
                                                    setState(() {
                                                      titleError = "Please Enter Appointment Title";
                                                    });
                                                    return;
                                                  }
                                                  if(controllers.meetingVenueCrt.text.isEmpty){
                                                    controllers.productCtr.reset();
                                                    setState(() {
                                                      venueError = "Please Enter Appointment Venue";
                                                    });
                                                    return;
                                                  }
                                                  if(controllers.fDate.value.isEmpty){
                                                    controllers.productCtr.reset();
                                                    setState(() {
                                                      stDateError = "Please Enter From Date";
                                                    });
                                                    return;
                                                  }
                                                  if(controllers.fTime.value.isEmpty){
                                                    controllers.productCtr.reset();
                                                    setState(() {
                                                      stTimeError = "Please Enter From Time";
                                                    });
                                                    return;
                                                  }
                                                  if(controllers.toDate.value.isEmpty){
                                                    controllers.productCtr.reset();
                                                    setState(() {
                                                      enDateError = "Please Enter To Date";
                                                    });
                                                    return;
                                                  }
                                                  if(controllers.toTime.value.isEmpty){
                                                    controllers.productCtr.reset();
                                                    setState(() {
                                                      enTimeError = "Please Enter To Time";
                                                    });
                                                    return;
                                                  }
                                                  if(controllers.selectedCustomerId.value.isEmpty){
                                                    controllers.productCtr.reset();
                                                    setState(() {
                                                      customerError = "Please Enter Customer";
                                                    });
                                                    return;
                                                  }
                                                  apiService.insertMeetingDetailsAPI(context);
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
                                    });
                              });
                        },
                        label: CustomText(
                          text: "New Appointment",
                          colors: Colors.white,
                          size: 14,
                          isCopy: false,
                        ),),
                    )
                  ],
                ),
                10.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Obx(()=> utils.selectHeatingType("Scheduled",
                            controllers.selectMeetingType.value=="Scheduled", (){
                              controllers.selectMeetingType.value="Scheduled";
                              remController.filterAndSortMeetings(
                                searchText: controllers.searchText.value.toLowerCase(),
                                callType: controllers.selectMeetingType.value,
                                sortField: controllers.sortFieldMeetingActivity.value,
                                sortOrder: controllers.sortOrderMeetingActivity.value,
                              );
                            }, false,controllers.allScheduleMeet),),
                        10.width,
                        Obx(()=>utils.selectHeatingType("Completed",
                            controllers.selectMeetingType.value=="Completed", (){
                              controllers.selectMeetingType.value="Completed";
                              remController.filterAndSortMeetings(
                                searchText: controllers.searchText.value.toLowerCase(),
                                callType: controllers.selectMeetingType.value,
                                sortField: controllers.sortFieldMeetingActivity.value,
                                sortOrder: controllers.sortOrderMeetingActivity.value,
                              );
                            }, false,controllers.allCompletedMeet),),
                        10.width,
                        Obx(()=> utils.selectHeatingType("Cancelled",
                            controllers.selectMeetingType.value=="Cancelled", (){
                              controllers.selectMeetingType.value="Cancelled";
                              remController.filterAndSortMeetings(
                                searchText: controllers.searchText.value.toLowerCase(),
                                callType: controllers.selectMeetingType.value,
                                sortField: controllers.sortFieldMeetingActivity.value,
                                sortOrder: controllers.sortOrderMeetingActivity.value,
                              );
                            }, true,controllers.allCancelled),),
                      ],
                    ),
                    remController.selectedMeetingIds.isNotEmpty?
                    InkWell(
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      onTap: (){
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              content: CustomText(
                                text: "Are you sure delete this Appointment?",
                                size: 16,
                                isBold: true,
                                isCopy: false,
                                colors: colorsConst.textColor,
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
                                      callback: ()async{
                                        remController.deleteMeetingAPI(context);
                                      },
                                      height: 35,
                                      isLoading: true,
                                      backgroundColor: colorsConst.primary,
                                      radius: 2,
                                      width: 80,
                                      controller: controllers.productCtr,
                                      isImage: false,
                                      text: "Delete",
                                      textColor: Colors.white,
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Container(
                        height: 40,
                        width: 100,
                        decoration: BoxDecoration(
                          color: colorsConst.secondary,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child:  Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("assets/images/action_delete.png"),
                            10.width,
                            CustomText(
                              text: "Delete",
                              colors: colorsConst.textColor,
                              size: 14,
                              isBold: true,
                              isCopy: false,
                            ),
                          ],
                        ),
                      ),
                    ):1.width,
                  ],
                ),
                5.height,
                Divider(
                  thickness: 1.5,
                  color: colorsConst.secondary,
                ),
                5.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomSearchTextField(
                      controller: controllers.search,
                      hintText: "Search Name, Customer Name, Company Name",
                      onChanged: (value) {
                        controllers.searchText.value = value.toString().trim();
                        remController.filterAndSortMeetings(
                          searchText: controllers.searchText.value.toLowerCase(),
                          callType: controllers.selectMeetingType.value,
                          sortField: controllers.sortFieldMeetingActivity.value,
                          sortOrder: controllers.sortOrderMeetingActivity.value,
                        );
                      },
                    ),
                    DateFilterBar(
                      selectedSortBy: remController.selectedMeetSortBy,
                      selectedRange: remController.selectedMeetRange,
                      selectedMonth: remController.selectedMeetMonth,
                      focusNode: _focusNode,
                      onDaysSelected: () {
                        remController.filterAndSortMeetings(
                          searchText: controllers.searchText.value.toLowerCase(),
                          callType: controllers.selectMeetingType.value,
                          sortField: controllers.sortFieldMeetingActivity.value,
                          sortOrder: controllers.sortOrderMeetingActivity.value,
                        );
                      },
                      onSelectMonth: () {
                        remController.selectMonth(
                          context,
                          remController.selectedMeetSortBy,
                          remController.selectedMeetMonth,
                              () {
                            remController.filterAndSortMeetings(
                              searchText: controllers.searchText.value.toLowerCase(),
                              callType: controllers.selectMeetingType.value,
                              sortField: controllers.sortFieldMeetingActivity.value,
                              sortOrder: controllers.sortOrderMeetingActivity.value,
                            );
                          },
                        );
                      },
                      onSelectDateRange: (ctx) {
                        remController.showDatePickerDialog(ctx, (pickedRange) {
                          remController.selectedMeetSortBy.value = "Custom Range";
                          remController.selectedMeetRange.value = pickedRange;
                          remController.filterAndSortMeetings(
                            searchText: controllers.searchText.value.toLowerCase(),
                            callType: controllers.selectMeetingType.value,
                            sortField: controllers.sortFieldMeetingActivity.value,
                            sortOrder: controllers.sortOrderMeetingActivity.value,
                          );
                        });
                      },
                    )
                  ],
                ),
                15.height,
                // Table Header
                SizedBox(
                  width: controllers.isLeftOpen.value?MediaQuery.of(context).size.width - 150:MediaQuery.of(context).size.width - 60,
                  child: Table(
                    columnWidths: {
                      for (int i = 0; i < colWidths.length; i++)
                        i: FixedColumnWidth(colWidths[i]),
                    },
                    border: TableBorder(
                      horizontalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                      verticalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                    ),
                    children: [
                      TableRow(
                          decoration: BoxDecoration(
                              color: colorsConst.primary,
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(5),
                                  topRight: Radius.circular(5))),
                          children: [
                            headerCell(0, Obx(() => Checkbox(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(2.0),
                              ),
                              side: WidgetStateBorderSide.resolveWith(
                                    (states) => const BorderSide(width: 1.0, color: Colors.white),
                              ),
                              value: remController.selectedRecordCallIds.length == remController.callFilteredList.length && remController.callFilteredList.isNotEmpty,
                              onChanged: (value) {
                                if (value == true) {
                                  remController.selectAllCalls();
                                } else {
                                  remController.unselectAllCalls();
                                }
                              },
                              activeColor: Colors.white,
                              checkColor: colorsConst.primary,
                            )),),
                            headerCell(1, CustomText(
                              textAlign: TextAlign.left,
                              text: "Actions",//1
                              size: 15,
                              isBold: true,
                              isCopy: true,
                              colors: Colors.white,
                            ),),
                            headerCell(2, Row(
                              children: [
                                CustomText(//1
                                  textAlign: TextAlign.left,
                                  text: "Customer Name",
                                  size: 15,
                                  isBold: true,
                                  isCopy: true,
                                  colors: Colors.white,
                                ),
                                const SizedBox(width: 3),
                                GestureDetector(
                                  onTap: (){
                                    if(controllers.sortFieldMeetingActivity.value=='customerName' && controllers.sortOrderMeetingActivity.value=='asc'){
                                      controllers.sortOrderMeetingActivity.value='desc';
                                    }else{
                                      controllers.sortOrderMeetingActivity.value='asc';
                                    }
                                    controllers.sortFieldMeetingActivity.value='customerName';
                                    remController.filterAndSortMeetings(
                                      searchText: controllers.searchText.value.toLowerCase(),
                                      callType: controllers.selectMeetingType.value,
                                      sortField: controllers.sortFieldMeetingActivity.value,
                                      sortOrder: controllers.sortOrderMeetingActivity.value,
                                    );
                                  },
                                  child: Obx(() => Image.asset(
                                    controllers.sortFieldMeetingActivity.value.isEmpty
                                        ? "assets/images/arrow.png"
                                        : controllers.sortOrderMeetingActivity.value == 'asc'
                                        ? "assets/images/arrow_up.png"
                                        : "assets/images/arrow_down.png",
                                    width: 15,
                                    height: 15,
                                  ),
                                  ),
                                ),
                              ],
                            ),),
                            headerCell(3, Row(
                              children: [
                                CustomText(//2
                                  textAlign: TextAlign.left,
                                  text: "Company name",
                                  isCopy: true,
                                  size: 15,
                                  isBold: true,
                                  colors: Colors.white,
                                ),
                                const SizedBox(width: 3),
                                GestureDetector(
                                  onTap: (){
                                    if(controllers.sortFieldMeetingActivity.value=='companyName' && controllers.sortOrderMeetingActivity.value=='asc'){
                                      controllers.sortOrderMeetingActivity.value='desc';
                                    }else{
                                      controllers.sortOrderMeetingActivity.value='asc';
                                    }
                                    controllers.sortFieldMeetingActivity.value='companyName';
                                    remController.filterAndSortMeetings(
                                      searchText: controllers.searchText.value.toLowerCase(),
                                      callType: controllers.selectMeetingType.value,
                                      sortField: controllers.sortFieldMeetingActivity.value,
                                      sortOrder: controllers.sortOrderMeetingActivity.value,
                                    );
                                  },
                                  child: Obx(() => Image.asset(
                                    controllers.sortFieldMeetingActivity.value.isEmpty
                                        ? "assets/images/arrow.png"
                                        : controllers.sortOrderMeetingActivity.value == 'asc'
                                        ? "assets/images/arrow_up.png"
                                        : "assets/images/arrow_down.png",
                                    width: 15,
                                    height: 15,
                                  ),
                                  ),
                                ),
                              ],
                            ),),
                            headerCell(4, Row(
                              children: [
                                CustomText(
                                  textAlign: TextAlign.left,
                                  text: "Title",
                                  isCopy: true,
                                  size: 15,
                                  isBold: true,
                                  colors: Colors.white,
                                ),
                                const SizedBox(width: 3),
                                GestureDetector(
                                  onTap: (){
                                    if(controllers.sortFieldMeetingActivity.value=='title' && controllers.sortOrderMeetingActivity.value=='asc'){
                                      controllers.sortOrderMeetingActivity.value='desc';
                                    }else{
                                      controllers.sortOrderMeetingActivity.value='asc';
                                    }
                                    controllers.sortFieldMeetingActivity.value='title';
                                    remController.filterAndSortMeetings(
                                      searchText: controllers.searchText.value.toLowerCase(),
                                      callType: controllers.selectMeetingType.value,
                                      sortField: controllers.sortFieldMeetingActivity.value,
                                      sortOrder: controllers.sortOrderMeetingActivity.value,
                                    );
                                  },
                                  child: Obx(() => Image.asset(
                                    controllers.sortFieldMeetingActivity.value.isEmpty
                                        ? "assets/images/arrow.png"
                                        : controllers.sortOrderMeetingActivity.value == 'asc'
                                        ? "assets/images/arrow_up.png"
                                        : "assets/images/arrow_down.png",
                                    width: 15,
                                    height: 15,
                                  ),
                                  ),
                                ),
                              ],
                            ),),
                            headerCell(5,  Row(
                              children: [
                                CustomText(
                                  textAlign: TextAlign.left,
                                  text: "Venue",
                                  isCopy: true,
                                  size: 15,
                                  isBold: true,
                                  colors: Colors.white,
                                ),
                                const SizedBox(width: 3),
                                GestureDetector(
                                  onTap: (){
                                    if(controllers.sortFieldMeetingActivity.value=='venue' && controllers.sortOrderMeetingActivity.value=='asc'){
                                      controllers.sortOrderMeetingActivity.value='desc';
                                    }else{
                                      controllers.sortOrderMeetingActivity.value='asc';
                                    }
                                    controllers.sortFieldMeetingActivity.value='venue';
                                    remController.filterAndSortMeetings(
                                      searchText: controllers.searchText.value.toLowerCase(),
                                      callType: controllers.selectMeetingType.value,
                                      sortField: controllers.sortFieldMeetingActivity.value,
                                      sortOrder: controllers.sortOrderMeetingActivity.value,
                                    );
                                  },
                                  child: Obx(() => Image.asset(
                                    controllers.sortFieldMeetingActivity.value.isEmpty
                                        ? "assets/images/arrow.png"
                                        : controllers.sortOrderMeetingActivity.value == 'asc'
                                        ? "assets/images/arrow_up.png"
                                        : "assets/images/arrow_down.png",
                                    width: 15,
                                    height: 15,
                                  ),
                                  ),
                                ),
                              ],
                            ),),
                            headerCell(6, Row(
                              children: [
                                CustomText(
                                  textAlign: TextAlign.left,
                                  text: "Notes",
                                  isCopy: true,
                                  size: 15,
                                  isBold: true,
                                  colors: Colors.white,
                                ),
                                const SizedBox(width: 3),
                                GestureDetector(
                                  onTap: (){
                                    if(controllers.sortFieldMeetingActivity.value=='notes' && controllers.sortOrderMeetingActivity.value=='asc'){
                                      controllers.sortOrderMeetingActivity.value='desc';
                                    }else{
                                      controllers.sortOrderMeetingActivity.value='asc';
                                    }
                                    controllers.sortFieldMeetingActivity.value='notes';
                                    remController.filterAndSortMeetings(
                                      searchText: controllers.searchText.value.toLowerCase(),
                                      callType: controllers.selectMeetingType.value,
                                      sortField: controllers.sortFieldMeetingActivity.value,
                                      sortOrder: controllers.sortOrderMeetingActivity.value,
                                    );
                                  },
                                  child: Obx(() => Image.asset(
                                    controllers.sortFieldMeetingActivity.value.isEmpty
                                        ? "assets/images/arrow.png"
                                        : controllers.sortOrderMeetingActivity.value == 'asc'
                                        ? "assets/images/arrow_up.png"
                                        : "assets/images/arrow_down.png",
                                    width: 15,
                                    height: 15,
                                  ),
                                  ),
                                ),
                              ],
                            ),),
                            headerCell(7, Row(
                              children: [
                                CustomText(
                                  textAlign: TextAlign.center,
                                  text: "Date",
                                  isCopy: true,
                                  size: 15,
                                  isBold: true,
                                  colors: Colors.white,
                                ),
                                const SizedBox(width: 3),
                                GestureDetector(
                                  onTap: (){
                                    if(controllers.sortFieldMeetingActivity.value=='date' && controllers.sortOrderMeetingActivity.value=='asc'){
                                      controllers.sortOrderMeetingActivity.value='desc';
                                    }else{
                                      controllers.sortOrderMeetingActivity.value='asc';
                                    }
                                    controllers.sortFieldMeetingActivity.value='date';
                                    remController.filterAndSortMeetings(
                                      searchText: controllers.searchText.value.toLowerCase(),
                                      callType: controllers.selectMeetingType.value,
                                      sortField: controllers.sortFieldMeetingActivity.value,
                                      sortOrder: controllers.sortOrderMeetingActivity.value,
                                    );
                                  },
                                  child: Obx(() => Image.asset(
                                    controllers.sortFieldMeetingActivity.value.isEmpty
                                        ? "assets/images/arrow.png"
                                        : controllers.sortOrderMeetingActivity.value == 'asc'
                                        ? "assets/images/arrow_up.png"
                                        : "assets/images/arrow_down.png",
                                    width: 15,
                                    height: 15,
                                  ),
                                  ),
                                ),
                              ],
                            ),)
                          ]),
                    ],
                  ),
                ),
                // Table Body
                Expanded(
                    child: Obx((){
                      return remController.meetingFilteredList.isEmpty?
                      Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height/2,
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                              "assets/images/noDataFound.svg"))
                          :RawKeyboardListener(
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
                        child: ListView.builder(
                          controller: _controller,
                          shrinkWrap: true,
                          physics: const ScrollPhysics(),
                          itemCount: remController.meetingFilteredList.length,
                          itemBuilder: (context, index) {
                            final data = remController.meetingFilteredList[index];
                            return Table(
                              columnWidths: {
                                for (int i = 0; i < colWidths.length; i++)
                                  i: FixedColumnWidth(colWidths[i]),
                              },
                              border: TableBorder(
                                horizontalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                                verticalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                                bottom:  BorderSide(width: 0.5, color: Colors.grey.shade400),
                              ),
                              children:[
                                TableRow(
                                    decoration: BoxDecoration(
                                      color: int.parse(index.toString()) % 2 == 0 ? Colors.white : colorsConst.backgroundColor,
                                    ),
                                    children:[
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Checkbox(
                                          value: remController.isCheckedMeeting(data.id.toString()),
                                          onChanged: (value) {
                                            setState(() {
                                              remController.toggleMeetingSelection(data.id.toString());
                                            });
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            IconButton(
                                                onPressed: (){
                                                  // remController.updateTitleController.text = reminder.title.toString()=="null"?"":reminder.title.toString();
                                                  // remController.updateLocation = reminder.location.toString()=="null"?"":reminder.location.toString();
                                                  // remController.updateDetailsController.text = reminder.details.toString()=="null"?"":reminder.details.toString();
                                                  // remController.updateStartController.text = reminder.startDt.toString()=="null"?"":reminder.startDt.toString();
                                                  // remController.updateEndController.text = reminder.endDt.toString()=="null"?"":reminder.endDt.toString();
                                                  // utils.showUpdateRecordDialog("",context);
                                                },
                                                icon:  SvgPicture.asset(
                                                  "assets/images/a_edit.svg",
                                                  width: 16,
                                                  height: 16,
                                                )),
                                            IconButton(
                                                onPressed: (){
                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return AlertDialog(
                                                        content: CustomText(
                                                          text: "Are you sure delete this Appointment?",
                                                          isCopy: true,
                                                          size: 16,
                                                          isBold: true,
                                                          colors: colorsConst.textColor,
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
                                                                      colors: colorsConst.primary,
                                                                      size: 14,
                                                                      isCopy: false,
                                                                    )),
                                                              ),
                                                              10.width,
                                                              CustomLoadingButton(
                                                                callback: ()async{
                                                                  remController.selectedMeetingIds.add(data.id.toString());
                                                                  remController.deleteMeetingAPI(context);
                                                                },
                                                                height: 35,
                                                                isLoading: true,
                                                                backgroundColor: colorsConst.primary,
                                                                radius: 2,
                                                                width: 80,
                                                                controller: controllers.productCtr,
                                                                isImage: false,
                                                                text: "Delete",
                                                                textColor: Colors.white,
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                                icon: SvgPicture.asset(
                                                  "assets/images/a_delete.svg",
                                                  width: 16,
                                                  height: 16,
                                                ))
                                          ],
                                        ),
                                      ),
                                      Tooltip(
                                        message: data.cusName.toString()=="null"?"":data.cusName.toString(),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: CustomText(
                                            textAlign: TextAlign.left,
                                            text: data.cusName.toString()=="null"?"":data.cusName.toString(),
                                            size: 14,
                                            isCopy: true,
                                            colors:colorsConst.textColor,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: CustomText(
                                          textAlign: TextAlign.left,
                                          text:data.comName.toString()=="null"?"":data.comName.toString(),
                                          size: 14,
                                          isCopy: true,
                                          colors: colorsConst.textColor,
                                        ),
                                      ),
                                      Tooltip(
                                        message: data.title.toString()=="null"?"":data.title.toString(),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: CustomText(
                                            textAlign: TextAlign.left,
                                            isCopy: true,
                                            text: data.title.toString(),
                                            size: 14,
                                            colors:colorsConst.textColor,
                                          ),
                                        ),
                                      ),
                                      Tooltip(
                                        message: data.venue.toString()=="null"?"":data.venue.toString(),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: CustomText(
                                            textAlign: TextAlign.left,
                                            text: data.venue.toString(),
                                            size: 14,
                                            isCopy: true,
                                            colors:colorsConst.textColor,
                                          ),
                                        ),
                                      ),
                                      Tooltip(
                                        message: data.notes.toString()=="null"?"":data.notes.toString(),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: CustomText(
                                            textAlign: TextAlign.left,
                                            text: data.notes.toString(),
                                            isCopy: true,
                                            size: 14,
                                            colors:colorsConst.textColor,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: CustomText(
                                          textAlign: TextAlign.left,
                                          text: formatFirstDate("${data.dates} ${data.time}"),
                                          size: 14,
                                          isCopy: true,
                                          colors: colorsConst.textColor,
                                        ),
                                      ),
                                    ]
                                ),
                              ],
                            );
                          },
                        ),
                      );
                    })
                ),
                20.height,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

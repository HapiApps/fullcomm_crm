import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fullcomm_crm/models/all_customers_obj.dart';
import 'package:fullcomm_crm/services/api_services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/models/comments_obj.dart';
import '../common/constant/colors_constant.dart';
import '../common/utilities/utils.dart';
import '../components/custom_date_box.dart';
import '../components/custom_loading_button.dart';
import '../components/custom_search_textfield.dart';
import '../components/custom_text.dart';
import '../components/custom_textfield.dart';
import '../components/keyboard_search.dart';
import '../controller/controller.dart';

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
      String firstDateString = input.split("||")[0];
      DateTime parsedDate = DateFormat("dd-MM-yyyy").parse(firstDateString);
      return DateFormat("dd MMM yyyy").format(parsedDate);
    } catch (e) {
      return "";
    }
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
                          text: "Meetings",
                          colors: colorsConst.textColor,
                          size: 20,
                          isBold: true,
                        ),
                        5.height,
                        CustomText(
                          text: "View all Meeting Activity Report ",
                          colors: colorsConst.textColor,
                          size: 14,
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
                            controllers.callType = null;
                            controllers.callStatus = null;
                          });
                          controllers.callCommentCont.text = "";
                          controllers.meetingTitleCrt.text = "";
                          controllers.meetingVenueCrt.text = "";
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) {
                                return AlertDialog(
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText(
                                        text: "New Meeting",
                                        size: 14,
                                        isBold: true,
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
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10),
                                          child: CustomTextField(
                                            hintText: "Meeting Title",
                                            text: "Meeting Title",
                                            controller: controllers.meetingTitleCrt,
                                            width: 480,
                                            keyboardType: TextInputType.text,
                                            textInputAction: TextInputAction.next,
                                            isOptional: false,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10),
                                          child: CustomTextField(
                                            hintText: "Meeting Venue",
                                            text: "Meeting Venue",
                                            controller: controllers.meetingVenueCrt,
                                            width: 480,
                                            keyboardType: TextInputType.text,
                                            textInputAction: TextInputAction.next,
                                            isOptional: false,
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Obx(() => CustomDateBox(
                                              text: "From Date",
                                              value: controllers.fDate.value,
                                              width: 230,
                                              onTap: () {
                                                utils.datePicker(
                                                    context: context,
                                                    textEditingController: controllers.dateOfConCtr,
                                                    pathVal: controllers.fDate);
                                              },
                                            ),
                                            ),
                                            15.width,
                                            Obx(() => CustomDateBox(
                                              text: "From Time",
                                              value: controllers.fTime.value,
                                              width: 230,
                                              onTap: () {
                                                utils.timePicker(
                                                    context: context,
                                                    textEditingController:
                                                    controllers.timeOfConCtr,
                                                    pathVal: controllers.fTime);
                                              },
                                            ),
                                            ),
                                          ],
                                        ),
                                        10.height,
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Obx(() => CustomDateBox(
                                              text: "To Date",
                                              value: controllers.toDate.value,
                                              width: 230,
                                              onTap: () {
                                                utils.datePicker(
                                                    context: context,
                                                    textEditingController:
                                                    controllers.dateOfConCtr,
                                                    pathVal: controllers.toDate);
                                              },
                                            ),
                                            ),
                                            15.width,
                                            Obx(() => CustomDateBox(
                                              text: "To Time",
                                              value: controllers.toTime.value,
                                              width: 230,
                                              onTap: () {
                                                utils.timePicker(
                                                    context: context,
                                                    textEditingController:
                                                    controllers.timeOfConCtr,
                                                    pathVal: controllers.toTime);
                                              },
                                            ),
                                            ),
                                          ],
                                        ),
                                        10.height,
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            CustomText(
                                              text:"Customer Name",
                                              colors: colorsConst.textColor,
                                              size: 13,
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
                                                labelBuilder: (customer) =>'${customer.name} ${customer.name.isEmpty?"":"-"} ${customer.phoneNo}',
                                                itemBuilder: (customer) =>
                                                    Container(
                                                      width: 300,
                                                      alignment: Alignment.topLeft,
                                                      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                                      child: CustomText(
                                                        text: '${customer.name} ${customer.name.isEmpty?"":"-"} ${customer.companyName}',
                                                        colors: Colors.black,
                                                        size: 14,
                                                        textAlign: TextAlign.start,
                                                      ),
                                                    ),
                                                textEditingController: controllers.cusController,
                                                onSelected: (value) {
                                                  controllers.selectCustomer(value);
                                                  print("mail ${value.email}");
                                                },
                                                onClear: () {
                                                  controllers.clearSelectedCustomer();
                                                },
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
                                              )),
                                        ),
                                        10.width,
                                        CustomLoadingButton(
                                          callback: (){
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
                        },
                        label: CustomText(
                          text: "New Meeting",
                          colors: Colors.white,
                          size: 14,
                        ),),
                    )
                  ],
                ),
                10.height,
                Row(
                  children: [
                    Obx(()=> utils.selectHeatingType("Scheduled",
                        controllers.selectMeetingType.value=="Scheduled", (){
                          controllers.selectMeetingType.value="Scheduled";
                    }, false,controllers.allScheduleMeet),),
                    10.width,
                    Obx(()=>utils.selectHeatingType("Completed",
                        controllers.selectMeetingType.value=="Completed", (){
                          controllers.selectMeetingType.value="Completed";
                    }, false,controllers.allCompletedMeet),),
                    10.width,
                    Obx(()=> utils.selectHeatingType("Cancelled",
                        controllers.selectMeetingType.value=="Cancelled", (){
                          controllers.selectMeetingType.value="Cancelled";
                    }, true,controllers.allCancelled),)
                  ],
                ),
                5.height,
                Divider(
                  thickness: 1.5,
                  color: colorsConst.secondary,
                ),
                5.height,
                Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CustomSearchTextField(
                      controller: controllers.search,
                      hintText: "Search Name, Customer Name, Company Name",
                      onChanged: (value) {
                        setState(() {
                          searchText = value.toString().trim();
                        });
                      },
                    ),
                    10.width,
                    // Container(
                    //   decoration: BoxDecoration(
                    //       color: colorsConst.secondary,
                    //       borderRadius: BorderRadius.circular(10)),
                    //   child: Row(
                    //     children: [
                    //       IconButton(
                    //           onPressed: () {
                    //             // controllers.isAllContacts.value=true;
                    //             controllers.isCommentsLoading.value = false;
                    //             var data = DateTime.parse(
                    //                     "${controllers.stDate.value.split("-").last}-${controllers.stDate.value.split("-")[1]}-${controllers.stDate.value.split("-").first}")
                    //                 .subtract(const Duration(days: 1));
                    //             controllers.stDate.value =
                    //                 "${data.day.toString().padLeft(2, "0")}"
                    //                 "-${data.month.toString().padLeft(2, "0")}"
                    //                 "-${data.year.toString()}";
                    //             controllers.isCommentsLoading.value = true;
                    //             if (controllers.shortBy.value == "all") {
                    //               controllers.shortBy.value = "";
                    //             }
                    //           },
                    //           hoverColor: Colors.transparent,
                    //           icon: Icon(Icons.arrow_back_ios,
                    //               size: 17, color: colorsConst.third)),
                    //       // ),
                    //       Icon(
                    //         Icons.calendar_today_outlined,
                    //         size: 13,
                    //         color: colorsConst.textColor,
                    //       ),
                    //       InkWell(
                    //         onTap: () {
                    //           if (context.mounted) {
                    //             DateFormat inputFormat =
                    //                 DateFormat("dd-MM-yyyy");
                    //             DateTime parsedDate = inputFormat
                    //                 .parse(controllers.stDate.value);
                    //             controllers.dateTime = parsedDate;
                    //             showDatePicker(
                    //               context: context,
                    //               initialDate: controllers.dateTime,
                    //               firstDate: DateTime(2021),
                    //               lastDate: DateTime.now(),
                    //             ).then((value) {
                    //               //controllers.isAllContacts.value=true;
                    //               controllers.dateTime = value!;
                    //               controllers.isCommentsLoading.value = false;
                    //               controllers.stDate.value =
                    //                   "${controllers.dateTime.day.toString().padLeft(2, "0")}"
                    //                   "-${controllers.dateTime.month.toString().padLeft(2, "0")}"
                    //                   "-${controllers.dateTime.year.toString()}";
                    //               controllers.isCommentsLoading.value = true;
                    //               if (controllers.shortBy.value == "all") {
                    //                 controllers.shortBy.value = "";
                    //               }
                    //             });
                    //           }
                    //         },
                    //         child: Container(
                    //           height: 30,
                    //           padding: const EdgeInsets.fromLTRB(6, 2, 4, 2),
                    //           alignment: Alignment.center,
                    //           decoration: BoxDecoration(
                    //               color: colorsConst.secondary,
                    //               borderRadius: BorderRadius.circular(8),
                    //               border: Border.all(
                    //                   color: colorsConst.secondary)),
                    //           child: Obx(
                    //             () => CustomText(
                    //               text: " ${controllers.stDate.value}  ",
                    //               colors: colorsConst.textColor,
                    //               size: 12,
                    //               isBold: true,
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //       // Container(
                    //       //   width:30,
                    //       //   height: 30,
                    //       //   alignment: Alignment.center,
                    //       //   decoration: BoxDecoration(
                    //       //       color: dateCheck()?colorsConst.secondary:colorsConst.primary,
                    //       //       borderRadius: BorderRadius.circular(8),
                    //       //       border: Border.all(
                    //       //           color: colorsConst.secondary
                    //       //       )
                    //       //   ),
                    //       //   child:
                    //       Obx(
                    //         () => IconButton(
                    //             onPressed: () {
                    //               if (dateCheck()) {
                    //                 // controllers.isAllContacts.value=true;
                    //                 controllers.isCommentsLoading.value =
                    //                     false;
                    //                 var data = DateTime.parse(
                    //                         "${controllers.stDate.value.split("-").last}-${controllers.stDate.value.split("-")[1]}-${controllers.stDate.value.split("-").first}")
                    //                     .add(const Duration(days: 1));
                    //                 controllers.stDate.value =
                    //                     "${data.day.toString().padLeft(2, "0")}"
                    //                     "-${data.month.toString().padLeft(2, "0")}"
                    //                     "-${data.year.toString()}";
                    //                 controllers.isCommentsLoading.value =
                    //                     true;
                    //                 if (controllers.shortBy.value == "all") {
                    //                   controllers.shortBy.value = "";
                    //                 }
                    //               }
                    //             },
                    //             hoverColor: Colors.transparent,
                    //             icon: Icon(
                    //               Icons.arrow_forward_ios,
                    //               size: 16,
                    //               color: dateCheck()
                    //                   ? colorsConst.third
                    //                   : Colors.grey,
                    //             )),
                    //       ),
                    //       //)
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
                15.height,

                // Table Header
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(3),//date
                    1: FlexColumnWidth(3.5),//Customer Name
                    2: FlexColumnWidth(2),//Mobile No.
                    3: FlexColumnWidth(3),//Call Type
                    4: FlexColumnWidth(3.5),//Message
                    5: FlexColumnWidth(2.5),//Status
                    6: FlexColumnWidth(4.5),//Actions
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

                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: CustomText(//1
                              textAlign: TextAlign.left,
                              text: "Customer Name",
                              size: 15,
                              isBold: true,
                              colors: Colors.white,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: CustomText(//2
                              textAlign: TextAlign.left,
                              text: "Company name",
                              size: 15,
                              isBold: true,
                              colors: Colors.white,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: CustomText(
                              textAlign: TextAlign.left,
                              text: "Meeting Title",
                              size: 15,
                              isBold: true,
                              colors: Colors.white,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: CustomText(
                              textAlign: TextAlign.left,
                              text: "Notes",
                              size: 15,
                              isBold: true,
                              colors: Colors.white,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: CustomText(//4
                              textAlign: TextAlign.left,
                              text: "Status",
                              size: 15,
                              isBold: true,
                              colors: Colors.white,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: CustomText(
                                  textAlign: TextAlign.center,
                                  text: "Date",
                                  size: 15,
                                  isBold: true,
                                  colors: Colors.white,
                                ),
                              ),
                              // Obx(() => GestureDetector(
                              //   onTap: (){
                              //     controllers.sortField.value = 'date';
                              //     controllers.sortOrder.value = 'asc';
                              //   },
                              //   child: Icon(
                              //     Icons.arrow_upward,
                              //     size: 16,
                              //     color: (controllers.sortField.value == 'date' &&
                              //         controllers.sortOrder.value == 'asc')
                              //         ? Colors.white
                              //         : Colors.grey,
                              //   ),
                              // )),
                              // Obx(() => GestureDetector(
                              //   onTap: (){
                              //     controllers.sortField.value = 'date';
                              //     controllers.sortOrder.value = 'desc';
                              //   },
                              //   child: Icon(
                              //     Icons.arrow_downward,
                              //     size: 16,
                              //     color: (controllers.sortField.value == 'date' &&
                              //         controllers.sortOrder.value == 'desc')
                              //         ? Colors.white
                              //         : Colors.grey,
                              //   ),
                              // )
                              // ),
                            ],
                          ),
                          // Padding(
                          //   padding: const EdgeInsets.all(10.0),
                          //   child: CustomText(//9
                          //     textAlign: TextAlign.center,
                          //     text: "Actions",
                          //     size: 15,
                          //     isBold: true,
                          //     colors: Colors.white,
                          //   ),
                          // ),
                        ]),
                  ],
                ),
                // Table Body
                Expanded(
                    child: Obx((){
                      final searchTexts = searchText.toLowerCase();

                      final filteredList = controllers.meetingActivity.where((activity) {
                        final matchesCallType = controllers.selectMeetingType.value.isEmpty ||
                            activity.status == controllers.selectMeetingType.value;

                        final matchesSearch = searchTexts.isEmpty ||
                            (activity.comName.toString().toLowerCase().contains(searchText) ?? false) ||
                            (activity.cusName.toString().toLowerCase().contains(searchText) ?? false);

                        return matchesCallType && matchesSearch;
                      }).toList();
                      return filteredList.isEmpty?
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          100.height,
                          Center(child: SvgPicture.asset("assets/images/noDataFound.svg")),
                        ],
                      )
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
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            final data = filteredList[index];
                            return Table(
                              columnWidths:const {
                                0: FlexColumnWidth(3),//date
                                1: FlexColumnWidth(3.5),//Customer Name
                                2: FlexColumnWidth(2),//Mobile No.
                                3: FlexColumnWidth(3),//Call Type
                                4: FlexColumnWidth(3.5),//Message
                                5: FlexColumnWidth(2.5),//Status
                                //6: FlexColumnWidth(4.5),//Actions
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
                                      Tooltip(
                                        message: data.cusName.toString()=="null"?"":data.cusName.toString(),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: CustomText(
                                            textAlign: TextAlign.left,
                                            text: data.cusName.toString()=="null"?"":data.cusName.toString(),
                                            size: 14,
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
                                          colors: colorsConst.textColor,
                                        ),
                                      ),
                                      Tooltip(
                                        message: data.title.toString()=="null"?"":data.title.toString(),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: CustomText(
                                            textAlign: TextAlign.left,
                                            text: data.title.toString(),
                                            size: 14,
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
                                            size: 14,
                                            colors:colorsConst.textColor,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: CustomText(
                                          textAlign: TextAlign.left,
                                          text: data.status.toString(),
                                          size: 14,
                                          colors:colorsConst.textColor,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: CustomText(
                                          textAlign: TextAlign.left,
                                          text: formatFirstDate(data.dates.toString()),
                                          size: 14,
                                          colors: colorsConst.textColor,
                                        ),
                                      ),
                                      // Padding(
                                      //   padding: const EdgeInsets.all(3.0),
                                      //   child: Row(
                                      //     mainAxisAlignment: MainAxisAlignment.center,
                                      //     children: [
                                      //       IconButton(
                                      //           onPressed: (){},
                                      //           icon: Icon(Icons.edit,color: Colors.green,)),
                                      //       IconButton(
                                      //           onPressed: (){},
                                      //           icon: SvgPicture.asset("assets/images/add_note.svg")),
                                      //       IconButton(
                                      //           onPressed: (){},
                                      //           icon: Icon(Icons.delete_outline_sharp,color: Colors.red,))
                                      //     ],
                                      //   ),
                                      // ),
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

  bool _isContactMatchingSearch(CommentsObj contact, String searchText) {
    List<String> keywords = searchText.toLowerCase().split(' ');
    String firstName = contact.firstname.toString().toLowerCase();
    String coName = contact.companyName.toString().toLowerCase();
    String customerName = contact.name.toString().toLowerCase();
    String mobile = contact.phoneNo.toString().toLowerCase();
    String comment = contact.comments.toString().toLowerCase();

    return keywords.every((keyword) =>
    firstName.contains(keyword) ||
        coName.contains(keyword) ||
        customerName.contains(keyword) ||
        mobile.contains(keyword) ||
        comment.contains(keyword));
  }

  void countCheck(List<CommentsObj> contact) {
    if (contact.isNotEmpty) {
      var type1Count = contact.where((item) => item.type == "1").length;
      var type2Count = contact.where((item) => item.type == "2").length;
      controllers.allDirectVisit.value = type1Count.toString();
      controllers.allTelephoneCalls.value = type2Count.toString();
    }
  }
}

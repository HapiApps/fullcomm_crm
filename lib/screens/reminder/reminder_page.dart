import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/screens/reminder/reminder_calendar.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../common/constant/colors_constant.dart';
import '../../common/utilities/reminder_utils.dart';
import '../../components/custom_loading_button.dart';
import '../../components/custom_search_textfield.dart';
import '../../components/custom_sidebar.dart';
import '../../components/custom_text.dart';
import '../../components/date_filter_bar.dart';
import '../../controller/controller.dart';
import '../../controller/reminder_controller.dart';
import '../../services/api_services.dart';

class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key});

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  List<double> colWidths = [
    50,   // 0 Checkbox
    80,  // 1 Actions
    150,  // 2 Event Name
    150,  // 3 Type
    150,  // 4 Location
    150,  // 5 Employee Name
    150,  // 6 Customer Name
    150,  // 7 Start Date
    150,  // 8 End Date
    150,  // 9 Details
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
    // initialize santhiya
    Future.delayed(Duration.zero,() {
      remController.sortReminders();
    });
    apiService.getAllEmployees();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SideBar(),
         Obx(()=> Container(
           width:controllers.isLeftOpen.value?MediaQuery.of(context).size.width - 150:MediaQuery.of(context).size.width - 60,
           height: MediaQuery.of(context).size.height,
           alignment: Alignment.center,
           padding: EdgeInsets.fromLTRB(16, 5, 16, 16),
           child: Column(
             children: [
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       CustomText(
                         text: "Reminder",
                         colors: colorsConst.textColor,
                         size: 20,
                         isBold: true,
                         isCopy: true,
                       ),
                       10.height,
                       CustomText(
                         text: "View all of your call activity Report",
                         colors: colorsConst.textColor,
                         size: 14,
                         isCopy: true,
                       ),
                     ],
                   ),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.end,
                     children: [
                      if(controllers.planType.value!="Business Essential"&&controllers.planType.value!="Business Fit")
                       SizedBox(
                         height: 40,
                         child: ElevatedButton(
                           onPressed: (){
                             Navigator.push(
                               context,
                               PageRouteBuilder(
                                 pageBuilder: (context, animation1, animation2) =>
                                 const ReminderCalender(),
                                 transitionDuration: Duration.zero,
                                 reverseTransitionDuration: Duration.zero,
                               ),
                             );
                             },
                           style: ElevatedButton.styleFrom(
                             backgroundColor: const Color(0xff0078D7),
                             padding: const EdgeInsets.symmetric(
                                 horizontal: 20, vertical: 12),
                             shape: RoundedRectangleBorder(
                               borderRadius: BorderRadius.circular(4),
                             ),
                           ),
                           child: Text(
                             'Reminder Calender',
                             style: GoogleFonts.lato(
                               color: Colors.white,
                               fontSize: 14,
                               fontWeight: FontWeight.bold
                             ),
                           ),
                         ),
                       ),10.width,
                       SizedBox(
                         height: 40,
                         child: ElevatedButton(
                           onPressed: (){
                             // Navigator.push(
                             //   context,
                             //   PageRouteBuilder(
                             //     pageBuilder: (context, animation1, animation2) => AddReminder(),
                             //     transitionDuration: Duration.zero,
                             //     reverseTransitionDuration: Duration.zero,
                             //   ),
                             // );
                             reminderUtils.showAddReminderDialog(context);
                           },
                           style: ElevatedButton.styleFrom(
                             backgroundColor: const Color(0xff0078D7),
                             padding: const EdgeInsets.symmetric(
                                 horizontal: 20, vertical: 12),
                             shape: RoundedRectangleBorder(
                               borderRadius: BorderRadius.circular(4),
                             ),
                           ),
                           child: Row(
                             children: [
                               const Icon(Icons.add,color: Colors.white),
                               const SizedBox(width: 5),
                               Text(
                                 'Add Reminder',
                                 style: GoogleFonts.lato(
                                     color: Colors.white,
                                     fontSize: 14,
                                     fontWeight: FontWeight.bold
                                 ),
                               ),
                             ],
                           ),
                         ),
                       ),
                     ],
                   ),
                 ],
               ),
               10.height,
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   Row(
                     children: [
                       CustomText(
                         text: "Follow-up Reminder",
                         colors: colorsConst.primary,
                         isBold: true,
                         size: 15,
                         isCopy: true,
                       ),
                       10.width,
                       CircleAvatar(
                         backgroundColor: colorsConst.primary,
                         radius: 17,
                         child: CustomText(
                           text: remController.followUpReminderCount.value.toString(),
                           colors: Colors.white,
                           isCopy: true,
                           size: 13,
                         ),
                       ),
                       20.width,
                       CustomText(
                         text: "Appointment Reminder",
                         colors: colorsConst.primary,
                         isBold: true,
                         size: 15,
                         isCopy: true,
                       ),
                       10.width,
                       CircleAvatar(
                         backgroundColor: colorsConst.primary,
                         radius: 17,
                         child: CustomText(
                           text: remController.meetingReminderCount.value.toString(),
                           colors: Colors.white,
                           isCopy: true,
                           size: 13,
                         ),
                       ),
                     ],
                   ),
                   remController.selectedReminderIds.isNotEmpty?
                   InkWell(
                     focusColor: Colors.transparent,
                     hoverColor: Colors.transparent,
                     onTap: (){
                       showDialog(
                         context: context,
                         builder: (BuildContext context) {
                           return AlertDialog(
                             content: CustomText(
                               text: "Are you sure delete this reminder?",
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
                                       remController.deleteReminderAPI(context);
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
                   ):1.width
                 ],
               ),
               5.height,
               Divider(
                 thickness: 1.5,
                 color: colorsConst.secondary,
               ),
               10.height,
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   CustomSearchTextField(
                     controller: controllers.search,
                     hintText: "Search Customer Name, Employee Name, Reminder Title",
                     onChanged: (value) {
                       remController.searchText.value = value.toString().trim();
                     },
                   ),
                   DateFilterBar(
                     selectedSortBy: remController.selectedReminderSortBy,
                     selectedRange: remController.selectedReminderRange,
                     selectedMonth: remController.selectedReminderMonth,
                     focusNode: FocusNode(),
                     onDaysSelected: () {
                       remController.sortReminders();
                     },
                     onSelectMonth: () {
                       remController.selectMonth(
                         context,
                         remController.selectedReminderSortBy,
                         remController.selectedReminderMonth,
                             () {
                               remController.sortReminders();
                         },
                       );
                     },
                     onSelectDateRange: (ctx) {
                       remController.showDatePickerDialog(ctx, (pickedRange) {
                         remController.selectedCallRange.value = pickedRange;
                         remController.sortReminders();
                       });
                     },
                   )
                 ],
               ),
               10.height,
               SizedBox(
                 width: controllers.isLeftOpen.value?MediaQuery.of(context).size.width - 150:MediaQuery.of(context).size.width - 60,
                 child: Table(
                   columnWidths: {
                     for (int i = 0; i < colWidths.length; i++)
                       i: FixedColumnWidth(colWidths[i]),
                   },
                   border: TableBorder(
                     horizontalInside: BorderSide(width: 0.5, color: Colors.grey.shade400),
                     verticalInside: BorderSide(width: 0.5, color: Colors.grey.shade400),
                   ),
                   children: [
                     TableRow(
                       decoration: BoxDecoration(
                         color: colorsConst.primary,
                         borderRadius: const BorderRadius.only(
                           topLeft: Radius.circular(5),
                           topRight: Radius.circular(5),
                         ),
                       ),
                       children: [
                         headerCell(0,
                           Checkbox(
                             shape: RoundedRectangleBorder(
                               borderRadius: BorderRadius.circular(2.0),
                             ),
                             side: WidgetStateBorderSide.resolveWith(
                                   (states) => const BorderSide(width: 1.0, color: Colors.white),
                             ),
                             value: remController.selectedReminderIds.length == remController.reminderFilteredList.length &&
                                 remController.reminderFilteredList.isNotEmpty,
                             onChanged: (value) => remController.toggleSelectAllReminder(),
                             activeColor: Colors.white,
                             checkColor: colorsConst.primary,
                           ),
                         ),
                         headerCell(1,
                           CustomText(
                             textAlign: TextAlign.left,
                             text: "Actions",
                             size: 15,
                             isBold: true,
                             isCopy: true,
                             colors: Colors.white,
                           ),
                         ),
                         headerCell(2,
                           Row(
                             children: [
                               CustomText(
                                 text: "Event Name",
                                 size: 15,
                                 isCopy: true,
                                 isBold: true,
                                 colors: Colors.white,
                               ),
                               const SizedBox(width: 3),
                               GestureDetector(
                                 onTap: () {
                                   if (remController.sortFieldCallActivity.value == 'title' &&
                                       remController.sortOrderCallActivity.value == 'asc') {
                                     remController.sortOrderCallActivity.value = 'desc';
                                   } else {
                                     remController.sortOrderCallActivity.value = 'asc';
                                   }
                                   remController.sortFieldCallActivity.value = 'title';
                                   remController.sortReminders();
                                 },
                                 child: Obx(() => Image.asset(
                                   controllers.sortFieldCallActivity.value.isEmpty
                                       ? "assets/images/arrow.png"
                                       : controllers.sortOrderCallActivity.value == 'asc'
                                       ? "assets/images/arrow_up.png"
                                       : "assets/images/arrow_down.png",
                                   width: 15,
                                   height: 15,
                                 )),
                               ),
                             ],
                           ),
                         ),
                         headerCell(3,
                           Row(
                             children: [
                               CustomText(
                                 text: "Type",
                                 size: 15,
                                 isBold: true,
                                 isCopy: true,
                                 colors: Colors.white,
                               ),
                               const SizedBox(width: 3),
                               GestureDetector(
                                 onTap: () {
                                   if (remController.sortFieldCallActivity.value == 'type' &&
                                       remController.sortOrderCallActivity.value == 'asc') {
                                     remController.sortOrderCallActivity.value = 'desc';
                                   } else {
                                     remController.sortOrderCallActivity.value = 'asc';
                                   }
                                   remController.sortFieldCallActivity.value = 'type';
                                   remController.sortReminders();
                                 },
                                 child: Obx(() => Image.asset(
                                   controllers.sortFieldCallActivity.value.isEmpty
                                       ? "assets/images/arrow.png"
                                       : controllers.sortOrderCallActivity.value == 'asc'
                                       ? "assets/images/arrow_up.png"
                                       : "assets/images/arrow_down.png",
                                   width: 15,
                                   height: 15,
                                 )),
                               ),
                             ],
                           ),
                         ),
                         headerCell(4,
                           Row(
                             children: [
                               CustomText(
                                 text: "Location",
                                 size: 15,
                                 isBold: true,
                                 isCopy: true,
                                 colors: Colors.white,
                               ),
                               const SizedBox(width: 3),
                               GestureDetector(
                                 onTap: () {
                                   if (remController.sortFieldCallActivity.value == 'location' &&
                                       remController.sortOrderCallActivity.value == 'asc') {
                                     remController.sortOrderCallActivity.value = 'desc';
                                   } else {
                                     remController.sortOrderCallActivity.value = 'asc';
                                   }
                                   remController.sortFieldCallActivity.value = 'location';
                                   remController.sortReminders();
                                 },
                                 child: Obx(() => Image.asset(
                                   controllers.sortFieldCallActivity.value.isEmpty
                                       ? "assets/images/arrow.png"
                                       : controllers.sortOrderCallActivity.value == 'asc'
                                       ? "assets/images/arrow_up.png"
                                       : "assets/images/arrow_down.png",
                                   width: 15,
                                   height: 15,
                                 )),
                               ),
                             ],
                           ),
                         ),
                         headerCell(5,
                           Row(
                             children: [
                               CustomText(
                                 text: "Employee Name",
                                 size: 15,
                                 isCopy: true,
                                 isBold: true,
                                 colors: Colors.white,
                               ),
                               const SizedBox(width: 3),
                               GestureDetector(
                                 onTap: () {
                                   if (remController.sortFieldCallActivity.value == 'employeeName' &&
                                       remController.sortOrderCallActivity.value == 'asc') {
                                     remController.sortOrderCallActivity.value = 'desc';
                                   } else {
                                     remController.sortOrderCallActivity.value = 'asc';
                                   }
                                   remController.sortFieldCallActivity.value = 'employeeName';
                                   remController.sortReminders();
                                 },
                                 child: Obx(() => Image.asset(
                                   controllers.sortFieldCallActivity.value.isEmpty
                                       ? "assets/images/arrow.png"
                                       : controllers.sortOrderCallActivity.value == 'asc'
                                       ? "assets/images/arrow_up.png"
                                       : "assets/images/arrow_down.png",
                                   width: 15,
                                   height: 15,
                                 )),
                               ),
                             ],
                           ),
                         ),
                         headerCell(6,
                           Row(
                             children: [
                               CustomText(
                                 text: "Customer Name",
                                 size: 15,
                                 isBold: true,
                                 isCopy: true,
                                 colors: Colors.white,
                               ),
                               const SizedBox(width: 3),
                               GestureDetector(
                                 onTap: () {
                                   if (remController.sortBy.value == 'customerName' &&
                                       remController.sortOrderCallActivity.value == 'asc') {
                                     remController.sortOrderCallActivity.value = 'desc';
                                   } else {
                                     remController.sortOrderCallActivity.value = 'asc';
                                   }
                                   remController.sortBy.value = 'customerName';
                                   remController.sortReminders();
                                 },
                                 child: Obx(() => Image.asset(
                                   remController.sortBy.value.isEmpty
                                       ? "assets/images/arrow.png"
                                       : controllers.sortOrderCallActivity.value == 'asc'
                                       ? "assets/images/arrow_up.png"
                                       : "assets/images/arrow_down.png",
                                   width: 15,
                                   height: 15,
                                 )),
                               ),
                             ],
                           ),
                         ),
                         headerCell(7,
                           Row(
                             children: [
                               CustomText(
                                 text: "Start Date",
                                 size: 15,
                                 isBold: true,
                                 isCopy: true,
                                 colors: Colors.white,
                               ),
                               const SizedBox(width: 3),
                               GestureDetector(
                                 onTap: () {
                                   if (remController.sortFieldCallActivity.value == 'startDate' &&
                                       remController.sortOrderCallActivity.value == 'asc') {
                                     remController.sortOrderCallActivity.value = 'desc';
                                   } else {
                                     remController.sortOrderCallActivity.value = 'asc';
                                   }
                                   remController.sortFieldCallActivity.value = 'startDate';
                                   remController.sortReminders();
                                 },
                                 child: Obx(() => Image.asset(
                                   controllers.sortFieldCallActivity.value.isEmpty
                                       ? "assets/images/arrow.png"
                                       : controllers.sortOrderCallActivity.value == 'asc'
                                       ? "assets/images/arrow_up.png"
                                       : "assets/images/arrow_down.png",
                                   width: 15,
                                   height: 15,
                                 )),
                               ),
                             ],
                           ),
                         ),
                         headerCell(8,
                           Row(
                             children: [
                               CustomText(
                                 text: "End Date",
                                 size: 15,
                                 isBold: true,
                                 isCopy: true,
                                 colors: Colors.white,
                               ),
                               const SizedBox(width: 3),
                               GestureDetector(
                                 onTap: () {
                                   if (remController.sortFieldCallActivity.value == 'endDate' &&
                                       remController.sortOrderCallActivity.value == 'asc') {
                                     remController.sortOrderCallActivity.value = 'desc';
                                   } else {
                                     remController.sortOrderCallActivity.value = 'asc';
                                   }
                                   remController.sortFieldCallActivity.value = 'endDate';
                                   remController.sortReminders();
                                 },
                                 child: Obx(() => Image.asset(
                                   controllers.sortFieldCallActivity.value.isEmpty
                                       ? "assets/images/arrow.png"
                                       : controllers.sortOrderCallActivity.value == 'asc'
                                       ? "assets/images/arrow_up.png"
                                       : "assets/images/arrow_down.png",
                                   width: 15,
                                   height: 15,
                                 )),
                               ),
                             ],
                           ),
                         ),
                         headerCell(9,
                           Row(
                             children: [
                               CustomText(
                                 text: "Details",
                                 size: 15,
                                 isBold: true,
                                 isCopy: true,
                                 colors: Colors.white,
                               ),
                               const SizedBox(width: 3),
                               GestureDetector(
                                 onTap: () {
                                   if (remController.sortFieldCallActivity.value == 'details' &&
                                       remController.sortOrderCallActivity.value == 'asc') {
                                     remController.sortOrderCallActivity.value = 'desc';
                                   } else {
                                     remController.sortOrderCallActivity.value = 'asc';
                                   }
                                   remController.sortFieldCallActivity.value = 'details';
                                   remController.sortReminders();
                                 },
                                 child: Obx(() => Image.asset(
                                   controllers.sortFieldCallActivity.value.isEmpty
                                       ? "assets/images/arrow.png"
                                       : controllers.sortOrderCallActivity.value == 'asc'
                                       ? "assets/images/arrow_up.png"
                                       : "assets/images/arrow_down.png",
                                   width: 15,
                                   height: 15,
                                 )),
                               ),
                             ],
                           ),
                         ),

                       ],
                     ),
                   ],
                 ),
               ),
               Expanded(
                 child: Obx(() {
                   final searchText = remController.searchText.value.toLowerCase();
                   final filteredList = remController.reminderFilteredList.where((activity) {
                     final matchesSearch = searchText.isEmpty ||
                         (activity.customerName.toString().toLowerCase().contains(searchText)) ||
                         (activity.employeeName.toString().toLowerCase().contains(searchText)) ||
                         (activity.title.toString().toLowerCase().contains(searchText));
                     return matchesSearch;
                   }).toList();
                   if (remController.isLoadingReminders.value) {
                     return const Center(child: CircularProgressIndicator());
                   }
                   if (filteredList.isEmpty) {
                     return const Center(child: Text("No reminders found"));
                   }
                   return ListView.builder(
                     itemCount: filteredList.length,
                     itemBuilder: (context, index) {
                       final reminder = filteredList[index];
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
                                     value: remController.isCheckedReminder(reminder.id),
                                     onChanged: (value) {
                                       setState(() {
                                         remController.toggleReminderSelection(reminder.id);
                                       });
                                     },
                                   ),
                                 ),
                                 Padding(
                                   padding: const EdgeInsets.all(3.0),
                                   child: Row(
                                     mainAxisAlignment: MainAxisAlignment.start,
                                     children: [
                                       IconButton(
                                           onPressed: (){
                                             remController.updateTitleController.text = reminder.title.toString()=="null"?"":reminder.title.toString();
                                             remController.updateLocation = reminder.location.toString()=="null"?"":reminder.location.toString();
                                             remController.updateDetailsController.text = reminder.details.toString()=="null"?"":reminder.details.toString();
                                             remController.updateStartController.text = reminder.startDt.toString()=="null"?"":reminder.startDt.toString();
                                             remController.updateEndController.text = reminder.endDt.toString()=="null"?"":reminder.endDt.toString();
                                             reminderUtils.showUpdateReminderDialog(reminder.id.toString(),context);
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
                                                     isCopy: true,
                                                     text: "Are you sure delete this reminder?",
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
                                                               isCopy: false,
                                                               colors: colorsConst.primary,
                                                               size: 14,
                                                             )),
                                                       ),
                                                       10.width,
                                                       CustomLoadingButton(
                                                         callback: ()async{
                                                           remController.selectedReminderIds.add(reminder.id.toString());
                                                            remController.deleteReminderAPI(context);
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
                                   message: reminder.title.toString()=="null"?"":reminder.title.toString(),
                                   child: Padding(
                                     padding: const EdgeInsets.all(10.0),
                                     child: CustomText(
                                       isCopy: true,
                                       textAlign: TextAlign.left,
                                       text: reminder.title.toString()=="null"?"":reminder.title.toString(),
                                       size: 14,
                                       colors:colorsConst.textColor,
                                     ),
                                   ),
                                 ),
                                 Padding(
                                     padding: const EdgeInsets.all(10.0),
                                     child: CustomText(
                                       isCopy: true,
                                       textAlign: TextAlign.left,
                                       text: reminder.type.toString()=="1"?"Follow-up":"Appointment",
                                       size: 14,
                                       colors:colorsConst.textColor,
                                     ),
                                   ),
                                 Padding(
                                   padding: const EdgeInsets.all(10.0),
                                   child: CustomText(
                                     isCopy: true,
                                     textAlign: TextAlign.left,
                                     text:reminder.location.toString()=="null"?"":reminder.location.toString(),
                                     size: 14,
                                     colors: colorsConst.textColor,
                                   ),
                                 ),
                                 // Tooltip(
                                 //   message: reminder.repeatType.toString()=="null"?"":reminder.repeatType.toString(),
                                 //   child: Padding(
                                 //     padding: const EdgeInsets.all(10.0),
                                 //     child: CustomText(
                                 //       textAlign: TextAlign.left,
                                 //       text: reminder.repeatType.toString(),
                                 //       size: 14,
                                 //       colors:colorsConst.textColor,
                                 //     ),
                                 //   ),
                                 // ),
                                 Tooltip(
                                   message: reminder.employeeName.toString()=="null"?"":reminder.employeeName.toString(),
                                   child: Padding(
                                     padding: const EdgeInsets.all(10.0),
                                     child: CustomText(
                                       isCopy: true,
                                       textAlign: TextAlign.left,
                                       text: reminder.employeeName.toString(),
                                       size: 14,
                                       colors:colorsConst.textColor,
                                     ),
                                   ),
                                 ),
                                 Tooltip(
                                  message: reminder.customerName.toString()=="null"?"":reminder.customerName.toString(),
                                   child: Padding(
                                     padding: const EdgeInsets.all(10.0),
                                     child: CustomText(
                                       isCopy: true,
                                       textAlign: TextAlign.left,
                                       text: reminder.customerName.toString(),
                                       size: 14,
                                       colors:colorsConst.textColor,
                                     ),
                                   ),
                                 ),
                                 Tooltip(
                                   message: reminder.startDt.toString()=="null"?"":reminder.startDt.toString(),
                                   child: Padding(
                                     padding: const EdgeInsets.all(10.0),
                                     child: CustomText(
                                       isCopy: true,
                                       textAlign: TextAlign.left,
                                       text: controllers.formatDate(reminder.startDt.toString()),
                                       size: 14,
                                       colors:colorsConst.textColor,
                                     ),
                                   ),
                                 ),
                                 Tooltip(
                                   message: reminder.endDt.toString()=="null"?"":reminder.endDt.toString(),
                                   child: Padding(
                                     padding: const EdgeInsets.all(10.0),
                                     child: CustomText(
                                       isCopy: true,
                                       textAlign: TextAlign.left,
                                       text: controllers.formatDate(reminder.endDt.toString()),
                                       size: 14,
                                       colors: colorsConst.textColor,
                                     ),
                                   ),
                                 ),
                                 Tooltip(
                                   message: reminder.details.toString()=="null"?"":reminder.details.toString(),
                                   child: Padding(
                                     padding: const EdgeInsets.all(10.0),
                                     child: CustomText(
                                       isCopy: true,
                                       textAlign: TextAlign.left,
                                       text: reminder.details.toString(),
                                       size: 14,
                                       colors: colorsConst.textColor,
                                     ),
                                   ),
                                 ),
                               ]
                           ),
                         ],
                       );
                     },
                   );
                 }),
               )
             ],
           ),
         ),)
        ],
      ),
    );
  }
}

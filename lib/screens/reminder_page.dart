import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:table_calendar/table_calendar.dart';

import '../common/constant/colors_constant.dart';
import '../common/constant/key_constant.dart';
import '../common/utilities/utils.dart';
import '../components/custom_loading_button.dart';
import '../components/custom_search_textfield.dart';
import '../components/custom_text.dart';
import '../components/custom_textfield.dart';
import '../components/keyboard_search.dart';
import '../controller/controller.dart';
import '../controller/reminder_controller.dart';
import '../models/all_customers_obj.dart';
import '../provider/reminder_provider.dart';
import '../services/api_services.dart';

class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key});

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    apiService.getAllEmployees();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          utils.sideBarFunction(context),
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
                       ),
                       10.height,
                       CustomText(
                         text: "View all of your call activity Report",
                         colors: colorsConst.textColor,
                         size: 14,
                       ),
                     ],
                   ),
                   SizedBox(
                     height: 40,
                     child: ElevatedButton(
                       onPressed: (){
                         utils.showAddReminderDialog(context);
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
               10.height,
               Row(
                 children: [
                   CustomText(
                     text: "Follow-up Reminder",
                     colors: colorsConst.primary,
                     isBold: true,
                     size: 15,
                   ),
                   10.width,
                   CircleAvatar(
                     backgroundColor: colorsConst.primary,
                     radius: 17,
                     child: CustomText(
                       text: remController.followUpReminderCount.value.toString(),
                       colors: Colors.white,
                       size: 13,
                     ),
                   ),
                   20.width,
                   CustomText(
                     text: "Meeting Reminder",
                     colors: colorsConst.primary,
                     isBold: true,
                     size: 15,
                   ),
                   10.width,
                   CircleAvatar(
                     backgroundColor: colorsConst.primary,
                     radius: 17,
                     child: CustomText(
                       text: remController.meetingReminderCount.value.toString(),
                       colors: Colors.white,
                       size: 13,
                     ),
                   ),
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
                           ),
                         ],
                       ),
                     ),
                   ):1.width
                 ],
               ),
               10.height,
               Table(
                 columnWidths: const {
                   0: FlexColumnWidth(1),
                   1: FlexColumnWidth(2),
                   2: FlexColumnWidth(3),//Reminder title
                   3: FlexColumnWidth(2),//Reminder Type
                   4: FlexColumnWidth(2),//Location
                   5: FlexColumnWidth(3),//Employee Name
                   6: FlexColumnWidth(3),//Customer Name
                   7: FlexColumnWidth(3),//Start Date - Time
                   8: FlexColumnWidth(3),//End Date - Time
                   9: FlexColumnWidth(4.5),//Details
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
                           child: CustomText(
                             textAlign: TextAlign.left,
                             text: "S.No",//0
                             size: 15,
                             isBold: true,
                             colors: Colors.white,
                           ),
                         ),
                         Padding(
                           padding: const EdgeInsets.all(10.0),
                           child: CustomText(
                             textAlign: TextAlign.left,
                             text: "Actions",//1
                             size: 15,
                             isBold: true,
                             colors: Colors.white,
                           ),
                         ),
                         Padding(
                           padding: const EdgeInsets.all(10.0),
                           child: CustomText(
                             textAlign: TextAlign.left,
                             text: "Reminder Title",//2
                             size: 15,
                             isBold: true,
                             colors: Colors.white,
                           ),
                         ),
                         Padding(
                           padding: const EdgeInsets.all(10.0),
                           child: CustomText(
                             textAlign: TextAlign.left,
                             text: "Type",//3
                             size: 15,
                             isBold: true,
                             colors: Colors.white,
                           ),
                         ),
                         Padding(
                           padding: const EdgeInsets.all(10.0),
                           child: CustomText(//4
                             textAlign: TextAlign.left,
                             text: "Location",
                             size: 15,
                             isBold: true,
                             colors: Colors.white,
                           ),
                         ),
                         // Padding(
                         //   padding: const EdgeInsets.all(10.0),
                         //   child: CustomText(
                         //     textAlign: TextAlign.left,
                         //     text: "Repeat",
                         //     size: 15,
                         //     isBold: true,
                         //     colors: Colors.white,
                         //   ),
                         // ),
                         Padding(
                           padding: const EdgeInsets.all(10.0),
                           child: Row(
                             children: [
                               CustomText(
                                 textAlign: TextAlign.left,
                                 text: "Employee Name",
                                 size: 15,
                                 isBold: true,
                                 colors: Colors.white,
                               ),
                               const SizedBox(width: 3),
                               GestureDetector(
                                 onTap: (){
                                   if(remController.sortFieldCallActivity.value=='employeeName' && remController.sortOrderCallActivity.value=='asc'){
                                     remController.sortOrderCallActivity.value='desc';
                                   }else{
                                     remController.sortOrderCallActivity.value='asc';
                                   }
                                   remController.sortFieldCallActivity.value='employeeName';
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
                                 ),
                                 ),
                               ),
                             ],
                           ),
                         ),
                         Padding(
                           padding: const EdgeInsets.all(10.0),
                           child: Row(
                             children: [
                               CustomText(//4
                                 textAlign: TextAlign.left,
                                 text: "Customer Name",
                                 size: 15,
                                 isBold: true,
                                 colors: Colors.white,
                               ),
                               const SizedBox(width: 3),
                               GestureDetector(
                                 onTap: (){
                                   if(remController.sortBy.value=='customerName' && remController.sortOrderCallActivity.value=='asc'){
                                     remController.sortOrderCallActivity.value='desc';
                                   }else{
                                     remController.sortOrderCallActivity.value='asc';
                                   }
                                   remController.sortBy.value='customerName';
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
                                 ),
                                 ),
                               ),
                             ],
                           ),
                         ),
                         Padding(
                           padding: const EdgeInsets.all(10.0),
                           child: Row(
                             children: [
                               CustomText(//4
                                 textAlign: TextAlign.left,
                                 text: "Start Date",
                                 size: 15,
                                 isBold: true,
                                 colors: Colors.white,
                               ),
                               const SizedBox(width: 3),
                               GestureDetector(
                                 onTap: (){
                                   if(remController.sortFieldCallActivity.value=='startDate' && remController.sortOrderCallActivity.value=='asc'){
                                     remController.sortOrderCallActivity.value='desc';
                                   }else{
                                     remController.sortOrderCallActivity.value='asc';
                                   }
                                   remController.sortFieldCallActivity.value='startDate';
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
                                 ),
                                 ),
                               ),
                             ],
                           ),
                         ),
                         Row(
                           mainAxisAlignment: MainAxisAlignment.start,
                           children: [
                             Padding(
                               padding: const EdgeInsets.all(10.0),
                               child: Row(
                                 children: [
                                   CustomText(
                                     textAlign: TextAlign.left,
                                     text: "End Date",//6
                                     size: 15,
                                     isBold: true,
                                     colors: Colors.white,
                                   ),
                                   const SizedBox(width: 3),
                                   GestureDetector(
                                     onTap: (){
                                       if(remController.sortFieldCallActivity.value=='endDate' && remController.sortOrderCallActivity.value=='asc'){
                                         remController.sortOrderCallActivity.value='desc';
                                       }else{
                                         remController.sortOrderCallActivity.value='asc';
                                       }
                                       remController.sortFieldCallActivity.value='endDate';
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
                                     ),
                                     ),
                                   ),
                                 ],
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
                         Padding(
                           padding: const EdgeInsets.all(10.0),
                           child: CustomText(//9
                             textAlign: TextAlign.center,
                             text: "Details",
                             size: 15,
                             isBold: true,
                             colors: Colors.white,
                           ),
                         ),
                       ]),
                 ],
               ),

               Expanded(
                 child: Obx(() {
                   final searchText = remController.searchText.value.toLowerCase();
                   final filteredList = remController.reminderList.where((activity) {
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
                         columnWidths:const {
                           0: FlexColumnWidth(1),
                           1: FlexColumnWidth(2),
                           2: FlexColumnWidth(3),//Reminder title
                           3: FlexColumnWidth(2),//Reminder Type
                           4: FlexColumnWidth(2),//Location
                           5: FlexColumnWidth(3),//Employee Name
                           6: FlexColumnWidth(3),//Customer Name
                           7: FlexColumnWidth(3),//Start Date - Time
                           8: FlexColumnWidth(3),//End Date - Time
                           9: FlexColumnWidth(4.5),//Details
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
                                 SizedBox(
                                   width: 50,
                                   child: Row(
                                     children: [
                                       Checkbox(
                                         value: remController.isCheckedReminder(reminder.id),
                                         onChanged: (value) {
                                           setState(() {
                                             remController.toggleReminderSelection(reminder.id);
                                           });
                                         },
                                       ),
                                       CustomText(text: "${index + 1}"),
                                     ],
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
                                             utils.showUpdateReminderDialog(reminder.id.toString(),context);
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
                                                     text: "Are you sure delete this reminder?",
                                                     size: 16,
                                                     isBold: true,
                                                     colors: colorsConst.textColor,
                                                   ),                                                                  actions: [
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
                                       textAlign: TextAlign.left,
                                       text: reminder.type.toString()=="1"?"Follow-up":"Meeting",
                                       size: 14,
                                       colors:colorsConst.textColor,
                                     ),
                                   ),
                                 Padding(
                                   padding: const EdgeInsets.all(10.0),
                                   child: CustomText(
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

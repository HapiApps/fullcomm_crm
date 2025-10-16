import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/controller/settings_controller.dart';
import 'package:fullcomm_crm/screens/settings/add_office_hours.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../common/constant/colors_constant.dart';
import '../../common/utilities/utils.dart';
import '../../components/custom_loading_button.dart';
import '../../components/custom_search_textfield.dart';
import '../../components/custom_text.dart';
import '../../controller/controller.dart';
import '../../controller/reminder_controller.dart';
import '../../services/api_services.dart';

class GeneralSettings extends StatefulWidget {
  const GeneralSettings({super.key});

  @override
  State<GeneralSettings> createState() => _GeneralSettingsState();
}

class _GeneralSettingsState extends State<GeneralSettings> {
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
                      children: [
                        CustomText(
                          text: "General Settings",
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
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.add,color: Colors.white,),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorsConst.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        onPressed: (){
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation1, animation2) =>
                              const AddOfficeHours(),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          );
                        },
                        label: CustomText(
                          text: "Add Office Hours",
                          colors: Colors.white,
                          isBold :true,
                          size: 14,
                        ),),
                    )
                  ],
                ),
                10.height,
                Row(
                  children: [
                    CustomText(
                      text: "Shift",
                      colors: colorsConst.primary,
                      isBold: true,
                      size: 15,
                    ),
                    10.width,
                    CircleAvatar(
                      backgroundColor: colorsConst.primary,
                      radius: 17,
                      child: Obx(()=>CustomText(
                        text: settingsController.officeHoursCount.value.toString(),
                        colors: Colors.white,
                        size: 13,
                      ),)
                    ),
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
                      hintText: "Search Employee Name, Shift Name",
                      onChanged: (value) {
                        settingsController.searchOfficeText.value = value.toString().trim();
                      },
                    ),
                    settingsController.selectedRoleIds.isNotEmpty?
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
                    // 0: FlexColumnWidth(1),//Check Box
                    // 1: FlexColumnWidth(3),//Actions
                    // 2: FlexColumnWidth(2),//Employee
                    // 3: FlexColumnWidth(3),//Shift Name
                    // 4: FlexColumnWidth(2),//From
                    // 5: FlexColumnWidth(2),//To
                    // 6: FlexColumnWidth(2),//days
                    // 7: FlexColumnWidth(2),//Updated On
                    0: FlexColumnWidth(2),//Employee
                    1: FlexColumnWidth(3),//Shift Name
                    2: FlexColumnWidth(2),//From
                    3: FlexColumnWidth(2),//To
                    4: FlexColumnWidth(2),//days
                    5: FlexColumnWidth(2),//Updated On
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
                          // Padding(
                          //   padding: const EdgeInsets.all(10.0),
                          //   child: CustomText(
                          //     textAlign: TextAlign.left,
                          //     text: "S.No",
                          //     size: 15,
                          //     isBold: true,
                          //     colors: Colors.white,
                          //   ),
                          // ),
                          // Padding(
                          //   padding: const EdgeInsets.all(10.0),
                          //   child: CustomText(
                          //     textAlign: TextAlign.left,
                          //     text: "Actions",//0
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
                                  text: "Employee",//1
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
                                CustomText(
                                  textAlign: TextAlign.left,
                                  text: "Shift Name",//2
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
                            child: CustomText(
                              textAlign: TextAlign.left,
                              text: "From",//3
                              size: 15,
                              isBold: true,
                              colors: Colors.white,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: CustomText(
                              textAlign: TextAlign.left,
                              text: "To",//4
                              size: 15,
                              isBold: true,
                              colors: Colors.white,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: CustomText(
                              textAlign: TextAlign.left,
                              text: "Days",//4
                              size: 15,
                              isBold: true,
                              colors: Colors.white,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: CustomText(
                              textAlign: TextAlign.left,
                              text: "Updated On",//4
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
                    final searchText = settingsController.searchOfficeText.value.toLowerCase();
                    final filteredList = settingsController.officeHoursList.where((activity) {
                      final matchesSearch = searchText.isEmpty ||
                          (activity.shiftName.toString().toLowerCase().contains(searchText)) ||
                          (activity.employeeName.toString().toLowerCase().contains(searchText));
                      return matchesSearch;
                    }).toList();
                    if (settingsController.isLoadingOfficeHours.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (filteredList.isEmpty) {
                      return const Center(child: Text("No reminders found"));
                    }
                    return ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final officeHour = filteredList[index];
                        return Table(
                          columnWidths:const {
                            // 0: FlexColumnWidth(1),//Check Box
                            // 1: FlexColumnWidth(3),//Actions
                            // 2: FlexColumnWidth(2),//Employee
                            // 3: FlexColumnWidth(3),//Shift Name
                            // 4: FlexColumnWidth(2),//From
                            // 5: FlexColumnWidth(2),//To
                            // 6: FlexColumnWidth(2),//days
                            // 7: FlexColumnWidth(2),//Updated On
                            0: FlexColumnWidth(2),//Employee
                            1: FlexColumnWidth(3),//Shift Name
                            2: FlexColumnWidth(2),//From
                            3: FlexColumnWidth(2),//To
                            4: FlexColumnWidth(2),//days
                            5: FlexColumnWidth(2),//Updated On
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
                                  // SizedBox(
                                  //   width:100,
                                  //   child: Row(
                                  //     children: [
                                  //       Checkbox(
                                  //         value: true,
                                  //         onChanged: (value) {
                                  //           //employeeProvider.toggleSelectionEmployee(staffId);
                                  //         },
                                  //       ),
                                  //       CustomText(text: "${index + 1}"),
                                  //     ],
                                  //   ),
                                  // ),
                                  // Padding(
                                  //   padding: const EdgeInsets.all(3.0),
                                  //   child: Row(
                                  //     mainAxisAlignment: MainAxisAlignment.start,
                                  //     children: [
                                  //       IconButton(
                                  //           onPressed: (){
                                  //
                                  //             //_showUpdateReminderDialog(reminder.id.toString());
                                  //           },
                                  //           icon:  SvgPicture.asset(
                                  //             "assets/images/a_edit.svg",
                                  //             width: 16,
                                  //             height: 16,
                                  //           )),
                                  //       IconButton(
                                  //           onPressed: (){
                                  //             showDialog(
                                  //               context: context,
                                  //               builder: (BuildContext context) {
                                  //                 return AlertDialog(
                                  //                   content: CustomText(
                                  //                     text: "Are you sure delete this reminder?",
                                  //                     size: 16,
                                  //                     isBold: true,
                                  //                     colors: colorsConst.textColor,
                                  //                   ),                                                                  actions: [
                                  //                   Row(
                                  //                     mainAxisAlignment: MainAxisAlignment.end,
                                  //                     children: [
                                  //                       Container(
                                  //                         decoration: BoxDecoration(
                                  //                             border: Border.all(color: colorsConst.primary),
                                  //                             color: Colors.white),
                                  //                         width: 80,
                                  //                         height: 25,
                                  //                         child: ElevatedButton(
                                  //                             style: ElevatedButton.styleFrom(
                                  //                               shape: const RoundedRectangleBorder(
                                  //                                 borderRadius: BorderRadius.zero,
                                  //                               ),
                                  //                               backgroundColor: Colors.white,
                                  //                             ),
                                  //                             onPressed: () {
                                  //                               Navigator.pop(context);
                                  //                             },
                                  //                             child: CustomText(
                                  //                               text: "Cancel",
                                  //                               colors: colorsConst.primary,
                                  //                               size: 14,
                                  //                             )),
                                  //                       ),
                                  //                       10.width,
                                  //                       CustomLoadingButton(
                                  //                         callback: ()async{
                                  //                           remController.selectedReminderIds.add(officeHour.id.toString());
                                  //                           remController.deleteReminderAPI(context);
                                  //                         },
                                  //                         height: 35,
                                  //                         isLoading: true,
                                  //                         backgroundColor: colorsConst.primary,
                                  //                         radius: 2,
                                  //                         width: 80,
                                  //                         controller: controllers.productCtr,
                                  //                         isImage: false,
                                  //                         text: "Delete",
                                  //                         textColor: Colors.white,
                                  //                       ),
                                  //                     ],
                                  //                   ),
                                  //                 ],
                                  //                 );
                                  //               },
                                  //             );
                                  //           },
                                  //           icon: SvgPicture.asset(
                                  //             "assets/images/a_delete.svg",
                                  //             width: 16,
                                  //             height: 16,
                                  //           ))
                                  //     ],
                                  //   ),
                                  // ),
                                  Tooltip(
                                    message: officeHour.employeeName,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: CustomText(
                                        textAlign: TextAlign.left,
                                        text:officeHour.employeeName,//1
                                        size: 14,
                                        colors:colorsConst.textColor,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: CustomText(
                                      textAlign: TextAlign.left,
                                      text: officeHour.shiftName,//2
                                      size: 14,
                                      colors:colorsConst.textColor,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: CustomText(
                                      textAlign: TextAlign.left,
                                      text:officeHour.fromTime,
                                      size: 14,
                                      colors: colorsConst.textColor,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: CustomText(
                                      textAlign: TextAlign.left,
                                      text:officeHour.toTime,
                                      size: 14,
                                      colors: colorsConst.textColor,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: CustomText(
                                      textAlign: TextAlign.left,
                                      text:officeHour.days,
                                      size: 14,
                                      colors: colorsConst.textColor,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: CustomText(
                                      textAlign: TextAlign.left,
                                      text:controllers.formatDateTime(officeHour.updatedTs),
                                      size: 14,
                                      colors: colorsConst.textColor,
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
          ))
        ],
      ),
    );
  }
}

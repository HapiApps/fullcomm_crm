import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../common/constant/colors_constant.dart';
import '../../common/styles/styles.dart';
import '../../common/utilities/utils.dart';
import '../../components/custom_date_box.dart';
import '../../components/custom_dropdown.dart';
import '../../components/custom_loading_button.dart';
import '../../components/custom_sidebar.dart';
import '../../components/custom_text.dart';
import '../../components/custom_textfield.dart';
import '../../components/keyboard_search.dart';
import '../../controller/controller.dart';
import '../../controller/reminder_controller.dart';
import '../../models/all_customers_obj.dart';
import '../../provider/reminder_provider.dart';
import '../../services/api_services.dart';

class AddReminder extends StatefulWidget {
  const AddReminder({super.key});

  @override
  State<AddReminder> createState() => _AddReminderState();
}

class _AddReminderState extends State<AddReminder> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    apiService.getAllEmployees();
  }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double textFieldSize = (MediaQuery.of(context).size.width - 400) / 1.8;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SideBar(),
          Obx(()=> Container(
            width:controllers.isLeftOpen.value?MediaQuery.of(context).size.width - 150:MediaQuery.of(context).size.width - 60,
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.center,
            padding: EdgeInsets.fromLTRB(20, 5, 20, 16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: "Reminder",
                            colors: colorsConst.textColor,
                            size: 20,
                            isCopy: true,
                            isBold: true,
                          ),
                          10.height,
                          CustomText(
                            text: "Add reminder details and save",
                            colors: colorsConst.textColor,
                            size: 14,
                            isCopy: true,
                          ),
                        ],
                      ),
                      CustomLoadingButton(
                        callback: () async {

                        },
                        height: 40,
                        isLoading: true,
                        backgroundColor: colorsConst.primary,
                        radius: 7,
                        width: 120,
                        controller: controllers.productCtr,
                        isImage: false,
                        text: "Save Reminder...",
                        textColor: Colors.white,
                      ),
                    ],
                  ),
                  Divider(
                    thickness: 1.5,
                    color: colorsConst.secondary,
                  ),
                  8.height,
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:colorsConst.backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child:Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: textFieldSize,
                            child: CustomTextField(
                              hintText: "Enter Event Name",
                              text: "Event Name",
                              controller: remController.titleController,
                              width: textFieldSize,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              isOptional: true,
                              // errorText: nameError,
                              // onChanged: (value) {
                              //   if (value.toString().isNotEmpty) {
                              //     setState(() {
                              //       nameError = null;
                              //     });
                              //   }
                              // },
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              8.height,
                              CustomText(text: "Event Type",
                                colors: colorsConst.fieldHead,
                                size: 13,
                                isCopy: true,
                              ),
                              5.height,
                              Container(
                                width: screenWidth/2.5,
                                height: 40,
                                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: Color(0xffE1E5FA)),
                                ),
                                child: Consumer<ReminderProvider>(
                                  builder: (context, provider, _) {
                                    return Row(
                                      //mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        Row(
                                          children: [
                                            Radio<String>(
                                              value: "followup",
                                              groupValue: provider.selectedNotification,
                                              activeColor: const Color(0xFF0078D7),
                                              onChanged: (v) => provider.setNotification(v!),
                                            ),
                                            CustomText(
                                              text: "Follow-up",
                                              colors: Colors.black,
                                              size: 15,
                                              isCopy: false,
                                            ),
                                          ],
                                        ),
                                        25.width,
                                        Row(
                                          children: [
                                            Radio<String>(
                                              value: "meeting",
                                              groupValue: provider.selectedNotification,
                                              activeColor: const Color(0xFF0078D7),
                                              onChanged: (v) => provider.setNotification(v!),
                                            ),
                                            CustomText(
                                              text: "Appointment",
                                              colors: Colors.black,
                                              size: 15,
                                              isCopy: false,
                                            ),
                                          ],
                                        ),
                                        25.width,
                                        Row(
                                          children: [
                                            Radio<String>(
                                              value: "task",
                                              groupValue: provider.selectedNotification,
                                              activeColor: const Color(0xFF0078D7),
                                              onChanged: (v) => provider.setNotification(v!),
                                            ),
                                            CustomText(
                                              text: "Task",
                                              isCopy: false,
                                              colors: Colors.black,
                                              size: 15,
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),

                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(() => CustomDateBox(
                            text: "Start Date",
                            value: controllers.fDate.value,
                            isOptional: true,
                            //errorText: stDateError,
                            width: screenWidth/4,
                            onTap: () {
                              utils.datePicker(
                                  context: context,
                                  textEditingController: controllers.dateOfConCtr,
                                  pathVal: controllers.fDate);
                              // if (stDateError != null) {
                              //   setState(() {
                              //     stDateError = null; // clear error on typing
                              //   });
                              // }
                            },
                          ),
                          ),
                          Obx(() => CustomDateBox(
                            text: "Start Time",
                            isOptional: true,
                            value: controllers.fTime.value,
                            width: screenWidth/4,
                            //errorText: stTimeError,
                            onTap: () {
                              utils.timePicker(
                                  context: context,
                                  textEditingController:
                                  controllers.timeOfConCtr,
                                  pathVal: controllers.fTime);
                              // if (stTimeError != null) {
                              //   setState(() {
                              //     stTimeError = null; // clear error on typing
                              //   });
                              // }
                            },
                          ),
                          ),
                          CustomDropDown(
                            saveValue: remController.defaultTime,
                            isOptional: true,
                            valueList: ["Immediately", "5 mins", "15 mins", "10 mins", "30 mins"],
                            text: "Event Duration",
                            width: screenWidth/4,
                            onChanged: (value) async {
                              setState(() {
                                remController.defaultTime = value.toString();
                              });
                            },
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: "Details",
                            colors: colorsConst.fieldHead,
                            isCopy: false,
                            size: 13,),
                          5.height,
                          TextFormField(
                              textCapitalization: TextCapitalization.sentences,
                              controller:
                              remController.detailsController,
                              maxLines: 5,
                              style: GoogleFonts.lato(
                                color: Colors.black,
                                fontSize: 17,
                              ),
                              decoration: customStyle.inputDecoration(
                                  text: "Enter Details")
                          ),
                        ],
                      ),
                      20.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomDropDown(
                            saveValue: remController.location,
                            isOptional: false,
                            valueList:["Online", "Office"],
                            text: "Enter Location",
                            width: screenWidth/4,
                            onChanged: (value) async {
                              setState(() {
                                remController.location = value.toString();
                              });
                            },
                          ),
                          SizedBox(
                            width: screenWidth/4,
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CustomText(
                                      text: "Employees",
                                      size: 13,
                                      colors: colorsConst.fieldHead,
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
                                KeyboardDropdownField<AllEmployeesObj>(
                                  items: controllers.employees,
                                  borderRadius: 5,
                                  borderColor: Colors.grey.shade300,
                                  hintText: "Employees",
                                  labelText: "",
                                  labelBuilder: (customer) =>
                                  '${customer.name} ${customer.name.isEmpty ? "" : "-"} ${customer.phoneNo}',
                                  itemBuilder: (customer) {
                                    return Container(
                                      width: 300,
                                      alignment: Alignment.topLeft,
                                      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                      child: CustomText(
                                        text:
                                        '${customer.name} ${customer.name.isEmpty ? "" : "-"} ${customer.phoneNo}',
                                        colors: Colors.black,
                                        size: 14,
                                        isCopy: false,
                                        textAlign: TextAlign.start,
                                      ),
                                    );
                                  },
                                  textEditingController: controllers.empController,
                                  onSelected: (value) {
                                    setState((){
                                      //employeeError=null;
                                    });
                                    controllers.selectEmployee(value);
                                  },
                                  onClear: () {
                                    controllers.clearSelectedCustomer();
                                  },
                                ),
                                // if (employeeError != null)
                                //   Padding(
                                //     padding: const EdgeInsets.only(top: 4.0),
                                //     child: Text(
                                //       employeeError!,
                                //       style: const TextStyle(
                                //           color: Colors.red,
                                //           fontSize: 13),
                                //     ),
                                //   ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: screenWidth/4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CustomText(
                                      text: "Assigned Customer",
                                      size: 13,
                                      isCopy: false,
                                      colors: colorsConst.fieldHead,
                                    ),
                                    const CustomText(
                                      text: "*",
                                      isCopy: false,
                                      colors: Colors.red,
                                      size: 25,
                                    )
                                  ],
                                ),
                                KeyboardDropdownField<AllCustomersObj>(
                                  items: controllers.customers,
                                  borderRadius: 5,
                                  borderColor: Colors.grey.shade300,
                                  hintText: "Customers",
                                  labelText: "",
                                  labelBuilder: (customer) =>
                                  '${customer.name}${customer.companyName.toString().isEmpty ? "" : ", ${customer.companyName}"} ${customer.name.isEmpty ? "" : "-"} ${customer.phoneNo}',
                                  itemBuilder: (customer) {
                                    return Container(
                                      width: 300,
                                      alignment: Alignment.topLeft,
                                      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                      child: CustomText(
                                        text: '${customer.name}${customer.companyName.toString().isEmpty ? "" : ", ${customer.companyName}"} ${customer.name.isEmpty ? "" : "-"} ${customer.phoneNo}',
                                        colors: Colors.black,
                                        size: 14,
                                        isCopy: false,
                                        textAlign: TextAlign.start,
                                      ),
                                    );
                                  },
                                  textEditingController: controllers.cusController,
                                  onSelected: (value) {
                                    // setState((){
                                    //   customerError=null;
                                    // });
                                    controllers.selectCustomer(value);
                                  },
                                  onClear: () {
                                    controllers.clearSelectedCustomer();
                                  },
                                ),
                                // if (customerError != null)
                                //   Padding(
                                //     padding:
                                //     const EdgeInsets.only(top: 4.0),
                                //     child: Text(
                                //       customerError!,
                                //       style: const TextStyle(
                                //           color: Colors.red,
                                //           fontSize: 13),
                                //     ),
                                //   ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          CustomDropDown(
                            saveValue: remController.location,
                            isOptional: false,
                            valueList:["Every", "Never","Daily", "Weekly", "Bi-Weekly", "Monthly", "Quarterly", "Half Yearly", "Yearly"],
                            text: "Repeat",
                            width: screenWidth/4,
                            onChanged: (value) async {
                              setState(() {
                                remController.location = value.toString();
                              });
                            },
                          ),
                          CustomDropDown(
                            saveValue: remController.location,
                            isOptional: false,
                            valueList:["1", "2","3", "4", "5", "6", "7", "8", "9", "10","11","12"],
                            text: "Repeat Every",
                            width: screenWidth/4,
                            onChanged: (value) async {
                              setState(() {
                                remController.location = value.toString();
                              });
                            },
                          ),
                          CustomDropDown(
                            saveValue: remController.location,
                            isOptional: false,
                            valueList:["Day", "Week","Month","Quarter", "Year","Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"],
                            text: "Repeat On",
                            width: screenWidth/4,
                            onChanged: (value) async {
                              setState(() {
                                remController.location = value.toString();
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                20.height,
                  Obx(() => ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: remController.reminders.length + 1,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          if (index == remController.reminders.length) {
                            return InkWell(
                              onTap: remController.addReminder,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(Icons.add_circle_outline, color: Colors.blue),
                                  6.width,
                                  CustomText(
                                    text: "Add More Reminder",
                                    colors: colorsConst.textColor,
                                    isCopy: false,
                                  ),
                                ],
                              ),
                            );
                          }
                          return reminderCard(index);
                        },
                      ),
                    ),
                ],
              ),
            ),
          ))
        ],
      ),
    );
  }
  Widget reminderCard(int index){
    final reminder = remController.reminders[index];
    return  Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:colorsConst.backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Reminder ${index + 1}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (index != 0)
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => remController.removeReminder(index),
                ),
            ],
          ),
          12.height,
          CustomTextField(
            hintText: "Enter Reminder Title",
            text: "Reminder Title",
            controller: reminder.titleController,
            width:MediaQuery.of(context).size.width-100,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            isOptional: true,
            // errorText: nameError,
            // onChanged: (value) {
            //   if (value.toString().isNotEmpty) {
            //     setState(() {
            //       nameError = null;
            //     });
            //   }
            // },
          ),
          const Text(
            "Remind Via",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          8.height,
          Obx(() => Wrap(
            spacing: 12,
            runSpacing: 4,
            children: reminder.remindVia.entries.map((entry) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: entry.value.value,
                    onChanged: (val) {
                      entry.value.value = val!;
                    },
                  ),
                  Text(entry.key),
                ],
              );
            }).toList(),
          ),
          ),
          12.height,
          const Text(
            "Before",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Obx(() => Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              for (var option in [
                "1 Min",
                "5 Mins",
                "15 Mins",
                "30 Mins",
                "1 Hr",
                "2 Hrs",
                "Other"
              ])
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Radio<String>(
                      value: option,
                      groupValue: reminder.selectedTime.value,
                      onChanged: (val) {
                        reminder.selectedTime.value = val!;
                      },
                    ),
                    Text(option),
                    if (option == "Other" &&
                        reminder.selectedTime.value == "Other")
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: DropdownButton<String>(
                          value: reminder.customTime.value,
                          items: reminder.otherTimes
                              .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          ))
                              .toList(),
                          onChanged: (val) {
                            reminder.customTime.value = val!;
                          },
                        ),
                      ),
                  ],
                ),
            ],
          ),
          ),
        ],
      ),
    );
  }
}

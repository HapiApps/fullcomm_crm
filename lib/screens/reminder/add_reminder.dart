import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../common/constant/colors_constant.dart';
import '../../common/utilities/utils.dart';
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
    double textFieldSize = (MediaQuery.of(context).size.width - 400) / 1.8;
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
                      children: [
                        CustomText(
                          text: "Reminder",
                          colors: colorsConst.textColor,
                          size: 20,
                          isBold: true,
                        ),
                        10.height,
                        CustomText(
                          text: "Add reminder details and save",
                          colors: colorsConst.textColor,
                          size: 14,
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
                      text: "Save Reminder",
                      textColor: Colors.white,
                    ),
                  ],
                ),
                Divider(
                  thickness: 1.5,
                  color: colorsConst.secondary,
                ),
                8.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: textFieldSize,
                      child: CustomTextField(
                        hintText: "Template Name",
                        text: "Template Name",
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
                    CustomText(text: "Event Type",
                      colors: colorsConst.headColor,
                      size: 13,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width/2.5,
                      height: 60,
                      child: Consumer<ReminderProvider>(
                        builder: (context, provider, _) {
                          return Row(
                            children: [
                              Expanded(
                                child: RadioListTile(
                                  title: CustomText(
                                    text: "Follow-up",
                                    colors: Colors.black,
                                    size: 15,
                                  ),
                                  value: "followup",
                                  groupValue: provider.selectedNotification,
                                  activeColor: const Color(0xFF0078D7),
                                  onChanged: (v) =>
                                      provider.setNotification(v as String),
                                ),
                              ),
                              Expanded(
                                child: RadioListTile(
                                  title: CustomText(
                                    text: "Appointment",
                                    colors: Colors.black,
                                    size: 15,
                                  ),
                                  value: "meeting",
                                  groupValue: provider.selectedNotification,
                                  activeColor: const Color(0xFF0078D7),
                                  onChanged: (v) =>
                                      provider.setNotification(v as String),
                                ),
                              ),
                              Expanded(
                                child: RadioListTile(
                                  title: CustomText(
                                    text: "Task",
                                    colors: Colors.black,
                                    size: 15,
                                  ),
                                  value: "task",
                                  groupValue: provider.selectedNotification,
                                  activeColor: const Color(0xFF0078D7),
                                  onChanged: (v) =>
                                      provider.setNotification(v as String),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: textFieldSize,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CustomText(text: "Start Date & Time",
                                  colors: colorsConst.fieldHead,
                                size: 13,
                             ),
                              const CustomText(
                                text: "*",
                                colors: Colors.red,
                                size: 25,
                              )
                            ],
                          ),
                          const SizedBox(height: 5),
                          TextFormField(
                            controller:
                            remController.startController,
                            readOnly: true,

                            onTap: () => utils.selectDateTime(
                                context: context, isStart: true),
                            style: GoogleFonts.lato(
                              color: Colors.black,
                              fontSize: 17,
                            ),
                            decoration: InputDecoration(
                              suffixIcon: const Icon(
                                Icons.calendar_today_outlined,
                                size: 20,
                                color: Colors.grey,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    CustomDropDown(
                      saveValue: remController.defaultTime,
                      valueList: ["Immediately", "5 mins", "15 mins", "10 mins", "30 mins"],
                      text: "Event Duration",
                      width: textFieldSize,
                      onChanged: (value) async {
                        setState(() {
                          remController.defaultTime = value.toString();
                        });
                      },
                    ),
                  ],
                ),
                // const Text("Reminder Type",
                //     style: TextStyle(fontSize: 18, color: Colors.black)),
                // Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: Consumer<ReminderProvider>(
                //     builder: (context, cp, child) {
                //       return Row(
                //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         children: [
                //           Row(
                //             mainAxisSize: MainAxisSize.min,
                //             children: [
                //               SizedBox(
                //                 width: 16,
                //                 height: 16,
                //                 child: Checkbox(
                //                   value: cp.email,
                //                   onChanged: cp.toggleEmail,
                //                   materialTapTargetSize:
                //                   MaterialTapTargetSize.shrinkWrap,
                //                   side: const BorderSide(
                //                     color: Color(0xFF757575),
                //                   ),
                //                   fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                //                     if (states.contains(WidgetState.selected)) {
                //                       return Color(0xFF0078D7);
                //                     }
                //                     return Colors.white;
                //                   }),
                //                   checkColor: Colors.white,
                //                 ),
                //               ),
                //               const SizedBox(width: 6),
                //               Text(
                //                 "Email",
                //                 style: GoogleFonts.lato(
                //                     fontSize: 16, color: Colors.black
                //                   // fontWeight: FontWeight.bold,
                //                 ),
                //               ),
                //             ],
                //           ),
                //           Row(
                //             mainAxisSize: MainAxisSize.min,
                //             children: [
                //               SizedBox(
                //                 width: 16,
                //                 height: 16,
                //                 child: Checkbox(
                //                   value: cp.sms,
                //                   onChanged: cp.toggleSms,
                //                   materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                //                   side: const BorderSide(
                //                     color: Color(0xFF757575),
                //                   ),
                //                   fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                //                     if (states.contains(WidgetState.selected)) {
                //                       return Color(0xFF0078D7);
                //                     }
                //                     return Colors.white;
                //                   }),
                //                   checkColor: Colors.white,
                //                 ),
                //               ),
                //               const SizedBox(width: 6),
                //               Text(
                //                 "SMS",
                //                 style: GoogleFonts.lato(
                //                     fontSize: 16, color: Colors.black
                //                   // fontWeight: FontWeight.bold,
                //                 ),
                //               ),
                //             ],
                //           ),
                //           Row(
                //             mainAxisSize: MainAxisSize.min,
                //             children: [
                //               SizedBox(
                //                 width: 10,
                //                 height: 10,
                //                 child: Checkbox(
                //                   value: cp.web,
                //                   onChanged: null,
                //                   materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                //                   side: const BorderSide(
                //                     color: Color(0xFFBDBDBD),
                //                   ),
                //                   fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                //                     return Colors.grey.shade200;
                //                   }),
                //                   checkColor: Colors.grey,
                //                 ),
                //               ),
                //               const SizedBox(width: 6),
                //               Text(
                //                 "Web",
                //                 style: GoogleFonts.lato(
                //                   color: Colors.black,
                //                   fontSize: 16,
                //                 ),
                //               ),
                //             ],
                //           ),
                //           Row(
                //             mainAxisSize: MainAxisSize.min,
                //             children: [
                //               SizedBox(
                //                 width: 16,
                //                 height: 16,
                //                 child: Checkbox(
                //                   value: cp.app,
                //                   onChanged: null,
                //                   materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                //                   side: const BorderSide(
                //                     color: Color(0xFFBDBDBD),
                //                   ),
                //                   fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                //                     return Colors.grey.shade200;
                //                   }),
                //                   checkColor: Colors.grey,
                //                 ),
                //               ),
                //               const SizedBox(width: 6),
                //               Text(
                //                 "App",
                //                 style: GoogleFonts.lato(
                //                     fontSize: 16, color: Colors.black
                //                   // fontWeight: FontWeight.bold,
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ],
                //       );
                //     },
                //   ),
                // ),
                const SizedBox(height: 10),
                /// Reminder title
                Row(
                  children: [
                    Text("Reminder Title",
                        style: GoogleFonts.lato(
                            fontSize: 17, color: Color(0xff737373))),
                    const CustomText(
                      text: "*",
                      colors: Colors.red,
                      size: 25,
                    )
                  ],
                ),
                5.height,
                TextFormField(
                  textCapitalization: TextCapitalization.sentences,
                  controller: remController.titleController,
                  onChanged: (value){
                    if (value.toString().isNotEmpty) {
                      String newValue = value.toString()[0].toUpperCase() + value.toString().substring(1);
                      if (newValue != value) {
                        remController.titleController.value = remController.titleController.value.copyWith(
                          text: newValue,
                          selection: TextSelection.collapsed(offset: newValue.length),
                        );
                      }
                    }
                    if(remController.titleController.text.trim().isNotEmpty){
                      // setState(() {
                      //   titleError = null;
                      // });
                    }
                  },
                  style: GoogleFonts.lato(
                    color: Colors.black,
                    fontSize: 17,
                  ),
                  decoration: InputDecoration(
                    hintText: "Reminder title",
                    hintStyle: TextStyle(
                      color: Color(0xFFCCCCCC),
                      fontSize: 17,
                      fontFamily: GoogleFonts.lato().fontFamily,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
                const SizedBox(height: 10),



                8.height,
                Consumer<ReminderProvider>(
                  builder: (context, provider, _) {
                    if (provider.selectedNotification == "task") {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      children: [
                        /// Location
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text("Location",
                                      style: GoogleFonts.lato(
                                          fontSize: 17,
                                          color: const Color(0xff737373))),
                                  const SizedBox(height: 5),
                                  DropdownButtonFormField<String>(
                                    value: remController.location,
                                    dropdownColor: Colors.white,
                                    style: GoogleFonts.lato(
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.circular(4),
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade300),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.circular(4),
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade300),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.circular(4),
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade300),
                                      ),
                                      contentPadding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 10),
                                    ),
                                    items: ["Online", "Office"]
                                        .map(
                                          (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(
                                          e,
                                          style: GoogleFonts.lato(
                                            color: Colors.black,
                                            fontSize: 17,
                                          ),
                                        ),
                                      ),
                                    )
                                        .toList(),
                                    onChanged: (v) => setState(
                                            () => remController.location = v),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        13.height,

                        /// Employee and Customer fields
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Employees",
                                        style: GoogleFonts.lato(
                                          fontSize: 17,
                                          color: const Color(0xff737373),
                                        ),
                                      ),
                                      const CustomText(
                                        text: "*",
                                        colors: Colors.red,
                                        size: 25,
                                      )
                                    ],
                                  ),
                                  5.height,
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
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 5, 10, 5),
                                        child: CustomText(
                                          text:
                                          '${customer.name} ${customer.name.isEmpty ? "" : "-"} ${customer.phoneNo}',
                                          colors: Colors.black,
                                          size: 14,
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
                            20.width,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Assigned Customer",
                                        style: GoogleFonts.lato(
                                          fontSize: 17,
                                          color: const Color(0xff737373),
                                        ),
                                      ),
                                      const CustomText(
                                        text: "*",
                                        colors: Colors.red,
                                        size: 25,
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  KeyboardDropdownField<AllCustomersObj>(
                                    items: controllers.customers,
                                    borderRadius: 5,
                                    borderColor: Colors.grey.shade300,
                                    hintText: "Customers",
                                    labelText: "",
                                    labelBuilder: (customer) =>
                                    '${customer.name} ${customer.name.isEmpty ? "" : "-"} ${customer.phoneNo}',
                                    itemBuilder: (customer) {
                                      return Container(
                                        width: 300,
                                        alignment: Alignment.topLeft,
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 5, 10, 5),
                                        child: CustomText(
                                          text:
                                          '${customer.name} ${customer.name.isEmpty ? "" : "-"} ${customer.phoneNo}',
                                          colors: Colors.black,
                                          size: 14,
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

                        const SizedBox(height: 18),
                        /// Start & End Date/Time
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text("Start Date & Time",
                                          style: GoogleFonts.lato(
                                              fontSize: 17,
                                              color:
                                              const Color(0xff737373))),
                                      const CustomText(
                                        text: "*",
                                        colors: Colors.red,
                                        size: 25,
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  TextFormField(
                                    controller:
                                    remController.startController,
                                    readOnly: true,

                                    onTap: () => utils.selectDateTime(
                                        context: context, isStart: true),
                                    style: GoogleFonts.lato(
                                      color: Colors.black,
                                      fontSize: 17,
                                    ),
                                    decoration: InputDecoration(
                                      suffixIcon: const Icon(
                                        Icons.calendar_today_outlined,
                                        size: 20,
                                        color: Colors.grey,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text("End Date & Time",
                                          style: GoogleFonts.lato(
                                              fontSize: 17,
                                              color:
                                              const Color(0xff737373))),
                                      const CustomText(
                                        text: "*",
                                        colors: Colors.red,
                                        size: 25,
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  TextFormField(
                                    controller: remController.endController,
                                    readOnly: true,
                                    onTap: () => utils.selectDateTime(
                                        context: context, isStart: false),
                                    style: GoogleFonts.lato(
                                      color: Colors.black,
                                      fontSize: 17,
                                    ),
                                    decoration: InputDecoration(
                                      suffixIcon: const Icon(
                                        Icons.calendar_today_outlined,
                                        size: 20,
                                        color: Colors.grey,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.circular(4),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        10.height,
                        /// Details field
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Details",
                                style: GoogleFonts.lato(
                                    fontSize: 17,
                                    color: Color(0xff737373))),
                            const SizedBox(height: 5),
                            TextFormField(
                              textCapitalization:
                              TextCapitalization.sentences,
                              controller:
                              remController.detailsController,
                              maxLines: 2,
                              style: GoogleFonts.lato(
                                color: Colors.black,
                                fontSize: 17,
                              ),
                              decoration: InputDecoration(
                                hintText: "Appointment Points",
                                hintStyle: GoogleFonts.lato(
                                  color: const Color(0xFFCCCCCC),
                                  fontSize: 17,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ))
        ],
      ),
    );
  }
}

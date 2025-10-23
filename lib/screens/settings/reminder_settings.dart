import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../common/constant/colors_constant.dart';
import '../../common/utilities/utils.dart';
import '../../components/custom_text.dart';
import '../../controller/controller.dart';
import '../../controller/reminder_controller.dart';
import '../../provider/reminder_provider.dart';
import '../employee/role_management.dart';

class ReminderSettings extends StatefulWidget {
  const ReminderSettings({super.key});

  @override
  State<ReminderSettings> createState() => _ReminderSettingsState();
}

class _ReminderSettingsState extends State<ReminderSettings> {
  String _defaultTime = "Immediately";
  String? _selectedNotification;
  void _showFollowUpDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          insetPadding:
          const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          child: StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                width: 480,
                height: 390,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Set Follow-up Reminder",
                            style: GoogleFonts.lato(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              // Text(
                              //   "=",
                              //   style: GoogleFonts.lato(
                              //     fontSize: 19,
                              //     fontWeight: FontWeight.bold,
                              //     color: Colors.black, // optional color
                              //   ),
                              // ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: const Text(
                                  "×",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Divider(
                        thickness: 1,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 20),
                      const Text("Reminder Type",
                          style: TextStyle(fontSize: 18, color: Colors.black)),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Consumer<ReminderProvider>(
                          builder: (context, cp, child) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: Checkbox(
                                        value: cp.email,
                                        onChanged: cp.toggleEmail,
                                        materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                        side: const BorderSide(
                                          color: Color(0xFF757575),
                                        ),
                                        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                                          if (states.contains(WidgetState.selected)) {
                                            return Color(0xFF0078D7);
                                          }
                                          return Colors.white;
                                        }),
                                        checkColor: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Email",
                                      style: GoogleFonts.lato(
                                          fontSize: 16, color: Colors.black
                                        // fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: Checkbox(
                                        value: cp.sms,
                                        onChanged: null,
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        side: const BorderSide(
                                          color: Color(0xFFBDBDBD),
                                        ),
                                        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                                          return Colors.grey.shade200;
                                        }),
                                        checkColor: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "SMS",
                                      style: GoogleFonts.lato(
                                          fontSize: 16, color: Colors.black
                                        // fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 10,
                                      height: 10,
                                      child: Checkbox(
                                        value: cp.web,
                                        onChanged: null,
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        side: const BorderSide(
                                          color: Color(0xFFBDBDBD),
                                        ),
                                        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                                          return Colors.grey.shade200;
                                        }),
                                        checkColor: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Web",
                                      style: GoogleFonts.lato(
                                        color: Colors.black,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: Checkbox(
                                        value: cp.app,
                                        onChanged: null,
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        side: const BorderSide(
                                          color: Color(0xFFBDBDBD),
                                        ),
                                        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                                          return Colors.grey.shade200;
                                        }),
                                        checkColor: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "App",
                                      style: GoogleFonts.lato(
                                          fontSize: 16, color: Colors.black
                                        // fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 27),
                      Text(
                        "Default Time (Optional)",
                        style: GoogleFonts.lato(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                        // style:
                        // TextStyle(
                        //     fontSize: 18, color: Colors.black)
                      ),
                      const SizedBox(height: 5),
                      DropdownButtonFormField<String>(
                        value: _defaultTime,
                        isExpanded: true,
                        dropdownColor: Colors.white,
                        style: GoogleFonts.lato(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        items: ["Immediately", "5 mins", "10 mins", "30 mins"].map(
                              (e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              e,
                              style: GoogleFonts.lato(
                                color: Colors.black,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        )
                            .toList(),
                        onChanged: (v) => setState(() => _defaultTime = v!),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor:
                          Colors.white, // white background for input box
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.black, // 👈 dropdown arrow color
                        ),
                      ),
                      30.height,
                      // const Text("Repeat (Optional)",
                      //     style: TextStyle(fontSize: 18, color: Colors.black)),
                      // Consumer<ReminderProvider>(
                      //   builder: (context, cp, child) {
                      //     return Row(
                      //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //       children: [
                      //         Expanded(
                      //           child: InkWell(
                      //             onTap: () => cp.setRepeatOption("None"),
                      //             child: Row(
                      //               mainAxisSize: MainAxisSize.min,
                      //               children: [
                      //                 Radio<String>(
                      //                   value: "None",
                      //                   groupValue: cp.repeatOption,
                      //                   onChanged: (v) =>
                      //                       cp.setRepeatOption(v!),
                      //                   activeColor: const Color(
                      //                       0xFF0078D7), // blue when selected
                      //                 ),
                      //                 4.width,
                      //                 Text(
                      //                   "None",
                      //                   style: GoogleFonts.lato(
                      //                     color: Colors.black,
                      //                     fontSize: 18,
                      //                   ),
                      //                 ),
                      //               ],
                      //             ),
                      //           ),
                      //         ),
                      //         Expanded(
                      //           child: InkWell(
                      //             onTap: () => cp.setRepeatOption("Daily"),
                      //             child: Row(
                      //               mainAxisSize: MainAxisSize.min,
                      //               children: [
                      //                 Radio<String>(
                      //                   value: "Daily",
                      //                   groupValue: cp.repeatOption,
                      //                   onChanged: (v) =>
                      //                       cp.setRepeatOption(v!),
                      //                   activeColor: const Color(
                      //                       0xFF0078D7), // blue when selected
                      //                 ),
                      //                 4.width,
                      //                 Text(
                      //                   "Daily",
                      //                   style: GoogleFonts.lato(
                      //                     color: Colors.black,
                      //                     fontSize: 18,
                      //                   ),
                      //                 ),
                      //               ],
                      //             ),
                      //           ),
                      //         ),
                      //         Expanded(
                      //           child: InkWell(
                      //             onTap: () => cp.setRepeatOption("Weekly"),
                      //             child: Row(
                      //               mainAxisSize: MainAxisSize.min,
                      //               children: [
                      //                 Radio<String>(
                      //                   value: "Weekly",
                      //                   groupValue: cp.repeatOption,
                      //                   onChanged: (v) =>
                      //                       cp.setRepeatOption(v!),
                      //                   activeColor: const Color(
                      //                       0xFF0078D7), // blue when selected
                      //                 ),
                      //                 4.width,
                      //                 Text(
                      //                   "Weekly",
                      //                   style: GoogleFonts.lato(
                      //                     color: Colors.black,
                      //                     fontSize: 18,
                      //                   ),
                      //                 ),
                      //               ],
                      //             ),
                      //           ),
                      //         ),
                      //         Expanded(
                      //           child: InkWell(
                      //             onTap: () => cp.setRepeatOption("Monthly"),
                      //             child: Row(
                      //               mainAxisSize: MainAxisSize.min,
                      //               children: [
                      //                 Radio<String>(
                      //                   value: "Monthly",
                      //                   groupValue: cp.repeatOption,
                      //                   onChanged: (v) =>
                      //                       cp.setRepeatOption(v!),
                      //                   activeColor: const Color(
                      //                       0xFF0078D7), // blue when selected
                      //                 ),
                      //                 4.width, // reduced space between radio & text
                      //                 Text(
                      //                   "Monthly",
                      //                   style: GoogleFonts.lato(
                      //                     color: Colors.black,
                      //                     fontSize: 18,
                      //                   ),
                      //                 ),
                      //               ],
                      //             ),
                      //           ),
                      //         ),
                      //       ],
                      //     );
                      //   },
                      // ),

                      const SizedBox(height: 50),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: 75,
                            height: 35,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                const Color(0xFFE7EEF8), // fill color
                                foregroundColor: Colors.black, // text color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7),
                                  side: const BorderSide(
                                      color: Color(0xff0078D7)), // border
                                ),
                                padding: EdgeInsets.zero,
                                elevation: 0, // flat style
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                "Cancel",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            height: 35,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff0078D7), // fill color
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(7), // border radius
                                ),
                              ),
                              onPressed: () {
                                remController.insertSettingsReminderAPI(context, _defaultTime);
                              },
                              child: const Text(
                                "Save Reminder",
                                style: TextStyle(
                                  color: Colors.white, // text color
                                  fontWeight: FontWeight.bold, // bold
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
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
                 mainAxisAlignment: MainAxisAlignment.start,
                 children: [
                   Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       CustomText(
                         text: "Settings",
                         colors: colorsConst.textColor,
                         size: 20,
                         isBold: true,
                       ),
                       10.height,
                       CustomText(
                         text: "Manage all your application settings in one place",
                         colors: colorsConst.textColor,
                         size: 14,
                       ),
                     ],
                   ),
                   // SizedBox(
                   //   height: 40,
                   //   child: ElevatedButton(
                   //     onPressed: (){
                   //       Navigator.push(context, MaterialPageRoute(builder: (context)=> const RoleManagement()));
                   //     },
                   //     style: ElevatedButton.styleFrom(
                   //       backgroundColor: const Color(0xff0078D7),
                   //       padding: const EdgeInsets.symmetric(
                   //           horizontal: 20, vertical: 12),
                   //       shape: RoundedRectangleBorder(
                   //         borderRadius: BorderRadius.circular(4),
                   //       ),
                   //     ),
                   //     child: Text(
                   //       'Role Management',
                   //       style: GoogleFonts.lato(
                   //           color: Colors.white,
                   //           fontSize: 14,
                   //           fontWeight: FontWeight.bold
                   //       ),
                   //     ),
                   //   ),
                   // ),
                 ],
               ),
               Padding(
                 padding: const EdgeInsets.all(20.0),
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.start,
                   children: [
                     Row(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         GestureDetector(
                           onTap: () {
                             context.read<ReminderProvider>().toggleReminder("followup");
                             remController.allReminders("1");
                           },
                           child: Container(
                             width: 270,
                             height: 82,
                             padding: const EdgeInsets.symmetric(horizontal: 10),
                             decoration: BoxDecoration(
                               color:
                               context.watch<ReminderProvider>().isFollowUpActive
                                   ? const Color(0xFFE7EEF8)
                                   : Colors.white,
                               borderRadius: BorderRadius.circular(6),
                               border: Border.all(
                                 color: context.watch<ReminderProvider>().isFollowUpActive
                                     ? Colors.blue
                                     : Colors.grey.shade300,
                                 width: 2,
                               ),
                             ),
                             child: Row(
                               children: [
                                 Text(
                                   "Follow-up Reminder",
                                   style: GoogleFonts.lato(
                                     fontSize: 16,
                                     fontWeight: FontWeight.bold,
                                     color: Color(0xff1E1E1E),
                                   ),
                                 ),
                                 IconButton(
                                     onPressed: () {
                                       _showFollowUpDialog();
                                     },
                                     icon: Icon(
                                       Icons.add,
                                       size: 20,
                                     )),
                                 // 7.width,
                                 // SvgPicture.asset('assets/images/edit.svg',
                                 //     width: 20, height: 20),
                                 // 7.width,
                                 // SvgPicture.asset('assets/images/delete.svg',
                                 //     width: 20, height: 20),
                               ],
                             ),
                           ),
                         ),

                         const SizedBox(width: 45),

                         // ---------------- Meeting Reminder ----------------
                         GestureDetector(
                           onTap: () {
                             context.read<ReminderProvider>().toggleReminder("meeting");
                             remController.allReminders("2");
                           },
                           child: Container(
                             width: 260,
                             height: 82,
                             padding: const EdgeInsets.symmetric(horizontal: 10),
                             decoration: BoxDecoration(
                               color:
                               context.watch<ReminderProvider>().isMeetingActive
                                   ? const Color(0xFFE7EEF8)
                                   : Colors.white,
                               borderRadius: BorderRadius.circular(6),
                               border: Border.all(
                                 color: context
                                     .watch<ReminderProvider>()
                                     .isMeetingActive
                                     ? Colors.blue
                                     : Colors.grey.shade300,
                                 width: 2,
                               ),
                             ),
                             child: Row(
                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                               children: [
                                 Expanded(
                                   child: Text(
                                     "Appointment Reminder",
                                     style: GoogleFonts.lato(
                                       fontSize: 16,
                                       fontWeight: FontWeight.bold,
                                       color: Colors.black87,
                                     ),
                                   ),
                                 ),
                                 Row(
                                   children: [
                                     IconButton(
                                         onPressed: () {
                                           _showFollowUpDialog();
                                         },
                                         icon: Icon(
                                           Icons.add,
                                           size: 20,
                                         )),
                                     // 7.width,
                                     // SvgPicture.asset('assets/images/edit.svg',
                                     //     width: 20, height: 20),
                                     // const SizedBox(width: 7),
                                     // SvgPicture.asset('assets/images/delete.svg',
                                     //     width: 20, height: 20),
                                   ],
                                 ),
                               ],
                             ),
                           ),
                         ),

                         const SizedBox(width: 50),

                         // ---------------- Calendar (only for Follow-up) ----------------
                         // if (context.watch<ReminderProvider>().isFollowUpActive)
                         //   Container(
                         //     width: 340,
                         //     height: 400,
                         //     decoration: BoxDecoration(
                         //       color: Colors.white,
                         //       borderRadius: BorderRadius.circular(7),
                         //       boxShadow: [
                         //         BoxShadow(
                         //           color: Colors.grey.shade300,
                         //           offset: Offset(0, 1),
                         //           blurRadius: 5,
                         //           spreadRadius: 3,
                         //         )
                         //       ],
                         //     ),
                         //     child: TableCalendar(
                         //       firstDay: DateTime(2020),
                         //       lastDay: DateTime(2100),
                         //       focusedDay: DateTime.now(),
                         //       selectedDayPredicate: (day) {
                         //         return context
                         //             .watch<ReminderProvider>()
                         //             .followUpSelectedDays
                         //             .any((d) => isSameDay(d, day));
                         //       },
                         //       onDaySelected: (selectedDay, focusedDay) {
                         //         context
                         //             .read<ReminderProvider>()
                         //             .toggleFollowUpDay(selectedDay);
                         //       },
                         //       calendarStyle: CalendarStyle(
                         //         isTodayHighlighted: true,
                         //         selectedDecoration: BoxDecoration(
                         //           color: Color(0xFF0078D7),
                         //           shape: BoxShape.circle,
                         //         ),
                         //         todayDecoration: BoxDecoration(
                         //           color: Colors.grey.shade300,
                         //           shape: BoxShape.circle,
                         //         ),
                         //       ),
                         //       headerStyle: HeaderStyle(
                         //         formatButtonVisible: false,
                         //         titleCentered: true,
                         //       ),
                         //     ),
                         //   ),
                       ],
                     )
                   ],
                 ),
               ),
             ],
           ),
         ))
        ],
      ),
    );
  }
}

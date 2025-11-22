import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/common/utilities/utils.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../components/custom_date_box.dart';
import '../../components/custom_dropdown.dart';
import '../../components/custom_loading_button.dart';
import '../../components/custom_text.dart';
import '../../components/custom_textfield.dart';
import '../../components/keyboard_search.dart';
import '../../controller/controller.dart';
import '../../controller/reminder_controller.dart';
import '../../models/all_customers_obj.dart';
import '../../provider/reminder_provider.dart';
import '../constant/colors_constant.dart';
import '../styles/styles.dart';

final ReminderUtils reminderUtils = ReminderUtils._();

class ReminderUtils {
  ReminderUtils._();
  bool showFollowUpCalendar = false;
  bool showMeetingCalendar = false;

  DateTime followUpSelectedDay = DateTime.now();
  DateTime meetingSelectedDay = DateTime.now();

// State for dropdown & repeat
  Map<DateTime, TimeOfDay> _selectedStartDatesTimes = {};
  Map<DateTime, TimeOfDay> _selectedEndDatesTimes = {};
  TimeOfDay _selectedTime = TimeOfDay.now();

  Future<void> selectDateTime({
    required BuildContext context,
    required bool isStart,
  })
  async {
    Map<DateTime, TimeOfDay> selectedDatesTimes = isStart ? _selectedStartDatesTimes : _selectedEndDatesTimes;
    TextEditingController controller = isStart ? remController.startController : remController.endController;
    TimeOfDay dialogSelectedTime = selectedDatesTimes.values.isNotEmpty
        ? selectedDatesTimes.values.first
        : _selectedTime;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              insetPadding: const EdgeInsets.all(20),
              contentPadding: const EdgeInsets.all(8),
              title: Text(
                isStart ? "Select Start Date & Time" : "Select End Date & Time",
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                height: 630,
                width: 700,
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: SfDateRangePicker(
                        backgroundColor: Colors.white,
                        view: DateRangePickerView.month,
                        selectionMode: DateRangePickerSelectionMode.single,
                        extendableRangeSelectionDirection: ExtendableRangeSelectionDirection.none,
                        selectionColor: colorsConst.primary,
                        startRangeSelectionColor: colorsConst.primary,
                        endRangeSelectionColor: colorsConst.primary,
                        rangeSelectionColor: const Color(0xffD9ECFF),
                        todayHighlightColor: colorsConst.primary,
                        headerStyle: DateRangePickerHeaderStyle(
                          backgroundColor: Colors.white,
                          textStyle: TextStyle(color: colorsConst.primary, fontSize: 16,),
                        ),
                        onSelectionChanged: (args) {
                          if (args.value is DateTime) {
                            DateTime selectedDate = args.value;
                            setDialogState(() {
                              selectedDatesTimes.clear();
                              selectedDatesTimes[selectedDate] = dialogSelectedTime;
                            });
                          }
                        },
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 600,
                      color: Colors.grey.shade300,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 500,
                            child: Center(
                                child: SizedBox(
                                    width: 330,
                                    child: Theme(
                                      data: Theme.of(context).copyWith(
                                        timePickerTheme: TimePickerThemeData(
                                          backgroundColor: const Color(0xFFE7EEF8),
                                          hourMinuteShape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(8)),
                                            side: BorderSide(color: Colors.black26),
                                          ),
                                          hourMinuteColor: WidgetStateColor.resolveWith((states) {
                                            if (states.contains(WidgetState.selected)) {
                                              return const Color(0xff0078D7);
                                            }
                                            return Colors.white;
                                          }),
                                          hourMinuteTextColor: WidgetStateColor.resolveWith((states) {
                                            if (states.contains(WidgetState.selected)) {
                                              return Colors.white;
                                            }
                                            return colorsConst.primary;
                                          }),
                                          timeSelectorSeparatorColor:  WidgetStateColor.resolveWith((states) {
                                            if (states.contains(WidgetState.selected)) {
                                              return Colors.white;
                                            }
                                            return Colors.black;
                                          }),
                                          dayPeriodShape:  RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(6)),
                                            side: BorderSide(color: colorsConst.primary),
                                          ),
                                          dayPeriodColor: WidgetStateColor.resolveWith((states) {
                                            if (states.contains(WidgetState.selected)) {
                                              return colorsConst.primary;
                                            }
                                            return Colors.white;
                                          }),
                                          dayPeriodTextColor: WidgetStateColor.resolveWith((states) {
                                            if (states.contains(WidgetState.selected)) {
                                              return Colors.white;
                                            }
                                            return Colors.black;
                                          }),
                                          dialBackgroundColor: Colors.white,
                                          dialHandColor:colorsConst.primary,
                                          dialTextColor: Colors.black, // unselected numbers
                                          dialTextStyle: WidgetStateTextStyle.resolveWith((states) {
                                            if (states.contains(WidgetState.selected)) {
                                              return const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              );
                                            }
                                            return const TextStyle(
                                              color: Colors.black,
                                              fontSize: 18,
                                            );
                                          }),
                                          hourMinuteTextStyle: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 50,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      child: TimePickerDialog(
                                        initialTime: dialogSelectedTime,
                                        orientation: Orientation.portrait,
                                        cancelText: "",
                                        confirmText:"",
                                        onEntryModeChanged: (value){
                                          print("Time $value");
                                          // _selectedTime=value;
                                        },
                                      ),
                                    )
                                )
                            ),
                          ),
                          const SizedBox(height: 12),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _quickButton("+15 min", () {
                                    final t = dialogSelectedTime.replacing(
                                      minute:
                                      (dialogSelectedTime.minute + 15) % 60,
                                      hour: (dialogSelectedTime.hour +
                                          (dialogSelectedTime.minute +
                                              15) ~/
                                              60) %
                                          24,
                                    );
                                    setDialogState(
                                            () => dialogSelectedTime = t);
                                  }),
                                  _quickButton("+30 min", () {
                                    final t = dialogSelectedTime.replacing(
                                      minute:
                                      (dialogSelectedTime.minute + 30) % 60,
                                      hour: (dialogSelectedTime.hour +
                                          (dialogSelectedTime.minute +
                                              30) ~/
                                              60) %
                                          24,
                                    );
                                    setDialogState(
                                            () => dialogSelectedTime = t);
                                  }),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _quickButton("+1 hour", () {
                                    setDialogState(() {
                                      dialogSelectedTime = TimeOfDay(
                                        hour:
                                        (dialogSelectedTime.hour + 1) % 24,
                                        minute: dialogSelectedTime.minute,
                                      );
                                    });
                                  }),
                                  _quickButton("End of Day", () {
                                    setDialogState(() => dialogSelectedTime =
                                    const TimeOfDay(hour: 23, minute: 59));
                                  }),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 25, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 116,
                        height: 40,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE7EEF8),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                              side: const BorderSide(color: Color(0xff0078D7)),
                            ),
                            padding: EdgeInsets.zero,
                            elevation: 0,
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
                        width: 116,
                        height: 40,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff0078D7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context, dialogSelectedTime);
                            selectedDatesTimes.updateAll(
                                  (key, value) => dialogSelectedTime,
                            );
                            if (selectedDatesTimes.isNotEmpty) {
                              final selectedDate = selectedDatesTimes.keys.first;
                              controller.text = "${selectedDate.day}-${selectedDate.month}-${selectedDate.year} "
                                  "${dialogSelectedTime.format(context)}";
                            }
                            print("Selected ${isStart ? "start" : "end"} dates & times: $selectedDatesTimes");
                          },
                          child: const Text(
                            "Set Time",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _quickButton(String text, VoidCallback onTap) {
    return Container(
      width: 120,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: BorderSide(color: Colors.grey.shade300),
          foregroundColor: Colors.black,
        ),
        child: Text(text, style: const TextStyle(fontSize: 13)),
      ),
    );
  }

  final DateFormat formatter = DateFormat("yyyy-MM-dd HH:mm");

  // void showAddReminderDialog(BuildContext context) {
  //   String? titleError;
  //   String? startError;
  //   String? endError;
  //   String? employeeError;
  //   String? customerError;
  //   showDialog(
  //     context: context,
  //     barrierDismissible: true,
  //     builder: (context) {
  //       return StatefulBuilder(
  //         builder: (context, setState) {
  //           return AlertDialog(
  //             insetPadding: const EdgeInsets.symmetric(horizontal: 80, vertical: 50),
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(8),
  //             ),
  //             contentPadding: EdgeInsets.zero,
  //             content: Container(
  //               width: 630,
  //               color: Colors.white,
  //               padding: const EdgeInsets.all(20),
  //               child: SingleChildScrollView(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Row(
  //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                       children: [
  //                         Text(
  //                           "Add Reminder",
  //                           style: GoogleFonts.lato(
  //                             fontSize: 18,
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         ),
  //                         GestureDetector(
  //                           onTap: () => Navigator.pop(context),
  //                           child: const Text(
  //                             "×",
  //                             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                     const SizedBox(height: 8),
  //                     Divider(thickness: 1, color: Colors.grey.shade300),
  //                     const SizedBox(height: 8),
  //                     const Text("Reminder Type",
  //                         style: TextStyle(fontSize: 18, color: Colors.black)),
  //                     Padding(
  //                       padding: const EdgeInsets.all(8.0),
  //                       child: Consumer<ReminderProvider>(
  //                         builder: (context, cp, child) {
  //                           return Row(
  //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                             children: [
  //                               Row(
  //                                 mainAxisSize: MainAxisSize.min,
  //                                 children: [
  //                                   SizedBox(
  //                                     width: 16,
  //                                     height: 16,
  //                                     child: Checkbox(
  //                                       value: cp.email,
  //                                       onChanged: cp.toggleEmail,
  //                                       materialTapTargetSize:
  //                                       MaterialTapTargetSize.shrinkWrap,
  //                                       side: const BorderSide(
  //                                         color: Color(0xFF757575),
  //                                       ),
  //                                       fillColor: WidgetStateProperty.resolveWith<Color>((states) {
  //                                         if (states.contains(WidgetState.selected)) {
  //                                           return Color(0xFF0078D7);
  //                                         }
  //                                         return Colors.white;
  //                                       }),
  //                                       checkColor: Colors.white,
  //                                     ),
  //                                   ),
  //                                   const SizedBox(width: 6),
  //                                   Text(
  //                                     "Email",
  //                                     style: GoogleFonts.lato(
  //                                         fontSize: 16, color: Colors.black
  //                                       // fontWeight: FontWeight.bold,
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //                               Row(
  //                                 mainAxisSize: MainAxisSize.min,
  //                                 children: [
  //                                   SizedBox(
  //                                     width: 16,
  //                                     height: 16,
  //                                     child: Checkbox(
  //                                       value: cp.sms,
  //                                       onChanged: cp.toggleSms,
  //                                       materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  //                                       side: const BorderSide(
  //                                         color: Color(0xFF757575),
  //                                       ),
  //                                       fillColor: WidgetStateProperty.resolveWith<Color>((states) {
  //                                         if (states.contains(WidgetState.selected)) {
  //                                           return Color(0xFF0078D7);
  //                                         }
  //                                         return Colors.white;
  //                                       }),
  //                                       checkColor: Colors.white,
  //                                     ),
  //                                   ),
  //                                   const SizedBox(width: 6),
  //                                   Text(
  //                                     "SMS",
  //                                     style: GoogleFonts.lato(
  //                                         fontSize: 16, color: Colors.black
  //                                       // fontWeight: FontWeight.bold,
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //                               Row(
  //                                 mainAxisSize: MainAxisSize.min,
  //                                 children: [
  //                                   SizedBox(
  //                                     width: 10,
  //                                     height: 10,
  //                                     child: Checkbox(
  //                                       value: cp.web,
  //                                       onChanged: null,
  //                                       materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  //                                       side: const BorderSide(
  //                                         color: Color(0xFFBDBDBD),
  //                                       ),
  //                                       fillColor: WidgetStateProperty.resolveWith<Color>((states) {
  //                                         return Colors.grey.shade200;
  //                                       }),
  //                                       checkColor: Colors.grey,
  //                                     ),
  //                                   ),
  //                                   const SizedBox(width: 6),
  //                                   Text(
  //                                     "Web",
  //                                     style: GoogleFonts.lato(
  //                                       color: Colors.black,
  //                                       fontSize: 16,
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //                               Row(
  //                                 mainAxisSize: MainAxisSize.min,
  //                                 children: [
  //                                   SizedBox(
  //                                     width: 16,
  //                                     height: 16,
  //                                     child: Checkbox(
  //                                       value: cp.app,
  //                                       onChanged: null,
  //                                       materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  //                                       side: const BorderSide(
  //                                         color: Color(0xFFBDBDBD),
  //                                       ),
  //                                       fillColor: WidgetStateProperty.resolveWith<Color>((states) {
  //                                         return Colors.grey.shade200;
  //                                       }),
  //                                       checkColor: Colors.grey,
  //                                     ),
  //                                   ),
  //                                   const SizedBox(width: 6),
  //                                   Text(
  //                                     "App",
  //                                     style: GoogleFonts.lato(
  //                                         fontSize: 16, color: Colors.black
  //                                       // fontWeight: FontWeight.bold,
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //                             ],
  //                           );
  //                         },
  //                       ),
  //                     ),
  //                     const SizedBox(height: 10),
  //                     Row(
  //                       children: [
  //                         Text("Default Time (Optional)",
  //                           style: GoogleFonts.lato(
  //                             color: Colors.black,
  //                             fontSize: 18,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                     const SizedBox(height: 5),
  //                     DropdownButtonFormField<String>(
  //                       value: remController.defaultTime,
  //                       isExpanded: true,
  //                       dropdownColor: Colors.white,
  //                       style: GoogleFonts.lato(
  //                         color: Colors.black,
  //                         fontSize: 16,
  //                       ),
  //                       items: ["Immediately", "5 mins", "10 mins", "30 mins"].map(
  //                             (e) => DropdownMenuItem(
  //                           value: e,
  //                           child: Text(
  //                             e,
  //                             style: GoogleFonts.lato(
  //                               color: Colors.black,
  //                               fontSize: 18,
  //                             ),
  //                           ),
  //                         ),
  //                       ).toList(),
  //                       onChanged: (v) => setState(() => remController.defaultTime = v!),
  //                       decoration: InputDecoration(
  //                         filled: true,
  //                         fillColor:
  //                         Colors.white, // white background for input box
  //                         border: OutlineInputBorder(
  //                           borderRadius: BorderRadius.circular(6),
  //                           borderSide: BorderSide(color: Colors.grey.shade300),
  //                         ),
  //                         enabledBorder: OutlineInputBorder(
  //                           borderRadius: BorderRadius.circular(6),
  //                           borderSide: BorderSide(color: Colors.grey.shade300),
  //                         ),
  //                         focusedBorder: OutlineInputBorder(
  //                           borderRadius: BorderRadius.circular(6),
  //                           borderSide: BorderSide(color: Colors.grey.shade300),
  //                         ),
  //                         contentPadding: const EdgeInsets.symmetric(
  //                             horizontal: 12, vertical: 10),
  //                       ),
  //                       icon: const Icon(
  //                         Icons.keyboard_arrow_down_rounded,
  //                         color: Colors.black, // 👈 dropdown arrow color
  //                       ),
  //                     ),
  //                     const SizedBox(height: 10),
  //                     /// Reminder title
  //                     Row(
  //                       children: [
  //                         Text("Reminder Title",
  //                             style: GoogleFonts.lato(
  //                                 fontSize: 17, color: Color(0xff737373))),
  //                         const CustomText(
  //                           text: "*",
  //                           colors: Colors.red,
  //                           size: 25,
  //                         )
  //                       ],
  //                     ),
  //                     5.height,
  //                     TextFormField(
  //                       textCapitalization: TextCapitalization.sentences,
  //                       controller: remController.titleController,
  //                       onChanged: (value){
  //                         if (value.toString().isNotEmpty) {
  //                           String newValue = value.toString()[0].toUpperCase() + value.toString().substring(1);
  //                           if (newValue != value) {
  //                             remController.titleController.value = remController.titleController.value.copyWith(
  //                               text: newValue,
  //                               selection: TextSelection.collapsed(offset: newValue.length),
  //                             );
  //                           }
  //                         }
  //                         if(remController.titleController.text.trim().isNotEmpty){
  //                           setState(() {
  //                             titleError = null;
  //                           });
  //                         }
  //                       },
  //                       style: GoogleFonts.lato(
  //                         color: Colors.black,
  //                         fontSize: 17,
  //                       ),
  //                       decoration: InputDecoration(
  //                         hintText: "Reminder title",
  //                         errorText: titleError,
  //                         hintStyle: TextStyle(
  //                           color: Color(0xFFCCCCCC),
  //                           fontSize: 17,
  //                           fontFamily: GoogleFonts.lato().fontFamily,
  //                         ),
  //                         border: OutlineInputBorder(
  //                           borderRadius: BorderRadius.circular(4),
  //                           borderSide: BorderSide(color: Colors.grey.shade300),
  //                         ),
  //                         enabledBorder: OutlineInputBorder(
  //                           borderRadius: BorderRadius.circular(4),
  //                           borderSide: BorderSide(color: Colors.grey.shade300),
  //                         ),
  //                         focusedBorder: OutlineInputBorder(
  //                           borderRadius: BorderRadius.circular(4),
  //                           borderSide: BorderSide(color: Colors.grey.shade300),
  //                         ),
  //                       ),
  //                     ),
  //                     const SizedBox(height: 10),
  //
  //                     Text("Notification Type",
  //                         style: GoogleFonts.lato(
  //                             fontSize: 17, color: const Color(0xff737373))),
  //                     Consumer<ReminderProvider>(
  //                       builder: (context, provider, _) {
  //                         return Row(
  //                           children: [
  //                             Expanded(
  //                               child: RadioListTile(
  //                                 title: Text(
  //                                   "Follow-up Reminder",
  //                                   style: GoogleFonts.lato(
  //                                     color: Colors.black,
  //                                     fontSize: 17,
  //                                   ),
  //                                 ),
  //                                 value: "followup",
  //                                 groupValue: provider.selectedNotification,
  //                                 activeColor: const Color(0xFF0078D7),
  //                                 onChanged: (v) =>
  //                                     provider.setNotification(v as String),
  //                               ),
  //                             ),
  //                             Expanded(
  //                               child: RadioListTile(
  //                                 title: Text(
  //                                   "Appointment Reminder",
  //                                   style: GoogleFonts.lato(
  //                                     color: Colors.black,
  //                                     fontSize: 17,
  //                                   ),
  //                                 ),
  //                                 value: "meeting",
  //                                 groupValue: provider.selectedNotification,
  //                                 activeColor: const Color(0xFF0078D7),
  //                                 onChanged: (v) =>
  //                                     provider.setNotification(v as String),
  //                               ),
  //                             ),
  //                           ],
  //                         );
  //                       },
  //                     ),
  //
  //                     8.height,
  //                     Consumer<ReminderProvider>(
  //                       builder: (context, provider, _) {
  //                         if (provider.selectedNotification == "task") {
  //                           return const SizedBox.shrink();
  //                         }
  //                         return Column(
  //                           children: [
  //                             /// Location
  //                             Row(
  //                               children: [
  //                                 Expanded(
  //                                   child: Column(
  //                                     crossAxisAlignment: CrossAxisAlignment.start,
  //                                     children: [
  //                                       Text("Location",
  //                                           style: GoogleFonts.lato(
  //                                               fontSize: 17,
  //                                               color: const Color(0xff737373))),
  //                                       const SizedBox(height: 5),
  //                                       DropdownButtonFormField<String>(
  //                                         value: remController.location,
  //                                         dropdownColor: Colors.white,
  //                                         style: GoogleFonts.lato(
  //                                           color: Colors.black,
  //                                           fontSize: 14,
  //                                         ),
  //                                         decoration: InputDecoration(
  //                                           filled: true,
  //                                           fillColor: Colors.white,
  //                                           border: OutlineInputBorder(
  //                                             borderRadius:
  //                                             BorderRadius.circular(4),
  //                                             borderSide: BorderSide(
  //                                                 color: Colors.grey.shade300),
  //                                           ),
  //                                           enabledBorder: OutlineInputBorder(
  //                                             borderRadius:
  //                                             BorderRadius.circular(4),
  //                                             borderSide: BorderSide(
  //                                                 color: Colors.grey.shade300),
  //                                           ),
  //                                           focusedBorder: OutlineInputBorder(
  //                                             borderRadius:
  //                                             BorderRadius.circular(4),
  //                                             borderSide: BorderSide(
  //                                                 color: Colors.grey.shade300),
  //                                           ),
  //                                           contentPadding:
  //                                           const EdgeInsets.symmetric(
  //                                               horizontal: 12,
  //                                               vertical: 10),
  //                                         ),
  //                                         items: ["Online", "Office"]
  //                                             .map(
  //                                               (e) => DropdownMenuItem(
  //                                             value: e,
  //                                             child: Text(
  //                                               e,
  //                                               style: GoogleFonts.lato(
  //                                                 color: Colors.black,
  //                                                 fontSize: 17,
  //                                               ),
  //                                             ),
  //                                           ),
  //                                         )
  //                                             .toList(),
  //                                         onChanged: (v) => setState(
  //                                                 () => remController.location = v),
  //                                       ),
  //                                     ],
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //
  //                             13.height,
  //
  //                             /// Employee and Customer fields
  //                             Row(
  //                               children: [
  //                                 Expanded(
  //                                   child: Column(
  //                                     crossAxisAlignment:
  //                                     CrossAxisAlignment.start,
  //                                     children: [
  //                                       Row(
  //                                         children: [
  //                                           Text(
  //                                             "Employees",
  //                                             style: GoogleFonts.lato(
  //                                               fontSize: 17,
  //                                               color: const Color(0xff737373),
  //                                             ),
  //                                           ),
  //                                           const CustomText(
  //                                             text: "*",
  //                                             colors: Colors.red,
  //                                             size: 25,
  //                                           )
  //                                         ],
  //                                       ),
  //                                       5.height,
  //                                       KeyboardDropdownField<AllEmployeesObj>(
  //                                         items: controllers.employees,
  //                                         borderRadius: 5,
  //                                         borderColor: Colors.grey.shade300,
  //                                         hintText: "Employees",
  //                                         labelText: "",
  //                                         labelBuilder: (customer) =>
  //                                         '${customer.name} ${customer.name.isEmpty ? "" : "-"} ${customer.phoneNo}',
  //                                         itemBuilder: (customer) {
  //                                           return Container(
  //                                             width: 300,
  //                                             alignment: Alignment.topLeft,
  //                                             padding: const EdgeInsets.fromLTRB(
  //                                                 10, 5, 10, 5),
  //                                             child: CustomText(
  //                                               text:
  //                                               '${customer.name} ${customer.name.isEmpty ? "" : "-"} ${customer.phoneNo}',
  //                                               colors: Colors.black,
  //                                               size: 14,
  //                                               textAlign: TextAlign.start,
  //                                             ),
  //                                           );
  //                                         },
  //                                         textEditingController: controllers.empController,
  //                                         onSelected: (value) {
  //                                           setState((){
  //                                             employeeError=null;
  //                                           });
  //                                           controllers.selectEmployee(value);
  //                                         },
  //                                         onClear: () {
  //                                           controllers.clearSelectedCustomer();
  //                                         },
  //                                       ),
  //                                       if (employeeError != null)
  //                                         Padding(
  //                                           padding: const EdgeInsets.only(top: 4.0),
  //                                           child: Text(
  //                                             employeeError!,
  //                                             style: const TextStyle(
  //                                                 color: Colors.red,
  //                                                 fontSize: 13),
  //                                           ),
  //                                         ),
  //                                     ],
  //                                   ),
  //                                 ),
  //                                 20.width,
  //                                 Expanded(
  //                                   child: Column(
  //                                     crossAxisAlignment: CrossAxisAlignment.start,
  //                                     children: [
  //                                       Row(
  //                                         children: [
  //                                           Text(
  //                                             "Assigned Customer",
  //                                             style: GoogleFonts.lato(
  //                                               fontSize: 17,
  //                                               color: const Color(0xff737373),
  //                                             ),
  //                                           ),
  //                                           const CustomText(
  //                                             text: "*",
  //                                             colors: Colors.red,
  //                                             size: 25,
  //                                           )
  //                                         ],
  //                                       ),
  //                                       const SizedBox(height: 5),
  //                                       KeyboardDropdownField<AllCustomersObj>(
  //                                         items: controllers.customers,
  //                                         borderRadius: 5,
  //                                         borderColor: Colors.grey.shade300,
  //                                         hintText: "Customers",
  //                                         labelText: "",
  //                                         labelBuilder: (customer) =>
  //                                         '${customer.name} ${customer.name.isEmpty ? "" : "-"} ${customer.phoneNo}',
  //                                         itemBuilder: (customer) {
  //                                           return Container(
  //                                             width: 300,
  //                                             alignment: Alignment.topLeft,
  //                                             padding: const EdgeInsets.fromLTRB(
  //                                                 10, 5, 10, 5),
  //                                             child: CustomText(
  //                                               text:
  //                                               '${customer.name} ${customer.name.isEmpty ? "" : "-"} ${customer.phoneNo}',
  //                                               colors: Colors.black,
  //                                               size: 14,
  //                                               textAlign: TextAlign.start,
  //                                             ),
  //                                           );
  //                                         },
  //                                         textEditingController: controllers.cusController,
  //                                         onSelected: (value) {
  //                                           setState((){
  //                                             customerError=null;
  //                                           });
  //                                           controllers.selectCustomer(value);
  //                                         },
  //                                         onClear: () {
  //                                           controllers.clearSelectedCustomer();
  //                                         },
  //                                       ),
  //                                       if (customerError != null)
  //                                         Padding(
  //                                           padding:
  //                                           const EdgeInsets.only(top: 4.0),
  //                                           child: Text(
  //                                             customerError!,
  //                                             style: const TextStyle(
  //                                                 color: Colors.red,
  //                                                 fontSize: 13),
  //                                           ),
  //                                         ),
  //                                     ],
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //
  //                             const SizedBox(height: 18),
  //
  //                             /// Start & End Date/Time
  //                             Row(
  //                               children: [
  //                                 Expanded(
  //                                   child: Column(
  //                                     crossAxisAlignment: CrossAxisAlignment.start,
  //                                     children: [
  //                                       Row(
  //                                         children: [
  //                                           Text("Start Date & Time",
  //                                               style: GoogleFonts.lato(
  //                                                   fontSize: 17,
  //                                                   color:
  //                                                   const Color(0xff737373))),
  //                                           const CustomText(
  //                                             text: "*",
  //                                             colors: Colors.red,
  //                                             size: 25,
  //                                           )
  //                                         ],
  //                                       ),
  //                                       const SizedBox(height: 5),
  //                                       TextFormField(
  //                                         controller:
  //                                         remController.startController,
  //                                         readOnly: true,
  //
  //                                         onTap: () => selectDateTime(
  //                                             context: context, isStart: true),
  //                                         style: GoogleFonts.lato(
  //                                           color: Colors.black,
  //                                           fontSize: 17,
  //                                         ),
  //                                         decoration: InputDecoration(
  //                                           suffixIcon: const Icon(
  //                                             Icons.calendar_today_outlined,
  //                                             size: 20,
  //                                             color: Colors.grey,
  //                                           ),
  //                                           errorText: startError,
  //                                           border: OutlineInputBorder(
  //                                             borderRadius: BorderRadius.circular(4),
  //                                             borderSide: BorderSide(
  //                                               color: Colors.grey.shade300,
  //                                             ),
  //                                           ),
  //                                         ),
  //                                       ),
  //                                     ],
  //                                   ),
  //                                 ),
  //                                 const SizedBox(width: 20),
  //                                 Expanded(
  //                                   child: Column(
  //                                     crossAxisAlignment: CrossAxisAlignment.start,
  //                                     children: [
  //                                       Row(
  //                                         children: [
  //                                           Text("End Date & Time",
  //                                               style: GoogleFonts.lato(
  //                                                   fontSize: 17,
  //                                                   color:
  //                                                   const Color(0xff737373))),
  //                                           const CustomText(
  //                                             text: "*",
  //                                             colors: Colors.red,
  //                                             size: 25,
  //                                           )
  //                                         ],
  //                                       ),
  //                                       const SizedBox(height: 5),
  //                                       TextFormField(
  //                                         controller: remController.endController,
  //                                         readOnly: true,
  //                                         onTap: () => selectDateTime(
  //                                             context: context, isStart: false),
  //                                         style: GoogleFonts.lato(
  //                                           color: Colors.black,
  //                                           fontSize: 17,
  //                                         ),
  //                                         decoration: InputDecoration(
  //                                           suffixIcon: const Icon(
  //                                             Icons.calendar_today_outlined,
  //                                             size: 20,
  //                                             color: Colors.grey,
  //                                           ),
  //                                           errorText: endError,
  //                                           border: OutlineInputBorder(
  //                                             borderRadius:
  //                                             BorderRadius.circular(4),
  //                                             borderSide: BorderSide(
  //                                               color: Colors.grey.shade300,
  //                                             ),
  //                                           ),
  //                                         ),
  //                                       ),
  //                                     ],
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                             10.height,
  //                             /// Details field
  //                             Column(
  //                               crossAxisAlignment: CrossAxisAlignment.start,
  //                               children: [
  //                                 Text("Details",
  //                                     style: GoogleFonts.lato(
  //                                         fontSize: 17,
  //                                         color: Color(0xff737373))),
  //                                 const SizedBox(height: 5),
  //                                 TextFormField(
  //                                   textCapitalization:
  //                                   TextCapitalization.sentences,
  //                                   controller:
  //                                   remController.detailsController,
  //                                   maxLines: 2,
  //                                   style: GoogleFonts.lato(
  //                                     color: Colors.black,
  //                                     fontSize: 17,
  //                                   ),
  //                                   decoration: InputDecoration(
  //                                     hintText: "Appointment Points",
  //                                     hintStyle: GoogleFonts.lato(
  //                                       color: const Color(0xFFCCCCCC),
  //                                       fontSize: 17,
  //                                     ),
  //                                     border: OutlineInputBorder(
  //                                       borderRadius: BorderRadius.circular(4),
  //                                       borderSide: BorderSide(
  //                                         color: Colors.grey.shade300,
  //                                       ),
  //                                     ),
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           ],
  //                         );
  //                       },
  //                     ),
  //
  //                     13.height,
  //
  //                     /// Action buttons
  //                     Row(
  //                       mainAxisAlignment: MainAxisAlignment.end,
  //                       children: [
  //                         SizedBox(
  //                           width: 80,
  //                           height: 30,
  //                           child: ElevatedButton(
  //                             style: ElevatedButton.styleFrom(
  //                               backgroundColor: Colors.white,
  //                               foregroundColor: Colors.black,
  //                               shape: RoundedRectangleBorder(
  //                                 borderRadius: BorderRadius.circular(7),
  //                                 side: const BorderSide(color: Color(0xff0078D7)),
  //                               ),
  //                               padding: EdgeInsets.zero,
  //                               elevation: 0,
  //                             ),
  //                             onPressed: () => Navigator.pop(context),
  //                             child: const Text(
  //                               "Cancel",
  //                               style: TextStyle(
  //                                   fontWeight: FontWeight.bold, fontSize: 12),
  //                             ),
  //                           ),
  //                         ),
  //                         const SizedBox(width: 10),
  //                         CustomLoadingButton(
  //                           callback: ()async{
  //                             setState(() {
  //                               titleError = remController.titleController.text.trim().isEmpty
  //                                   ? "Please enter reminder title"
  //                                   : null;
  //                               startError = remController.startController.text.trim().isEmpty
  //                                   ? "Please select start date & time"
  //                                   : null;
  //                               endError = remController.endController.text.trim().isEmpty
  //                                   ? "Please select end date & time"
  //                                   : null;
  //                               employeeError = controllers.selectedEmployeeId.value.isEmpty
  //                                   ? "Please select employee"
  //                                   : null;
  //                               customerError = controllers.selectedCustomerId.value.isEmpty
  //                                   ? "Please select customer"
  //                                   : null;
  //                             });
  //                             if (titleError == null &&
  //                                 startError == null &&
  //                                 endError == null &&
  //                                 employeeError == null &&
  //                                 customerError == null) {
  //                               final provider = Provider.of<ReminderProvider>(context, listen: false);
  //                               remController.insertReminderAPI(context, provider.selectedNotification);
  //                             }else{
  //                               controllers.productCtr.reset();
  //                             }
  //                           },
  //                           height: 40,
  //                           isLoading: true,
  //                           backgroundColor: colorsConst.primary,
  //                           radius: 7,
  //                           width: 150,
  //                           controller: controllers.productCtr,
  //                           isImage: false,
  //                           text: "Save Reminder",
  //                           textColor: Colors.white,
  //                         ),
  //                       ],
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  void showAddReminderDialog(BuildContext context) {
    String? titleError;
    String? startDError;
    String? startTError;
    String? endDError;
    String? endTError;
    String? employeeError;
    String? customerError;
    double screenWidth = MediaQuery.of(context).size.width;
    double textFieldSize = 550;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: EdgeInsets.zero,
              content: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            text: "Add Reminder",
                            colors: colorsConst.textColor,
                            size: 20,
                            isBold: true,
                          ),
                          IconButton(
                              onPressed: (){
                                Navigator.pop(context);
                              },
                              icon: Icon(Icons.clear))
                        ],
                      ),
                      Divider(
                        thickness: 1.5,
                        color: colorsConst.secondary,
                      ),
                      8.height,
                      Container(
                        padding: EdgeInsets.all(16),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color:colorsConst.backgroundColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child:Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTextField(
                              hintText: "Enter Event Name",
                              text: "Event Name",
                              controller: remController.titleController,
                              width: textFieldSize,
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
                            Row(
                              children: [
                                CustomText(text: "Event Type",
                                  colors: colorsConst.fieldHead,
                                  size: 13,
                                ),
                                20.width,
                                Consumer<ReminderProvider>(
                                  builder: (context, provider, _) {
                                    // Determine which fields are required based on selectedNotification
                                    final sel = provider.selectedNotification ?? "";
                                    final employeeRequired = sel == "followup" || (sel != "followup" && sel != "meeting"); // followup => employee required; default both required handled later
                                    final customerRequired = sel == "meeting" || (sel != "followup" && sel != "meeting"); // meeting => customer required

                                    return Row(
                                      children: [
                                        Row(
                                          children: [
                                            Radio<String>(
                                              value: "followup",
                                              groupValue: provider.selectedNotification,
                                              activeColor: const Color(0xFF0078D7),
                                              onChanged: (v) {
                                                provider.setNotification(v!);
                                                // clear errors when changing type
                                                setState(() {
                                                  employeeError = null;
                                                  customerError = null;
                                                });
                                              },
                                            ),
                                            CustomText(
                                              text: "Follow-up",
                                              colors: Colors.black,
                                              size: 15,
                                            ),
                                          ],
                                        ),
                                        20.width,
                                        Row(
                                          children: [
                                            Radio<String>(
                                              value: "meeting",
                                              groupValue: provider.selectedNotification,
                                              activeColor: const Color(0xFF0078D7),
                                              onChanged: (v) {
                                                provider.setNotification(v!);
                                                setState(() {
                                                  employeeError = null;
                                                  customerError = null;
                                                });
                                              },
                                            ),
                                            CustomText(
                                              text: "Appointment",
                                              colors: Colors.black,
                                              size: 15,
                                            ),
                                          ],
                                        ),
                                        // you can add more types similarly
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Obx(() => CustomDateBox(
                                  text: "Start Date",
                                  value: remController.stDate.value,
                                  isOptional: true,
                                  errorText: startDError,
                                  width: 150,
                                  onTap: () {
                                    utils.datePicker(
                                        context: context,
                                        textEditingController: controllers.dateOfConCtr,
                                        pathVal: remController.stDate);
                                    if (startDError != null) {
                                      setState(() {
                                        startDError = null; // clear error on typing
                                      });
                                    }
                                  },
                                ),
                                ),
                                20.width,
                                Obx(() => CustomDateBox(
                                  text: "Start Time",
                                  isOptional: true,
                                  value: remController.stTime.value,
                                  width: 150,
                                  errorText: startTError,
                                  onTap: () {
                                    utils.timePicker(
                                        context: context,
                                        textEditingController:
                                        controllers.timeOfConCtr,
                                        pathVal: remController.stTime);
                                    if (startTError != null) {
                                      setState(() {
                                        startTError = null; // clear error on typing
                                      });
                                    }
                                  },
                                ),
                                ),
                                20.width,
                                CustomDropDown(
                                  saveValue: remController.repeat,
                                  isOptional: true,
                                  valueList: ["Immediately", "5 mins", "15 mins", "10 mins", "30 mins"],
                                  text: "Event Duration",
                                  width: 200,
                                  onChanged: (value) async {
                                    setState(() {
                                      remController.repeat = value.toString();
                                    });
                                  },
                                ),
                              ],
                            ),
                            CustomText(
                              text: "Details",
                              colors: colorsConst.fieldHead,
                              size: 13,),
                            5.height,
                            SizedBox(
                              width: textFieldSize,
                              child: TextFormField(
                                  textCapitalization: TextCapitalization.sentences,
                                  controller: remController.detailsController,
                                  maxLines: 5,
                                  style: GoogleFonts.lato(
                                    color: Colors.black,
                                    fontSize: 17,
                                  ),
                                  decoration: customStyle.inputDecoration(
                                      text: "Enter Details")
                              ),
                            ),
                            20.height,
                            CustomDropDown(
                              saveValue: remController.location,
                              isOptional: false,
                              valueList:["Online", "Office"],
                              text: "Enter Location",
                              width: textFieldSize,
                              onChanged: (value) async {
                                setState(() {
                                  remController.location = value.toString();
                                });
                              },
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Employees column - show red * dynamically based on selected type
                                Consumer<ReminderProvider>(
                                  builder: (context, provider, _) {
                                    final sel = provider.selectedNotification ?? "";
                                    final employeeRequired = sel == "followup" || (sel != "followup" && sel != "meeting");
                                    return SizedBox(
                                      width: 270,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              CustomText(
                                                text: "Employees",
                                                size: 13,
                                                colors: colorsConst.fieldHead,
                                              ),
                                              if (employeeRequired)
                                                const CustomText(
                                                  text: "*",
                                                  colors: Colors.red,
                                                  size: 25,
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
                                                employeeError=null;
                                              });
                                              controllers.selectEmployee(value);
                                            },
                                            onClear: () {
                                              controllers.clearSelectedCustomer();
                                            },
                                          ),
                                          if (employeeError != null)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 4.0),
                                              child: Text(
                                                employeeError!,
                                                style: const TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 13),
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                20.width,
                                // Customer column - star shown dynamically
                                Consumer<ReminderProvider>(
                                  builder: (context, provider, _) {
                                    final sel = provider.selectedNotification ?? "";
                                    final customerRequired = sel == "meeting" || (sel != "followup" && sel != "meeting");
                                    return SizedBox(
                                      width: 270,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              CustomText(
                                                text: "Assigned Customer",
                                                size: 13,
                                                colors: colorsConst.fieldHead,
                                              ),
                                              if (customerRequired)
                                                const CustomText(
                                                  text: "*",
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
                                              setState((){
                                                customerError=null;
                                              });
                                              controllers.selectCustomer(value);
                                            },
                                            onClear: () {
                                              controllers.clearSelectedCustomer();
                                            },
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
                                    );
                                  },
                                ),
                              ],
                            ),
                            20.height,
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomDropDown(
                                  saveValue: remController.repeatWise,
                                  isOptional: false,
                                  valueList:["Never", "Every", "Daily", "Weekly", "Bi-Weekly", "Monthly", "Quarterly", "Half Yearly", "Yearly"],
                                  text: "Repeat",
                                  width: 120,
                                  onChanged: (value) async {
                                    setState(() {
                                      remController.repeatWise = value.toString();
                                    });
                                  },
                                ),
                                10.width,
                                remController.repeatWise=="Never"?0.height:CustomDropDown(
                                  saveValue: remController.repeatEvery,
                                  isOptional: false,
                                  valueList:["1", "2","3", "4", "5", "6", "7", "8", "9", "10","11","12"],
                                  text: "",
                                  width: 60,
                                  onChanged: (value) async {
                                    setState(() {
                                      remController.repeatEvery = value.toString();
                                    });
                                  },
                                ),
                                10.width,
                                remController.repeatWise=="Never"?0.height:CustomDropDown(
                                  saveValue: remController.repeatOn,
                                  isOptional: false,
                                  valueList:["Day(s)", "Week(s)","Month(s)","Quarter(s)", "Year(s)","Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"],
                                  text: "",
                                  width: 100,
                                  onChanged: (value) async {
                                    setState(() {
                                      remController.repeatOn = value.toString();
                                    });
                                  },
                                ),
                                10.width,
                                Obx(() => CustomDateBox(
                                  text: "End Date",
                                  value: remController.enDate.value,
                                  isOptional: true,
                                  errorText: endDError,
                                  width: 150,
                                  onTap: () {
                                    utils.datePicker(
                                        context: context,
                                        textEditingController: controllers.dateOfConCtr,
                                        pathVal: remController.enDate);
                                    if (endDError != null) {
                                      setState(() {
                                        endDError = null; // clear error on typing
                                      });
                                    }
                                  },
                                ),
                                ),
                                10.width,
                                Obx(() => CustomDateBox(
                                  text: "End Time",
                                  isOptional: true,
                                  value: remController.enTime.value,
                                  width: 150,
                                  errorText: endTError,
                                  onTap: () {
                                    utils.timePicker(
                                        context: context,
                                        textEditingController:
                                        controllers.timeOfConCtr,
                                        pathVal: remController.enTime);
                                    if (endTError != null) {
                                      setState(() {
                                        endTError = null; // clear error on typing
                                      });
                                    }
                                  },
                                ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      20.height,
                      Obx(() => Column(
                        children: [
                          ...remController.reminders
                              .asMap()
                              .entries
                              .map((e) => reminderCard(e.key, context)),
                          InkWell(
                            onTap: remController.addReminder,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(Icons.add_circle_outline, color: Colors.blue),
                                6.width,
                                CustomText(
                                  text: "Add More Reminder",
                                  colors: colorsConst.textColor,
                                ),
                              ],
                            ),
                          ),
                        ],
                      )),
                      20.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: 80,
                            height: 30,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7),
                                  side: const BorderSide(color: Color(0xff0078D7)),
                                ),
                                padding: EdgeInsets.zero,
                                elevation: 0,
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                "Cancel",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ),
                          10.width,
                          CustomLoadingButton(
                            callback: () async {
                              if (remController.titleController.text.trim().isEmpty) {
                                setState(() {
                                  titleError = "Please enter reminder title";
                                });
                                controllers.productCtr.reset();
                                return;
                              }
                              if (remController.stDate.value.isEmpty) {
                                setState(() {
                                  startDError = "Please select start date";
                                });
                                controllers.productCtr.reset();
                                return;
                              }
                              if (remController.stTime.value.isEmpty) {
                                setState(() {
                                  startTError = "Please select start time";
                                });
                                controllers.productCtr.reset();
                                return;
                              }
                              if (remController.enDate.value.isEmpty) {
                                setState(() {
                                  endDError = "Please select end date";
                                });
                                controllers.productCtr.reset();
                                return;
                              }
                              if (remController.enTime.value.isEmpty) {
                                setState(() {
                                  endTError = "Please select end time";
                                });
                                controllers.productCtr.reset();
                                return;
                              }
                              final selType = Provider.of<ReminderProvider>(context, listen: false).selectedNotification ?? "";
                              final needEmployee = selType == "followup" || (selType != "followup" && selType != "meeting");
                              final needCustomer = selType == "meeting" || (selType != "followup" && selType != "meeting");

                              if (needEmployee && controllers.selectedEmployeeId.value.isEmpty) {
                                setState(() {
                                  employeeError = "Please select employee";
                                });
                                controllers.productCtr.reset();
                                return;
                              }

                              if (needCustomer && controllers.selectedCustomerId.value.isEmpty) {
                                setState(() {
                                  customerError = "Please select customer";
                                });
                                controllers.productCtr.reset();
                                return;
                              }
                              remController.insertReminderAPI(context, Provider.of<ReminderProvider>(context, listen: false).selectedNotification);
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
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }


  void showUpdateReminderDialog(String id,BuildContext context) {
    String? titleError;
    String? startError;
    String? endError;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 80, vertical: 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: EdgeInsets.zero,
              content: Container(
                width: 630,
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Update Reminder",
                            style: GoogleFonts.lato(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Text(
                              "×",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Divider(thickness: 1, color: Colors.grey.shade300),
                      const SizedBox(height: 8),

                      /// Reminder title
                      Text("Reminder Title",
                          style: GoogleFonts.lato(
                              fontSize: 17, color: Color(0xff737373))),
                      const SizedBox(height: 5),
                      TextFormField(
                        textCapitalization: TextCapitalization.sentences,
                        controller: remController.updateTitleController,
                        onChanged: (value) {
                          if (value.toString().isNotEmpty) {
                            String newValue = value.toString()[0].toUpperCase() + value.toString().substring(1);
                            if (newValue != value) {
                              remController.updateTitleController.value = remController.updateTitleController.value.copyWith(
                                text: newValue,
                                selection: TextSelection.collapsed(offset: newValue.length),
                              );
                            }
                          }
                          if (value.trim().isNotEmpty) {
                            setState(() {
                              titleError = null;
                            });
                          }
                        },
                        style: GoogleFonts.lato(
                          color: Colors.black,
                          fontSize: 17,
                        ),
                        decoration: InputDecoration(
                          hintText: "Reminder title",
                          errorText: titleError,
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

                      Text("Notification Type",
                          style: GoogleFonts.lato(
                              fontSize: 17, color: const Color(0xff737373))),
                      Consumer<ReminderProvider>(
                        builder: (context, provider, _) {
                          return Row(
                            children: [
                              Expanded(
                                child: RadioListTile(
                                  title: Text(
                                    "Follow-up Reminder",
                                    style: GoogleFonts.lato(
                                      color: Colors.black,
                                      fontSize: 17,
                                    ),
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
                                  title: Text(
                                    "Appointment Reminder",
                                    style: GoogleFonts.lato(
                                      color: Colors.black,
                                      fontSize: 17,
                                    ),
                                  ),
                                  value: "meeting",
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
                                          value: remController.updateLocation,
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
                                                  () => remController.updateLocation = v),
                                        ),
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
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text("Start Date & Time",
                                            style: GoogleFonts.lato(
                                                fontSize: 17,
                                                color:
                                                const Color(0xff737373))),
                                        const SizedBox(height: 5),
                                        TextFormField(
                                          controller:
                                          remController.updateStartController,
                                          readOnly: true,
                                          onTap: () => selectDateTime(
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
                                            errorText: startError,
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
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text("End Date & Time",
                                            style: GoogleFonts.lato(
                                                fontSize: 17,
                                                color:
                                                const Color(0xff737373))),
                                        const SizedBox(height: 5),
                                        TextFormField(
                                          controller: remController.updateEndController,
                                          readOnly: true,
                                          onTap: () => selectDateTime(
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
                                            errorText: endError,
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
                                    controller: remController.updateDetailsController,
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

                      13.height,

                      /// Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: 80,
                            height: 30,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7),
                                  side: const BorderSide(color: Color(0xff0078D7)),
                                ),
                                padding: EdgeInsets.zero,
                                elevation: 0,
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                "Cancel",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          CustomLoadingButton(
                            callback: ()async{
                              setState(() {
                                titleError = remController.updateTitleController.text.trim().isEmpty
                                    ? "Please enter reminder title"
                                    : null;
                                startError = remController.updateStartController.text.trim().isEmpty
                                    ? "Please select start date & time"
                                    : null;
                                endError = remController.updateEndController.text.trim().isEmpty
                                    ? "Please select end date & time"
                                    : null;
                              });
                              if (titleError == null && startError == null && endError == null) {
                                final provider = Provider.of<ReminderProvider>(context, listen: false);
                                remController.updateReminderAPI(context, provider.selectedNotification,id);
                              }else{
                                controllers.productCtr.reset();
                              }
                            },
                            height: 40,
                            isLoading: true,
                            backgroundColor: colorsConst.primary,
                            radius: 7,
                            width: 150,
                            controller: controllers.productCtr,
                            isImage: false,
                            text: "Update Reminder",
                            textColor: Colors.white,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget reminderCard(int index,BuildContext context) {
    final reminder = remController.reminders[index];
    return  Container(
      //width: 550,
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
            width:520,
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
                          )).toList(),
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
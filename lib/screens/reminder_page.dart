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
import '../common/utilities/utils.dart';
import '../components/custom_text.dart';
import '../controller/controller.dart';
import '../provider/reminder_provider.dart';

class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key});

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  bool showFollowUpCalendar = false;
  bool showMeetingCalendar = false;

  DateTime followUpSelectedDay = DateTime.now();
  DateTime meetingSelectedDay = DateTime.now();

// State for dropdown & repeat
  String _defaultTime = "Immediately";
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
                height: 480,
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
                              Text(
                                "=",
                                style: GoogleFonts.lato(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black, // optional color
                                ),
                              ),
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
                                // Web
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 10,
                                      height: 10,
                                      child: Checkbox(
                                        value: cp.web,
                                        onChanged: cp.toggleWeb,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        side: const BorderSide(
                                          // 👈 border color when unchecked
                                          color: Color(0xFF757575),
                                        ),
                                        fillColor: MaterialStateProperty
                                            .resolveWith<Color>((states) {
                                          if (states.contains(
                                              MaterialState.selected)) {
                                            return const Color(
                                                0xFF0078D7); // blue when checked
                                          }
                                          return Colors
                                              .white; // white background when unchecked
                                        }),
                                        checkColor:
                                            Colors.white, // checkmark color
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Web",
                                      style: GoogleFonts.lato(
                                        color: Colors.black,
                                        fontSize: 16,

                                        // fontWeight: FontWeight.bold,
                                      ),
                                      // TextStyle(
                                      //     fontSize: 16,
                                      //     color: Colors.black)
                                    ),
                                  ],
                                ),

                                // Email
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
                                          // 👈 border color when unchecked
                                          color: Color(0xFF757575),
                                        ),
                                        fillColor: MaterialStateProperty
                                            .resolveWith<Color>((states) {
                                          if (states.contains(
                                              MaterialState.selected)) {
                                            return Color(
                                                0xFF0078D7); // blue when checked
                                          }
                                          return Colors
                                              .white; // white when unchecked
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

                                // SMS
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: Checkbox(
                                        value: cp.sms,
                                        onChanged: cp.toggleSms,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        side: const BorderSide(
                                          // 👈 border color when unchecked
                                          color: Color(0xFF757575),
                                        ),
                                        fillColor: MaterialStateProperty
                                            .resolveWith<Color>((states) {
                                          if (states.contains(
                                              MaterialState.selected)) {
                                            return Color(
                                                0xFF0078D7); // blue when checked
                                          }
                                          return Colors
                                              .white; // white when unchecked
                                        }),
                                        checkColor: Colors.white,
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
                                      width: 16,
                                      height: 16,
                                      child: Checkbox(
                                        value: cp.app,
                                        onChanged: cp.toggleApp,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        side: const BorderSide(
                                          // 👈 border color when unchecked
                                          color: Color(0xFF757575),
                                        ),
                                        fillColor: MaterialStateProperty
                                            .resolveWith<Color>((states) {
                                          if (states.contains(
                                              MaterialState.selected)) {
                                            return Color(
                                                0xFF0078D7); // blue when checked
                                          }
                                          return Colors
                                              .white; // white when unchecked
                                        }),
                                        checkColor: Colors.white,
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
                        dropdownColor:
                            Colors.white, // 👈 dropdown list background = white
                        style: GoogleFonts.lato(
                          // 👈 text style for selected + menu items
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        items: ["Immediately", "5 mins", "10 mins", "30 mins"]
                            .map(
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

                      SizedBox(height: 30),

                      // ✅ Repeat (Radio buttons in 2 rows)
                      const Text("Repeat (Optional)",
                          style: TextStyle(fontSize: 18, color: Colors.black)),
                      Consumer<ReminderProvider>(
                        builder: (context, cp, child) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => cp.setRepeatOption("None"),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Radio<String>(
                                        value: "None",
                                        groupValue: cp.repeatOption,
                                        onChanged: (v) =>
                                            cp.setRepeatOption(v!),
                                        activeColor: const Color(
                                            0xFF0078D7), // blue when selected
                                      ),
                                      const SizedBox(
                                          width:
                                              4), // reduce space between radio and text
                                      Text(
                                        "None",
                                        style: GoogleFonts.lato(
                                          color: Colors.black,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () => cp.setRepeatOption("Daily"),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Radio<String>(
                                        value: "Daily",
                                        groupValue: cp.repeatOption,
                                        onChanged: (v) =>
                                            cp.setRepeatOption(v!),
                                        activeColor: const Color(
                                            0xFF0078D7), // blue when selected
                                      ),
                                      const SizedBox(
                                          width:
                                              4), // reduced space between radio & text
                                      Text(
                                        "Daily",
                                        style: GoogleFonts.lato(
                                          color: Colors.black,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () => cp.setRepeatOption("Weekly"),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Radio<String>(
                                        value: "Weekly",
                                        groupValue: cp.repeatOption,
                                        onChanged: (v) =>
                                            cp.setRepeatOption(v!),
                                        activeColor: const Color(
                                            0xFF0078D7), // blue when selected
                                      ),
                                      const SizedBox(
                                          width:
                                              4), // reduce space between radio & text
                                      Text(
                                        "Weekly",
                                        style: GoogleFonts.lato(
                                          color: Colors.black,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () => cp.setRepeatOption("Monthly"),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Radio<String>(
                                        value: "Monthly",
                                        groupValue: cp.repeatOption,
                                        onChanged: (v) =>
                                            cp.setRepeatOption(v!),
                                        activeColor: const Color(
                                            0xFF0078D7), // blue when selected
                                      ),
                                      const SizedBox(
                                          width:
                                              4), // reduced space between radio & text
                                      Text(
                                        "Monthly",
                                        style: GoogleFonts.lato(
                                          color: Colors.black,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),

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
                                backgroundColor:
                                    const Color(0xff0078D7), // fill color
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(7), // border radius
                                ),
                              ),
                              onPressed: () {},
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

  String? _selectedNotification;
  Map<DateTime, TimeOfDay> _selectedStartDatesTimes = {};
  Map<DateTime, TimeOfDay> _selectedEndDatesTimes = {};

  TextEditingController _startController = TextEditingController();
  TextEditingController _endController = TextEditingController();

  TimeOfDay _selectedTime = TimeOfDay.now();

  Future<void> _selectDateTime({
    required BuildContext context,
    required bool isStart,
  })
  async {
    Map<DateTime, TimeOfDay> selectedDatesTimes =
        isStart ? _selectedStartDatesTimes : _selectedEndDatesTimes;
    TextEditingController controller =
        isStart ? _startController : _endController;

    // Initialize dialogSelectedTime
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
                        selectionMode: DateRangePickerSelectionMode.range,
                        extendableRangeSelectionDirection:
                            ExtendableRangeSelectionDirection.none,
                        selectionColor: const Color(0xff0078D7),
                        startRangeSelectionColor: const Color(0xff0078D7),
                        endRangeSelectionColor: const Color(0xff0078D7),
                        rangeSelectionColor: const Color(0xffD9ECFF),
                        todayHighlightColor: const Color(0xff0078D7),
                        headerStyle: DateRangePickerHeaderStyle(
                          backgroundColor: Colors.white,
                          textStyle: TextStyle(
                            color: Color(0xff0078D7),
                            // fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        onSelectionChanged: (args) {
                          if (args.value is PickerDateRange) {
                            DateTime? start = args.value.startDate;
                            DateTime? end =
                                args.value.endDate ?? args.value.startDate;
                            if (start != null && end != null) {
                              setDialogState(() {
                                selectedDatesTimes.clear();
                                selectedDatesTimes[start] = dialogSelectedTime;
                                selectedDatesTimes[end] = dialogSelectedTime;
                              });
                            }
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
                                      // Overall dialog background
                                      backgroundColor: const Color(0xFFE7EEF8),
                                      // Hour / Minute boxes
                                      hourMinuteShape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(8)),
                                        side: BorderSide(color: Colors.black26),
                                      ),
                                      hourMinuteColor: Colors.white,
                                      hourMinuteTextColor: const Color(0xff0078D7),
                                      // timeSelectorSeparatorColor:  MaterialStateColor.resolveWith((states) {
                                      //   if (states.contains(MaterialState.selected)) {
                                      //     return Colors.white;
                                      //   }
                                      //   return Colors.black;
                                      // }),
                                      // AM / PM buttons
                                      dayPeriodShape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(6)),
                                        side: BorderSide(color: Color(0xff0078D7)),
                                      ),
                                      dayPeriodColor: MaterialStateColor.resolveWith((states) {
                                        if (states.contains(MaterialState.selected)) {
                                          return const Color(0xff0078D7);
                                        }
                                        return Colors.white;
                                      }),
                                      dayPeriodTextColor: MaterialStateColor.resolveWith((states) {
                                        if (states.contains(MaterialState.selected)) {
                                          return Colors.white;
                                        }
                                        return Colors.black;
                                      }),

                                      // Analog clock circle
                                      dialBackgroundColor: Colors.white, // normal clock circle
                                      dialHandColor: const Color(0xff0078D7), // blue hand

                                      // Clock numbers
                                      dialTextColor: Colors.black, // unselected numbers
                                      dialTextStyle: MaterialStateTextStyle.resolveWith((states) {
                                        if (states.contains(MaterialState.selected)) {
                                          return const TextStyle(
                                            color: Colors.white, // selected number
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          );
                                        }
                                        return const TextStyle(
                                          color: Colors.black, // unselected numbers
                                          fontSize: 18,
                                        );
                                      }),

                                      // Selected time at the top
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
                                    confirmText: "",
                                  ),
                                )


                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Quick action buttons
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
                            setState(() {
                              // Update selected dates with final time
                              selectedDatesTimes.updateAll(
                                  (key, value) => dialogSelectedTime);

                              final sortedDates = selectedDatesTimes.keys
                                  .toList()
                                ..sort((a, b) => a.compareTo(b));
                              controller.text =
                                  "${sortedDates.first.day}-${sortedDates.first.month}-${sortedDates.first.year} - "
                                  "${sortedDates.last.day}-${sortedDates.last.month}-${sortedDates.last.year} "
                                  "${dialogSelectedTime.format(context)}";
                            });
                            Navigator.pop(context);
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

  void _showAddReminderDialog() {
    String? location;
    String? repeat;
    String? assignment;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 80, vertical: 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Container(
                color: Colors.white,
                width: 630,
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Add Reminder",
                            style: GoogleFonts.lato(
                              fontSize: 18,
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
                              //     color: Colors.black,
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
                      const SizedBox(height: 8),
                      Divider(thickness: 1, color: Colors.grey.shade300),
                      const SizedBox(height: 8),

                      // Reminder Title
                      Text("Reminder Title",
                          style: GoogleFonts.lato(
                              fontSize: 17, color: Color(0xff737373))),
                      const SizedBox(height: 5),
                      TextFormField(
                        textCapitalization: TextCapitalization.sentences,
                        style: GoogleFonts.lato(
                          // 👈 Lato font for input text
                          color: Colors.black,
                          fontSize: 17,
                        ),
                        decoration: InputDecoration(
                          hintText: "Reminder title",
                          hintStyle: TextStyle(
                            color: Color(0xFFCCCCCC),
                            fontSize: 17,
                            fontFamily: GoogleFonts.lato()
                                .fontFamily, // optional: make hint also Lato
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

                      const SizedBox(height: 18),

                      // Notification Type
                      Text("Notification Type",
                          style: GoogleFonts.lato(
                              fontSize: 17, color: Color(0xff737373))),
                      Consumer<ReminderProvider>(
                        builder: (context, provider, _) {
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: RadioListTile(
                                      title: Text(
                                        "Follow-up Reminder",
                                        style: GoogleFonts.lato(
                                          color: Colors.black,
                                          fontSize: 17, // adjust as needed
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
                                        "Meeting Reminder",
                                        style: GoogleFonts.lato(
                                          color: Colors.black,
                                          fontSize: 17, // adjust size as needed
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
                              ),
                              Row(
                                children: [
                                  // Task Reminder
                                  Expanded(
                                    child: RadioListTile(
                                      title: Text(
                                        "Task Reminder",
                                        style: GoogleFonts.lato(
                                          color: Colors.black,
                                          fontSize: 17, // adjust size if needed
                                        ),
                                      ),
                                      value: "task",
                                      groupValue: provider.selectedNotification,
                                      activeColor: const Color(0xFF0078D7),
                                      onChanged: (v) =>
                                          provider.setNotification(v as String),
                                    ),
                                  ),

                                  // Payment Reminder
                                  // Expanded(
                                  //   child: RadioListTile(
                                  //     title: const Text("Payment Reminder"),
                                  //     value: "payment",
                                  //     groupValue: provider.selectedNotification,
                                  //     activeColor: const Color(0xFF0078D7),
                                  //     onChanged: (v) =>
                                  //         provider.setNotification(v as String),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 8),

                      // 🔽 Hide everything below if Task Reminder is selected
                      Consumer<ReminderProvider>(
                        builder: (context, provider, _) {
                          if (provider.selectedNotification == "task") {
                            return const SizedBox.shrink();
                          }
                          return Column(
                            children: [
                              // Location & Repeat
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
                                                color: Color(0xff737373))),
                                        const SizedBox(height: 5),
                                        DropdownButtonFormField<String>(
                                          value: location,
                                          dropdownColor: Colors
                                              .white, // 👈 dropdown menu background
                                          style: GoogleFonts.lato(
                                            // 👈 text style for selected value
                                            color: Colors.black,
                                            fontSize: 14,
                                          ),
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors
                                                .white, // field background
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
                                                      // 👈 text style for dropdown items
                                                      color: Colors.black,
                                                      fontSize: 17,
                                                    ),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                          onChanged: (v) =>
                                              setState(() => location = v),
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
                                        Text("Repeat",
                                            style: GoogleFonts.lato(
                                                fontSize: 17,
                                                color: Color(0xff737373))),
                                        const SizedBox(height: 5),
                                        DropdownButtonFormField<String>(
                                          value: repeat,
                                          dropdownColor: Colors
                                              .white, // 👈 dropdown menu background
                                          style: GoogleFonts.lato(
                                            // 👈 text style for selected value
                                            color: Colors.black,
                                            fontSize: 14,
                                          ),
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors
                                                .white, // field background
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
                                          items: ["Every Day", "Every Week"]
                                              .map(
                                                (e) => DropdownMenuItem(
                                                  value: e,
                                                  child: Text(
                                                    e,
                                                    style: GoogleFonts.lato(
                                                      // 👈 text style for dropdown items
                                                      color: Colors.black,
                                                      fontSize: 17,
                                                    ),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                          onChanged: (v) =>
                                              setState(() => repeat = v),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 13),

                              // Employees & Assignment
                              Row(
                                children: [
                                  Expanded(
                                    child: Consumer<ReminderProvider>(
                                      builder: (context, provider, _) {
                                        if (provider.selectedNotification ==
                                            "meeting") {
                                          // Single dropdown for Meeting Reminder → heading visible, no checkboxes
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Employees",
                                                style: GoogleFonts.lato(
                                                  fontSize: 17,
                                                  color:
                                                      const Color(0xff737373),
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              DropdownButtonFormField<String>(
                                                value: provider
                                                        .selectedEmployees
                                                        .isNotEmpty
                                                    ? provider
                                                        .selectedEmployees.first
                                                    : null,
                                                hint: Text(
                                                  "",
                                                  style: GoogleFonts.lato(
                                                      color: Colors.black,
                                                      fontSize: 14),
                                                ),
                                                dropdownColor: Colors
                                                    .white, // 👈 dropdown menu background
                                                style: GoogleFonts.lato(
                                                  // 👈 text style for selected value
                                                  color: Colors.black,
                                                  fontSize: 17,
                                                ),
                                                items: provider.allEmployees
                                                    .map(
                                                      (e) => DropdownMenuItem(
                                                        value: e,
                                                        child: Text(
                                                          e,
                                                          style: GoogleFonts.lato(
                                                              color:
                                                                  Colors.black,
                                                              fontSize:
                                                                  17), // 👈 dropdown item text
                                                        ),
                                                      ),
                                                    )
                                                    .toList(),
                                                onChanged: (val) {
                                                  if (val != null)
                                                    provider
                                                        .selectSingleEmployee(
                                                            val);
                                                },
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor: Colors
                                                      .white, // field background
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                    borderSide: BorderSide(
                                                        color: Colors
                                                            .grey.shade300),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                    borderSide: BorderSide(
                                                        color: Colors
                                                            .grey.shade300),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                    borderSide: BorderSide(
                                                        color: Colors
                                                            .grey.shade300),
                                                  ),
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 12,
                                                          vertical: 10),
                                                ),
                                              ),
                                            ],
                                          );
                                        } else if (provider
                                                .selectedNotification ==
                                            "followup") {
                                          // Multi-select checkboxes → blue highlights for selected
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Employees",
                                                style: GoogleFonts.lato(
                                                  fontSize: 17,
                                                  color:
                                                      const Color(0xff737373),
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              GestureDetector(
                                                onTap: provider.toggleDropdown,
                                                child: AbsorbPointer(
                                                  child: TextFormField(
                                                    readOnly: true,
                                                    style: GoogleFonts.lato(
                                                        color: Colors.black,
                                                        fontSize:
                                                            17), // 👈 Lato font size 17
                                                    decoration: InputDecoration(
                                                      hintText: provider
                                                              .selectedText
                                                              .isEmpty
                                                          ? ""
                                                          : provider
                                                              .selectedText,
                                                      hintStyle: GoogleFonts.lato(
                                                          color: Colors.black,
                                                          fontSize:
                                                              17), // hint size 17
                                                      suffixIcon: Icon(
                                                        provider.showDropdown
                                                            ? Icons
                                                                .keyboard_arrow_up
                                                            : Icons
                                                                .keyboard_arrow_down,
                                                      ),
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                        borderSide: BorderSide(
                                                            color: Colors
                                                                .grey.shade300),
                                                      ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                        borderSide: BorderSide(
                                                            color: Colors
                                                                .grey.shade300),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                        borderSide: BorderSide(
                                                            color: Colors
                                                                .grey.shade300),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              if (provider.showDropdown)
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    border: Border.all(
                                                        color: Colors
                                                            .grey.shade300),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      // Select All
                                                      CheckboxListTile(
                                                        title: Text(
                                                          "Select All",
                                                          style: GoogleFonts.lato(
                                                              color:
                                                                  Colors.black,
                                                              fontSize:
                                                                  17), // size 17
                                                        ),
                                                        value: provider
                                                            .isAllSelected,
                                                        onChanged: provider
                                                            .toggleSelectAll,
                                                        activeColor:
                                                            const Color(
                                                                0xFF0078D7),
                                                        controlAffinity:
                                                            ListTileControlAffinity
                                                                .leading,
                                                      ),
                                                      // Individual Employees
                                                      ...provider.allEmployees
                                                          .map(
                                                        (e) => CheckboxListTile(
                                                          title: Text(
                                                            e,
                                                            style: GoogleFonts.lato(
                                                                color: Colors
                                                                    .black,
                                                                fontSize:
                                                                    17), // size 17
                                                          ),
                                                          value: provider
                                                              .selectedEmployees
                                                              .contains(e),
                                                          onChanged: (val) =>
                                                              provider
                                                                  .toggleEmployee(
                                                                      e, val),
                                                          activeColor:
                                                              const Color(
                                                                  0xFF0078D7),
                                                          controlAffinity:
                                                              ListTileControlAffinity
                                                                  .leading,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          );
                                        } else {
                                          // Task Reminder → hide completely
                                          return const SizedBox.shrink();
                                        }
                                      },
                                    ),
                                  ),

                                  const SizedBox(width: 20),

                                  // Right side -> Assigned Customer
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Assigned Customer",
                                          style: GoogleFonts.lato(
                                            fontSize: 17,
                                            color: const Color(0xff737373),
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        DropdownButtonFormField<String>(
                                          value: assignment,
                                          isExpanded: true,
                                          dropdownColor: Colors
                                              .white, // 👈 dropdown menu background
                                          style: GoogleFonts.lato(
                                            // 👈 selected value text style
                                            color: Colors.black,
                                            fontSize: 17,
                                          ),
                                          items: ["Team A", "Team B", "Team C"]
                                              .map(
                                                (e) => DropdownMenuItem(
                                                  value: e,
                                                  child: Text(
                                                    e,
                                                    style: GoogleFonts.lato(
                                                      // 👈 dropdown item text style
                                                      color: Colors.black,
                                                      fontSize: 17,
                                                    ),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                          onChanged: (v) =>
                                              setState(() => assignment = v!),
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors
                                                .white, // field background
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              borderSide: BorderSide(
                                                  color: Colors.grey.shade300),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              borderSide: BorderSide(
                                                  color: Colors.grey.shade300),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              borderSide: BorderSide(
                                                  color: Colors.grey.shade300),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 10),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Expanded(
                                  //   child: Column(
                                  //     crossAxisAlignment: CrossAxisAlignment.start,
                                  //     children: [
                                  //       Text("Assigned Customer",
                                  //           style: GoogleFonts.lato(
                                  //               fontSize: 17, color: Color(0xff737373))),
                                  //       const SizedBox(height: 5),
                                  //       DropdownButtonFormField<String>(
                                  //         value: assignment,
                                  //         isExpanded: true,
                                  //         items: ["Team A", "Team B", "Team C"]
                                  //             .map((e) => DropdownMenuItem(
                                  //             value: e, child: Text(e)))
                                  //             .toList(),
                                  //         onChanged: (v) => setState(() => assignment = v!),
                                  //         decoration: InputDecoration(
                                  //           filled: true,
                                  //           fillColor: Colors.white,
                                  //           border: OutlineInputBorder(
                                  //             borderRadius: BorderRadius.circular(4),
                                  //             borderSide: BorderSide(color: Colors.grey.shade300, ),
                                  //           ),
                                  //           enabledBorder: OutlineInputBorder(
                                  //             borderRadius: BorderRadius.circular(4),
                                  //             borderSide: BorderSide(color: Colors.grey.shade300,),
                                  //           ),
                                  //           focusedBorder: OutlineInputBorder(
                                  //             borderRadius: BorderRadius.circular(4),
                                  //             borderSide: BorderSide(color: Colors.grey.shade300),
                                  //           ),
                                  //           contentPadding: const EdgeInsets.symmetric(
                                  //               horizontal: 12, vertical: 10),
                                  //         ),
                                  //       ),
                                  //     ],
                                  //   ),
                                  // ),
                                ],
                              ),
                              const SizedBox(height: 18),
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
                                                color: Color(0xff737373))),
                                        const SizedBox(height: 5),
                                        TextFormField(
                                          controller: _startController,
                                          readOnly: true,
                                          onTap: () => _selectDateTime(
                                              context: context, isStart: true),
                                          style: GoogleFonts.lato(
                                            // 👈 Lato font
                                            color: Colors.black,
                                            fontSize: 17, // 👈 font size 17
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
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              borderSide: BorderSide(
                                                color: Colors.grey.shade300,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
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
                                                color: Color(0xff737373))),
                                        const SizedBox(height: 5),
                                        TextFormField(
                                          controller: _endController,
                                          readOnly: true,
                                          onTap: () => _selectDateTime(
                                              context: context, isStart: false),
                                          style: GoogleFonts.lato(
                                            // 👈 Lato font
                                            color: Colors.black,
                                            fontSize: 17, // 👈 font size 17
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
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              borderSide: BorderSide(
                                                color: Colors.grey.shade300,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
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
                              const SizedBox(height: 11),
                              // Details
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
                                    maxLines: 2,
                                    style: GoogleFonts.lato(
                                      // 👈 Lato font for typed text
                                      color: Colors.black,
                                      fontSize: 17, // adjust size as needed
                                    ),
                                    decoration: InputDecoration(
                                      hintText: "Meeting Points",
                                      hintStyle: GoogleFonts.lato(
                                        // 👈 Lato font for hint text
                                        color: const Color(0xFFCCCCCC),
                                        fontSize: 17,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
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

                      const SizedBox(height: 13),

                      // Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: 80,
                            height: 35,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE7EEF8),
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7),
                                  side: const BorderSide(
                                      color: Color(0xff0078D7)),
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
                          SizedBox(
                            height: 35,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff0078D7),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7),
                                ),
                              ),
                              onPressed: () {},
                              child: const Text(
                                "Save Reminder",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
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
      backgroundColor: Colors.white,
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
                       onPressed: _showAddReminderDialog,
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
               5.height,
               Divider(
                 thickness: 1.5,
                 color: colorsConst.secondary,
               ),
               10.height,
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
                                 color: context
                                     .watch<ReminderProvider>()
                                     .isFollowUpActive
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
                                 const SizedBox(width: 7),
                                 SvgPicture.asset('assets/images/edit.svg',
                                     width: 20, height: 20),
                                 const SizedBox(width: 7),
                                 SvgPicture.asset('assets/images/delete.svg',
                                     width: 20, height: 20),
                               ],
                             ),
                           ),
                         ),

                         const SizedBox(width: 45),

                         // ---------------- Meeting Reminder ----------------
                         GestureDetector(
                           onTap: () {
                             context.read<ReminderProvider>().toggleReminder("meeting");
                           },
                           child: Container(
                             width: 230,
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
                                     "Meeting Reminder",
                                     style: GoogleFonts.lato(
                                       fontSize: 16,
                                       fontWeight: FontWeight.bold,
                                       color: Colors.black87,
                                     ),
                                   ),
                                 ),
                                 Row(
                                   children: [
                                     SvgPicture.asset('assets/images/edit.svg',
                                         width: 20, height: 20),
                                     const SizedBox(width: 7),
                                     SvgPicture.asset('assets/images/delete.svg',
                                         width: 20, height: 20),
                                   ],
                                 ),
                               ],
                             ),
                           ),
                         ),

                         const SizedBox(width: 50),

                         // ---------------- Calendar (only for Follow-up) ----------------
                         if (context.watch<ReminderProvider>().isFollowUpActive)
                           Container(
                             width: 340,
                             height: 400,
                             decoration: BoxDecoration(
                               color: Colors.white,
                               borderRadius: BorderRadius.circular(7),
                               boxShadow: [
                                 BoxShadow(
                                   color: Colors.grey.shade300,
                                   offset: Offset(0, 1),
                                   blurRadius: 5,
                                   spreadRadius: 3,
                                 )
                               ],
                             ),
                             child: TableCalendar(
                               firstDay: DateTime(2020),
                               lastDay: DateTime(2100),
                               focusedDay: DateTime.now(),
                               selectedDayPredicate: (day) {
                                 return context
                                     .watch<ReminderProvider>()
                                     .followUpSelectedDays
                                     .any((d) => isSameDay(d, day));
                               },
                               onDaySelected: (selectedDay, focusedDay) {
                                 context
                                     .read<ReminderProvider>()
                                     .toggleFollowUpDay(selectedDay);
                               },
                               calendarStyle: CalendarStyle(
                                 isTodayHighlighted: true,
                                 selectedDecoration: BoxDecoration(
                                   color: Color(0xFF0078D7),
                                   shape: BoxShape.circle,
                                 ),
                                 todayDecoration: BoxDecoration(
                                   color: Colors.grey.shade300,
                                   shape: BoxShape.circle,
                                 ),
                               ),
                               headerStyle: HeaderStyle(
                                 formatButtonVisible: false,
                                 titleCentered: true,
                               ),
                             ),
                           ),
                       ],
                     )
                   ],
                 ),
               ),
             ],
           ),
         ),)
        ],
      ),
    );
  }
}

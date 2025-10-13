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
  bool showFollowUpCalendar = false;
  bool showMeetingCalendar = false;

  DateTime followUpSelectedDay = DateTime.now();
  DateTime meetingSelectedDay = DateTime.now();

// State for dropdown & repeat

  Map<DateTime, TimeOfDay> _selectedStartDatesTimes = {};
  Map<DateTime, TimeOfDay> _selectedEndDatesTimes = {};
  TimeOfDay _selectedTime = TimeOfDay.now();

  Future<void> _selectDateTime({
    required BuildContext context,
    required bool isStart,
  })
  async {
    Map<DateTime, TimeOfDay> selectedDatesTimes =
        isStart ? _selectedStartDatesTimes : _selectedEndDatesTimes;
    TextEditingController controller =
        isStart ? remController.startController : remController.endController;

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
                        selectionMode: DateRangePickerSelectionMode.single,
                        extendableRangeSelectionDirection:
                            ExtendableRangeSelectionDirection.none,
                        selectionColor: colorsConst.primary,
                        startRangeSelectionColor: colorsConst.primary,
                        endRangeSelectionColor: colorsConst.primary,
                        rangeSelectionColor: const Color(0xffD9ECFF),
                        todayHighlightColor: colorsConst.primary,
                        headerStyle: DateRangePickerHeaderStyle(
                          backgroundColor: Colors.white,
                          textStyle: TextStyle(
                            color: colorsConst.primary,
                            // fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
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
                                        hourMinuteColor: MaterialStateColor.resolveWith((states) {
                                          if (states.contains(MaterialState.selected)) {
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
                                      confirmText: "",
                                    ),
                                  )
                              )
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
                              selectedDatesTimes.updateAll(
                                    (key, value) => dialogSelectedTime,
                              );
                              if (selectedDatesTimes.isNotEmpty) {
                                final selectedDate = selectedDatesTimes.keys.first;
                                controller.text =
                                "${selectedDate.day}-${selectedDate.month}-${selectedDate.year} "
                                    "${dialogSelectedTime.format(context)}";
                              }
                              print("Selected ${isStart ? "start" : "end"} dates & times: $selectedDatesTimes");
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
    // local error variables
    String? titleError;
    String? startError;
    String? endError;
    String? employeeError;
    String? customerError;

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
                        controller: remController.titleController,
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
                                    "Meeting Reminder",
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
                                        Text(
                                          "Employees",
                                          style: GoogleFonts.lato(
                                            fontSize: 17,
                                            color: const Color(0xff737373),
                                          ),
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
                                          textEditingController:
                                          controllers.empController,
                                          onSelected: (value) {
                                            controllers.selectEmployee(value);
                                          },
                                          onClear: () {
                                            controllers.clearSelectedCustomer();
                                          },
                                        ),
                                        if (employeeError != null)
                                          Padding(
                                            padding:
                                            const EdgeInsets.only(top: 4.0),
                                            child: Text(
                                              employeeError!,
                                              style: const TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 13),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  20.width,
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
                                          textEditingController:
                                          controllers.cusController,
                                          onSelected: (value) {
                                            controllers.selectCustomer(value);
                                          },
                                          onClear: () {
                                            controllers.clearSelectedCustomer();
                                          },
                                        ),
                                        if (customerError != null)
                                          Padding(
                                            padding:
                                            const EdgeInsets.only(top: 4.0),
                                            child: Text(
                                              customerError!,
                                              style: const TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 13),
                                            ),
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
                                          remController.startController,
                                          readOnly: true,
                                          onTap: () => _selectDateTime(
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
                                          controller: remController.endController,
                                          readOnly: true,
                                          onTap: () => _selectDateTime(
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
                                    controller:
                                    remController.detailsController,
                                    maxLines: 2,
                                    style: GoogleFonts.lato(
                                      color: Colors.black,
                                      fontSize: 17,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: "Meeting Points",
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
                            height: 35,
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
                              onPressed: () {
                                setState(() {
                                  titleError = remController.titleController.text.trim().isEmpty
                                      ? "Please enter reminder title"
                                      : null;
                                  startError = remController.startController.text.trim().isEmpty
                                      ? "Please select start date & time"
                                      : null;
                                  endError = remController.endController.text.trim().isEmpty
                                      ? "Please select end date & time"
                                      : null;
                                  employeeError = controllers.selectedEmployeeId.value.isEmpty
                                      ? "Please select employee"
                                      : null;
                                  customerError = controllers.selectedCustomerId.value.isEmpty
                                      ? "Please select customer"
                                      : null;
                                });

                                if (titleError == null &&
                                    startError == null &&
                                    endError == null &&
                                    employeeError == null &&
                                    customerError == null) {
                                  final provider = Provider.of<ReminderProvider>(
                                      context,
                                      listen: false);
                                  remController.insertReminderAPI(
                                      context, provider.selectedNotification);
                                }
                              },
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
                         _showAddReminderDialog();
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
                   5: FlexColumnWidth(2),//Repeat
                   6: FlexColumnWidth(3),//Employee Name
                   7: FlexColumnWidth(3),//Customer Name
                   8: FlexColumnWidth(3),//Start Date - Time
                   9: FlexColumnWidth(3),//End Date - Time
                   10: FlexColumnWidth(4.5),//Details
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
                             text: "Actions",//0
                             size: 15,
                             isBold: true,
                             colors: Colors.white,
                           ),
                         ),
                         Padding(
                           padding: const EdgeInsets.all(10.0),
                           child: CustomText(
                             textAlign: TextAlign.left,
                             text: "Reminder Title",//0
                             size: 15,
                             isBold: true,
                             colors: Colors.white,
                           ),
                         ),
                         Padding(
                           padding: const EdgeInsets.all(10.0),
                           child: CustomText(
                             textAlign: TextAlign.left,
                             text: "Type",//0
                             size: 15,
                             isBold: true,
                             colors: Colors.white,
                           ),
                         ),
                         Padding(
                           padding: const EdgeInsets.all(10.0),
                           child: CustomText(//2
                             textAlign: TextAlign.left,
                             text: "Location",
                             size: 15,
                             isBold: true,
                             colors: Colors.white,
                           ),
                         ),
                         Padding(
                           padding: const EdgeInsets.all(10.0),
                           child: CustomText(
                             textAlign: TextAlign.left,
                             text: "Repeat",
                             size: 15,
                             isBold: true,
                             colors: Colors.white,
                           ),
                         ),
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
                           5: FlexColumnWidth(2),//Repeat
                           6: FlexColumnWidth(3),//Employee Name
                           7: FlexColumnWidth(3),//Customer Name
                           8: FlexColumnWidth(3),//Start Date - Time
                           9: FlexColumnWidth(3),//End Date - Time
                           10: FlexColumnWidth(4.5),//Details
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
                                 Tooltip(
                                   message: reminder.repeatType.toString()=="null"?"":reminder.repeatType.toString(),
                                   child: Padding(
                                     padding: const EdgeInsets.all(10.0),
                                     child: CustomText(
                                       textAlign: TextAlign.left,
                                       text: reminder.repeatType.toString(),
                                       size: 14,
                                       colors:colorsConst.textColor,
                                     ),
                                   ),
                                 ),
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

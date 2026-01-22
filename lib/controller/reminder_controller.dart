
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/utilities/utils.dart';
import 'package:fullcomm_crm/services/api_services.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../common/constant/api.dart';
import '../models/all_customers_obj.dart';
import '../models/customer_activity.dart';
import '../models/meeting_obj.dart';
import '../models/reminder_obj.dart';
import '../provider/reminder_provider.dart';
import '../screens/reminder/reminder_page.dart';
import 'controller.dart';

class AddReminderModel {
  final TextEditingController titleController = TextEditingController();
  RxMap<String, RxBool> remindVia = {
    "Desktop": false.obs,
    "Email": true.obs,
    "SMS": false.obs,
    "WhatsApp": false.obs,
    "App Notification": false.obs,
  }.obs;

  RxString selectedTime = "1 Min".obs;
  RxString customTime = "1 Day".obs;

  List<String> otherTimes = ["1 Day", "2 Days", "3 Days", "1 Week","1 Month"];
}

final remController = Get.put(ReminderController());

class ReminderController extends GetxController with GetSingleTickerProviderStateMixin {
  // late CalendarDataSource dataSource;
  late CalendarDataSource dataSource;

  bool hasAppointment(DateTime date) {
    return dataSource.appointments!.any((appt) =>
    appt.startTime.year == date.year &&
        appt.startTime.month == date.month &&
        appt.startTime.day == date.day);
  }
  bool hasStatus(DateTime date, String status) {
    return dataSource.appointments!.any((appt) =>
    appt.startTime.year == date.year &&
        appt.startTime.month == date.month &&
        appt.startTime.day == date.day &&
        (appt.subject?.toLowerCase() ?? '') == status.toLowerCase());
  }
  TextEditingController titleController       = TextEditingController();
  TextEditingController detailsController     = TextEditingController();
  TextEditingController startController       = TextEditingController();
  TextEditingController endController         = TextEditingController();
  String? location;
  String? repeat;
  String? repeatOn;
  String repeatWise = "Never";
  String? repeatEvery;

  var stDate = "".obs;
  var stTime = "".obs;
  var enDate = "".obs;
  var enTime = "".obs;

  String defaultTime = "Immediately";
  RxList<AddReminderModel> reminders = <AddReminderModel>[AddReminderModel()].obs;
  final listKey = GlobalKey<AnimatedListState>();
  void addReminder() {
    reminders.add(AddReminderModel());
  }
  void removeReminder(int index) {
    reminders.removeAt(index);
  }
  DateTime selectedDate = DateTime.now();
  var filterDate = "".obs;
  void filterDateList(String value,DateTime dateTime){
    filterDate.value=value;
    selectedDate = dateTime;
  }
  var assignedIds="".obs;
  var assignedNames="".obs;
  var assignedNumbers="".obs;
  var assignedEmail="".obs;
  void changeAssignedIs(context, List<dynamic> names) {
    List<String> ids = [];
    List<String> selectedNames = [];
    List<String> numbers = [];
    List<String> mails = [];


    for (var name in names) {
      var found = controllers.employees.firstWhere(
            (element) => element.name.toString().trim().toLowerCase() == name.toString().trim().toLowerCase(),
        orElse: () => AllEmployeesObj(id: "0", name: '', phoneNo: '', email: ''),
      );

      if (found.id != "0") {
        ids.add(found.id.toString());
        selectedNames.add(found.name.toString());
        numbers.add(found.phoneNo.toString());
        mails.add(found.email.toString());
      }
    }

    assignedIds.value = ids.join(",");
    assignedNames.value = selectedNames.join(", ");
    assignedNumbers.value = numbers.join(", ");
    assignedEmail.value = mails.join(", ");
    controllers.selectedEmployeeId.value = assignedIds.value;
    controllers.selectedEmployeeName.value = assignedNames.value;
    controllers.selectedEmployeeMobile.value = assignedNumbers.value;
    controllers.selectedEmployeeEmail.value = assignedEmail.value;
    // print("Assigned IDs: $_assignedId");
    // print("Assigned Names: $_assignedNames");
  }

  TextEditingController updateTitleController   = TextEditingController();
  TextEditingController updateDetailsController = TextEditingController();
  TextEditingController updateStartController   = TextEditingController();
  TextEditingController updateEndController     = TextEditingController();
  String? updateLocation;
  String? updateRepeat;

  var sortFieldCallActivity = ''.obs;
  var setType = ''.obs;
  var sortOrderCallActivity = 'asc'.obs;
  var searchText = ''.obs;
  final Rxn<DateTime> selectedCallMonth = Rxn<DateTime>();
  final Rxn<DateTime> selectedMailMonth = Rxn<DateTime>();
  final Rxn<DateTime> selectedMeetMonth = Rxn<DateTime>();
  final Rxn<DateTime> selectedReminderMonth = Rxn<DateTime>();
  RxString selectedCallSortBy = "All".obs;
  RxString selectedMailSortBy = "All".obs;
  RxString selectedMeetSortBy = "Today".obs;
  RxString selectedReminderSortBy = "All".obs;

  void loadSavedFilters() {
    final storage = controllers.storage.read("selectedSortBy");
    controllers.selectedSortBy.value = storage ?? "All";
    controllers.selectedProspectSortBy.value = storage ?? "All";
    controllers.selectedQualifiedSortBy.value = storage ?? "All";
    controllers.selectedCustomerSortBy.value = storage ?? "All";
    selectedCallSortBy.value = storage ?? "All";
    selectedMailSortBy.value = storage ?? "All";
    selectedMeetSortBy.value = storage ?? "All";
    selectedReminderSortBy.value = storage ?? "All";
  }

  var selectedCallRange = Rxn<DateTimeRange>();
  var selectedMailRange = Rxn<DateTimeRange>();
  var selectedMeetRange = Rxn<DateTimeRange>();
  var selectedReminderRange = Rxn<DateTimeRange>();
  var reminderList = <ReminderModel>[].obs;
  var selectedReminderIds = <String>[].obs;
  var selectedMeetingIds = <String>[].obs;
  var selectedRecordMailIds = <String>[].obs;
  var selectedRecordCallIds = <String>[].obs;
  RxList<CustomerActivity> callFilteredList  = <CustomerActivity>[].obs;
  RxList<CustomerActivity> mailFilteredList  = <CustomerActivity>[].obs;
  RxList<MeetingObj> meetingFilteredList     = <MeetingObj>[].obs;
  RxList<ReminderModel> reminderFilteredList     = <ReminderModel>[].obs;
  void selectMonth(BuildContext context, RxString sortByKey, Rxn<DateTime> selectedMonthTarget,VoidCallback onMonthSelected,) {
    showMonthPicker(
      context: context,
      monthStylePredicate: (month) {
        final now = DateTime.now();
        if (month.month == now.month && month.year == now.year) {
          return ButtonStyle(
            foregroundColor: WidgetStateProperty.all(Colors.white),
            backgroundColor: WidgetStateProperty.all(Colors.blue.withOpacity(0.2)),
          );
        } else {
          return ButtonStyle(
            foregroundColor: WidgetStateProperty.all(Colors.black),
            backgroundColor: WidgetStateProperty.all(Colors.transparent),
          );
        }
      },
      initialDate: selectedMonthTarget.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    ).then((selected) {
      if (selected != null) {
        sortByKey.value = 'Custom Month';
        selectedMonthTarget.value = selected;
        onMonthSelected();
      }
    });
  }

  var reminderTitleController = TextEditingController();
  var remindVia = {
    "Desktop": true.obs,
    "Email": true.obs,
    "SMS": true.obs,
    "WhatsApp": false.obs,
    "App": false.obs,
  };

  var selectedTime = "Other".obs;
  var customTime = "1 Day".obs;

  List<String> otherTimes = ["1 Day", "2 Days", "3 Days", "1 Week"];

  void showDatePickerDialog(BuildContext context,void Function(DateTimeRange)? onDateSelected) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        dynamic tempRange;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xffFFFCF9),
              title: const Text(
                'Select Date',
                style: TextStyle(
                  color: Color(0xFF004AAD),
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SizedBox(
                height: 300,
                width: 350,
                child: SfDateRangePicker(
                  backgroundColor: const Color(0xffFFFCF9),
                  minDate: DateTime(2023),
                  maxDate: DateTime.now(),
                  selectionMode: DateRangePickerSelectionMode.range,
                  selectionShape: DateRangePickerSelectionShape.circle,
                  selectionRadius: 18,
                  selectionColor: const Color(0xFF004AAD),
                  startRangeSelectionColor: const Color(0xFF004AAD),
                  endRangeSelectionColor: const Color(0xFF004AAD),
                  rangeSelectionColor: const Color(0x22004AAD),
                  monthCellStyle: const DateRangePickerMonthCellStyle(
                    textStyle: TextStyle(
                      fontSize: 14,
                      height: 1.0,
                      color: Colors.black87,
                    ),
                    todayTextStyle: TextStyle(
                      fontSize: 14,
                      height: 1.0,
                      color: Colors.black87,
                    ),
                  ),
                  monthViewSettings: const DateRangePickerMonthViewSettings(
                    dayFormat: 'EEE',
                    viewHeaderHeight: 28,
                  ),
                  selectionTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    height: 1.0,
                  ),
                  onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                    setState(() {
                      tempRange = args.value;
                    });
                  },
                ),
              ),
              actions: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Center(
                    child: Text(
                      'Click and drag to select multiple dates',
                      style: TextStyle(
                        color: Color(0xFF004AAD),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        if (tempRange != null) {
                          if (onDateSelected != null) {
                            onDateSelected(
                              DateTimeRange(
                                start: tempRange.startDate!,
                                end: tempRange.endDate!,
                              ),
                            );
                          }
                        }
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'OK',
                        style: TextStyle(
                          color: Color(0xFF004AAD),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  void filterAndSortCalls({
    required List<CustomerActivity> allCalls,
    required String searchText,
    required String callType,
    required String sortField,
    required String sortOrder,
    required String selectedDateFilter, // Today, Yesterday, etc.
    required DateTime? selectedMonth,
    required DateTimeRange? selectedRange,
  }) {
    DateTime parseDate(String dateStr) {
      try {
        return DateFormat("dd.MM.yyyy hh:mm a").parse(dateStr);
      } catch (e) {
        return DateTime(1900);
      }
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final filtered = allCalls.where((activity) {
      final matchesCallType =
          callType.isEmpty || callType == "All" || activity.callType == callType;
      final matchesSearch = searchText.isEmpty ||
          activity.customerName.toLowerCase().contains(searchText.toLowerCase()) ||
          activity.toData.toLowerCase().contains(searchText.toLowerCase());

      final activityDate = parseDate(activity.sentDate);
      bool matchesDate = true;
      if (selectedDateFilter == "Today") {
        matchesDate = activityDate.isAfter(today) && activityDate.isBefore(today.add(const Duration(days: 1)));
      } else if (selectedDateFilter == "Yesterday") {
        final yesterday = today.subtract(const Duration(days: 1));
        matchesDate = activityDate.isAfter(yesterday) && activityDate.isBefore(today);
      } else if (selectedDateFilter == "Last 7 Days") {
        final sevenDaysAgo = today.subtract(const Duration(days: 7));
        matchesDate = activityDate.isAfter(sevenDaysAgo);
      } else if (selectedDateFilter == "Last 30 Days") {
        final thirtyDaysAgo = today.subtract(const Duration(days: 30));
        matchesDate = activityDate.isAfter(thirtyDaysAgo);
      }
      if (selectedRange != null) {
        matchesDate = activityDate.isAfter(selectedRange.start.subtract(const Duration(seconds: 1))) &&
            activityDate.isBefore(selectedRange.end.add(const Duration(seconds: 1)));
      }
      if (selectedMonth != null) {
        matchesDate = (activityDate.month == selectedMonth.month &&
            activityDate.year == selectedMonth.year);
      }

      return matchesCallType && matchesSearch && matchesDate;
    }).toList();
    if (sortField == 'customerName') {
      filtered.sort((a, b) {
        final nameA = a.customerName.toLowerCase();
        final nameB = b.customerName.toLowerCase();
        final comparison = nameA.compareTo(nameB);
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    } else if (sortField == 'mobile') {
      filtered.sort((a, b) {
        final nameA = a.toData.toLowerCase();
        final nameB = b.toData.toLowerCase();
        final comparison = nameA.compareTo(nameB);
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    } else if (sortField == 'type') {
      filtered.sort((a, b) {
        final nameA = a.callType.toLowerCase();
        final nameB = b.callType.toLowerCase();
        final comparison = nameA.compareTo(nameB);
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    } else if (sortField == 'status') {
      filtered.sort((a, b) {
        final nameA = a.callStatus.toLowerCase();
        final nameB = b.callStatus.toLowerCase();
        final comparison = nameA.compareTo(nameB);
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    } else if (sortField == 'message') {
      filtered.sort((a, b) {
        final nameA = a.message.toLowerCase();
        final nameB = b.message.toLowerCase();
        final comparison = nameA.compareTo(nameB);
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    } else if (sortField == 'leadStatus') {
      filtered.sort((a, b) {
        final nameA = a.leadStatus.toLowerCase();
        final nameB = b.leadStatus.toLowerCase();
        final comparison = nameA.compareTo(nameB);
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    } else if (sortField == 'date') {
      filtered.sort((a, b) {
        final dateA = parseDate(a.sentDate);
        final dateB = parseDate(b.sentDate);
        final comparison = dateA.compareTo(dateB);
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }
    callFilteredList.assignAll(filtered);
  }

  void filterAndSortMeetings({
    required String searchText,
    required String callType,
    required String sortField,
    required String sortOrder,
  }) {
    var filtered = [...controllers.meetingActivity];

    final now = DateTime.now();
    if (selectedMeetSortBy.value.isNotEmpty) {
      filtered = filtered.where((activity) {
        final date = _parseMeetingDate(activity.dates ?? '');
        switch (selectedMeetSortBy.value) {
          case 'Today':
            return _isSameDay(date, now);
          case 'Yesterday':
            final yesterday = now.subtract(const Duration(days: 1));
            return _isSameDay(date, yesterday);
          case 'Last 7 Days':
            final last7 = now.subtract(const Duration(days: 7));
            return date.isAfter(last7);
          case 'Last 30 Days':
            final last30 = now.subtract(const Duration(days: 30));
            return date.isAfter(last30);
          case 'Custom Month':
            if (selectedMeetMonth.value != null) {
              final selected = selectedMeetMonth.value!;
              return date.year == selected.year && date.month == selected.month;
            }
            return true;
          case 'Custom Range':
            if (selectedMeetRange.value != null) {
              final range = selectedMeetRange.value!;
              return date.isAfter(range.start.subtract(const Duration(days: 1))) &&
                  date.isBefore(range.end.add(const Duration(days: 1)));
            }
            return true;
          default:
            return true;
        }
      }).toList();
    }
    filtered = filtered.where((activity) {
      final matchesCallType = controllers.selectMeetingType.value.isEmpty ||
          activity.status == controllers.selectMeetingType.value;

      final matchesSearch = searchText.isEmpty ||
          (activity.comName.toLowerCase().contains(searchText)) ||
          (activity.cusName.toLowerCase().contains(searchText));

      return matchesCallType && matchesSearch;
    }).toList();

    String field = controllers.sortFieldMeetingActivity.value;
    String order = controllers.sortOrderMeetingActivity.value;

    int compareString(String a, String b) {
      final comparison = a.toLowerCase().compareTo(b.toLowerCase());
      return order == 'asc' ? comparison : -comparison;
    }

    if (field == 'customerName') {
      filtered.sort((a, b) => compareString(a.cusName ?? '', b.cusName ?? ''));
    } else if (field == 'companyName') {
      filtered.sort((a, b) => compareString(a.comName ?? '', b.comName ?? ''));
    } else if (field == 'title') {
      filtered.sort((a, b) => compareString(a.title ?? '', b.title ?? ''));
    } else if (field == 'venue') {
      filtered.sort((a, b) => compareString(a.venue ?? '', b.venue ?? ''));
    } else if (field == 'notes') {
      filtered.sort((a, b) => compareString(a.notes ?? '', b.notes ?? ''));
    } else if (field == 'date') {
      filtered.sort((a, b) {
        final dateA = _parseMeetingDate(a.dates ?? '');
        final dateB = _parseMeetingDate(b.dates ?? '');
        final comparison = dateA.compareTo(dateB);
        return order == 'asc' ? comparison : -comparison;
      });
    }
    meetingFilteredList.assignAll(filtered);
  }
  DateTime _parseMeetingDate(String dateStr) {
    try {
      final parts = dateStr.split('||');
      final mainPart = parts.first.trim();
      if (mainPart.contains(RegExp(r'[APMapm]'))) {
        return DateFormat("dd.MM.yyyy hh:mm a").parse(mainPart);
      } else {
        return DateFormat("dd.MM.yyyy").parse(mainPart);
      }
    } catch (e) {
      return DateTime(1900);
    }
  }

  var sortBy = ''.obs;
  var ascending = true.obs;
  void sortReminders() {
    var filteredList = [...reminderList];
    final dateFormatter = DateFormat("dd-MM-yyyy h:mm a");
    final now = DateTime.now();
    if (selectedReminderSortBy.value.isNotEmpty) {
      switch (selectedReminderSortBy.value) {
        case 'All':
          filteredList = [...reminderList];
          break;
        case 'Today':
          filteredList = filteredList.where((r) {
            final date = _parseReminderDate(r.updatedTs, dateFormatter);
            return _isSameDay(date, now);
          }).toList();
          break;

        case 'Yesterday':
          final yesterday = now.subtract(const Duration(days: 1));
          filteredList = filteredList.where((r) {
            final date = _parseReminderDate(r.updatedTs, dateFormatter);
            return _isSameDay(date, yesterday);
          }).toList();
          break;

        case 'Last 7 Days':
          final last7 = now.subtract(const Duration(days: 7));
          filteredList = filteredList.where((r) {
            final date = _parseReminderDate(r.updatedTs, dateFormatter);
            return date.isAfter(last7);
          }).toList();
          break;

        case 'Last 30 Days':
          final last30 = now.subtract(const Duration(days: 30));
          filteredList = filteredList.where((r) {
            final date = _parseReminderDate(r.updatedTs, dateFormatter);
            return date.isAfter(last30);
          }).toList();
          break;

        case 'Custom Month':
          if (selectedReminderMonth.value != null) {
            final selected = selectedReminderMonth.value!;
            filteredList = filteredList.where((r) {
              final date = _parseReminderDate(r.startDt, dateFormatter);
              return date.year == selected.year && date.month == selected.month;
            }).toList();
          }
          break;

        case 'Custom Range':
          if (selectedReminderRange.value != null) {
            final range = selectedReminderRange.value!;
            filteredList = filteredList.where((r) {
              final date = _parseReminderDate(r.startDt, dateFormatter);
              return date.isAfter(range.start.subtract(const Duration(days: 1))) &&
                  date.isBefore(range.end.add(const Duration(days: 1)));
            }).toList();
          }
          break;
      }
    }
    filteredList.sort((a, b) {
      dynamic aValue;
      dynamic bValue;

      switch (sortFieldCallActivity.value) {
        case 'customerName':
          aValue = a.customerName.toLowerCase();
          bValue = b.customerName.toLowerCase();
          break;
        case 'employeeName':
          aValue = a.employeeName.toLowerCase();
          bValue = b.employeeName.toLowerCase();
          break;
        case 'details':
          aValue = a.details.toLowerCase();
          bValue = b.details.toLowerCase();
          break;
        case 'location':
          aValue = a.location.toLowerCase();
          bValue = b.location.toLowerCase();
          break;
        case 'type':
          aValue = a.type.toLowerCase();
          bValue = b.type.toLowerCase();
          break;
        case 'title':
          aValue = a.title.toLowerCase();
          bValue = b.title.toLowerCase();
          break;
        case 'startDate':
          aValue = _parseReminderDate(a.startDt, dateFormatter);
          bValue = _parseReminderDate(b.startDt, dateFormatter);
          break;
        case 'endDate':
          aValue = _parseReminderDate(a.endDt, dateFormatter);
          bValue = _parseReminderDate(b.endDt, dateFormatter);
          break;
        default:
          aValue = '';
          bValue = '';
      }

      int result;
      if (aValue is String && bValue is String) {
        result = aValue.compareTo(bValue);
      } else if (aValue is DateTime && bValue is DateTime) {
        result = aValue.compareTo(bValue);
      } else {
        result = 0;
      }

      return sortOrderCallActivity.value == 'asc' ? result : -result;
    });
    reminderFilteredList.assignAll(filteredList);
  }
  DateTime _parseReminderDate(String dateStr, DateFormat fallbackFormatter) {
    try {
      final cleaned = dateStr.trim().replaceAll(RegExp(r'[^0-9:\-\sT]'), '');
      // Try direct parse first (handles yyyy-MM-dd HH:mm:ss and ISO)
      final parsed = DateTime.tryParse(cleaned);
      if (parsed != null) {
        return parsed;
      }
      final parsed2 = fallbackFormatter.parse(cleaned);
      return parsed2;
    } catch (e) {
      return DateTime(1900);
    }
  }



  void sortMails() {
    var filteredList = [...controllers.mailActivity];
    final dateFormatter = DateFormat("dd-MM-yyyy h:mm a");
    final now = DateTime.now();
    if (selectedMailSortBy.value.isNotEmpty) {
      switch (selectedMailSortBy.value) {
        case 'Today':
          filteredList = filteredList.where((mail) {
            final date = _parseMailDate(mail.sentDate, dateFormatter);
            return _isSameDay(date, now);
          }).toList();
          break;

        case 'Yesterday':
          final yesterday = now.subtract(const Duration(days: 1));
          filteredList = filteredList.where((mail) {
            final date = _parseMailDate(mail.sentDate, dateFormatter);
            return _isSameDay(date, yesterday);
          }).toList();
          break;

        case 'Last 7 Days':
          final last7 = now.subtract(const Duration(days: 7));
          filteredList = filteredList.where((mail) {
            final date = _parseMailDate(mail.sentDate, dateFormatter);
            return date.isAfter(last7);
          }).toList();
          break;

        case 'Last 30 Days':
          final last30 = now.subtract(const Duration(days: 30));
          filteredList = filteredList.where((mail) {
            final date = _parseMailDate(mail.sentDate, dateFormatter);
            return date.isAfter(last30);
          }).toList();
          break;

        case 'Custom Month':
          if (selectedMailMonth.value != null) {
            final selected = selectedMailMonth.value!;
            filteredList = filteredList.where((mail) {
              final date = _parseMailDate(mail.sentDate, dateFormatter);
              return date.year == selected.year && date.month == selected.month;
            }).toList();
          }
          break;
        case 'Custom Range':
          if (selectedMailRange.value != null) {
            final range = selectedMailRange.value!;
            filteredList = filteredList.where((mail) {
              final date = _parseMailDate(mail.sentDate, dateFormatter);
              return date.isAfter(range.start.subtract(const Duration(days: 1))) &&
                  date.isBefore(range.end.add(const Duration(days: 1)));
            }).toList();
          }
          break;
      }
    }
    filteredList.sort((a, b) {
      dynamic aValue;
      dynamic bValue;
      switch (sortFieldCallActivity.value) {
        case 'customerName':
          aValue = (a.customerName ?? '').toLowerCase();
          bValue = (b.customerName ?? '').toLowerCase();
          break;
        case 'mail':
          aValue = (a.toData ?? '').toLowerCase();
          bValue = (b.toData ?? '').toLowerCase();
          break;
        case 'subject':
          aValue = (a.subject ?? '').toLowerCase();
          bValue = (b.subject ?? '').toLowerCase();
          break;
        case 'msg':
          aValue = (a.message ?? '').toLowerCase();
          bValue = (b.message ?? '').toLowerCase();
          break;
        case 'date':
          aValue = _parseMailDate(a.sentDate, dateFormatter);
          bValue = _parseMailDate(b.sentDate, dateFormatter);
          break;
        default:
          aValue = '';
          bValue = '';
      }
      int result;
      if (aValue is String && bValue is String) {
        result = aValue.compareTo(bValue);
      } else if (aValue is DateTime && bValue is DateTime) {
        result = aValue.compareTo(bValue);
      } else {
        result = 0;
      }

      return sortOrderCallActivity.value == 'asc' ? result : -result;
    });
    mailFilteredList.assignAll(filteredList);
  }

  DateTime _parseMailDate(String? dateStr, DateFormat formatter) {
    if (dateStr == null || dateStr.trim().isEmpty) return DateTime(1900);
    try {
      final clean = dateStr.trim().replaceAll(RegExp(r'\s+'), ' ').toUpperCase();
      return formatter.parseStrict(clean);
    } catch (e) {
      print("Date parse failed for: $dateStr -> $e");
      return DateTime(1900);
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }



  bool isCheckedReminder(String id) {
    return selectedReminderIds.contains(id);
  }
  void toggleReminderSelection(String id) {
    if (selectedReminderIds.contains(id)) {
      selectedReminderIds.remove(id);
    } else {
      selectedReminderIds.add(id);
    }
  }
  void toggleSelectAllReminder() {
    bool allSelected = reminderFilteredList.every((office) => selectedReminderIds.contains(office.id));
    if (allSelected) {
      selectedReminderIds.clear();
    } else {
      selectedReminderIds.assignAll(reminderFilteredList.map((office) => office.id));
    }
  }

  bool isCheckedMeeting(String id) {
    return selectedMeetingIds.contains(id);
  }
  void selectAllCalls() {
    selectedRecordCallIds.assignAll(callFilteredList.map((e) => e.id.toString()).toList());
  }

  void unselectAllCalls() {
    selectedRecordCallIds.clear();
  }
  void toggleMeetingSelection(String id) {
    if (selectedMeetingIds.contains(id)) {
      selectedMeetingIds.remove(id);
    } else {
      selectedMeetingIds.add(id);
    }
  }

  bool isCheckedRecordCall(String id) {
    return selectedRecordCallIds.contains(id);
  }
  void toggleRecordSelectionCall(String id) {
    if (selectedRecordCallIds.contains(id)) {
      selectedRecordCallIds.remove(id);
    } else {
      selectedRecordCallIds.add(id);
    }
  }

  bool isCheckedRecordMAil(String id) {
    return selectedRecordMailIds.contains(id);
  }
  void toggleRecordSelectionMail(String id) {
    if (selectedRecordMailIds.contains(id)) {
      selectedRecordMailIds.remove(id);
    } else {
      selectedRecordMailIds.add(id);
    }
  }
  var isLoadingReminders = false.obs;
  var followUpReminderCount = 0.obs;
  var meetingReminderCount = 0.obs;
  var defaultMonth=DateTime.now().month.obs;
  var thisMonthLeave = "0".obs;

  Future<void> allReminders(String type) async {
    isLoadingReminders.value = true;
    thisMonthLeave.value = "0";

    dataSource.dispose();
    dataSource.appointments?.clear();

    final url = Uri.parse(scriptApi);

    try {
      final response = await http.post(
        url,
        body: jsonEncode({
          "action": "get_data",
          "type": type,
          "cos_id": controllers.storage.read("cos_id"),
          "search_type": "allReminders"
        }),
      );

      if (response.statusCode == 200) {

        final data = jsonDecode(response.body);

        if (data is List) {

          reminderList.value =
              data.map((e) => ReminderModel.fromJson(e)).toList();

          // ---------- COUNTS ----------
          followUpReminderCount.value =
              reminderList.where((r) => r.type.toString() == '1').length;

          meetingReminderCount.value =
              reminderList.where((r) => r.type.toString() == '2').length;

          int monthCount = 0;

          // ---------- LOOP ----------
          for (var i = 0; i < reminderList.length; i++) {

            String dateStr = reminderList[i].startDt ?? '';

            // Skip empty dates
            if (dateStr.trim().isEmpty) {
              print("Empty date skipped");
              continue;
            }

            DateTime? parsedDate;

            // ---------- SAFE DATE PARSE ----------
            try {
              // Format: 03.02.2026 11:00 AM
              parsedDate = DateFormat('dd.MM.yyyy hh:mm a').parse(dateStr);
            } catch (e) {
              try {
                // Format: 26-10-2025 09:50 PM
                parsedDate = DateFormat('dd-MM-yyyy hh:mm a').parse(dateStr);
              } catch (e) {
                print("Date parse failed => $dateStr");
                continue;
              }
            }

            DateTime dateOnly = DateTime(
              parsedDate.year,
              parsedDate.month,
              parsedDate.day,
            );

            // ---------- CALENDAR APPOINTMENT ----------
            Appointment app = Appointment(
              startTime: dateOnly,
              endTime: dateOnly,
              subject: reminderList[i].title ?? '',
              color: Colors.redAccent,
            );

            dataSource.appointments!.add(app);
            dataSource.notifyListeners(
                CalendarDataSourceAction.add, <Appointment>[app]);

            // ---------- MONTH COUNT ----------
            if (defaultMonth.value.toString().padLeft(2, "0") ==
                parsedDate.month.toString().padLeft(2, "0")) {
              monthCount++;
            }
          }

          thisMonthLeave.value = monthCount.toString();

        } else {
          reminderList.value = [];
          followUpReminderCount.value = 0;
          meetingReminderCount.value = 0;
        }

      } else {
        reminderList.value = [];
        followUpReminderCount.value = 0;
        meetingReminderCount.value = 0;
        print("Failed API Response: ${response.body}");
      }

    } catch (e) {
      reminderList.value = [];
      followUpReminderCount.value = 0;
      meetingReminderCount.value = 0;
      print("Reminder API Error: $e");
    } finally {
      isLoadingReminders.value = false;
    }
  }

  Future insertReminderAPI(BuildContext context,String type) async {
    try{
      Map data = {
        "action": "insert_reminder",
        "title": titleController.text.trim(),
        "type": type,
        "location": location,
        "repeat_type": repeat,
        "employee": controllers.selectedEmployeeId.value,
        "customer": controllers.selectedCustomerId.value,
        "start_dt": "${stDate.value} ${stTime.value}",
        "end_dt": "${enDate.value} ${enTime.value}",
        "details": detailsController.text.trim(),
        "set_time": defaultTime,
        "set_type": "Email",
        "repeat_on": repeatOn,
        "repeat_wise": repeatWise,
        "repeat_every": repeatEvery,
        "created_by": controllers.storage.read("id"),
        "cos_id": controllers.storage.read("cos_id"),
        "reminders": reminders.map((reminder) {
          return {
            "remind_via": reminder.remindVia.entries
                .where((entry) => entry.value.value)
                .map((entry) => entry.key)
                .toList(),
            "before_ts": reminder.selectedTime.value == "Other"
                ? reminder.customTime.value
                : reminder.selectedTime.value,
            "title": reminder.titleController.text.trim(),
          };
        }).toList(),
      };
      print("Reminder data $data");
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8")
      );
      print("request ${request.body}");
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 200 && response["message"]=="Reminder added successfully"){
         titleController.clear();
         location=null;
         repeat=null;
         controllers.clearSelectedEmployee();
         controllers.clearSelectedCustomer();
         startController.clear();
         endController.clear();
         detailsController.clear();
          reminders.clear();
          reminders.add(AddReminderModel());
          stDate.value="";
          stTime.value="";
          enDate.value="";
          enTime.value="";
          repeatOn=null;
         final provider = Provider.of<ReminderProvider>(context, listen: false);
         provider.selectedNotification = "followup";
        allReminders(type);
        Navigator.pop(context);
        utils.snackBar(context: context, msg: "Reminder added successfully", color: Colors.green);
        controllers.productCtr.reset();
      } else {
        apiService.errorDialog(Get.context!,request.body);
        controllers.productCtr.reset();
      }
    }catch(e){
      apiService.errorDialog(Get.context!,e.toString());
      controllers.productCtr.reset();
    }
  }

  Future updateReminderAPI(BuildContext context,String type,String id) async {
    try{
      Map data = {
        "action": "update_reminder",
        "id": id,
        "title": updateTitleController.text.trim(),
        "type": type,
        "location": updateLocation,
        "repeat_type": updateRepeat,
        "employee": controllers.selectedEmployeeId.value,
        "customer": controllers.selectedCustomerId.value,
        "start_dt": updateStartController.text.trim(),
        "end_dt": updateEndController.text.trim(),
        "details": updateDetailsController.text.trim(),
        "updated_by": controllers.storage.read("id"),
        "cos_id": controllers.storage.read("cos_id")
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8")
      );
      print("request ${request.body}");
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 200 && response["message"]=="Reminder updated successfully"){
        allReminders(type);
        Navigator.pop(context);
        utils.snackBar(context: context, msg: "Reminder updated successfully", color: Colors.green);
        controllers.productCtr.reset();
      } else {
        apiService.errorDialog(Get.context!,request.body);
        controllers.productCtr.reset();
      }
    }catch(e){
      apiService.errorDialog(Get.context!,e.toString());
      controllers.productCtr.reset();
    }
  }

  Future insertSettingsReminderAPI(BuildContext context,String time) async {
    try{
      Map data = {
        "action": "insert_settings_reminder",
        "type": "Email",
        "time": time,
        "created_by": controllers.storage.read("id"),
        "cos_id": controllers.storage.read("cos_id")
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8")
      );
      print("request ${request.body}");
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 200 && response["message"]=="Settings added successfully"){
        Navigator.pop(context);
        utils.snackBar(context: context, msg: "Settings added successfully", color: Colors.green);
        controllers.productCtr.reset();
      } else {
        apiService.errorDialog(Get.context!,request.body);
        controllers.productCtr.reset();
      }
    }catch(e){
      apiService.errorDialog(Get.context!,e.toString());
      controllers.productCtr.reset();
    }
  }

  Future deleteReminderAPI(BuildContext context) async {
    try{
      Map data = {
        "action": "delete_reminder",
        "user_id": controllers.storage.read("id"),
        "cos_id": controllers.storage.read("cos_id"),
        "empList": selectedReminderIds,
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8")
      );
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 200 && response["message"]=="OK"){
        allReminders("type");
        Navigator.pop(context);
        utils.snackBar(context: context, msg: "Reminder deleted successfully.", color: Colors.green);
        controllers.productCtr.reset();
        selectedReminderIds.clear();
      } else {
        apiService.errorDialog(Get.context!,request.body);
        controllers.productCtr.reset();
      }
    }catch(e){
      apiService.errorDialog(Get.context!,e.toString());
      controllers.productCtr.reset();
    }
  }

  Future<void> deleteMeetingAPI(BuildContext context) async {
    try {
      Map<String, dynamic> data = {
        "user_id": controllers.storage.read("id"),
        "cos_id": controllers.storage.read("cos_id"),
        "meetingList": selectedMeetingIds,
        "action": "delete_meeting",
      };
      print("Request: ${jsonEncode(data)}");
      final response = await http.post(
        Uri.parse(scriptApi), // your endpoint for delete_meeting.php
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode(data),
      );

      Map<String, dynamic> result = json.decode(response.body);
      print("Response: ${response.body}");

      if (response.statusCode == 200 && result["message"] == "OK") {
        apiService.getAllMeetingActivity("");
        Navigator.pop(context);
        utils.snackBar(
          context: context,
          msg: "Meeting deleted successfully.",
          color: Colors.green,
        );
        controllers.productCtr.reset();
        selectedMeetingIds.clear();
      } else {
        apiService.errorDialog(Get.context!, result["message"] ?? "Failed to delete meeting.");
        controllers.productCtr.reset();
      }
    } catch (e) {
      apiService.errorDialog(Get.context!, e.toString());
      controllers.productCtr.reset();
    }
  }


  Future<void> deleteRecordCallAPI(BuildContext context) async {
    try {
      Map<String, dynamic> data = {
        "action": "delete_record",
        "user_id": controllers.storage.read("id"),
        "cos_id": controllers.storage.read("cos_id"),
        "recordList": selectedRecordCallIds,
      };
      print("delete record $data");
      final response = await http.post(
        Uri.parse(scriptApi),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode(data),
      );
      print("Response body: ${response.body}");
      Map<String, dynamic> result = json.decode(response.body);
      if (response.statusCode == 200 && result["message"] == "OK") {
        Navigator.pop(context);
        apiService.getAllCallActivity("");
        apiService.getAllMailActivity();
        utils.snackBar(
          context: context,
          msg: "Call Record deleted successfully.",
          color: Colors.green,
        );
        controllers.productCtr.reset();
        selectedRecordCallIds.clear();

      } else {
        apiService.errorDialog(
          Get.context!,
          result["message"] ?? "Failed to delete call record.",
        );
        controllers.productCtr.reset();
      }
    } catch (e) {
      apiService.errorDialog(Get.context!, e.toString());
      controllers.productCtr.reset();
    }
  }


  Future<void> deleteRecordMailAPI(BuildContext context) async {
    try {
      Map<String, dynamic> data = {
        "action": "delete_record",
        "user_id": controllers.storage.read("id"),
        "cos_id": controllers.storage.read("cos_id"),
        "recordList": selectedRecordMailIds,
      };
      print("Response bodyjsonEncode(data): ${jsonEncode(data)}");
      final response = await http.post(
        Uri.parse(scriptApi),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode(data),
      );

      print("Response body: ${response.body}");

      Map<String, dynamic> result = json.decode(response.body);

      if (response.statusCode == 200 && result["message"] == "OK") {
        Navigator.pop(context);
        utils.snackBar(
          context: context,
          msg: "Mail Record deleted successfully.",
          color: Colors.green,
        );
        controllers.productCtr.reset();
        selectedRecordMailIds.clear();
      } else {
        apiService.errorDialog(
          Get.context!,
          result["message"] ?? "Failed to delete mail record.",
        );
        controllers.productCtr.reset();
      }
    } catch (e) {
      apiService.errorDialog(Get.context!, e.toString());
      controllers.productCtr.reset();
    }
  }


}
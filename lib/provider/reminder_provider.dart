
import 'package:flutter/material.dart';
import 'package:fullcomm_crm/controller/reminder_controller.dart';
import 'package:table_calendar/table_calendar.dart';

class ReminderProvider extends ChangeNotifier {
  // Notification types
  bool web = false;
  bool email = true;
  bool sms = false;
  bool app = false;

  void toggleWeb(bool? val) {
    web = val ?? false;
    notifyListeners();
  }

  void toggleEmail(bool? val) {
    email = val ?? false;

    List<String> types = [];

    if (email) types.add("Email");
    if (sms) types.add("SMS");

    remController.setType.value = types.join(", ");
    notifyListeners();
  }

  void toggleSms(bool? val) {
    sms = val ?? false;

    List<String> types = [];

    if (email) types.add("Email");
    if (sms) types.add("SMS");

    remController.setType.value = types.join(", ");
    notifyListeners();
  }

  void toggleApp(bool? val) {
    app = val ?? false;
    notifyListeners();
  }

  // Repeat options
  String repeatOption = "None";
  void setRepeatOption(String val) {
    repeatOption = val;
    notifyListeners();
  }

  // Default time dropdown
  String defaultTime = "Immediately";
  void setDefaultTime(String val) {
    defaultTime = val;
    notifyListeners();
  }

  // Calendar visibility
  bool showFollowUpCalendar = false;
  bool showMeetingCalendar = false;

  void toggleFollowUpCalendar() {
    showFollowUpCalendar = !showFollowUpCalendar;
    notifyListeners();
  }

  void toggleMeetingCalendar() {
    showMeetingCalendar = !showMeetingCalendar;
    notifyListeners();
  }

  // Single selected date for Meeting
  DateTime meetingSelectedDay = DateTime.now();
  void setMeetingSelectedDay(DateTime day) {
    meetingSelectedDay = day;
    notifyListeners();
  }

  // Multiple selected dates for Follow-up
  List<DateTime> followUpSelectedDays = [];

  void toggleFollowUpDay(DateTime day) {
    if (followUpSelectedDays.any((d) => isSameDay(d, day))) {
      followUpSelectedDays.removeWhere((d) => isSameDay(d, day));
    } else {
      followUpSelectedDays.add(day);
    }
    notifyListeners();
  }

  // Active reminder type
  String activeReminder = "";

  void toggleReminder(String type) {
    if (activeReminder == type) {
      activeReminder = "";
    } else {
      activeReminder = type;
    }
    notifyListeners();
  }

  bool get isFollowUpActive => activeReminder == "followup";
  bool get isMeetingActive => activeReminder == "meeting";




  List<DateTime> selectedStartDates = [];
  List<DateTime> selectedEndDates = [];

  void addStartDate(DateTime date) {
    selectedStartDates.add(date);
    notifyListeners();
  }

  void addEndDate(DateTime date) {
    selectedEndDates.add(date);
    notifyListeners();
  }

  void clearStartDates() {
    selectedStartDates.clear();
    notifyListeners();
  }

  void clearEndDates() {
    selectedEndDates.clear();
    notifyListeners();
  }

// Employee dropdown
  String selectedNotification = "followup"; // default
  List<String> allEmployees = ["Office", "Home", "Client Site"];
  List<String> selectedEmployees = [];
  String selectedText = "";
  bool showDropdown = false;

  bool get isAllSelected => selectedEmployees.length == allEmployees.length;

  // Change notification type
  void setNotification(String type) {
    selectedNotification = type;

    // Reset selection if switching to Meeting
    if (type == "meeting") {
      selectedEmployees.clear();
      selectedText = "";
      showDropdown = false;
    }

    notifyListeners();
  }

  void toggleDropdown() {
    if (selectedNotification == "followup") {
      showDropdown = !showDropdown;
      notifyListeners();
    }
  }

  void toggleEmployee(String employee, bool? val) {
    if (val == true) {
      if (!selectedEmployees.contains(employee)) selectedEmployees.add(employee);
    } else {
      selectedEmployees.remove(employee);
    }
    selectedText = selectedEmployees.join(", ");
    notifyListeners();
  }

  void toggleSelectAll(bool? val) {
    if (val == true) {
      selectedEmployees = List.from(allEmployees);
    } else {
      selectedEmployees.clear();
    }
    selectedText = selectedEmployees.join(", ");
    notifyListeners();
  }

  void selectSingleEmployee(String employee) {
    selectedEmployees = [employee];
    selectedText = employee;
    notifyListeners();
  }

  bool get isMeetingReminder => selectedNotification == "meeting";
  bool get isFollowUpReminder => selectedNotification == "followup";
  bool _isBold = false;
  bool _isItalic = false;
  bool _isUnderline = false;
  bool _isLink = false;

  bool get isBold => _isBold;
  bool get isItalic => _isItalic;
  bool get isUnderline => _isUnderline;
  bool get isLink => _isLink;

  void toggleBold() {
    _isBold = !_isBold;
    notifyListeners();
  }

  void toggleItalic() {
    _isItalic = !_isItalic;
    notifyListeners();
  }

  void toggleUnderline() {
    _isUnderline = !_isUnderline;
    notifyListeners();
  }

  void toggleLink() {
    _isLink = !_isLink;
    notifyListeners();
  }

  TextStyle get subjectTextStyle {
    return TextStyle(
      fontSize: 14,
      fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
      fontStyle: _isItalic ? FontStyle.italic : FontStyle.normal,
      decoration: _isUnderline || _isLink
          ? TextDecoration.underline
          : TextDecoration.none,
      color: _isLink ? Colors.blue : Colors.black87,
    );
  }
  void resetFormatting() {
    _isBold = false;
    _isItalic = false;
    _isUnderline = false;
    _isLink = false;
    notifyListeners();
  }

  void removeLink() {
    _isLink = false;
    notifyListeners();
  }
}

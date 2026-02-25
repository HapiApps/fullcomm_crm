import 'package:flutter/material.dart';

class DashboardProvider extends ChangeNotifier {
  DateTimeRange? selectedRange;

  Future<void> pickDateRange(BuildContext context) async {
    final DateTimeRange? result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: selectedRange,
    );

    if (result != null) {
      selectedRange = result;
      notifyListeners();
    }
  }

  String format(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}-"
          "${d.month.toString().padLeft(2, '0')}-"
          "${d.year}";

  int days() {
    if (selectedRange == null) return 0;
    return selectedRange!.end
        .difference(selectedRange!.start)
        .inDays +
        1;
  }
}


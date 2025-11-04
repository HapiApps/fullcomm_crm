import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../common/constant/colors_constant.dart';

class DateFilterBar extends StatelessWidget {
  final RxString selectedSortBy;
  final Rxn<DateTimeRange> selectedRange;
  final Rxn<DateTime> selectedMonth;
  final FocusNode focusNode;
  final VoidCallback onSelectMonth;
  final VoidCallback onDaysSelected;
  final Function(BuildContext) onSelectDateRange;

  const DateFilterBar({
    super.key,
    required this.selectedSortBy,
    required this.selectedRange,
    required this.selectedMonth,
    required this.focusNode,
    required this.onSelectMonth,
    required this.onSelectDateRange, required this.onDaysSelected,
  });

  @override
  Widget build(BuildContext context) {
    final options = ["Today", "Yesterday", "Last 7 Days", "Last 30 Days"];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Obx(() {
          return Wrap(
            spacing: 8,
            children: options.map((option) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Radio<String>(
                    value: option,
                    groupValue: selectedSortBy.value,
                    activeColor: Colors.blue,
                    onChanged: (val) {
                      selectedRange.value = null;
                      selectedMonth.value = null;
                      selectedSortBy.value = val!;
                      focusNode.requestFocus();
                      onDaysSelected();
                    },
                  ),
                  Text(
                    option,
                    style: TextStyle(
                      color: colorsConst.textColor,
                      fontFamily: "Lato",
                    ),
                  ),
                ],
              );
            }).toList(),
          );
        }),
        10.width,
        SizedBox(
          height: 35,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorsConst.secondary,
              shadowColor: Colors.transparent,
            ),
            onPressed: onSelectMonth,
            child: Obx(() => Text(
              selectedMonth.value != null
                  ? DateFormat('MMMM yyyy').format(selectedMonth.value!)
                  : 'Select Month',
              style: TextStyle(
                fontFamily: "Lato",
                color: colorsConst.textColor,
              ),
            )),
          ),
        ),
        const SizedBox(width: 10),
        InkWell(
          onTap: () {
            onSelectDateRange(context);
            selectedSortBy.value = "";
          },
          child: Container(
            width: 200,
            height: 30,
            decoration: BoxDecoration(
              color: colorsConst.secondary,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(() {
                  final range = selectedRange.value;
                  if (range == null) {
                    return Text(
                      "Filter by Date Range",
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: "Lato",
                      ),
                    );
                  }
                  return Text(
                    "${range.start.day}-${range.start.month}-${range.start.year}  -  ${range.end.day}-${range.end.month}-${range.end.year}",
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Lato",
                    ),
                  );
                }),
                const SizedBox(width: 5),
                const Icon(Icons.calendar_today, color: Colors.black, size: 17),
                const SizedBox(width: 10),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

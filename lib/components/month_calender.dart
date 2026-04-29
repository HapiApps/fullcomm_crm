import 'package:flutter/material.dart';
import 'package:fullcomm_crm/controller/new_payroll_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../common/constant/colors_constant.dart';
import '../controller/controller.dart';
import 'custom_text.dart';

class CustomMonthPicker extends StatefulWidget {
  final int initialMonth;
  final int initialYear;
  final int firstYear;
  final int lastYear;
  final ValueChanged<DateTime> onSelected;

  const CustomMonthPicker({super.key,
    required this.initialMonth,
    required this.initialYear,
    required this.firstYear,
    required this.lastYear,
    required this.onSelected,
  });

  @override
  State<CustomMonthPicker> createState() => _CustomMonthPickerState();
}

class _CustomMonthPickerState extends State<CustomMonthPicker> {
  late int selectedMonth;
  late int selectedYear;
  bool isYearPickerVisible = false;

  @override
  void initState() {
    super.initState();
    selectedMonth = widget.initialMonth;
    selectedYear = widget.initialYear;
  }

  Widget _buildYearGrid() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      children: List.generate(widget.lastYear - widget.firstYear + 1, (index) {
        final year = widget.firstYear + index;
        return InkWell(
          onTap: () {
            setState(() {
              selectedYear = year;
              isYearPickerVisible = false;
            });
          },
          child: Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: selectedYear == year?colorsConst.primary
                  :selectedYear == year?colorsConst.primary : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$year',
              style: TextStyle(
                color: selectedYear == year ? Colors.white : Colors.black,
              ),
            ),
          ),
        );
      }),
    );
  }
  Widget _buildMonthGrid() {
    final now = DateTime.now(); // 🔥 current date

    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      children: List.generate(12, (index) {
        final month = index + 1;

        // 🔥 future month check
        bool isFuture = (selectedYear > now.year) ||
            (selectedYear == now.year && month > now.month);

        bool isSelected = selectedMonth == month;

        return InkWell(
          onTap: isFuture
              ? null // ❌ disable click
              : () {
            setState(() {
              selectedMonth = month;
            });
          },
          child: Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: controllers.storage.read("role")=="7"&&isSelected
                  ?colorsConst.primary:controllers.storage.read("role")!="7"&&isSelected?colorsConst.primary
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: CustomText(
              text: [
                'Jan','Feb','Mar','Apr','May','Jun',
                'Jul','Aug','Sep','Oct','Nov','Dec'
              ][index],
              colors: isFuture
                  ? Colors.grey
                  : isSelected
                  ? Colors.white
                  : Colors.black, isCopy: false,
            ),
          ),
        );
      }),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width,
          color: controllers.storage.read("role")=="7"?colorsConst.primary:colorsConst.primary,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    isYearPickerVisible = !isYearPickerVisible;
                  });
                },
                child: CustomText(text:
                  '${['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][selectedMonth - 1]} $selectedYear',
                  colors: Colors.white, size: 20, isCopy: false,),
              ),
              // if (isYearPickerVisible)
              //   _buildYearSelector(),
            ],
          ),
        ),
        Expanded(
          child: isYearPickerVisible ? _buildYearGrid() : _buildMonthGrid(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: CustomText(text:'Cancel', colors: controllers.storage.read("role")=="7"?colorsConst.primary:colorsConst.primary, isCopy: false,),
            ),
            TextButton(
              onPressed: () {
                widget.onSelected(DateTime(selectedYear, selectedMonth));
                Navigator.of(context).pop();
              },
              child:CustomText(text:'OK', colors: controllers.storage.read("role")=="7"?colorsConst.primary:colorsConst.primary, isCopy: false),
            ),
          ],
        ),
      ],
    );
  }
}

void showCustomMonthPicker({
  required BuildContext context,
  required RxString date1,
  required RxString date2,
  required RxString month,
  required void Function() function,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      final now = DateTime.now();

      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: SizedBox(
          width: 300,
          height: 400,
          child: CustomMonthPicker(
            // initialMonth: DateTime.now().month,
            // initialYear:  DateTime.now().year,
            initialMonth: pyrlCtr.monthCount.value,

            initialYear: (pyrlCtr.year != null && pyrlCtr.year != 0)
                ? pyrlCtr.year
                : now.year,
            firstYear: 2024,
            lastYear: now.year,
            // onSelected: onSelected,
            onSelected: (value) {
                var m  =value.month ;
                var y = value.year;
                pyrlCtr.saveMonth = value.month;
                pyrlCtr.year = value.year;
                pyrlCtr.start =
                ("01-${(m.toString().padLeft(2, "0"))}-$y");
                var ex = pyrlCtr.start.split("-");
                var date = DateTime(int.parse(ex.first), int.parse(ex[1]) + 1,0);
                pyrlCtr.lastDate = date.day;
                pyrlCtr.end = "${date.day.toString().padLeft(2, "0")}-${m.toString().padLeft(2, "0")}-$y";
                month.value = DateFormat('MMMM').format(DateTime(0, int.parse(m.toString().padLeft(2, "0"))));
                pyrlCtr.monthCount.value = date.month;
                // print("date.year");
                // print(payrollCtr.year);
                date1.value=pyrlCtr.start;
                date2.value=pyrlCtr.end;
                pyrlCtr.noOfWorkingDay.text=pyrlCtr.lastDate.toString();
                function();
            },
          ),
        ),
      );
    },
  );
}

void showMonthPicker({
  required BuildContext context,
  required RxString month,
  required VoidCallback  function,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: SizedBox(
          width: 300,
          height: 400,
          child: CustomMonthPicker(
            initialMonth: DateTime.now().month,
            initialYear:  DateTime.now().year,
            firstYear: 2024,
            lastYear: 2050,
            // onSelected: onSelected,
            onSelected: (value) {
                var m  =value.month ;
                var y = value.year;
                pyrlCtr.saveMonth = value.month;
                pyrlCtr.year = value.year;
                pyrlCtr.start =
                ("01-${(m.toString().padLeft(2, "0"))}-$y");
                var ex = pyrlCtr.start.split("-");
                var date = DateTime(int.parse(ex.first), int.parse(ex[1]) + 1,0);
                pyrlCtr.lastDate = date.day;
                pyrlCtr.end = "${date.day.toString().padLeft(2, "0")}-${m.toString().padLeft(2, "0")}-$y";
                month.value =  DateFormat('MMMM yyyy').format(DateTime(y, m));
                function();
            },
          ),
        ),
      );
    },
  );
}
void showMonthPicker2({
  required BuildContext context,
  required RxString month,
  VoidCallback?  function,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: SizedBox(
          width: 300,
          height: 400,
          child: CustomMonthPicker(
            initialMonth: DateTime.now().month,
            initialYear:  DateTime.now().year,
            firstYear: 2024,
            lastYear: 2050,
            // onSelected: onSelected,
            onSelected: (value) {
                var m  =value.month ;
                var y = value.year;
                pyrlCtr.saveMonth = value.month;
                pyrlCtr.year = value.year;
                pyrlCtr.start =
                ("01-${(m.toString().padLeft(2, "0"))}-$y");
                var ex = pyrlCtr.start.split("-");
                var date = DateTime(int.parse(ex.first), int.parse(ex[1]) + 1,0);
                pyrlCtr.lastDate = date.day;
                pyrlCtr.end = "${date.day.toString().padLeft(2, "0")}-${m.toString().padLeft(2, "0")}-$y";
                month.value =  DateFormat('MMMM yyyy').format(DateTime(y, m));
                function!();
            },
          ),
        ),
      );
    },
  );
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../common/constant/colors_constant.dart';
import '../controller/controller.dart';
import 'custom_text.dart';

class CustomTableHeader extends StatelessWidget {
  final bool showCheckbox;
  final bool isAllSelected;
  final Function(bool?) onSelectAll;
  final VoidCallback onSortDate;

  const CustomTableHeader({
    super.key,
    required this.showCheckbox,
    required this.isAllSelected,
    required this.onSelectAll,
    required this.onSortDate,
  });

  @override
  Widget build(BuildContext context) {
    final headerChildren = <Widget>[
      if (showCheckbox)
        Container(
          height: 40,
          alignment: Alignment.center,
          child: Checkbox(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2.0),
            ),
            side: WidgetStateBorderSide.resolveWith(
                  (states) => const BorderSide(width: 1.0, color: Colors.white),
            ),
            checkColor: colorsConst.primary,
            activeColor: Colors.white,
            value: isAllSelected,
            onChanged: onSelectAll,
          ),
        ),
      _headerCell("Actions", textAlign: TextAlign.center),
      _headerCell(controllers.getUserHeading("name") ?? "Name"),
      _headerCell(controllers.getUserHeading("company_name") ?? "Company Name"),
      _headerCell(controllers.getUserHeading("phone_no") ?? "Mobile No."),
      _headerCell(controllers.getUserHeading("details_of_service_required") ?? "Details of Service Required"),
      _headerCell(controllers.getUserHeading("source") ?? "Source Of Prospect"),
      Container(
        height: 45,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Row(
          children: [
            const CustomText(
              textAlign: TextAlign.left,
              text: "Added Date",
              size: 15,
              colors: Colors.white,
            ),
            const SizedBox(width: 3),
            GestureDetector(
              onTap: onSortDate,
              child: Obx(
                    () => Image.asset(
                  controllers.sortField.value.isEmpty
                      ? "assets/images/arrow.png"
                      : controllers.sortOrder.value == 'asc'
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
      _headerCell(controllers.getUserHeading("city") ?? "City"),
      _headerCell(controllers.getUserHeading("status_update") ?? "Status Update"),
    ];

    return Table(
      columnWidths:showCheckbox?{
    0: FlexColumnWidth(1),
    1: const FlexColumnWidth(3),
    2: const FlexColumnWidth(2),
    3: const FlexColumnWidth(2.5),
    4: const FlexColumnWidth(2),
    5: const FlexColumnWidth(3),
    6: const FlexColumnWidth(2),
    7: const FlexColumnWidth(2),
    8: const FlexColumnWidth(2),
    9: const FlexColumnWidth(3),
    }:{
    0: const FlexColumnWidth(3),
    1: const FlexColumnWidth(2),
    2: const FlexColumnWidth(2.5),
    3: const FlexColumnWidth(2),
    4: const FlexColumnWidth(3),
    5: const FlexColumnWidth(2),
    6: const FlexColumnWidth(2),
    7: const FlexColumnWidth(2),
    8: const FlexColumnWidth(3),
    },
      border: TableBorder(
        horizontalInside: BorderSide(width: 0.5, color: Colors.grey.shade400),
        verticalInside: BorderSide(width: 0.5, color: Colors.grey.shade400),
      ),
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: colorsConst.primary,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(5),
              topRight: Radius.circular(5),
            ),
          ),
          children: headerChildren,
        ),
      ],
    );
  }

  String _formatHeading(String heading) {
    String cleaned = heading.replaceAll(",", "").trim();
    return cleaned
        .split(" ")
        .map((word) => word.isNotEmpty
        ? word[0].toUpperCase() + word.substring(1).toLowerCase()
        : "")
        .join(" ");
  }

  Widget _headerCell(String text, {TextAlign textAlign = TextAlign.left}) {
    return Container(
      height: 45,
      alignment:
      textAlign == TextAlign.center ? Alignment.center : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: CustomText(
        textAlign: textAlign,
        text: _formatHeading(text),
        size: 15,
        colors: Colors.white,
      ),
    );
  }
}

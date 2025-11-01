import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../common/constant/colors_constant.dart';
import '../controller/controller.dart';
import '../controller/table_controller.dart';
import '../models/user_heading_obj.dart';

class CustomTableHeader extends StatelessWidget {
  final bool showCheckbox;
  final bool isAllSelected;
  final Function(bool?) onSelectAll;
  final VoidCallback onSortDate;
  final VoidCallback onSortName;

  const CustomTableHeader({
    super.key,
    required this.showCheckbox,
    required this.isAllSelected,
    required this.onSelectAll,
    required this.onSortDate,
    required this.onSortName,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Obx(() {
      final headings = tableController.tableHeadings;
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
        _headerCell("Actions", screenWidth, textAlign: TextAlign.center),

        ...headings.map((h) {
          final lower = h.toLowerCase();
          if (lower == "added date" ||
              lower == "prospect enrollment date" ||
              lower == "date") {
            return Container(
              height: 45,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Added Date",
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontFamily: "Lato",
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 3),
                  GestureDetector(
                    onTap: onSortDate,
                    child: Obx(() => Image.asset(
                      controllers.sortField.value.isEmpty
                          ? "assets/images/arrow.png"
                          : controllers.sortOrder.value == 'asc'
                          ? "assets/images/arrow_up.png"
                          : "assets/images/arrow_down.png",
                      width: 15,
                      height: 15,
                    )),
                  ),
                ],
              ),
            );
          } else {
            return Container(
              height: 45,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      h,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontFamily: "Lato",
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 3),
                  GestureDetector(
                    onTap: (){
                      final selected = controllers.fields.firstWhere(
                            (f) => f.userHeading == h,
                        orElse: () => CustomerField(userHeading: h, systemField: h.toLowerCase(), id: '', isRequired: ''),
                      );
                      controllers.sortField.value = selected.systemField;
                      controllers.sortOrderN.value =
                      controllers.sortOrderN.value == 'asc' ? 'desc' : 'asc';
                    },
                    child: Obx(() => Image.asset(
                      controllers.sortField.value.isEmpty
                          ? "assets/images/arrow.png"
                          : controllers.sortOrderN.value == 'asc'
                          ? "assets/images/arrow_up.png"
                          : "assets/images/arrow_down.png",
                      width: 15,
                      height: 15,
                    )),
                  ),
                ],
              ),
            );
          }
        }),
      ];

      final totalColumns = headings.length + 1 + (showCheckbox ? 1 : 0);
      final Map<int, TableColumnWidth> columnWidths = {};

      columnWidths[0] =
      showCheckbox ? const FlexColumnWidth(1) : const FlexColumnWidth(3);
      columnWidths[1] = const FlexColumnWidth(3);
      columnWidths[2] = const FlexColumnWidth(2.5);

      for (int i = 3; i < totalColumns; i++) {
        columnWidths[i] = const FlexColumnWidth(2);
      }

      return Table(
        columnWidths: columnWidths,
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
    });
  }

  Widget _headerCell(String text, double width,
      {TextAlign textAlign = TextAlign.left}) {
    return Container(
      height: width <= 922 ? 65 : 45,
      width: 150,
      alignment:
      textAlign == TextAlign.center ? Alignment.center : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Text(
        text,
        textAlign: textAlign,
        style: TextStyle(
          fontSize: text == "Details Of Services Required" ? 13 : 15,
          color: Colors.white,
          fontFamily: "Lato",
        ),
        maxLines: null,
        softWrap: true,
        overflow: TextOverflow.visible,
      ),
    );
  }
}

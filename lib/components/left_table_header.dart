import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../common/constant/colors_constant.dart';
import '../controller/controller.dart';
import '../controller/table_controller.dart';
import '../models/user_heading_obj.dart';

class LeftTableHeader extends StatelessWidget {
  final bool showCheckbox;
  final bool isAllSelected;
  final Function(bool?) onSelectAll;
  final VoidCallback onSortDate;

  const LeftTableHeader({
    super.key,
    required this.showCheckbox,
    required this.isAllSelected,
    required this.onSelectAll,
    required this.onSortDate,
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
              side: const BorderSide(width: 1.0, color: Colors.white),
              checkColor: colorsConst.primary,
              activeColor: Colors.white,
              value: isAllSelected,
              onChanged: onSelectAll,
            ),
          ),

        _headerCell("Actions", screenWidth, textAlign: TextAlign.center),
        if (headings.isNotEmpty) _buildResizableHeader(headings.first),
      ];

      // Column widths
      final Map<int, TableColumnWidth> columnWidths = {
        //Santhiya
        0: showCheckbox ? const FlexColumnWidth(0.6) : const FlexColumnWidth(1.5),
        1: showCheckbox ? const FlexColumnWidth(2) : const FlexColumnWidth(2.3),
        2: FixedColumnWidth(tableController.colWidth[headings.first] ?? 150),
      };

      return Table(
        columnWidths: columnWidths,
        border: TableBorder(
          horizontalInside: BorderSide(width: 0.5, color: Colors.grey.shade400),
          verticalInside: BorderSide(width: 0.5, color: Colors.grey.shade400),
          right: BorderSide(width: 0.5, color: Colors.grey.shade400),
        ),
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: colorsConst.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5),
              ),
            ),
            children: headerChildren,
          ),
        ],
      );
    });
  }

  // -------------------------------------------------------------------------
  // 🔥 NEW: RESIZABLE HEADER (LIKE YOUR RIGHT SIDE TABLE)
  // -------------------------------------------------------------------------
  Widget _buildResizableHeader(String heading) {
    return Stack(
      children: [
        Container(
          height: 45,
          width: tableController.colWidth[heading] ?? 150,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  heading,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    fontFamily: "Lato",
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // SORT BUTTON
              GestureDetector(
                onTap: () {
                  final selected = controllers.fields.firstWhere(
                        (f) => f.userHeading == heading,
                    orElse: () => CustomerField(
                        userHeading: heading,
                        systemField: heading.toLowerCase(),
                        id: '',
                        isRequired: ''),
                  );

                  controllers.sortField.value = selected.systemField;
                  controllers.sortOrderN.value =
                  controllers.sortOrderN.value == 'asc'
                      ? 'desc'
                      : 'asc';
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
        ),

        // DRAG RESIZER HANDLE
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          width: 10,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragUpdate: (details) {
              final current = tableController.colWidth[heading] ?? 150.0;
              final newWidth =
              (current + details.delta.dx).clamp(80.0, 400.0);
              tableController.colWidth[heading] = newWidth;
              tableController.colWidth.refresh();
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.resizeColumn,
              child: Container(color: Colors.transparent),
            ),
          ),
        ),
      ],
    );
  }

  Widget _headerCell(String text, double width,
      {TextAlign textAlign = TextAlign.left}) {
    return Container(
      height: width <= 922 ? 65 : 45,
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
      ),
    );
  }
}


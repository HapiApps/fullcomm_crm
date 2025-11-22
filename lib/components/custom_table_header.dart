import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../common/constant/colors_constant.dart';
import '../controller/controller.dart';
import '../controller/table_controller.dart';
import '../models/user_heading_obj.dart';

class CustomTableHeader extends StatefulWidget {
  final VoidCallback onSortDate;
  final VoidCallback onSortName;

  const CustomTableHeader({
    super.key,
    required this.onSortDate,
    required this.onSortName,
  });

  @override
  State<CustomTableHeader> createState() => _CustomTableHeaderState();
}

class _CustomTableHeaderState extends State<CustomTableHeader> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final headings = tableController.tableHeadings;

      final headerChildren = <Widget>[];

      // ---------------------------------------------
      // 🚀 BUILD DRAGGABLE HEADER COLUMNS
      // ---------------------------------------------
      for (int index = 1; index < headings.length; index++) {
        final h = headings[index];

        headerChildren.add(
          DragTarget<String>(
            onWillAccept: (draggedHeader) => draggedHeader != null,
            onAccept: (draggedHeader) {
              int oldIndex = headings.indexOf(draggedHeader);
              int newIndex = index;

              if (oldIndex != -1 && newIndex != -1) {
                // Move column inside list
                final item = headings.removeAt(oldIndex);
                headings.insert(newIndex, item);

                // Same for column width
                final width = tableController.colWidth[item];
                tableController.colWidth.remove(item);
                tableController.colWidth[item] = width!;

                tableController.tableHeadings.refresh();
                tableController.colWidth.refresh();
              }
            },

            builder: (context, candidate, rejected) {
              return LongPressDraggable<String>(
                data: h,
                feedback: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: tableController.colWidth[h],
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      h,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.3,
                  child: _buildHeaderCell(h),
                ),
                child: _buildHeaderCell(h),
              );
            },
          ),
        );
      }

      // BUILD TABLE
      final Map<int, TableColumnWidth> columnWidths = {};
      int i = 0;
      for (var h in headings.skip(1)) {
        columnWidths[i++] = FixedColumnWidth(tableController.colWidth[h]!);
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
            ),
            children: headerChildren,
          ),
        ],
      );
    });
  }

  Widget _buildHeaderCell(String h) {
    final lower = h.toLowerCase();
    return Stack(
      children: [
        Container(
          height: 45,
          width: tableController.colWidth[h],
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  lower == "added date" ||
                      lower == "prospect enrollment date" ||
                      lower == "date"
                      ? "Added Date"
                      : h,
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
                onTap: () {
                  if (lower == "added date" ||
                      lower == "prospect enrollment date" ||
                      lower == "date") {
                    widget.onSortDate();
                  } else {
                    final selected = controllers.fields.firstWhere(
                          (f) => f.userHeading == h,
                      orElse: () => CustomerField(
                          userHeading: h,
                          systemField: h.toLowerCase(),
                          id: '',
                          isRequired: ''),
                    );

                    controllers.sortField.value = selected.systemField;

                    controllers.sortOrderN.value =
                    controllers.sortOrderN.value == 'asc'
                        ? 'desc'
                        : 'asc';
                  }
                },
                child: Obx(() => Image.asset(
                  controllers.sortField.value.isEmpty
                      ? "assets/images/arrow.png"
                      : controllers.sortOrder.value == 'asc' ||
                      controllers.sortOrderN.value == 'asc'
                      ? "assets/images/arrow_up.png"
                      : "assets/images/arrow_down.png",
                  width: 15,
                  height: 15,
                )),
              ),
            ],
          ),
        ),

        // Resize handler
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          width: 10,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragUpdate: (details) {
              final current = tableController.colWidth[h] ?? 150.0;
              final newWidth =
              (current + details.delta.dx).clamp(80.0, 400.0);
              tableController.colWidth[h] = newWidth;
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
}
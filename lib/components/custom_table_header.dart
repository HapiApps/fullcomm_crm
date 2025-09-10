import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../common/constant/colors_constant.dart';
import '../controller/controller.dart';
import 'custom_text.dart';

class CustomTableHeader extends StatelessWidget {
  final bool isAllSelected;
  final Function(bool?) onSelectAll; // callback
  final VoidCallback onSortDate; // callback

  const CustomTableHeader({
    super.key,
    required this.isAllSelected,
    required this.onSelectAll,
    required this.onSortDate,
  });

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(3),
        2: FlexColumnWidth(2),
        3: FlexColumnWidth(2.5),
        4: FlexColumnWidth(2),
        5: FlexColumnWidth(3),
        6: FlexColumnWidth(2),
        7: FlexColumnWidth(2),
        8: FlexColumnWidth(2),
        9: FlexColumnWidth(3),
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
          children: [
            // Checkbox column
            Container(
              height: 40,
              alignment: Alignment.center,
              child: Checkbox(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2.0),
                ),
                side: WidgetStateBorderSide.resolveWith(
                      (states) => BorderSide(width: 1.0, color: Colors.white),
                ),
                checkColor: colorsConst.primary,
                activeColor: Colors.white,
                value: isAllSelected,
                onChanged: onSelectAll,
              ),
            ),
            _headerCell("Actions", textAlign: TextAlign.center),
            _headerCell("Name"),
            _headerCell("Company Name"),
            _headerCell("Mobile No."),
            _headerCell("Details of Service Required"),
            _headerCell("Source Of Prospect"),
            Container(
              height: 45,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Row(
                children: [
                  CustomText(
                    textAlign: TextAlign.left,
                    text: "Added Date",
                    size: 15,
                    colors: Colors.white,
                  ),
                  const SizedBox(width: 3),
                  GestureDetector(
                    onTap: onSortDate,
                    child: Obx(()=>Image.asset(controllers.sortField.value.isEmpty?
                    "assets/images/arrow.png":controllers.sortOrder.value == 'asc'?"assets/images/arrow_up.png":"assets/images/arrow_down.png",
                      width: 15,height: 15,),)
                  ),
                ],
              ),
            ),
            _headerCell("City"),
            _headerCell("Status Update"),
          ],
        ),
      ],
    );
  }

  Widget _headerCell(String text, {TextAlign textAlign = TextAlign.left}) {
    return Container(
      height: 45,
      alignment:
      textAlign == TextAlign.center ? Alignment.center : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: CustomText(
        textAlign: textAlign,
        text: text,
        size: 15,
        colors: Colors.white,
      ),
    );
  }
}

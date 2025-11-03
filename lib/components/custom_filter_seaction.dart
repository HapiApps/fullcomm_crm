import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/controller/controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../common/constant/colors_constant.dart';
import 'action_button.dart';
import 'custom_search_textfield.dart';
import 'custom_text.dart';

class FilterSection extends StatelessWidget {
  final String title;
  final int count;
  final List<dynamic> itemList;
  final VoidCallback onDelete;
  final VoidCallback onMail;
  final VoidCallback onPromote;
  final VoidCallback? onDisqualify;
  final VoidCallback? onDemote;
  final VoidCallback? onQualify;
  final TextEditingController searchController;
  final ValueChanged<Object?>? onSearchChanged;
  final VoidCallback onSelectMonth;
  final Rx<DateTime?> selectedMonth;
  final RxString selectedSortBy;
  final RxBool isMenuOpen;

  const FilterSection({
    super.key,
    required this.title,
    required this.count,
    required this.itemList,
    required this.onDelete,
    required this.onMail,
    required this.onPromote,
     this.onDisqualify,
    this.onDemote,
    required this.searchController,
    required this.onSearchChanged,
    required this.onSelectMonth,
    required this.selectedMonth,
    required this.selectedSortBy,
    required this.isMenuOpen, this.onQualify,
  });

  @override
  Widget build(BuildContext context) {
    final FocusNode _focusNode = FocusNode();
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CustomText(
                  text: title,
                  colors: colorsConst.primary,
                  isBold: true,
                  size: 15,
                ),
                10.width,
                CircleAvatar(
                  backgroundColor: colorsConst.primary,
                  radius: 17,
                  child: CustomText(
                    text: count.toString(),
                    colors: Colors.white,
                    size: 13,
                  ),
                ),
              ],
            ),

            // --- Action Buttons ---
            itemList.isEmpty
                ? 0.height
                : title=="Disqualified"?ActionButton(
              width: 100,
              image: "assets/images/action_promote.png",
              name: "Qualified",
              toolTip:
              "Click here to Qualified the customer details",
              callback: onQualify!,
              ):Row(
              children: [
                ActionButton(
                  width: 100,
                  image: "assets/images/action_delete.png",
                  name: "Delete",
                  toolTip:
                  "Click here to delete the customer details",
                  callback: onDelete,
                ),
                10.width,
                ActionButton(
                  width: 100,
                  image: "assets/images/action_mail.png",
                  name: "Mail",
                  toolTip:
                  "Click here to mail send the customer details",
                  callback: onMail,
                ),
                10.width,
                title=="Customers"?0.height:ActionButton(
                  width: 100,
                  image: "assets/images/action_promote.png",
                  name: "Promote",
                  toolTip:
                  "Click here to promote the customer details",
                  callback: onPromote,
                ),
                10.width,
                title=="Suspects"?ActionButton(
                    width: 100,
                    image: "assets/images/action_disqualified.png",
                    name: "Disqualify",
                    toolTip: "Click here to disqualify the customer details",
                    callback: onDisqualify!,
                    ):ActionButton(
                  width: 100,
                  image: "assets/images/action_disqualified.png",
                  name: "Demote",
                  toolTip: "Click here to disqualify the customer details",
                  callback: onDemote!,
                ),
                5.width,
              ],
            ),
          ],
        ),
        10.height,
        Divider(thickness: 1.5, color: colorsConst.secondary),
        10.height,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomSearchTextField(
              hintText: "Search Name, Company, Mobile No.",
              controller: searchController,
              onChanged: onSearchChanged,
            ),
            Row(
              children: [
                InkWell(
                  onTap: (){
                    controllers.showDatePickerDialog(context);
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
                          final range = controllers.selectedRange.value;
                          if (range == null) {
                            return const Text(
                              "Filter by Date Range",
                              style: TextStyle(color: Colors.black,fontFamily: "Lato",),
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
                        const Icon(Icons.calendar_today,
                            color: Colors.black, size: 17),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ),
                ),
                10.width,
                // Select Month
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
                10.width,
                // Popup Filter
                PopupMenuButton<String>(
                  offset: const Offset(0, 40),
                  color: const Color(0xffE7EEF8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2),
                  ),
                  onSelected: (value) {
                    controllers.selectedRange.value = null;
                    selectedMonth.value = null;
                    selectedSortBy.value = value;
                    _focusNode.requestFocus();
                    isMenuOpen.value = false;
                  },
                  onCanceled: () {
                    isMenuOpen.value = false;
                  },
                  onOpened: () {
                    isMenuOpen.value = true;
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                        value: "Today",
                        child: Text("Today",
                            style: TextStyle(color: colorsConst.textColor))),
                    PopupMenuItem(
                        value: "Yesterday",
                        child: Text("Yesterday",
                            style: TextStyle(color: colorsConst.textColor))),
                    PopupMenuItem(
                        value: "Last 7 Days",
                        child: Text("Last 7 Days",
                            style:
                            TextStyle(color: colorsConst.textColor))),
                    PopupMenuItem(
                        value: "Last 30 Days",
                        child: Text("Last 30 Days",
                            style:
                            TextStyle(color: colorsConst.textColor))),
                    // PopupMenuItem(
                    //     value: "All",
                    //     child: Text("All",
                    //         style:
                    //         TextStyle(color: colorsConst.textColor))),
                  ],
                  child: Container(
                    color: colorsConst.secondary,
                    height: 36,
                    padding: const EdgeInsets.all(9),
                    child: Row(
                      children: [
                        Obx(() => Text(
                         selectedSortBy.value.isEmpty
                              ? "Filter by Date Range"
                              : selectedSortBy.value,
                          style: TextStyle(
                            fontFamily: "Lato",
                            color: colorsConst.textColor,
                          ),

                        )),
                        5.width,
                        Obx(() => Icon(
                          isMenuOpen.value
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          color: colorsConst.textColor,
                        )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

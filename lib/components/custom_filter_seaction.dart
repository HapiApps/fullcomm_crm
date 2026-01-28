import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/controller/controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../common/constant/colors_constant.dart';
import '../models/new_lead_obj.dart';
import 'action_button.dart';
import 'custom_search_textfield.dart';
import 'custom_text.dart';
import 'keyboard_search.dart';

class FilterSection extends StatelessWidget {
  final String title;
  final int count;
  final bool isActionEnabled;
  final List<dynamic> itemList;
  final RxList<NewLeadObj> leadFuture;
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
  //Santhiya
  final FocusNode? focusNode;

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
    required this.isMenuOpen,
    this.onQualify,
    required this.leadFuture,
    this.isActionEnabled = true, this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        isActionEnabled?Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CustomText(
                  text: title,
                  colors: colorsConst.primary,
                  isBold: true,
                  size: 15,
                  isCopy: false,
                ),
                10.width,
                CircleAvatar(
                  backgroundColor: colorsConst.primary,
                  radius: 17,
                  child: CustomText(
                    text: count.toString(),
                    colors: Colors.white,
                    size: 13,
                    isCopy: false,
                  ),
                ),
                10.width,
                SizedBox(
                  width: 350,
                  child: KeyboardDropdownField<NewLeadObj>(
                    items: leadFuture,
                    borderRadius: 5,
                    borderColor: Colors.grey.shade300,
                    hintText: "",
                    labelText: "Search Mobile Number",
                    labelBuilder: (customer) =>
                    '${customer.firstname}${customer.companyName.toString().isEmpty ? "" : ", ${customer.companyName}"} ${customer.firstname.toString().isEmpty ? "" : "-"} ${customer.mobileNumber}',
                    itemBuilder: (customer) {
                      return Container(
                        width: 400,
                        alignment: Alignment.topLeft,
                        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                        child: CustomText(
                          text:
                          '${customer.firstname}${customer.companyName.toString().isEmpty ? "" : ", ${customer.companyName}"} ${customer.firstname.toString().isEmpty ? "" : "-"} ${customer.mobileNumber}',
                          colors: Colors.black,
                          size: 14,
                          isCopy: false,
                          textAlign: TextAlign.start,
                        ),
                      );
                    },
                    textEditingController: controllers.cusController,
                    onSelected: (value) {
                      selectedMonth.value = null;
                      selectedSortBy.value = "";
                      if(value.mobileNumber.toString().isNotEmpty){
                        onSearchChanged!(value.mobileNumber.toString());
                      }
                      //controllers.selectCustomer(value);
                    },
                    onClear: () {
                      if (onSearchChanged != null) onSearchChanged!("");
                      controllers.clearSelectedCustomer();
                    },
                  ),
                ),
              ],
            ),

            // --- Action Buttons ---
            Row(
              children: [
                if(itemList.isNotEmpty)
                CustomText(text: "Selected count: ${itemList.length}", isCopy: false),15.width,
                itemList.isEmpty
                    ? 0.height
                    : title == "No Matches" || title == "Target Leads"
                        ? ActionButton(
                            width: 100,
                            image: "assets/images/action_promote.png",
                            name: "Qualified",
                            toolTip: "Click here to Qualified the customer details",
                            callback: onQualify!,
                          )
                        : Row(
                            children: [
                              ActionButton(
                                width: 100,
                                image: "assets/images/action_delete.png",
                                name: "Delete",
                                toolTip: "Click here to delete the customer details",
                                callback: onDelete,
                              ),
                              10.width,
                              title == "Customers"
                                  ? 0.height
                                  : ActionButton(
                                      width: 100,
                                      image: "assets/images/action_promote.png",
                                      name: "Promote",
                                      toolTip:
                                          "Click here to promote the customer details",
                                      callback: onPromote,
                                    ),
                              10.width,
                              title == "Suspects"
                                  ? ActionButton(
                                      width: 110,
                                      image:
                                          "assets/images/action_disqualified.png",
                                      name: "No Matches",
                                      toolTip:
                                          "Click here to No Matches the customer details",
                                      callback: onDisqualify!,
                                    )
                                  : ActionButton(
                                      width: 100,
                                      image:
                                          "assets/images/action_disqualified.png",
                                      name: "Demote",
                                      toolTip:
                                          "Click here to No Matches the customer details",
                                      callback: onDemote!,
                                    ),
                              10.width,
                            ],
                          ),
                ActionButton(
                  width: 100,
                  image: "assets/images/action_mail.png",
                  name: "Mail",
                  toolTip: "Click here to mail send the customer details",
                  callback: onMail,
                ),
                5.width,
              ],
            ),
          ],
        ):0.height,
        10.height,
        isActionEnabled?Divider(thickness: 1.5, color: colorsConst.secondary) :0.height,
        10.height,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: CustomSearchTextField(
                focusNode:focusNode,
                hintText: "Search Name, Company",
                controller: searchController,
                onChanged: (value) {
                  if (onSearchChanged != null) onSearchChanged!(value);
                  if (value.toString().isEmpty) {
                    controllers.clearSelectedCustomer();
                  }
                },
                //onChanged: onSearchChanged,
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              flex: 5,
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                runSpacing: 8,
                children: [
                  Obx(() {
                    final options = [
                      "Today",
                      "Yesterday",
                      "Last 7 Days",
                      "Last 30 Days",
                      "All"
                    ];
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
                                controllers.selectedRange.value = null;
                                selectedMonth.value = null;
                                selectedSortBy.value = val!;
                                onSearchChanged!("");
                                controllers.clearSelectedCustomer();
                                focusNode?.requestFocus();
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
                  InkWell(
                    onTap: () {
                      controllers.showDatePickerDialog(context, selectedSortBy);
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
                          const Icon(Icons.calendar_today,
                              color: Colors.black, size: 17),
                          const SizedBox(width: 10),
                        ],
                      ),
                    ),
                  ),
                  // Popup Filter
                ],
              ),
            )
          ],
        ),
      ],
    );
  }
}

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import '../common/constant/colors_constant.dart';
import '../common/styles/decoration.dart';
import 'custom_text.dart';

class CustomDropDown<T> extends StatefulWidget {
  const CustomDropDown(
      {super.key,
      required this.text,
      required this.valueList,
      required this.saveValue,
      required this.onChanged,
      required this.width, this.isOptional=false});
  final String text;
  final List valueList;
  final T saveValue;
  final double width;
  final bool isOptional;
  final ValueChanged<Object?> onChanged;

  @override
  State<CustomDropDown> createState() => _CustomDropDownState();
}

class _CustomDropDownState extends State<CustomDropDown> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomText(
              text:widget.text,
              colors: colorsConst.fieldHead,
              size: 13,
              isCopy: false,
            ),
            widget.isOptional == true
                ? const CustomText(
              text: "*",
              colors: Colors.red,
              size: 25,
              isCopy: false,
            )
                : 0.width
          ],
        ),
        widget.isOptional == true ? 0.height : 6.height,
        Container(
          width: widget.width,
          height: 40,
          decoration: customDecoration.baseBackgroundDecoration(
              radius: 5,
              color: Colors.white,
              borderColor: Colors.grey.shade400),
          child: DropdownButtonHideUnderline(
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton(
                hint: CustomText(
                    text: "",
                    colors: Colors.grey.shade400,
                    size: 13,
                    isCopy: false,
                    isBold: false),
                underline: const SizedBox(),
                focusColor: Colors.transparent,
                style: TextStyle(
                  color: colorsConst.textColor
                ),
                isExpanded: true,
                value: widget.saveValue,
                iconEnabledColor: Colors.black,
                iconSize: 22,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                items: widget.valueList.map((list) {
                  return DropdownMenuItem(
                    value: list,
                    child: CustomText(
                        text: list,
                        colors:colorsConst.textColor,
                        size: 15,
                        isCopy: false,
                        isBold: false),
                  );
                }).toList(),
                onChanged: widget.onChanged,
              ),
            ),
          ),
        ),
        widget.text.isEmpty ? 10.height : 20.height,
      ],
    );
  }
}

class IndustryDropdown extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final ValueChanged<Map<String, dynamic>?> onChanged;
  final String hint;
  final double width;
  final VoidCallback onAdd;

  const IndustryDropdown({
    super.key,
    required this.items,
    required this.onChanged,
    required this.onAdd,
    this.hint = "Select Industry",
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    // sort by value
    final sortedList = List<Map<String, dynamic>>.from(items)
      ..sort((a, b) =>
          a['value'].toString().toLowerCase().compareTo(
            b['value'].toString().toLowerCase(),
          ));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomText(
              text:"Industry",
              colors: colorsConst.fieldHead,
              size: 13,
              isCopy: false,
            ),
          ],
        ),
        6.height,
        Container(
          width: width,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownSearch<Map<String, dynamic>>(
            items: sortedList,
            itemAsString: (item) => item?['value'] ?? '',
            onChanged: onChanged,

            dropdownDecoratorProps: DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                hintText: hint,
                contentPadding: const EdgeInsets.fromLTRB(10, 8, 0, 2),
                border: InputBorder.none,
              ),
            ),

            popupProps: PopupProps.menu(
              showSearchBox: true,
              fit: FlexFit.loose,

              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                  hintText: "Industry",
                  contentPadding: const EdgeInsets.all(10),
                ),
              ),

              /// 🔥 custom popup with ADD option
              containerBuilder: (ctx, popupWidget) {
                return Column(
                  children: [
                    Expanded(child: popupWidget),
                    const Divider(height: 1),
                    InkWell(
                      onTap: () {
                        Navigator.pop(ctx);
                        onAdd(); // callback to open add dialog
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Icon(Icons.add, color: Colors.blue),
                            SizedBox(width: 8),
                            CustomText(
                              text: "Add New Industry",colors: colorsConst.primary,isCopy: false,
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                );
              },

              itemBuilder: (context, item, isSelected) {
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: CustomText(
                    textAlign: TextAlign.start,
                    text:item['value'],isCopy: false,
                  ),
                );
              },
            ),
          ),
        ),
        20.height
      ],
    );
  }
}

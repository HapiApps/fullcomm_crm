import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';

import '../common/styles/decoration.dart';
import 'custom_text.dart';

class CustomDropDown<T> extends StatefulWidget {
  const CustomDropDown(
      {Key? key,
      required this.text,
      required this.valueList,
      required this.saveValue,
      required this.onChanged,
      required this.width})
      : super(key: key);
  final String text;
  final List valueList;
  final T saveValue;
  final double width;
  final ValueChanged<Object?> onChanged;

  @override
  State<CustomDropDown> createState() => _CustomDropDownState();
}

class _CustomDropDownState extends State<CustomDropDown> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: widget.width,
            height: 48,
            decoration: customDecoration.baseBackgroundDecoration(
                radius: 5, color: Colors.white),
            child: DropdownButtonHideUnderline(
              child: ButtonTheme(
                alignedDropdown: true,
                child: DropdownButton(
                  hint: CustomText(
                      text: widget.text,
                      colors: Colors.grey.shade400,
                      size: 13,
                      isBold: false),
                  underline: const SizedBox(),
                  isExpanded: true,
                  value: widget.saveValue,
                  dropdownColor: Colors.white,
                  iconEnabledColor: Colors.white,
                  items: widget.valueList.map((list) {
                    return DropdownMenuItem(
                      value: list,
                      child: CustomText(
                          text: list,
                          colors: Colors.black,
                          size: 13,
                          isBold: false),
                    );
                  }).toList(),
                  onChanged: widget.onChanged,
                ),
              ),
            ),
          ),
          5.height
        ],
      ),
    );
  }
}

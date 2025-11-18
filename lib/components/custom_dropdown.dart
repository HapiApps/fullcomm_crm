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
            ),
            widget.isOptional == true
                ? const CustomText(
              text: "*",
              colors: Colors.red,
              size: 25,
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
                        isCopy: false,
                        text: list,
                        colors:colorsConst.textColor,
                        size: 15,
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

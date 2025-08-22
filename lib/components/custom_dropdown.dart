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
      required this.width});
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text:widget.text,
          colors: colorsConst.headColor,
          size: 15,
        ),
        Container(
          width: widget.width,
          height: 50,
          decoration: customDecoration.baseBackgroundDecoration(
              radius: 8,
              color: Colors.transparent,
              borderColor: const Color(0xffE1E5FA)),
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
                isExpanded: true,
                value: widget.saveValue,
                dropdownColor: colorsConst.secondary,
                iconEnabledColor: Colors.white,
                iconSize: 22,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                items: widget.valueList.map((list) {
                  return DropdownMenuItem(
                    value: list,
                    child: CustomText(
                        isCopy: false,
                        text: list,
                        colors: list.toString().isEmpty
                            ? Colors.black
                            : Colors.white,
                        size: 15,
                        isBold: false),
                  );
                }).toList(),
                onChanged: widget.onChanged,
              ),
            ),
          ),
        ),
        20.height
      ],
    );
  }
}


import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import '../common/constant/colors_constant.dart';
import '../common/styles/decoration.dart';
import 'custom_text.dart';

class CustomEmployeeDropDown<T> extends StatefulWidget {
  const CustomEmployeeDropDown({Key? key, required this.text,
    required this.valueList, required this.saveValue,
    required this.onChanged, required this.width}) : super(key: key);
  final String text;
  final List valueList;
  final T saveValue;
  final double width;
  final ValueChanged<Object?> onChanged;

  @override
  State<CustomEmployeeDropDown> createState() => _CustomEmployeeDropDownState();
}

class _CustomEmployeeDropDownState extends State<CustomEmployeeDropDown> {
  @override
  Widget build(BuildContext context){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children:[
        CustomText(
          text:widget.text,
          colors:colorsConst.secondary,
          size: 15,
        ),
        Container(
          width: widget.width,
          height: 50,
          decoration: customDecoration.baseBackgroundDecoration(
              radius:8,color:Colors.white,
              borderColor: Colors.grey.shade300),
          child: DropdownButtonHideUnderline(
            child:ButtonTheme(
              alignedDropdown:true,
              child: DropdownButton(
                hint: CustomText(text:"",colors:Colors.grey.shade400,
                    size: 13,isBold:false),
                underline: const SizedBox(),
                isExpanded: true,
                value:widget.saveValue,
                dropdownColor:Colors.white,
                iconEnabledColor: Colors.black,
                iconSize: 30,
                items:widget.valueList.map((list){
                  return DropdownMenuItem(
                    value: list,
                    child: CustomText(
                        text: list,colors:Colors.black,size:15,isBold:false),
                  );
                }
                ).toList(),
                onChanged: widget.onChanged,
              ),
            ) ,
          ),
        ),
        25.height
      ],
    );
  }
}

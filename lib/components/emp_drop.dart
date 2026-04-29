
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:get/get.dart';

import '../common/styles/decoration.dart';
import '../models/payroll/unit_model.dart';
import 'Customtext.dart';

class PayrollUnitDropDown extends StatefulWidget {
  final RxList<units> unitList;
  final ValueChanged<units?> onChanged;
  final Color? color;
  final String? text;
  // final String? label;
  final double size;
  final bool? isRequired;
  const PayrollUnitDropDown({super.key, required this.unitList, required this.onChanged, this.color, this.text,
    required this.size, this.isRequired});

  @override
  State<PayrollUnitDropDown> createState() => _PayrollUnitDropDownState();
}

class _PayrollUnitDropDownState extends State<PayrollUnitDropDown> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 47,
      width: widget.size,
      decoration: customDecoration.baseBackgroundDecoration(
        color: widget.color,
        radius: 5,
      ),
      child: Obx(()=>DropdownSearch<units>(
        items: widget.unitList, // Pass the list of EmployeeModel directly
        itemAsString: (units? unit) => unit?.unit_name ?? '',
        onChanged: widget.onChanged,
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            // labelText: widget.label,
              label: Row(
                children: [
                  CustomText(text: "${widget.text}",colors: Colors.grey,size: 15, isCopy: false,),
                  if(widget.isRequired==true)
                    const CustomText(text: "*",colors:Colors.red,size: 15, isCopy: false,),
                ],
              ),
              contentPadding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
              border: InputBorder.none
          ),
        ),
        popupProps: PopupProps.menu(
          showSearchBox: true,
          itemBuilder: (context, units? unit, bool isSelected) {
            return Column(
              children: [
                ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(text:unit?.unit_name ?? '', isCopy: false,),
                      CustomText(text:unit?.address_line_2 ?? '',colors: Colors.grey, isCopy: false),
                      CustomText(text:unit?.leader_name ?? '',colors: Colors.blueGrey, isCopy: false),
                      // CustomText(text:employee?.roleName ?? '',colors: Colors.brown,),
                    ],
                  ),
                  // subtitle: SizedBox(
                  //     width: 200,
                  //     child: CustomText(text:unit?.shifts ?? '',colors: Colors.grey,)),
                ),
                const Divider(color: Colors.grey,)
              ],
            );
          },
        ),
      )),
    );
  }
}


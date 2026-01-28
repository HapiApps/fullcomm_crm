import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:provider/provider.dart';

import '../../common/constant/colors_constant.dart';
import '../../common/styles/decoration.dart';
import '../../components/custom_text.dart';
import '../../controller/reminder_controller.dart';

class SearchCustomDropdown<T> extends StatefulWidget {
  const SearchCustomDropdown(
      {super.key,
      required this.text,
      required this.hintText,
      required this.onChanged,
      required this.width,
      this.isOptional = true,
      required this.valueList});
  final String text;
  final String hintText;
  final List valueList;
  final double width;
  final ValueChanged<Object?> onChanged;
  final bool? isOptional;

  @override
  State<SearchCustomDropdown> createState() => _SearchCustomDropdownState();
}

class _SearchCustomDropdownState extends State<SearchCustomDropdown> {
  //SingleSelectController searchCont = SingleSelectController;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: 40,
      alignment: Alignment.center,
      decoration: customDecoration.baseBackgroundDecoration(
          radius: 5, color: Colors.white, borderColor: Colors.grey.shade300),
      child: CustomDropdown.multiSelect(
        hintText: widget.hintText,
        items: widget.valueList,
        decoration: CustomDropdownDecoration(
            hintStyle: TextStyle(
              color: colorsConst.primary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              // fontStyle: FontStyle.italic,
            ),
            headerStyle: const TextStyle(
                color: Colors.black, fontSize: 13, fontFamily: "Lato"),
            searchFieldDecoration: SearchFieldDecoration(
              hintStyle: TextStyle(
                color: colorsConst.primary,
                fontSize: 13,
              ),
              prefixIcon:
              IconButton(onPressed: () {}, icon: const Icon(Icons.add,size: 15,)),
              textStyle: const TextStyle(
                  color: Colors.black, fontSize: 13, fontFamily: "Lato"),
            ),

            listItemStyle: const TextStyle(
                color: Colors.black,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
              onListChanged: (item) {
                FocusScope.of(context).unfocus();
                remController.changeAssignedIs(context,item);
              },
      ),
    );
  }
}

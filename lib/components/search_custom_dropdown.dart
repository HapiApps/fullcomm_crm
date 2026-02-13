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

// class EmployeeDropdown extends StatelessWidget {
//   final List employeeList;
//   final ValueChanged onChanged;
//   final String? text;
//   final double size;
//   final bool? isRequired;
//   final VoidCallback? callback;
//   const EmployeeDropdown({super.key, required this.employeeList, required this.onChanged, this.text="", required this.size, this.isRequired, this.callback});
//
//   @override
//   Widget build(BuildContext context) {
//     List<UserModel> sortedList = List.from(employeeList)
//       ..sort((a, b) => a.firstname!.toLowerCase().compareTo(b.firstname!.toLowerCase()));
//     return Column(
//       children: [
//         if(sortedList.isEmpty)
//           GestureDetector(
//               onTap: callback,
//               child: const Icon(Icons.refresh,color: Colors.red,size: 15,)),
//         Container(
//           width: size,
//           height: 42,
//           decoration: customDecoration.baseBackgroundDecoration(
//               color: Colors.white,
//               radius: 5,
//               borderColor: Colors.grey.shade200
//           ),
//           child: DropdownSearch<UserModel>(
//             items: sortedList,
//             itemAsString: (UserModel? employee) => employee?.firstname ?? '',
//             onChanged: onChanged,
//             dropdownDecoratorProps: DropDownDecoratorProps(
//               dropdownSearchDecoration: InputDecoration(
//                 // labelText: text, // Set the label text dynamically
//                 //   labelStyle: const TextStyle(
//                 //     fontSize: 13
//                 //   ),
//                   hintText: text,
//                   hintStyle: TextStyle(
//                       fontSize: 14
//                   ),// Set the hint text
//                   contentPadding: const EdgeInsets.fromLTRB(8, 8, 0, 2),
//                   border: InputBorder.none,
//                   suffixIcon: const Icon(Icons.star, color: Colors.red, size: 15)
//               ),
//             ),
//             popupProps: PopupProps.menu(
//               showSearchBox: true,
//               fit: FlexFit.loose,
//               constraints: BoxConstraints(
//                 maxWidth: MediaQuery.of(context).size.width * 0.9, // Set max width for the dropdown popup
//               ),
//               itemBuilder: (context, UserModel? employee, bool isSelected) {
//                 return Padding(
//                   padding: const EdgeInsets.fromLTRB(5, 0, 2, 0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       CustomText(text:employee?.firstname ?? ''),
//                       CustomText(text:employee?.mobileNumber ?? '',colors: colorsConst.greyClr),
//                       CustomText(text:employee?.roleName ?? '',colors: Provider.of<HomeProvider>(context, listen: false).primary),
//                       const Divider(color: Colors.grey,)
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

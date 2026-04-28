import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:security/component/custom_text.dart';
import 'package:security/source/extentions/extensions.dart';
import '../../controller/new_payroll_controller.dart';
import '../../model/employee_model.dart';
import '../../model/myunit_model.dart';
import '../../model/unit_employee_model.dart';

class EmployeeSearchBox extends StatefulWidget {
  final List<EmployeeModel2> allEmployees;
  final Function(EmployeeModel2) onEmployeeSelected;

  const EmployeeSearchBox({
    super.key,
    required this.allEmployees,
    required this.onEmployeeSelected,
  });

  @override
  State<EmployeeSearchBox> createState() => _EmployeeSearchBoxState();
}

class _EmployeeSearchBoxState extends State<EmployeeSearchBox> {
  final TextEditingController _controller = TextEditingController();
  List<EmployeeModel2> _filteredList = [];

  void _onSearchChanged(String value) {
    setState(() {
      if (value.isEmpty) {
        _filteredList = [];
      } else {
        _filteredList = widget.allEmployees
            .where((emp) =>
        (emp.empCode?.toLowerCase().contains(value.toLowerCase()) ?? false) ||
            (emp.fName?.toLowerCase().contains(value.toLowerCase()) ?? false) ||
            (emp.mobileNumber?.toLowerCase().contains(value.toLowerCase()) ?? false))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var mobileSize= MediaQuery.of(context).size.width*0.95;
    var webSize= MediaQuery.of(context).size.width*0.97;
    return SizedBox(
      width: kIsWeb?webSize:mobileSize,
      child: Column(
        children: [
          // 🔎 Search box
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              labelText: "Enter Employee Code Or Name Or Number",
              border: const OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                  borderSide:  const BorderSide(color: Colors.white,),
                  borderRadius: BorderRadius.circular(5)
              ),
              focusedBorder: OutlineInputBorder(
                  borderSide:  const BorderSide(color: Colors.white,),
                  borderRadius: BorderRadius.circular(5)
              ),
              focusedErrorBorder: OutlineInputBorder(
                  borderSide:  const BorderSide(color: Colors.white,),
                  borderRadius: BorderRadius.circular(5)
              ),
              // errorStyle: const TextStyle(height:0.05,fontSize: 12),
              contentPadding:const EdgeInsets.fromLTRB(10, 0, 10, 0),
              errorBorder: OutlineInputBorder(
                  borderSide:  const BorderSide(color: Colors.white,),
                  borderRadius: BorderRadius.circular(5)
              ),
            ),
            onChanged: _onSearchChanged,
          ),

        if (_controller.text.isNotEmpty) // search panrapo mattum
        _filteredList.isNotEmpty
        ? SizedBox(
              height: 200, // adjust as needed
              child: ListView.builder(
                itemCount: _filteredList.length,
                itemBuilder: (context, index) {
                  final emp = _filteredList[index];
                  return ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(emp.fName ?? ''),
                        Row(
                          children: [
                            Text(emp.roleName ?? ''),10.width,
                            Text(emp.mobileNumber ?? ''),
                          ],
                        ),
                      ],
                    ),
                    subtitle: Text("Code: ${emp.empCode ?? ''}"),
                    onTap: () {
                      widget.onEmployeeSelected(emp);

                      // Clear search box and list
                      _controller.clear();
                      setState(() => _filteredList = []);
                    },
                  );
                },
              ),
            )
        : const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
              "No Employee Found",
              style: TextStyle(color: Colors.red),
              ),
        )
        ],
      ),
    );
  }
}

class EmployeeSearchClient extends StatefulWidget {
  final List<unit_em> allEmployees;
  final Function(unit_em) onEmployeeSelected;

  const EmployeeSearchClient({
    super.key,
    required this.allEmployees,
    required this.onEmployeeSelected,
  });

  @override
  State<EmployeeSearchClient> createState() => _EmployeeSearchClientState();
}

class _EmployeeSearchClientState extends State<EmployeeSearchClient> {
  final TextEditingController _controller = TextEditingController();
  List<unit_em> _filteredList = [];

  void _onSearchChanged(String value) {
    setState(() {
      if (value.isEmpty) {
        _filteredList = [];
      } else {
        _filteredList = widget.allEmployees
            .where((emp) =>
        (emp.emp_cd_1
            ?.toLowerCase()
            .contains(value.toLowerCase()) ??
            false) ||
            (emp.firstname
                ?.toLowerCase()
                .contains(value.toLowerCase()) ??
                false) ||
            (emp.mobile_number
                ?.toLowerCase()
                .contains(value.toLowerCase()) ??
                false))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var webWidth=MediaQuery.of(context).size.width*0.5;
    var mobileWidth=MediaQuery.of(context).size.width*0.9;
    return SizedBox(
      width: kIsWeb?webWidth/1.2:mobileWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomText(text: "Guard Selection"),5.height,
          /// 🔍 SEARCH FIELD
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              hintText: "Employee Code/Name/No",
              border: const OutlineInputBorder(),
              suffixIcon: const Icon(Icons.keyboard_arrow_down_sharp,color: Colors.grey,),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade500),
                  borderRadius: BorderRadius.circular(10)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade500),
                  borderRadius: BorderRadius.circular(10)),
              contentPadding:
              const EdgeInsets.fromLTRB(10, 10, 10, 10),
            ),
            onChanged: _onSearchChanged,
          ),

          /// RESULT LIST
          if (_controller.text.isNotEmpty)
            _filteredList.isNotEmpty
                ? Container(
              margin: const EdgeInsets.only(top: 5),
              height: 200,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border:
                  Border.all(color: Colors.grey.shade500),
                  borderRadius: BorderRadius.circular(10)),
              child: ListView.builder(
                itemCount: _filteredList.length,
                itemBuilder: (context, index) {
                  final emp = _filteredList[index];

                  return ListTile(
                    title: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Text(emp.firstname ?? ''),
                        Row(
                          children: [
                            Text(emp.user_role ?? ''),
                            const SizedBox(width: 10),
                            Text(emp.mobile_number ?? ''),
                          ],
                        ),
                      ],
                    ),
                    subtitle:
                    Text("Code: ${emp.emp_cd_1 ?? ''}"),

                    /// ✅ SELECT ACTION
                    onTap: () {
                      widget.onEmployeeSelected(emp);

                      // SHOW SELECTED VALUE IN TEXTFIELD
                      _controller.text =
                      "${emp.emp_cd_1 ?? ''} - ${emp.firstname ?? ''}";

                      // CLOSE KEYBOARD
                      FocusScope.of(context).unfocus();

                      // CLEAR DROPDOWN LIST
                      setState(() {
                        _filteredList = [];
                      });
                    },
                  );
                },
              ),
            )
                : const Padding(
              padding: EdgeInsets.all(0.0),
              child: Text(
                "",
                // "No Employee Found",
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }
}


class UnitSearchBox extends StatefulWidget {
  final List<myunit> allUnits;
  final Function(myunit) onUnitSelected;

  const UnitSearchBox({
    super.key,
    required this.allUnits,
    required this.onUnitSelected,
  });

  @override
  State<UnitSearchBox> createState() => _UnitSearchBoxState();
}

class _UnitSearchBoxState extends State<UnitSearchBox> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _saveController = TextEditingController();
  List<myunit> _filteredList = [];

  void _onSearchChanged(String value) {
    setState(() {
      if (value.isEmpty) {
        _filteredList = [];
      } else {
        _filteredList = widget.allUnits
            .where((emp) =>
        (emp.id?.toLowerCase().contains(value.toLowerCase()) ?? false) ||
            (emp.unit_name?.toLowerCase().contains(value.toLowerCase()) ?? false))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var mobileSize= MediaQuery.of(context).size.width*0.95;
    var webSize= MediaQuery.of(context).size.width*0.9;
    return SizedBox(
      width: kIsWeb?webSize:mobileSize,
      child: Column(
        children: [
          // 🔎 Search box
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              labelText: "Enter Unit Code Or Name",
              border: const OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                  borderSide:  const BorderSide(color: Colors.white,),
                  borderRadius: BorderRadius.circular(5)
              ),
              focusedBorder: OutlineInputBorder(
                  borderSide:  const BorderSide(color: Colors.white,),
                  borderRadius: BorderRadius.circular(5)
              ),
              focusedErrorBorder: OutlineInputBorder(
                  borderSide:  const BorderSide(color: Colors.white,),
                  borderRadius: BorderRadius.circular(5)
              ),
              // errorStyle: const TextStyle(height:0.05,fontSize: 12),
              contentPadding:const EdgeInsets.fromLTRB(10, 0, 10, 0),
              errorBorder: OutlineInputBorder(
                  borderSide:  const BorderSide(color: Colors.white,),
                  borderRadius: BorderRadius.circular(5)
              ),
            ),
            onChanged: _onSearchChanged,
          ),

          if (_controller.text.isNotEmpty) // search panrapo mattum
            _filteredList.isNotEmpty
                ? SizedBox(
              height: 200, // adjust as needed
              child: ListView.builder(
                itemCount: _filteredList.length,
                itemBuilder: (context, index) {
                  final unit = _filteredList[index];
                  return ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(unit.unit_name ?? ''),
                        Text(unit.leader_name ?? ''),
                      ],
                    ),
                    subtitle: Text("Code: ${unit.id ?? ''}"),
                    onTap: () {
                      widget.onUnitSelected(unit);
                      _controller.text = unit.unit_name ?? '';
                      _saveController.text = unit.unit_name ?? '';
                      setState(() => _filteredList = []);
                    },
                  );
                },
              ),
            )
                : _saveController.text.isEmpty?
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "No Unit Found ${_saveController.text.isNotEmpty}",
                style: TextStyle(color: Colors.red),
              ),
            ):SizedBox()
        ],
      ),
    );
  }
}

// class UnitSearchBox extends StatefulWidget {
//   final List<myunit> allUnits;
//   final Function(myunit) onUnitSelected;
//   final Color color;
//   final String text;
//   final double size;
//   final bool isRequired;
//
//   const UnitSearchBox({
//     super.key,
//     required this.allUnits,
//     required this.onUnitSelected,
//     this.color = Colors.white,
//     this.text = "Unit Name",
//     this.size = 300,
//     this.isRequired = false,
//   });
//
//   @override
//   State<UnitSearchBox> createState() => _UnitSearchBoxState();
// }
//
// class _UnitSearchBoxState extends State<UnitSearchBox> {
//   final TextEditingController _controller = TextEditingController();
//   List<myunit> _filteredList = [];
//
//   void _onSearchChanged(String value) {
//     setState(() {
//       if (value.isEmpty) {
//         _filteredList = [];
//       } else {
//         _filteredList = widget.allUnits.where((unit) {
//           final name = unit.unit_name?.toLowerCase() ?? '';
//           final code = unit.id?.toLowerCase() ?? '';
//           return name.contains(value.toLowerCase()) ||
//               code.contains(value.toLowerCase());
//         }).toList();
//       }
//     });
//   }
//
//   Widget build(BuildContext context) {
//     var mobileSize = MediaQuery.of(context).size.width * 0.95;
//     var webSize = MediaQuery.of(context).size.width * 0.9;
//
//     return SizedBox(
//       width: kIsWeb ? webSize : mobileSize,
//       child: Column(
//         children: [
//           TextField(
//             controller: _controller,
//             decoration: InputDecoration(
//               fillColor: widget.color,
//               filled: true,
//               labelText: "Enter Unit Name Or Code",
//               border: const OutlineInputBorder(),
//               enabledBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: widget.color),
//                   borderRadius: BorderRadius.circular(5)),
//               focusedBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: widget.color),
//                   borderRadius: BorderRadius.circular(5)),
//               contentPadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
//             ),
//             onChanged: _onSearchChanged,
//           ),
//
//           // Suggestions / No Unit Found
//           if (_filteredList.isNotEmpty)
//             SizedBox(
//               height: 200,
//               child: ListView.builder(
//                 itemCount: _filteredList.length,
//                 itemBuilder: (context, index) {
//                   final unit = _filteredList[index];
//                   return ListTile(
//                     title: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(unit.unit_name ?? ''),
//                         Text(unit.leader_name ?? ''),
//                       ],
//                     ),
//                     subtitle: Text("Code: ${unit.id ?? ''}"),
//                     onTap: () {
//                       widget.onUnitSelected(unit);
//                       _controller.text = unit.unit_name ?? '';
//                       setState(() => _filteredList = []);
//                     },
//                   );
//                 },
//               ),
//             )
//           else if (_controller.text.isNotEmpty && _filteredList.isEmpty)
//             const Padding(
//               padding: EdgeInsets.all(8.0),
//               child: Text(
//                 "No Unit Found",
//                 style: TextStyle(color: Colors.red),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

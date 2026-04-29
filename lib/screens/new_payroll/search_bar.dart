import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../billing_utils/sized_box.dart';
import '../../controller/new_payroll_controller.dart';

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


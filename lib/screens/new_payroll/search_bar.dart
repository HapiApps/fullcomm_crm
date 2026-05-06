import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../billing_utils/sized_box.dart';
import '../../components/Customtext.dart';
import '../../controller/new_payroll_controller.dart';
import '../../models/all_customers_obj.dart';
import '../../models/employee_details.dart';

class EmployeeSearchBox extends StatefulWidget {
  final List<Staff> allEmployees;
  final Function(Staff) onEmployeeSelected;

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
  List<Staff> _filteredList = [];

  void _onSearchChanged(String value) {
    setState(() {
      if (value.isEmpty) {
        _filteredList = [];
      } else {
        _filteredList = widget.allEmployees
            .where((emp) =>
        (emp.sName.toString().toLowerCase().contains(value.toLowerCase()) ?? false) ||
            (emp.sMobile.toString().toLowerCase().contains(value.toLowerCase()) ?? false))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var mobileSize= MediaQuery.of(context).size.width*0.95;
    var webSize= MediaQuery.of(context).size.width*0.8;
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
              labelText: "Enter Employee Name Or Number",
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
                    tileColor: Colors.white,
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CustomText(text:emp.sName ?? '',isCopy: false,isBold: true,),10.width,
                            CustomText(text:emp.roleTitle ?? '',isCopy: false,colors: Colors.grey,),
                          ],
                        ),
                        Row(
                          children: [
                            CustomText(text:emp.sMobile ?? '',isCopy: false,),
                          ],
                        ),
                      ],
                    ),
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


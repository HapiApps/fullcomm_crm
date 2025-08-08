// emp.id,emp.name, emp.emp_id, emp.email, emp.phone_number, emp.address_id,emp.position,emp.doj,emp.manager_name,emp.salary,
// emp.department,
// a.address_line_1,a.address_line_2,a.area,a.city,a.state,a.country,a.pincode,emp.active
class EmployeeObj {
  String? id;
  String? name;
  String? empId;
  String? email;
  String? phoneNumber;
  String? position;
  String? doj;
  String? managerName;
  String? salary;
  String? department;
  String? doorNo;
  String? streetName;
  String? area;
  String? city;
  String? state;
  String? pinCode;
  String? country;

  EmployeeObj(
      {this.id,
      this.name,
      this.empId,
      this.email,
      this.phoneNumber,
      this.position,
      this.department,
      this.doj,
      this.salary,
      this.managerName,
      this.doorNo,
      this.streetName,
      this.area,
      this.state,
      this.city,
      this.pinCode,
      this.country});

  factory EmployeeObj.fromJson(Map<String, dynamic> json) => EmployeeObj(
      id: json["id"],
      name: json["name"],
      email: json["email"] ?? "",
      empId: json["emp_id"],
      salary: json["salary"],
      position: json["position"],
      phoneNumber: json["phone_number"],
      managerName: json["manager_name"],
      department: json["department"],
      doj: json["doj"],
      doorNo: json["address_line_1"],
      streetName: json["address_line_2"],
      area: json["area"],
      city: json["city"],
      state: json["state"],
      pinCode: json["pincode"],
      country: json["country"]);
}

//
// import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_datagrid/datagrid.dart';
// import 'package:fullcomm_crm/components/custom_text.dart';
//
// class Employee {
//   Employee(
//       this.id, this.name,
//       this.mobileNumber,
//       this.email,
//       this.companyName,
//       this.rating,
//       this.status,
//       this.isCheck
//       );
//
//    int? id;
//    String? name;
//    String? mobileNumber;
//    String? email;
//    String? companyName;
//    String? status;
//    String? rating;
//    bool? isCheck;
// }
//
//
// class EmployeeDataSource extends DataGridSource {
//   EmployeeDataSource({required List<Employee> employeeData}) {
//     _employeeData = employeeData
//         .map<DataGridRow>((e) => DataGridRow(
//
//         cells: [
//       DataGridCell<bool>(columnName: 'isCheck', value: e.isCheck),
//       DataGridCell<String>(columnName: 'name', value: e.name),
//       DataGridCell<String>(
//           columnName: 'mobileNumber', value: e.mobileNumber),
//       DataGridCell<String>(columnName: 'email', value: e.email),
//       DataGridCell<String>(columnName: 'companyName', value: e.companyName),
//       DataGridCell<String>(columnName: 'status', value: e.status),
//       DataGridCell<String>(columnName: 'rating', value: e.rating),
//     ]
//     )
//     )
//         .toList();
//   }
//
//   List<DataGridRow> _employeeData = [];
//
//   @override
//   List<DataGridRow> get rows => _employeeData;
//
//   @override
//   DataGridRowAdapter buildRow(DataGridRow row) {
//     return DataGridRowAdapter(
//      // color: Colors.greenAccent,
//         cells: row.getCells().map<Widget>((e) {
//           return CustomText(
//             text: e.value.toString(),
//             colors: Colors.black,
//             size: 15,
//             textAlign: TextAlign.right,
//           );
//         }).toList());
//   }
// }

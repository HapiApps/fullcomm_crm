
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
    id: json["id"]?.toString() ?? '',
    name: json["name"]?.toString() ?? '',
    email: json["email"]?.toString() ?? '',
    empId: json["emp_id"]?.toString() ?? '',
    salary: json["salary"]?.toString() ?? '',
    position: json["position"]?.toString() ?? '',
    phoneNumber: json["phone_number"]?.toString() ?? '',
    managerName: json["manager_name"]?.toString() ?? '',
    department: json["department"]?.toString() ?? '',
    doj: json["doj"]?.toString() ?? '',
    doorNo: json["address_line_1"]?.toString() ?? '',
    streetName: json["address_line_2"]?.toString() ?? '',
    area: json["area"]?.toString() ?? '',
    city: json["city"]?.toString() ?? '',
    state: json["state"]?.toString() ?? '',
    pinCode: json["pincode"]?.toString() ?? '',
    country: json["country"]?.toString() ?? '',
  );
}


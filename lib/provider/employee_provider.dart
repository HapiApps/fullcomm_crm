import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

import '../common/utilities/utils.dart';
import '../models/employee_details.dart';
import 'employee_repo.dart';

class EmployeeProvider with ChangeNotifier {

  final EmployeeRepository _employeeRepository = EmployeeRepository();
  bool _isLoading = false;
  bool _isError = false;

  bool get isLoading => _isLoading;

  bool get isError => _isError;

  bool _isVisible = true;
  bool _isVisible3 = true;
  bool _isVisible4 = true;
  bool _isVisible2 = true;
  bool get isVisible => _isVisible;
  bool get isVisible3 => _isVisible3;
  bool get isVisible4 => _isVisible4;
  bool get isVisible2 => _isVisible2;


  void switchObscure(){
    _isVisible = !_isVisible;
    notifyListeners();
  }
  void switchObscure2(){
    _isVisible2 = !_isVisible2;
    notifyListeners();
  }
  void switchObscure3(){
    _isVisible3 = !_isVisible3;
    notifyListeners();
  }
  void switchObscure4(){
    _isVisible4 = !_isVisible4;
    notifyListeners();
  }
  String _sortField = 'name';
  String _sortOrder = 'asc';
  String get sortField => _sortField;
  String get sortOrder => _sortOrder;
  void setFieldAndToggle(String field) {
    if (_sortField == field) {
      _sortOrder = _sortOrder == 'asc' ? 'desc' : 'asc';
    } else {
      _sortField = field;
      _sortOrder = 'asc';
    }
    sortStaff();
  }

  void sortStaff() {
    int compareStrings(String? a, String? b) {
      final sa = (a ?? '').toLowerCase();
      final sb = (b ?? '').toLowerCase();
      return sa.compareTo(sb);
    }

    int compareNumbers(num? a, num? b) {
      final na = a ?? 0;
      final nb = b ?? 0;
      if (na == nb) return 0;
      return na < nb ? -1 : 1;
    }
    final orderFactor = _sortOrder == 'asc' ? 1 : -1;
    filteredStaff.sort((a, b) {
      int cmp = 0;
      switch (_sortField) {
        case 'role':
          cmp = compareStrings(a.role, b.role);
          if (cmp == 0) cmp = compareStrings(a.sName, b.sName); // tie-breaker: name
          break;
        case 'mobile':
          cmp = compareStrings(a.sMobile, b.sMobile);
          if (cmp == 0) cmp = compareStrings(a.sName, b.sName);
          break;
        case 'email':
          cmp = compareStrings(a.email, b.email);
          if (cmp == 0) cmp = compareStrings(a.sName, b.sName);
          break;
        case 'address':
          cmp = compareStrings(a.sAddress, b.sAddress);
          if (cmp == 0) cmp = compareStrings(a.sName, b.sName);
          break;
        case 'salary':
          num? sa;
          num? sb;
          if (a.salary is num) {
            sa = a.salary as num?;
          } else if (a.salary is String) {
            sa = num.tryParse((a.salary as String).replaceAll(',', ''));
          }
          if (b.salary is num) {
            sb = b.salary as num?;
          } else if (b.salary is String) {
            sb = num.tryParse((b.salary as String).replaceAll(',', ''));
          }
          cmp = compareNumbers(sa, sb);
          if (cmp == 0) cmp = compareStrings(a.sName, b.sName);
          break;
        case 'bonus':
          num? ba;
          num? bb;
          if (a.bonus is num) {
            ba = a.bonus as num?;
          } else if (a.bonus is String) {
            ba = num.tryParse((a.bonus as String).replaceAll(',', ''));
          }
          if (b.bonus is num) {
            bb = b.bonus as num?;
          } else if (b.bonus is String) {
            bb = num.tryParse((b.bonus as String).replaceAll(',', ''));
          }
          cmp = compareNumbers(ba, bb);
          if (cmp == 0) cmp = compareStrings(a.sName, b.sName);
          break;
        case 'name':
        default:
          cmp = compareStrings(a.sName, b.sName);
      }
      return orderFactor * cmp;
    });
    notifyListeners();
  }
  List<Staff> _staffRoleData = [];

  // List<Staff> get staffRoleData => _staffRoleData;

  List<Staff>  filteredStaff = [];

  void _initializeStaff() {
    filteredStaff = List.from(_staffRoleData);
    notifyListeners();
  }

  void filterStaff(String query) {
    if (query.isEmpty) {
      filteredStaff = List.from(_staffRoleData);
    } else {
      filteredStaff = _staffRoleData.where((staffData) =>
          staffData.sName!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  void clearSearchStaff() {
    filteredStaff= List.from(_staffRoleData);
    notifyListeners();
  }

  ///Customer Details Checkbox
  List<String> _selectedCustomerIds = [];
  List<String> get selectedCustomerIds => _selectedCustomerIds;

  bool isCheckedCustomer(String id) {
    return _selectedCustomerIds.contains(id);
  }

  bool get hasSelectedCustomer {
    return _selectedCustomerIds.isNotEmpty;
  }

  void resetCategoriesCheckedCustomer(){
    _selectedCustomerIds = [];
  }

  void toggleSelectionCustomer(String id) {
    if (_selectedCustomerIds.contains(id)) {
      _selectedCustomerIds.remove(id);
      log("Selected Product Id for deletion:$_selectedCustomerIds");
    } else {
      // Add ID if not in the list (selected)
      _selectedCustomerIds.add(id);
      log("Selected Product Id for deletion:$_selectedCustomerIds");
    }
    notifyListeners();
  }

  ///Employee Details Checkbox
  List<String> _selectedEmployeeIds = [];
  List<String> get selectedEmployeeIds => _selectedEmployeeIds;

  bool isCheckedEmployee(String id) {
    return _selectedEmployeeIds.contains(id);
  }

  bool get hasSelectedEmployee {
    return _selectedEmployeeIds.isNotEmpty;
  }

  void resetCategoriesCheckedEmployee(){
    _selectedEmployeeIds = [];
  }

  void toggleSelectionEmployee(String id) {
    if (_selectedEmployeeIds.contains(id)) {
      _selectedEmployeeIds.remove(id);
      log("Selected Product Id for deletion:$_selectedEmployeeIds");
    } else {
      // Add ID if not in the list (selected)
      _selectedEmployeeIds.add(id);
      log("Selected Product Id for deletion:$_selectedEmployeeIds");
    }
    notifyListeners();
  }

  void toggleSelectAllEmployees() {
    final allSelected = filteredStaff.every((staff) => _selectedEmployeeIds.contains(staff.id));

    if (allSelected) {
      for (var staff in filteredStaff) {
        _selectedEmployeeIds.remove(staff.id);
      }
    } else {
      for (var staff in filteredStaff) {
        if (!_selectedEmployeeIds.contains(staff.id)) {
          _selectedEmployeeIds.add(staff.id.toString());
        }
      }
    }
    notifyListeners();
  }

  ///Role Details Checkbox
  List<String> _selectedRoleIds = [];
  List<String> get selectedRoleIds => _selectedRoleIds;

  bool isCheckedRole(String id) {
    return _selectedRoleIds.contains(id);
  }

  bool get hasSelectedRole {
    return _selectedRoleIds.isNotEmpty;
  }

  void resetCategoriesCheckedRole(){
    _selectedEmployeeIds = [];
  }

  void toggleSelectionRole(String id) {
    if (_selectedRoleIds.contains(id)) {
      _selectedRoleIds.remove(id);
      log("Selected Product Id for deletion:$_selectedRoleIds");
    } else {
      // Add ID if not in the list (selected)
      _selectedRoleIds.add(id);
      log("Selected Product Id for deletion:$_selectedRoleIds");
    }
    notifyListeners();
  }

  ///Delivery Details Checkbox
  List<String> _selectedDeliveryIds = [];
  List<String> get selectedDeliveryIds => _selectedDeliveryIds;

  bool isCheckedDelivery(String id) {
    return _selectedDeliveryIds.contains(id);
  }

  bool get hasSelectedDelivery {
    return _selectedDeliveryIds.isNotEmpty;
  }

  void resetCategoriesCheckedDelivery(){
    _selectedDeliveryIds = [];
  }

  void toggleSelectionDelivery(String id) {
    if (_selectedDeliveryIds.contains(id)) {
      _selectedDeliveryIds.remove(id);
      log("Selected Product Id for deletion:$_selectedDeliveryIds");
    } else {
      // Add ID if not in the list (selected)
      _selectedDeliveryIds.add(id);
      log("Selected Product Id for deletion:$_selectedDeliveryIds");
    }
    notifyListeners();
  }
  ///

  int? selectedIndex;

  void setSelectedIndex(int? index) {
    selectedIndex = (selectedIndex == index) ? null : index; // Toggle selection
    notifyListeners(); // Triggers UI rebuild
  }
  int? selectedEmployeeIndex;

  void setSelectedEmployeeIndex(int? index) {
    selectedEmployeeIndex= (selectedEmployeeIndex== index) ? null : index; // Toggle selection
    notifyListeners(); // Triggers UI rebuild
  }


  int? selectedDeliveryIndex;

  void setSelectedDeliveryIndex(int? index) {
    selectedDeliveryIndex = (selectedDeliveryIndex == index) ? null : index; // Toggle selection
    notifyListeners(); // Triggers UI rebuild
  }
  int? selectedCustomerIndex;

  void setSelectedCustomerIndex(int? index) {
    selectedCustomerIndex = (selectedCustomerIndex == index) ? null : index; // Toggle selection
    notifyListeners(); // Triggers UI rebuild
  }
  int? selectedRoleIndex;

  void setSelectedRoleIndex(int? index) {
    selectedRoleIndex = (selectedRoleIndex == index) ? null : index; // Toggle selection
    notifyListeners(); // Triggers UI rebuild
  }


  String? _selectedRadioRole = "1";

  String? get selectedRadioRole => _selectedRadioRole;

  void setSelectedRole(String value) {
    _selectedRadioRole = value;
    notifyListeners();
  }

  ///Product Publication
  String? _selectedPublication = "1";
  String? get selectedPublication => _selectedPublication;

  void setSelectedPublication(String value) {
    _selectedPublication = value;
    notifyListeners();
  }


  ///Update & Add vendor Button Controller
  final RoundedLoadingButtonController addEmployeeButtonController = RoundedLoadingButtonController();
  final RoundedLoadingButtonController addRoleButtonController = RoundedLoadingButtonController();
  final RoundedLoadingButtonController updateVendorButtonController = RoundedLoadingButtonController();
  final RoundedLoadingButtonController addCustomerButtonController = RoundedLoadingButtonController();
  final RoundedLoadingButtonController updateCustomerButtonController = RoundedLoadingButtonController();
  final RoundedLoadingButtonController addDeliveryButtonController = RoundedLoadingButtonController();
  final RoundedLoadingButtonController updateDeliveryButtonController = RoundedLoadingButtonController();


  ///Search Field Controller
  final TextEditingController vendorSearchController = TextEditingController();
  final TextEditingController roleSearchController = TextEditingController();
  final TextEditingController deliverySearchController = TextEditingController();
  final TextEditingController customerSearchController = TextEditingController();
  final TextEditingController employeeSearchController = TextEditingController();


  ///Vendor TextEditing  Controllers
  late final TextEditingController nameController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final TextEditingController otherRoleController = TextEditingController();
  final TextEditingController nameRoleController = TextEditingController();
  final TextEditingController designationController = TextEditingController();
  final TextEditingController date = TextEditingController();
  final TextEditingController descriptionRoleController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController WhatsappController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController door = TextEditingController();
  final TextEditingController street = TextEditingController();
  final TextEditingController area = TextEditingController();
  final TextEditingController pincode = TextEditingController();
  final TextEditingController state = TextEditingController();
  final TextEditingController city = TextEditingController();
  final TextEditingController country = TextEditingController();
  final TextEditingController salary = TextEditingController();
  final TextEditingController bonus = TextEditingController();

  final TextEditingController cEmailController = TextEditingController();
  final TextEditingController cMobileController = TextEditingController();
  final TextEditingController cWhatsappController = TextEditingController();
  final TextEditingController cAddressController = TextEditingController();
  final TextEditingController cdAddressController = TextEditingController();
  final TextEditingController cPassword = TextEditingController();
  final TextEditingController cName = TextEditingController();

  final TextEditingController dEmailController = TextEditingController();
  final TextEditingController dMobileController = TextEditingController();
  final TextEditingController dWhatsappController = TextEditingController();
  final TextEditingController dAddressController = TextEditingController();
  final TextEditingController dPassword = TextEditingController();
  final TextEditingController dName = TextEditingController();
  final TextEditingController dsalary = TextEditingController();
  final TextEditingController dbonus = TextEditingController();





  // List<String> roles = ['Admin', 'Biller', 'Delivery Person', 'Manager', 'Packager'];
  // List<String> selectedRoles = [];

  void clearAllEmployeeControllers() {
    nameController.clear();
    roleController.clear();
    otherRoleController.clear();
    nameRoleController.clear();
    designationController.clear();
    date.clear();
    descriptionRoleController.clear();
    emailController.clear();
    mobileController.clear();
    WhatsappController.clear();
    addressController.clear();
    password.clear();
    door.clear();
    street.clear();
    area.clear();
    pincode.clear();
    state.clear();
    city.clear();
    country.clear();
    salary.clear();
    bonus.clear();
    cName.clear();
    cPassword.clear();
    cMobileController.clear();
    cWhatsappController.clear();
    cAddressController.clear();
    cEmailController.clear();

    dsalary.clear();
    dbonus.clear();
    dName.clear();
    dPassword.clear();
    dMobileController.clear();
    dWhatsappController.clear();
    dAddressController.clear();
    dEmailController.clear();
  }

  Future<void> staffRoleDetailsData({required BuildContext context}) async {
    try {
      final response = await _employeeRepository.getStaffRoleData();
      if (response.responseCode == 200) {
        _isLoading = false;
        _staffRoleData = response.employees ?? [];
        _initializeStaff();
      } else {
        log("Vendor Provider: Something Went Wrong");
      }
    } catch (e) {
      log("Vendor Provider: ${e}");
      throw Exception(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> employeeInsert({
    required BuildContext context,
    required empName,
    required empMobile, required empAddress,
    required empBonus, required empEmail, required empJoinDate, required empPassword,
    required empRole , required empSalary, required empWhatsapp, required active
  })
  async {
    try {
      notifyListeners();
      final response = await _employeeRepository.insertEmployee(
        empName: empName,
        empMobile : empMobile,
        empAddress: empAddress,
        empBonus: empBonus,
        empEmail: empEmail,
        empJoinDate: empJoinDate,
        empPassword:empPassword ,
        empRole: empRole,
        empSalary:empSalary ,
        empWhatsapp:empWhatsapp ,
        active : active,
      );
      if (response.responseCode == 200) {
        Navigator.pop(context);
        utils.snackBar(msg: "Employee Inserted Successfully", color: Colors.green,context:context);
        addEmployeeButtonController.reset();
        staffRoleDetailsData(context: context);
       } else if(response.responseCode.toString().trim() == "409"){
        addEmployeeButtonController.reset();
        utils.snackBar(msg: "Mobile Number Already Exist",
            color: Colors.red,context:context);
      } else {
        addEmployeeButtonController.reset();
        utils.snackBar(msg: "Employee Inserted Failed",
            color: Colors.red,context:context);
      }
    } catch (e) {
      addEmployeeButtonController.reset();
      throw Exception(e);
    } finally {
      _isLoading = false;
      notifyListeners();
      addEmployeeButtonController.reset();
    }
  }

  Future<void> employeeUpdate({
    required BuildContext context,required id,
    required empName,  required empMobile, required empAddress,
    required empBonus, required empEmail, required empJoinDate, required empPassword,
    required empRole , required empSalary, required empWhatsapp, required active,
  })
  async {
    try {
      // _isLoading = true;
      notifyListeners();
      final response = await _employeeRepository.updateEmployee(
        id: id,
        empName: empName,
        empMobile : empMobile,
        empAddress: empAddress,
        empBonus: empBonus,
        empEmail: empEmail,
        empJoinDate: empJoinDate,
        empPassword:empPassword ,
        empRole: empRole,
        empSalary:empSalary ,
        empWhatsapp:empWhatsapp ,
        active : active,
      );
      log("response:$response");

      if (response.responseCode == 200) {
        log("response:$response");
        staffRoleDetailsData(context: context);
        Navigator.pop(context);
        utils.snackBar(msg: "Employee Updated Successfully",
            color: Colors.green,context:context);

        addEmployeeButtonController.reset();
      }
      else if(response.responseCode == 409){
      addEmployeeButtonController.reset();
      utils.snackBar(msg: "Mobile Number Already Exist  ",
          color: Colors.red,context:context);
      }
      else {
        addEmployeeButtonController.reset();
        utils.snackBar(msg: "Employee Updated Failed",
            color: Colors.red,context:context);
      }
    } catch (e) {
      addEmployeeButtonController.reset();
      throw Exception(e);
    } finally {
      _isLoading = false;
      notifyListeners();
      addEmployeeButtonController.reset();
    }
  }
  var role;
  var roleId;
  List<dynamic> _roleList = [];
  List<dynamic> get roleList => _roleList;
  List<Map<String, dynamic>> get fRoleList => List<Map<String, dynamic>>.from(_roleList);

  String getRoleName(String? staffRoleId) {
    if (staffRoleId == null || staffRoleId == "null") return "";
    final match = fRoleList.firstWhere(
          (role) => role['u_id'].toString() == staffRoleId,
      orElse: () => <String, dynamic>{},
    );
    return match.isNotEmpty ? match['role_name'].toString() : "";
  }


  Future<void> fetchRoleList() async {
    role = null;
    _roleList = [];
    notifyListeners();
    try {
      final response = await _employeeRepository.getRole();

      if (response.isNotEmpty) {
        _roleList = response;
        print("Role List: $_roleList");

      } else {
        _roleList = [];
      }
      notifyListeners();
    } catch (e) {
      print("fetchRoleList error $e");
      _roleList = [];
      notifyListeners();
    }
  }

  Future<void> employeeDelete({required BuildContext context, List<String>? eIds, eId}) async {
    try {
      notifyListeners(); // Notifying without setting loading to true

      final response = await _employeeRepository.deleteEmployee(
        employeeIds: eIds,
        employeeId: eId,
      );

      log("${response.toJson()}");

      if (response.responseCode == 200) {
        List<String> deletedIds = [];

        if (response.result is List) {
          deletedIds = List<String>.from(response.result?.map((id) => id.toString()));
        } else if (response.result is String) {
          deletedIds = [response.result.toString()];
        }

        if (deletedIds.isNotEmpty) {
          filteredStaff.removeWhere((staff) => deletedIds.contains(staff.id.toString()));
          _selectedEmployeeIds.clear();
          staffRoleDetailsData(context: context);
          notifyListeners();
        }

        if (context.mounted) {
          utils.snackBar(msg: "Employees deleted successfully",
              color: Colors.green,context:context);
        }
        staffRoleDetailsData(context: context);
        notifyListeners();
      } else {
        utils.snackBar(msg: "Employee deletion failed",
            color: Colors.red,context:context);
      }
    } catch (e) {
      throw Exception(e);
    } finally {
      Navigator.pop(context);
      notifyListeners(); // Keeping this to update UI if needed
    }
  }


  ///Date Picker to Select Date and display it in TextField
  DateTime? _selectedDate;

  DateTime? get selectedDate => _selectedDate;

  Future<void> selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      _selectedDate = pickedDate;
      date.text =
      "${_selectedDate!.toLocal()}".split(' ')[0]; // Format date
      notifyListeners();
    }
  }

}





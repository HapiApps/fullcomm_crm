import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pss_web/model/customer_response.dart';
import 'package:pss_web/model/delivery_response.dart';
import 'package:pss_web/model/employee_details.dart';
import 'package:pss_web/model/role_details.dart';

import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

import '../api/color.dart';
import '../common/util/toast.dart';
import '../repo/employee_repo.dart';
import '../sidebar.dart';



class EmployeeProvider with ChangeNotifier {

  final EmployeeRepository _EmployeeRepository = EmployeeRepository();
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


  List<Role> _roledata = [];

  List<Role> get roleData => _roledata;

  List<Staff> _staffRoleData = [];

  List<Staff> get staffRoleData => _staffRoleData;

  List<Staff>  filteredStaff = [];
  List<Role>  filteredRole = [];

  List<Delivery> _deliverydata = [];

  List<Delivery> get deliverydata => _deliverydata;

  List<Customer> _customerData = [];

  List<Customer> get customerData => _customerData;

  List<Delivery>  filtereddelivery = [];
  List<Customer>  filteredCustomer = [];

  void _initializeRoles() {
    filteredRole = List.from(_roledata);
   // log('Initialized vendors: $_roledata');
    notifyListeners();
  }

  void _initializeStaff() {
    filteredStaff = List.from(_staffRoleData);
    //log('Initialized vendors: $_staffRoleData');
    notifyListeners();
  }

  void _initializeDelivery() {
    filtereddelivery = List.from(_deliverydata);
   // log('Initialized vendors: $_deliverydata');
    notifyListeners();
  }
  void _initializeCustomer() {
    filteredCustomer = List.from(_customerData);
   // log('Initialized vendors: $_customerData');
    notifyListeners();
  }
  // void _initializeCustomer() {
  //   filteredCustomer = _customerData.where((customer) {
  //     final role = customer.code ?? '';
  //     return role.isNotEmpty; // or whatever condition
  //   }).toList();
  // }

  void filterRoles(String query) {
    if (query.isEmpty) {
      filteredRole = List.from(_roledata);
    } else {
      filteredRole = _roledata
          .where((roleData) =>
          roleData.roleTitle!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  void filterStaff(String query) {
    if (query.isEmpty) {
      filteredStaff = List.from(_staffRoleData);
    } else {
      filteredStaff = _staffRoleData
          .where((staffData) =>
          staffData.sName!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  void filterDelivery(String query) {
    if (query.isEmpty) {
      filtereddelivery = List.from(_deliverydata);
    } else {
      filtereddelivery = _deliverydata
          .where((deliverydata) =>
          deliverydata.sName!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }
  void initializeCustomers(List<Customer> customers) {
    _customerData = customers;
    filteredCustomer = List.from(_customerData); // Initialize with full data
    notifyListeners();
  }
  void filterCustomer(String query) {
    if (query.isEmpty) {
      // Restore full list
      filteredCustomer = List.from(_customerData);
    } else {
      // Apply filter
      filteredCustomer = _customerData
          .where((customerData) =>
          customerData.name!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  // Filter users based on search query
  void clearSearch() {
    // searchController.clear();
    filteredRole= List.from(_roledata);
    notifyListeners();
  }
  void clearSearchStaff() {
    // searchController.clear();
    filteredStaff= List.from(_staffRoleData);
    notifyListeners();
  }


  // /// Vendor Checkbox
  // List<String> _selectedVendorIds = [];
  // List<String> get selectedVendorIds => _selectedVendorIds;
  //
  // bool isChecked(String id) {
  //   return _selectedVendorIds.contains(id);
  // }
  //
  // bool get hasSelectedVendors {
  //   return _selectedVendorIds.isNotEmpty;
  // }
  //
  // void resetCategoriesChecked(){
  //   _selectedVendorIds = [];
  // }
  //
  // void toggleSelection(String id) {
  //   if (_selectedVendorIds.contains(id)) {
  //     _selectedVendorIds.remove(id);
  //     log("Selected Product Id for deletion:$_selectedVendorIds");
  //   } else {
  //     // Add ID if not in the list (selected)
  //     _selectedVendorIds.add(id);
  //     log("Selected Product Id for deletion:$_selectedVendorIds");
  //   }
  //   notifyListeners();
  // }

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

  List<Role> _roleTitles = [];
  List<Role> get roleTitles => _roleTitles;

  List<Role> roles = [];

  List<Role> selectedRoles = [];






  void showRoleMultiSelect(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Select Roles"),
          content: SingleChildScrollView(
            child: Column(
              children: roleTitles.map((role) {
                final isSelected = selectedRoles.contains(role);
                return CheckboxListTile(
                  value: isSelected,
                  title: Text(role.roleTitle ?? ''),
                  onChanged: (bool? value) {
                    if (value == true) {
                      selectedRoles.add(role);
                    } else {
                      selectedRoles.remove(role);
                    }
                    // Force rebuild the dialog
                    (context as Element).markNeedsBuild();
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);

                // Update text field with role titles (for UI display)
                otherRoleController.text =
                    selectedRoles.map((r) => r.roleTitle).join(',');

                // ✅ Extract only IDs and store/send
                List<String?> selectedRoleIds = selectedRoles.map((r) => r.id).toList();

                print("Selected Role IDs to send: $selectedRoleIds");

                // ❗ Now send this `selectedRoleIds` to backend wherever you do API call
              },
              child: Text("OK"),
            )
          ],
        );
      },
    );
  }

  Role? _selectedRole;
  Role? get selectedRole => _selectedRole;

  void selectedRoleSetter(Role? role) {
    _selectedRole = role;
    notifyListeners();
  }

  void setRolesFromJson(List<dynamic> jsonList) {
    _roleTitles = jsonList.map((e) => Role.fromJson(e)).toList();
    notifyListeners();
  }

  Future<void> roleDetailsData({required BuildContext context}) async {

    try {

      // _isLoading = true;
      // notifyListeners();

      final response = await _EmployeeRepository.getRoleData();

      if (response.responseCode == 200) {

        _isLoading = false;

        _roledata = response.roles ?? [];
        _roleTitles = _roledata;

        _initializeRoles();

        log("Filtered Role Data Count: ${filteredRole.length}");

        log("Filtered Role Data : ${filteredRole}");


        log("Role Inn: $_roledata");

        log("Role Data Fetched: ${response.roles}");

      } else {

        log("Role Provider: Something Went Wrong");

      }

    } catch (e) {

      log("Role Provider: ${e}");
      throw Exception(e);

    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> staffRoleDetailsData({required BuildContext context}) async {

    try {

      // _isLoading = true;
      // notifyListeners();

      final response = await _EmployeeRepository.getStaffRoleData();

      if (response.responseCode == 200) {

        _isLoading = false;
        _staffRoleData = response.roles ?? [];
        _initializeStaff();

        // log("Filtered Vendors Data Count: ${filteredStaff.length}");
        //
        // log("Filtered Vendors Data : ${filteredStaff}");
        //
        //
        // log("Categories Inn: $_roledata");
        //
        // log("Categories Data Fetched: ${response.roles}");

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

  Future<void> CustomerDetailsData({required BuildContext context}) async {

    try {

      // _isLoading = true;
      // notifyListeners();

      final response = await _EmployeeRepository.getCustomerRoleData();

      if (response.responseCode == 200) {

        _isLoading = false;

        _customerData = response.customer ;

        _initializeCustomer();
        //CustomerDetailsData(context: context);
        // log("Filtered filteredCustomer Data Count: ${filteredCustomer.length}");
        //
        // log("Filtered filteredCustomer Data : ${filteredCustomer}");
        //
        //
        // log("filteredCustomer Inn: $_roledata");
        //
        // log("filteredCustomer Data Fetched: ${response.customer}");

      } else {

        log("filteredCustomer Provider: Something Went Wrong");

      }

    } catch (e) {

      log("filteredCustomer Provider: ${e}");
      throw Exception(e);

    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> DeliveryDetailsData({required BuildContext context}) async {

    try {

      // _isLoading = true;
      // notifyListeners();

      final response = await _EmployeeRepository.getDeliveryData();

      if (response.responseCode == 200) {

        _isLoading = false;

        _deliverydata = response.delivery ?? [];

        _initializeDelivery();

       // log("Filtered Vendors Data Count: ${filtereddelivery.length}");

       // log("Filtered Vendors Data : ${filtereddelivery}");

//log("Categories Inn: $_roledata");

        //log("Categories Data Fetched: ${response.delivery}");

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

  Future<void> roleInsert({required BuildContext context, required role, required roleDesc ,required active}) async {

    try {
      // _isLoading = true;
      notifyListeners();
      final response = await _EmployeeRepository.insertRole(
         roleName: role,
         roleDesc : roleDesc,
         active : active,
      );
      log("$response");
      if (response.responseCode == 200) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => SidebarScreen(selectedPage: "Role")));
        ToastMsg.showSnackbar(
            context: context,
            text: "Role Inserted Sucessfully",
            backgroundColor: colorsConst.successColor
        );


      }
      else if(response.responseCode == 409) {
        ToastMsg.showSnackbar(
            context: context,
            text: "Role Already Exist",
            backgroundColor: colorsConst.errorColor);
      }
      else {
        ToastMsg.showSnackbar(
            context: context,
            text: "Role Insertion Failed",
            backgroundColor: colorsConst.errorColor);
      }

    } catch (e) {

      throw Exception(e);

    } finally {
      _isLoading = false;
      notifyListeners();
      addRoleButtonController.reset();

    }
  }

  Future<void> roleUpdate({required BuildContext context, required role, required roleDesc ,required id ,required active}) async {

    try {
      // _isLoading = true;
      notifyListeners();
      final response = await _EmployeeRepository.updateRole(
        id:id,
        roleName: role,
        roleDesc : roleDesc,
        active : active,
      );
      log("$response");
      if (response.responseCode == 200) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => SidebarScreen(selectedPage: "Role")));
        ToastMsg.showSnackbar(
            context: context,
            text: "Role Updated Sucessfully",
            backgroundColor: colorsConst.successColor
        );


      }
      else if(response.responseCode == 409) {
        ToastMsg.showSnackbar(
            context: context,
            text: "Role Already Exist",
            backgroundColor: colorsConst.errorColor);
      }
      else {
        ToastMsg.showSnackbar(
            context: context,
            text: "Role Updated Failed",
            backgroundColor: colorsConst.errorColor);
      }

    } catch (e) {

      throw Exception(e);

    } finally {
      _isLoading = false;
      notifyListeners();
      addRoleButtonController.reset();

    }
  }

  Future<void> employeeInsert({
    required BuildContext context,
    required emp_name,  required emp_mobile, required emp_address, required emp_bonus, required emp_email, required emp_join_date, required emp_password,
    required emp_role , required emp_salary, required emp_whatsapp, required active,  required roles,
  })
  async {

    try {
      // _isLoading = true;
      notifyListeners();
      final response = await _EmployeeRepository.insertEmployee(
        emp_name: emp_name,
        emp_mobile : emp_mobile,
        emp_address: emp_address,
        emp_bonus: emp_bonus,
        emp_email: emp_email,
        emp_join_date: emp_join_date,
        emp_password:emp_password ,
        emp_role: emp_role,
        emp_salary:emp_salary ,
        emp_whatsapp:emp_whatsapp ,
        active : active,
        roles:roles ,
      );
      log("response:$response");
      log("Add Employee Repository if ${emp_name}");
      log("Add Employee Repository if ${emp_mobile}");
      log("Add Employee Repository if ${emp_whatsapp}");
      log("Add Employee Repository if ${emp_email}");
      log("Add Employee Repository if ${emp_address}");
      log("Add Employee Repository if ${emp_password}");
      log("Add Employee Repository if ${emp_role}");
      log("Add Employee Repository if ${emp_salary}");
      log("Add Employee Repository if ${emp_bonus}");
      log("Add Employee Repository if ${emp_join_date}");
      if (response.responseCode == 200) {
        log("response:$response");
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => SidebarScreen(selectedPage: "Employee")));
        ToastMsg.showSnackbar(
            context: context,
            text: "Employee Inserted Sucessfully",
            backgroundColor: colorsConst.successColor
        );
        addRoleButtonController.reset();
       }
      else if(response.responseCode == 409){
        addRoleButtonController.reset();
        ToastMsg.showSnackbar(
            context: context,
            text: "Mobile Number Already Exist  ",
            backgroundColor: colorsConst.errorColor);
      }

      else {
        addRoleButtonController.reset();
        ToastMsg.showSnackbar(
            context: context,
            text: "Employee Insertion Failed",
            backgroundColor: colorsConst.errorColor);
      }

    } catch (e) {
      addRoleButtonController.reset();
      throw Exception(e);

    } finally {
      _isLoading = false;
      notifyListeners();
      addRoleButtonController.reset();

    }
  }

  Future<void> employeeUpdate({
    required BuildContext context,required id,
    required emp_name,  required emp_mobile, required emp_address, required emp_bonus, required emp_email, required emp_join_date, required emp_password,
    required emp_role , required emp_salary, required emp_whatsapp, required active,  required roles,
  })
  async {

    try {
      // _isLoading = true;
      notifyListeners();
      final response = await _EmployeeRepository.updateEmployee(
        id: id,
        emp_name: emp_name,
        emp_mobile : emp_mobile,
        emp_address: emp_address,
        emp_bonus: emp_bonus,
        emp_email: emp_email,
        emp_join_date: emp_join_date,
        emp_password:emp_password ,
        emp_role: emp_role,
        emp_salary:emp_salary ,
        emp_whatsapp:emp_whatsapp ,
        active : active,
        roles:roles ,
      );
      log("response:$response");
      log("Add Employee Repository if ${emp_name}");
      log("Add Employee Repository if ${emp_mobile}");
      log("Add Employee Repository if ${emp_whatsapp}");
      log("Add Employee Repository if ${emp_email}");
      log("Add Employee Repository if ${emp_address}");
      log("Add Employee Repository if ${emp_password}");
      log("Add Employee Repository if ${emp_role}");
      log("Add Employee Repository if ${emp_salary}");
      log("Add Employee Repository if ${emp_bonus}");
      log("Add Employee Repository if ${emp_join_date}");
      if (response.responseCode == 200) {
        log("response:$response");
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => SidebarScreen(selectedPage: "Employee")));
        ToastMsg.showSnackbar(
            context: context,
            text: "Employee Inserted Sucessfully",
            backgroundColor: colorsConst.successColor
        );
        addEmployeeButtonController.reset();
      }
      else if(response.responseCode == 409){
      addEmployeeButtonController.reset();
        ToastMsg.showSnackbar(
            context: context,
            text: "Mobile Number Already Exist  ",
            backgroundColor: colorsConst.errorColor);
      }

      else {
        addEmployeeButtonController.reset();
        ToastMsg.showSnackbar(
            context: context,
            text: "Employee Insertion Failed",
            backgroundColor: colorsConst.errorColor);
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

  Future<void> employeeDelete({required BuildContext context, List<String>? eIds, eId}) async {
    try {
      notifyListeners(); // Notifying without setting loading to true

      final response = await _EmployeeRepository.deleteEmployee(
        employeeIds: eIds,
        employeeId: eId,
      );

      log("${response.toJson()}");

      if (response.responseCode == 200) {
        List<String> deletedIds = [];

        if (response.result is List) {
          log("Deleting Vendor(s) with ID(s): ${response.result}");
          deletedIds = List<String>.from(response.result?.map((id) => id.toString()));
        } else if (response.result is String) {
          deletedIds = [response.result.toString()];
        }

        if (deletedIds.isNotEmpty) {
          log("Before deletion: ${filteredStaff.length}");

          filteredStaff.removeWhere((staff) => deletedIds.contains(staff.id.toString()));

          log("After deletion: ${filteredStaff.length}");

          _selectedEmployeeIds.clear();

          staffRoleDetailsData(context: context);

          notifyListeners();
        }

        if (context.mounted) {
          ToastMsg.showSnackbar(
            context: context,
            text: "Vendor(s) deleted successfully",
            backgroundColor: colorsConst.successColor,
          );
        }
        staffRoleDetailsData(context: context);
        notifyListeners();
      } else {
        ToastMsg.showSnackbar(
          context: context,
          text: "Vendor deletion failed",
          backgroundColor: colorsConst.errorColor,
        );
      }
    } catch (e) {
      throw Exception(e);
    } finally {
      notifyListeners(); // Keeping this to update UI if needed
    }
  }

  Future<void> roleDelete({required BuildContext context, List<String>? rIds, rId}) async {
    try {
      notifyListeners(); // Notifying without setting loading to true

      final response = await _EmployeeRepository.roledelete(
        roleIds: rIds,
        roleId: rId,
      );

      log("${response.toJson()}");

      if (response.responseCode == 200) {
        List<String> deletedIds = [];

        if (response.result is List) {
          log("Deleting Vendor(s) with ID(s): ${response.result}");
          deletedIds = List<String>.from(response.result?.map((id) => id.toString()));
        } else if (response.result is String) {
          deletedIds = [response.result.toString()];
        }

        if (deletedIds.isNotEmpty) {
          log("Before deletion: ${filteredRole.length}");

          filteredRole.removeWhere((role) => deletedIds.contains(role.id.toString()));

          log("After deletion: ${filteredRole.length}");



          roleDetailsData(context: context);

          notifyListeners();
        }

        if (context.mounted) {
          ToastMsg.showSnackbar(
            context: context,
            text: "Role deleted successfully",
            backgroundColor: colorsConst.successColor,
          );
        }
        staffRoleDetailsData(context: context);
        notifyListeners();
      } else {
        ToastMsg.showSnackbar(
          context: context,
          text: "Role deletion failed",
          backgroundColor: colorsConst.errorColor,
        );
      }
    } catch (e) {
      throw Exception(e);
    } finally {
      notifyListeners(); // Keeping this to update UI if needed
    }
  }


  Future<void> customerInsert({
    required BuildContext context,
    required name,  required mobile, required address,required email,  required password,
    required whatsapp, required active,
  })
  async {

    try {
      // _isLoading = true;
      notifyListeners();
      final response = await _EmployeeRepository.insertCustomer(
        name: name,
        mobile : mobile,
        address: address,

        email: email,

        password:password ,

        whatsapp:whatsapp ,
        active : active,

      );
      log("response:$response");
      log("Add Employee Repository if ${name}");
      log("Add Employee Repository if ${mobile}");
      log("Add Employee Repository if ${whatsapp}");
      log("Add Employee Repository if ${email}");
      log("Add Employee Repository if ${address}");
      log("Add Employee Repository if ${password}");

      if (response.responseCode == 200) {
        log("response:$response");
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => SidebarScreen(selectedPage: "Customer")));
        ToastMsg.showSnackbar(
            context: context,
            text: "Customer Inserted Sucessfully",
            backgroundColor: colorsConst.successColor
        );
        CustomerDetailsData(context: context);
        addCustomerButtonController.reset();
      }
      else if(response.responseCode == 409){
        addCustomerButtonController.reset();
        ToastMsg.showSnackbar(
            context: context,
            text: "Mobile Number Already Exist  ",
            backgroundColor: colorsConst.errorColor);
      }

      else {
        addCustomerButtonController.reset();
        ToastMsg.showSnackbar(
            context: context,
            text: "Customer Insertion Failed",
            backgroundColor: colorsConst.errorColor);
      }

    } catch (e) {
      addCustomerButtonController.reset();
      throw Exception(e);

    } finally {
      _isLoading = false;
      notifyListeners();
      addCustomerButtonController.reset();

    }
  }

  Future<void> customerUpdate({
    required BuildContext context,required id,
    required name,  required mobile, required address,  required email,  required password,
     required whatsapp, required active,
  })
  async {

    try {
      // _isLoading = true;
      notifyListeners();
      final response = await _EmployeeRepository.updateCustomer(
        id: id,
        name: name,
        mobile : mobile,
        address: address,
        email: email,
        password:password ,
        whatsapp:whatsapp ,
        active : active,

      );
      log("response:$response");
      log("Add Employee Repository if ${name}");
      log("Add Employee Repository if ${whatsapp}");
      log("Add Employee Repository if ${email}");
      log("Add Employee Repository if ${address}");
      log("Add Employee Repository if ${password}");

      if (response.responseCode == 200) {
        log("response:$response");
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => SidebarScreen(selectedPage: "Customer")));
        ToastMsg.showSnackbar(
            context: context,
            text: "Customer Updated Sucessfully",
            backgroundColor: colorsConst.successColor
        );
        CustomerDetailsData(context: context);
        addCustomerButtonController.reset();
      }
      else if(response.responseCode == 409){
        addEmployeeButtonController.reset();
        ToastMsg.showSnackbar(
            context: context,
            text: "Mobile Number Already Exist  ",
            backgroundColor: colorsConst.errorColor);
      }

      else {
        log("Customer Updation Failed");
        addCustomerButtonController.reset();
        ToastMsg.showSnackbar(
            context: context,
            text: "Customer Updation Failed",
            backgroundColor: colorsConst.errorColor);
      }

    } catch (e) {
      addCustomerButtonController.reset();
      throw Exception(e);

    } finally {
      _isLoading = false;
      notifyListeners();
      addCustomerButtonController.reset();
    }
  }

  Future<void> customerDelete({required BuildContext context, List<String>? cIds, cId}) async {
    try {
      notifyListeners(); // Notifying without setting loading to true

      final response = await _EmployeeRepository.deleteCustomer(
        customerIds: cIds,
        customerId: cId,
      );

      log("${response.toJson()}");

      if (response.responseCode == 200) {
        List<String> deletedIds = [];

        if (response.result is List) {
          log("Deleting customer(s) with ID(s): ${response.result}");
          deletedIds = List<String>.from(response.result?.map((id) => id.toString()));
        } else if (response.result is String) {
          deletedIds = [response.result.toString()];
        }

        if (deletedIds.isNotEmpty) {
          if (deletedIds.isNotEmpty) {
            log("Before deletion: ${filteredCustomer.length}");
            filteredCustomer.removeWhere((customer) => deletedIds.contains(customer.id.toString()));
            log("After deletion: ${filteredCustomer.length}");

            Navigator.pop(context); // Close the dialog first

            ToastMsg.showSnackbar(
              context: context,
              text: "Customer Deleted Successfully",
              backgroundColor: colorsConst.successColor,
            );

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SidebarScreen(selectedPage: "Customer")),
            );

          //  CustomerDetailsData(context: context);
            notifyListeners();
          }
        }


        addCustomerButtonController.reset();
        CustomerDetailsData(context: context);
        notifyListeners();
      } else {
        addCustomerButtonController.reset();
        ToastMsg.showSnackbar(
          context: context,
          text: "customer deletion failed",
          backgroundColor: colorsConst.errorColor,
        );
      }
    } catch (e) {
      addCustomerButtonController.reset();
      throw Exception(e);
    } finally {
      addCustomerButtonController.reset();
      notifyListeners(); // Keeping this to update UI if needed
    }
  }

  Future<void> deliveryInsert({
    required BuildContext context,
    required emp_name,  required emp_mobile, required emp_address, required emp_bonus,
    required emp_email, required emp_join_date, required emp_password, required emp_salary, required emp_whatsapp, required active,
  })
  async {

    try {
      // _isLoading = true;
      notifyListeners();
      final response = await _EmployeeRepository.inserDelivery(
        emp_name: emp_name,
        emp_mobile : emp_mobile,
        emp_address: emp_address,
        emp_bonus: emp_bonus,
        emp_email: emp_email,
        emp_join_date: emp_join_date,
        emp_password:emp_password ,
        emp_salary:emp_salary ,
        emp_whatsapp:emp_whatsapp ,
        active : active,

      );
      log("response:$response");
      log("Add Employee Repository if ${emp_name}");
      log("Add Employee Repository if ${emp_mobile}");
      log("Add Employee Repository if ${emp_whatsapp}");
      log("Add Employee Repository if ${emp_email}");
      log("Add Employee Repository if ${emp_address}");
      log("Add Employee Repository if ${emp_password}");

      log("Add Employee Repository if ${emp_salary}");
      log("Add Employee Repository if ${emp_bonus}");
      log("Add Employee Repository if ${emp_join_date}");
      if (response.responseCode == 200) {
        log("response:$response");
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => SidebarScreen(selectedPage: "Delivery")));
        ToastMsg.showSnackbar(
            context: context,
            text: "Delivery Person Inserted Sucessfully",
            backgroundColor: colorsConst.successColor
        );
        addDeliveryButtonController.reset();
      }
      else if(response.responseCode == 409){
        addDeliveryButtonController.reset();
        ToastMsg.showSnackbar(
            context: context,
            text: "Mobile Number Already Exist  ",
            backgroundColor: colorsConst.errorColor);
      }

      else {
        addDeliveryButtonController.reset();
        ToastMsg.showSnackbar(
            context: context,
            text: "Delivery Person Insertion Failed",
            backgroundColor: colorsConst.errorColor);
      }

    } catch (e) {
      addDeliveryButtonController.reset();
      throw Exception(e);

    } finally {
      _isLoading = false;
      notifyListeners();
      addDeliveryButtonController.reset();

    }
  }

  Future<void> deliveryUpdate({
    required BuildContext context,required id,
    required emp_name,  required emp_mobile, required emp_address, required emp_bonus, required emp_email, required emp_join_date, required emp_password,
     required emp_salary, required emp_whatsapp, required active,
  })
  async {

    try {
      // _isLoading = true;
      notifyListeners();
      final response = await _EmployeeRepository.updateDelivery(
        id: id,
        emp_name: emp_name,
        emp_mobile : emp_mobile,
        emp_address: emp_address,
        emp_bonus: emp_bonus,
        emp_email: emp_email,
        emp_join_date: emp_join_date,
        emp_password:emp_password ,

        emp_salary:emp_salary ,
        emp_whatsapp:emp_whatsapp ,
        active : active,

      );
      log("response:$response");
      log("Add Employee Repository if ${emp_name}");
      log("Add Employee Repository if ${emp_mobile}");
      log("Add Employee Repository if ${emp_whatsapp}");
      log("Add Employee Repository if ${emp_email}");
      log("Add Employee Repository if ${emp_address}");
      log("Add Employee Repository if ${emp_password}");

      log("Add Employee Repository if ${emp_salary}");
      log("Add Employee Repository if ${emp_bonus}");
      log("Add Employee Repository if ${emp_join_date}");
      if (response.responseCode == 200) {
        log("response:$response");
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => SidebarScreen(selectedPage: "Delivery")));
        ToastMsg.showSnackbar(
            context: context,
            text: "Delivery person Updated Successfully",
            backgroundColor: colorsConst.successColor
        );
        addDeliveryButtonController.reset();
      }
      else if(response.responseCode == 409){
        addDeliveryButtonController.reset();
        ToastMsg.showSnackbar(
            context: context,
            text: "Mobile Number Already Exist  ",
            backgroundColor: colorsConst.errorColor);
      }

      else {
        addDeliveryButtonController.reset();
        ToastMsg.showSnackbar(
            context: context,
            text: "Delivery person  Updation Failed",
            backgroundColor: colorsConst.errorColor);
      }

    } catch (e) {
      addDeliveryButtonController.reset();
      throw Exception(e);

    } finally {
      _isLoading = false;
      notifyListeners();
      addDeliveryButtonController.reset();

    }
  }

  Future<void> deliveryDelete({required BuildContext context, List<String>? eIds, eId}) async {
    try {
      notifyListeners(); // Notifying without setting loading to true

      final response = await _EmployeeRepository.deleteDelivery(
        employeeIds: eIds,
        employeeId: eId,
      );

      log("${response.toJson()}");

      if (response.responseCode == 200) {
        List<String> deletedIds = [];

        if (response.result is List) {
          log("Deleting Delivery person (s) with ID(s): ${response.result}");
          deletedIds = List<String>.from(response.result?.map((id) => id.toString()));
        } else if (response.result is String) {
          deletedIds = [response.result.toString()];
        }

        if (deletedIds.isNotEmpty) {
          log("Before deletion: ${filtereddelivery.length}");

          filtereddelivery.removeWhere((delivery) => deletedIds.contains(delivery.id.toString()));

          log("After deletion: ${filtereddelivery.length}");


          DeliveryDetailsData
          (context: context);

          notifyListeners();
        }

        if (context.mounted) {
          ToastMsg.showSnackbar(
            context: context,
            text: "Delivery person  deleted successfully",
            backgroundColor: colorsConst.successColor,
          );
        }
        DeliveryDetailsData(context: context);
        notifyListeners();
      } else {
        ToastMsg.showSnackbar(
          context: context,
          text: "Delivery person  deletion failed",
          backgroundColor: colorsConst.errorColor,
        );
      }
    } catch (e) {
      throw Exception(e);
    } finally {
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





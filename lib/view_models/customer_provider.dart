import 'package:flutter/material.dart';
import 'package:fullcomm_crm/repo/customer_repo.dart';
import 'package:fullcomm_crm/res/colors.dart';
import 'package:fullcomm_crm/billing_utils/sized_box.dart';
import 'package:fullcomm_crm/billing_utils/toast_messages.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:flutter/services.dart';
import '../billing_utils/input_formatters.dart';
import '../billing_utils/text_formats.dart';
import '../common/billing_data/local_data.dart';
import '../controller/controller.dart';
import '../models/billing_models/cashier_amount.dart';
import '../models/billing_models/customers_response.dart';
import '../res/components/buttons.dart';
import '../res/components/k_text.dart';
import '../res/components/k_text_field.dart';
import 'billing_provider.dart';

class CustomersProvider with ChangeNotifier {
  final CustomersRepository _customerRepo = CustomersRepository();

  // Add Customer Fields :
  TextEditingController customerName = TextEditingController();
  TextEditingController customerMobile = TextEditingController();
  TextEditingController customerStreet = TextEditingController();
  TextEditingController customerArea = TextEditingController();
  TextEditingController customerCity = TextEditingController();
  TextEditingController customerPincode = TextEditingController();
  TextEditingController customerState = TextEditingController(text: 'TamilNadu');

  // Loading Button Controller:
  RoundedLoadingButtonController loadingButtonController = RoundedLoadingButtonController();

  /// ----------- Add Customer ----------------------
  Future<String> addCustomer({
    required BuildContext context,
    required String name,
    required String mobile,
    required String addressLine1,
    required String area,
    required String pincode,
    required String city,
    required String state,
  })
  async {
    final billingProvider = Provider.of<BillingProvider>(
        context, listen: false);
    try {
      final response = await _customerRepo.addCustomer(
        name: name,
        mobile: mobile,
        addressLine1: addressLine1,
        area: area,
        pincode: pincode,
        city: city,
        state: state,
      );

      // -----------------------------
      // ✓ SUCCESS
      // -----------------------------
      if (response.responseCode == 200) {

        /// ⭐ Extract newly created ID
        final String newCustomerId = response.customerId ?? "0";
        // Clear fields
        customerName.clear();
        customerMobile.clear();
        customerStreet.clear();
        customerArea.clear();
        customerCity.clear();
        customerPincode.clear();

        // Refresh list
        if (context.mounted) await getAllCustomers(context);

        // Close popup
        //if (context.mounted) Navigator.pop(context);
        // Save locally
        localData.customerName = name;
        localData.customerMobile = mobile;
        localData.customerAddress = "$addressLine1,$area,$city,$pincode".replaceAll(",,", ",");
        setCustomerDetails(
          customerId: newCustomerId.toString(),
          customerName: customerName.toString(),
          customerMobile: customerMobile.toString(),
          customerAddress: "",
        );
        Toasts.showToastBar(context: context, text: "Customer added.",color: Colors.green);

        billingProvider.mobileController.clear();
        billingProvider.nameController.clear();
        notifyListeners();
        Navigator.pop(context);
        return newCustomerId;
      }
      else if (response.responseCode == 409) {
        Toasts.showToastBar(
          context: context,
          text: "Customer already exists.",
          color: AppColors.toastRed,
        );

        return "0";
      }

      // -----------------------------
      // ✓ VALIDATION ERROR
      // -----------------------------
      else {
        Toasts.showToastBar(
          context: context,
          text: "Enter valid details",
          color: AppColors.toastRed,
        );
        return "0";
      }
    } catch (e) {
      Toasts.showToastBar(
        context: context,
        text: "Something went wrong.",
        color: AppColors.toastRed,
      );
      return "0";
    } finally {
      loadingButtonController.reset();
      notifyListeners();
    }
  }

  CustomerData? selectedCustomer;
  void setSelectedCustomer(CustomerData customer) {
    selectedCustomer = customer;
    notifyListeners();
  }
  void selectCustomer(CustomerData value) {
  setSelectedCustomer(value); // <<< IMPORTANT

  setCustomerDetails(
      customerId: value.userId.toString(),
      customerName: value.name.toString(),
      customerMobile: value.mobile.toString(),
      customerAddress:
      "${value.addressLine1 ?? ''} ${value.area ?? ''} ${value.city ?? ''}-${value.pincode ?? ''}",
    );
  }

  /// --------- Add Customer DialogBox --------------
  // void addCustomerDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: true,
  //     builder: (context) {
  //       return StatefulBuilder(builder: (context, setState) {
  //         return AlertDialog(
  //           content: SingleChildScrollView(
  //             // Ensures content fits dynamically
  //             child: Container(
  //               alignment: Alignment.center,
  //               child: Column(
  //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                 mainAxisSize: MainAxisSize.min, // Adjusts size to fit content
  //                 children: [
  //                   MyText(
  //                     text: 'Add Customer',
  //                     fontSize: TextFormat.responsiveFontSize(context, 20),
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                   6.height,
  //                   MyTextField(
  //                     labelText: "Customer's Name",
  //                     controller: customerName,
  //                   ),
  //                   6.height,
  //                   MyTextField(
  //                     labelText: "Mobile",
  //                     controller: customerMobile,
  //                     inputFormatters: InputFormatters.mobileNumberInput,
  //                   ),
  //                   6.height,
  //                   MyTextField(
  //                     labelText: "Door No, Street",
  //                     controller: customerStreet,
  //                     textCapitalization: TextCapitalization.sentences,
  //                   ),
  //                   6.height,
  //                   MyTextField(
  //                     labelText: "Area",
  //                     controller: customerArea,
  //                     textCapitalization: TextCapitalization.sentences,
  //                   ),
  //                   6.height,
  //                   MyTextField(
  //                     labelText: "City",
  //                     controller: customerCity,
  //                     textCapitalization: TextCapitalization.sentences,
  //                   ),
  //                   6.height,
  //                   MyTextField(
  //                     labelText: "Pincode",
  //                     controller: customerPincode,
  //                     inputFormatters: InputFormatters.pinCodeInput,
  //                   ),
  //                   6.height,
  //                   MyTextField(
  //                     labelText: "State",
  //                     controller: customerState,
  //                     textCapitalization: TextCapitalization.sentences,
  //                   ),
  //                   6.height,
  //                   Buttons.loginButton(
  //                     context: context,
  //                     loadingButtonController: loadingButtonController,
  //                     onPressed: () {
  //                       if(customerName.text.isEmpty){
  //                         loadingButtonController.reset();
  //                         Toasts.showToastBar(context: context, text: "Please enter customer name",color: Colors.red);
  //                       }else if(customerMobile.text.isEmpty){
  //                         loadingButtonController.reset();
  //                         Toasts.showToastBar(context: context, text: "Please enter customer mobile",color: Colors.red);
  //                       }else if(customerCity.text.isEmpty){
  //                         loadingButtonController.reset();
  //                         Toasts.showToastBar(context: context, text: "Please enter customer city",color: Colors.red);
  //                       }else if(customerPincode.text.isEmpty){
  //                         loadingButtonController.reset();
  //                         Toasts.showToastBar(context: context, text: "Please enter customer pincode",color: Colors.red);
  //                       }else{
  //                         addCustomer(
  //                           context: context,
  //                           name: customerName.text,
  //                           mobile: customerMobile.text,
  //                           addressLine1: customerStreet.text,
  //                           area: customerArea.text,
  //                           pincode: customerPincode.text,
  //                           city: customerCity.text,
  //                           state: customerState.text,
  //                         );
  //                       }
  //                     },
  //                     text: 'Submit',
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         );
  //       });
  //     },
  //   );
  // }

  void addCustomerDialog(BuildContext context) {

    customerName.clear();
    customerMobile.clear();
    customerStreet.clear();
    customerArea.clear();
    customerCity.clear();
    customerPincode.clear();

    final FocusNode nameFocus = FocusNode();
    final FocusNode keyboardFocus = FocusNode();

    final billingProvider =
    Provider.of<BillingProvider>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {

        WidgetsBinding.instance.addPostFrameCallback((_) {
          keyboardFocus.requestFocus();
          nameFocus.requestFocus();
        });

        return RawKeyboardListener(
          focusNode: keyboardFocus,
          onKey: (event) {
            if (event is RawKeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.escape) {

              Navigator.pop(dialogContext); // ✅ close dialog

              // ✅ focus back to product search
              Future.delayed(const Duration(milliseconds: 100), () {
                billingProvider.dropdownFocusNode.requestFocus();
              });
            }
          },

          child: AlertDialog(
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  MyText(
                    text: 'Add Customer',
                    fontSize:
                    TextFormat.responsiveFontSize(context, 20),
                    fontWeight: FontWeight.bold,
                  ),

                  6.height,

                  MyTextField(
                    labelText: "Customer's Name",
                    labelRedText: "*",
                    controller: customerName,
                    focusNode: nameFocus,
                    textCapitalization: TextCapitalization.none,
                    onChanged: (value) {
                      String formatted = value
                          .split(' ')
                          .map((word) => word.isNotEmpty
                          ? word[0].toUpperCase() +
                          word.substring(1).toLowerCase()
                          : '')
                          .join(' ');
                      if (formatted != value) {
                        customerName.value = TextEditingValue(
                          text: formatted,
                          selection: TextSelection.collapsed(
                              offset: formatted.length),
                        );
                      }
                    },
                  ),

                  6.height,

                  MyTextField(
                    labelText: "Mobile",
                    labelRedText: "*",
                    controller: customerMobile,
                    keyboardType: TextInputType.number,
                    inputFormatters:
                    InputFormatters.mobileNumberInput,
                  ),

                  6.height,

                  MyTextField(
                    labelText: "Door No, Street",
                    controller: customerStreet,
                  ),

                  6.height,

                  MyTextField(
                    labelText: "Area",
                    controller: customerArea,
                  ),

                  6.height,

                  MyTextField(
                    labelText: "City",

                    controller: customerCity,
                    onChanged: (value) {
                      String formatted = value
                          .split(' ')
                          .map((word) => word.isNotEmpty
                          ? word[0].toUpperCase() +
                          word.substring(1).toLowerCase()
                          : '')
                          .join(' ');
                      if (formatted != value) {
                        customerCity.value = TextEditingValue(
                          text: formatted,
                          selection: TextSelection.collapsed(
                              offset: formatted.length),
                        );
                      }
                    },
                  ),

                  6.height,

                  MyTextField(
                    labelText: "Pincode",

                    controller: customerPincode,
                    keyboardType: TextInputType.number,

                    inputFormatters:
                    InputFormatters.pinCodeInput,
                  ),

                  6.height,

                  MyTextField(
                    labelText: "State",
                    labelRedText: "*",
                    controller:
                    customerState..text = "Tamil Nadu",
                    enabled: false,
                  ),

                  12.height,

                  Buttons.loginButton(
                    context: context,
                    loadingButtonController:
                    loadingButtonController,
                    onPressed: () {
                      final name = customerName.text.trim();
                      final mobile = customerMobile.text.trim();

                      if (name.isEmpty) {
                        loadingButtonController.reset();
                        Toasts.showToastBar(
                          context: context,
                          text: "Please enter customer name",
                          color: Colors.red,
                        );
                        nameFocus.requestFocus();
                      }

                      /// mobile empty
                      else if (mobile.isEmpty) {
                        loadingButtonController.reset();
                        Toasts.showToastBar(
                          context: context,
                          text: "Please enter mobile number",
                          color: Colors.red,
                        );
                      }

                      /// mobile length check
                      else if (mobile.length != 10) {
                        loadingButtonController.reset();
                        Toasts.showToastBar(
                          context: context,
                          text: "Mobile number must be 10 digits",
                          color: Colors.red,
                        );
                      }

                      /// digits only check (recommended)
                      else if (!RegExp(r'^\d+$').hasMatch(mobile)) {
                        loadingButtonController.reset();
                        Toasts.showToastBar(
                          context: context,
                          text: "Invalid mobile number",
                          color: Colors.red,
                        );
                      }

                      else {
                        addCustomer(
                          context: context,
                          name: name,
                          mobile: mobile,
                          addressLine1: customerStreet.text.trim(),
                          area: customerArea.text.trim(),
                          pincode: customerPincode.text.trim(),
                          city: customerCity.text.trim(),
                          state: "Tamil Nadu",
                        );

                        nameFocus.requestFocus();
                      }
                    },
                    text: 'Submit',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }



  /// -------- Customer Selection -------------------
  String _selectedCustomerId = '';
  String _selectedCustomerName = '';
  String _selectedCustomerMobile = '';

  String get selectedCustomerId => _selectedCustomerId;
  String get selectedCustomerName => _selectedCustomerName;
  String get selectedCustomerMobile => _selectedCustomerMobile;

  /// -------- Fetch all Customers -----------------

  List<CustomerData> _allCustomers = [];
  List<CustomerData> get allCustomersList => _allCustomers;
  /// ✅ Clear after bill print
  void clearSelectedCustomer() {
    _selectedCustomerId = '';
    _selectedCustomerName = '';
    _selectedCustomerMobile = '';
    customerAddressController.clear();
    customerDropController.clear();
    customerMobileController.clear();
    notifyListeners(); // Provider use pannina MUST
  }
  // Fetch all Customers Api :
  Future<void> getAllCustomers(context) async {
    try {
      final response = await _customerRepo.getCustomers();
      if(response.responseCode == 200){
        _allCustomers = response.customersList ?? [];
      }else {
        _allCustomers = [];
      }
    } catch (e) {
      Toasts.showToastBar(context: context, text: 'Failed to receive Customers List');
      throw Exception(e);
    }finally{
      notifyListeners();
    }
  }

  // Select Customer :
  TextEditingController customerAddressController = TextEditingController();
  TextEditingController customerMobileController = TextEditingController();
  TextEditingController customerNameController = TextEditingController();
  TextEditingController customerDropController = TextEditingController();
  void clearCustomer() {
    customerAddressController.clear();
    customerDropController.clear();
    customerMobileController.clear();
    notifyListeners(); // ✅ correct place
  }

  /// Set Customer Details :
  void setCustomerDetails({required String customerId,required String customerName,required String customerMobile,required String customerAddress}){
    _selectedCustomerId = customerId;
    _selectedCustomerName = customerName;
    _selectedCustomerMobile = customerMobile;

    customerAddressController.text = customerAddress;
    customerMobileController.text = customerMobile;
    customerNameController.text = customerName;
    customerDropController.text = "$customerName - $customerMobile";
    print("Address ${customerAddressController.text}");
    print("Name ${customerDropController.text}");
    print("Name 2${customerNameController.text}");
    selectedCustomer = CustomerData(
      userId: customerId,
      name: customerName,
      mobile: customerMobile,
      addressLine1: customerAddress,
    );
    notifyListeners();
  }

  /// Reset Customer Details (Emptying)
  void resetCustomerDetails(){
    _selectedCustomerId = '';
    _selectedCustomerName = '';
    _selectedCustomerMobile = '';
    customerAddressController.clear();
    customerDropController.clear();
    notifyListeners();
  }


  bool isLoading = false;
  String? errorMessage;

  List<CashierAmountModel> cashierAmounts = [];

  Future<void> fetchCashierAmounts(String createdBy) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final response = await _customerRepo.getCashierAmount(createdBy: createdBy);
      if (response.responseCode == 200) {
        cashierAmounts = response.data ?? [];
      } else {
        errorMessage = response.message;
      }

    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  void showCashierPopupAndLogout(
      BuildContext context,
      BillingProvider provider,
      ) async {

    final cashier =
    Provider.of<CustomersProvider>(context, listen: false);

    await cashier.fetchCashierAmounts(controllers.storage.read("id"));

// ✅ prevent double pop

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {


        return Focus(
          autofocus: true,

          /// ✅ modern key handler (better than RawKeyboardListener)
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent) {

              /// ESC → just close
              if (event.logicalKey == LogicalKeyboardKey.escape) {
                Navigator.pop(dialogContext);

                Future.delayed(const Duration(milliseconds: 100), () {
                  provider.dropdownFocusNode.requestFocus();
                });

                return KeyEventResult.handled;
              }
            }

            return KeyEventResult.ignored;
          },

          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.all(20),

            content: Consumer<CustomersProvider>(
              builder: (context, cashier, _) {

                if (cashier.isLoading) {
                  return const SizedBox(
                    height: 100,
                    width: 200,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                return SizedBox(
                  width: 400,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      const Text(
                        "Today's Collection",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      /// ================= TABLE =================
                      Table(
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(1),
                        },
                        border: const TableBorder(
                          horizontalInside: BorderSide(color: Colors.grey),
                        ),
                        children: [

                          ...cashier.cashierAmounts.map((item) {

                            String methodName = "";

                            switch (item.pMethodId) {
                              case "1": methodName = "Cash"; break;
                              case "2": methodName = "Card"; break;
                              case "3": methodName = "UPI"; break;
                              case "4": methodName = "Credit"; break;
                            }

                            return TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    methodName,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    "₹${item.totalAmount}",
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ],
                      ),

                      const Divider(thickness: 1),

                      /// ================= TOTAL =================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "TOTAL",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "₹${cashier.cashierAmounts
                                .fold(0.0, (sum, e) => sum + double.parse(e.totalAmount))
                                .toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  String getTotalByPaymentMethod(String methodId) {
    try {
      return cashierAmounts
          .firstWhere((e) => e.pMethodId == methodId)
          .totalAmount;
    } catch (_) {
      return "0";
    }
  }

}

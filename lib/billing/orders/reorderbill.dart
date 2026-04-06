import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fullcomm_crm/res/colors.dart';
import 'package:fullcomm_crm/res/components/bottom_widgets.dart';
import 'package:fullcomm_crm/res/components/buttons.dart';
import 'package:fullcomm_crm/res/components/k_loadings.dart';
import 'package:fullcomm_crm/res/components/k_text.dart';
import 'package:fullcomm_crm/res/components/screen_widgtes.dart';
import 'package:fullcomm_crm/res/widgets/divider_widgets.dart';
import 'package:fullcomm_crm/billing_utils/input_formatters.dart';
import 'package:fullcomm_crm/billing_utils/sized_box.dart';
import 'package:fullcomm_crm/billing_utils/text_formats.dart';
import 'package:fullcomm_crm/billing_utils/toast_messages.dart';
import 'package:fullcomm_crm/view_models/billing_provider.dart';
import 'package:fullcomm_crm/view_models/credentials_provider.dart';
import 'package:fullcomm_crm/view_models/customer_provider.dart';
import 'package:fullcomm_crm/billing/orders/hold_order_details.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/billing_models/customers_response.dart';
import '../../res/components/customer_widgets.dart';
import '../../res/components/hint.dart';
import '../../res/components/k_dropdown_menu_2.dart';
import '../../res/components/k_text_field.dart';
import '../../res/components/keyboard_search.dart';
import 'hold_order.dart';
import 'order_detail_page.dart';
import 'reorderbill.dart';
import '../products/add_products.dart';

class NextPageIntent extends Intent {
  const NextPageIntent();
}

class ActivateIntent extends Intent {
  const ActivateIntent();
}

class LastBillIntent extends Intent {
  const LastBillIntent();
}

class AltOnlyIntent extends Intent {
  const AltOnlyIntent();
}
class F1Intent extends Intent {
  const F1Intent();
}class F4Intent extends Intent {
  const F4Intent();
}
class F2Intent extends Intent {
  const F2Intent();
}


class F6Intent extends Intent {
  const F6Intent();
}
class AddCustomerIntent extends Intent {
  const AddCustomerIntent();
}

class RefreshIntent extends Intent {
  const RefreshIntent();
}

class HelpIntent extends Intent {
  const HelpIntent();
}
class HoldIntent extends Intent {
  const HoldIntent();
}
class ReturnIntent extends Intent {
  const ReturnIntent();
}
class ArrowUpIntent extends Intent {}
class ArrowDownIntent extends Intent {}
class LogoutIntent extends Intent {
  const LogoutIntent();
}
class ResetIntent extends Intent {
  const ResetIntent();
}
class TabIntent extends Intent {
  const TabIntent();
}
class OpenProductIntent extends Intent {
  const OpenProductIntent();
}
class OpenCustomerDropdownIntent extends Intent {
  const OpenCustomerDropdownIntent();
}
class AddNewProduct extends Intent {
  const AddNewProduct();
}
class ProductDelete extends Intent {
  const ProductDelete();
}
class Reorder extends StatefulWidget {
  const Reorder({super.key});

  @override
  State<Reorder> createState() => _ReorderState();
}

class _ReorderState extends State<Reorder> {
  bool _isProgrammaticChange = false;
  String? _lastScannedCode;
  DateTime? _lastErrorTime;
  bool _fetchInProgress = false;
  bool _alreadyRefetchedForThisScan = false;
  String? qrData;
  String upiId = "test@upi";
  String upiName = "Test User";
  String userName = "Test User";



  // void generateQR(double amount) {
  //   qrData =
  //   "upi://pay?pa=$upiId&pn=$upiName&am=${amount.toStringAsFixed(2)}&cu=INR";
  // }

  final FocusNode fieldFocusNode = FocusNode();
  final FocusNode cusFocusNode = FocusNode();
  final FocusNode cusNameFocusNode = FocusNode();
  final TextEditingController dropdownController = TextEditingController();
  final TextEditingController quantityVariationController = TextEditingController();
  final ScrollController billScrollController = ScrollController();

  final GlobalKey cusDropdownKey = GlobalKey();
  final FocusNode globalFocusNode = FocusNode();
  int selectedRowIndex = -1; // highlighted row
  List<FocusNode> qtyFocusNodes = []; // focus for qty cells
  final FocusNode _keyboardFocusNode = FocusNode();
  bool isProductDropdownOpen = false;   // <<< ADD THIS ABOVE BUILD()
  String _barcodeBuffer = '';
  Timer? _barcodeTimer;
  bool _scanCompleted = false;


  // For Scrolling Billing Table :
  ScrollController scrollController = ScrollController();

  bool _productDropdownInitialFocusDone = false;
  final FocusNode _scanFocusNode = FocusNode();
  final TextEditingController _scanController = TextEditingController();
  FocusNode _focusNode = FocusNode();
  FocusNode _focusNodeSearch = FocusNode();
  void scrollToLastItem() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (billScrollController.hasClients) {
        billScrollController.animateTo(
          billScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }


  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final billing = Provider.of<BillingProvider>(context, listen: false);
      final customers = Provider.of<CustomersProvider>(context, listen: false);
      final credentials = Provider.of<UserDataProvider>(context, listen: false);
      FocusScope.of(context).requestFocus(billing.dropdownFocusNode);
      billing.dropdownFocusNode.requestFocus();
      await credentials.loadCashierInfo();
      // Set cashier
      billing.cashierController.text =
      "${billing.cashierNameController} - ${billing.cashierIdController}";

      billing.loadHeldBillsFromPrefs();
      _focusNode.requestFocus();
      // Load data
      if (billing.isWChecked) {
        await billing.getWholeSaleProducts();
      } else {
        await billing.getProducts();
      }
      customers.getAllCustomers(context);
      customers.resetCustomerDetails();
      billing.setBillingItems([]);
      final provider =
      Provider.of<BillingProvider>(context, listen: false);

      provider.changeDateFilter("Today");

      final today = DateTime.now();
      final tomorrow = today.add(const Duration(days: 1));

      provider.getAllOrderDetails(
        DateFormat('yyyy-MM-dd').format(today),
        DateFormat('yyyy-MM-dd').format(tomorrow),
      );
      await billing.loadLastBillFromPrefs();

      if (billing.lastBillOrder != null) {
        billing.setLastBillToBilling(billing.lastBillOrder!);
      }
      // 👉 Give focus to dropdown only ONCE

    });
  }
  @override
  void dispose() {
    _focusNodeSearch.dispose();
    //dropdownFocusNode.dispose();
    fieldFocusNode.dispose();
    _focusNode.requestFocus();
    dropdownController.dispose();
    quantityVariationController.dispose();
    scrollController.dispose();
    super.dispose();
  }
  Timer? _scanDebounce;
  String capitalizeEachWord(String value) {
    if (value.trim().isEmpty) return value;

    return value
        .trim()
        .split(RegExp(r'\s+'))
        .map((word) =>
    word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    double screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    String searchText = "";
    bool _isPaymentDialogOpen = false;
    BuildContext? _dialogContext;bool _isPrinting = false;
    return Consumer3<UserDataProvider, CustomersProvider, BillingProvider>(
        builder: (context, userDataProvider, customerProvider, billingProvider,
            _) {
          return Focus(
            autofocus: true,
            focusNode: _focusNode,
            child: PopScope(
              canPop: false,
              child: Scaffold(
                appBar: PreferredSize(
                  preferredSize: Size.fromHeight(screenHeight * 0.21),
                  child: GestureDetector(
                    onTap: () {
                      _focusNode.requestFocus();
                    },
                    child: Container(
                      color: AppColors.primary,
                      padding: const EdgeInsets.only(bottom: 1),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Top AppBar Section
                          AppBar(
                            toolbarHeight: screenHeight * 0.11,
                            title: Padding(
                              padding: const EdgeInsets.only(right: 4,top:4,bottom: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.black,   // black border
                                        width: 1.3,              // thick border
                                      ),
                                      borderRadius: BorderRadius.circular(10), // rounded corner (optional)
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // LOGO
                                        Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: SizedBox(
                                            width: 140,
                                            height: 40,
                                            child: FittedBox(
                                              fit: BoxFit.cover,
                                              child: Image.asset('assets/images/Martway.png'),
                                            ),
                                          ),
                                        ),



                                        // VERSION TEXT
                                        Padding(
                                          padding: const EdgeInsets.only(top: 30.0,left: 10),
                                          child: MyText(
                                            text: "0.0",
                                            fontSize: 18,               // bigger text
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )

                                ],
                              ),
                            ),
                            automaticallyImplyLeading: false,
                            centerTitle: true,
                            backgroundColor: AppColors.transparent,
                            elevation: 0,
                            // Removes shadow
                            actions: [

                              ],
                          ),

                          // Bottom Section (Customer Details and Inputs)
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 5, top: 5),
                              child: Row(
                                children: [
                                  // ===============================================================
                                  // CUSTOMER CONTACT DROPDOWN (FORCED FULL WIDTH)
                                  // ===============================================================
                                  Expanded(
                                    flex: 1,
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        return ConstrainedBox(
                                          // Force the child to be AT LEAST the parent's width.
                                          constraints: BoxConstraints(minWidth: constraints.maxWidth),
                                          child: SizedBox(
                                            //  height: 30, // same as TextField height
                                            width: constraints.maxWidth,
                                            child: SizedBox.expand(
                                              child: MyDropdownMenu2<CustomerData>(
                                                width: constraints.maxWidth,
                                                key: cusDropdownKey,

                                                // IMPORTANT: do NOT set a fixed 'width' here.
                                                // If MyDropdownMenu2 accepts width, set to double.infinity or remove it.
                                                // width: double.infinity, // <- use this only if the param exists

                                                labelText: "Cust. Contact",
                                                hintText: "Select Customer...",
                                                labelstyle: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 26,
                                                  color: Colors.black,
                                                ),
                                                hintstyle: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 26,
                                                  color: Colors.black,
                                                ),

                                                focusNode: cusFocusNode,
                                                controller: customerProvider.customerDropController,
                                                enableSearch: true,
                                                enableFilter: true,
                                                menuHeight: screenHeight * 0.40,

                                                dropdownMenuEntries:
                                                customerProvider.allCustomersList.map((c) {
                                                  return MyDropdownMenuEntry2(
                                                    value: c,
                                                    label: '${c.name} - ${c.mobile}',
                                                  );
                                                }).toList(),

                                                onSelected: (value) async {
                                                  if (value == null) return;

                                                  /// ✅ Set Customer Details
                                                  customerProvider.setCustomerDetails(
                                                    customerId: value.userId.toString(),
                                                    customerName: value.name.toString(),
                                                    customerMobile: value.mobile.toString(),
                                                    customerAddress:
                                                    "${value.addressLine1 ?? ''} ${value.area ?? ''} "
                                                        "${value.city ?? ''}-${value.pincode ?? ''}-${value.pincode ?? ''}",
                                                  );

                                                  /// ✅ Get Last Order
                                                  final lastOrder =
                                                  billingProvider.getLastOrderByCustomer(value.userId.toString());

                                                  /// ✅ Set Last Bill To Billing Screen
                                                  if (lastOrder != null) {
                                                    billingProvider.setLastBillToBilling(lastOrder);
                                                  } else {
                                                    billingProvider.clearBillingData(context);
                                                  }

                                                  /// ✅ Close This Page & Go Back To Main Billing Screen
                                                  await Future.delayed(const Duration(milliseconds: 100));
                                                  Navigator.pop(context);

                                                  /// ✅ After pop → focus product dropdown
                                                  Future.delayed(const Duration(milliseconds: 200), () {
                                                    billingProvider.dropdownFocusNode.requestFocus();
                                                  });
                                                },


                                                onSearchSubmit: (search) async {
                                                  final raw = (search ?? '').trim();
                                                  final q = raw.toLowerCase();
                                                  final formattedName = capitalizeEachWord(raw);

                                                  final dropdownState = cusDropdownKey.currentState as dynamic;
                                                  final highlighted = dropdownState?.highlightedValue;

                                                  // ✅ If highlighted item exists → select it
                                                  if (highlighted != null) {
                                                    dropdownState?.setText(
                                                        "${highlighted.name} - ${highlighted.mobile}");

                                                    customerProvider.setCustomerDetails(
                                                      customerId: highlighted.userId.toString(),
                                                      customerName: highlighted.name.toString(),
                                                      customerMobile: highlighted.mobile.toString(),
                                                      customerAddress:
                                                      "${highlighted.addressLine1 ?? ''} ${highlighted.area ?? ''} "
                                                          "${highlighted.city ?? ''}-${highlighted.pincode ?? ''}",
                                                    );

                                                    Future.delayed(const Duration(milliseconds: 150), () {
                                                      FocusScope.of(context)
                                                          .requestFocus(billingProvider.dropdownFocusNode);
                                                    });
                                                    return;
                                                  }

                                                  // ❌ Empty search → just move focus
                                                  if (q.isEmpty) {
                                                    Future.delayed(const Duration(milliseconds: 150), () {
                                                      FocusScope.of(context)
                                                          .requestFocus(billingProvider.dropdownFocusNode);
                                                    });
                                                    return;
                                                  }

                                                  // 🔍 Search customers
                                                  final matches =
                                                  customerProvider.allCustomersList.where((customer) {
                                                    final name = (customer.name ?? '').toLowerCase();
                                                    final mobile = (customer.mobile ?? '').toLowerCase();
                                                    return name.contains(q) || mobile.contains(q);
                                                  }).toList();

                                                  // ❌ No customer found → ADD CUSTOMER popup (with CAPS)
                                                  if (matches.isEmpty) {
                                                   // showAddCustomerPopup(context, formattedName);
                                                    return;
                                                  }

                                                  // ✅ Only one match → auto select
                                                  if (matches.length == 1) {
                                                    final v = matches.first;
                                                    customerProvider.setCustomerDetails(
                                                      customerId: v.userId.toString(),
                                                      customerName: v.name.toString(),
                                                      customerMobile: v.mobile.toString(),
                                                      customerAddress:
                                                      "${v.addressLine1 ?? ''} ${v.area ?? ''} "
                                                          "${v.city ?? ''}-${v.pincode ?? ''}",
                                                    );

                                                    Future.delayed(const Duration(milliseconds: 150), () {
                                                      FocusScope.of(context)
                                                          .requestFocus(billingProvider.dropdownFocusNode);
                                                    });
                                                    return;
                                                  }

                                                  // 🔽 Multiple matches → selection dialog
                                                  final selected = await showDialog<CustomerData?>(
                                                    context: context,
                                                    builder: (ctx) {
                                                      return AlertDialog(
                                                        title: const Text("Select customer"),
                                                        content: SizedBox(
                                                          width: double.maxFinite,
                                                          child: ListView.separated(
                                                            shrinkWrap: true,
                                                            itemCount: matches.length,
                                                            separatorBuilder: (_, __) =>
                                                            const Divider(height: 1),
                                                            itemBuilder: (_, i) {
                                                              final c = matches[i];
                                                              return ListTile(
                                                                title: Text(c.name ?? ''),
                                                                subtitle: Text(c.mobile ?? ''),
                                                                onTap: () => Navigator.of(ctx).pop(c),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () => Navigator.of(ctx).pop(null),
                                                            child: const Text("Cancel"),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );

                                                  if (selected != null) {
                                                    customerProvider.setCustomerDetails(
                                                      customerId: selected.userId.toString(),
                                                      customerName: selected.name.toString(),
                                                      customerMobile: selected.mobile.toString(),
                                                      customerAddress:
                                                      "${selected.addressLine1 ?? ''} ${selected.area ?? ''} "
                                                          "${selected.city ?? ''}-${selected.pincode ?? ''}",
                                                    );
                                                  }
                                                },


                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),


                                ],
                              ),
                            ),
                          )

                        ],
                      ),
                    ),
                  ),
                ),

                body: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      // 🔥 mouse click ஆனாலும் focus return
                      _focusNode.requestFocus();
                    },
                    child: billingProvider.isLoading ? LoadingWidgets
                        .circleLoading()
                        : Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [

                        ],
                    )
                ),

              ),
            ),
          );
        }
    );
  }

}











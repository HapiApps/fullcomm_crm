import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
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
import '../../billing_utils/caps_letter.dart';
import '../../common/billing_data/local_data.dart';
import '../../common/billing_data/project_data.dart';
import '../../common/constant/colors_constant.dart';
import '../../components/custom_sidebar.dart';
import '../../controller/controller.dart';
import '../../models/all_customers_obj.dart';
import '../../models/billing_models/billing_product.dart';
import '../../models/billing_models/customers_response.dart';
import '../../models/billing_models/place_order.dart';
import '../../models/billing_models/products_response.dart';
import '../../models/billing_models/return_qty.dart';
import '../../res/components/customer_widgets.dart';
import '../../res/components/hint.dart';
import '../../res/components/k_dropdown_menu_2.dart';
import '../../res/components/k_text_field.dart';
import '../../res/components/keyboard_search.dart';
import '../../screens/quotation/send_quotation.dart';
import '../orders/hold_order.dart';
import '../orders/order_detail_page.dart';
import '../orders/reorderbill.dart';
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
class NewBillingScreen extends StatefulWidget {
  const NewBillingScreen({super.key});

  @override
  State<NewBillingScreen> createState() => _NewBillingScreenState();
}

class _NewBillingScreenState extends State<NewBillingScreen> {
  bool _isProgrammaticChange = false;
  String? _lastScannedCode;
  DateTime? _lastErrorTime;
  bool _fetchInProgress = false;
  bool _alreadyRefetchedForThisScan = false;
  String? qrData;
  String upiId = "test@upi";
  String upiName = "Test User";
  String userName = "Test User";
  void generateQR(double amount) {
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter amount"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final upiUrl =
        "upi://pay?"
        "pa=${Uri.encodeComponent(upiId)}"
        "&pn=${Uri.encodeComponent(userName)}"
        "&am=${amount.toStringAsFixed(2)}"
        "&cu=INR";

    debugPrint("UPI QR => $upiUrl");

    setState(() {
      qrData = upiUrl;
    });
  }
  void safeClear(TextEditingController c) {
    c.value = const TextEditingValue(
      text: "",
      selection: TextSelection.collapsed(offset: 0),
    );
  }

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

  void closeDropdownMenu() {
    FocusScope.of(context).unfocus();
  }

  // For Scrolling Billing Table :
  ScrollController scrollController = ScrollController();

  void scrollDown() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent + kBottomNavigationBarHeight,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      log("ScrollController is not attached to any scroll view.");
    }
  }
  void scrollToTop() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0.0, // 👈 TOP
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

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
        if(Provider.of<BillingProvider>(context, listen: false).productsList.isEmpty){
          Provider.of<BillingProvider>(context, listen: false).getProducts();
        }
      }
      customers.getAllCustomers(context);
      customers.resetCustomerDetails();
      billing.setBillingItems([]);

      // 👉 Give focus to dropdown only ONCE

    });
  }




  void _handleArrowDown() {
    final billingProvider = Provider.of<BillingProvider>(context, listen: false);
    if (billingProvider.billingItems.isEmpty) return;

    setState(() {
      if (selectedRowIndex < billingProvider.billingItems.length - 1) {
        selectedRowIndex++;
      }
    });

    _focusQty(selectedRowIndex);
  }

  void _handleArrowUp() {
    final billingProvider = Provider.of<BillingProvider>(context, listen: false);
    if (billingProvider.billingItems.isEmpty) return;

    setState(() {
      if (selectedRowIndex > 0) {
        selectedRowIndex--;
      }
    });

    _focusQty(selectedRowIndex);
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
  double safeDouble(dynamic value) {
    if (value == null) return 0;

    final cleaned = value
        .toString()
        .replaceAll(RegExp(r'[^0-9.\-]'), "") // remove everything except digits . -
        .trim();

    return double.tryParse(cleaned) ?? 0;
  }

  int safeInt(dynamic value) {
    if (value == null) return 0;

    final cleaned = value
        .toString()
        .replaceAll(RegExp(r'[^0-9]'), "") // only digits
        .trim();

    return int.tryParse(cleaned) ?? 0;
  }
  void _setScannedProduct(ProductData product) {
    final billingProvider =
    Provider.of<BillingProvider>(context, listen: false);

    /// set selected product (optional, but ok)
    billingProvider.selectedProduct = product;

    /// find if product already exists in table
    final index = billingProvider.billingItems.indexWhere(
          (item) => item.product.id == product.id,
    );

    // ---------------- LOOSE PRODUCT ----------------
    if (product.isLoose == '1') {
      const double addKg = 1.0; // default 1kg
      final double addGrams = addKg * 1000;

      if (index != -1) {
        // update existing
        billingProvider.billingItems[index].variation += addGrams;

        billingProvider.quantityControllers[index]!.text =
            (billingProvider.billingItems[index].variation / 1000)
                .toStringAsFixed(3);
      } else {
        // add new
        billingProvider.addBillingItem(
          BillingItem(
            id: product.id.toString(),
            product: product,
            productTitle: product.pTitle ?? "",
            variation: addGrams,
            variationUnit: "${product.pVariation}${product.unit}",
            quantity: 1, p_out_price: product.outPrice.toString(),
            p_mrp:product.mrp.toString(),
          ),
        );

        final newIndex = billingProvider.billingItems.length - 1;
        billingProvider.quantityControllers[newIndex]!.text =
            addKg.toStringAsFixed(3);
      }
    }

    // ---------------- NORMAL PRODUCT ----------------
    else {
      const int addQty = 1;

      if (index != -1) {
        // update existing
        billingProvider.billingItems[index].quantity += addQty;

        billingProvider.quantityControllers[index]!.text =
            billingProvider.billingItems[index].quantity.toString();
      } else {
        // add new
        billingProvider.addBillingItem(
          BillingItem(
            id: product.id.toString(),
            product: product,
            productTitle: product.pTitle ?? "",
            variation: 1,
            variationUnit: "${product.pVariation}${product.unit}",
            quantity: addQty,
            p_out_price: product.outPrice.toString(),
            p_mrp:product.mrp.toString(),
          ),
        );
      }
    }

    /// refresh UI
    billingProvider.notifyListeners();

    /// clear dropdown for next scan
    dropdownController.clear();
    quantityVariationController.clear();
    billingProvider.selectedProduct = null;

    /// ready for next scan
    Future.delayed(const Duration(milliseconds: 40), () {
      billingProvider.dropdownFocusNode.requestFocus();
    });
  }

  void _handleNoProductFound() {
    final billingProvider =
    Provider.of<BillingProvider>(context, listen: false);

    // clear selection
    billingProvider.selectedProduct = null;

    // clear text
    dropdownController.clear();

    // focus back to product field
    billingProvider.dropdownFocusNode.requestFocus();

    // show snackbar
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('❌ No product found'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Timer? _scanDebounce;
  bool _scanLocked = false;
  DateTime? _lastKeyTime;
  bool _isScannerInput = true;
  static const int scannerThresholdMs = 40; // 🔥 KEY VALUE

  void updateMethod(int index) {
    final billingProvider = Provider.of<BillingProvider>(context);
    final method = billingProvider.billMethods[index];

    // Change selected bill method
    billingProvider.changeBillMethod(method);

    // ðŸ‘‰ Auto-fill Cash Amount field with total amount
    double totalAmount = billingProvider.grandTotal ??
        0; // Use your total variable
    billingProvider.paymentReceived.text = totalAmount.toStringAsFixed(2);

    // Recalculate balance
    billingProvider.calculatePaymentBalance();

    // Focus to radio button
    billingProvider.billMethodFocusNodes[index].requestFocus();
  }

  void showReturnQuantityDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final billingProvider =
        Provider.of<BillingProvider>(context, listen: false);
        String _lastScan = '';
        Timer? _scanTimer;
        String? scannedProductName;
        String? scannedProductId;
        String? loose;
        String? scannerBatchId;

        final TextEditingController quantityController =
        TextEditingController();
        final TextEditingController dropdownReturnController =
        TextEditingController();

        final FocusNode quantityFocusNode = FocusNode();

        bool scanLocked = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              billingProvider.dropdownReturnFocusNode.requestFocus();
            });
            return WillPopScope(
              onWillPop: () async {
                billingProvider.dropdownFocusNode.requestFocus();
                return true;
              },
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: const Text(
                  "Return Quantity",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                content: SizedBox(
                  width: 420,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // ================= PRODUCT SEARCH / SCAN =================
                        KeyboardDropdownField<ProductData>(
                          focusNode: billingProvider.dropdownReturnFocusNode,
                          textEditingController: dropdownReturnController,
                          hintText: "Product...",
                          labelText: "Product",
                          items: billingProvider.productsList,

                          labelBuilder: (p) => p.isLoose == '0'
                              ? '${p.pTitle} ${p.pVariation}${p.unit}'
                              : '${p.pTitle} (${p.pVariation})',

                          itemBuilder: (p) => Padding(
                            padding: const EdgeInsets.all(6),
                            child: Text(
                              p.isLoose == '0'
                                  ? '${p.pTitle} ${p.pVariation}${p.unit}'
                                  : '${p.pTitle} (${p.pVariation})',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          // ================= BARCODE SCAN (NO DROPDOWN TEXT TOUCH) =================


                          onScan: (code) {
                            String normalize(String v) =>
                                v.replaceAll(RegExp(r'[^0-9]'), '').replaceFirst(RegExp(r'^0+'), '');

                            final cleaned = normalize(code);
                            if (cleaned.isEmpty) return;

                            // 🔥 ALWAYS REPLACE (NOT APPEND)
                            _lastScan = cleaned;

                            _scanTimer?.cancel();
                            _scanTimer = Timer(const Duration(milliseconds: 200), () {
                              final scanned = _lastScan;
                              _lastScan = '';

                              debugPrint("📦 FINAL BARCODE => $scanned");

                              try {
                                final product = billingProvider.productsList.firstWhere(
                                      (p) => normalize(p.barcode ?? '') == scanned,
                                );

                                final qtyLeft =
                                    double.tryParse(product.qtyLeft?.toString() ?? "0") ?? 0;

                                if (qtyLeft <= 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("❌ Out of Stock"),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                setDialogState(() {
                                  scannedProductName =
                                  "${product.pTitle} - ${product.pVariation}${product.unit}";
                                  scannedProductId = product.id.toString();
                                  loose = product.isLoose;
                                  scannerBatchId = product.batchNo;
                                });

                                Future.delayed(
                                  const Duration(milliseconds: 60),
                                      () => quantityFocusNode.requestFocus(),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("❌ Product not found ($scanned)"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            });
                          },




                          // ================= MANUAL SELECT =================
                          onSelected: (product) {
                            dropdownReturnController.text =
                            product.isLoose == '0'
                                ? '${product.pTitle} ${product.pVariation}${product.unit}'
                                : '${product.pTitle} (${product.pVariation})';

                            dropdownReturnController.selection =
                                TextSelection.collapsed(
                                  offset: dropdownReturnController.text.length,
                                );

                            setDialogState(() {
                              scannedProductName =
                              "${product.pTitle} - ${product.pVariation}${product.unit}";
                              scannedProductId = product.id.toString();
                              loose = product.isLoose;
                              scannerBatchId = product.batchNo;
                            });

                            // ✅ move focus AFTER rebuild
                            Future.delayed(const Duration(milliseconds: 50), () {
                              quantityFocusNode.requestFocus();
                            });
                          },
                        ),

                        const SizedBox(height: 16),

                        // ================= PRODUCT INFO =================
                        if (scannedProductName != null)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Product ID: $scannedProductId",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Text("Product: $scannedProductName"),
                              ],
                            ),
                          ),

                        const SizedBox(height: 16),

                        // ================= QUANTITY =================
                        TextField(
                          focusNode: quantityFocusNode,
                          controller: quantityController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly, // ✅ only numbers
                          ],
                          decoration: const InputDecoration(
                            labelText: "Quantity",
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ================= SUBMIT =================
                        ElevatedButton(
                          onPressed: () {
                            if (scannedProductId == null ||
                                quantityController.text.isEmpty) {
                              Toasts.showToastBar(
                                context: context,
                                text: "Select product & enter quantity",
                                color: Colors.red,
                              );
                              return;
                            }

                            final stockProduct = StockProduct(
                              productId: int.parse(scannedProductId!),
                              batchNo: scannerBatchId ?? '',
                              quantity:
                              int.tryParse(quantityController.text) ?? 1,
                              loose: loose ?? '0',
                            );

                            billingProvider
                                .updateStock([stockProduct], context);
                          },
                          child: const Text("Return Product"),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      billingProvider.dropdownFocusNode.requestFocus();
                    },
                    child: const Text("Close"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void setValueToController(String value) {
    final billingProvider = Provider.of<BillingProvider>(
        context, listen: false);
    value = value.trim();

    // Check: contains only digits?
    final isNumber = RegExp(r'^[0-9]+$').hasMatch(value);

    if (isNumber) {
      // It's a mobile number
      billingProvider.mobileController.text = value;
    } else {
      // It's a name (contains letters or mixed characters)
      billingProvider.nameController.text = value;
    }
  }

  void _applyDefaultQtyIfNeeded(
      BillingProvider billingProvider,
      int index,
      )
  {
    final controller = billingProvider.quantityControllers[index]!;

    int qty = int.tryParse(controller.text) ?? 0;

    // 🔥 EMPTY / ZERO → DEFAULT 1
    if (qty <= 0) {
      const String defaultText = "1";

      controller.value = controller.value.copyWith(
        text: defaultText,
        selection:
        const TextSelection.collapsed(offset: 1),
        composing: TextRange.empty,
      );

      billingProvider.updateBillingItem(
        index,
        isLoose: '0',
        quantity: 1,
      );
    }
  }

  void _applyDefaultLooseIfNeeded(
      BillingProvider billingProvider,
      int index,
      )
  {
    final controller = billingProvider.quantityControllers[index]!;

    double kg = double.tryParse(controller.text) ?? 0;

    // 🔥 EMPTY / ZERO → DEFAULT 1.000
    if (kg <= 0) {
      const String defaultText = "1.000";

      controller.value = controller.value.copyWith(
        text: defaultText,
        selection:
        TextSelection.collapsed(offset: defaultText.length),
        composing: TextRange.empty,
      );

      billingProvider.updateBillingItem(
        index,
        isLoose: '1',
        variation: 1000, // grams
      );
    }
  }

  void closeCustomerPopup(
      BuildContext context,
      FocusNode productSearchFocus,
      )
  {
    final billingProvider = Provider.of<BillingProvider>(
        context, listen: false);
    Navigator.pop(context);

    // Clear fields
    billingProvider.nameController.clear();
    billingProvider.mobileController.clear();

    // Return focus
    Future.delayed(const Duration(milliseconds: 100), () {
      productSearchFocus.requestFocus();
    });
  }
  void showAddCustomerPopup(BuildContext context, String mobile) {
    setValueToController(mobile);
    final billingProvider = Provider.of<BillingProvider>(
        context, listen: false);
    // Focus Nodes declared OUTSIDE builder → SAFE
    FocusNode nameFocus = FocusNode();
    FocusNode mobileFocus = FocusNode();
    FocusNode keyFocus = FocusNode(); // for ESC + Enter listener

    FocusNode productSearchFocus =
        Provider
            .of<BillingProvider>(context, listen: false)
            .productSearchFocusNode;

    showDialog(
      context: context,
      builder: (context) {
        // Auto focus to NAME field — SAFE & NO CRASH
        WidgetsBinding.instance.addPostFrameCallback((_) {
          nameFocus.requestFocus();
        });

        return AlertDialog(
          title: const Text("Add New Customer"),

          content: RawKeyboardListener(
            focusNode: keyFocus,
            autofocus: true,
            onKey: (event) async {
              if (event is RawKeyDownEvent) {
                // ESC → CLOSE popup
                if (event.logicalKey == LogicalKeyboardKey.escape) {
                  closeCustomerPopup(context, productSearchFocus);
                }


                // ENTER when mobile field focused → SAVE
                if (event.logicalKey == LogicalKeyboardKey.enter &&
                    mobileFocus.hasFocus) {
                  await saveCustomerAndClose(context, productSearchFocus);
                }
              }
            },

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: billingProvider.nameController,
                  focusNode: nameFocus,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: "Customer Name"),
                  onSubmitted: (_) => mobileFocus.requestFocus(),
                  inputFormatters: [

                    FirstLetterCapsFormatter(), // 👈 WEB FIX
                  ],
                ),

                SizedBox(height: 12),

                TextField(
                  controller: billingProvider.mobileController,
                  focusNode: mobileFocus,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: const InputDecoration(labelText: "Mobile Number"),
                  onSubmitted: (_) =>
                      saveCustomerAndClose(context, productSearchFocus),
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                productSearchFocus.requestFocus();
                billingProvider.mobileController.clear();
                billingProvider.nameController.clear();
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await saveCustomerAndClose(context, productSearchFocus);
                billingProvider.mobileController.clear();
                billingProvider.nameController.clear();
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> saveCustomerAndClose(
      BuildContext context,
      FocusNode dropdownFocusNode,
      )
  async {
    final billingProvider =
    Provider.of<BillingProvider>(context, listen: false);

    if (billingProvider.isSavingCustomer) return; // 🔒 prevent double call
    billingProvider.isSavingCustomer = true;

    final name = billingProvider.nameController.text.trim();
    final mobile = billingProvider.mobileController.text.trim();

    if (name.isEmpty || mobile.isEmpty) {
      Toasts.showToastBar(
        context: context,
        text: "Please fill all fields",
        color: Colors.red,
      );
      billingProvider.isSavingCustomer = false;
      return;
    }

    final bool success =
    await handleTypedCustomer(context, mobile, name);

    billingProvider.isSavingCustomer = false;

    // ❌ FAILED → keep popup open
    if (!success) return;

    // ✅ SUCCESS → close popup
    Navigator.pop(context);

    billingProvider.nameController.clear();
    billingProvider.mobileController.clear();

    Future.delayed(const Duration(milliseconds: 80), () {
      FocusScope.of(context).requestFocus(dropdownFocusNode);
    });
  }

  Future<bool> handleTypedCustomer(
      BuildContext context,
      String typed,
      String nameInput,
      )
  async {

    final customerProvider =
    Provider.of<CustomersProvider>(context, listen: false);

    final String mobile = typed.trim();
    final String name =
    nameInput.trim().isEmpty ? "Customer" : nameInput.trim();

    // ❌ Invalid mobile → popup OPEN
    if (mobile.length != 10) {
      Toasts.showToastBar(
        context: context,
        text: "Enter valid 10 digit mobile",
        color: Colors.red,
      );
      return false;
    }

    final String newCustomerId =
    await customerProvider.addCustomer(
      context: context,
      name: name,
      mobile: mobile,
      addressLine1: "",
      area: "",
      pincode: "600001",
      city: "Chennai",
      state: "Tamil Nadu",
    );

    // ❌ Already exists OR error → popup OPEN
    if (newCustomerId == "0") return false;

    // ✅ SUCCESS → select customer
    await customerProvider.getAllCustomers(context);

    final savedCustomer =
    customerProvider.allCustomersList.firstWhere(
          (c) => c.mobile == mobile,
    );

    customerProvider.setCustomerDetails(
      customerId: savedCustomer.userId.toString(),
      customerName: savedCustomer.name!,
      customerMobile: savedCustomer.mobile!,
      customerAddress: "",
    );

    return true; // ✅ close popup
  }





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
          return Scaffold(
            body: Focus(
              autofocus: true,
              focusNode: _focusNode,
              child: Shortcuts(
                  shortcuts: <LogicalKeySet, Intent>{
                    // LogicalKeySet(LogicalKeyboardKey.alt,
                    //     LogicalKeyboardKey.keyP): const ActivateIntent(),
                    // //alt +P  (Current Bill)
                    LogicalKeySet(LogicalKeyboardKey.control,
                        LogicalKeyboardKey.keyP): const ActivateIntent(),
                    //stop
                    LogicalKeySet(LogicalKeyboardKey.alt,
                        LogicalKeyboardKey.keyS): const NextPageIntent(),
                    //alt + S  (search bill)
                    LogicalKeySet(LogicalKeyboardKey.alt,
                        LogicalKeyboardKey.keyR): const LastBillIntent(),
                    //alt+ R (Last bill)
                    LogicalKeySet(LogicalKeyboardKey.f1): const F1Intent(),
                    //F1 (Current Bill)
                    LogicalKeySet(LogicalKeyboardKey.f2): const F2Intent(),
                    //F2 (Hold Bill)
                    LogicalKeySet(LogicalKeyboardKey.f4): const F4Intent(),
                    //F4 (Hold Bill)
                    LogicalKeySet(LogicalKeyboardKey.f6): const F6Intent(),
                    //F6  (Last bill)
                    LogicalKeySet(LogicalKeyboardKey.alt,
                        LogicalKeyboardKey.keyC): const AddCustomerIntent(),
                    // Alt + C  (Add Customer)
                    LogicalKeySet(LogicalKeyboardKey.alt,
                        LogicalKeyboardKey.keyL): const RefreshIntent(),
                    LogicalKeySet(LogicalKeyboardKey.tab): const TabIntent(),
                    // Alt + L  (Refresh Page)
                    LogicalKeySet(LogicalKeyboardKey.alt,
                        LogicalKeyboardKey.keyK): const HelpIntent(),
                    // Alt + K (Shortcut key List)
                    LogicalKeySet(LogicalKeyboardKey.alt,
                        LogicalKeyboardKey.keyR): const ReturnIntent(),
                    // Alt + R (Return Quantity)
                    LogicalKeySet(LogicalKeyboardKey.alt,
                        LogicalKeyboardKey.keyH): const HoldIntent(),
                    // Alt + H  (Search Hold bills)
                    LogicalKeySet(LogicalKeyboardKey.alt,
                        LogicalKeyboardKey.keyO): const LogoutIntent(),
                    // Alt + O (Log out Screen)
                    LogicalKeySet(
                      LogicalKeyboardKey.shift,
                      LogicalKeyboardKey.tab,
                    ): const ResetIntent(),

                    // Alt + O (Log out Screen)
                    LogicalKeySet(LogicalKeyboardKey.alt): const AltOnlyIntent(),
                    LogicalKeySet(LogicalKeyboardKey.alt,
                        LogicalKeyboardKey.keyP): const OpenProductIntent(),
                    // Alt + P ( Product Search Field)
                    LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey
                        .keyA): const OpenCustomerDropdownIntent(),
                    LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey
                        .keyN): const AddNewProduct(),
                    LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey
                        .keyD): const ProductDelete(),

                  },
                  child: Actions(
                    actions: {
                      NextPageIntent: CallbackAction<NextPageIntent>(
                        onInvoke: (intent) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const OrderDetailPage(),
                            ),
                          ).then((_) {
                            // 🔥 Search Bill screen-la irundhu thirumba vandha udane
                            billingProvider.dropdownFocusNode.requestFocus();
                          });

                          return null;
                        },
                      ),
                      LastBillIntent: CallbackAction<LastBillIntent>(
                        onInvoke: (intent) {
                          billingProvider.getLastOrderDetails(context);
                          return null;
                        },
                      ),
                      AltOnlyIntent: CallbackAction<Intent>(
                        onInvoke: (intent) {
                          print('Alt alone pressed!');
                          return null;
                        },
                      ),
                      F1Intent: CallbackAction<F1Intent>(
                        onInvoke: (intent) {
                          final billingProvider = Provider.of<BillingProvider>(context, listen: false);
                          final customerProvider = Provider.of<CustomersProvider>(context, listen: false);

                          print("_isPaymentDialogOpen: $_isPaymentDialogOpen");

                          // 🔹 CLOSE DIALOG IF ALREADY OPEN
                          if (_isPaymentDialogOpen) {
                            Navigator.pop(context); // ONLY ONE POP
                            setState(() => _isPaymentDialogOpen = false);
                            return;
                          }

                          // 🔹 PREVENT OPENING WHEN NO ITEMS
                          if (billingProvider.billingItems.isEmpty) {
                            billingProvider.printButtonController.reset();
                            Toasts.showToastBar(
                              context: context,
                              text: 'Bill List is empty',
                              color: Colors.red,
                            );
                            return;
                          }

                          // 🔹 OPEN PAYMENT DIALOG
                          setState(() => _isPaymentDialogOpen = true);

                          showPaymentBalanceDialog(
                            context,

                            onPressPrint: () async {
                              // =======================================
                              // 🔥 PREVENT MULTIPLE CALLS
                              // =======================================
                              // if (billingProvider.billingItems.isNotEmpty) {
                              if (_isPrinting) {
                                print("PRINT BLOCKED — ALREADY PRINTING");
                                return;
                              }

                              _isPrinting = true; // lock

                              final paymentMap = {
                                'UPI': '1',
                                'Paytm': '1',
                                'Split Payment': '5',
                                'Credit Card': '4',
                                'Cash': '2',
                                'Credit': '3',
                              };

                              final selectedMethod = billingProvider
                                  .selectBillMethod.toString();
                              final paymentId = paymentMap[selectedMethod] ?? '0';

                              print(
                                  "Payment Method: $selectedMethod, Payment ID: $paymentId");

                              final billStatus = selectedMethod == 'Credit'
                                  ? 0
                                  : 1;

                              // Assign default customer if empty
                              if (customerProvider.selectedCustomerId.isEmpty) {
                                customerProvider.setCustomerDetails(
                                  customerId: ProjectData.cash,
                                  customerName: ProjectData.name,
                                  customerMobile: ProjectData.mobile,
                                  customerAddress: ProjectData.address,
                                );
                              }

                              // =======================================
                              // 🔥 REAL PRINT — ONLY ONCE
                              // =======================================
                              await billingProvider.placeOrderAndPrintBill(
                                context,
                                order: Order(
                                  split_pay: selectedMethod == "Split Payment"
                                      ? (billingProvider.upiPayment.text.isEmpty
                                      ? "0"
                                      : billingProvider.upiPayment.text)
                                      : "0",

                                  customerMobile: customerProvider
                                      .selectedCustomerMobile,
                                  customerId: customerProvider.selectedCustomerId,
                                  customerName: customerProvider.selectedCustomerName.isEmpty ? "Cash Customer" : customerProvider.selectedCustomerName,
                                  customerAddress: customerProvider
                                      .customerAddressController.text,
                                  cashier: controllers.storage.read("id"),
                                  paymentMethod: selectedMethod,
                                  paymentId: paymentId,
                                  creditDays:
                                  selectedMethod == "Credit" ? (billingProvider
                                      .creditDays ?? 0) : 0,
                                  products: billingProvider.billingItems,
                                  orderGrandTotal:
                                  billingProvider
                                      .calculatedGrandTotal()
                                      .toString(),
                                  orderSubTotal:
                                  billingProvider
                                      .calculatedGrandTotal()
                                      .toString(),
                                  receivedAmt: billingProvider.paymentReceived
                                      .text.isEmpty
                                      ? "0.0"
                                      : double.parse(
                                      billingProvider.paymentReceived.text)
                                      .toStringAsFixed(0),
                                  payBackAmt: selectedMethod == "Cash"
                                      ? ((billingProvider.paymentReceived.text
                                      .isEmpty
                                      ? 0.0
                                      : double.parse(
                                      billingProvider.paymentReceived.text)) -
                                      billingProvider.calculatedGrandTotal())
                                      .abs()
                                      .toStringAsFixed(2)
                                      : "0.00",
                                  savings:
                                  '${billingProvider.billingItems.fold(
                                      0.0, (total, item) =>
                                  total + item.calculateDiscount())}',
                                  billStatus: billStatus,
                                  salesmanId: controllers.storage.read("id").toString(),
                                  version: "0.0",
                                ),
                              );

                              // Unlock print after attempt
                              _isPrinting = false;
                            },
                            // },


                            onPressPrintHold: () {},
                            onPressPrintSave: () async {
                              // =======================================
                              // 🔥 PREVENT MULTIPLE CALLS
                              // =======================================
                              // if (billingProvider.billingItems.isNotEmpty) {
                              if (_isPrinting) {
                                print("PRINT BLOCKED — ALREADY PRINTING");
                                return;
                              }

                              _isPrinting = true; // lock

                              final paymentMap = {
                                'UPI': '1',
                                'Paytm': '1',
                                'Split Payment': '5',
                                'Credit Card': '4',
                                'Cash': '2',
                                'Credit': '3',
                              };

                              final selectedMethod = billingProvider
                                  .selectBillMethod.toString();
                              final paymentId = paymentMap[selectedMethod] ?? '0';

                              print(
                                  "Payment Method: $selectedMethod, Payment ID: $paymentId");

                              final billStatus = selectedMethod == 'Credit'
                                  ? 0
                                  : 1;

                              // Assign default customer if empty
                              if (customerProvider.selectedCustomerId.isEmpty) {
                                customerProvider.setCustomerDetails(
                                  customerId: ProjectData.cash,
                                  customerName: ProjectData.name,
                                  customerMobile: ProjectData.mobile,
                                  customerAddress: ProjectData.address,
                                );
                              }

                              // =======================================
                              // 🔥 REAL PRINT — ONLY ONCE
                              // =======================================
                              await billingProvider.placeOrderAndSaveBill(
                                context,
                                order: Order(
                                  split_pay: selectedMethod == "Split Payment"
                                      ? (billingProvider.upiPayment.text.isEmpty
                                      ? "0"
                                      : billingProvider.upiPayment.text)
                                      : "0",

                                  customerMobile: customerProvider
                                      .selectedCustomerMobile,
                                  customerId: customerProvider.selectedCustomerId,
                                  customerName: customerProvider.selectedCustomerName.isEmpty ? "Cash Customer" : customerProvider.selectedCustomerName,
                                  customerAddress: customerProvider
                                      .customerAddressController.text,
                                  cashier: controllers.storage.read("id"),
                                  paymentMethod: selectedMethod,
                                  paymentId: paymentId,
                                  creditDays:
                                  selectedMethod == "Credit" ? (billingProvider
                                      .creditDays ?? 0) : 0,
                                  products: billingProvider.billingItems,
                                  orderGrandTotal:
                                  billingProvider
                                      .calculatedGrandTotal()
                                      .toString(),
                                  orderSubTotal:
                                  billingProvider
                                      .calculatedGrandTotal()
                                      .toString(),
                                  receivedAmt: billingProvider.paymentReceived
                                      .text.isEmpty
                                      ? "0.0"
                                      : double.parse(
                                      billingProvider.paymentReceived.text)
                                      .toStringAsFixed(0),
                                  payBackAmt: selectedMethod == "Cash"
                                      ? ((billingProvider.paymentReceived.text
                                      .isEmpty
                                      ? 0.0
                                      : double.parse(
                                      billingProvider.paymentReceived.text)) -
                                      billingProvider.calculatedGrandTotal())
                                      .abs()
                                      .toStringAsFixed(2)
                                      : "0.00",
                                  savings:
                                  '${billingProvider.billingItems.fold(
                                      0.0, (total, item) =>
                                  total + item.calculateDiscount())}',
                                  billStatus: billStatus,
                                  salesmanId: controllers.storage.read("id").toString(),
                                  version: "0.0",
                                ),
                              );

                              // Unlock print after attempt
                              _isPrinting = false;
                            },
                          ).whenComplete(() {
                            setState(() => _isPaymentDialogOpen = false);
                          });

                          return;
                        },
                      ),
                      TabIntent: CallbackAction<TabIntent>(
                        onInvoke: (intent) async {
                          final billingProvider = Provider.of<BillingProvider>(context, listen: false);
                          final customerProvider = Provider.of<CustomersProvider>(context, listen: false);

                          print("_isPaymentDialogOpen: $_isPaymentDialogOpen");

                          // 🔹 CLOSE DIALOG IF ALREADY OPEN
                          if (_isPaymentDialogOpen) {
                            Navigator.pop(context); // ONLY ONE POP
                            setState(() => _isPaymentDialogOpen = false);
                            return;
                          }

                          // 🔹 PREVENT OPENING WHEN NO ITEMS
                          if (billingProvider.billingItems.isEmpty) {
                            billingProvider.printButtonController.reset();
                            Toasts.showToastBar(
                              context: context,
                              text: 'Bill List is empty',
                              color: Colors.red,
                            );
                            return;
                          }

                          // 🔹 OPEN PAYMENT DIALOG
                          setState(() => _isPaymentDialogOpen = true);
                          // 🔹 Directly save the bill
                          final selectedMethod = billingProvider.selectBillMethod.toString();
                          final paymentMap = {
                            'UPI': '1',
                            'Paytm': '1',
                            'Split Payment': '5',
                            'Credit Card': '4',
                            'Cash': '2',
                            'Credit': '3',
                          };
                          final paymentId = paymentMap[selectedMethod] ?? '0';
                          final billStatus = selectedMethod == 'Credit' ? 0 : 1;

                          // Assign default customer if none selected
                          if (customerProvider.selectedCustomerId.isEmpty) {
                            customerProvider.setCustomerDetails(
                              customerId: ProjectData.cash,
                              customerName: ProjectData.name,
                              customerMobile: ProjectData.mobile,
                              customerAddress: ProjectData.address,
                            );
                          }

                          await billingProvider.placeOrderAndSaveBill(
                            context,
                            order: Order(
                              split_pay: selectedMethod == "Split Payment"
                                  ? (billingProvider.upiPayment.text.isEmpty
                                  ? "0"
                                  : billingProvider.upiPayment.text)
                                  : "0",
                              customerMobile: customerProvider.selectedCustomerMobile,
                              customerId: customerProvider.selectedCustomerId,
                              customerName: customerProvider.selectedCustomerName.isEmpty ? "Cash Customer" : customerProvider.selectedCustomerName,
                              customerAddress: customerProvider.customerAddressController.text,
                              cashier: controllers.storage.read("id"),
                              paymentMethod: selectedMethod,
                              paymentId: paymentId,
                              creditDays: selectedMethod == "Credit" ? (billingProvider.creditDays ?? 0) : 0,
                              products: billingProvider.billingItems,
                              orderGrandTotal: billingProvider.calculatedGrandTotal().toString(),
                              orderSubTotal: billingProvider.calculatedGrandTotal().toString(),
                              receivedAmt: billingProvider.paymentReceived.text.isEmpty
                                  ? "0.0"
                                  : double.parse(billingProvider.paymentReceived.text).toStringAsFixed(0),
                              payBackAmt: selectedMethod == "Cash"
                                  ? ((billingProvider.paymentReceived.text.isEmpty
                                  ? 0.0
                                  : double.parse(billingProvider.paymentReceived.text)) -
                                  billingProvider.calculatedGrandTotal())
                                  .abs()
                                  .toStringAsFixed(2)
                                  : "0.00",
                              savings:
                              '${billingProvider.billingItems.fold(0.0, (total, item) => total + item.calculateDiscount())}',
                              billStatus: billStatus,
                              salesmanId: controllers.storage.read("id").toString(),
                              version: "0.0",
                            ),
                          );

                          return;
                        },
                      ),
                      F4Intent: CallbackAction<F4Intent>(
                        onInvoke: (intent) async {
                          print("ðŸ‘‰ F2 Pressed");
                          {
                            if (billingProvider.billingItems.isEmpty) {
                              billingProvider.printButtonController.reset();
                              Toasts.showToastBar(
                                context: context,
                                text: 'Bill List is empty',
                                color: Colors.red,
                              );
                              return;
                            }

                            // âœ… Directly hold the bill without payment dialog
                            final paymentMap = {
                              'UPI': '1',
                              'Paytm': '1',
                              'Split Payment': '5',
                              'Credit Card': '4',
                              'Cash': '2',
                              'Credit': '3',
                            };
                            final selectedMethod = billingProvider
                                .selectBillMethod ?? "Cash"; // default Cash
                            final paymentId = paymentMap[selectedMethod] ?? '0';

                            if (customerProvider.selectedCustomerId.isEmpty) {
                              customerProvider.setCustomerDetails(
                                  customerId: ProjectData.cash,
                                  customerName: ProjectData.name,
                                  customerMobile: ProjectData.mobile,
                                  customerAddress: ProjectData.address);
                            }

                            final now = DateTime.now();
                            final billNo = 'BILL${now.millisecondsSinceEpoch %
                                10000}';
                            final formattedDate = '${now.day}/${now.month}/${now
                                .year} ${now.hour}:${now.minute}';

                            await billingProvider.saveHoldBillDetails(context: context,
                              order: Order(
                                split_pay: billingProvider.selectBillMethod ==
                                    "Split Payment"
                                    ? (billingProvider.upiPayment.text.isEmpty
                                    ? "0"
                                    : billingProvider.upiPayment.text)
                                    : "0",

                                id: billNo,
                                // âœ… Bill No
                                createdTs: formattedDate,
                                // âœ… Date
                                customerMobile: customerProvider
                                    .selectedCustomerMobile,
                                customerId: customerProvider.selectedCustomerId,
                                customerName: customerProvider.selectedCustomerName.isEmpty ? "Cash Customer" : customerProvider.selectedCustomerName,
                                customerAddress: customerProvider
                                    .customerAddressController.text,
                                // cashier: billingProvider.cashierNameController.text
                                //     .trim(),
                                cashier: controllers.storage.read("id"),
                                paymentMethod: billingProvider.selectBillMethod
                                    .toString(),
                                paymentId: paymentId,
                                creditDays: billingProvider.selectBillMethod
                                    .toString() == "Credit"
                                    ? (billingProvider.creditDays ?? 0)
                                    : 0,
                                products: billingProvider.billingItems,
                                orderGrandTotal: billingProvider
                                    .calculatedGrandTotal().toStringAsFixed(2),
                                orderSubTotal: billingProvider
                                    .calculatedGrandTotal().toStringAsFixed(2),
                                receivedAmt: billingProvider.paymentReceived.text
                                    .isEmpty
                                    ? "0.0"
                                    : double
                                    .parse(
                                    billingProvider.paymentReceived.text)
                                    .toStringAsFixed(1),
                                payBackAmt: (
                                    billingProvider.selectBillMethod == "Cash"
                                        ? ((billingProvider.paymentReceived.text
                                        .isEmpty
                                        ? 0.0
                                        : double.parse(
                                        billingProvider.paymentReceived.text))
                                        - billingProvider.calculatedGrandTotal())
                                        .abs()
                                        .toStringAsFixed(2)
                                        : "0.00"
                                ),
                                savings: '${billingProvider.billingItems.fold(
                                    0.0, (t, i) => t + i.calculateDiscount())}',
                                billStatus: 0,
                                version: "0.0",
                                salesmanId: controllers.storage.read("id").toString(),
                              ),
                            );


                            Toasts.showToastBar(
                              context: context,
                              text: 'Bill saved to Hold successfully',
                              color: Colors.green,
                            );

                            billingProvider.printAfterChangeButtonControllerHold
                                .reset();

                            // âœ… Optionally, clear current billing items after hold
                            billingProvider.billingItems.clear();
                            billingProvider.quantityControllers.clear();
                            billingProvider.notifyListeners();
                          }
                        }, //F6 last bill
                      ),
                      OpenProductIntent: CallbackAction<OpenProductIntent>(
                        onInvoke: (intent) {
                          dropdownController.text = '';
                          billingProvider.dropdownFocusNode.requestFocus();
                          Future.delayed(const Duration(milliseconds: 10), () {
                            dropdownController.selection = TextSelection.collapsed(
                                offset: dropdownController.text.length);
                          });

                          return null;
                        },
                      ),
                      AddCustomerIntent: CallbackAction<AddCustomerIntent>(
                        onInvoke: (intent) {
                          // Open AddCustomerDialog on Alt + C
                          // showDialog(
                          //   context: context,
                          //   builder: (context) => AddCustomerDialog(),
                          // );
                          // return null;
                          customerProvider.addCustomerDialog(context);
                        },
                      ),
                      RefreshIntent: CallbackAction<RefreshIntent>(
                        onInvoke: (intent) {
                          // Call getProducts() on Alt + L
                          if (billingProvider.isWChecked) {
                            billingProvider.getWholeSaleProducts();
                          } else {
                            billingProvider.getProducts();
                          }
                          return null;
                        },
                      ),
                      HelpIntent: CallbackAction<HelpIntent>(
                        onInvoke: (intent) {
                          ShortcutHelpDialog.show(context); // Help dialog open
                          return null;
                        },
                      ),
                      ReturnIntent: CallbackAction<ReturnIntent>(
                        onInvoke: (intent) {
                          if (localData.secretCode == null ||
                              localData.secretCode!.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  "Don't Have The Access to Return Product ",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 18),),
                                backgroundColor: colorsConst.primary,
                                duration: const Duration(seconds: 2),
                              ),
                            );

                            return null; // âŒ stop dialog
                          }

                          // âœ… access iruntha open
                          showReturnQuantityDialog();
                          return null;
                        },
                      ),
                      HoldIntent: CallbackAction<HoldIntent>(
                          onInvoke: (intent) async {
                            // âœ… Wait for result from HoldBillsScreen
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HoldBill()),
                            );

                            // âœ… If user released a bill, rebuild the screen
                            if (result == true) {
                              setState(() {}); // refreshes UI to show restored products
                            }
                          }

                      ),
                      LogoutIntent: CallbackAction<LogoutIntent>(
                        onInvoke: (intent) {
                          // Show logout confirm dialog
                          customerProvider.showCashierPopupAndLogout(context,billingProvider);
                        },
                      ),
                      ResetIntent: CallbackAction<ResetIntent>(
                        onInvoke: (intent) {
                          // Show logout confirm dialog
                          billingProvider.clearBillingData(context);
                          billingProvider.dropdownFocusNode.requestFocus();
                        },
                      ),
                      OpenCustomerDropdownIntent: CallbackAction<
                          OpenCustomerDropdownIntent>(
                        onInvoke: (intent) {
                          cusFocusNode.requestFocus();
                          Future.delayed(const Duration(milliseconds: 80), () {
                            try {
                              (cusDropdownKey.currentState as dynamic)?.openMenu();
                            } catch (e, st) {
                              debugPrint(
                                  'Failed to open customer dropdown: $e\n$st');
                            }
                          });
                          return null;
                        },
                      ),
                      AddNewProduct: CallbackAction<AddNewProduct>(
                        onInvoke: (intent) async {

                          // ❌ DO NOT unfocus (this kills shortcuts)
                          // FocusScope.of(context).unfocus();

                          // ✅ Ensure keyboard focus before dialog
                          _keyboardFocusNode.requestFocus();

                          final result = await showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (_) => const AddProductDialog(),
                          );

                          // ✅ Dialog close aana apram focus MUST be restored
                          if (result == true) {
                            Future.delayed(const Duration(milliseconds: 100), () {
                              _keyboardFocusNode.requestFocus();
                              billingProvider.dropdownFocusNode.requestFocus();
                            });
                          }

                          return null;
                        },
                      ),
                      ProductDelete: CallbackAction<ProductDelete>(
                          onInvoke: (intent) async {
                            billingProvider
                                .selectedProduct = null;
                            billingProvider
                                .updateTemporaryFields(
                                quantity: 0,
                                variation: 0.0);
                            safeClear(dropdownController);
                            safeClear(quantityVariationController);
                            Future.microtask(() {
                              billingProvider.dropdownFocusNode.requestFocus();
                            });

                          }    ),
                    },
                    child: Scaffold(
                      body: RawKeyboardListener(
                        focusNode: FocusNode(),
                        onKey: (RawKeyEvent event) {
                          if (event is RawKeyDownEvent) {
                            // ☑️ If dropdown is focused → DO NOT HANDLE ARROWS
                            if (dropdownController.text.isEmpty) {
                              // ▼▼ DOWN ARROW ▼▼
                              if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                                _handleArrowDown();
                              }
                              // ▲▲ UP ARROW ▲▲
                              if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                                _handleArrowUp();
                              }// stop table navigation
                            }
                            // ❌ BACKSPACE key → also remove selected row
                            if (event.logicalKey == LogicalKeyboardKey.delete) {
                              if (selectedRowIndex >= 0 &&
                                  selectedRowIndex < billingProvider.billingItems.length) {
                                billingProvider.removeBillingItem(index: selectedRowIndex);
                                billingProvider.dropdownFocusNode.requestFocus();
                              }
                            }
                            // if (event.logicalKey == LogicalKeyboardKey.enter) {
                            //   dropdownFocusNode.requestFocus();
                            //
                            // }
                          }
                        },
                        child: Row(
                          children: [
                            SideBar(),
                            GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  // 🔥 mouse click ஆனாலும் focus return
                                  _focusNode.requestFocus();
                                },
                                child: billingProvider.isLoading ? LoadingWidgets
                                    .circleLoading()
                                    : Container(
                                  width:controllers.isLeftOpen.value?MediaQuery.of(context).size.width - 150:MediaQuery.of(context).size.width - 60,
                                  height: MediaQuery.of(context).size.height,
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.fromLTRB(16, 5, 16, 16),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          _focusNode.requestFocus();
                                        },
                                        child: Container(
                                          color: colorsConst.primary,
                                          padding: const EdgeInsets.only(bottom: 1),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              20.height,
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  SizedBox(
                                                    height: 70,
                                                    width: 120,
                                                    child: InkWell(
                                                      onTap: () =>
                                                          billingProvider.clearBillingData(
                                                              context),
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(
                                                            horizontal: 10, vertical: 8),
                                                        decoration: BoxDecoration(
                                                            border: Border.all(
                                                                color: Colors.black26),
                                                            color: Colors.white
                                                          // color: colorsConst.primaryGreen.withOpacity(0.2)
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            // ICON
                                                            SvgPicture.asset(
                                                              "assets/bill/Reset.svg",
                                                              height: 23,
                                                            ),
                                                            const SizedBox(width: 2),

                                                            // TWO-LINE TEXT
                                                            const Column(
                                                              crossAxisAlignment: CrossAxisAlignment
                                                                  .start,
                                                              children: [
                                                                Text(
                                                                  "Clear Bill\n Shf + Tab",
                                                                  style: TextStyle(
                                                                    color: Colors.black,
                                                                    fontSize: 16,
                                                                    fontWeight: FontWeight
                                                                        .bold,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 70,
                                                    width: 134,
                                                    child: InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(builder: (
                                                                context) => const OrderDetailPage()));
                                                      },
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(
                                                            horizontal: 10, vertical: 8),
                                                        decoration: BoxDecoration(
                                                            border: Border.all(
                                                                color: Colors.black26),
                                                            color: Colors.white
                                                          // color: colorsConst.primaryGreen.withOpacity(0.2)
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            // ICON
                                                            SvgPicture.asset(
                                                              "assets/bill/bill.svg",
                                                              height: 30,
                                                            ),
                                                            const SizedBox(width: 2),

                                                            // TWO-LINE TEXT
                                                            const Column(
                                                              crossAxisAlignment: CrossAxisAlignment
                                                                  .start,
                                                              children: [
                                                                Text(
                                                                  "Search Bill\n ALT + S",
                                                                  style: TextStyle(
                                                                    color: Colors.black,
                                                                    fontSize: 16,
                                                                    fontWeight: FontWeight
                                                                        .bold,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 70,
                                                    width: 146,
                                                    child: InkWell(
                                                      onTap: () {
                                                        showDialog(
                                                          context: context,
                                                          barrierDismissible: true,
                                                          builder: (_) => const AddProductDialog(),
                                                        );
                                                      },

                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(
                                                            horizontal: 10, vertical: 8),
                                                        decoration: BoxDecoration(
                                                            border: Border.all(
                                                                color: Colors.black26),
                                                            color: Colors.white
                                                          // color: colorsConst.primaryGreen.withOpacity(0.2)
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            // ICON
                                                            SvgPicture.asset(
                                                              "assets/bill/bill.svg",
                                                              height: 30,
                                                            ),
                                                            const SizedBox(width: 2),

                                                            // TWO-LINE TEXT
                                                            const Column(
                                                              crossAxisAlignment: CrossAxisAlignment
                                                                  .start,
                                                              children: [
                                                                Text(
                                                                  "Add Product\nALT + N",
                                                                  style: TextStyle(
                                                                    color: Colors.black,
                                                                    fontSize: 16,
                                                                    fontWeight: FontWeight
                                                                        .bold,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 70,
                                                    width:137,
                                                    child: InkWell(
                                                      onTap: () {
                                                        if (localData.secretCode == null ||
                                                            localData.secretCode!
                                                                .trim()
                                                                .isEmpty) {
                                                          ScaffoldMessenger
                                                              .of(context)
                                                              .showSnackBar(
                                                             SnackBar(
                                                              content: Text(
                                                                "Don't Have the Access to return quantity",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 18),),
                                                              backgroundColor: colorsConst.primary,
                                                              duration: Duration(seconds: 2),
                                                            ),
                                                          );

                                                          return; // stop opening dialog
                                                        }

                                                        showReturnQuantityDialog();
                                                      },
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(
                                                            horizontal: 10, vertical: 8),
                                                        decoration: BoxDecoration(
                                                          // border: Border.all(color: Colors.white),
                                                            border: Border.all(
                                                                color: Colors.black26),
                                                            color: Colors.white),
                                                        child: Row(
                                                          children: [
                                                            // ICON
                                                            SvgPicture.asset(
                                                              "assets/bill/return.svg",
                                                              height: 30,
                                                            ),
                                                            const SizedBox(width: 2),

                                                            // TWO-LINE TEXT
                                                            const Column(
                                                              crossAxisAlignment: CrossAxisAlignment
                                                                  .start,
                                                              children: [
                                                                Text(
                                                                  "Return Qty \nALT + R",
                                                                  style: TextStyle(
                                                                    color: Colors.black,
                                                                    fontSize: 16,
                                                                    fontWeight: FontWeight
                                                                        .bold,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 70,
                                                    width: 138,
                                                    child: InkWell(
                                                      onTap: () async {
                                                        // âœ… Wait for result from HoldBillsScreen
                                                        final result = await Navigator.push(
                                                          context,
                                                          MaterialPageRoute(builder: (
                                                              context) => HoldBill()
                                                          ),
                                                        );

                                                        // âœ… If user released a bill, rebuild the screen
                                                        if (result == true) {
                                                          setState(() {}); // refreshes UI to show restored products
                                                        }
                                                      },
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(
                                                            horizontal: 10, vertical: 8),
                                                        decoration: BoxDecoration(
                                                          // border: Border.all(color: Colors.white),
                                                            border: Border.all(
                                                                color: Colors.black26),
                                                            color: Colors.white
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            // ICON
                                                            SvgPicture.asset(
                                                              "assets/bill/release_bill.svg",
                                                              height: 30,
                                                            ),
                                                            const SizedBox(width: 2),

                                                            // TWO-LINE TEXT
                                                            const Column(
                                                              crossAxisAlignment: CrossAxisAlignment
                                                                  .start,
                                                              children: [
                                                                Text(
                                                                  "Release Bill\nALT + H",
                                                                  style: TextStyle(
                                                                    color: Colors.black,
                                                                    fontSize: 16,
                                                                    fontWeight: FontWeight
                                                                        .bold,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 70,
                                                    width: 140,
                                                    child: InkWell(
                                                      onTap: () {
                                                        customerProvider.addCustomerDialog(
                                                            context);
                                                      },
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(
                                                            horizontal: 10, vertical: 8),
                                                        decoration: BoxDecoration(
                                                            border: Border.all(
                                                                color: Colors.black26),
                                                            color: Colors.white),
                                                        child: Row(
                                                          children: [
                                                            // ICON
                                                            SvgPicture.asset(
                                                              "assets/bill/customer.svg",
                                                              height: 30,
                                                            ),
                                                            const SizedBox(width: 2),

                                                            // TWO-LINE TEXT
                                                            const Column(
                                                              crossAxisAlignment: CrossAxisAlignment
                                                                  .start,
                                                              children: [
                                                                Text(
                                                                  "Add Cust\nALT + C",
                                                                  style: TextStyle(
                                                                    color: Colors.black,
                                                                    fontSize: 16,
                                                                    fontWeight: FontWeight
                                                                        .bold,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 70,
                                                    width: 155,
                                                    child: InkWell(
                                                      onTap: () {
                                                        if (billingProvider.isWChecked) {
                                                          billingProvider.getWholeSaleProducts();
                                                        } else {
                                                          billingProvider.getProducts();
                                                        }
                                                      },
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(
                                                            horizontal: 10, vertical: 8),
                                                        decoration: BoxDecoration(
                                                          // border: Border.all(color: Colors.white),
                                                            border: Border.all(
                                                                color: Colors.black26),
                                                            color: Colors.white),
                                                        child: Row(
                                                          children: [
                                                            // ICON
                                                            SvgPicture.asset(
                                                              "assets/bill/Refresh.svg",
                                                              height: 30,
                                                            ),
                                                            const SizedBox(width: 2),

                                                            // TWO-LINE TEXT
                                                            const Column(
                                                              crossAxisAlignment: CrossAxisAlignment
                                                                  .start,
                                                              children: [
                                                                Text(
                                                                  "Refresh Stock\nALT + L",
                                                                  style: TextStyle(
                                                                    color: Colors.black,
                                                                    fontSize: 16,
                                                                    fontWeight: FontWeight
                                                                        .bold,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 70,
                                                    width: 118,
                                                    child: InkWell(
                                                      onTap: () {
                                                        customerProvider
                                                            .showCashierPopupAndLogout(
                                                            context,billingProvider);
                                                      },
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(
                                                            horizontal: 10, vertical: 8),
                                                        decoration: BoxDecoration(
                                                            border: Border.all(
                                                                color: Colors.black26),
                                                            color: Colors
                                                                .white // color: colorsConst.primaryGreen.withOpacity(0.2)
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            // ICON
                                                            SvgPicture.asset(
                                                              "assets/bill/logout.svg",
                                                              height: 30,
                                                            ),
                                                            const SizedBox(width: 2),

                                                            // TWO-LINE TEXT
                                                            const Column(
                                                              crossAxisAlignment: CrossAxisAlignment
                                                                  .start,
                                                              children: [
                                                                Text(
                                                                  "Logout\nALT + O",
                                                                  style: TextStyle(
                                                                    color: Colors.black,
                                                                    fontSize: 16,
                                                                    fontWeight: FontWeight
                                                                        .bold,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),20.height,
                                              CustomerDropdown(
                                                custList: controllers.customers,
                                                onChanged: (AllCustomersObj? customer) {
                                                  setState(() {
                                                    controllers.selectCustomer(customer!);
                                                  });
                                                },),20.height,
                                            ],
                                          ),
                                        ),
                                      ),
                                      /// Fixed Header:
                                      // Row containing Search Dropdown and Variation/Quantity field
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0, right: 8, bottom: 1, top: 5),
                                            child: Row(
                                              children: [
                                                /// Searchable DropdownMenu (Header)
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                      left: 8.0,
                                                      right: 8,
                                                      bottom: 1,
                                                      top: 1),
                                                  child: Row(
                                                    children: [
                                                      SizedBox(
                                                        width: screenWidth/5,
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius
                                                                .circular(20),
                                                            border: Border.all(
                                                                color: Colors.grey
                                                                    .shade600,
                                                                width: 1.4),
                                                          ),
                                                          padding: const EdgeInsets.symmetric(horizontal: 0),
                                                          child:Focus(
                                                            onKeyEvent: (node, event) {
                                                              // 🚫 block ONLY arrow keys (these cause editable.dart crash)
                                                              if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
                                                                  event.logicalKey == LogicalKeyboardKey.arrowUp) {
                                                                return KeyEventResult.handled;
                                                              }

                                                              // ✅ allow everything else (numbers, enter, tab, etc)
                                                              return KeyEventResult.ignored;
                                                            },
                                                            onFocusChange: (hasFocus) {
                                                              if (!hasFocus) {

                                                                final billing = billingProvider;
                                                                final text = dropdownController.text.trim();

                                                                // 🔒 Skip validation during scan / programmatic update
                                                                if (_isProgrammaticChange) return;

                                                                // ❌ Manual typing but no product selected
                                                                if (billing.selectedProduct == null && text.isNotEmpty) {
                                                                  // ScaffoldMessenger.of(context).showSnackBar(
                                                                  //   const SnackBar(
                                                                  //     content: Text("❌ Product not found"),
                                                                  //     backgroundColor: Colors.red,
                                                                  //   ),
                                                                  // );

                                                                  Future.microtask(() {
                                                                    billing.dropdownFocusNode.requestFocus();

                                                                    dropdownController.value = TextEditingValue(
                                                                      text: dropdownController.text,
                                                                      selection: TextSelection.collapsed(
                                                                        offset: dropdownController.text.length,
                                                                      ),
                                                                    );
                                                                  });
                                                                }
                                                              }
                                                            },
                                                            child: KeyboardDropdownField<ProductData>(
                                                              focusNode: billingProvider.dropdownFocusNode,

                                                              items: billingProvider.productsList
                                                                  .where((p) {
                                                                final price = double.tryParse(p.outPrice?.toString() ?? "0") ?? 0;

                                                                // Apply price > 0 condition to BOTH loose and normal products
                                                                if (price > 0) return true;

                                                                return false;
                                                              })
                                                                  .toList()
                                                                ..sort((a, b) {
                                                                  String titleA = a.pTitle?.toLowerCase().trim() ?? "";
                                                                  String titleB = b.pTitle?.toLowerCase().trim() ?? "";
                                                                  titleA = titleA.replaceAll(RegExp(r'\s+'), '');
                                                                  titleB = titleB.replaceAll(RegExp(r'\s+'), '');

                                                                  bool aStartsNum = RegExp(r'^\d').hasMatch(titleA);
                                                                  bool bStartsNum = RegExp(r'^\d').hasMatch(titleB);

                                                                  if (!aStartsNum && bStartsNum) return -1;
                                                                  if (aStartsNum && !bStartsNum) return 1;
                                                                  return titleA.compareTo(titleB);
                                                                }),
                                                              hintText: "Product...",
                                                              hintStyle: TextStyle(
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 24,
                                                                color: Colors.grey.shade600,
                                                              ),
                                                              linkStyle: const TextStyle(
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 24,
                                                                color: Colors.black,
                                                              ),

                                                              labelText: "Product",
                                                              textEditingController: dropdownController,

                                                              labelBuilder: (product) {
                                                                final double qty =
                                                                    double.tryParse(product.qtyLeft?.toString() ?? "0") ?? 0;

                                                                bool isLowStock = qty > 0 && qty <= 10; // 🔥 low stock limit

                                                                return product.isLoose == '0'
                                                                    ? '${product.pTitle ?? ""}'
                                                                    '${product.pVariation != null ? " ${product.pVariation}" : ""}'
                                                                    '${product.unit != null ? product.unit : ""}'
                                                                    : '${product.pTitle ?? ""}'
                                                                    '${product.pVariation != null ? " (${product.pVariation})" : ""}';

                                                              },

                                                              itemBuilder: (product)
                                                              {
                                                                final double qty =
                                                                    double.tryParse(product.qtyLeft?.toString() ?? "0") ?? 0;

                                                                bool isLowStock = qty > 0 && qty <= 20; // 🔥 low stock limit


                                                                bool isOutOfStock = qty <= 0;
                                                                return Container(
                                                                  padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                                                  child:
                                                                  Row(
                                                                    children: [
                                                                      SizedBox(
                                                                        width: 230,
                                                                        child: Text(
                                                                          product.qtyLeft! == "0"
                                                                              ? product.isLoose == '0'
                                                                              ? '${product.pTitle} ${product.pVariation}${product.unit} (Out of Stock)'
                                                                              : '${product.pTitle} (${product.pVariation}) (Out of Stock)'
                                                                              : product.isLoose == '0'
                                                                              ? '${product.pTitle} ${product.pVariation}${product.unit}'
                                                                              : '${product.pTitle} (${product.pVariation})',
                                                                          style: TextStyle(
                                                                            color: isOutOfStock ? Colors.green
                                                                                : Colors.black, // ✅ out of stock red
                                                                            fontSize: 18,
                                                                            fontWeight: FontWeight.bold,
                                                                          ),
                                                                          maxLines: 2,
                                                                          overflow: TextOverflow.ellipsis,
                                                                        ),
                                                                      ),

                                                                      SizedBox(width: 10),
                                                                      buildInfoBlock(
                                                                        label: product.qtyLeft! == "0"
                                                                            ? ""
                                                                            : "MRP:",
                                                                        value: product.qtyLeft! == "0"
                                                                            ? ""
                                                                            : product.isLoose == "1"
                                                                            ? ((double.tryParse(
                                                                            product.mrp?.toString() ?? "") ?? 0))
                                                                            .toStringAsFixed(1)
                                                                            : (double.tryParse(
                                                                            product.mrp?.toString() ?? "") ?? 0)
                                                                            .toStringAsFixed(1),
                                                                        color: Colors.blue, color1: Colors.black,
                                                                      ),

                                                                      buildInfoBlock(
                                                                        label: product.qtyLeft! == "0"
                                                                            ? ""
                                                                            : "Sell:",
                                                                        value: product.qtyLeft! == "0"
                                                                            ? ""
                                                                            : product.isLoose == "1"
                                                                            ? ((double.tryParse(
                                                                            product.pricePerG?.toString() ?? "") ?? 0) * 1000)
                                                                            .toStringAsFixed(1)
                                                                            : (double.tryParse(
                                                                            product.outPrice?.toString() ?? "") ?? 0)
                                                                            .toStringAsFixed(1),
                                                                        color: Colors.green, color1: Colors.black,
                                                                      ),

                                                                      buildInfoBlock(
                                                                        label: product.qtyLeft! == "0"
                                                                            ? ""
                                                                            : "Stk:",
                                                                        value: product.qtyLeft! == "0"
                                                                            ? ""
                                                                            : product.isLoose == "1"
                                                                            ? "${((double.tryParse(
                                                                            product.qtyLeft?.toString() ?? "") ?? 0) / 1000)
                                                                            .toStringAsFixed(2)} Kg"
                                                                            : (int.tryParse(
                                                                            product.qtyLeft?.toString() ?? "") ?? 0)
                                                                            .toString(),
                                                                        color: Colors.purple,
                                                                        color1: isLowStock ? Colors.lightBlueAccent.shade700 : Colors.black,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );

                                                              },
                                                              onScan: (code) {
                                                                final billingProvider =
                                                                Provider.of<BillingProvider>(context, listen: false);

                                                                String onlyDigits(String s) =>
                                                                    s.replaceAll(RegExp(r'[^0-9]'), '');

                                                                final digits = onlyDigits(code.trim());

                                                                if (digits.length < 6) return;

                                                                _scanDebounce?.cancel();

                                                                _scanDebounce = Timer(const Duration(milliseconds: 120), () {

                                                                  try {
                                                                    final match = billingProvider.productsList.firstWhere(
                                                                          (p) => p.barcode == digits,
                                                                    );

                                                                    final double qty =
                                                                        double.tryParse(match.qtyLeft?.toString() ?? "0") ?? 0;

                                                                    if (qty <= 0) {
                                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                                        const SnackBar(
                                                                          content: Text("❌ Out of Stock"),
                                                                          backgroundColor: Colors.red,
                                                                        ),
                                                                      );
                                                                      return;
                                                                    }

                                                                    _isProgrammaticChange = true;

                                                                    dropdownController.value = TextEditingValue(
                                                                      text: digits,
                                                                      selection: TextSelection.collapsed(offset: digits.length),
                                                                    );

                                                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                                                      _setScannedProduct(match);
                                                                      scrollDown();
                                                                      _isProgrammaticChange = false;
                                                                    });

                                                                    // reset error memory on success
                                                                    _lastScannedCode = null;
                                                                    _lastErrorTime = null;

                                                                  } catch (_) {

                                                                    final now = DateTime.now();

                                                                    // 🔒 Prevent repeat error within 1 second for same barcode
                                                                    if (_lastScannedCode == digits &&
                                                                        _lastErrorTime != null &&
                                                                        now.difference(_lastErrorTime!) < const Duration(seconds: 1)) {
                                                                      return;
                                                                    }

                                                                    _lastScannedCode = digits;
                                                                    _lastErrorTime = now;

                                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                                      const SnackBar(
                                                                        content: Text("❌ Product not found"),
                                                                        backgroundColor: Colors.red,
                                                                      ),
                                                                    );
                                                                  }
                                                                });
                                                              },



                                                              //                                                    onScan: (code) {
                                                              //                                                      final billingProvider =
                                                              //                                                      Provider.of<BillingProvider>(context, listen: false);
                                                              //
                                                              //                                                      String onlyDigits(String s) =>
                                                              //                                                          s.replaceAll(RegExp(r'[^0-9]'), '');
                                                              //
                                                              //                                                      final digits = onlyDigits(code.trim());
                                                              //                                                      if (digits.length < 6) return;
                                                              //
                                                              //                                                      try {
                                                              //                                                        final match = billingProvider.productsList.firstWhere(
                                                              //                                                              (p) => p.barcode == digits,
                                                              //                                                        );
                                                              //    /// ❌ NOT FOUND
                                                              // ///   if (match == null) {
                                                              //
                                                              //                                                        final qty =
                                                              //                                                            double.tryParse(match.qtyLeft?.toString() ?? "0") ?? 0;
                                                              //
                                                              //                                                        // if (qty <= 0) {
                                                              //                                                        //   ScaffoldMessenger.of(context).showSnackBar(
                                                              //                                                        //     const SnackBar(
                                                              //                                                        //       content: Text("❌ Out of Stock"),
                                                              //                                                        //       backgroundColor: Colors.red,
                                                              //                                                        //     ),
                                                              //                                                        //   );
                                                              //                                                        //   return;
                                                              //                                                        // }
                                                              //
                                                              //                                                        _isProgrammaticChange = true;
                                                              //
                                                              //                                                        /// update text safely
                                                              //                                                        dropdownController.value = TextEditingValue(
                                                              //                                                          text: digits,
                                                              //                                                          selection: TextSelection.collapsed(offset: digits.length),
                                                              //                                                        );
                                                              //
                                                              //                                                        /// schedule logic AFTER frame (non blocking)
                                                              //                                                        WidgetsBinding.instance.addPostFrameCallback((_) {
                                                              //                                                          _setScannedProduct(match);
                                                              //                                                          scrollDown();
                                                              //                                                        });
                                                              //
                                                              //                                                      } catch (_) {
                                                              //                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                              //                                                          const SnackBar(
                                                              //                                                            content: Text("❌ Product not found"),
                                                              //                                                            backgroundColor: Colors.red,
                                                              //                                                          ),
                                                              //                                                        );
                                                              //                                                      }
                                                              //
                                                              //                                                      _isProgrammaticChange = false;
                                                              //                                                    },



                                                              // onSelected: (product) async {
                                                              //   bool isOutOfStock(ProductData p) {
                                                              //     final double qty =
                                                              //         double.tryParse(p.qtyLeft?.toString() ?? "0") ?? 0;
                                                              //     return qty <= 0;
                                                              //   }
                                                              //   // 🚫 BLOCK OUT OF STOCK SELECTION
                                                              //   if (isOutOfStock(product)) {
                                                              //     ScaffoldMessenger.of(context).showSnackBar(
                                                              //       const SnackBar(
                                                              //         content: Text("❌ Out of Stock"),
                                                              //         backgroundColor: Colors.red,
                                                              //       ),
                                                              //     );
                                                              //
                                                              //     dropdownController.clear();
                                                              //     billingProvider.selectedProduct = null;
                                                              //
                                                              //     Future.delayed(const Duration(milliseconds: 80), () {
                                                              //       billingProvider.dropdownFocusNode.requestFocus();
                                                              //     });
                                                              //
                                                              //     return; // ⛔ STOP HERE
                                                              //   }
                                                              //
                                                              //   // ✅ ALLOW ONLY IF STOCK AVAILABLE
                                                              //   billingProvider.selectedProduct = product;
                                                              //
                                                              //   billingProvider.updateTemporaryFields(
                                                              //     variation: product.isLoose == '1' ? 1.0 : null,
                                                              //     quantity: product.isLoose == '0' ? 1 : null,
                                                              //   );
                                                              //
                                                              //   dropdownController.text =
                                                              //   product.isLoose == '0'
                                                              //       ? '${product.pTitle} ${product.pVariation}${product.unit}'
                                                              //       : '${product.pTitle} (${product.pVariation})';
                                                              //
                                                              //   dropdownController.selection = TextSelection.fromPosition(
                                                              //     TextPosition(offset: dropdownController.text.length),
                                                              //   );
                                                              //
                                                              //   fieldFocusNode.requestFocus();
                                                              // },

                                                              onSelected: (product) async {
                                                                bool isOutOfStock(ProductData p) {
                                                                  final double qty =
                                                                      double.tryParse(p.qtyLeft?.toString() ?? "0") ?? 0;
                                                                  return qty <= 0;
                                                                }

                                                                // 🚫 BLOCK OUT OF STOCK SELECTION
                                                                if (isOutOfStock(product)) {
                                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                                    const SnackBar(
                                                                      content: Text("❌ Out of Stock"),
                                                                      backgroundColor: Colors.red,
                                                                    ),
                                                                  );

                                                                  safeClear(dropdownController);
                                                                  billingProvider.selectedProduct = null;

                                                                  Future.microtask(() {
                                                                    billingProvider.dropdownFocusNode.requestFocus();
                                                                    scrollDown();
                                                                  });

                                                                  return;
                                                                }

                                                                // ✅ ALLOW ONLY IF STOCK AVAILABLE
                                                                billingProvider.selectedProduct = product;

                                                                billingProvider.updateTemporaryFields(
                                                                  variation: product.isLoose == '1' ? 1.0 : null,
                                                                  quantity: product.isLoose == '0' ? 1 : null,
                                                                );

                                                                final displayText = product.isLoose == '0'
                                                                    ? '${product.pTitle} ${product.pVariation}${product.unit}'
                                                                    : '${product.pTitle} (${product.pVariation})';

                                                                // ✅ SAFE text + caret placement
                                                                dropdownController.value = TextEditingValue(
                                                                  text: displayText,
                                                                  selection: TextSelection.collapsed(offset: displayText.length),
                                                                );

                                                                // ✅ Delay focus change (prevents caret crash)
                                                                Future.microtask(() {
                                                                  fieldFocusNode.requestFocus();
                                                                  scrollDown();
                                                                });
                                                              },



                                                              // onSelected: (product) async {
                                                              //   billingProvider
                                                              //       .selectedProduct =
                                                              //       product;
                                                              //   billingProvider
                                                              //       .updateTemporaryFields(
                                                              //     variation: product
                                                              //         .isLoose == '1'
                                                              //         ? 1.0
                                                              //         : null,
                                                              //     quantity: product
                                                              //         .isLoose == '0'
                                                              //         ? 1
                                                              //         : null,
                                                              //   );
                                                              //
                                                              //   dropdownController.text =
                                                              //   product.isLoose == '0'
                                                              //       ? '${product
                                                              //       .pTitle} ${product
                                                              //       .pVariation}${product
                                                              //       .unit}'
                                                              //       : '${product
                                                              //       .pTitle} (${product
                                                              //       .pVariation})';
                                                              //
                                                              //   dropdownController
                                                              //       .selection =
                                                              //       TextSelection
                                                              //           .fromPosition(
                                                              //         TextPosition(
                                                              //             offset: dropdownController
                                                              //                 .text.length),
                                                              //       );
                                                              //
                                                              //   fieldFocusNode
                                                              //       .requestFocus();
                                                              // },
                                                              onClear: () {
                                                                billingProvider
                                                                    .selectedProduct = null;
                                                                billingProvider
                                                                    .updateTemporaryFields(
                                                                    quantity: 0,
                                                                    variation: 0.0);
                                                                safeClear(dropdownController);
                                                                safeClear(quantityVariationController);

                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                      ),

                                                      30.width,

                                                      ///quantity /variation entry
                                                      Container(
                                                        width: screenWidth*0.12,
                                                        alignment: Alignment.center,
                                                        child: MyTextField(
                                                          focusNode: fieldFocusNode,
                                                          height: 50,
                                                          controller: quantityVariationController,

                                                          hintText: billingProvider
                                                              .selectedProduct
                                                              ?.isLoose == '1'
                                                              ? "1.000"
                                                              : "1",
                                                          labelText: billingProvider
                                                              .selectedProduct
                                                              ?.isLoose == '1'
                                                              ? "variation"
                                                              : "Quantity",

                                                          keyboardType: TextInputType
                                                              .number,
                                                          inputFormatters: billingProvider
                                                              .selectedProduct
                                                              ?.isLoose == '1'
                                                              ? InputFormatters
                                                              .variationInput
                                                              : InputFormatters
                                                              .quantityInput,
                                                          // onTap: () {
                                                          //   if (billingProvider.selectedProduct != null &&
                                                          //       quantityVariationController.text.isEmpty) {
                                                          //     quantityVariationController.text =
                                                          //     billingProvider.selectedProduct!
                                                          //         .isLoose == '1'
                                                          //         ? "1.000"
                                                          //         : "1";
                                                          //     quantityVariationController.selection =
                                                          //         TextSelection(
                                                          //             baseOffset: 0,
                                                          //             extentOffset: quantityVariationController
                                                          //                 .text.length);
                                                          //   }
                                                          // },
                                                          // onChanged: (value) {
                                                          //   if (billingProvider
                                                          //       .selectedProduct ==
                                                          //       null) {
                                                          //     Toasts.showToastBar(
                                                          //         context: context,
                                                          //         text: "Please add product",
                                                          //         color: Colors.red);
                                                          //     return;
                                                          //   }
                                                          //   if (value.isEmpty) {
                                                          //     quantityVariationController.text =
                                                          //     billingProvider.selectedProduct!.isLoose == '1'
                                                          //         ? "1.000"
                                                          //         : "1";
                                                          //     quantityVariationController.selection =
                                                          //         TextSelection(
                                                          //             baseOffset: 0,
                                                          //             extentOffset: quantityVariationController
                                                          //                 .text.length);
                                                          //     return;
                                                          //   }
                                                          //   if (billingProvider
                                                          //       .selectedProduct!
                                                          //       .isLoose == '1') {
                                                          //     billingProvider
                                                          //         .updateTemporaryFields(
                                                          //         variation: (double
                                                          //             .parse(value) *
                                                          //             1000));
                                                          //   } else {
                                                          //     billingProvider
                                                          //         .updateTemporaryFields(
                                                          //         quantity: int
                                                          //             .tryParse(
                                                          //             value) ??
                                                          //             billingProvider
                                                          //                 .temporaryQuantity);
                                                          //   }
                                                          // },
                                                          onFieldSubmitted: (value) {
                                                            final billing = billingProvider;

                                                            // 1) Selected product must exist
                                                            final product = billing.selectedProduct;
                                                            bool isOutOfStock(ProductData p) {
                                                              final double qty =
                                                                  double.tryParse(p.qtyLeft?.toString() ?? "0") ?? 0;
                                                              return qty <= 0;
                                                            }
                                                            if (product == null) {
                                                              Toasts.showToastBar(
                                                                context: context,
                                                                text: "Please add product",
                                                                color: Colors.red,
                                                              );
                                                              return;
                                                            }
                                                            if (isOutOfStock(product)) {
                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                const SnackBar(
                                                                  content: Text("❌ Out of Stock"),
                                                                  backgroundColor: Colors.red,
                                                                ),
                                                              );
                                                              return;
                                                            }

                                                            // 2) Entered value cleanup
                                                            final enteredText = value.trim().isEmpty ? "1" : value.trim();

                                                            // 3) Safe parsing
                                                            final double parsedDouble = safeDouble(enteredText);
                                                            final int parsedInt = safeInt(enteredText);

                                                            // 4) Safe product values
                                                            final double stockQty = safeDouble(product.qtyLeft);
                                                            final double mrp = safeDouble(product.mrp);
                                                            final double outPrice = safeDouble(product.outPrice);

                                                            // ---------------------------------------------------
                                                            // PRODUCT EXISTS → UPDATE IT
                                                            // ---------------------------------------------------
                                                            final alreadyExists = billing.billingItems.any(
                                                                  (item) => item.id == product.id.toString(),
                                                            );

                                                            if (alreadyExists) {
                                                              final existingItem = billing.billingItems.firstWhere(
                                                                    (item) => item.id == product.id.toString(),
                                                              );

                                                              final double currentQty = product.isLoose == '1'
                                                                  ? existingItem.variation / 1000
                                                                  : existingItem.quantity.toDouble();

                                                              final double newQty = product.isLoose == '1'
                                                                  ? parsedDouble
                                                                  : parsedInt.toDouble();

                                                              final double totalQty = currentQty + newQty;
                                                              if (stockQty <= 0) {
                                                                Toasts.showToastBar(
                                                                  context: context,
                                                                  text: "Out of Stock",
                                                                  color: Colors.red,
                                                                );
                                                                return;
                                                              }

                                                              // STOCK CHECK
                                                              if (totalQty > stockQty) {
                                                                Toasts.showToastBar(
                                                                  context: context,
                                                                  text: "Stock limit reached! Available: $stockQty",
                                                                  color: Colors.red,
                                                                );

                                                                // 🔥 CLEAR EVERYTHING RELATED TO THIS PRODUCT
                                                                safeClear(quantityVariationController);
                                                                safeClear(dropdownController);

                                                                billing.selectedProduct = null;

                                                                // 🔥 MOVE FOCUS BACK TO PRODUCT FIELD
                                                                Future.microtask(() {
                                                                  billing.dropdownFocusNode.requestFocus();
                                                                });

                                                                return;
                                                              }
                                                              // UPDATE EXISTING ITEM
                                                              final index = billing.billingItems.indexOf(existingItem);

                                                              if (product.isLoose == '1') {
                                                                final double addQty = parsedDouble * 1000;
                                                                existingItem.variation += addQty;

                                                                billing.quantityControllers[index]!.text =
                                                                    (existingItem.variation / 1000).toStringAsFixed(3);

                                                              } else
                                                              {
                                                                existingItem.quantity += parsedInt;

                                                                billing.quantityControllers[index]!.text =
                                                                    existingItem.quantity.toString();
                                                              }

                                                              billing.updateExistingBillingItem(existingItem);
                                                              billing.notifyListeners();

                                                              // RESET
                                                              safeClear(quantityVariationController);
                                                              safeClear(dropdownController);
                                                              billing.selectedProduct = null;
                                                              Future.microtask(() {
                                                                billing.dropdownFocusNode.requestFocus();
                                                              });

                                                              return;
                                                            }

                                                            // ---------------------------------------------------
                                                            // ADD NEW PRODUCT
                                                            // ---------------------------------------------------
                                                            if (product.isLoose == '1') {
                                                              final double enteredKg = parsedDouble <= 0 ? 1.0 : parsedDouble;
                                                              final double enteredQty = enteredKg * 1000;
                                                              if (enteredQty > stockQty) {
                                                                Toasts.showToastBar(
                                                                  context: context,
                                                                  text: "Entered weight exceeds stock ($stockQty g).",
                                                                  color: Colors.red,
                                                                );
                                                                Future.microtask(() {
                                                                  fieldFocusNode.requestFocus();
                                                                });

                                                                return;
                                                              }

                                                              billing.addBillingItem(
                                                                BillingItem(
                                                                  id: product.id.toString(),
                                                                  product: product,
                                                                  productTitle: "${product.pTitle}",
                                                                  variation: enteredQty,
                                                                  variationUnit: "${product.pVariation}${product.unit}",
                                                                  quantity: 1,
                                                                  p_out_price: product.outPrice.toString(),
                                                                  p_mrp:product.mrp.toString(),
                                                                ),
                                                              );

                                                              final index = billing.billingItems.indexWhere(
                                                                      (item) => item.product.id == product.id.toString());

                                                              billing.quantityControllers[index]!.text =
                                                                  enteredKg.toStringAsFixed(3);

                                                            } else {
                                                              final int finalQty = parsedInt <= 0 ? 1 : parsedInt;
                                                              if (stockQty <= 0) {
                                                                Toasts.showToastBar(
                                                                  context: context,
                                                                  text: "Out of Stock",
                                                                  color: Colors.red,
                                                                );
                                                                return;
                                                              }

                                                              if (finalQty > stockQty) {
                                                                Toasts.showToastBar(
                                                                  context: context,
                                                                  text: "Entered quantity exceeds stock ($stockQty).",
                                                                  color: Colors.red,
                                                                );
                                                                Future.microtask(() {
                                                                  fieldFocusNode.requestFocus();
                                                                });

                                                                return;
                                                              }

                                                              billing.addBillingItem(
                                                                BillingItem(
                                                                  id: product.id.toString(),
                                                                  product: product,
                                                                  variation: 1,
                                                                  variationUnit: "${product.pVariation}${product.unit}",
                                                                  quantity: finalQty,
                                                                  productTitle: product.pTitle ?? "",
                                                                  p_out_price: product.outPrice.toString(),
                                                                  p_mrp:product.mrp.toString(),
                                                                ),
                                                              );
                                                            }

                                                            // ---------------------------------------------------
                                                            // FINAL RESET
                                                            // ---------------------------------------------------
                                                            safeClear(billing.barcodeScanner);
                                                            billing.selectedProduct = null;

                                                            WidgetsBinding.instance.addPostFrameCallback((_) {
                                                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                                                scrollDown();
                                                              });
                                                            });

                                                            safeClear(quantityVariationController);
                                                            safeClear(dropdownController);

                                                            Future.microtask(() {
                                                              billing.dropdownFocusNode.requestFocus();
                                                            });
                                                          },

                                                        ),
                                                      ),


                                                    ],
                                                  ),
                                                ),


                                                10.width,
                                              ],
                                            ),
                                          ),

                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0, right: 8, bottom: 1, top: 1),

                                            child: SizedBox(
                                              height: 49,
                                              width: screenWidth*0.12,
                                              child: ElevatedButton(
                                                focusNode: FocusNode(skipTraversal: true),
                                                onPressed: () async {
                                                  if (billingProvider.billingItems
                                                      .isEmpty) {
                                                    billingProvider.printButtonController
                                                        .reset();
                                                    Toasts.showToastBar(
                                                      context: context,
                                                      text: 'Bill List is empty',
                                                      color: Colors.red,
                                                    );
                                                    return;
                                                  }

                                                  final paymentMap = {
                                                    'UPI': '1',
                                                    'Paytm': '1',
                                                    'Split Payment': '5',
                                                    'Credit Card': '4',
                                                    'Cash': '2',
                                                    'Credit': '3',
                                                  };

                                                  final selectedMethod = billingProvider
                                                      .selectBillMethod ?? "Cash";
                                                  final paymentId = paymentMap[selectedMethod] ??
                                                      '0';

                                                  if (customerProvider.selectedCustomerId
                                                      .isEmpty) {
                                                    customerProvider.setCustomerDetails(
                                                      customerId: ProjectData.cash,
                                                      customerName: ProjectData.name,
                                                      customerMobile: ProjectData.mobile,
                                                      customerAddress: ProjectData
                                                          .address,
                                                    );
                                                  }

                                                  final now = DateTime.now();
                                                  final billNo = 'BILL${now
                                                      .millisecondsSinceEpoch % 10000}';
                                                  final formattedDate =
                                                      '${now.day}/${now.month}/${now
                                                      .year} ${now.hour}:${now.minute}';

                                                  await billingProvider
                                                      .saveHoldBillDetails(context: context,
                                                    order: Order(
                                                      split_pay: billingProvider
                                                          .selectBillMethod ==
                                                          "Split Payment"
                                                          ? (billingProvider.upiPayment
                                                          .text.isEmpty
                                                          ? "0"
                                                          : billingProvider.upiPayment
                                                          .text)
                                                          : "0",

                                                      id: billNo,
                                                      createdTs: formattedDate,
                                                      customerMobile: customerProvider
                                                          .selectedCustomerMobile,
                                                      customerId: customerProvider
                                                          .selectedCustomerId,
                                                      customerName: customerProvider.selectedCustomerName.isEmpty ? "Cash Customer" : customerProvider.selectedCustomerName,
                                                      customerAddress:
                                                      customerProvider
                                                          .customerAddressController.text,

                                                      cashier: controllers.storage.read("id"),
                                                      paymentMethod: selectedMethod,
                                                      paymentId: paymentId,

                                                      creditDays: selectedMethod ==
                                                          "Credit"
                                                          ? (billingProvider.creditDays ??
                                                          0)
                                                          : 0,

                                                      products: billingProvider
                                                          .billingItems,
                                                      orderGrandTotal:
                                                      billingProvider
                                                          .calculatedGrandTotal()
                                                          .toStringAsFixed(2),
                                                      orderSubTotal:
                                                      billingProvider
                                                          .calculatedGrandTotal()
                                                          .toStringAsFixed(2),

                                                      receivedAmt: billingProvider
                                                          .paymentReceived.text.isEmpty
                                                          ? "0.0"
                                                          : double.parse(
                                                          billingProvider.paymentReceived
                                                              .text)
                                                          .toStringAsFixed(2),

                                                      payBackAmt: (
                                                          selectedMethod == "Cash"
                                                              ? ((billingProvider
                                                              .paymentReceived.text
                                                              .isEmpty
                                                              ? 0.0
                                                              : double.parse(
                                                              billingProvider
                                                                  .paymentReceived
                                                                  .text)) -
                                                              billingProvider
                                                                  .calculatedGrandTotal())
                                                              .abs()
                                                              .toStringAsFixed(2)
                                                              : "0.00"
                                                      ),
                                                      version: "0.0",
                                                      savings:
                                                      '${billingProvider.billingItems
                                                          .fold(0.0, (t, i) =>
                                                      t + i.calculateDiscount())}',

                                                      billStatus: 0,
                                                      salesmanId: controllers.storage.read("id")
                                                          .toString(),
                                                    ),
                                                  );

                                                  Toasts.showToastBar(
                                                    context: context,
                                                    text: 'Bill saved to Hold successfully',
                                                    color: Colors.green,
                                                  );

                                                  billingProvider.printAfterChangeButtonControllerHold.reset();
                                                  billingProvider.billingItems.clear();
                                                  billingProvider.quantityControllers.clear();
                                                  billingProvider.notifyListeners();
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: AppColors
                                                      .textFieldBackground,
                                                  foregroundColor: AppColors.black,
                                                  elevation: 6,
                                                  shadowColor: Colors.black26,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(
                                                        20),
                                                    side: BorderSide(
                                                      color: Colors.black,
                                                      // subtle border
                                                      width: 0.8,
                                                    ),
                                                  ),
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 25, vertical: 10),
                                                ),
                                                child: MyText(
                                                  text: 'Hold Bill (F4)',
                                                  color: AppColors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: TextFormat.responsiveFontSize(
                                                      context, 18),
                                                ),
                                              ),
                                            ),
                                          ),  // Hold Bill
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0, right: 8, bottom: 1, top: 1),
                                            child: SizedBox(
                                              height: 49,
                                              width: screenWidth*0.12,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  if (billingProvider.billingItems
                                                      .isNotEmpty) {
                                                    showPaymentBalanceDialog(
                                                      context,
                                                      onPressPrint: () {
                                                        final paymentMap = {
                                                          'UPI': '1',
                                                          'Paytm': '1',
                                                          'Split Payment': '5',
                                                          'Credit Card': '4',
                                                          'Cash': '2',
                                                          'Credit': '3',
                                                        };
                                                        final selectedMethod =
                                                        billingProvider.selectBillMethod
                                                            .toString();
                                                        final paymentId = paymentMap[selectedMethod] ??
                                                            '0';

                                                        final billStatus = selectedMethod ==
                                                            'Credit' ? 0 : 1;

                                                        if (customerProvider
                                                            .selectedCustomerId.isEmpty) {
                                                          customerProvider
                                                              .setCustomerDetails(
                                                            customerId: ProjectData.cash,
                                                            customerName: ProjectData
                                                                .name,
                                                            customerMobile: ProjectData
                                                                .mobile,
                                                            customerAddress: ProjectData
                                                                .address,
                                                          );
                                                        }

                                                        billingProvider
                                                            .placeOrderAndSaveBill(
                                                          context,
                                                          order: Order(
                                                            split_pay: selectedMethod ==
                                                                "Split Payment"
                                                                ? (billingProvider
                                                                .upiPayment.text.isEmpty
                                                                ? "0"
                                                                : billingProvider
                                                                .upiPayment.text)
                                                                : "0",

                                                            customerMobile:
                                                            customerProvider
                                                                .selectedCustomerMobile,
                                                            customerId: customerProvider
                                                                .selectedCustomerId,
                                                            customerName: customerProvider.selectedCustomerName.isEmpty ? "Cash Customer" : customerProvider.selectedCustomerName,
                                                            customerAddress:
                                                            customerProvider
                                                                .customerAddressController
                                                                .text,

                                                            cashier: controllers.storage.read("id"),
                                                            paymentMethod: selectedMethod,
                                                            paymentId: paymentId,
                                                            salesmanId: controllers.storage.read("id")
                                                                .toString(),

                                                            creditDays: selectedMethod ==
                                                                "Credit"
                                                                ? (billingProvider
                                                                .creditDays ?? 0)
                                                                : 0,

                                                            products: billingProvider
                                                                .billingItems,
                                                            orderGrandTotal: billingProvider
                                                                .calculatedGrandTotal()
                                                                .toString(),
                                                            orderSubTotal: billingProvider
                                                                .calculatedGrandTotal()
                                                                .toString(),

                                                            receivedAmt:
                                                            billingProvider
                                                                .paymentReceived.text
                                                                .isEmpty
                                                                ? "0.0"
                                                                : double.parse(
                                                                billingProvider
                                                                    .paymentReceived.text)
                                                                .toStringAsFixed(1),

                                                            payBackAmt: (
                                                                selectedMethod == "Cash"
                                                                    ? ((billingProvider
                                                                    .paymentReceived.text
                                                                    .isEmpty
                                                                    ? 0.0
                                                                    : double.parse(
                                                                    billingProvider
                                                                        .paymentReceived
                                                                        .text)) -
                                                                    billingProvider
                                                                        .calculatedGrandTotal())
                                                                    .abs()
                                                                    .toStringAsFixed(2)
                                                                    : "0.00"
                                                            ),

                                                            savings:
                                                            '${billingProvider
                                                                .billingItems.fold(
                                                                0.0, (t, i) =>
                                                            t + i.calculateDiscount())}',
                                                            version: "0.0",
                                                            billStatus: billStatus,
                                                          ),
                                                        );
                                                      },
                                                      onPressPrintHold: () {},
                                                      onPressPrintSave: () async {
                                                        // =======================================
                                                        // 🔥 PREVENT MULTIPLE CALLS
                                                        // =======================================
                                                        // if (billingProvider.billingItems.isNotEmpty) {
                                                        if (_isPrinting) {
                                                          print("PRINT BLOCKED — ALREADY PRINTING");
                                                          return;
                                                        }

                                                        _isPrinting = true; // lock

                                                        final paymentMap = {
                                                          'UPI': '1',
                                                          'Paytm': '1',
                                                          'Split Payment': '5',
                                                          'Credit Card': '4',
                                                          'Cash': '2',
                                                          'Credit': '3',
                                                        };

                                                        final selectedMethod = billingProvider
                                                            .selectBillMethod.toString();
                                                        final paymentId = paymentMap[selectedMethod] ?? '0';

                                                        print(
                                                            "Payment Method: $selectedMethod, Payment ID: $paymentId");

                                                        final billStatus = selectedMethod == 'Credit'
                                                            ? 0
                                                            : 1;

                                                        // Assign default customer if empty
                                                        if (customerProvider.selectedCustomerId.isEmpty) {
                                                          customerProvider.setCustomerDetails(
                                                            customerId: ProjectData.cash,
                                                            customerName: ProjectData.name,
                                                            customerMobile: ProjectData.mobile,
                                                            customerAddress: ProjectData.address,
                                                          );
                                                        }

                                                        // =======================================
                                                        // 🔥 REAL PRINT — ONLY ONCE
                                                        // =======================================
                                                        await billingProvider.placeOrderAndSaveBill(
                                                          context,
                                                          order: Order(
                                                            split_pay: selectedMethod == "Split Payment"
                                                                ? (billingProvider.upiPayment.text.isEmpty
                                                                ? "0"
                                                                : billingProvider.upiPayment.text)
                                                                : "0",

                                                            customerMobile: customerProvider
                                                                .selectedCustomerMobile,
                                                            customerId: customerProvider.selectedCustomerId,
                                                            customerName: customerProvider.selectedCustomerName.isEmpty ? "Cash Customer" : customerProvider.selectedCustomerName,
                                                            customerAddress: customerProvider
                                                                .customerAddressController.text,
                                                            cashier: controllers.storage.read("id"),
                                                            paymentMethod: selectedMethod,
                                                            paymentId: paymentId,
                                                            creditDays:
                                                            selectedMethod == "Credit" ? (billingProvider
                                                                .creditDays ?? 0) : 0,
                                                            products: billingProvider.billingItems,
                                                            orderGrandTotal:
                                                            billingProvider
                                                                .calculatedGrandTotal()
                                                                .toString(),
                                                            orderSubTotal:
                                                            billingProvider
                                                                .calculatedGrandTotal()
                                                                .toString(),
                                                            receivedAmt: billingProvider.paymentReceived
                                                                .text.isEmpty
                                                                ? "0.0"
                                                                : double.parse(
                                                                billingProvider.paymentReceived.text)
                                                                .toStringAsFixed(0),
                                                            payBackAmt: selectedMethod == "Cash"
                                                                ? ((billingProvider.paymentReceived.text
                                                                .isEmpty
                                                                ? 0.0
                                                                : double.parse(
                                                                billingProvider.paymentReceived.text)) -
                                                                billingProvider.calculatedGrandTotal())
                                                                .abs()
                                                                .toStringAsFixed(2)
                                                                : "0.00",
                                                            savings:
                                                            '${billingProvider.billingItems.fold(
                                                                0.0, (total, item) =>
                                                            total + item.calculateDiscount())}',
                                                            billStatus: billStatus,
                                                            salesmanId: controllers.storage.read("id").toString(),
                                                            version: "0.0",
                                                          ),
                                                        );

                                                        // Unlock print after attempt
                                                        _isPrinting = false;
                                                      },
                                                    );
                                                  } else {
                                                    billingProvider.printButtonController
                                                        .reset();
                                                    Toasts.showToastBar(
                                                        context: context,
                                                        text: 'Bill List is empty',
                                                        color: Colors.red);
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: AppColors
                                                      .textFieldBackground,
                                                  foregroundColor: AppColors.black,
                                                  elevation: 3,
                                                  shadowColor: Colors.black26,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(
                                                        23),
                                                    side: BorderSide(
                                                      color: Colors.black,
                                                      width: 0.8,
                                                    ),
                                                  ),
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 25, vertical: 10),
                                                ),
                                                child: MyText(
                                                  text: 'Save Bill (TAB)',
                                                  color: AppColors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: TextFormat.responsiveFontSize(
                                                      context, 18),

                                                  letterSpacing: 1.2,
                                                ),
                                              ),
                                            ),
                                          ),  //  Save bill
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0, right: 8, bottom: 1, top: 1),
                                            child: SizedBox(
                                              height: 49,
                                              width: screenWidth*0.12,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  if (billingProvider.billingItems
                                                      .isNotEmpty) {
                                                    showPaymentBalanceDialog(
                                                      context,
                                                      onPressPrint: () {
                                                        final paymentMap = {
                                                          'UPI': '1',
                                                          'Paytm': '1',
                                                          'Split Payment': '5',
                                                          'Credit Card': '4',
                                                          'Cash': '2',
                                                          'Credit': '3',
                                                        };
                                                        final selectedMethod =
                                                        billingProvider.selectBillMethod
                                                            .toString();
                                                        final paymentId = paymentMap[selectedMethod] ??
                                                            '0';

                                                        final billStatus = selectedMethod ==
                                                            'Credit' ? 0 : 1;

                                                        if (customerProvider
                                                            .selectedCustomerId.isEmpty) {
                                                          customerProvider
                                                              .setCustomerDetails(
                                                            customerId: ProjectData.cash,
                                                            customerName: ProjectData
                                                                .name,
                                                            customerMobile: ProjectData
                                                                .mobile,
                                                            customerAddress: ProjectData
                                                                .address,
                                                          );
                                                        }

                                                        billingProvider
                                                            .placeOrderAndPrintBill(
                                                          context,
                                                          order: Order(
                                                            split_pay: selectedMethod ==
                                                                "Split Payment"
                                                                ? (billingProvider
                                                                .upiPayment.text.isEmpty
                                                                ? "0"
                                                                : billingProvider
                                                                .upiPayment.text)
                                                                : "0",

                                                            customerMobile:
                                                            customerProvider
                                                                .selectedCustomerMobile,
                                                            customerId: customerProvider
                                                                .selectedCustomerId,
                                                            customerName: customerProvider.selectedCustomerName.isEmpty ? "Cash Customer" : customerProvider.selectedCustomerName,
                                                            customerAddress:
                                                            customerProvider
                                                                .customerAddressController
                                                                .text,

                                                            cashier: controllers.storage.read("id"),
                                                            paymentMethod: selectedMethod,
                                                            paymentId: paymentId,
                                                            salesmanId: controllers.storage.read("id")
                                                                .toString(),

                                                            creditDays: selectedMethod ==
                                                                "Credit"
                                                                ? (billingProvider
                                                                .creditDays ?? 0)
                                                                : 0,

                                                            products: billingProvider
                                                                .billingItems,
                                                            orderGrandTotal: billingProvider
                                                                .calculatedGrandTotal()
                                                                .toString(),
                                                            orderSubTotal: billingProvider
                                                                .calculatedGrandTotal()
                                                                .toString(),

                                                            receivedAmt:
                                                            billingProvider
                                                                .paymentReceived.text
                                                                .isEmpty
                                                                ? "0.0"
                                                                : double.parse(
                                                                billingProvider
                                                                    .paymentReceived.text)
                                                                .toStringAsFixed(1),

                                                            payBackAmt: (
                                                                selectedMethod == "Cash"
                                                                    ? ((billingProvider
                                                                    .paymentReceived.text
                                                                    .isEmpty
                                                                    ? 0.0
                                                                    : double.parse(
                                                                    billingProvider
                                                                        .paymentReceived
                                                                        .text)) -
                                                                    billingProvider
                                                                        .calculatedGrandTotal())
                                                                    .abs()
                                                                    .toStringAsFixed(2)
                                                                    : "0.00"
                                                            ),

                                                            savings:
                                                            '${billingProvider
                                                                .billingItems.fold(
                                                                0.0, (t, i) =>
                                                            t + i.calculateDiscount())}',

                                                            billStatus: billStatus,
                                                            version: "0.0",
                                                          ),
                                                        );
                                                      },
                                                      onPressPrintHold: () {},
                                                      onPressPrintSave: () async {
                                                        // =======================================
                                                        // 🔥 PREVENT MULTIPLE CALLS
                                                        // =======================================
                                                        // if (billingProvider.billingItems.isNotEmpty) {
                                                        if (_isPrinting) {
                                                          print("PRINT BLOCKED — ALREADY PRINTING");
                                                          return;
                                                        }

                                                        _isPrinting = true; // lock

                                                        final paymentMap = {
                                                          'UPI': '1',
                                                          'Paytm': '1',
                                                          'Split Payment': '5',
                                                          'Credit Card': '4',
                                                          'Cash': '2',
                                                          'Credit': '3',
                                                        };

                                                        final selectedMethod = billingProvider
                                                            .selectBillMethod.toString();
                                                        final paymentId = paymentMap[selectedMethod] ?? '0';

                                                        print(
                                                            "Payment Method: $selectedMethod, Payment ID: $paymentId");

                                                        final billStatus = selectedMethod == 'Credit'
                                                            ? 0
                                                            : 1;

                                                        // Assign default customer if empty
                                                        if (customerProvider.selectedCustomerId.isEmpty) {
                                                          customerProvider.setCustomerDetails(
                                                            customerId: ProjectData.cash,
                                                            customerName: ProjectData.name,
                                                            customerMobile: ProjectData.mobile,
                                                            customerAddress: ProjectData.address,
                                                          );
                                                        }

                                                        // =======================================
                                                        // 🔥 REAL PRINT — ONLY ONCE
                                                        // =======================================
                                                        await billingProvider.placeOrderAndSaveBill(
                                                          context,
                                                          order: Order(
                                                            split_pay: selectedMethod == "Split Payment"
                                                                ? (billingProvider.upiPayment.text.isEmpty
                                                                ? "0"
                                                                : billingProvider.upiPayment.text)
                                                                : "0",

                                                            customerMobile: customerProvider
                                                                .selectedCustomerMobile,
                                                            customerId: customerProvider.selectedCustomerId,
                                                            customerName: customerProvider.selectedCustomerName.isEmpty ? "Cash Customer" : customerProvider.selectedCustomerName,
                                                            customerAddress: customerProvider
                                                                .customerAddressController.text,
                                                            cashier: controllers.storage.read("id"),
                                                            paymentMethod: selectedMethod,
                                                            paymentId: paymentId,
                                                            creditDays:
                                                            selectedMethod == "Credit" ? (billingProvider
                                                                .creditDays ?? 0) : 0,
                                                            products: billingProvider.billingItems,
                                                            orderGrandTotal:
                                                            billingProvider
                                                                .calculatedGrandTotal()
                                                                .toString(),
                                                            orderSubTotal:
                                                            billingProvider
                                                                .calculatedGrandTotal()
                                                                .toString(),
                                                            receivedAmt: billingProvider.paymentReceived
                                                                .text.isEmpty
                                                                ? "0.0"
                                                                : double.parse(
                                                                billingProvider.paymentReceived.text)
                                                                .toStringAsFixed(0),
                                                            payBackAmt: selectedMethod == "Cash"
                                                                ? ((billingProvider.paymentReceived.text
                                                                .isEmpty
                                                                ? 0.0
                                                                : double.parse(
                                                                billingProvider.paymentReceived.text)) -
                                                                billingProvider.calculatedGrandTotal())
                                                                .abs()
                                                                .toStringAsFixed(2)
                                                                : "0.00",
                                                            savings:
                                                            '${billingProvider.billingItems.fold(
                                                                0.0, (total, item) =>
                                                            total + item.calculateDiscount())}',
                                                            billStatus: billStatus,
                                                            salesmanId: controllers.storage.read("id").toString(),
                                                            version: "0.0",
                                                          ),
                                                        );

                                                        // Unlock print after attempt
                                                        _isPrinting = false;
                                                      },
                                                    );
                                                  } else {
                                                    billingProvider.printButtonController
                                                        .reset();
                                                    Toasts.showToastBar(
                                                        context: context,
                                                        text: 'Bill List is empty',
                                                        color: Colors.red);
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: AppColors
                                                      .textFieldBackground,
                                                  foregroundColor: AppColors.black,
                                                  elevation: 3,
                                                  shadowColor: Colors.black26,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(
                                                        23),
                                                    side: BorderSide(
                                                      color: Colors.black,
                                                      width: 0.8,
                                                    ),
                                                  ),
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 25, vertical: 10),
                                                ),
                                                child: MyText(
                                                  text: 'Print Bill (F1)',
                                                  color: AppColors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: TextFormat.responsiveFontSize(
                                                      context, 18),

                                                  letterSpacing: 1.2,
                                                ),
                                              ),
                                            ),
                                          ),

                                        ],
                                      ),

                                      ///  Billing Table :
                                      Expanded(
                                        child: Card(
                                          elevation: 4,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: Container(
                                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                                              child: Column(
                                                children: [
                                                  // ===========================
                                                  // HEADER
                                                  // ===========================
                                                  Table(
                                                    border: TableBorder(
                                                      top: const BorderSide(color: Colors.black26, width: 1),
                                                      bottom: const BorderSide(color: Colors.black26, width: 1),
                                                      left: const BorderSide(color: Colors.black26, width: 1),
                                                      right: const BorderSide(color: Colors.black26, width: 1),
                                                      horizontalInside: const BorderSide(color: Colors.black26, width: 1),
                                                      verticalInside: const BorderSide(color: Colors.black26, width: 1),
                                                    ),
                                                    columnWidths: const {
                                                      0: FixedColumnWidth(70),//s no
                                                      1: FlexColumnWidth(5),//ptp
                                                      2: FixedColumnWidth(80),//var
                                                      3: FixedColumnWidth(80),//qty
                                                      // 4: FixedColumnWidth(100),//tot sto
                                                      5: FlexColumnWidth(2),//mrp
                                                      6: FlexColumnWidth(1),//op
                                                      7: FlexColumnWidth(2),//dic
                                                      8: FlexColumnWidth(1),//st
                                                    },
                                                    children: [
                                                      TableRow(
                                                        decoration: BoxDecoration(color: colorsConst.primary),
                                                        children: [
                                                          _buildHeaderCell("S.N"),
                                                          _buildHeaderCell("Product"),
                                                          // _buildCell("Product"),
                                                          _buildHeaderCell("Vari"),
                                                          _buildHeaderCell("Qty"),
                                                          // _buildRightHeaderCell("Tot Sto"),
                                                          _buildRightHeaderCell("MRP"),
                                                          _buildRightHeaderCell("Our Price"),
                                                          _buildRightHeaderCell("Disc"),
                                                          _buildRightHeaderCell("Sub Tot"),
                                                        ],
                                                      ),
                                                    ],
                                                  ),

                                                  // ===========================
                                                  //     BILLING LIST
                                                  // ===========================
                                                  Expanded(
                                                    child: billingProvider.billingItems.isNotEmpty
                                                        ? ListView.builder(
                                                      controller: scrollController,
                                                      itemCount: billingProvider.billingItems.length,
                                                      itemBuilder: (context, index) {

                                                        // --- ALWAYS sync qtyFocusNodes with items ---
                                                        if (qtyFocusNodes.length != billingProvider.billingItems.length) {
                                                          qtyFocusNodes = List.generate(
                                                            billingProvider.billingItems.length,
                                                                (_) => FocusNode(),
                                                          );
                                                        }

                                                        final billProduct = billingProvider.billingItems[index];
                                                        final productData = billingProvider.productsList.firstWhere(
                                                              (p) => p.id == billProduct.product.id,
                                                          orElse: () => billProduct.product,
                                                        );
                                                        if (billingProvider.quantityControllers.length <= index) {
                                                          billingProvider.quantityControllers.add(TextEditingController(text: billProduct.quantity.toString().isEmpty?"1":billProduct.quantity.toString()=='null'?"1":billProduct.quantity.toString()));
                                                        }
                                                        return Table(
                                                          border: TableBorder(
                                                            top: const BorderSide(color: Colors.black26, width: 1),
                                                            bottom: const BorderSide(color: Colors.black26, width: 1),
                                                            left: const BorderSide(color: Colors.black26, width: 1),
                                                            right: const BorderSide(color: Colors.black26, width: 1),
                                                            horizontalInside: const BorderSide(color: Colors.black26, width: 1),
                                                            verticalInside: const BorderSide(color: Colors.black26, width: 1),
                                                          ),
                                                          columnWidths: const {
                                                            0: FixedColumnWidth(70),//s no
                                                            1: FlexColumnWidth(5),//ptp
                                                            2: FixedColumnWidth(80),//var
                                                            3: FixedColumnWidth(80),//qty
                                                            // 4: FixedColumnWidth(100),//tot sto
                                                            5: FlexColumnWidth(2),//mrp
                                                            6: FlexColumnWidth(1),//op
                                                            7: FlexColumnWidth(2),//dic
                                                            8: FlexColumnWidth(1),//st
                                                          },
                                                          children: [
                                                            TableRow(
                                                              decoration: BoxDecoration(
                                                                color: selectedRowIndex == index
                                                                    ? Colors.yellow.shade200
                                                                    : Colors.white,
                                                              ),
                                                              children: [
                                                                _buildCell("${index + 1}"),

                                                                Padding(
                                                                  padding: const EdgeInsets.symmetric(vertical: 1),
                                                                  child: Row(
                                                                    children: [
                                                                      Expanded(
                                                                        child: Padding(
                                                                          padding: const EdgeInsets.only(left: 15.0),
                                                                          child: MyText(
                                                                            text: billProduct.product.isLoose == '1'
                                                                                ? billProduct.product.pTitle!
                                                                                : "${billProduct.product.pTitle} "
                                                                                "${billProduct.product.pVariation ?? ""}"
                                                                                "${billProduct.product.unit ?? ""}",
                                                                            fontSize: 20,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      IconButton(
                                                                        icon: const Icon(Icons.delete_forever, color: Colors.black),
                                                                        onPressed: () {
                                                                          billingProvider.removeBillingItem(index: index);
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),


                                                                billProduct.product.isLoose == '1'
                                                                    ? TextField(
                                                                  focusNode: qtyFocusNodes[index],
                                                                  controller: billingProvider.quantityControllers[index]!,
                                                                  textAlign: TextAlign.center,
                                                                  keyboardType:
                                                                  const TextInputType.numberWithOptions(decimal: true),

                                                                  inputFormatters: [
                                                                    FilteringTextInputFormatter.allow(
                                                                      RegExp(r'^\d*\.?\d{0,3}'),
                                                                    ),
                                                                  ],

                                                                  style: const TextStyle(fontSize: 21),

                                                                  decoration: const InputDecoration(
                                                                    isDense: true,
                                                                    border: InputBorder.none,
                                                                    enabledBorder: InputBorder.none,
                                                                    focusedBorder: InputBorder.none,
                                                                    contentPadding: EdgeInsets.symmetric(
                                                                      vertical: 6,
                                                                      horizontal: 6,
                                                                    ),),

                                                                  // 🔹 USER TYPING (ALLOW EMPTY)
                                                                  onChanged: (value) {
                                                                    // allow empty while typing
                                                                    if (value.isEmpty) {
                                                                      billingProvider.updateBillingItem(
                                                                        index,
                                                                        isLoose: '1',
                                                                        variation: 0, // temp
                                                                      );
                                                                      return;
                                                                    }

                                                                    final controller =
                                                                    billingProvider.quantityControllers[index]!;

                                                                    final double enteredKg = double.tryParse(value) ?? 0;

                                                                    final double maxKg =
                                                                        (double.tryParse(billProduct.product.qtyLeft ?? "0") ??
                                                                            0) /
                                                                            1000;

                                                                    double safeKg = enteredKg;

                                                                    // 🔥 STOCK LIMIT
                                                                    if (enteredKg > maxKg) {
                                                                      safeKg = maxKg;

                                                                      final fixedText = safeKg.toStringAsFixed(3);

                                                                      if (controller.text != fixedText) {
                                                                        controller.value = controller.value.copyWith(
                                                                          text: fixedText,
                                                                          selection:
                                                                          TextSelection.collapsed(offset: fixedText.length),
                                                                          composing: TextRange.empty,
                                                                        );
                                                                      }
                                                                    }

                                                                    // update provider in grams
                                                                    billingProvider.updateBillingItem(
                                                                      index,
                                                                      isLoose: '1',
                                                                      variation: safeKg * 1000,
                                                                    );
                                                                  },

                                                                  // 🔹 USER FINISHED → APPLY DEFAULT
                                                                  onEditingComplete: () {
                                                                    _applyDefaultLooseIfNeeded(
                                                                      billingProvider,
                                                                      index,
                                                                    );
                                                                    Future.microtask(() {
                                                                      billingProvider.dropdownFocusNode.requestFocus();
                                                                    });
                                                                  },

                                                                  onSubmitted: (_) {
                                                                    _applyDefaultLooseIfNeeded(
                                                                      billingProvider,
                                                                      index,
                                                                    );
                                                                    Future.microtask(() {
                                                                      billingProvider.dropdownFocusNode.requestFocus();
                                                                    });
                                                                  },
                                                                )
                                                                    : _buildCell(
                                                                  billProduct.variationUnit == "nullnull"
                                                                      ? ""
                                                                      : billProduct.variationUnit,
                                                                ),


                                                                //cahnge qty
                                                                billProduct.product.isLoose == '0'
                                                                    ? TextField(
                                                                  focusNode: qtyFocusNodes[index],
                                                                  controller: billingProvider.quantityControllers[index]!,
                                                                  textAlign: TextAlign.center,
                                                                  keyboardType: TextInputType.number,
                                                                  style: const TextStyle(fontSize: 21),
                                                                  decoration: const InputDecoration(
                                                                    isDense: true,
                                                                    border: InputBorder.none,
                                                                    enabledBorder: InputBorder.none,
                                                                    focusedBorder: InputBorder.none,
                                                                    contentPadding: EdgeInsets.symmetric(
                                                                      vertical: 6,
                                                                      horizontal: 6,
                                                                    ),
                                                                  ),

                                                                  // 🔹 USER TYPING — ALLOW EMPTY / 0
                                                                  onChanged: (value) {
                                                                    // allow empty while typing
                                                                    if (value.isEmpty) {
                                                                      billingProvider.updateBillingItem(
                                                                        index,
                                                                        isLoose: '0',
                                                                        quantity: 0, // temp
                                                                      );
                                                                      return;
                                                                    }

                                                                    int qty = int.tryParse(value) ?? 0;

                                                                    // allow 0 while typing
                                                                    if (qty < 0) qty = 0;

                                                                    // stock limit
                                                                    final int maxQty =
                                                                        int.tryParse(billProduct.product.qtyLeft ?? "0") ?? 0;

                                                                    if (qty > maxQty) {
                                                                      qty = maxQty;

                                                                      final controller =
                                                                      billingProvider.quantityControllers[index]!;

                                                                      final fixedText = qty.toString();

                                                                      // cursor-safe update
                                                                      if (controller.text != fixedText) {
                                                                        controller.value = controller.value.copyWith(
                                                                          text: fixedText,
                                                                          selection:
                                                                          TextSelection.collapsed(offset: fixedText.length),
                                                                          composing: TextRange.empty,
                                                                        );
                                                                      }
                                                                    }

                                                                    // update provider
                                                                    billingProvider.updateBillingItem(
                                                                      index,
                                                                      isLoose: '0',
                                                                      quantity: qty,
                                                                    );
                                                                  },

                                                                  // 🔹 USER FINISHED → APPLY DEFAULT
                                                                  // 🔹 Enter pressed
                                                                  onEditingComplete: () {
                                                                    _applyDefaultQtyIfNeeded(billingProvider, index);
                                                                    qtyFocusNodes[index].unfocus();

                                                                    Future.microtask(() {
                                                                      Future.microtask(() {
                                                                        billingProvider.dropdownFocusNode.requestFocus();
                                                                      });
                                                                    });
                                                                  },

                                                                  onSubmitted: (_) {
                                                                    _applyDefaultQtyIfNeeded(billingProvider, index);
                                                                    qtyFocusNodes[index].unfocus();

                                                                    Future.microtask(() {
                                                                      billingProvider.dropdownFocusNode.requestFocus();
                                                                    });
                                                                  },

                                                                )
                                                                    : _buildCellQuantity("${1}"),

                                                                _buildBoldCell(
                                                                  TextFormat.formattedAmount(
                                                                    billProduct.mrpPerProduct(),
                                                                  ),
                                                                ),
                                                                _buildRedBoldCell(
                                                                  TextFormat.formattedAmount(
                                                                    billProduct.calculateOutPrice(),
                                                                  ),
                                                                ),
                                                                _buildRightCell(
                                                                  billProduct.calculateDiscount().toStringAsFixed(2),
                                                                ),
                                                                _buildBoldCell(
                                                                  TextFormat.formattedAmount(
                                                                    billProduct.calculateSubtotal(),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    )
                                                        : ScreenWidgets.emptyAlert(
                                                      context,
                                                      image: 'assets/bill/empty_bill.png',
                                                      text: '',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),30.height,
                                      billingProvider.isLoading ? 0.height
                                      : Container(
                                        width:controllers.isLeftOpen.value?MediaQuery.of(context).size.width - 150:MediaQuery.of(context).size.width - 60,
                                        color: colorsConst.primary.withOpacity(0.1),
                                        // padding: const EdgeInsets.only(
                                        //     top: 8, left: 12, right: 12, bottom: 8),
                                        height: screenHeight * 0.14,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            BottomWidgets.valueCard(context: context,
                                                title: 'Items',
                                                value: billingProvider
                                                    .calculatedTotalProducts()
                                                    .toString(),
                                                isBold: false),
                                            BottomWidgets.valueCard(context: context,
                                                title: 'Qty',
                                                value: billingProvider
                                                    .calculatedTotalQuantity()
                                                    .toString(),
                                                isBold: false),
                                            BottomWidgets.valueCard(context: context,
                                                title: 'MRP',
                                                value: billingProvider
                                                    .calculatedMrpSubtotal()
                                                    .toString(),
                                                isBold: false),
                                            BottomWidgets.valueCard(context: context,
                                                title: 'Discount',
                                                value: billingProvider.calculateTotalDiscount(),
                                                isBold: false),
                                            BottomWidgets.valueCard(context: context,
                                                title: 'GST',
                                                value: '0.0%',
                                                isBold: false),
                                            BottomWidgets.valueRight(
                                              context: context,
                                              title: 'Grand Total',
                                              value: TextFormat.formattedAmount(
                                                  billingProvider.calculatedGrandTotal()),
                                              isBold: true,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
            ),
          );
        }
    );
  }



  Future<void> showPaymentBalanceDialog(
      BuildContext context, {
        required void Function() onPressPrint,
        required void Function() onPressPrintSave,
        required void Function() onPressPrintHold,
      })
  async {
    final billingProvider =
    Provider.of<BillingProvider>(context, listen: false);

    // ================= RESET =================
    billingProvider.selectBillMethod = "Cash";
    billingProvider.selectedCreditPeriod = null;
    billingProvider.creditDays = null;
    billingProvider.paymentReceived.clear();
    billingProvider.upiPayment.clear();

    // ================= FOCUS NODES =================
    final FocusNode dialogFocusNode = FocusNode();
    final FocusNode cashFocus = FocusNode();
    final FocusNode upiFocus = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      cashFocus.requestFocus(); // ✅ ONLY ONE FOCUS
    });

    // ================= LISTENERS =================
    billingProvider.paymentReceived
        .addListener(billingProvider.calculatePaymentBalance);
    billingProvider.upiPayment
        .addListener(billingProvider.calculatePaymentBalance);

    final double total = billingProvider.calculatedGrandTotal();
    billingProvider.paymentReceived.text = total.toStringAsFixed(2);

    billingProvider.paymentReceived.selection = TextSelection(
      baseOffset: 0,
      extentOffset: billingProvider.paymentReceived.text.length,
    );
    bool _updatingSplit = false;

    void updateSplitFromUpi(double total) {
      if (_updatingSplit) return;
      _updatingSplit = true;

      final upi = double.tryParse(billingProvider.upiPayment.text) ?? 0.0;
      final cash = (total - upi).clamp(0, total);

      billingProvider.paymentReceived.text = cash.toStringAsFixed(2);

      billingProvider.calculatePaymentBalance();
      _updatingSplit = false;
    }

    void updateSplitFromCash(double total) {
      if (_updatingSplit) return;
      _updatingSplit = true;

      final cash = double.tryParse(billingProvider.paymentReceived.text) ?? 0.0;
      final upi = (total - cash).clamp(0, total);

      billingProvider.upiPayment.text = upi.toStringAsFixed(2);

      billingProvider.calculatePaymentBalance();
      _updatingSplit = false;
    }


    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Consumer2<BillingProvider, CustomersProvider>(
              builder: (context, billingProvider, customerProvider, _) {
                // ================= ARROW METHOD UPDATE =================
                void updateMethod(int newIndex) {
                  int index = newIndex;

                  for (int i = 0;
                  i < billingProvider.billMethods.length;
                  i++) {
                    final method = billingProvider.billMethods[index];

                    if (method == "Credit" &&
                        (localData.secretCode == null ||
                            localData.secretCode!.trim().isEmpty)) {
                      index =
                          (index + 1) % billingProvider.billMethods.length;
                      continue;
                    }

                    setState(() {
                      billingProvider.changeBillMethod(method);

                      if (method == "Paytm") {
                        generateQR(
                            billingProvider.calculatedGrandTotal());
                        dialogFocusNode.requestFocus(); // ✅ QR → no input focus
                      } else {
                        qrData = null;
                        if (method == "Cash") {
                          cashFocus.requestFocus();
                        } else if (method == "Split Payment") {
                          upiFocus.requestFocus();
                        } else {
                          cashFocus.requestFocus();
                        }
                      }
                    });
                    break;
                  }
                }

                return AlertDialog(
                  title: MyText(
                    text: 'Print Bill',
                    fontSize:
                    TextFormat.responsiveFontSize(context, 27),
                    fontWeight: FontWeight.bold,
                    textAlign: TextAlign.center,
                  ),

                  // ================= KEYBOARD =================
                  content: KeyboardListener(
                    focusNode: dialogFocusNode,
                    onKeyEvent: (event) {
                      if (event is! KeyDownEvent) return;

                      final currentIndex = billingProvider.billMethods
                          .indexOf(billingProvider.selectBillMethod ?? "");

                      // ================= ESC =================
                      if (event.logicalKey == LogicalKeyboardKey.escape) {
                        Navigator.pop(context);
                        Future.delayed(const Duration(milliseconds: 100), () {
                          billingProvider.dropdownFocusNode.requestFocus();
                        });
                        return;
                      }

                      // ================= ENTER → PRINT =================
                      if (event.logicalKey == LogicalKeyboardKey.enter) {
                        billingProvider.printAfterChangeButtonController.start();
                        onPressPrint();
                        Navigator.pop(context);
                        return;
                      }

                      // ================= TAB → SAVE =================
                      if (event.logicalKey == LogicalKeyboardKey.tab) {
                        billingProvider.printAfterChangeButtonControllerSave.start();
                        onPressPrintSave();
                        Navigator.pop(context);
                        return;
                      }

                      // ================= NEXT PAYMENT =================
                      if (
                      event.logicalKey == LogicalKeyboardKey.arrowRight
                      // ||
                      // event.logicalKey == LogicalKeyboardKey.arrowDown
                      )
                      {

                        // 🔥 IMPORTANT: remove input focus
                        cashFocus.unfocus();
                        upiFocus.unfocus();
                        Future.microtask(() {
                          dialogFocusNode.requestFocus();
                        });


                        updateMethod(
                          (currentIndex + 1) % billingProvider.billMethods.length,
                        );
                        return;
                      }

                      // ================= PREVIOUS PAYMENT =================
                      if (event.logicalKey == LogicalKeyboardKey.arrowLeft
                      // ||
                      // event.logicalKey == LogicalKeyboardKey.arrowUp
                      ) {

                        // 🔥 IMPORTANT: remove input focus
                        cashFocus.unfocus();
                        upiFocus.unfocus();
                        Future.microtask(() {
                          dialogFocusNode.requestFocus();
                        });

                        updateMethod(
                          (currentIndex - 1 + billingProvider.billMethods.length) %
                              billingProvider.billMethods.length,
                        );
                        return;
                      }
                    },


                    child: SizedBox(
                      height:
                      MediaQuery.of(context).size.height * 0.45,
                      child: Column(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceEvenly,
                        children: [
                          // ================= TOTAL =================
                          RichText(
                            text: TextSpan(
                              text: 'Total Amount : ',
                              style: GoogleFonts.lato(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                              children: [
                                TextSpan(
                                  text:
                                  TextFormat.formattedAmount(
                                      billingProvider
                                          .calculatedGrandTotal()),
                                  style: GoogleFonts.lato(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const MyText(
                              text: "Select Payment Method",
                              fontSize: 22,
                              fontWeight: FontWeight.bold),

                          // ================= PAYMENT METHODS =================
                          Row(
                            children: List.generate(
                              billingProvider.billMethods.length,
                                  (index) {
                                final method =
                                billingProvider.billMethods[index];
                                return Row(
                                  children: [
                                    Radio<String>(
                                      value: method,
                                      groupValue: billingProvider
                                          .selectBillMethod,
                                      focusNode: null, // ✅ NO RADIO FOCUS
                                      onChanged: (value) {
                                        if (value == "Credit" &&
                                            (localData.secretCode ==
                                                null ||
                                                localData.secretCode!
                                                    .trim()
                                                    .isEmpty)) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  "No credit access"),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          return;
                                        }

                                        setState(() {
                                          billingProvider
                                              .changeBillMethod(
                                              value!);

                                          if (value == "Paytm") {
                                            generateQR(billingProvider
                                                .calculatedGrandTotal());
                                            dialogFocusNode
                                                .requestFocus();
                                          } else {
                                            qrData = null;
                                            if (value == "Cash") {
                                              cashFocus
                                                  .requestFocus();
                                            }
                                          }
                                        });
                                      },
                                    ),
                                    MyText(text: method, fontSize: 18),
                                  ],
                                );
                              },
                            ),
                          ),

                          // ================= CASH =================
                          if (billingProvider.selectBillMethod ==
                              "Cash")
                            Column(
                              children: [
                                MyTextField(
                                  labelText: "Payment Received",
                                  focusNode: cashFocus,
                                  controller:
                                  billingProvider.paymentReceived,
                                  onFieldSubmitted: (_) {
                                    billingProvider
                                        .printAfterChangeButtonController
                                        .start();
                                    onPressPrint();
                                    Navigator.pop(context);
                                  },
                                ),
                                ValueListenableBuilder<TextEditingValue>(
                                  valueListenable: billingProvider.paymentBalance,
                                  builder: (context, value, child) {
                                    double balance = double.tryParse(value.text) ?? 0.0;
                                    bool positive = balance <= 0; // paid / extra

                                    return RichText(
                                      text: TextSpan(
                                        text: "Balance: ",
                                        style: GoogleFonts.lato(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: "₹ ${balance.abs().toStringAsFixed(2)}",
                                            style: GoogleFonts.lato(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: positive ? Colors.green : Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),


                              ],
                            ),

                          // ================= SPLIT =================
                          // ================= SPLIT =================
                          if (billingProvider.selectBillMethod == "Split Payment") ...[
                            MyTextField(
                              labelText: "UPI Amount",
                              focusNode: upiFocus,
                              controller: billingProvider.upiPayment,
                              onChanged: (_) {
                                updateSplitFromUpi(total);
                              },
                            ),

                            MyTextField(
                              labelText: "Cash Amount",
                              controller: billingProvider.paymentReceived,
                              onChanged: (_) {
                                updateSplitFromCash(total);
                              },
                            ),

                            ValueListenableBuilder<TextEditingValue>(
                              valueListenable: billingProvider.paymentBalance,
                              builder: (context, value, _) {
                                final balance = double.tryParse(value.text) ?? 0.0;
                                final positive = balance <= 0;

                                return RichText(
                                  text: TextSpan(
                                    text: "Balance: ",
                                    style: GoogleFonts.lato(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: "₹ ${balance.abs().toStringAsFixed(2)}",
                                        style: GoogleFonts.lato(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: positive ? Colors.green : Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],


                          // ================= QR =================
                          if (billingProvider.selectBillMethod ==
                              "Paytm" &&
                              qrData != null) ...[
                            const SizedBox(height: 10),
                            const MyText(
                                text: "Scan QR & Pay",
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                            SizedBox(
                              width: 200,
                              height: 200,
                              child: QrImageView(data: qrData!),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  actions: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 200, // 👈 adjust pannalaam
                          child: Buttons.loginButton(
                            context: context,
                            loadingButtonController:
                            billingProvider.printAfterChangeButtonController,
                            text: 'Print Bill (ENTER)',
                            onPressed: () {
                              onPressPrint();
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 160, // 👈 same width
                          child: Buttons.loginButton(
                            context: context,
                            loadingButtonController:
                            billingProvider.printAfterChangeButtonControllerSave,
                            text: 'Save Bill (TAB)',
                            onPressed: () {
                              onPressPrintSave();
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],



                );
              },
            );
          },
        );
      },
    );
  }


  bool isMultiple = false;
  final TextEditingController barcodeController = TextEditingController();
  final List<String> scannedStocks = [];

  void handleInsert(StateSetter setDialogState) {
    final code = barcodeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please scan or enter a barcode")),
      );
      return;
    }

    if (isMultiple) {
      setDialogState(() {
        scannedStocks.add(code);
      });
      barcodeController.clear();
    } else {
      insertStock(code);
    }
  }

  void insertStock(String barcode) {
    Navigator.pop(context); // Close dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Single stock inserted: $barcode")),
    );
  }

  void insertMultipleStocks() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Uploaded ${scannedStocks.length} stocks.")),
    );
    setState(() => scannedStocks.clear());
  }
  Widget buildInfoBlock({
    required String label,
    required String value,
    required Color color,
    required Color color1,
  }) {
    return Container(
      width: 120,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label",
            style: TextStyle(
              fontSize: 16,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              color: color1,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }


  /// Table Header Widget :
  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(

        // decoration: BoxDecoration(
        //   border: Border.all(color: Colors.black, width: 1.5),
        //   borderRadius: BorderRadius.circular(12), // <-- ROUND BORDER
        //             // optional background
        // ),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),
        child: MyText(
          text: text,
          textAlign: TextAlign.center,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildRightHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(4.0,),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 3),
        // decoration: BoxDecoration(
        //   border: Border.all(color: Colors.black, width: 1.5),
        //   borderRadius: BorderRadius.circular(12), // <-- ROUND BORDER
        //             // optional background
        // ),
        child: MyText(
          text: text,
          textAlign: TextAlign.end,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  /// Billing Products Widget :
  // Widget _buildCell(String text) {
  //   return Padding(
  //     padding: const EdgeInsets.all(4),
  //     child: MyText(
  //       text: text == "null" ? "" : text,
  //       textAlign: TextAlign.center,
  //       fontSize: 21,
  //
  //      fontWeight: FontWeight.bold,
  //     ),
  //   );
  // }

  Widget _buildCell(String text) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle, // 🔥 KEY LINE
      child: IgnorePointer(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          child: Align(
            alignment: Alignment.centerRight, // right aligned
            child: MyText(
              text: text == "null" ? "" : text,
              fontSize: 21,
              // color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildCellQuantity(String text) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle, // 🔥 KEY LINE
      child: IgnorePointer(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          child: Align(
            alignment: Alignment.center, // right aligned
            child: MyText(
              text: text == "null" ? "" : text,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQtyField({
    required BillingProvider billingProvider,
    required int index,
    required dynamic billProduct, // 🔥 changed
  }) {
    return Focus(
      onKeyEvent: (node, event) {
        // 🔥 Scanner or any key press while qty focused
        if (event is KeyDownEvent &&
            qtyFocusNodes[index].hasFocus) {

          final controller =
          billingProvider.quantityControllers[index]!;

          // keep old value safe
          int oldQty = int.tryParse(controller.text) ?? 0;

          if (oldQty <= 0) {
            controller.text = "1";
            oldQty = 1;
          }

          billingProvider.updateBillingItem(
            index,
            isLoose: '0',
            quantity: oldQty,
          );

          // ❌ stop qty receiving characters
          qtyFocusNodes[index].unfocus();

          // ✅ move to product/barcode
          Future.microtask(() {
            billingProvider.dropdownFocusNode.requestFocus();
          });

          return KeyEventResult.handled;
        }

        return KeyEventResult.ignored;
      },

      child: TextField(
        focusNode: qtyFocusNodes[index],
        controller: billingProvider.quantityControllers[index]!,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 21),

        decoration: const InputDecoration(
          isDense: true,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            vertical: 6,
            horizontal: 6,
          ),
        ),

        // 🔹 Manual typing only
        onChanged: (value) {
          if (value.isEmpty) {
            billingProvider.updateBillingItem(
              index,
              isLoose: '0',
              quantity: 0,
            );
            return;
          }

          int qty = int.tryParse(value) ?? 0;
          if (qty < 0) qty = 0;

          final int maxQty =
              int.tryParse(billProduct.product.qtyLeft ?? "0") ?? 0;

          if (qty > maxQty) {
            qty = maxQty;

            final fixed = qty.toString();

            billingProvider.quantityControllers[index]!.value =
                billingProvider.quantityControllers[index]!.value.copyWith(
                  text: fixed,
                  selection:
                  TextSelection.collapsed(offset: fixed.length),
                );
          }

          billingProvider.updateBillingItem(
            index,
            isLoose: '0',
            quantity: qty,
          );
        },

        // 🔹 Enter pressed
        onEditingComplete: () {
          _applyDefaultQtyIfNeeded(billingProvider, index);
          qtyFocusNodes[index].unfocus();

          Future.microtask(() {
            billingProvider.dropdownFocusNode.requestFocus();
          });
        },

        onSubmitted: (_) {
          _applyDefaultQtyIfNeeded(billingProvider, index);
          qtyFocusNodes[index].unfocus();

          Future.microtask(() {
            billingProvider.dropdownFocusNode.requestFocus();
          });
        },
      ),
    );
  }


  Widget _buildRightCell(String text) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle, // 🔥 KEY LINE
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
        child: Align(
          alignment: Alignment.centerRight, // right aligned
          child: MyText(
            text: text == "null" ? "" : text,
            fontSize: 23,
          ),
        ),
      ),
    );
  }


  Widget _buildBoldCell(String text) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle, // 🔥 KEY LINE
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
        child: Align(
          alignment: Alignment.centerRight, // right aligned
          child: MyText(
            text: text == "null" ? "" : text,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }


  Widget _buildRedBoldCell(String text) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle, // 🔥 KEY LINE
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
        child: Align(
          alignment: Alignment.centerRight, // right aligned
          child: MyText(
            text: text == "null" ? "" : text,
            color: Colors.red,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }



  void _focusQty(int index) {
    if (index < 0) return;
    if (index >= qtyFocusNodes.length) return;

    Future.delayed(const Duration(milliseconds: 80), () {
      if (index < qtyFocusNodes.length) {
        qtyFocusNodes[index].requestFocus();
      }
    });
  }

  Widget _buildEditableCell({
    required int index,
    required FocusNode focusNode,
    required TextEditingController controller,
    required Function(String) onChanged,
    required Function() onEditingComplete,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      focusNode: focusNode,
      controller: controller,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      style: const TextStyle(fontSize: 16),

      // ⬇ THIS REMOVES UNDERLINE
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        border: InputBorder.none,
      ),
    );
  }
}







String _formatKg(dynamic grams) {
  double g = double.tryParse(grams.toString()) ?? 0;
  double kg = g / 1000;

  // Remove trailing zeros (1.0 â†’ 1, 1.50 â†’ 1.5)
  if (kg % 1 == 0) {
    return kg.toInt().toString();     // example: 1
  } else {
    return kg.toStringAsFixed(3).replaceAll(RegExp(r"0+$"), "").replaceAll(RegExp(r"\.$"), "");
  }
}
Widget _verticalDivider() {
  return Container(
    width: 2,
    height: 40,
    color:colorsConst.primary,
  );
}



import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_utils/src/extensions/string_extensions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fullcomm_crm/res/colors.dart';
import 'package:fullcomm_crm/res/components/bottom_widgets.dart';
import 'package:fullcomm_crm/res/components/buttons.dart';
import 'package:fullcomm_crm/res/components/k_loadings.dart';
import 'package:fullcomm_crm/res/components/k_text.dart';
import 'package:fullcomm_crm/res/components/screen_widgtes.dart';
import 'package:fullcomm_crm/billing_utils/input_formatters.dart';
import 'package:fullcomm_crm/billing_utils/sized_box.dart';
import 'package:fullcomm_crm/billing_utils/text_formats.dart';
import 'package:fullcomm_crm/billing_utils/toast_messages.dart';
import 'package:fullcomm_crm/view_models/billing_provider.dart';
import 'package:fullcomm_crm/view_models/customer_provider.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../billing_utils/caps_letter.dart';
import '../../common/billing_data/local_data.dart';
import '../../common/billing_data/project_data.dart';
import '../../common/constant/colors_constant.dart';
import '../../common/styles/decoration.dart';
import '../../common/utilities/utils.dart';
import '../../components/Customtext.dart';
import '../../components/custom_loading_button.dart';
import '../../controller/controller.dart';
import '../../controller/settings_controller.dart';
import '../../models/all_customers_obj.dart';
import '../../models/billing_models/billing_product.dart';
import '../../models/billing_models/place_order.dart';
import '../../models/billing_models/products_response.dart';
import '../../models/billing_models/return_qty.dart';
import '../../res/components/hint.dart';
import '../../res/components/k_text_field.dart';
import '../../res/components/keyboard_search.dart';
import '../../screens/quotation/send_quotation.dart';
import '../../services/api_services.dart';
import '../orders/hold_order.dart';
import '../orders/order_detail_page.dart';
import '../products/add_products.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

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
      // log("ScrollController is not attached to any scroll view.");
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
      FocusScope.of(context).requestFocus(billing.dropdownFocusNode);
      billing.dropdownFocusNode.requestFocus();
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


  Timer? _scanDebounce;

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
    bool _isPaymentDialogOpen = false;
    bool _isPrinting = false;
    return Consumer2<CustomersProvider, BillingProvider>(
        builder: (context, customerProvider, billingProvider,
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
                          return null;
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
                          return null;
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
                          if (localData.secretCode.trim().isEmpty) {
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
                            return null;
                          }

                      ),
                      LogoutIntent: CallbackAction<LogoutIntent>(
                        onInvoke: (intent) {
                          // Show logout confirm dialog
                          customerProvider.showCashierPopupAndLogout(context,billingProvider);
                          return null;
                        },
                      ),
                      ResetIntent: CallbackAction<ResetIntent>(
                        onInvoke: (intent) {
                          // Show logout confirm dialog
                          billingProvider.clearBillingData(context);
                          billingProvider.dropdownFocusNode.requestFocus();
                          return null;
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
                            return null;

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
                        child: GestureDetector(
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
                                    GestureDetector(
                                      onTap: () {
                                        _focusNode.requestFocus();
                                      },
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          20.height,
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              CustomerDropdown(
                                                custList: controllers.customers,
                                                onChanged: (AllCustomersObj? customer) {
                                                  setState(() {
                                                    controllers.selectCustomer(customer!);
                                                  });
                                                },),
                                            Row(
                                              children: [
                                                CustomLoadingButton(
                                                  callback: ()async{
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
                                                    final now = DateTime.now();
                                                    final billNo = 'BILL${now
                                                        .millisecondsSinceEpoch % 10000}';
                                                    final formattedDate =
                                                        '${now.day}/${now.month}/${now
                                                        .year} ${now.hour}:${now.minute}';
                                                    await billingProvider.saveHoldBillDetails(context: context,
                                                      order: Order(
                                                        split_pay: billingProvider.selectBillMethod =="Split Payment"?
                                                        (billingProvider.upiPayment.text.isEmpty ? "0" : billingProvider.upiPayment .text): "0",
                                                        id: billNo,
                                                        createdTs: formattedDate,
                                                        customerMobile: controllers.selectedCustomerMobile.value,
                                                        cashier: "${controllers.storage.read("id")}",
                                                        salesmanId: "${controllers.storage.read("id")}",
                                                        customerId: controllers.selectedCustomerId.value,
                                                        customerName: controllers.selectedCustomerName.value,
                                                        customerAddress:"",
                                                        paymentMethod: selectedMethod,
                                                        paymentId: paymentId,
                                                        creditDays: selectedMethod =="Credit"? (billingProvider.creditDays ??0): 0,
                                                        products: billingProvider.billingItems,
                                                        orderGrandTotal:billingProvider.calculatedGrandTotal().toStringAsFixed(2),
                                                        orderSubTotal:billingProvider.calculatedGrandTotal().toStringAsFixed(2),
                                                        receivedAmt: billingProvider.paymentReceived.text.isEmpty? "0.0": double.parse(billingProvider.paymentReceived.text).toStringAsFixed(2),
                                                        payBackAmt:(selectedMethod == "Cash" ? ((billingProvider .paymentReceived.text .isEmpty ? 0.0
                                                            : double.parse( billingProvider .paymentReceived .text)) -
                                                            billingProvider .calculatedGrandTotal()) .abs() .toStringAsFixed(2) : "0.00"
                                                        ),
                                                        version: "0.0",
                                                        savings: '${billingProvider.billingItems .fold(0.0, (t, i) => t + i.calculateDiscount())}',
                                                        billStatus: 0,
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
                                                  isLoading: false,
                                                  height: 35,
                                                  backgroundColor: Colors.white,
                                                  radius: 2,
                                                  width: MediaQuery.of(context).size.width*0.05,
                                                  isImage: false,
                                                  text: "Hold Bill",
                                                  textColor: colorsConst.primary,
                                                ),10.width,
                                                CustomLoadingButton(
                                                  callback: (){
                                                    billingProvider.clearBillingData(context);
                                                  },
                                                  isLoading: false,
                                                  height: 35,
                                                  backgroundColor: Colors.white,
                                                  radius: 2,
                                                  width: MediaQuery.of(context).size.width*0.05,
                                                  isImage: false,
                                                  text: "Clear Bill",
                                                  textColor: colorsConst.primary,
                                                ),10.width,
                                                CustomLoadingButton(
                                                  callback: ()async{
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
                                                  isLoading: false,
                                                  height: 35,
                                                  backgroundColor: Colors.white,
                                                  radius: 2,
                                                  width: MediaQuery.of(context).size.width*0.07,
                                                  isImage: false,
                                                  text: "Release Bill",
                                                  textColor: colorsConst.primary,
                                                ),10.width,
                                                CustomLoadingButton(
                                                  callback: (){
                                                    showDialog(
                                                      context: context,
                                                      barrierDismissible: true,
                                                      builder: (_) => const AddProductDialog(),
                                                    );
                                                  },
                                                  isLoading: false,
                                                  height: 35,
                                                  backgroundColor: colorsConst.primary,
                                                  radius: 2,
                                                  width: MediaQuery.of(context).size.width*0.07,
                                                  isImage: false,
                                                  text: "Add Product",
                                                  textColor: Colors.white,
                                                ),
                                                10.width,
                                              ],
                                            )
                                            ],
                                          ),20.height,
                                        ],
                                      ),
                                    ),
                                    /// Fixed Header:
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          width: screenWidth/2.6,
                                          decoration: BoxDecoration(
                                            color: Colors.transparent, // outer
                                            borderRadius: BorderRadius.circular(5),
                                            border: Border.all(color: Colors.grey.shade300, width: 0),
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
                                            child: Theme(
                                              data: Theme.of(context).copyWith(
                                                inputDecorationTheme: InputDecorationTheme(
                                                  filled: true,
                                                  fillColor: Colors.white, // 👈 change here
                                                  enabledBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(5),
                                                    borderSide: BorderSide(color: Colors.grey.shade300, width: 0),
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(5),
                                                    borderSide: BorderSide(color: Colors.blue, width: 0),
                                                  ),
                                                ),
                                              ),
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
                                                  fontSize: 15,
                                                ),
                                                linkStyle: const TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black,
                                                ),

                                                labelText: "Product",
                                                textEditingController: dropdownController,

                                                labelBuilder: (product) {
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
                                                              fontSize: 15,
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
                                        Container(
                                          width: screenWidth*0.09,
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
                                        CustomLoadingButton(
                                          callback: () {
                                            if(controllers.selectedCustomerId.value==""){
                                              utils.snackBar(context: context, msg: "Please select customer", color: Colors.red);
                                            }else if(billingProvider.billingItems.isEmpty){
                                              utils.snackBar(context: context, msg: "Please select products", color: Colors.red);
                                            }else{
                                              printInvoice(billingProvider);
                                            }
                                          },
                                          isLoading: false,
                                          height: 45,
                                          backgroundColor: colorsConst.primary,
                                          radius: 2,
                                          width: screenWidth*0.1,
                                          isImage: false,
                                          text: "View Quotation",
                                          textColor: Colors.white,
                                        ),
                                        CustomLoadingButton(
                                          callback: () {
                                            if(controllers.selectedCustomerId.value==""){
                                              utils.snackBar(context: context, msg: "Please select customer", color: Colors.red);
                                            }else if(billingProvider.billingItems.isEmpty){
                                              utils.snackBar(context: context, msg: "Please select products", color: Colors.red);
                                            }else{
                                              setState(() {
                                                controllers.emailToCtr.text=controllers.selectedCustomerEmail.value;
                                                controllers.isTemplate.value=false;
                                                controllers.emailSubjectCtr.clear();
                                                controllers.emailMessageCtr.clear();
                                              });
                                              showDialog(
                                                  context: context,
                                                  barrierDismissible: false,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      actions: [
                                                        Column(
                                                          children: [
                                                            Divider(
                                                              color: Colors.grey.shade300,
                                                              thickness: 1,
                                                            ),
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                SizedBox(
                                                                  child: Row(
                                                                    children: [
                                                                      TextButton(
                                                                          onPressed: () {
                                                                            Navigator.of(context).pop();
                                                                            settingsController.showAddTemplateDialog(context);
                                                                          },
                                                                          child: CustomText(
                                                                            text: "Add Template",
                                                                            isCopy: false,
                                                                            colors: colorsConst.third,
                                                                            size: 18,
                                                                            isBold: true,
                                                                          )),
                                                                    ],
                                                                  ),
                                                                ),
                                                                CustomLoadingButton(
                                                                  callback: () {
                                                                    if(controllers.emailToCtr.text.trim().isEmpty){
                                                                      utils.snackBar(context: context, msg: "To is empty!", color: Colors.red);
                                                                      controllers.emailCtr.reset();
                                                                      return;
                                                                    }
                                                                    if(!controllers.emailToCtr.text.trim().isEmail){
                                                                      utils.snackBar(
                                                                        context: context,
                                                                        msg: "Invalid mail!",
                                                                        color: Colors.red,
                                                                      );
                                                                      controllers.emailCtr.reset();
                                                                      return;
                                                                    }
                                                                    if(controllers.emailSubjectCtr.text.trim().isEmpty){
                                                                      utils.snackBar(context: context, msg: "Quotation is empty!", color: Colors.red);
                                                                      controllers.emailCtr.reset();
                                                                      return;
                                                                    }
                                                                    if(controllers.emailMessageCtr.text.trim().isEmpty){
                                                                      utils.snackBar(context: context, msg: "Message is empty!", color: Colors.red);
                                                                      controllers.emailCtr.reset();
                                                                      return;
                                                                    }
                                                                    sendInvoice(billingProvider);
                                                                  },
                                                                  controller: controllers.emailCtr,
                                                                  isImage: false,
                                                                  isLoading: true,
                                                                  backgroundColor: colorsConst.primary,
                                                                  radius: 5,
                                                                  width: 200,
                                                                  height: 50,
                                                                  text: "Send Quotation",
                                                                  textColor: Colors.white,
                                                                ),
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                      ],
                                                      content: SizedBox(
                                                          width: 600,
                                                          height: 400,
                                                          child: SingleChildScrollView(
                                                            child: Column(
                                                              children: [
                                                                Align(
                                                                    alignment: Alignment.topRight,
                                                                    child: InkWell(
                                                                        onTap: () {
                                                                          Navigator.pop(context);
                                                                        },
                                                                        child: Icon(
                                                                          Icons.clear,
                                                                          size: 18,
                                                                          color: colorsConst.textColor,
                                                                        ))),
                                                                Align(
                                                                  alignment: Alignment.topRight,
                                                                  child: TextButton(
                                                                      onPressed: () {
                                                                        controllers.isTemplate.value = !controllers.isTemplate.value;
                                                                      },
                                                                      child: CustomText(
                                                                        text: "Get Form Template",
                                                                        colors: colorsConst.third,
                                                                        size: 18,
                                                                        isCopy: false,
                                                                        isBold: true,
                                                                      )),
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    CustomText(
                                                                      textAlign: TextAlign.center,
                                                                      text: "To",
                                                                      colors: colorsConst.textColor,
                                                                      size: 15,
                                                                      isCopy: false,
                                                                    ),
                                                                    50.width,
                                                                    SizedBox(
                                                                      width: 500,
                                                                      child: TextField(
                                                                        controller: controllers.emailToCtr,
                                                                        style: TextStyle(
                                                                            fontSize: 15, color: colorsConst.textColor),
                                                                        decoration: const InputDecoration(
                                                                          border: InputBorder.none,
                                                                        ),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                    width: 600,
                                                                    child: SingleChildScrollView(
                                                                      child: Column(
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        children: [
                                                                          Divider(
                                                                            color: Colors.grey.shade300,
                                                                            thickness: 1,
                                                                          ),
                                                                          Row(
                                                                            children: [
                                                                              15.height,
                                                                              CustomText(
                                                                                text: "Quotation",
                                                                                colors: colorsConst.textColor,
                                                                                size: 14,
                                                                                isCopy: false,
                                                                              ),
                                                                              20.width,
                                                                              SizedBox(
                                                                                width: 500,
                                                                                height: 50,
                                                                                child: TextField(
                                                                                  controller: controllers.emailSubjectCtr,
                                                                                  maxLines: null,
                                                                                  minLines: 1,
                                                                                  style: TextStyle(
                                                                                    color: colorsConst.textColor,
                                                                                  ),
                                                                                  decoration: const InputDecoration(
                                                                                    border: InputBorder.none,
                                                                                  ),
                                                                                ),
                                                                              )
                                                                            ],
                                                                          ),
                                                                          Divider(
                                                                            color: Colors.grey.shade300,
                                                                            thickness: 1,
                                                                          ),
                                                                          Obx(() => controllers.isTemplate.value == false
                                                                              ? SingleChildScrollView(
                                                                            child: Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                SizedBox(
                                                                                  width: 600,
                                                                                  height: 70,
                                                                                  child: TextField(
                                                                                    textInputAction: TextInputAction.newline,
                                                                                    controller: controllers.emailMessageCtr,
                                                                                    keyboardType: TextInputType.multiline,
                                                                                    maxLines: 21,
                                                                                    expands: false,
                                                                                    style: TextStyle(
                                                                                      color: colorsConst.textColor,
                                                                                    ),
                                                                                    decoration: InputDecoration(
                                                                                      hintText: "Message",
                                                                                      hintStyle: TextStyle(
                                                                                          color: colorsConst.textColor,
                                                                                          fontSize: 14,
                                                                                          fontFamily: "Lato"),
                                                                                      border: InputBorder.none,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          )
                                                                              :Obx(() => UnconstrainedBox(
                                                                            child: Container(
                                                                              width: 500,
                                                                              alignment: Alignment.center,
                                                                              decoration: BoxDecoration(
                                                                                color: colorsConst.secondary,
                                                                                borderRadius: BorderRadius.circular(10),
                                                                              ),
                                                                              child: SingleChildScrollView(
                                                                                child: Column(
                                                                                  children: [
                                                                                    SizedBox(
                                                                                      width: 500,
                                                                                      height: 170,
                                                                                      child: Table(
                                                                                        defaultColumnWidth: const FixedColumnWidth(120.0),
                                                                                        border: TableBorder.all(
                                                                                          color: Colors.grey.shade300,
                                                                                          style: BorderStyle.solid,
                                                                                          borderRadius: BorderRadius.circular(10),
                                                                                          width: 1,
                                                                                        ),
                                                                                        children: [
                                                                                          // Header Row
                                                                                          TableRow(
                                                                                            children: [
                                                                                              CustomText(
                                                                                                textAlign: TextAlign.center,
                                                                                                text: "\nTemplate Name\n",
                                                                                                colors: colorsConst.textColor,
                                                                                                size: 15,
                                                                                                isBold: true,
                                                                                                isCopy: false,
                                                                                              ),
                                                                                              CustomText(
                                                                                                textAlign: TextAlign.center,
                                                                                                text: "\nSubject\n",
                                                                                                colors: colorsConst.textColor,
                                                                                                size: 15,
                                                                                                isBold: true,
                                                                                                isCopy: false,
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                          // Dynamic Rows
                                                                                          for (var item in settingsController.templateList)
                                                                                            utils.emailRow(
                                                                                                context,
                                                                                                isCheck: controllers.isAdd,
                                                                                                templateName: item.templateName,
                                                                                                msg: item.message,
                                                                                                subject: item.subject,
                                                                                                id: item.id
                                                                                            ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ))),
                                                                          CustomText(
                                                                            textAlign: TextAlign.start,isBold: true,size: 15,
                                                                              text: "The quotation has been sent for ${billingProvider.calculatedTotalProducts()} items with a total amount of ${TextFormat.formattedAmount(billingProvider.calculatedGrandTotal())}.", isCopy: true),
                                                                          10.height,
                                                                          SizedBox(
                                                                            width: 600,
                                                                            child: TextField(
                                                                              textInputAction: TextInputAction.newline,
                                                                              controller: controllers.notesCtr,
                                                                              keyboardType: TextInputType.multiline,
                                                                              maxLines: null,
                                                                              minLines: 3,
                                                                              style: TextStyle(
                                                                                color: colorsConst.textColor,
                                                                              ),
                                                                              decoration: InputDecoration(
                                                                                hintText: "Notes",
                                                                                hintStyle: TextStyle(
                                                                                    color: colorsConst.textColor,
                                                                                    fontSize: 14,
                                                                                    fontFamily: "Lato"),
                                                                                border: OutlineInputBorder(),
                                                                                enabledBorder: OutlineInputBorder(
                                                                                    borderSide: BorderSide(
                                                                                      color: Colors.grey.shade400,
                                                                                    ),
                                                                                    borderRadius: BorderRadius.circular(5)),
                                                                                focusedBorder: OutlineInputBorder(
                                                                                    borderSide: BorderSide(
                                                                                      color: colorsConst.primary,
                                                                                    ),
                                                                                    borderRadius: BorderRadius.circular(5)),
                                                                                focusedErrorBorder: OutlineInputBorder(
                                                                                    borderSide: BorderSide(
                                                                                        color: const Color(0xffE1E5FA)),
                                                                                    borderRadius: BorderRadius.circular(5)),
                                                                                contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                                                                errorBorder: OutlineInputBorder(
                                                                                    borderSide: BorderSide(
                                                                                        color: const Color(0xffE1E5FA)),
                                                                                    borderRadius: BorderRadius.circular(5)),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          10.height,
                                                                          Container(
                                                                            width: MediaQuery.of(context).size.width*0.6,
                                                                            decoration: customDecoration.baseBackgroundDecoration(
                                                                              color: Colors.grey.shade50,radius: 5,
                                                                            ),
                                                                            child: Padding(
                                                                              padding: const EdgeInsets.all(8.0),
                                                                              child: CustomText(
                                                                                textAlign: TextAlign.start,
                                                                                text: "${controllers.selectedCustomerName.value.replaceAll(' ', '_')}_${controllers.selectedCompanyName.value.replaceAll(' ', '_')}_${DateFormat('dd-MM-yyyy').format(DateTime.now())}.pdf",
                                                                                isCopy: false,colors: colorsConst.primary,isBold: true,),
                                                                            ),
                                                                          )
                                                                        ],
                                                                      ),
                                                                    )),
                                                              ],
                                                            ),
                                                          )),
                                                    );
                                                  });
                                            }
                                          },
                                          isLoading: false,
                                          height: 45,
                                          backgroundColor: Colors.green,
                                          radius: 2,
                                          width: screenWidth*0.1,
                                          isImage: false,
                                          text: "Send Quotation",
                                          textColor: Colors.white,
                                        ),
                                      ],
                                    ),
                                    10.height,
                                    ///  Billing Table :
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                                        child: Column(
                                          children: [
                                            // ===========================
                                            // HEADER
                                            // ===========================
                                            Table(
                                              border: TableBorder(
                                                horizontalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                                                verticalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                                              ),
                                              columnWidths: const {
                                                0: FixedColumnWidth(70),//s no
                                                1: FlexColumnWidth(4),//ptp
                                                2: FixedColumnWidth(200),//HSN
                                                3: FixedColumnWidth(70),//Var
                                                4: FixedColumnWidth(60),//Qty
                                                5: FlexColumnWidth(1),//mrp
                                                6: FlexColumnWidth(1),//op
                                                7: FlexColumnWidth(1),//dic
                                                8: FlexColumnWidth(1),//st
                                              },
                                              children: [
                                                TableRow(
                                                  decoration: BoxDecoration(
                                                      color: colorsConst.primary,
                                                      borderRadius: const BorderRadius.only(
                                                          topLeft: Radius.circular(5),
                                                          topRight: Radius.circular(5))),
                                                  children: [
                                                    _buildHeaderCell("S.N"),
                                                    _buildHeaderCell("Product"),
                                                    _buildHeaderCell("HSN"),
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
                                                  // final productData = billingProvider.productsList.firstWhere(
                                                  //       (p) => p.id == billProduct.product.id,
                                                  //   orElse: () => billProduct.product,
                                                  // );
                                                  if (billingProvider.quantityControllers.length <= index) {
                                                    billingProvider.quantityControllers.add(TextEditingController(text: billProduct.quantity.toString().isEmpty?"1":billProduct.quantity.toString()=='null'?"1":billProduct.quantity.toString()));
                                                  }
                                                  return Table(
                                                    border: TableBorder(
                                                      horizontalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                                                      verticalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                                                      bottom:  BorderSide(width: 0.5, color: Colors.grey.shade400),
                                                    ),
                                                    columnWidths: const {
                                                      0: FixedColumnWidth(70),//s no
                                                      1: FlexColumnWidth(4),//ptp
                                                      2: FixedColumnWidth(200),//HSN
                                                      3: FixedColumnWidth(70),//Var
                                                      4: FixedColumnWidth(60),//Qty
                                                      5: FlexColumnWidth(1),//mrp
                                                      6: FlexColumnWidth(1),//op
                                                      7: FlexColumnWidth(1),//dic
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
                                                                      fontSize: 15,
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

                                                          _buildCell(billProduct.product.hsnCode),
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

                                                            style: const TextStyle(fontSize: 15),

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
                                                            style: const TextStyle(fontSize: 15),
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
                                    ),30.height,
                                    billingProvider.isLoading ? 0.height
                                        : Container(
                                      width:controllers.isLeftOpen.value?MediaQuery.of(context).size.width - 150:MediaQuery.of(context).size.width - 60,
                                      color: Colors.white,
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
                                )
                        ),
                      ),
                    ),
                  )),
            ),
          );
        }
    );
  }

  Future<void> printInvoice(BillingProvider billingPvr) async {
    final pdf = await generateInvoicePdf(billingPvr);

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  Future<void> sendInvoice(BillingProvider billingPvr) async {
    final pdf = await generateInvoicePdf(billingPvr);
    String productListJson = jsonEncode(
      billingPvr.billingItems.map((e) => e.toJson()).toList(),
    );
    apiService.insertQuotationAPI(context, pdf,productListJson);
  }

  Future<pw.Document> generateInvoicePdf(BillingProvider billingPvr) async {
    print(".......printInvoice");
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 20),

                /// 🟢 HEADER ROW
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [

                    /// LEFT SIDE (Company)
                    pw.Expanded(
                      flex: 6,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("Hapi Apps",
                              style: pw.TextStyle(
                                  fontSize: 18,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.Text(
                              "7/38, East Street, Kulaiyankarisal\nThoothukudi, Tamil Nadu, 628103"),
                          pw.SizedBox(height: 5),
                          pw.Text("Email : info@hapiapps.com"),
                          pw.Text("Mobile : +91 9677 281 724"),
                          pw.Text("GSTIN : "),
                        ],
                      ),
                    ),

                    /// RIGHT BOX
                    pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(),
                        borderRadius: pw.BorderRadius.circular(5),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          rowText("Quotation No:", (10000 + Random().nextInt(90000)).toString()),
                          rowText("Quotation Date:", DateFormat("dd-MM-yyyy").format(DateTime.now())),
                          // rowText("OrderNo:", data.id),
                        ],
                      ),
                    )
                  ],
                ),

                pw.SizedBox(height: 15),

                /// CUSTOMER
                pw.Text("M/S : ${controllers.selectedCustomerName}"),
                // pw.Text("Address : ${controllers.selectedc}"),

                pw.SizedBox(height: 10),

                pw.Text("PARTY GSTIN : "),

                pw.SizedBox(height: 10),

                /// 🔵 TABLE
                pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(1),
                    1: const pw.FlexColumnWidth(4),
                    2: const pw.FlexColumnWidth(1),
                    3: const pw.FlexColumnWidth(1),
                    4: const pw.FlexColumnWidth(2),
                  },
                  children: [

                    /// HEADER
                    pw.TableRow(
                      children: [
                        tableCell("S.No.", isHeader: true),
                        tableCell("Product Name", isHeader: true),
                        tableCell("Qty", isHeader: true),
                        tableCell("MRP", isHeader: true),
                        tableCell("Amount INR", isHeader: true),
                      ],
                    ),

                    /// DATA
                    ...List.generate(billingPvr.billingItems.length, (index) {
                      final p = billingPvr.billingItems[index];
                      final billProduct = billingPvr.billingItems[index];

                      return pw.TableRow(
                        children: [
                          tableCell("${index + 1}"),
                          tableCell(p.productTitle.toString()),
                          tableCell(p.quantity.toString()),
                          tableCell(p.p_mrp.toString()),
                          tableCell("Rs. ${billProduct.calculateSubtotal()}"),
                        ],
                      );
                    }),
                  ],
                ),

                pw.SizedBox(height: 10),

                /// 🔶 BOTTOM SECTION
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [

                    /// LEFT SIDE
                    pw.Expanded(
                      flex: 6,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          // pw.Text("Amount in Words: INR ${productCtr.numberToWords(int.parse(data.totalAmt))} Only"),
                          pw.SizedBox(height: 10),
                          pw.Text("UPI ID:"),
                          pw.Text("Bank Account No:"),
                          pw.Text("Name: Hapi Apps"),
                          pw.Text("IFSC: ..."),
                          pw.Text("Kulaiyankarisal branch"),
                        ],
                      ),
                    ),

                    /// RIGHT SIDE (TOTAL BOX)
                    pw.Expanded(
                      flex: 4,
                      child: pw.Container(
                        decoration:
                        pw.BoxDecoration(border: pw.Border.all()),
                        child: pw.Column(
                          children: [
                            totalRows("Total Before Tax SGST", "15,000"),
                            totalRows("CGST 9%", "1,350"),
                            totalRows("Round Off 9%", "1,350"),
                            totalRows("Total After", "1,350"),
                            // totalRows("Tax for HapiApps", data.totalAmt,isBold: true),
                            pw.SizedBox(height: 20),
                            pw.Text("Signature"),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
    return pdf;
  }
  pw.Widget totalRows(String title, String value,{bool isBold = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      decoration: pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide()),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(title,
              style: pw.TextStyle(
                  fontWeight: isBold
                      ? pw.FontWeight.bold
                      : pw.FontWeight.normal)),
          pw.Text(value,
              style: pw.TextStyle(
                  fontWeight: isBold
                      ? pw.FontWeight.bold
                      : pw.FontWeight.normal)),
        ],
      ),
    );
  }

  pw.Widget tableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight:
          isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  pw.Widget rowText(String title, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.Text(title),
          pw.SizedBox(width: 5),
          pw.Text(value),
        ],
      ),
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
                        (localData.secretCode.trim().isEmpty)) {
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
                                            (localData.secretCode.trim().isEmpty)) {
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
          fontSize: 15,
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
          fontSize: 15,
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
              fontSize: 15,
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
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
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
            fontSize: 15,
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
            fontSize: 15,
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
            fontSize: 15,
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

}










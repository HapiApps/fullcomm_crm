import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:fullcomm_crm/repo/place_order_repo.dart';
import 'package:fullcomm_crm/repo/products_repo.dart';
import 'package:fullcomm_crm/billing_utils/toast_messages.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../billing/pdf/bill_pdf.dart';
import '../billing_utils/text_formats.dart';
import '../common/utilities/utils.dart';
import '../controller/controller.dart';
import '../models/billing_models/billing_product.dart';
import '../models/billing_models/category_model.dart';
import '../models/billing_models/online_orders.dart';
import '../models/billing_models/order_details.dart';
import '../models/billing_models/place_order.dart';
import '../models/billing_models/products_response.dart';
import '../models/billing_models/return_qty.dart';
import 'customer_provider.dart';

class BillingProvider with ChangeNotifier{

  final ProductsRepository _productsRepo = ProductsRepository();
  final PlaceOrderRepository _placeOrderRepo = PlaceOrderRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _selectedDate = 'Today';
  OrderData? lastBillOrder;
  String get selectedDate => _selectedDate;

  notifyListeners();

  void changeDateFilter(String value) {
    _selectedDate = value;
    notifyListeners();
  }
  void clearSearch() {
    searchName.clear();
    bill.clear();
    searchAmount.clear();
    searchProd.clear();
  }
  void applyQuickDateFilter(String value) {
    DateTime today = DateTime.now();

    if (value == 'Today') {
      final start = DateFormat('yyyy-MM-dd').format(today);
      final end = DateFormat('yyyy-MM-dd')
          .format(today.add(const Duration(days: 1)));

      getAllOrderDetails(start, end);
      getAllOnlineOrderDetails(start, end);
      setDateRange(null);
    }

    else if (value == 'Last 7 Days') {
      final start = DateFormat('yyyy-MM-dd')
          .format(today.subtract(const Duration(days: 6)));
      final end = DateFormat('yyyy-MM-dd').format(today);

      getAllOrderDetails(start, end);
      getAllOnlineOrderDetails(start, end);

      setDateRange(null);
    }

    else if (value == 'Last 30 Days') {
      final start = DateFormat('yyyy-MM-dd')
          .format(today.subtract(const Duration(days: 30)));
      final end = DateFormat('yyyy-MM-dd').format(today);

      getAllOrderDetails(start, end);
      getAllOnlineOrderDetails(start, end);
      setDateRange(null);
    }
  }

  String stDate = '';
  String enDate = '';
  PickerDateRange? selectedRange;
  final FocusNode dropdownFocusNode = FocusNode();
  final FocusNode dropdownReturnFocusNode = FocusNode();
  void setDateRange(PickerDateRange? range) {
    selectedRange = range;

    if (range != null) {
      final start = range.startDate!;
      final end = range.endDate ?? DateTime.now();
      log("stdat:$stDate");
      log("stddat:$enDate");

      stDate = _formatDate(start);
      enDate = _formatDate(end);

      final endForApi = end.add(const Duration(days: 0));
      getAllOrderDetails(start.toString(), endForApi.toString());
      getAllOnlineOrderDetails(start.toString(), endForApi.toString());

    } else {
      stDate = '';
      enDate = '';
    }

    notifyListeners();
  }

  // void setDateRange(DateTime start, DateTime end) {
  //   stDate = "${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}";
  //   enDate = "${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}";
  //   notifyListeners();
  // }
  // List<String> billMethods = ["Cash", "Money Transfer", "Cheque","Credit"];

  // List<String> billMethods = ["Cash", "UPI", "Credit Card","Split Payment","Paytm","Credit"];
  // List<FocusNode> billMethodFocusNodes = List.generate(6, (_) => FocusNode());FocusNode
  List<String> billMethods = ["Cash", "UPI", "Credit Card","Split Payment","Credit"];
  List<FocusNode> billMethodFocusNodes = List.generate(5, (_) => FocusNode());
  String? selectBillMethod = "Cash";
  int? creditDays;
  List<FocusNode> qtyFocusNodes = [];
  int selectedRowIndex = -1;
  double upiAmount = 0.0;
  double cashBalance = 0.0;

  double totalAmount = 0.0; // 🟢 Your billing total (set this where you calculate)

  void updateUpiAmount(String value) {
    upiAmount = double.tryParse(value) ?? 0.0;
    cashBalance = totalAmount - upiAmount;
    if (cashBalance < 0) cashBalance = 0;
    notifyListeners();
  }

  // existing focus nodes & methods already in your code
  //List<FocusNode> billMethodFocusNodes = [];

  void changeBillMethod(String value) {
    selectBillMethod = value;
    notifyListeners();
  }

  void changeCreditDays(int days) {
    creditDays = days;
    notifyListeners();
  }
  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, "0")}-${date.day.toString().padLeft(2, "0")}";
  }

  /// --------------- Cashier Tab ---------------------
  // TextEditingController cashierNameController = TextEditingController(text: localData.userName);
  final userId = controllers.storage.read("id") ?? "";
  late TextEditingController cashierNameController =
  TextEditingController(text: "Cashier code-$userId");
  // TextEditingController cashierNameController =
  // TextEditingController(text: "${localData.userName} - ${controllers.storage.read("id")}");
  TextEditingController cashierIdController = TextEditingController(text: controllers.storage.read("id").toString());
  TextEditingController cashierController = TextEditingController();
  TextEditingController cashierCounter        = TextEditingController();
  final nameController = TextEditingController();//cusname
  final mobileController = TextEditingController();// cusmob

  /// ------------- Fetch Products -------------------

  List<ProductData> _productsList = [];
  List<ProductData> get productsList => _productsList;
  bool isSavingCustomer = false;
  // API Call For Products :
  Future<void> getProducts() async {
    _isLoading = true;
    notifyListeners();
    try{
      final response = await _productsRepo.getProducts();

      if(response.responseCode==200){
        _productsList = response.productList ?? [];
        dropdownFocusNode.requestFocus();
        //print("products ${_productsList.length}");
        for(int i = 0; i<_productsList.length;i++){
          //print("barcode ${_productsList[i].barcode} ${_productsList[i].pTitle} ${_productsList[i].pVariation}${_productsList[i].unit}");
        }
      }else{
        _productsList=[];
      }

      log("Products List : ${_productsList.length}");

    }catch(e){
      Exception("getProducts Error : $e");
    }finally{
      _isLoading = false;
      notifyListeners();
    }

  }
  Future<void> getWholeSaleProducts() async {
    _isLoading = true;
    notifyListeners();
    try{
      final response = await _productsRepo.getProducts();

      if(response.responseCode==200){
        _productsList = response.productList ?? [];
        dropdownFocusNode.requestFocus();
        //print("products ${_productsList.length}");
        for(int i = 0; i<_productsList.length;i++){
          //print("barcode ${_productsList[i].barcode} ${_productsList[i].pTitle} ${_productsList[i].pVariation}${_productsList[i].unit}");
        }
      }else{
        _productsList=[];
      }

      log("Products List : ${_productsList.length}");

    }catch(e){
      Exception("getProducts Error : $e");
    }finally{
      _isLoading = false;
      notifyListeners();
    }

  }
  /// ----------- Billing Calculations ---------------

  List<BillingItem> _billingItems = [];
  List<BillingItem> get billingItems => _billingItems;

  ProductData? selectedProduct;

  List<TextEditingController?> variationControllers = [];
  List<TextEditingController?> quantityControllers = [];


  void initializeControllers(List<BillingItem> items) {
    variationControllers = List.generate(
      items.length,
          (_) => TextEditingController(),
    );
    quantityControllers = List.generate(
      items.length,
          (_) => TextEditingController(),
    );
  }

  void setBillingItems(List<BillingItem> items) {
    _billingItems = items;
    initializeControllers(items);
  }

  void initQtyFocusNodes(int count) {
    qtyFocusNodes = List.generate(count, (_) => FocusNode());
  }

  // Add Billing Items : (Add Billing Item From the Header)




  // void addBillingItem(BillingItem newItem) {
  //   print("QTY ${newItem.quantity}");
  //
  //   final existingIndex =
  //   _billingItems.indexWhere((item) => item.product.id == newItem.product.id);
  //
  //   if (existingIndex != -1) {
  //     // 🔁 ALREADY EXISTS → UPDATE QTY / VARIATION
  //     final existingItem = _billingItems[existingIndex];
  //
  //     final updatedItem = BillingItem(
  //       id: existingItem.id,
  //       product: existingItem.product,
  //       productTitle: existingItem.productTitle,
  //       variation: existingItem.product.isLoose == '1'
  //           ? existingItem.variation + newItem.variation
  //           : existingItem.variation,
  //       variationUnit: existingItem.variationUnit,
  //       quantity: existingItem.product.isLoose == '0'
  //           ? existingItem.quantity + newItem.quantity
  //           : existingItem.quantity,
  //       p_out_price: existingItem.p_out_price,
  //       p_mrp: existingItem.p_mrp,
  //     );
  //
  //     _billingItems[existingIndex] = updatedItem;
  //
  //     variationControllers[existingIndex]?.text =
  //         updatedItem.variation.toString();
  //     quantityControllers[existingIndex]?.text =
  //         updatedItem.quantity.toString();
  //   } else {
  //     // 🔥 NEW PRODUCT → INSERT AT TOP
  //     _billingItems.insert(0, newItem);
  //
  //     // 🔥 CONTROLLERS ALSO INSERT AT TOP
  //     variationControllers.insert(
  //       0,
  //       TextEditingController(text: newItem.variation.toString()),
  //     );
  //
  //     quantityControllers.insert(
  //       0,
  //       TextEditingController(text: newItem.quantity.toString()),
  //     );
  //
  //     // 🔥 Focus nodes sync (if using)
  //     initQtyFocusNodes(_billingItems.length);
  //   }
  //
  //   notifyListeners();
  // }  ...reverse

  // Update Temporary Variation or Quantity for a Product (Headers) :
  double temporaryVariation = 1.0;
  int temporaryQuantity = 1;

  // Header Billing
  void updateTemporaryFields({double? variation, int? quantity}) {
    if (variation != null) temporaryVariation = variation;
    if (quantity != null) temporaryQuantity = quantity;
    initQtyFocusNodes(billingItems.length);
    notifyListeners();
  }


  String _variation = "";
  String get variation => _variation;
  void changeVariation(String value){
    _variation = value;
    notifyListeners();
  }
  // void addBillingItem(BillingItem newItem) {
  //   print("QTY ${newItem.quantity}");
  //   // Check if the product already exists in the list
  //   final existingIndex = _billingItems.indexWhere((item) => item.product.id == newItem.product.id);
  //
  //   if (existingIndex != -1) {
  //     // Update the existing item
  //     final existingItem = _billingItems[existingIndex];
  //     initQtyFocusNodes(billingItems.length);
  //     final updatedItem = BillingItem(
  //       id: existingItem.id,
  //       product: existingItem.product,
  //       productTitle: existingItem.productTitle,
  //       variation: existingItem.product.isLoose == '1'
  //           ? existingItem.variation + newItem.variation
  //           : 1,
  //       variationUnit: existingItem.variationUnit,
  //       // quantity: existingItem.product.isLoose == '0'
  //       //     ? existingItem.quantity + newItem.quantity
  //       //     : 1,
  //       quantity: existingItem.product.isLoose == '0'
  //           ? _calculateUpdatedQuantity(existingItem)
  //           : 1,
  //       p_out_price: existingItem.p_out_price,
  //       p_mrp: existingItem.p_mrp,
  //     );
  //
  //     _billingItems[existingIndex] = updatedItem; // Replace the old item
  //     variationControllers[existingIndex]?.text = updatedItem.variation.toString();
  //     quantityControllers[existingIndex]?.text = updatedItem.quantity.toString();
  //   }
  //   else {
  //     // Add the new item if it doesn't exist
  //     _billingItems.add(newItem);
  //
  //     // Initialize controllers for the new item
  //     variationControllers.add(TextEditingController(text: newItem.variation.toString()));
  //     quantityControllers.add(TextEditingController(text: newItem.quantity.toString()));
  //   }
  //
  //   notifyListeners(); // Notify listeners about the change
  // }
  // Update Billing Items : (For Edit Option)
// void updateBillingItem(int index, {required String isLoose, double? variation, int? quantity}) {
  //   if (index < 0 || index >= billingItems.length) {
  //     log("Invalid index: $index");
  //     return; // Exit if index is invalid
  //   }
  //
  //   if (variation != null && isLoose == '1') {
  //     billingItems[index].variation = variation;
  //     initQtyFocusNodes(billingItems.length);
  //     // Ensure the controller exists
  //     if (variationControllers[index] != null) {
  //       variationControllers[index]!.value = TextEditingValue(
  //         text: variation.toString(),
  //         selection: TextSelection.collapsed(offset: variation.toString().length),
  //       );
  //       initQtyFocusNodes(billingItems.length);
  //     } else {
  //       log("Variation controller for index $index is null");
  //     }
  //   }
  //
  //   if (quantity != null && isLoose == '0') {
  //     initQtyFocusNodes(billingItems.length);
  //     billingItems[index].quantity = quantity;
  //
  //     // Ensure the controller exists
  //     if (quantityControllers[index] != null) {
  //       quantityControllers[index]!.value = TextEditingValue(
  //         text: quantity.toString(),
  //         selection: TextSelection.collapsed(offset: quantity.toString().length),
  //       );
  //       initQtyFocusNodes(billingItems.length);
  //     } else {
  //       log("Quantity controller for index $index is null");
  //     }
  //   }
  //   initQtyFocusNodes(billingItems.length);
  //   log("UpdateBillingItem: index=$index, variation=$variation, quantity=$quantity, quantityController=${quantityControllers[index]?.text}");
  //   notifyListeners();
  // }

  void addBillingItem(BillingItem newItem) {

    final existingIndex = _billingItems
        .indexWhere((item) => item.product.id == newItem.product.id);

    if (existingIndex != -1) {

      final item = _billingItems[existingIndex];

      // ---------------- LOOSE PRODUCT ----------------
      if (item.product.isLoose == '1') {
        item.variation += newItem.variation;
      }

      // ---------------- PACKED PRODUCT ----------------
      else {

        bool isOffer = item.product.isFree?.toString() == "1";

        int buy = int.tryParse(item.product.buyQty ?? '') ?? 0;
        int free = int.tryParse(item.product.getQty ?? '') ?? 0;

        if (isOffer && buy > 0 && free > 0) {

          int groupSize = buy + free;

          // increase raw scan count
          item.scanCount += 1;

          // calculate groups
          int groups =
              ((item.scanCount - 1) ~/ groupSize) + 1;

          item.quantity = groups * groupSize;
        }

        // NORMAL PRODUCT
        else {
          item.quantity += 1;
        }
      }

      variationControllers[existingIndex]?.text =
          item.variation.toString();

      quantityControllers[existingIndex]?.text =
          item.quantity.toString();

    } else {

      bool isOffer = newItem.product.isFree?.toString() == "1";

      int buy = int.tryParse(newItem.product.buyQty ?? '') ?? 0;
      int free = int.tryParse(newItem.product.getQty ?? '') ?? 0;

      if (newItem.product.isLoose == '0' &&
          isOffer && buy > 0 && free > 0) {

        newItem.scanCount = 1;

        int groupSize = buy + free;

        newItem.quantity = groupSize;
      }

      _billingItems.add(newItem);

      variationControllers.add(
          TextEditingController(text: newItem.variation.toString()));

      quantityControllers.add(
          TextEditingController(text: newItem.quantity.toString()));
    }

    notifyListeners();
  }

  void updateBillingItem(int index,
      {required String isLoose, double? variation, int? quantity}) {

    if (index < 0 || index >= billingItems.length) {
      log("Invalid index: $index");
      return;
    }

    final item = billingItems[index];

    print("===== MANUAL UPDATE DEBUG START =====");
    print("Product: ${item.product.pTitle}");
    print("Entered quantity: $quantity");
    print("isFree: ${item.product.isFree}");
    print("buyQty: ${item.product.buyQty}");
    print("getQty: ${item.product.getQty}");

    // LOOSE
    if (variation != null && isLoose == '1') {

      item.variation = variation;

      print("Loose updated variation: ${item.variation}");

      variationControllers[index]?.value = TextEditingValue(
        text: variation.toString(),
        selection:
        TextSelection.collapsed(offset: variation.toString().length),
      );
    }

    // PACKED
    if (quantity != null && isLoose == '0') {

      bool isOffer = item.product.isFree?.toString() == "1";

      int buy = int.tryParse(item.product.buyQty ?? '') ?? 0;
      int free = int.tryParse(item.product.getQty ?? '') ?? 0;

      print("Parsed buy: $buy free: $free");

      if (isOffer && buy > 0 && free > 0) {

        int groupSize = buy + free;

        if (quantity <= 0) {
          item.quantity = 0;
          item.scanCount = 0;
        } else {

          int groups =
              ((quantity - 1) ~/ groupSize) + 1;

          item.quantity = groups * groupSize;
          item.scanCount = quantity;

          print("Offer applied (manual)");
          print("groupSize: $groupSize");
          print("groups: $groups");
          print("Final quantity: ${item.quantity}");
        }
      }

      else {
        item.quantity = quantity;
        print("Normal product → quantity set: ${item.quantity}");
      }

      quantityControllers[index]?.value = TextEditingValue(
        text: item.quantity.toString(),
        selection:
        TextSelection.collapsed(offset: item.quantity.toString().length),
      );
    }

    print("===== MANUAL UPDATE DEBUG END =====");

    notifyListeners();
  }


  /// Remove a billing item
  void removeBillingItem({required int index}) {
    if (index < 0 || index >= billingItems.length) return;
    billingItems.removeAt(index);
    variationControllers.removeAt(index);
    quantityControllers.removeAt(index);
    initQtyFocusNodes(billingItems.length);
    calculatedMrpSubtotal();
    calculateTotalItems();
    calculateTotalDiscount();
    calculatedGrandTotal();
    notifyListeners();
  }
  Future<void> saveLastBillToPrefs(OrderData order) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("lastBillOrder", jsonEncode(order.toJson()));

    lastBillOrder = order;
    notifyListeners();
  }
  Future<void> loadLastBillFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString("lastBillOrder");

    if (data != null) {
      lastBillOrder = OrderData.fromJson(jsonDecode(data));
    } else {
      lastBillOrder = null;
    }

    notifyListeners();
  }
  // void removeBillingItem({required int index}) {
  //   if (index < 0 || index >= _billingItems.length) return;
  //
  //   // 🔴 Dispose controllers properly
  //   variationControllers[index]?.dispose();
  //   quantityControllers[index]?.dispose();
  //
  //   // 🔥 Remove same index everywhere
  //   _billingItems.removeAt(index);
  //   variationControllers.removeAt(index);
  //   quantityControllers.removeAt(index);
  //
  //   // 🔄 Recreate focus nodes cleanly
  //   initQtyFocusNodes(_billingItems.length);
  //
  //   // 🔄 Recalculate totals
  //   calculatedMrpSubtotal();
  //   calculateTotalItems();
  //   calculateTotalDiscount();
  //   calculatedGrandTotal();
  //
  //   notifyListeners();
  // }   reverse


  /// Calculate the grand total
  double get grandTotal {
    return billingItems.fold(0.0, (sum, item) => sum + item.calculateSubtotal());
  }

  /// Total No of Billing Items :
  int calculateTotalItems() {
    return billingItems.fold(0, (total, item) => total + item.quantity);
  }

  // Total Discount of Billing Items :
  String calculateTotalDiscount() {
    final totalDiscount = billingItems.fold(0.0,
            (total, item) => total + item.calculateDiscount());

    // log("formattedAmount ${totalDiscount}");

    return totalDiscount.toStringAsFixed(2);   // ⭐ TWO DECIMAL POINTS
  }


  // Grand Total of Billing Items :
  double calculatedGrandTotal() {
    double total = billingItems.fold(
        0.0, (total, item) => total + item.calculateSubtotal());

    return total.roundToDouble();
  }


  String calculatedMrpSubtotal(){
    return TextFormat.formattedAmount(billingItems.fold(0.0, (total, item) => total + item.calculateMrpSubtotal()));
  }

  int calculatedTotalProducts() => billingItems.length;

  int calculatedTotalQuantity() => billingItems.fold(0, (total, item) => total + item.quantity);


  /// --------- Print Bill / Place Order ---------------
  RoundedLoadingButtonController printButtonController = RoundedLoadingButtonController();
  RoundedLoadingButtonController paymentButtonController = RoundedLoadingButtonController();



  // final BillPdf pdfService = BillPdf();

  // Place Order Api :
  Future<void> placeOrderAndPrintBill(
      context, {
        required Order order,
      })
  async {
    try {

      final response = await _placeOrderRepo.placeOrder(
        order: order,
        context: context,
      );

      if (response.responseCode == 200) {
        // 1️⃣ PRINT THE BILL
        bool printSuccess = false;
        try {
          // printSuccess = await pdfService.printBill(
          //   context,
          //   invoiceNo: response.invoiceNo ?? 0,
          // );

        } catch (e) {
          print("PRINT ERROR: $e");
          Toasts.showToastBar(
            context: context,
            text: "Printer error. Try again.",
          );
          printButtonController.reset();
          printAfterChangeButtonController.reset();
          return; // ❌ stop order clear, allow retry
        }

        // 2️⃣ HANDLE PRINT RESULT
        if (!printSuccess) {
          Toasts.showToastBar(
            context: context,
            text: "Printing failed. Check printer.",
          );
          printButtonController.reset();
          printAfterChangeButtonController.reset();
          return;
        }
        // ✅ Print success → refresh products
        if (isWChecked) {
          await getWholeSaleProducts();
        } else {
          await getProducts();
        }
        // 3️⃣ CLOSE POPUP (IF OPEN)
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        // 4️⃣ CLEAR BILL ITEMS AFTER SMALL DELAY
        Future.delayed(const Duration(seconds: 2), () {
          _billingItems = [];
          calculateTotalDiscount();
          calculateTotalItems();
          calculatedGrandTotal();
          final customerProvider =
          Provider.of<CustomersProvider>(context, listen: false);
          customerProvider.clearSelectedCustomer();
          // Clear customer fields
          order.customerName = '';
          order.customerMobile = '';
          order.customerAddress = '';
          paymentReceived.clear();
          quantityControllers.clear();
          dropdownFocusNode.requestFocus();
          notifyListeners();
        });
      }
      else {
        Toasts.showToastBar(
          context: context,
          text: "Couldn't print receipt.",
        );
        printButtonController.reset();
        printAfterChangeButtonController.reset();
        notifyListeners();
      }
    } catch (e) {
      Toasts.showToastBar(
        context: context,
        text: 'Something went wrong. Try again.',
      );
      throw Exception("placeOrder Provider Error: $e");
    } finally {
      printButtonController.reset();
      printAfterChangeButtonController.reset();
      notifyListeners();
    }
  }

  void clearScannedProduct() {
    selectedProduct = null;



    barcodeController.clear();


    notifyListeners();
  }

  Future<void> placeOrderAndSaveBill(
      BuildContext context, {
        required Order order,
      })
  async {
    try {
      final response = await _placeOrderRepo.placeOrder(
        order: order,
        context: context,
      );

      print("response...: ${order.products.length}");
      print("response...rrrr: $response");
      print("response...oed: ${response.responseCode}");
      print("response...oed: ${jsonDecode(order.savings)}");
      print("response...oed: ${jsonDecode(order.savings)}");

      if (response.responseCode == 200) {
        // ✅ SAVE SUCCESS WITHOUT PRINTING
        Toasts.showToastBar(
          context: context,
          text: "Bill saved successfully",
        );

        // Refresh products
        if (isWChecked) {
          getWholeSaleProducts();
        } else {
          getProducts();
        }

        // Close popup if open
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        // Clear bill items after small delay
        Future.delayed(const Duration(seconds: 2), () {
          _billingItems = [];
          calculateTotalDiscount();
          calculateTotalItems();
          calculatedGrandTotal();

          // Clear customer fields
          order.customerName = '';
          order.customerMobile = '';
          order.customerAddress = '';
          paymentReceived.clear();
          quantityControllers.clear();
          dropdownFocusNode.requestFocus();
          notifyListeners();
        });
      } else {
        Toasts.showToastBar(
          context: context,
          text: "Couldn't save the bill.",
        );
      }
    } catch (e) {
      Toasts.showToastBar(
        context: context,
        text: 'Something went wrong. Try again.',
      );
      throw Exception("placeOrder Provider Error: $e");
    } finally {
      notifyListeners();
    }
  }

// Focus Nodes
  List<FocusNode> quantityFocusNodes = [];
  FocusNode productSearchFocusNode = FocusNode();

// Initialize focus nodes
  void initQuantityFocusNodes(int length) {
    quantityFocusNodes = List.generate(length, (_) => FocusNode());
  }



  void clearBillingData(BuildContext context) {
    initQtyFocusNodes(billingItems.length);
    _billingItems = [];
    calculateTotalDiscount();
    quantityController.clear();
    quantityControllers.clear();
    calculateTotalItems();
    calculatedGrandTotal();
    dropdownFocusNode.requestFocus();
    Provider.of<CustomersProvider>(context,listen: false).resetCustomerDetails();
    paymentReceived.clear();
  }

  bool _barcodeMode = false;
  bool get barcodeMode => _barcodeMode;

  void barcodeModeChange(){
    _barcodeMode =! _barcodeMode;
    notifyListeners();
  }
  void findProductByBarcode(BuildContext context,String barcode) {
    try {
      final product = productsList.firstWhere((p) => p.barcode == barcode);

      selectedProduct = product;
      print("selectedProduct ${selectedProduct!.pTitle}");
      barcodeScanner.text = selectedProduct!.pTitle.toString();
      updateTemporaryFields(
        variation: product.isLoose == '1' ? 1.0 : null,
        quantity: product.isLoose == '0' ? 1 : null,
      );

      notifyListeners();
    } catch (e) {
      Toasts.showToastBar(context: context, text: "Please scan correct barcode..",color: Colors.red);
      // Product not found — you can log or show a message if needed
    }
  }


  // List<FocusNode> billMethodFocusNodes = List.generate(3, (_) => FocusNode());
  // String? selectBillMethod = "Cash";

  String? selectedCreditPeriod;

  void changeCreditPeriod(String period) {
    selectedCreditPeriod = period;
    notifyListeners();
  }
  /// --------- Payment Box ----------------
  RoundedLoadingButtonController paymentBalanceButtonController = RoundedLoadingButtonController();
  RoundedLoadingButtonController printAfterChangeButtonController = RoundedLoadingButtonController();
  RoundedLoadingButtonController printAfterChangeButtonControllerHold = RoundedLoadingButtonController();
  RoundedLoadingButtonController printAfterChangeButtonControllerSave = RoundedLoadingButtonController();

  TextEditingController paymentReceived = TextEditingController();
  TextEditingController upiPayment = TextEditingController();
  // TextEditingController paymentBalance = TextEditingController();
  TextEditingController barcodeScanner = TextEditingController();
  TextEditingController barcodeController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  List<Map<String, dynamic>> scannedStocks = [];
  ValueNotifier<TextEditingValue> paymentBalance =
  ValueNotifier(TextEditingValue(text: "0"));

  void updateBalance(double total, double cash, double upi) {
    double balance = total - (cash + upi);

    paymentBalance.value = TextEditingValue(
      text: balance.toStringAsFixed(2),
    );
  }

  // Calculate Payment Balance
  void calculatePaymentBalance() {
    double total = calculatedGrandTotal(); // Total bill amount

    // Parse the amounts from the fields
    double cash = double.tryParse(paymentReceived.text.trim()) ?? 0.0;
    double upi = double.tryParse(upiPayment.text.trim()) ?? 0.0;

    // Calculate total received based on payment method
    double received = 0.0;

    if (selectBillMethod == "Split Payment") {
      received = cash + upi;  // Both together
    } else if (selectBillMethod == "UPI") {
      received = upi;          // Only UPI
    } else {
      received = cash;         // Onl8444000000003

      // y cash
    }

    // Calculate balance → positive if extra paid, negative if less paid
    double balance = received - total;

    // Update the ValueNotifier
    paymentBalance.value = TextEditingValue(
      text: balance.toStringAsFixed(2),
    );
  }


  // void calculatePaymentBalance() {
  //   try {
  //     if(paymentReceived.text.isEmpty){
  //       _paymentBalanceAmount = '0';
  //       paymentBalance.text = '0';
  //     }else{
  //       int receivedAmount = int.tryParse(paymentReceived.text.trim()) ?? 0;
  //       int grandTotal = calculatedGrandTotal().toInt();
  //       _paymentBalanceAmount = (receivedAmount - grandTotal).toString();
  //       paymentBalance.text = _paymentBalanceAmount;
  //     }
  //   } catch (e) {
  //     _paymentBalanceAmount = '0';
  //     paymentBalance.text = '0';
  //   }
  // }

  void updateSplitAmounts() {
    double total = calculatedGrandTotal();

    double upi = double.tryParse(upiPayment.text.trim()) ?? 0.0;

    double cash = total - upi;

    paymentReceived.text = cash < 0 ? "0" : cash.toStringAsFixed(2);

    calculatePaymentBalance();
  }
  final FocusNode keyboardListenerFocusNode = FocusNode();
  final billMethodFocusNode   = FocusNode();


  bool _isRefresh = true;
  bool get isRefresh => _isRefresh;
  List<OrderData> _lastOrder = [];
  List<OrderData> _allOrders = [];
  List<OrderData> _searchAllOrders = [];
  List<OrderData> get allOrders => _allOrders;
  List<OrderData> get searchAllOrders => _searchAllOrders;
  List<OrderData> get lastOrder => _lastOrder;

  List<OrderData> allCashOrders = [];
  List<OrderData> filteredOrders = [];
  double get filteredTotal {
    return filteredOrders.fold<double>(
      0.0,
          (sum, item) {
        final raw = item.oTotal;

        if (raw == null) return sum;

        final value = double.tryParse(raw.toString());
        if (value == null) return sum;

        return sum + value;
      },
    );
  }

  double _amount(dynamic raw) {
    if (raw == null) return 0.0;
    return double.tryParse(raw.toString()) ?? 0.0;
  }
  double get allPaymentTotal {
    return allOrders
        .where((e) =>
    e.pMethodId == '1' || // UPI
        e.pMethodId == '2' || // CASH
        e.pMethodId == '3' || // CREDIT
        e.pMethodId == '4')   // CARD
        .fold<double>(
      0.0,
          (sum, item) => sum + _amount(item.oTotal),
    );
  }
  double get cashTotal {
    return filteredOrders
        .where((e) => e.pMethodId == '2')
        .fold<double>(
      0.0,
          (sum, item) => sum + _amount(item.oTotal),
    );
  }
  double get upiTotal {
    return filteredOrders
        .where((e) => e.pMethodId == '1')
        .fold<double>(
      0.0,
          (sum, item) => sum + _amount(item.oTotal),
    );
  }
  void filterByPaymentMethodId(int methodId) {
    _searchAllOrders = _allOrders.where((order) {
      return int.tryParse(order.pMethodId.toString()) == methodId;
    }).toList();

    notifyListeners();
  }
  double get creditTotal {
    return filteredOrders
        .where((e) => e.pMethodId == '3')
        .fold<double>(
      0.0,
          (sum, item) => sum + _amount(item.oTotal),
    );
  }
  double get creditCardTotal {
    return filteredOrders
        .where((e) => e.pMethodId == '4')
        .fold<double>(
      0.0,
          (sum, item) => sum + _amount(item.oTotal),
    );
  }
  void applySearch() {
    filteredOrders = allOrders.where((order) {
      final nameMatch = order.name
          ?.toLowerCase()
          .contains(searchName.text.toLowerCase());

      final billMatch = order.invoiceNo
          .toString()
          .contains(bill.text);

      final amountMatch = order.oTotal
          .toString()
          .contains(searchAmount.text);

      return nameMatch! && billMatch && amountMatch;
    }).toList();

    notifyListeners();
  }



  final TextEditingController searchName   = TextEditingController();
  final TextEditingController searchAmount = TextEditingController();
  final TextEditingController bill = TextEditingController();
  final TextEditingController searchProd   = TextEditingController();
  Future<void> getAllOrderDetails(String stDate, String enDate) async {
    try {
      _isRefresh = false;
      _allOrders = [];
      _searchAllOrders = [];
      notifyListeners();

      final response = await _placeOrderRepo.getOrderDetails(
        stDate: stDate,
        enDate: enDate,
      );

      if (response.responseCode == 200) {
        _allOrders = response.ordersList ?? [];

        // 🔥 IMPORTANT: SORT FIRST (morning → night)
        _allOrders.sort((a, b) {
          final DateTime aTime =
          DateTime.parse(a.createdTs.toString());
          final DateTime bTime =
          DateTime.parse(b.createdTs.toString());

          return aTime.compareTo(bTime); // ASCENDING
        });

        // 🔍 search list also same order
        _searchAllOrders = List.from(_allOrders);

        applySearch(); // ✅ AFTER sorting
        _isRefresh = true;
      } else {
        _isRefresh = true;
        _allOrders = [];
        _searchAllOrders = [];
      }
    } catch (e) {
      _isRefresh = true;
      _allOrders = [];
      _searchAllOrders = [];
      throw Exception(e);
    } finally {
      _isRefresh = true;
      notifyListeners();
    }
  }
  // OrderData? getLastOrderByCustomer(String customerId) {
  //   final list = _allOrders.where((o) {
  //     return o.uId.toString() == customerId.toString();
  //   }).toList();
  //
  //   if (list.isEmpty) return null;
  //
  //   // latest order = last element (because you sorted ASC)
  //   return list.last;
  // }
  void setLastBillToBilling(OrderData order) {
    _billingItems.clear();
    variationControllers.clear();
    quantityControllers.clear();

    /// 🔥 order la products string format la iruku (productTitles, productQuantity, productOutPrice...)
    final titles = (order.productTitles ?? "").split(",");
    final qtyList = (order.productQuantity ?? "").split(",");
    final priceList = (order.productOutPrice ?? "").split(",");
    final mrpList = (order.productMrp ?? "").split(",");
    final unitList = (order.productUnit ?? "").split(",");

    for (int i = 0; i < titles.length; i++) {
      final title = titles[i].trim();

      final qty = (i < qtyList.length)
          ? int.tryParse(qtyList[i].trim()) ?? 1
          : 1;

      final price = (i < priceList.length)
          ? double.tryParse(priceList[i].trim()) ?? 0
          : 0;

      final mrp = (i < mrpList.length)
          ? double.tryParse(mrpList[i].trim()) ?? 0
          : 0;

      final unit = (i < unitList.length) ? unitList[i].trim() : "";

      /// ⚠️ Find product from your productsList
      ProductData? product;
      try {
        product = productsList.firstWhere(
              (p) => (p.pTitle ?? "").trim().toLowerCase() == title.toLowerCase(),
        );
      } catch (_) {
        product = null;
      }

      if (product == null) continue;

      final newItem = BillingItem(
        product: product,
        quantity: qty,
        variation: 0,
        id: '',
        productTitle: title,
        variationUnit: unit,
        p_out_price: price.toString(),
        p_mrp: mrp.toString(),
      );

      _billingItems.add(newItem);

      variationControllers.add(TextEditingController(text: "0"));
      quantityControllers.add(TextEditingController(text: qty.toString()));
    }

    initQtyFocusNodes(_billingItems.length);

    calculatedMrpSubtotal();
    calculateTotalItems();
    calculateTotalDiscount();
    calculatedGrandTotal();

    notifyListeners();
  }
  OrderData? getLastOrderByCustomer(String customerId) {
    try {
      final customerOrders = _allOrders
          .where((order) => order.uId == customerId)
          .toList();

      if (customerOrders.isEmpty) return null;

      customerOrders.sort((a, b) =>
          DateTime.parse(b.createdTs!)
              .compareTo(DateTime.parse(a.createdTs!)));

      return customerOrders.first; // latest order
    } catch (e) {
      return null;
    }
  }


  int totalOrders = 0;
  int orderPlaced = 0;
  int processing = 0;
  int packed = 0;
  int deliveryPersonAssigned = 0;
  int outForDelivery = 0;
  int completed = 0;
  int cancelled = 0;

  OrderStatusCountModel? _orderStatusData;
  OrderStatusCountModel? get orderStatusData => _orderStatusData;

  /// Fetch order status count
  Future<void> getAllOnlineOrderDetails(String stDate, String enDate) async {
    try {
      _isRefresh = false;
      notifyListeners();

      final response = await _placeOrderRepo.getOnlineOrderDetails(
        stDate: stDate,
        enDate: enDate,
      );
      print("ONLINE ORDER RESPONSE 123 : ${response.toString()}");
      if (response.responseCode == 200) {
        print("ONLINE ORDER RESPONSE : ${response.toString()}");
        print("RESPONSE CODE : ${response.responseCode}");
        print("DATA : ${response.data}");
        _orderStatusData = response.data;

        totalOrders = _orderStatusData?.totalOrders ?? 0;
        orderPlaced = _orderStatusData?.orderPlaced ?? 0;
        processing = _orderStatusData?.processing ?? 0;
        packed = _orderStatusData?.packed ?? 0;
        deliveryPersonAssigned =
            _orderStatusData?.deliveryPersonAssigned ?? 0;
        outForDelivery = _orderStatusData?.outForDelivery ?? 0;
        completed = _orderStatusData?.completed ?? 0;
        cancelled = _orderStatusData?.cancelled ?? 0;
        calculateStatusCounts();
      } else {
        clearCounts();
      }

      _isRefresh = true;
      notifyListeners();

    } catch (e) {

      _isRefresh = true;
      clearCounts();
      notifyListeners();

      throw Exception("Provider Error: $e");
    }
  }

  /// Reset counts
  void clearCounts() {
    totalOrders = 0;
    orderPlaced = 0;
    processing = 0;
    packed = 0;
    deliveryPersonAssigned = 0;
    outForDelivery = 0;
    completed = 0;
    cancelled = 0;
  }

  Future<void> getLastOrderDetails(context)
  async {
    try {
      _lastOrder = [];
      notifyListeners();
      final response = await _placeOrderRepo.getLastOrderDetails();

      if(response.responseCode == '200'){
        _lastOrder = response.ordersList ?? [];
        log("_lastOrder.toString()");
        log(_lastOrder.toString());
        // await pdfService.printCustomBill(
        //     context,
        //     data: _lastOrder[0]);
      }else {
        _lastOrder = [];
      }
    } catch (e) {
      _lastOrder = [];
      throw Exception(e);
    }finally{
      _isRefresh=true;
      notifyListeners();
    }
  }
  Timer? _debounce;

  String _nameQuery = '';
  String _totalQuery = '';
  String _productQuery = '';
  String _billQuery = '';

  void setSearchQuery({
    String? name,
    String? total,
    String? product,
    String? bill,
  })
  {
    // Update values immediately
    if (name != null) _nameQuery = name.toLowerCase();
    if (total != null) _totalQuery = total.toLowerCase();
    if (product != null) _productQuery = product.toLowerCase();
    if (bill != null) _billQuery = bill.toLowerCase();

    // 🔥 Debounce filtering
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 2500), () {
      applySearch(); // ✅ HERE
      _filterOrders();
    });
  }
  void _filterOrders() {
    _allOrders = _searchAllOrders.where((order) {
      final nameMatch =
          order.name?.toLowerCase().contains(_nameQuery) ?? false;

      final billMatch =
          order.invoiceNo?.toLowerCase().contains(_billQuery) ?? false;

      bool totalMatch = true;
      if (_totalQuery.isNotEmpty) {
        final totalString = order.oTotal ?? '';
        // ✅ Check if the total contains the search text
        totalMatch = totalString.contains(_totalQuery);
      }

      final productMatch =
          order.productTitles?.toLowerCase().contains(_productQuery) ?? false;

      return (_nameQuery.isEmpty || nameMatch) &&
          (_totalQuery.isEmpty || totalMatch) &&
          (_productQuery.isEmpty || productMatch) &&
          (_billQuery.isEmpty || billMatch);
    }).toList();
    applySearch(); // ✅ HERE
    notifyListeners();
  }



  void searchOrders(String value) {
    final suggestions = _searchAllOrders.where((user) {
      final name = user.name?.toLowerCase() ?? '';
      final oTotal = user.oTotal?.toLowerCase() ?? '';
      final productTitles = user.productTitles?.toLowerCase() ?? '';

      // Format the oDate to dd-MM-yyyy
      String formattedDate = '';
      if (user.oDate != null && user.oDate!.isNotEmpty) {
        try {
          DateTime parsedDate = DateTime.parse(user.oDate!);
          formattedDate = DateFormat('dd-MM-yyyy').format(parsedDate).toLowerCase();
        } catch (e) {
          // If parse fails, fallback to raw string
          formattedDate = user.oDate!.toLowerCase();
        }
      }

      final input = value.toLowerCase();

      return name.contains(input) ||
          formattedDate.contains(input) ||
          oTotal.contains(input) ||
          productTitles.contains(input);
    }).toList();

    _allOrders = suggestions;
    notifyListeners();
  }
  String formatDate(String dateString) {
    DateTime date = DateTime.parse(dateString);
    String formatted = DateFormat('dd-MM-yyyy').format(date);
    return formatted;
  }
  String formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);

    // 12-hour format with AM/PM
    return DateFormat('dd-MM-yyyy  hh:mm a').format(dateTime);
  }
  // void updateExistingBillingItem(BillingItem updatedItem) {
  //   final index = _billingItems.indexWhere((item) => item.id == updatedItem.id);
  //   if (index != -1) {
  //     _billingItems[index] = updatedItem;
  //     notifyListeners();
  //   }
  // }
  void updateExistingBillingItem(BillingItem item) {
    final index = billingItems.indexWhere((it) => it.id == item.id);
    if (index != -1) {
      billingItems[index] = item;
      notifyListeners(); // 👈 VERY IMPORTANT
    }
  }

  Future<void> updateBillStatus(BuildContext context, String invoiceNo,{required OrderData data}) async {
    _isLoading = true;
    notifyListeners();

    final response = await _placeOrderRepo.updateBillStatus(invoiceNo);

    _isLoading = false;
    notifyListeners();

    if (response['status'] == true) {
      // final BillPdf pdfService = BillPdf();
      // await pdfService.printCustomBill(context, data: data);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text(response['message'] ?? 'Update successful')),
      // );
      DateTime today = DateTime.now();
      DateTime tomorrow = today.add(const Duration(days: 1));
      String todayStr = DateFormat('yyyy-MM-dd').format(today);
      String tomorrowStr = DateFormat('yyyy-MM-dd').format(tomorrow);
      getAllOrderDetails(todayStr,tomorrowStr);
      getAllOnlineOrderDetails(todayStr,tomorrowStr);
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Update failed')),
      );
    }
  }

  String message = '';
  Map<int, int> updatedQuantities = {}; // productId -> updated qty

  Future<void> updateStock(List<StockProduct> products,BuildContext context) async {
    try {
      // isLoading = true;
      notifyListeners();

      final result = await _placeOrderRepo.updateStock(products: products);
      print("response2: ${result['responseCode'] == 200}");
      if (result['result'] == "Success") {
        Navigator.pop(context);
        snackBar(context: context, msg: "Return Quantity added successfully", color: Colors.green);
        if (result['updated_qty'] != null) {
          updatedQuantities = Map<int, int>.from(result['updated_qty']);
        }
        if (isWChecked) {
          getWholeSaleProducts();
        } else {
          getProducts();
        }
      } else {
        message = result['responseMsg'] ?? 'Failed to update stock';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      message = e.toString();
    } finally {
      //  isLoading = false;
      notifyListeners();
    }
  }
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> snackBar(
      {required BuildContext context,
        required String msg,
        required Color color}) {
    var snack = SnackBar(
        width: 500,
        content: Center(child: Text(msg)),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        backgroundColor: color,
        //margin: const EdgeInsets.all(50),
        elevation: 30,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))));
    return ScaffoldMessenger.of(context).showSnackBar(
      snack,
    );
  }
  // Setter
  set billingItems(List<BillingItem> items) {
    _billingItems = items;
    initQtyFocusNodes(billingItems.length);
    notifyListeners();
  }

  // Optional: helper method


  // Future<void> saveHoldBillDetails({required Order order}) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final orderData = jsonEncode(order.toJson());
  //   await prefs.setString('holdBill', orderData);
  //   print("Hold Bill saved successfully");
  // }
  // Future<void> loadHoldBillDetails() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final data = prefs.getString('holdBill');
  //
  //   if (data != null && data.isNotEmpty) {
  //     final order = Order.fromJson(jsonDecode(data));
  //     // ✅ Restore data into your provider’s fields
  //     selectBillMethod = order.paymentMethod;
  //     paymentReceived.text = order.receivedAmt;
  //     billingItems = order.products;
  //     // ...assign other fields like customer details, etc.
  //     notifyListeners();
  //   }
  // }

  List<List<BillingItem>> heldBills = [];


  List<Order> heldOrders = [];

  // ✅ Save (Hold) current order
  Future<void> saveHoldBillDetails({required Order order, required BuildContext context}) async {
    final prefs = await SharedPreferences.getInstance();

    // Load existing held orders
    final existingData = prefs.getStringList('heldOrders') ?? [];

    // Add new order JSON
    final newOrderJson = jsonEncode(order.toJson());
    existingData.add(newOrderJson);

    // Save back to prefs
    await prefs.setStringList('heldOrders', existingData);

    // Update local list
    heldOrders.add(order);
    billingItems.clear();

    // 🔹 Clear customer properly
    Provider.of<CustomersProvider>(context, listen: false)
        .clearSelectedCustomer();
    dropdownFocusNode.requestFocus();
    // clear current bill after holding
    notifyListeners();
  }

  // ✅ Load held bills from SharedPreferences (called on app start)
  Future<void> loadHeldBillsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final storedList = prefs.getStringList('heldOrders') ?? [];

    heldOrders = storedList
        .map((billString) => Order.fromJson(jsonDecode(billString)))
        .toList();

    notifyListeners();
  }



  // ✅ Check if any held bills exist
  bool hasHeldBills() => heldOrders.isNotEmpty;

  Future<void> releaseHeldBill(int index) async {
    if (index < 0 || index >= heldOrders.length) return;

    final order = heldOrders[index];

    /// ✅ DEEP COPY products
    billingItems = order.products.map((p) => p.copyWith()).toList();

    /// 🔥🔥🔥 CREATE & SYNC QUANTITY CONTROLLERS (MAIN FIX)
    quantityControllers =
        List.generate(billingItems.length, (_) => TextEditingController());

    for (int i = 0; i < billingItems.length; i++) {
      final item = billingItems[i];

      if (item.product.isLoose == '1') {
        // grams → kg (UI value)
        quantityControllers[i]?.text =
            (item.variation / 1000).toStringAsFixed(3);
      } else {
        quantityControllers[i]?.text =
            item.quantity.toString();
      }
    }

    /// ✅ restore payment info
    paymentReceived.text = order.receivedAmt;
    selectBillMethod = order.paymentMethod;

    /// ✅ clear dropdown selection
    selectedProduct = null;


    /// ✅ remove from hold list
    heldOrders.removeAt(index);

    /// ✅ save updated held list
    final prefs = await SharedPreferences.getInstance();
    final updatedList =
    heldOrders.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('heldOrders', updatedList);

    /// ✅ focus ready for next scan
    dropdownFocusNode.requestFocus();

    notifyListeners();
  }


  double safeDouble(value) {
    if (value == null) return 0.0;
    if (value.toString().trim().isEmpty) return 0.0;
    return double.tryParse(value.toString()) ?? 0.0;
  }


  double calculateTotalGST() {
    return billingItems.fold(
      0.0,
          (sum, item) => sum + (double.tryParse(item.product.sgst.toString()) ?? 0.0),
    );
  }

// ===========================
//   Add inside BillingProvider
// ===========================

  int? selectedRow;

  void selectRow(int index) {
    selectedRow = index;
    notifyListeners();
  }

  List<Category> categories = [];


  bool loading = false;

  /// NEW FIELDS
  String unitWeight = "Kg";     // Kg / Litre / Piece
  String pVariation = "1";      // default 1
  String? selectedCategoryId;
  String? selectedSubCategoryId;


  void setUnitWeight(String val) {
    unitWeight = val;
    notifyListeners();
  }

  int isLoose = 0; // 0 = No, 1 = Yes

  void setLoose(int val) {
    isLoose = val;
    notifyListeners();
  }

  Future<void> fetchCategories() async {
    loading = true;
    notifyListeners();

    categories = await PlaceOrderRepository.getCategories();

    loading = false;
    notifyListeners();
  }

  // void setCategory(Category category) {
  //   selectedCategoryId = category.id;   // ✅
  //   selectedSubCategoryId = null;       // ✅ reset
  //   notifyListeners();
  // }
  //
  // void setSubCategory(SubCategory subCategory) {
  //   selectedSubCategoryId = subCategory.id; // ✅
  //   notifyListeners();
  // }
  /// SET CATEGORY
  void setCategory(String id) {
    selectedCategoryId = id;
    selectedSubCategoryId = null; // 🔥 important
    notifyListeners();
  }

  /// SET SUB CATEGORY
  void setSubCategory(String id) {
    selectedSubCategoryId = id;
    notifyListeners();
  }

  /// CLEAR (insert success apram use pannalam)
  void clearSelection() {
    selectedCategoryId = null;
    selectedSubCategoryId = null;
    notifyListeners();
  }

  Category? get selectedCategory =>
      categories.firstWhereOrNull(
            (c) => c.id == selectedCategoryId,
      );

  SubCategory? get selectedSubCategory =>
      selectedCategory?.subcategories.firstWhereOrNull(
            (s) => s.id == selectedSubCategoryId,
      );

  /// controllers
  final title = TextEditingController();
  final variations = TextEditingController();
  final units = TextEditingController();
  final sku = TextEditingController();
  final barcode = TextEditingController();
  final qty = TextEditingController();
  final mrp = TextEditingController();
  final outPrice = TextEditingController();
  final inPrice = TextEditingController();

  Future<void> insert_product(BuildContext context) async {
    final catProv = context.read<BillingProvider>();

    if (catProv.selectedCategory == null ||
        catProv.selectedSubCategory == null) {
      _toast(context, "Select Category & Sub Category");
      return;
    }
    print("barcode: ${barcode.text.trim()}");
    final int qtyVal = int.tryParse(qty.text.trim()) ?? 0;
    final double mrpVal = double.tryParse(mrp.text.trim()) ?? 0;
    final double outPriceVal = double.tryParse(outPrice.text.trim()) ?? 0;
    final double inPriceVal = double.tryParse(inPrice.text.trim()) ?? 0;

    if (
    mrpVal <= outPriceVal ||
        inPriceVal >= outPriceVal) {
      _toast(context, "Check price values");
      return;
    }

    loading = true;
    notifyListeners();

    final success = await PlaceOrderRepository.insertProduct({
      "action": "insert_product",
      "p_title": title.text.trim(),
      "cat_id": catProv.selectedCategory!.id.toString(),
      "sub_cat_id": catProv.selectedSubCategory!.id.toString(),
      "sku_id": sku.text.trim(),
      "barcode": barcode.text.trim(),
      "unit_weight": units.text.trim(),
      "p_variation": isLoose == 1
          ? "Loose"
          : variations.text.trim(),
      "is_loose": isLoose.toString(),
      "qty": qtyVal,
      "mrp": mrpVal,
      "out_price": outPriceVal,
      "in_price": inPriceVal,
    });

    loading = false;
    notifyListeners();
    if (success) {
      Navigator.pop(context);
      clearProductForm();
      if (isWChecked) {
        getWholeSaleProducts();
      } else {
        getProducts();
      }
      _toast(context, "Product Added Successfully");
    } else {
      _toast(context, "Product Added Failed");
    }
  }


  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
  void clearProductForm() {
    title.clear();
    sku.clear();
    barcode.clear();
    units.clear();
    variations.clear();
    qty.clear();
    mrp.clear();
    outPrice.clear();
    inPrice.clear();

    clearSelection();

    isLoose = 0; // or default value
  }

  bool validatePrices(BillingProvider p, BuildContext context) {
    // ---------- BASIC TEXT VALIDATION ----------
    if (p.title.text.trim().isEmpty) {
      utils.showToast("Enter Product Name",Colors.red);
      return false;
    }

    if (p.sku.text.trim().isEmpty) {
      utils.showToast("Enter HSN Code",Colors.red);
      return false;
    }

    if (p.barcode.text.trim().isEmpty) {
      utils.showToast("Barcode is required",Colors.red);
      return false;
    }

    // ---------- CATEGORY ----------
    if (p.selectedCategory == null) {
      utils.showToast("Select Category",Colors.red);
      return false;
    }

    if (p.selectedSubCategory == null) {
      utils.showToast("Select Sub Category",Colors.red);
      return false;
    }

    // ---------- VARIATION / UNIT ----------
    if (p.isLoose == 1) {
      // Loose product
      if (p.variations.text.trim().isEmpty) {
        p.variations.text = "Loose"; // 🔥 auto set
      }
    }

    if (p.units.text.trim().isEmpty) {
      utils.showToast("Enter Unit",Colors.red);
      return false;
    }

    // ---------- PRICE VALIDATION ----------
    final double? mrp = double.tryParse(p.mrp.text);
    final double? outPrice = double.tryParse(p.outPrice.text);
    final double? inPrice = double.tryParse(p.inPrice.text);

    if (mrp == null ) {
      utils.showToast("Enter valid  Mrp price values",Colors.red);
      return false;
    }

    if (outPrice == null ) {
      utils.showToast("Enter valid out price values",Colors.red);
      return false;
    }

    if ( inPrice == null) {
      utils.showToast("Enter valid In-price values",Colors.red);
      return false;
    }

    if (mrp <= 0 || outPrice <= 0 || inPrice <= 0) {
      utils.showToast("Price must be greater than zero",Colors.red);
      return false;
    }

    // MRP > Out Price
    if (mrp <= outPrice) {
      utils.showToast("MRP must be greater than Out Price",Colors.red);
      return false;
    }

    // In Price < Out Price
    if (inPrice >= outPrice) {
      utils.showToast("In Price must be less than Out Price",Colors.red);
      return false;
    }

    // ---------- LOOSE ----------
    if (p.isLoose != 0 && p.isLoose != 1) {
      utils.showToast("Select Loose Product (Yes / No)",Colors.red);
      return false;
    }

    return true; // ✅ ALL OK
  }

  void showErrorSnackBar( String msg,BuildContext context,) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }
  int placedCount = 0;
  int pendingCount = 0;
  int packedCount = 0;
  int deliveryCount = 0;
  int completedCount = 0;
  int cancelledCount = 0;
  void calculateStatusCounts() {

    placedCount = 0;
    pendingCount = 0;
    packedCount = 0;
    deliveryCount = 0;
    completedCount = 0;
    cancelledCount = 0;

    for (var order in _allOrders) {

      switch(order.status) {

        case "placed":
          placedCount++;
          break;

        case "pending":
          pendingCount++;
          break;

        case "packed":
          packedCount++;
          break;

        case "out_for_delivery":
          deliveryCount++;
          break;

        case "completed":
          completedCount++;
          break;

        case "cancelled":
          cancelledCount++;
          break;
      }
    }

    notifyListeners();
  }
  String _randomBarcode() {
    final rnd = DateTime.now().millisecondsSinceEpoch;
    return rnd.toString().substring(4, 13); // 9–10 digit barcode
  }

  Future<void> generateUniqueBarcode(BuildContext context) async {
    final prodProv = context.read<BillingProvider>();

    for (int i = 0; i < 5; i++) { // 🔁 max 5 attempts
      final newBarcode = _randomBarcode();

      final exists = await checkBarcodeExists(newBarcode);

      // 🔍 DEBUG PRINT
      debugPrint("🔎 Checking barcode: $newBarcode");
      debugPrint("📦 Exists in DB? : $exists");

      if (!exists) {
        // ✅ NOT EXISTS → SAFE TO USE
        debugPrint("✅ Barcode NOT found in table. Using this one.");

        prodProv.barcode.text = newBarcode;
        prodProv.barcode.selection = TextSelection.collapsed(
          offset: newBarcode.length,
        );

        return;
      } else {
        // ❌ EXISTS
        debugPrint("❌ Barcode already exists. Trying next...");
      }
    }

    // ❌ FAILED ALL ATTEMPTS
    debugPrint("🚫 Failed to generate unique barcode after 5 tries");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("❌ Failed to generate unique barcode"),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<bool> checkBarcodeExists(String barcode) async {
    try {
      final res = await PlaceOrderRepository.checkBarcode({
        "action": "b_select_barcode",
        "barcode": barcode,
      });

      // Backend must return: { "exists": true / false }
      return res["exists"] == true;

    } catch (e) {
      debugPrint("Barcode check error: $e");

      // 🔥 API fail-na barcode allow pannalaam
      return false;
    }
  }
  String _responseMessage = '';
  Future<void> cancelOrder(String orderId,BuildContext context) async {
    _isLoading = true;
    _responseMessage = '';
    notifyListeners(); // Notify the UI to show loading indicator

    // Assuming you are calling the cancelOrder API from a repository
    final response = await _placeOrderRepo.cancelOrder(orderId);

    // Check the response
    if (response['ResponseCode'] == '200') {
      _responseMessage = "Order canceled successfully!";
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Order canceled successfully!"),
          backgroundColor: Colors.red,
        ),
      );
      final today = DateTime.now();
      final tomorrow = today.add(const Duration(days: 1));

      getAllOrderDetails(
        DateFormat('yyyy-MM-dd').format(today),
        DateFormat('yyyy-MM-dd').format(tomorrow),
      );
      getAllOrderDetails(
        DateFormat('yyyy-MM-dd').format(today),
        DateFormat('yyyy-MM-dd').format(tomorrow),
      );

      print("Order$_responseMessage");
    } else {
      _responseMessage = response['ResponseMsg'] ?? "Failed to cancel the order.";
      print("$_responseMessage");
    }
    _isLoading = false;
    notifyListeners(); // Notify the UI after loading is done
  }

  Future<void> getDataByDate(String date) async {
    print("Selected Date: $date");

    stDate = date;

    notifyListeners();
  }

  bool isWChecked = false;

  void setWChecked(bool value) {
    isWChecked = value;
    notifyListeners();
  }



}
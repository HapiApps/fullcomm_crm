import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/common/utilities/jwt_storage.dart';
import 'package:fullcomm_crm/models/office_hours_obj.dart';
import 'package:fullcomm_crm/models/role_obj.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common/constant/api.dart';
import '../common/constant/colors_constant.dart';
import '../common/utilities/utils.dart';
import '../common/widgets/log_in.dart';
import '../components/custom_loading_button.dart';
import '../components/custom_text.dart';
import '../components/custom_textfield.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../models/template_obj.dart';
import '../services/api_services.dart';
import 'controller.dart';

final productCtr = Get.put(ProductController());

class ProductController extends GetxController with GetSingleTickerProviderStateMixin {


  var selectedProductId="".obs;
  var selectedProductName="".obs;
  void selectProduct(ProductModel c) {
    print("productsList");
    print(productsList);
    selectedProductId.value = c.id.toString();
    selectedProductName.value = c.title.toString();
    controllers.search.text = c.title ?? "";
    productsList.value.add(c);
    controllers.search.clear();
    productsList.refresh();
  }
  void clearProduct() {
    selectedProductId.value = "";
    selectedProductName.value = "";
    controllers.search.clear();
    // productsList.value.remove(value);
  }

  final TextEditingController title = TextEditingController();
  final TextEditingController description = TextEditingController();
  final TextEditingController availability = TextEditingController();
  final TextEditingController condition = TextEditingController();
  final TextEditingController price = TextEditingController();
  final TextEditingController brand = TextEditingController();
  final RoundedLoadingButtonController saveCtr = RoundedLoadingButtonController();
  Rxn<PlatformFile> selectedFile = Rxn<PlatformFile>();
  var searchProspects = ''.obs;
  RxString selectedProspectTemperature = "".obs;
  RxString selectedQualifiedSortBy = "All".obs;
  var sortField = ''.obs;
  var sortOrder = 'asc'.obs;
  var sortOrderN = 'asc'.obs;
  var currentProspectPage = 1.obs;
  final itemsProspectPerPage = 20;
  var  totalProspectPages =0.obs;
  final itemsPerPage = 20; // Adjust based on your needs

  List<ProductModel> changeProductPage(RxList<ProductModel> list,RxList<ProductModel> list2){
    final query = searchProspects.value.trim().toLowerCase();
    final ratingFilter = selectedProspectTemperature.value;
    final sortBy = selectedQualifiedSortBy.value; // 'Today', 'Last 7 Days', etc.
    final now = DateTime.now();

    final filteredLeads = list2.value.where((lead) {
      final matchesQuery = (lead.title ?? '').toLowerCase().contains(query);
      return matchesQuery;
    }).toList();

    if (sortField.isNotEmpty) {
      filteredLeads.sort((a, b) {
        dynamic getFieldValue(ProductModel lead, String field) {
          switch (field) {
            case 'name':
              var name = lead.title ?? '';
              if (name.contains('||')) name = name.split('||')[0].trim();
              return name.toLowerCase();
            default:
            // final value = lead.asMap()[field];
              return "value".toString().toLowerCase();
          }
        }

        final valA = getFieldValue(a, sortField.value);
        final valB = getFieldValue(b, sortField.value);

        if (valA is DateTime && valB is DateTime) {
          return sortOrder.value == 'asc'
              ? valA.compareTo(valB)
              : valB.compareTo(valA);
        } else {
          return sortOrderN.value == 'asc'
              ? valA.compareTo(valB)
              : valB.compareTo(valA);
        }
      });
    }

    int start = (currentProspectPage.value - 1) * itemsProspectPerPage;

    if (start >= filteredLeads.length) {
      return list.value=[];
    }

    int end = start + itemsProspectPerPage;
    end = end > filteredLeads.length ? filteredLeads.length : end;
    print("list");
    print(filteredLeads.sublist(start, end));
    return list.value=filteredLeads.sublist(start, end);
    // return filteredLeads.sublist(start, end);
    // }
  }
  List<Quotations> changeQuotationPage(RxList<Quotations> list,RxList<Quotations> list2){
    final query = searchProspects.value.trim().toLowerCase();
    final ratingFilter = selectedProspectTemperature.value;
    final sortBy = selectedQualifiedSortBy.value; // 'Today', 'Last 7 Days', etc.
    final now = DateTime.now();

    final filteredLeads = list2.value.where((lead) {
      final matchesQuery = (lead.name ?? '').toLowerCase().contains(query);
      return matchesQuery;
    }).toList();

    if (sortField.isNotEmpty) {
      filteredLeads.sort((a, b) {
        dynamic getFieldValue(Quotations lead, String field) {
          switch (field) {
            case 'name':
              var name = lead.name ?? '';
              if (name.contains('||')) name = name.split('||')[0].trim();
              return name.toLowerCase();
            default:
            // final value = lead.asMap()[field];
              return "value".toString().toLowerCase();
          }
        }

        final valA = getFieldValue(a, sortField.value);
        final valB = getFieldValue(b, sortField.value);

        if (valA is DateTime && valB is DateTime) {
          return sortOrder.value == 'asc'
              ? valA.compareTo(valB)
              : valB.compareTo(valA);
        } else {
          return sortOrderN.value == 'asc'
              ? valA.compareTo(valB)
              : valB.compareTo(valA);
        }
      });
    }

    int start = (currentProspectPage.value - 1) * itemsProspectPerPage;

    if (start >= filteredLeads.length) {
      return list.value=[];
    }

    int end = start + itemsProspectPerPage;
    end = end > filteredLeads.length ? filteredLeads.length : end;
    print("list");
    print(filteredLeads.sublist(start, end));
    return list.value=filteredLeads.sublist(start, end);
    // return filteredLeads.sublist(start, end);
    // }
  }

  Future pickImage() async {

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true, // important for web preview
    );

    if (result != null) {
      selectedFile.value = result.files.first;

      print(selectedFile.value!.name); // file name
    }
  }

  Future<void> addProduct(context) async {
    try {

      var request = http.MultipartRequest(
        "POST",
        Uri.parse(scriptApi),
      );

      // ✅ HEADER ADD
      request.headers.addAll({
        'X-API-TOKEN': "${TokenStorage().readToken()}",
        'Content-Type': 'application/json',
      });

      request.fields['action'] = "add_product";
      request.fields['title'] = title.text.trim();
      request.fields['description'] = description.text.trim();
      request.fields['availability'] = availability.text.trim();
      request.fields['condition'] = condition.text.trim();
      request.fields['price'] = price.text.trim();
      request.fields['brand'] = brand.text.trim();
      request.fields['created_by'] = controllers.storage.read("id").toString();
      request.fields['cos_id'] = controllers.storage.read("cos_id").toString();

      if (selectedFile.value != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            "image",
            selectedFile.value!.bytes!,
            filename: selectedFile.value!.name,
          ),
        );
      }

      // SEND
      var response = await request.send();
      var responseData = await http.Response.fromStream(response);

      print("STATUS CODE: ${response.statusCode}");
      print("RAW RESPONSE: ${responseData.body}");
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return addProduct(context);
        } else {
          controllers.setLogOut();
        }
      }
      final decoded = jsonDecode(responseData.body);

      if (response.statusCode == 200 && decoded["status"] == true) {
        utils.snackBar(context: context, msg: "Product added successfully", color: Colors.green);
        productCtr.saveCtr.reset();
        getProducts();
        Navigator.pop(context);
      } else {
        utils.snackBar(context: context, msg: "Failed", color: Colors.red);
        productCtr.saveCtr.reset();
        print("API Error: ${decoded["message"]}");
      }
      saveCtr.reset();
    } catch (e) {
      utils.snackBar(context: context, msg: "Failed", color: Colors.red);
      productCtr.saveCtr.reset();
      saveCtr.reset();
      print("FLUTTER ERROR => $e");
    }
  }
  Future<void> updateProduct(context,String id,String imagePath,String linkPath) async {
    try {

      var request = http.MultipartRequest(
        "POST",
        Uri.parse(scriptApi),
      );

      // ✅ HEADER ADD
      request.headers.addAll({
        'X-API-TOKEN': "${TokenStorage().readToken()}",
        'Content-Type': 'application/json',
      });

      request.fields['action'] = "update_product";
      request.fields['id'] = id;
      request.fields['title'] = title.text.trim();
      request.fields['description'] = description.text.trim();
      request.fields['availability'] = availability.text.trim();
      request.fields['condition'] = condition.text.trim();
      request.fields['price'] = price.text.trim();
      request.fields['brand'] = brand.text.trim();
      request.fields['image_path'] = imagePath;
      request.fields['link_path'] = linkPath;
      request.fields['created_by'] = controllers.storage.read("id").toString();
      request.fields['cos_id'] = controllers.storage.read("cos_id").toString();

      if (selectedFile.value != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            "image",
            selectedFile.value!.bytes!,
            filename: selectedFile.value!.name,
          ),
        );
      }

      // SEND
      var response = await request.send();
      var responseData = await http.Response.fromStream(response);

      print("STATUS CODE: ${response.statusCode}");
      print("RAW RESPONSE: ${responseData.body}");
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return updateProduct(context,id,imagePath,linkPath);
        } else {
          controllers.setLogOut();
        }
      }
      final decoded = jsonDecode(responseData.body);

      if (response.statusCode == 200 && decoded["status"] == true) {
        utils.snackBar(context: context, msg: "Product updated successfully", color: Colors.green);
        productCtr.saveCtr.reset();
        getProducts();
        Navigator.pop(context);
      } else {
        utils.snackBar(context: context, msg: "Failed", color: Colors.red);
        productCtr.saveCtr.reset();
        print("API Error: ${decoded["message"]}");
      }
      saveCtr.reset();
    } catch (e) {
      utils.snackBar(context: context, msg: "Failed", color: Colors.red);
      productCtr.saveCtr.reset();
      saveCtr.reset();
      print("FLUTTER ERROR => $e");
    }
  }
  Future<void> deleteProduct(context) async {
    try {

      Map<String, dynamic> data = {
        "created_by": controllers.storage.read("id"),
        "cos_id": controllers.storage.read("cos_id"),
        "action": "delete_product",
        "id": idsList.value,
      };
      print("Request: ${jsonEncode(data)}");
      final response = await http.post(
        Uri.parse(scriptApi),
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );


      print("STATUS CODE: ${response.statusCode}");
      print("RAW RESPONSE: ${response.body}");
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return deleteProduct(context);
        } else {
          controllers.setLogOut();
        }
      }
      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 && decoded["status"] == true) {
        idsList.value.clear();
        utils.snackBar(context: context, msg: "Product deleted successfully", color: Colors.green);
        productCtr.saveCtr.reset();
        getProducts();
        Navigator.pop(context);
      } else {
        utils.snackBar(context: context, msg: "Failed", color: Colors.red);
        productCtr.saveCtr.reset();
        print("API Error: ${decoded["message"]}");
      }
      saveCtr.reset();
    } catch (e) {
      utils.snackBar(context: context, msg: "Failed", color: Colors.red);
      productCtr.saveCtr.reset();
      saveCtr.reset();
      print("FLUTTER ERROR => $e");
    }
  }
var idsList=[].obs;
var isSelectAll=false.obs;
  void checkDelete() {
    for (var product in products) {
      if(isSelectAll.value==true ){
        product.isSelect.value = isSelectAll.value;
        idsList.add(product.id);
      }else{
        product.isSelect.value = isSelectAll.value;
        idsList.clear();
      }
    }
  }
  String formatAmount(dynamic amount) {
    try {
      if (amount == null) return "₹0";

      final value = double.parse(amount.toString());

      final formatter = NumberFormat.currency(
        locale: 'en_IN',     // 👈 Indian format
        symbol: '₹',         // 👈 Rupee symbol
        decimalDigits: 2,    // 👈 2 decimal places
      );

      return formatter.format(value);
    } catch (e) {
      return "₹0";
    }
  }
 RxList<ProductModel> products=<ProductModel>[].obs;
 RxList<ProductModel> products2=<ProductModel>[].obs;
  RxList<ProductModel> productsList=<ProductModel>[].obs;

  Future<List<ProductModel>> getProducts() async {
    try {
      products.clear();
      products2.clear();
      final response = await http.post(
        Uri.parse(scriptApi),
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "action": "get_data",
          "search_type": "get_products",
          "role": controllers.storage.read("role").toString(),
          "id": controllers.storage.read("id").toString(),
          "cos_id": controllers.storage.read("cos_id").toString(),
        }),
      );

      // print("STATUS CODE add_values: ${response.statusCode}");
      // print("get_products...: ${response.body}");
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return getProducts();
        } else {
          controllers.setLogOut();
        }
      }
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        products.value =data.map((e) => ProductModel.fromJson(e)).toList();
        products2.value =data.map((e) => ProductModel.fromJson(e)).toList();
        return products;
      }else{
          return [];
      }
    } catch (e) {
      log("FLUTTER ERROR => $e");
      return [];
    }
  }
  String numberToWords(int number) {
    final units = [
      "", "One", "Two", "Three", "Four", "Five", "Six",
      "Seven", "Eight", "Nine", "Ten", "Eleven", "Twelve",
      "Thirteen", "Fourteen", "Fifteen", "Sixteen",
      "Seventeen", "Eighteen", "Nineteen"
    ];

    final tens = [
      "", "", "Twenty", "Thirty", "Forty",
      "Fifty", "Sixty", "Seventy", "Eighty", "Ninety"
    ];

    if (number < 20) return units[number];

    if (number < 100) {
      return "${tens[number ~/ 10]} ${units[number % 10]}";
    }

    if (number < 1000) {
      return "${units[number ~/ 100]} Hundred ${numberToWords(number % 100)}";
    }

    if (number < 100000) {
      return "${numberToWords(number ~/ 1000)} Thousand ${numberToWords(number % 1000)}";
    }

    if (number < 10000000) {
      return "${numberToWords(number ~/ 100000)} Lakh ${numberToWords(number % 100000)}";
    }

    return number.toString();
  }
  final ScreenshotController screenshotController = ScreenshotController();
  RxList<Order> ordersList=<Order>[].obs;
  RxList<Order> ordersList2=<Order>[].obs;
  String formatDateTime(String? dateTime) {
    try {
      if (dateTime == null || dateTime.isEmpty) return "-";
      final dt = DateTime.parse(dateTime);
      return DateFormat('dd-MM-yyyy hh:mm a').format(dt);
    } catch (e) {
      return dateTime ?? "-";
    }
  }
  Future<List<Order>> getOrderDetails() async {
    try {
      ordersList.clear();
      ordersList2.clear();
      final response = await http.post(
        Uri.parse(scriptApi),
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "action": "get_data",
          "search_type": "get_order_details",
          "role": controllers.storage.read("role").toString(),
          "id": controllers.storage.read("id").toString(),
          "cos_id": controllers.storage.read("cos_id").toString(),
        }),
      );

      // print("STATUS CODE add_values: ${response.statusCode}");
      // print("get_order_details..: ${response.body}");
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return getOrderDetails();
        } else {
          controllers.setLogOut();
        }
      }
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        ordersList.value =data.map((e) => Order.fromJson(e)).toList();
        ordersList2.value =data.map((e) => Order.fromJson(e)).toList();
        return ordersList;
      }else{
          return [];
      }
    } catch (e) {
      log("FLUTTER ERROR => $e");
      return [];
    }
  }
  RxString selectedCallSortBy = "All".obs;
  var selectedCallRange = Rxn<DateTimeRange>();
  final Rxn<DateTime> selectedCallMonth = Rxn<DateTime>();
  void filterAndSortProducts({
    required String searchText,
    required String sortField,
    required String sortOrder,
    required String selectedDateFilter,
    required DateTime? selectedMonth,
    required DateTimeRange? selectedRange,
  }) {
    DateTime parseDate(String dateStr) {
      try {
        return DateTime.parse(dateStr); // 🔥 BEST
      } catch (e) {
        return DateTime(1900);
      }
    }

    final now = DateTime.now();

    final filtered = products2.where((activity) {

      final matchesSearch =
          searchText.isEmpty ||
              activity.title.toString().toLowerCase().contains(searchText.toLowerCase()) ||
              activity.hsnCode.toString().toLowerCase().contains(searchText.toLowerCase());

      final activityDate = parseDate(activity.createdTs.toString());

      bool matchesDate = true;

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);

      /// Today
      if (selectedDateFilter == "Today") {
        final tomorrowStart = todayStart.add(const Duration(days: 1));

        matchesDate = activityDate.isAfter(todayStart) &&
            activityDate.isBefore(tomorrowStart);
      }

      /// Yesterday
      else if (selectedDateFilter == "Yesterday") {
        final yesterdayStart = todayStart.subtract(const Duration(days: 1));

        matchesDate = activityDate.isAfter(yesterdayStart) &&
            activityDate.isBefore(todayStart);
      }

      /// Last 7 Days
      else if (selectedDateFilter == "Last 7 Days") {
        final start = todayStart.subtract(const Duration(days: 6));

        matchesDate = activityDate.isAfter(start) &&
            activityDate.isBefore(todayStart.add(const Duration(days: 1)));
      }

      /// Last 30 Days
      else if (selectedDateFilter == "Last 30 Days") {
        final start = todayStart.subtract(const Duration(days: 29));

        matchesDate = activityDate.isAfter(start) &&
            activityDate.isBefore(todayStart.add(const Duration(days: 1)));
      }
      print("activityDate ${activityDate}");
      print("selectedRange ${selectedRange}");

      /// Date Range Filter (same date issue fixed)
      if (selectedRange != null) {
        final start = DateTime(
          selectedRange.start.year,
          selectedRange.start.month,
          selectedRange.start.day,
        );

        final end = DateTime(
          selectedRange.end.year,
          selectedRange.end.month,
          selectedRange.end.day,
          23, 59, 59,
        );

        matchesDate = !activityDate.isBefore(start) &&
            !activityDate.isAfter(end);
      }
      /// Month Filter
      if (selectedMonth != null) {
        matchesDate = activityDate.month == selectedMonth.month &&
            activityDate.year == selectedMonth.year;
      }

      return matchesSearch && matchesDate;

    }).toList();

    /// Sorting
    if (sortField == 'name') {
      filtered.sort((a, b) {
        final comparison =
        a.title.toString().toLowerCase().compareTo(b.title.toString().toLowerCase());
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }else if (sortField == 'mrp') {
      filtered.sort((a, b) {
        final aVal = int.tryParse(a.mrp.toString()) ?? 0;
        final bVal = int.tryParse(b.mrp.toString()) ?? 0;
        final comparison = aVal.compareTo(bVal);
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }else if (sortField == 'price') {
      filtered.sort((a, b) {
        final aVal = int.tryParse(a.outPrice.toString()) ?? 0;
        final bVal = int.tryParse(b.outPrice.toString()) ?? 0;
        final comparison = aVal.compareTo(bVal);
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }else if (sortField == 'sku') {
      filtered.sort((a, b) {
        final aVal = int.tryParse(a.skuId.toString()) ?? 0;
        final bVal = int.tryParse(b.skuId.toString()) ?? 0;
        final comparison = aVal.compareTo(bVal);
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }else if (sortField == 'hsn') {
      filtered.sort((a, b) {
        final aVal = int.tryParse(a.hsnCode.toString()) ?? 0;
        final bVal = int.tryParse(b.hsnCode.toString()) ?? 0;
        final comparison = aVal.compareTo(bVal);
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }else if (sortField == 'gst') {
      filtered.sort((a, b) {
        final aVal = int.tryParse(a.gst.toString()) ?? 0;
        final bVal = int.tryParse(b.gst.toString()) ?? 0;
        final comparison = aVal.compareTo(bVal);
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }else if (sortField == 'date') {
      filtered.sort((a, b) {
        final dateA = parseDate(a.createdTs.toString());
        final dateB = parseDate(b.createdTs.toString());
        final comparison = dateA.compareTo(dateB);
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }else if (sortField == 'cat') {
      filtered.sort((a, b) {
        final comparison =
        a.cat.toString().toLowerCase().compareTo(b.cat.toString().toLowerCase());
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }else if (sortField == 'sub cat') {
      filtered.sort((a, b) {
        final comparison =
        a.subCat.toString().toLowerCase().compareTo(b.subCat.toString().toLowerCase());
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }
    products.assignAll(filtered);
  }

  void filterAndSortOrders({
    required String searchText,
    required String sortField,
    required String sortOrder,
    required String selectedDateFilter,
    required DateTime? selectedMonth,
    required DateTimeRange? selectedRange,
  }) {
    DateTime parseDate(String dateStr) {
      try {
        return DateTime.parse(dateStr); // 🔥 BEST
      } catch (e) {
        return DateTime(1900);
      }
    }

    final now = DateTime.now();

    final filtered = ordersList2.where((activity) {

      final matchesSearch =
          searchText.isEmpty ||
              activity.customerName.toString().toLowerCase().contains(searchText.toLowerCase()) ||
              activity.totalAmt.toString().toLowerCase().contains(searchText.toLowerCase());

      final activityDate = parseDate(activity.createdTs.toString());

      bool matchesDate = true;

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);

      /// Today
      if (selectedDateFilter == "Today") {
        final tomorrowStart = todayStart.add(const Duration(days: 1));

        matchesDate = activityDate.isAfter(todayStart) &&
            activityDate.isBefore(tomorrowStart);
      }

      /// Yesterday
      else if (selectedDateFilter == "Yesterday") {
        final yesterdayStart = todayStart.subtract(const Duration(days: 1));

        matchesDate = activityDate.isAfter(yesterdayStart) &&
            activityDate.isBefore(todayStart);
      }

      /// Last 7 Days
      else if (selectedDateFilter == "Last 7 Days") {
        final start = todayStart.subtract(const Duration(days: 6));

        matchesDate = activityDate.isAfter(start) &&
            activityDate.isBefore(todayStart.add(const Duration(days: 1)));
      }

      /// Last 30 Days
      else if (selectedDateFilter == "Last 30 Days") {
        final start = todayStart.subtract(const Duration(days: 29));

        matchesDate = activityDate.isAfter(start) &&
            activityDate.isBefore(todayStart.add(const Duration(days: 1)));
      }
      print("activityDate ${activityDate}");
      print("selectedRange ${selectedRange}");

      /// Date Range Filter (same date issue fixed)
      if (selectedRange != null) {
        final start = DateTime(
          selectedRange.start.year,
          selectedRange.start.month,
          selectedRange.start.day,
        );

        final end = DateTime(
          selectedRange.end.year,
          selectedRange.end.month,
          selectedRange.end.day,
          23, 59, 59,
        );

        matchesDate = !activityDate.isBefore(start) &&
            !activityDate.isAfter(end);
      }
      /// Month Filter
      if (selectedMonth != null) {
        matchesDate = activityDate.month == selectedMonth.month &&
            activityDate.year == selectedMonth.year;
      }

      return matchesSearch && matchesDate;

    }).toList();

    /// Sorting
    if (sortField == 'name') {
      filtered.sort((a, b) {
        final comparison =
        a.customerName.toString().toLowerCase().compareTo(b.customerName.toString().toLowerCase());
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }else if (sortField == 'number') {
      filtered.sort((a, b) {
        final aVal = int.tryParse(a.orderId.toString()) ?? 0;
        final bVal = int.tryParse(b.orderId.toString()) ?? 0;
        final comparison = aVal.compareTo(bVal);
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }else if (sortField == 'amt') {
      filtered.sort((a, b) {
        final aVal = int.tryParse(a.totalAmt.toString()) ?? 0;
        final bVal = int.tryParse(b.totalAmt.toString()) ?? 0;
        final comparison = aVal.compareTo(bVal);
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }else if (sortField == 'date') {
      filtered.sort((a, b) {
        final dateA = parseDate(a.createdTs.toString());
        final dateB = parseDate(b.createdTs.toString());
        final comparison = dateA.compareTo(dateB);
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }
    ordersList.assignAll(filtered);
  }

  void filterAndSortQuotations({
    required String searchText,
    required String sortField,
    required String sortOrder,
    required String selectedDateFilter,
    required DateTime? selectedMonth,
    required DateTimeRange? selectedRange,
  }) {
  DateTime parseDate(String dateStr) {
    try {
      return DateTime.parse(dateStr); // 🔥 BEST
    } catch (e) {
      return DateTime(1900);
    }
  }

    final now = DateTime.now();

    final filtered = quotationsList2.where((activity) {

      final matchesSearch =
          searchText.isEmpty ||
              activity.number.toString().toLowerCase().contains(searchText.toLowerCase()) ||
              activity.totalAmt.toString().toLowerCase().contains(searchText.toLowerCase()) ||
              activity.number.toString().toLowerCase().contains(searchText.toLowerCase());

      final activityDate = parseDate(activity.createdTs.toString());

      bool matchesDate = true;

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);

      /// Today
      if (selectedDateFilter == "Today") {
      final tomorrowStart = todayStart.add(const Duration(days: 1));

      matchesDate = activityDate.isAfter(todayStart) &&
      activityDate.isBefore(tomorrowStart);
      }

      /// Yesterday
      else if (selectedDateFilter == "Yesterday") {
      final yesterdayStart = todayStart.subtract(const Duration(days: 1));

      matchesDate = activityDate.isAfter(yesterdayStart) &&
      activityDate.isBefore(todayStart);
      }

      /// Last 7 Days
      else if (selectedDateFilter == "Last 7 Days") {
      final start = todayStart.subtract(const Duration(days: 6));

      matchesDate = activityDate.isAfter(start) &&
      activityDate.isBefore(todayStart.add(const Duration(days: 1)));
      }

      /// Last 30 Days
      else if (selectedDateFilter == "Last 30 Days") {
      final start = todayStart.subtract(const Duration(days: 29));

      matchesDate = activityDate.isAfter(start) &&
      activityDate.isBefore(todayStart.add(const Duration(days: 1)));
      }
      print("activityDate ${activityDate}");
      print("selectedRange ${selectedRange}");

      /// Date Range Filter (same date issue fixed)
      if (selectedRange != null) {
        final start = DateTime(
          selectedRange.start.year,
          selectedRange.start.month,
          selectedRange.start.day,
        );

        final end = DateTime(
          selectedRange.end.year,
          selectedRange.end.month,
          selectedRange.end.day,
          23, 59, 59,
        );

        matchesDate = !activityDate.isBefore(start) &&
            !activityDate.isAfter(end);
      }
      /// Month Filter
      if (selectedMonth != null) {
        matchesDate = activityDate.month == selectedMonth.month &&
            activityDate.year == selectedMonth.year;
      }

      return matchesSearch && matchesDate;

    }).toList();

    /// Sorting
    if (sortField == 'name') {
      filtered.sort((a, b) {
        final comparison =
        a.name.toString().toLowerCase().compareTo(b.name.toString().toLowerCase());
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }else if (sortField == 'number') {
      filtered.sort((a, b) {
        final comparison =
        a.number.toLowerCase().compareTo(b.number.toLowerCase());
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }else if (sortField == 'amt') {
      filtered.sort((a, b) {
        final aVal = int.tryParse(a.totalAmt.toString()) ?? 0;
        final bVal = int.tryParse(b.totalAmt.toString()) ?? 0;
        final comparison = aVal.compareTo(bVal);
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }else if (sortField == 'date') {
        filtered.sort((a, b) {
          final dateA = parseDate(a.createdTs);
          final dateB = parseDate(b.createdTs);
          final comparison = dateA.compareTo(dateB);
          return sortOrder == 'asc' ? comparison : -comparison;
        });
    }else if (sortField == 'status') {
      filtered.sort((a, b) {
        final comparison =
        a.status.toLowerCase().compareTo(b.status.toLowerCase());
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }
    quotationsList.assignAll(filtered);
  }

  RxList<Quotations> quotationsList=<Quotations>[].obs;
  RxList<Quotations> quotationsList2=<Quotations>[].obs;
  Future<List<Quotations>> getQuotationDetails() async {
    try {
      quotationsList.clear();
      quotationsList2.clear();
      final response = await http.post(
        Uri.parse(scriptApi),
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "action": "get_data",
          "search_type": "get_quotations",
          "role": controllers.storage.read("role").toString(),
          "id": controllers.storage.read("id").toString(),
          "cos_id": controllers.storage.read("cos_id").toString(),
        }),
      );

      // print("STATUS CODE add_values: ${response.statusCode}");
      print("get_quotations..: ${response.body}");
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return getQuotationDetails();
        } else {
          controllers.setLogOut();
        }
      }
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        quotationsList.value =data.map((e) => Quotations.fromJson(e)).toList();
        quotationsList2.value =data.map((e) => Quotations.fromJson(e)).toList();
        // print("get_quotations..: ${quotationsList.length}");
        // print("get_quotations..: ${quotationsList2.length}");
        return quotationsList;
      }else{
          return [];
      }
    } catch (e) {
      log("FLUTTER ERROR => $e");
      return [];
    }
  }
  RxList<BillingRow> rows = <BillingRow>[].obs;

  /// 🔹 INIT
  @override
  void onInit() {
    super.onInit();
  }

  /// 🔹 ADD PRODUCT
  void addProducts(ProductModel product) {
    bool alreadyAdded =
    rows.any((e) => e.product?.id == product.id);

    if (alreadyAdded) {
      Get.snackbar("Warning", "Product already added");
      return;
    }

    // rows.add(BillingRow(
    //   product: product,
    //   price: product.price ?? 0.0,
    //   qty: 1,
    //   amount: product.price ?? 0.0,
    // ));
  }

  /// 🔹 UPDATE QTY
  void updateQty(int index, int qty) {
    rows[index].qty = qty;
    rows[index].amount = rows[index].price * qty;
    rows.refresh();
  }

  /// 🔹 DELETE ROW
  void removeRow(int index) {
    rows.removeAt(index);
  }

  /// 🔹 TOTAL
  double getTotal() {
    return rows.fold(0, (sum, item) => sum + item.amount);
  }
  Future<void> insertOrder(context,String totalAmt,String customerId,) async {
    try {

      Map<String, dynamic> data = {
        "created_by": controllers.storage.read("id"),
        "cos_id": controllers.storage.read("cos_id"),
        "total_amt": totalAmt,
        "customer_id": customerId,
        "action": "insert_order",
        "productList": rows.toJson(),
      };
      print("Request: ${jsonEncode(data)}");
      final response = await http.post(
        Uri.parse(scriptApi),
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );


      print("STATUS CODE: ${response.statusCode}");
      print("RAW RESPONSE: ${response.body}");
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return insertOrder(context,totalAmt,customerId);
        } else {
          controllers.setLogOut();
        }
      }
      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 && decoded["status"] == true) {
        idsList.value.clear();
        utils.snackBar(context: context, msg: "Order Placed successfully", color: Colors.green);
        productCtr.saveCtr.reset();
        // getProducts();
        Navigator.pop(context);
      } else {
        utils.snackBar(context: context, msg: "Failed", color: Colors.red);
        productCtr.saveCtr.reset();
        print("API Error: ${decoded["message"]}");
      }
      saveCtr.reset();
    } catch (e) {
      utils.snackBar(context: context, msg: "Failed", color: Colors.red);
      productCtr.saveCtr.reset();
      saveCtr.reset();
      print("FLUTTER ERROR => $e");
    }
  }

}
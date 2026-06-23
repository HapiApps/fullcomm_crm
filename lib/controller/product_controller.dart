import 'dart:convert';
import 'dart:developer';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/utilities/jwt_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:screenshot/screenshot.dart';
import '../common/constant/api.dart';
import '../common/utilities/utils.dart';
import '../models/billing_models/products_response.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import 'controller.dart';

final productCtr = Get.put(ProductController());

class ProductController extends GetxController with GetSingleTickerProviderStateMixin {


  var selectedProductId="".obs;
  var selectedProductName="".obs;
  void clearProduct() {
    selectedProductId.value = "";
    selectedProductName.value = "";
    controllers.search.clear();
    // productsList.value.remove(value);
  }
  int currentPage = 1;
  int currentPrdPage = 1;
  int currentOrdersPage = 1;

  int itemsPerPage = 20;
  int itemsPrdPerPage = 20;
  int itemsOrdersPerPage = 20;

  List get paginatedItems {

    final start =
        (currentPage - 1) * itemsPerPage;

    final end =
        start + itemsPerPage;

    return quotationsList.sublist(
      start,
      end > quotationsList.length
          ? quotationsList.length
          : end,
    );
  }
  List get paginatedPrdItems {

    final start =
        (currentPrdPage - 1) * itemsPrdPerPage;

    final end =
        start + itemsPrdPerPage;

    return products.sublist(
      start,
      end > products.length
          ? products.length
          : end,
    );
  }

  List get paginatedOrdersItems {

    final start =
        (currentOrdersPage - 1) * itemsOrdersPerPage;

    final end =
        start + itemsOrdersPerPage;

    return ordersList.sublist(
      start,
      end > ordersList.length
          ? ordersList.length
          : end,
    );
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

  List<ProductData> changeProductPage(RxList<ProductData> list,RxList<ProductData> list2){
    final query = searchProspects.value.trim().toLowerCase();
    // final ratingFilter = selectedProspectTemperature.value;
    // final sortBy = selectedQualifiedSortBy.value; // 'Today', 'Last 7 Days', etc.
    // final now = DateTime.now();

    final filteredLeads = list2.value.where((lead) {
      final matchesQuery = (lead.pTitle ?? '').toLowerCase().contains(query);
      return matchesQuery;
    }).toList();

    if (sortField.isNotEmpty) {
      filteredLeads.sort((a, b) {
        dynamic getFieldValue(ProductData lead, String field) {
          switch (field) {
            case 'name':
              var name = lead.pTitle ?? '';
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
    debugPrint("list");
    return list.value=filteredLeads.sublist(start, end);
    // return filteredLeads.sublist(start, end);
    // }
  }
  List<Quotations> changeQuotationPage(RxList<Quotations> list,RxList<Quotations> list2){
    final query = searchProspects.value.trim().toLowerCase();
    // final ratingFilter = selectedProspectTemperature.value;
    // final sortBy = selectedQualifiedSortBy.value; // 'Today', 'Last 7 Days', etc.
    // final now = DateTime.now();

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
    debugPrint("list");
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

      debugPrint(selectedFile.value!.name); // file name
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

      // debugPrint("STATUS CODE: ${response.statusCode}");
      // debugPrint("RAW RESPONSE: ${responseData.body}");
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
        debugPrint("API Error: ${decoded["message"]}");
      }
      saveCtr.reset();
    } catch (e) {
      utils.snackBar(context: context, msg: "Failed", color: Colors.red);
      productCtr.saveCtr.reset();
      saveCtr.reset();
      debugPrint("FLUTTER ERROR => $e");
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

      // debugPrint("STATUS CODE: ${response.statusCode}");
      // debugPrint("RAW RESPONSE: ${responseData.body}");
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
        debugPrint("API Error: ${decoded["message"]}");
      }
      saveCtr.reset();
    } catch (e) {
      utils.snackBar(context: context, msg: "Failed", color: Colors.red);
      productCtr.saveCtr.reset();
      saveCtr.reset();
      debugPrint("FLUTTER ERROR => $e");
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
      debugPrint("Request: ${jsonEncode(data)}");
      final response = await http.post(
        Uri.parse(scriptApi),
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );


      // debugPrint("STATUS CODE: ${response.statusCode}");
      // debugPrint("RAW RESPONSE: ${response.body}");
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
        debugPrint("API Error: ${decoded["message"]}");
      }
      saveCtr.reset();
    } catch (e) {
      utils.snackBar(context: context, msg: "Failed", color: Colors.red);
      productCtr.saveCtr.reset();
      saveCtr.reset();
      debugPrint("FLUTTER ERROR => $e");
    }
  }
var idsList=[].obs;
var isSelectAll=false.obs;
  void checkDelete() {
    // for (var product in products) {
      // if(isSelectAll.value==true ){
      //   product.isSelect.value = isSelectAll.value;
      //   idsList.add(product.id);
      // }else{
      //   product.isSelect.value = isSelectAll.value;
      //   idsList.clear();
      // }
    // }
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
  String formatAmount2(dynamic amount) {
    try {
      final formatted = NumberFormat.currency(
        locale: 'en_IN',
        symbol: '₹',
        decimalDigits: 0,
      ).format(double.parse(amount));

      return formatted;
    } catch (e) {
      return "₹0";
    }
  }
  var selectedPrdIds = <String>[].obs;
  void selectAllCalls() {
    selectedPrdIds.assignAll(products.map((e) => e.id.toString()).toList());
  }

  void unselectAllCalls() {
    selectedPrdIds.clear();
  }
  bool isCheckedRecordCall(String id) {
    return selectedPrdIds.contains(id);
  }

  void toggleRecordSelectionCall(String id) {
    if (selectedPrdIds.contains(id)) {
      selectedPrdIds.remove(id);
    } else {
      selectedPrdIds.add(id);
    }
  }
  RxList<ProductData> products=<ProductData>[].obs;
 RxList<ProductData> products2=<ProductData>[].obs;

  Future<List<ProductData>> getProducts() async {
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
          "action": "select_products",
          "cos_id": controllers.storage.read("cos_id").toString(),
        }),
      );

      // debugPrint("STATUS CODE add_values: ${response.statusCode}");
      // debugPrint("get_products...: ${response.body}");
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return getProducts();
        } else {
          controllers.setLogOut();
        }
      }
      if (response.statusCode == 200) {
        final ProductsResponse data = ProductsResponse.fromJson(jsonDecode(response.body));
        products2.value = data.productList ?? [];
        products.value = data.productList ?? [];
        return products;
      }else{
          return [];
      }
    } catch (e) {
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
  String fixedDateTime(String? dateTime) {
    try {
      if (dateTime == null || dateTime.isEmpty) return "-";

      final dt = DateTime.parse(dateTime);
      final now = DateTime.now();

      // ✅ same year → hide year
      if (dt.year == now.year) {
        return DateFormat('dd/MM hh:mm a').format(dt);
      }
      // ✅ different year → show full
      else {
        return DateFormat('dd/MM/yyyy hh:mm a').format(dt);
      }

    } catch (e) {
      return dateTime ?? "-";
    }
  }
  Future<List<Order>> getOrderDetails() async {
    try {
      // ordersList.clear();
      // ordersList2.clear();
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

      // debugPrint("STATUS CODE add_values: ${response.statusCode}");
      // debugPrint("get_order_details..: ${response.body}");
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
      return [];
    }
  }
  RxString selectedCallSortBy = "All".obs;
  var selectedCallRange = Rxn<DateTimeRange>();
  final Rxn<DateTime> selectedCallMonth = Rxn<DateTime>();
  // void filterAndSortProducts({
  //   required String searchText,
  //   required String sortField,
  //   required String sortOrder,
  //   required String selectedDateFilter,
  //   required DateTime? selectedMonth,
  //   required DateTimeRange? selectedRange,
  // }) {
  //   debugPrint("===== FILTER START =====");
  //   debugPrint("searchText : $searchText");
  //   debugPrint("selectedDateFilter : $selectedDateFilter");
  //   debugPrint("selectedMonth : $selectedMonth");
  //   debugPrint("selectedRange : $selectedRange");
  //
  //   DateTime parseDate(String dateStr) {
  //     try {
  //       return DateTime.parse(dateStr);
  //     } catch (e) {
  //       debugPrint("Date Parse Error : $dateStr");
  //       return DateTime(1900);
  //     }
  //   }
  //
  //   final filtered = products2.where((activity) {
  //     /// SEARCH
  //     bool matchesSearch = true;
  //
  //     if (searchText.trim().isNotEmpty) {
  //       matchesSearch =
  //           activity.pTitle
  //               .toString()
  //               .toLowerCase()
  //               .contains(searchText.toLowerCase()) ||
  //               activity.hsnCode
  //                   .toString()
  //                   .toLowerCase()
  //                   .contains(searchText.toLowerCase()) ||
  //               activity.barcode
  //                   .toString()
  //                   .toLowerCase()
  //                   .contains(searchText.toLowerCase()) ||
  //               activity.skuId
  //                   .toString()
  //                   .toLowerCase()
  //                   .contains(searchText.toLowerCase());
  //     }
  //
  //     final activityDate = parseDate(activity.createdTs.toString());
  //
  //     bool matchesDate = true;
  //
  //     /// ALL
  //     if (selectedDateFilter == "All") {
  //       matchesDate = true;
  //     }
  //
  //     /// DATE RANGE
  //     else if (selectedRange != null) {
  //       final start = DateTime(
  //         selectedRange.start.year,
  //         selectedRange.start.month,
  //         selectedRange.start.day,
  //       );
  //
  //       final end = DateTime(
  //         selectedRange.end.year,
  //         selectedRange.end.month,
  //         selectedRange.end.day,
  //         23,
  //         59,
  //         59,
  //       );
  //
  //       matchesDate = !activityDate.isBefore(start) &&
  //           !activityDate.isAfter(end);
  //     }
  //
  //     /// MONTH
  //     else if (selectedMonth != null) {
  //       matchesDate =
  //           activityDate.month == selectedMonth.month &&
  //               activityDate.year == selectedMonth.year;
  //     }
  //
  //     /// TODAY
  //     else if (selectedDateFilter == "Today") {
  //       final now = DateTime.now();
  //
  //       final start = DateTime(
  //         now.year,
  //         now.month,
  //         now.day,
  //       );
  //
  //       final end = start.add(const Duration(days: 1));
  //
  //       matchesDate = !activityDate.isBefore(start) &&
  //           activityDate.isBefore(end);
  //     }
  //
  //     /// YESTERDAY
  //     else if (selectedDateFilter == "Yesterday") {
  //       final now = DateTime.now();
  //
  //       final start = DateTime(
  //         now.year,
  //         now.month,
  //         now.day,
  //       ).subtract(const Duration(days: 1));
  //
  //       final end = DateTime(
  //         now.year,
  //         now.month,
  //         now.day,
  //       );
  //
  //       matchesDate = !activityDate.isBefore(start) &&
  //           activityDate.isBefore(end);
  //     }
  //
  //     /// LAST 7 DAYS
  //     else if (selectedDateFilter == "Last 7 Days") {
  //       final now = DateTime.now();
  //
  //       final start = DateTime(
  //         now.year,
  //         now.month,
  //         now.day,
  //       ).subtract(const Duration(days: 6));
  //
  //       final end = DateTime(
  //         now.year,
  //         now.month,
  //         now.day,
  //       ).add(const Duration(days: 1));
  //
  //       matchesDate = !activityDate.isBefore(start) &&
  //           activityDate.isBefore(end);
  //     }
  //
  //     /// LAST 30 DAYS
  //     else if (selectedDateFilter == "Last 30 Days") {
  //       final now = DateTime.now();
  //
  //       final start = DateTime(
  //         now.year,
  //         now.month,
  //         now.day,
  //       ).subtract(const Duration(days: 29));
  //
  //       final end = DateTime(
  //         now.year,
  //         now.month,
  //         now.day,
  //       ).add(const Duration(days: 1));
  //
  //       matchesDate = !activityDate.isBefore(start) &&
  //           activityDate.isBefore(end);
  //     }
  //
  //     return matchesSearch && matchesDate;
  //   }).toList();
  //
  //   debugPrint("Filtered Products Count : ${filtered.length}");
  //   debugPrint("Before assign");
  //   debugPrint("products : ${products.length}");
  //   debugPrint("products2 : ${products2.length}");
  //
  //   products.assignAll(filtered);
  //
  //   debugPrint("After assign");
  //   debugPrint("products : ${products.length}");
  //   debugPrint("products2 : ${products2.length}");
  //
  //   // products.assignAll(filtered);
  //   // products.refresh();
  //   // products2.refresh();
  //   // debugPrint("END products2 count : ${products2.length}");
  // }

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
        return DateTime.parse(dateStr);
      } catch (e) {
        return DateTime(1900);
      }
    }

    debugPrint("========== FILTER START ==========");
    debugPrint("selectedDateFilter : $selectedDateFilter");
    debugPrint("selectedMonth      : $selectedMonth");
    debugPrint("selectedRange      : $selectedRange");

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    final filtered = ordersList2.where((activity) {
      final activityDate =
      parseDate(activity.createdTs.toString());

      /// SEARCH
      bool matchesSearch =
          searchText.isEmpty ||
              activity.customerName
                  .toString()
                  .toLowerCase()
                  .contains(searchText.toLowerCase()) ||
              activity.totalAmt
                  .toString()
                  .toLowerCase()
                  .contains(searchText.toLowerCase());

      /// DATE FILTER
      bool matchesDate = true;

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
          23,
          59,
          59,
        );

        matchesDate =
            !activityDate.isBefore(start) &&
                !activityDate.isAfter(end);
      }

      else if (selectedMonth != null) {
        matchesDate =
            activityDate.month ==
                selectedMonth.month &&
                activityDate.year ==
                    selectedMonth.year;
      }

      else if (selectedDateFilter == "Today") {
        final tomorrow =
        todayStart.add(const Duration(days: 1));

        matchesDate =
            !activityDate.isBefore(todayStart) &&
                activityDate.isBefore(tomorrow);
      }

      else if (selectedDateFilter == "Yesterday") {
        final yesterday =
        todayStart.subtract(const Duration(days: 1));

        matchesDate =
            !activityDate.isBefore(yesterday) &&
                activityDate.isBefore(todayStart);
      }

      else if (selectedDateFilter == "Last 7 Days") {
        final start =
        todayStart.subtract(const Duration(days: 6));

        matchesDate =
            !activityDate.isBefore(start) &&
                activityDate.isBefore(
                    todayStart.add(
                        const Duration(days: 1)));
      }

      else if (selectedDateFilter == "Last 30 Days") {
        final start =
        todayStart.subtract(const Duration(days: 29));

        matchesDate =
            !activityDate.isBefore(start) &&
                activityDate.isBefore(
                    todayStart.add(
                        const Duration(days: 1)));
      }

      debugPrint(
          "Date : $activityDate => Match : $matchesDate");

      return matchesSearch && matchesDate;
    }).toList();

    debugPrint(
        "Filtered Count Before Sort : ${filtered.length}");

    /// SORTING
    switch (sortField) {
      case 'name':
        filtered.sort((a, b) {
          final result = a.customerName
              .toString()
              .toLowerCase()
              .compareTo(
            b.customerName
                .toString()
                .toLowerCase(),
          );

          return sortOrder == 'asc'
              ? result
              : -result;
        });
        break;

      case 'company':
        filtered.sort((a, b) {
          final result = a.companyName
              .toString()
              .toLowerCase()
              .compareTo(
            b.companyName
                .toString()
                .toLowerCase(),
          );

          return sortOrder == 'asc'
              ? result
              : -result;
        });
        break;

      case 'status':
        filtered.sort((a, b) {
          final result = a.status
              .toString()
              .toLowerCase()
              .compareTo(
            b.status
                .toString()
                .toLowerCase(),
          );

          return sortOrder == 'asc'
              ? result
              : -result;
        });
        break;

      case 'number':
        filtered.sort((a, b) {
          final result =
          (int.tryParse(a.orderId.toString()) ?? 0)
              .compareTo(
            int.tryParse(
                b.orderId.toString()) ??
                0,
          );

          return sortOrder == 'asc'
              ? result
              : -result;
        });
        break;

      case 'amt':
        filtered.sort((a, b) {
          final result =
          (double.tryParse(
              a.totalAmt.toString()) ??
              0)
              .compareTo(
            double.tryParse(
                b.totalAmt.toString()) ??
                0,
          );

          return sortOrder == 'asc'
              ? result
              : -result;
        });
        break;

      case 'date':
        filtered.sort((a, b) {
          final result = parseDate(
            a.createdTs.toString(),
          ).compareTo(
            parseDate(
              b.createdTs.toString(),
            ),
          );

          return sortOrder == 'asc'
              ? result
              : -result;
        });
        break;
    }

    debugPrint(
        "Filtered Count After Sort : ${filtered.length}");

    ordersList.assignAll(filtered);

    debugPrint(
        "ordersList Count : ${ordersList.length}");

    debugPrint("========== FILTER END ==========");
  }
  ///
  void filterProducts({
    required String value,
    DateTime? selectedRangeStart,
    DateTime? selectedRangeEnd,
    DateTime? selectedMonth,
    String? selectedDateFilter,
  }) {
    controllers.searchText.value = value.toString().trim();
    final input = value.toString().toLowerCase().trim();

    final todayStart = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    DateTime? startDate;
    DateTime? endDate;

    /// 🔥 DATE FILTER LOGIC
    if (selectedRangeStart != null && selectedRangeEnd != null) {
      startDate = DateTime(
        selectedRangeStart.year,
        selectedRangeStart.month,
        selectedRangeStart.day,
      );

      endDate = DateTime(
        selectedRangeEnd.year,
        selectedRangeEnd.month,
        selectedRangeEnd.day,
        23,
        59,
        59,
      );
    }

    else if (selectedMonth != null) {
      startDate = DateTime(selectedMonth.year, selectedMonth.month, 1);
      endDate = DateTime(selectedMonth.year, selectedMonth.month + 1, 0, 23, 59, 59);
    }

    else if (selectedDateFilter != null) {
      switch (selectedDateFilter) {
        case "Today":
          startDate = todayStart;
          endDate = todayStart.add(const Duration(days: 1));
          break;

        case "Yesterday":
          startDate = todayStart.subtract(const Duration(days: 1));
          endDate = todayStart;
          break;

        case "Last 7 Days":
          startDate = todayStart.subtract(const Duration(days: 6));
          endDate = todayStart.add(const Duration(days: 1));
          break;

        case "Last 30 Days":
          startDate = todayStart.subtract(const Duration(days: 29));
          endDate = todayStart.add(const Duration(days: 1));
          break;

        default:
          startDate = null;
          endDate = null;
      }
    }

    /// 🔥 FINAL FILTER + SORT
    productCtr.products.value = productCtr.products2.where((user) {
      final matchesSearch =
          user.pTitle.toString().toLowerCase().contains(input) ||
              user.hsnCode.toString().toLowerCase().contains(input) ||
              user.skuId.toString().toLowerCase().contains(input);

      bool matchesDate = true;

      if (startDate != null && endDate != null) {
        final activityDate = DateTime.tryParse(user.createdTs ?? "") ?? DateTime(1970);

        matchesDate =
            !activityDate.isBefore(startDate) &&
                activityDate.isBefore(endDate);
      }

      return matchesSearch && matchesDate;
    }).toList()
      ..sort((a, b) {
        final aDate = DateTime.tryParse(a.createdTs ?? "") ?? DateTime(1970);
        final bDate = DateTime.tryParse(b.createdTs ?? "") ?? DateTime(1970);

        return bDate.compareTo(aDate); // 🔥 latest first
      });
  }
///
  void filterSortProducts({
    required String searchText,
    DateTime? selectedRangeStart,
    DateTime? selectedRangeEnd,
    DateTime? selectedMonth,
    String? selectedDateFilter,
    required String sortField,
    required String sortOrder,
  }) {
    controllers.searchText.value = searchText.trim();
    final input = searchText.toLowerCase().trim();

    final todayStart = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    DateTime? startDate;
    DateTime? endDate;

    /// =========================
    /// 📅 DATE FILTER
    /// =========================
    if (selectedRangeStart != null && selectedRangeEnd != null) {
      startDate = DateTime(
        selectedRangeStart.year,
        selectedRangeStart.month,
        selectedRangeStart.day,
      );

      endDate = DateTime(
        selectedRangeEnd.year,
        selectedRangeEnd.month,
        selectedRangeEnd.day,
        23,
        59,
        59,
      );
    }

    else if (selectedMonth != null) {
      startDate = DateTime(selectedMonth.year, selectedMonth.month, 1);
      endDate = DateTime(selectedMonth.year, selectedMonth.month + 1, 0, 23, 59, 59);
    }

    else if (selectedDateFilter != null) {
      switch (selectedDateFilter) {
        case "Today":
          startDate = todayStart;
          endDate = todayStart.add(const Duration(days: 1));
          break;

        case "Yesterday":
          startDate = todayStart.subtract(const Duration(days: 1));
          endDate = todayStart;
          break;

        case "Last 7 Days":
          startDate = todayStart.subtract(const Duration(days: 6));
          endDate = todayStart.add(const Duration(days: 1));
          break;

        case "Last 30 Days":
          startDate = todayStart.subtract(const Duration(days: 29));
          endDate = todayStart.add(const Duration(days: 1));
          break;

        default:
          startDate = null;
          endDate = null;
      }
    }

    /// =========================
    /// 🔥 FILTER LIST
    /// =========================
    List<ProductData> filtered = productCtr.products2.where((user) {

      final matchesSearch =
          user.pTitle.toString().toLowerCase().contains(input) ||
              user.hsnCode.toString().toLowerCase().contains(input) ||
              user.skuId.toString().toLowerCase().contains(input);

      bool matchesDate = true;

      if (startDate != null && endDate != null) {
        final activityDate =
            DateTime.tryParse(user.createdTs ?? "") ?? DateTime(1970);

        matchesDate =
            !activityDate.isBefore(startDate) &&
                activityDate.isBefore(endDate);
      }

      return matchesSearch && matchesDate;
    }).toList();

    /// =========================
    /// 📊 SAFE SORT FUNCTION (FIXED)
    /// =========================
    int compareValue(Comparable? a, Comparable? b) {
      if (a == null && b == null) return 0;
      if (a == null) return -1;
      if (b == null) return 1;

      return sortOrder == 'asc'
          ? a.compareTo(b)
          : b.compareTo(a);
    }

    /// =========================
    /// 📊 SORTING
    /// =========================
    filtered.sort((a, b) {
      switch (sortField) {

        case 'name':
          return compareValue(
            a.pTitle.toString().toLowerCase(),
            b.pTitle.toString().toLowerCase(),
          );

        case 'mrp':
          return compareValue(
            int.tryParse(a.mrp.toString()) ?? 0,
            int.tryParse(b.mrp.toString()) ?? 0,
          );

        case 'price':
          return compareValue(
            int.tryParse(a.outPrice.toString()) ?? 0,
            int.tryParse(b.outPrice.toString()) ?? 0,
          );

        case 'sku':
          return compareValue(
            int.tryParse(a.skuId.toString()) ?? 0,
            int.tryParse(b.skuId.toString()) ?? 0,
          );

        case 'hsn':
          return compareValue(
            int.tryParse(a.hsnCode.toString()) ?? 0,
            int.tryParse(b.hsnCode.toString()) ?? 0,
          );

        case 'gst':
          return compareValue(
            int.tryParse(a.cgst.toString()) ?? 0,
            int.tryParse(b.cgst.toString()) ?? 0,
          );

        case 'date':
          return compareValue(
            DateTime.tryParse(a.createdTs ?? "") ?? DateTime(1970),
            DateTime.tryParse(b.createdTs ?? "") ?? DateTime(1970),
          );

        case 'barcode':
          return compareValue(
            a.barcode.toString().toLowerCase(),
            b.barcode.toString().toLowerCase(),
          );

        case 'cat':
          return compareValue(
            a.category.toString().toLowerCase(),
            b.category.toString().toLowerCase(),
          );

        case 'subcat':
          return compareValue(
            a.subCategory.toString().toLowerCase(),
            b.subCategory.toString().toLowerCase(),
          );

        case 'brand':
          return compareValue(
            a.brand.toString().toLowerCase(),
            b.brand.toString().toLowerCase(),
          );

        default:
          return 0;
      }
    });

    /// =========================
    /// 📦 UPDATE UI LIST
    /// =========================
    productCtr.products.value = filtered;
  }  ///
  // void filterAndSortPrds({
  //   required String searchText,
  //   required String sortField,
  //   required String sortOrder,
  //   required String selectedDateFilter,
  //   required DateTime? selectedMonth,
  //   required DateTimeRange? selectedRange,
  // }) {
  //   DateTime parseDate(String dateStr) {
  //     try {
  //       return DateTime.parse(dateStr);
  //     } catch (e) {
  //       return DateTime(1900);
  //     }
  //   }
  //
  //   debugPrint("========== FILTER START ==========");
  //   debugPrint("selectedDateFilter : $selectedDateFilter");
  //   debugPrint("selectedMonth      : $selectedMonth");
  //   debugPrint("selectedRange      : $selectedRange");
  //
  //   final now = DateTime.now();
  //   final todayStart = DateTime(now.year, now.month, now.day);
  //   final source = products2; // original ALWAYS
  //   final filtered = source.where((activity) {
  //     final activityDate =
  //     parseDate(activity.createdTs.toString());
  //
  //     /// SEARCH
  //     // bool matchesSearch =  searchText.isEmpty || activity.pTitle .toString() .toLowerCase() .contains(searchText.toLowerCase());
  //
  //     /// DATE FILTER
  //     bool matchesDate = true;
  //
  //     if (selectedRange != null) {
  //       final start = DateTime(
  //         selectedRange.start.year,
  //         selectedRange.start.month,
  //         selectedRange.start.day,
  //       );
  //
  //       final end = DateTime(
  //         selectedRange.end.year,
  //         selectedRange.end.month,
  //         selectedRange.end.day,
  //         23,
  //         59,
  //         59,
  //       );
  //
  //       matchesDate =
  //           !activityDate.isBefore(start) &&
  //               !activityDate.isAfter(end);
  //     }
  //
  //     else if (selectedMonth != null) {
  //       matchesDate =
  //           activityDate.month ==
  //               selectedMonth.month &&
  //               activityDate.year ==
  //                   selectedMonth.year;
  //     }
  //
  //     else if (selectedDateFilter == "Today") {
  //       final tomorrow =
  //       todayStart.add(const Duration(days: 1));
  //
  //       matchesDate =
  //           !activityDate.isBefore(todayStart) &&
  //               activityDate.isBefore(tomorrow);
  //     }
  //
  //     else if (selectedDateFilter == "Yesterday") {
  //       final yesterday =
  //       todayStart.subtract(const Duration(days: 1));
  //
  //       matchesDate =
  //           !activityDate.isBefore(yesterday) &&
  //               activityDate.isBefore(todayStart);
  //     }
  //
  //     else if (selectedDateFilter == "Last 7 Days") {
  //       final start =
  //       todayStart.subtract(const Duration(days: 6));
  //
  //       matchesDate =
  //           !activityDate.isBefore(start) &&
  //               activityDate.isBefore(
  //                   todayStart.add(
  //                       const Duration(days: 1)));
  //     }
  //
  //     else if (selectedDateFilter == "Last 30 Days") {
  //       final start =
  //       todayStart.subtract(const Duration(days: 29));
  //
  //       matchesDate =
  //           !activityDate.isBefore(start) &&
  //               activityDate.isBefore(
  //                   todayStart.add(
  //                       const Duration(days: 1)));
  //     }
  //
  //     debugPrint(
  //         "Date : $activityDate => Match : $matchesDate");
  //
  //     return matchesDate;
  //   }).toList();
  //
  //   debugPrint("Filtered Count Before Sort : ${filtered.length}");
  //
  //   /// SORTING
  //   // switch (sortField) {
  //   //   case 'name':
  //   //     filtered.sort((a, b) {
  //   //       final result = a.customerName
  //   //           .toString()
  //   //           .toLowerCase()
  //   //           .compareTo(
  //   //         b.customerName
  //   //             .toString()
  //   //             .toLowerCase(),
  //   //       );
  //   //
  //   //       return sortOrder == 'asc'
  //   //           ? result
  //   //           : -result;
  //   //     });
  //   //     break;
  //   //
  //   //   case 'company':
  //   //     filtered.sort((a, b) {
  //   //       final result = a.companyName
  //   //           .toString()
  //   //           .toLowerCase()
  //   //           .compareTo(
  //   //         b.companyName
  //   //             .toString()
  //   //             .toLowerCase(),
  //   //       );
  //   //
  //   //       return sortOrder == 'asc'
  //   //           ? result
  //   //           : -result;
  //   //     });
  //   //     break;
  //   //
  //   //   case 'status':
  //   //     filtered.sort((a, b) {
  //   //       final result = a.status
  //   //           .toString()
  //   //           .toLowerCase()
  //   //           .compareTo(
  //   //         b.status
  //   //             .toString()
  //   //             .toLowerCase(),
  //   //       );
  //   //
  //   //       return sortOrder == 'asc'
  //   //           ? result
  //   //           : -result;
  //   //     });
  //   //     break;
  //   //
  //   //   case 'number':
  //   //     filtered.sort((a, b) {
  //   //       final result =
  //   //       (int.tryParse(a.orderId.toString()) ?? 0)
  //   //           .compareTo(
  //   //         int.tryParse(
  //   //             b.orderId.toString()) ??
  //   //             0,
  //   //       );
  //   //
  //   //       return sortOrder == 'asc'
  //   //           ? result
  //   //           : -result;
  //   //     });
  //   //     break;
  //   //
  //   //   case 'amt':
  //   //     filtered.sort((a, b) {
  //   //       final result =
  //   //       (double.tryParse(
  //   //           a.totalAmt.toString()) ??
  //   //           0)
  //   //           .compareTo(
  //   //         double.tryParse(
  //   //             b.totalAmt.toString()) ??
  //   //             0,
  //   //       );
  //   //
  //   //       return sortOrder == 'asc'
  //   //           ? result
  //   //           : -result;
  //   //     });
  //   //     break;
  //   //
  //   //   case 'date':
  //   //     filtered.sort((a, b) {
  //   //       final result = parseDate(
  //   //         a.createdTs.toString(),
  //   //       ).compareTo(
  //   //         parseDate(
  //   //           b.createdTs.toString(),
  //   //         ),
  //   //       );
  //   //
  //   //       return sortOrder == 'asc'
  //   //           ? result
  //   //           : -result;
  //   //     });
  //   //     break;
  //   // }
  //
  //   debugPrint(
  //       "Filtered Count After Sort : ${filtered.length}");
  //
  //   products.assignAll(filtered);
  //
  //   debugPrint(
  //       "products Count : ${products.length}");
  //
  //   debugPrint("========== FILTER END ==========");
  // }
///
  // void filterAndSortProductsDetails({
  //   required String searchText,
  //   required String sortField,
  //   required String sortOrder,
  //   required String selectedDateFilter,
  //   required DateTime? selectedMonth,
  //   required DateTimeRange? selectedRange,
  // }) {
  //   DateTime parseDate(String dateStr) {
  //     try {
  //       return DateTime.parse(dateStr); // 🔥 BEST
  //     } catch (e) {
  //       return DateTime(1900);
  //     }
  //   }
  //   debugPrint("selectedDateFilter $selectedDateFilter");
  //   // final now = DateTime.now();
  //
  //   final filtered = products2.where((activity) {
  //
  //     final matchesSearch =
  //         searchText.isEmpty ||
  //             activity.pTitle.toString().toLowerCase().contains(searchText.toLowerCase()) ||
  //             activity.mrp.toString().toLowerCase().contains(searchText.toLowerCase());
  //
  //     final activityDate = parseDate(activity.createdTs.toString());
  //
  //     bool matchesDate = true;
  //
  //     final now = DateTime.now();
  //     final todayStart = DateTime(now.year, now.month, now.day);
  //
  //     /// Today
  //     if (selectedDateFilter == "Today") {
  //       final tomorrowStart = todayStart.add(const Duration(days: 1));
  //
  //       matchesDate = activityDate.isAfter(todayStart) &&
  //           activityDate.isBefore(tomorrowStart);
  //     }
  //
  //     /// Yesterday
  //     else if (selectedDateFilter == "Yesterday") {
  //       final yesterdayStart = todayStart.subtract(const Duration(days: 1));
  //
  //       matchesDate = activityDate.isAfter(yesterdayStart) &&
  //           activityDate.isBefore(todayStart);
  //     }
  //
  //     /// Last 7 Days
  //     else if (selectedDateFilter == "Last 7 Days") {
  //       final start = todayStart.subtract(const Duration(days: 6));
  //
  //       matchesDate = activityDate.isAfter(start) &&
  //           activityDate.isBefore(todayStart.add(const Duration(days: 1)));
  //     }
  //
  //     /// Last 30 Days
  //     else if (selectedDateFilter == "Last 30 Days") {
  //       final start = todayStart.subtract(const Duration(days: 29));
  //
  //       matchesDate = activityDate.isAfter(start) &&
  //           activityDate.isBefore(todayStart.add(const Duration(days: 1)));
  //     }
  //     debugPrint("activityDate ${activityDate}");
  //     debugPrint("selectedRange ${selectedRange}");
  //
  //     /// Date Range Filter (same date issue fixed)
  //     if (selectedRange != null) {
  //       final start = DateTime(
  //         selectedRange.start.year,
  //         selectedRange.start.month,
  //         selectedRange.start.day,
  //       );
  //
  //       final end = DateTime(
  //         selectedRange.end.year,
  //         selectedRange.end.month,
  //         selectedRange.end.day,
  //         23, 59, 59,
  //       );
  //
  //       matchesDate = !activityDate.isBefore(start) &&
  //           !activityDate.isAfter(end);
  //     }
  //     /// Month Filter
  //     if (selectedMonth != null) {
  //       matchesDate = activityDate.month == selectedMonth.month &&
  //           activityDate.year == selectedMonth.year;
  //     }
  //
  //     return matchesSearch && matchesDate;
  //
  //   }).toList();
  //
  //   /// Sorting
  //   /// Sorting
  //   if (sortField == 'name') {
  //     filtered.sort((a, b) {
  //       final comparison =
  //       a.pTitle.toString().toLowerCase().compareTo(b.pTitle.toString().toLowerCase());
  //       return sortOrder == 'asc' ? comparison : -comparison;
  //     });
  //   }
  //   else if (sortField == 'mrp') {
  //     filtered.sort((a, b) {
  //       final aVal = int.tryParse(a.mrp.toString()) ?? 0;
  //       final bVal = int.tryParse(b.mrp.toString()) ?? 0;
  //       final comparison = aVal.compareTo(bVal);
  //       return sortOrder == 'asc' ? comparison : -comparison;
  //     });
  //   }
  //   else if (sortField == 'price') {
  //     filtered.sort((a, b) {
  //       final aVal = int.tryParse(a.outPrice.toString()) ?? 0;
  //       final bVal = int.tryParse(b.outPrice.toString()) ?? 0;
  //       final comparison = aVal.compareTo(bVal);
  //       return sortOrder == 'asc' ? comparison : -comparison;
  //     });
  //   }
  //   else if (sortField == 'sku') {
  //     filtered.sort((a, b) {
  //       final aVal = int.tryParse(a.skuId.toString()) ?? 0;
  //       final bVal = int.tryParse(b.skuId.toString()) ?? 0;
  //       final comparison = aVal.compareTo(bVal);
  //       return sortOrder == 'asc' ? comparison : -comparison;
  //     });
  //   }
  //   else if (sortField == 'hsn') {
  //     filtered.sort((a, b) {
  //       final aVal = int.tryParse(a.hsnCode.toString()) ?? 0;
  //       final bVal = int.tryParse(b.hsnCode.toString()) ?? 0;
  //       final comparison = aVal.compareTo(bVal);
  //       return sortOrder == 'asc' ? comparison : -comparison;
  //     });
  //   }
  //   else if (sortField == 'gst') {
  //     filtered.sort((a, b) {
  //       final aVal = int.tryParse(a.cgst.toString()) ?? 0;
  //       final bVal = int.tryParse(b.cgst.toString()) ?? 0;
  //       final comparison = aVal.compareTo(bVal);
  //       return sortOrder == 'asc' ? comparison : -comparison;
  //     });
  //   }
  //   else if (sortField == 'date') {
  //     filtered.sort((a, b) {
  //       final dateA = parseDate(a.createdTs.toString());
  //       final dateB = parseDate(b.createdTs.toString());
  //       final comparison = dateA.compareTo(dateB);
  //       return sortOrder == 'asc' ? comparison : -comparison;
  //     });
  //   }
  //   else if (sortField == 'barcode') {
  //     filtered.sort((a, b) {
  //       final comparison =
  //       a.barcode.toString().toLowerCase().compareTo(b.barcode.toString().toLowerCase());
  //       return sortOrder == 'asc' ? comparison : -comparison;
  //     });
  //   }
  //   else if (sortField == 'cat') {
  //     filtered.sort((a, b) {
  //       final comparison =
  //       a.category.toString().toLowerCase().compareTo(b.category.toString().toLowerCase());
  //       return sortOrder == 'asc' ? comparison : -comparison;
  //     });
  //   }
  //   else if (sortField == 'subcat') {
  //     filtered.sort((a, b) {
  //       final comparison =
  //       a.subCategory.toString().toLowerCase().compareTo(b.subCategory.toString().toLowerCase());
  //       return sortOrder == 'asc' ? comparison : -comparison;
  //     });
  //   }
  //   else if (sortField == 'brand') {
  //     filtered.sort((a, b) {
  //       final comparison =
  //       a.brand.toString().toLowerCase().compareTo(b.brand.toString().toLowerCase());
  //       return sortOrder == 'asc' ? comparison : -comparison;
  //     });
  //   }
  //   products.assignAll(filtered);
  // }


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

    // final now = DateTime.now();

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
      debugPrint("activityDate ${activityDate}");
      debugPrint("selectedRange ${selectedRange}");

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
    }else if (sortField == 'company') {
      filtered.sort((a, b) {
        final comparison =
        a.company.toString().toLowerCase().compareTo(b.company.toString().toLowerCase());
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }else if (sortField == 'qno') {
      filtered.sort((a, b) {
        final comparison =
        a.quotationNo.toString().toLowerCase().compareTo(b.quotationNo.toString().toLowerCase());
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
    }else if (sortField == 'products') {
      filtered.sort((a, b) {
        final aVal = int.tryParse(a.totalProduct.toString()) ?? 0;
        final bVal = int.tryParse(b.totalProduct.toString()) ?? 0;
        final comparison = aVal.compareTo(bVal);
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }else if (sortField == 'item') {
      filtered.sort((a, b) {
        final aVal = int.tryParse(a.totalItem.toString()) ?? 0;
        final bVal = int.tryParse(b.totalItem.toString()) ?? 0;
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
    }else if (sortField == 'validity') {
        filtered.sort((a, b) {
          final dateA = parseDate(a.validityDate);
          final dateB = parseDate(b.validityDate);
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
  late TabController productTab;
  void changeTab(int index) {
    productCtr.productTab.index=index;
  }
  @override
  void onInit() {
    productTab = TabController(length: 2, vsync: this);
    productTab.addListener(() {
    });
    super.onInit();
  }



  String showCrtDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "";

    DateTime dt = DateTime.parse(dateStr);
    DateTime now = DateTime.now();
    return DateFormat('dd-MM-yyyy').format(dt);
    // if (dt.year == now.year) {
    // } else {
    //   return DateFormat('dd MMM yyyy').format(dt); // 14 Apr 2025
    // }
  }
  @override
  void onClose() {
    productTab.dispose();
    super.onClose();
  }

  RxList<Quotations> quotationsList=<Quotations>[].obs;
  RxList<Quotations> quotationsList2=<Quotations>[].obs;
  RxList<QuotationsDetails> quotationsListDetail=<QuotationsDetails>[].obs;
  Future<List<Quotations>> getQuotationDetails() async {
    try {
      // quotationsList.clear();
      // quotationsList2.clear();
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

      // debugPrint("STATUS CODE add_values: ${response.statusCode}");
      // debugPrint("get_quotations..: ${response.body}");
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
        // debugPrint("get_quotations..: ${quotationsList.length}");
        // debugPrint("get_quotations..: ${quotationsList2.length}");
        return quotationsList;
      }else{
          return [];
      }
    } catch (e) {
      return [];
    }
  }
  var dataRefresh=true.obs;
  Future<List<QuotationsDetails>> getQuotationFullDetails(String id) async {
    try {
      dataRefresh.value=false;
      quotationsListDetail.clear();
      final response = await http.post(
        Uri.parse(scriptApi),
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "action": "get_data",
          "search_type": "quotations_full_details",
          "role": controllers.storage.read("role").toString(),
          "id": id,
          "cos_id": controllers.storage.read("cos_id").toString(),
        }),
      );

      // debugPrint(id);
      // debugPrint("get_quotations..: ${response.body}");
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return getQuotationFullDetails(id);
        } else {
          controllers.setLogOut();
        }
      }
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        quotationsListDetail.value =data.map((e) => QuotationsDetails.fromJson(e)).toList();
        dataRefresh.value=true;
        return quotationsListDetail;
      }else{
        dataRefresh.value=true;
        return [];
      }
    } catch (e) {
      dataRefresh.value=true;
      return [];
    }
  }
  RxList termsAndConditionsList=[].obs;
  RxList termsAndConditionsList2=[].obs;
  Future<List> getTermsAndConditions() async {
    try {
      termsAndConditionsList.clear();
      termsAndConditionsList2.clear();
      final response = await http.post(
        Uri.parse(scriptApi),
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "action": "get_data",
          "search_type": "get_terms_and_conditions",
          "role": controllers.storage.read("role").toString(),
          "cos_id": controllers.storage.read("cos_id").toString(),
        }),
      );

      // debugPrint("STATUS CODE add_values: ${response.statusCode}");
      // debugPrint("getTermsAndConditions..: ${response.body}");
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return getTermsAndConditions();
        } else {
          controllers.setLogOut();
        }
      }
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        termsAndConditionsList.value =data;
        termsAndConditionsList2.value =data;
        // debugPrint("get_quotations..: ${quotationsList.length}");
        // debugPrint("get_quotations..: ${quotationsList2.length}");
        return termsAndConditionsList;
      }else{
          return [];
      }
    } catch (e) {
      return [];
    }
  }
  RxList<BillingRow> rows = <BillingRow>[].obs;

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
      debugPrint("Request: ${jsonEncode(data)}");
      final response = await http.post(
        Uri.parse(scriptApi),
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );


      // debugPrint("STATUS CODE: ${response.statusCode}");
      // debugPrint("RAW RESPONSE: ${response.body}");
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
        debugPrint("API Error: ${decoded["message"]}");
      }
      saveCtr.reset();
    } catch (e) {
      utils.snackBar(context: context, msg: "Failed", color: Colors.red);
      productCtr.saveCtr.reset();
      saveCtr.reset();
      debugPrint("FLUTTER ERROR => $e");
    }
  }

}
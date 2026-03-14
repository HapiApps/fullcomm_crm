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
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common/constant/api.dart';
import '../common/constant/colors_constant.dart';
import '../common/utilities/utils.dart';
import '../common/widgets/log_in.dart';
import '../components/custom_loading_button.dart';
import '../components/custom_text.dart';
import '../components/custom_textfield.dart';
import '../models/product_model.dart';
import '../models/template_obj.dart';
import '../services/api_services.dart';
import 'controller.dart';

final productCtr = Get.put(ProductController());

class ProductController extends GetxController with GetSingleTickerProviderStateMixin {
  final TextEditingController title = TextEditingController();
  final TextEditingController description = TextEditingController();
  final TextEditingController availability = TextEditingController();
  final TextEditingController condition = TextEditingController();
  final TextEditingController price = TextEditingController();
  final TextEditingController brand = TextEditingController();
  final RoundedLoadingButtonController saveCtr = RoundedLoadingButtonController();
  Rxn<PlatformFile> selectedFile = Rxn<PlatformFile>();

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
  Future<void> updateProduct(context,String id,String imagePath) async {
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
          return updateProduct(context,id,imagePath);
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

 RxList<ProductModel> products=<ProductModel>[].obs;

  Future<List<ProductModel>> getProducts() async {
    try {
      products.clear();
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
      print("get_products...: ${response.body}");
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
        return products;
      }else{
          return [];
      }
    } catch (e) {
      log("FLUTTER ERROR => $e");
      return [];
    }
  }

}
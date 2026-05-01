import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../common/constant/api.dart';
import 'controller.dart';

final exControllers = Get.put(ExtractedInfoControllerNew());
class ExtractedInfoControllerNew extends GetxController {

  // Observables
  var extractedFields = <String, String>{}.obs;
  var tempFields = <String, String>{}.obs;
  var reorderedKeys = <String>[].obs;
  var isEditing = false.obs;
  var selectedCategory = RxnString();
  var isLoading = false.obs;
  Rx<File?> scannedImage = Rx<File?>(null);

  // 🔹 Add new fields from OCR
  void addExtractedFields(Map<String, String> fields) {
    extractedFields.addAll(fields);

    for (var key in fields.keys) {
      if (!reorderedKeys.contains(key)) {
        reorderedKeys.add(key);
      }
    }
    initControllers();
  }
  void clearExtractedFields() {
    extractedFields.clear();
    reorderedKeys.clear();
    for (var controller in fieldControllers.values) {
      controller.dispose();
    }
    fieldControllers.clear();
  }


  void toggleEditing() {
    isEditing.value = !isEditing.value;
    if (isEditing.value) {
      tempFields.assignAll(extractedFields);
    } else {
      tempFields.clear();
    }
  }
  void resetEdits() {
    tempFields.clear();
    isEditing.value = false;
  }

  // 🔹 Category selection
  void selectCategory(String? category) {
    selectedCategory.value = category;
  }

  // 🔹 Get effective value
  String? getEffectiveValue(String key) {
    if (isEditing.value && tempFields.containsKey(key)) {
      return tempFields[key];
    }
    return extractedFields[key];
  }

  var fieldControllers = <String, TextEditingController>{}.obs;
  void initControllers() {
    for (var key in reorderedKeys) {
      fieldControllers[key] = TextEditingController(
        text: getEffectiveValue(key) ?? "",
      );
    }
  }
  Map<String, String> getFinalFields() {
    final Map<String, String> result = {};

    for (var key in reorderedKeys) {
      final temp = tempFields[key];
      final ctrl = fieldControllers[key]?.text;
      final extracted = extractedFields[key];

      result[key] =
      (temp != null && temp.trim().isNotEmpty)
          ? temp
          : (ctrl != null && ctrl.trim().isNotEmpty)
          ? ctrl
          : (extracted != null && extracted.trim().isNotEmpty)
          ? extracted
          : "";
    }

    return result;
  }

  String getFinalValue(String key) {
    final temp = tempFields[key];
    final ctrl = fieldControllers[key]?.text;
    final extracted = extractedFields[key];

    if (temp != null && temp.trim().isNotEmpty) return temp.trim();
    if (ctrl != null && ctrl.trim().isNotEmpty) return ctrl.trim();
    if (extracted != null && extracted.trim().isNotEmpty) return extracted.trim();

    return "";
  }


  var dataFrom = "1".obs;

  Future<bool> saveVisitingCardToServers(
      String contactType,
      String nameP,
      String phoneP,
      String emailP,
      String doorNumP,
      String streetP,
      String areaP,
      String cityP,
      String stateP,
      String countryP,
      String pincodeP,
      String coNameP,
      String designationP,
      String jobTitleP, {
        File? audioFile,
      }) async {
    try {
      final phoneD = phoneP.trim();

      if (phoneD.isEmpty) {
        Get.snackbar(
          "Error",
          "Data not clear. Please capture the card again",
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        controllers.isUpdateLoading.value = false;
        return false;
      }
      Future<http.StreamedResponse> sendRequest(String token) async {
        final request = http.MultipartRequest(
          'POST',
          Uri.parse(scriptApi),
        );

        request.fields.addAll({
          "action": "share_visiting_card_crm",
          "user_id": controllers.storage.read("id").toString(),
          "fullname_g": nameP,
          "phone_number_g": phoneD,
          "whatsapp_number_g": phoneD,
          "mobile_number_g": phoneD,
          "phone_map": phoneD,
          "email": emailP,
          "email_map": emailP,
          "co_address": "",
          "sharing_location": controllers.sharingLocation.value,
          "notes": controllers.notesController.text,
          "address": cityP,
          "door_no": doorNumP,
          "street_name": streetP,
          "area": areaP,
          "city": cityP,
          "state": stateP,
          "pincode": pincodeP,
          "country": countryP,
          "notes_g": getFinalValue("Slogan"),
          "live_data_g": "1",
          "facebook_id_g":
          getFinalValue("Socials").contains("facebook")
              ? getFinalValue("Socials")
              : "",
          "instagram_id_g":
          getFinalValue("Socials").contains("instagram")
              ? getFinalValue("Socials")
              : "",
          "twitter_id_g":
          getFinalValue("Socials").contains("twitter")
              ? getFinalValue("Socials")
              : "",
          "linkedin_id_g":
          getFinalValue("Socials").contains("linkedin")
              ? getFinalValue("Socials")
              : "",
          "co_name_g": coNameP,
          "designation": jobTitleP,
          "info_g": designationP,
          "industry_g": "",
          "sub_industry_g": "",
          "products_g": "",
          "data_from": "3",
          "contact_type": contactType,
        });

        request.headers.addAll({
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        });

        if (audioFile != null && await audioFile.exists()) {
          request.files.add(
            await http.MultipartFile.fromPath('audio', audioFile.path),
          );
        }

        return await request.send();
      }
      String token = controllers.storage.read("jwt_token");
      var streamedResponse = await sendRequest(token);

      if (streamedResponse.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return saveVisitingCardToServers(contactType,nameP,phoneP,emailP,
              doorNumP,streetP,areaP,cityP,stateP,countryP,pincodeP,coNameP,designationP,jobTitleP,
            audioFile: audioFile,
          );
        } else {
          controllers.setLogOut();
        }
      }

      final responseBody = await streamedResponse.stream.bytesToString();


      if (responseBody.isEmpty) {
        Get.snackbar(
          "Error",
          "Server returned empty response",
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
        );
        controllers.isUpdateLoading.value = false;
        return false;
      }

      final dataOutput = jsonDecode(responseBody);

      if (streamedResponse.statusCode != 200 ||
          dataOutput["status"] == "error") {
        Get.snackbar(
          "Error",
          dataOutput["message"] ?? "Server error",
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
        );
        controllers.isUpdateLoading.value = false;
        return false;
      }

      Get.snackbar(
        "Success",
        "Visiting card saved successfully!",
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return true;

    } catch (e, st) {

      Get.snackbar(
        "Error",
        "Something went wrong. Please try again.",
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      controllers.isUpdateLoading.value = false;
      return false;
    }
  }


  void resetController() {
    extractedFields.clear();
    tempFields.clear();
    scannedImage.value = null;
    selectedCategory.value = "All";
    isEditing.value = false;
  }

}


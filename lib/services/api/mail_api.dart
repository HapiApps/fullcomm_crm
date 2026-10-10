import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:fullcomm_crm/common/constant/api.dart';
import 'package:fullcomm_crm/common/utilities/jwt_storage.dart';
import 'package:fullcomm_crm/common/utilities/utils.dart';
import 'package:fullcomm_crm/controller/controller.dart';
import 'package:fullcomm_crm/controller/image_controller.dart';
import 'package:fullcomm_crm/controller/reminder_controller.dart';
import 'package:fullcomm_crm/models/customer_activity.dart';

import '../api_services.dart';

extension MailApi on ApiService {
  Future bulkEmailAPI(
      BuildContext context, List<Map<String, String>> list) async {
    try {
      debugPrint("bulkEmailAPI called");
      debugPrint("Total leads: ${list.length}");

      var request = http.MultipartRequest('POST', Uri.parse(scriptApi));

      request.fields['subject'] = controllers.emailSubjectCtr.text;
      request.fields['cos_id'] = controllers.storage.read("cos_id").toString();
      request.fields['count'] = '${controllers.emailCount.value + 1}';
      request.fields['quotation_name'] = controllers.emailQuotationCtr.text;
      request.fields['body'] = controllers.emailMessageCtr.text;
      request.fields['user_id'] = controllers.storage.read("id").toString();
      request.fields['date'] = "${controllers.dateTime.day.toString().padLeft(2, "0")}-"
          "${controllers.dateTime.month.toString().padLeft(2, "0")}-"
          "${controllers.dateTime.year} "
          "${DateFormat('hh:mm a').format(DateTime.now())}";
      request.fields['action'] = 'bulk_mail_receive';

      /// Extract ids & emails
      List<String> ids = list.map((e) => e['lead_id'] ?? '').toList();
      List<String> emails = list.map((e) => e['mail_id'] ?? '').toList();

      request.fields['clientMail'] = emails.join(",");
      request.fields['id'] = ids.join(",");

      if (imageController.images.isNotEmpty) {
        for (var file in imageController.images) {
          request.files.add(
            http.MultipartFile.fromBytes(
              "attachment[]",
              file["bytes"],
              filename: file["fileName"],
            ),
          );
        }
      }

      debugPrint("Emails: ${emails.join(",")}");
      debugPrint("Lead IDs: ${ids.join(",")}");

      debugPrint("Request Fields:");
      request.fields.forEach((key, value) {
        debugPrint("$key : $value");
      });

      request.headers.addAll({
        'X-API-TOKEN': "${TokenStorage().readToken()}",
        'Content-Type': 'application/json',
      });

      if (imageController.empFileName.value.isNotEmpty) {
        debugPrint("Attachment: ${imageController.empFileName.value}");

        var picture1 = http.MultipartFile.fromBytes(
          "attachment",
          imageController.empMediaData,
          filename: imageController.empFileName.value,
        );
        request.files.add(picture1);
      } else {
        debugPrint("No attachment added");
      }

      debugPrint("Sending bulk mail request...");
      var response = await request.send();

      debugPrint("Status Code: ${response.statusCode}");

      var body = await response.stream.bytesToString();
      debugPrint("Response Body: $body");
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return bulkEmailAPI(context, list);
        } else {
          controllers.setLogOut();
        }
      }
      if (body.contains("Mail process completed.")) {
        debugPrint("Bulk mail success");
        controllers.idList.clear();
        utils.snackBar(
          msg: "Mail has been sent",
          color: Colors.green,
          context: Get.context!,
        );
        controllers.emailMessageCtr.clear();
        controllers.emailToCtr.clear();
        controllers.emailSubjectCtr.clear();

        prospectsList.clear();
        allNewLeadsDetails();

        await Future.delayed(const Duration(milliseconds: 100));
        Navigator.pop(Get.context!);

        controllers.emailCtr.reset();
      } else {
        debugPrint("Bulk mail failed");
        controllers.emailCtr.reset();
        errorDialog(Get.context!, "Mail has not been sent");
      }
    } catch (e, s) {
      debugPrint("Exception: $e");
      debugPrint("StackTrace: $s");

      errorDialog(Get.context!, e.toString());
      controllers.emailCtr.reset();
    }
  }

  Future insertEmailAPI(BuildContext context, String id, String image) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(scriptApi));

      // Body values
      request.fields['clientMail'] = controllers.emailToCtr.text;
      request.fields['subject'] = controllers.emailSubjectCtr.text;
      request.fields['cos_id'] = controllers.storage.read("cos_id").toString();
      request.fields['count'] = '${controllers.emailCount.value + 1}';
      request.fields['quotation_name'] = controllers.emailQuotationCtr.text;
      request.fields['body'] = controllers.emailMessageCtr.text;
      request.fields['user_id'] = controllers.storage.read("id").toString();
      request.fields['id'] = id;
      request.fields['date'] =
      "${controllers.dateTime.day.toString().padLeft(2, "0")}-${controllers.dateTime.month.toString().padLeft(2, "0")}-${controllers.dateTime.year.toString()} ${DateFormat('hh:mm a').format(DateTime.now())}";
      request.fields['action'] = 'send_email';
      request.fields['customer_name'] = controllers.selectedCustomerName.value;
      request.headers.addAll({
        'X-API-TOKEN': "${TokenStorage().readToken()}",
        'Content-Type': 'application/json'
      });
      if (imageController.images.isNotEmpty) {
        for (var file in imageController.images) {
          request.files.add(
            http.MultipartFile.fromBytes(
              "attachment[]",
              file["bytes"],
              filename: file["fileName"],
            ),
          );
        }
      }

      var response = await request.send();
      var body = await response.stream.bytesToString();
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return insertEmailAPI(context, id, image);
        } else {
          controllers.setLogOut();
        }
      }
      if (body.toString().contains('Message has been sent')) {
        utils.snackBar(
            msg: "Mail has been sent",
            color: Colors.green,
            context: Get.context!);
        controllers.emailMessageCtr.clear();
        controllers.emailToCtr.clear();
        controllers.emailSubjectCtr.clear();
        allLeadsDetails();
        allNewLeadsDetails();
        getAllMailActivity();
        controllers.allGoodLeadFuture = allGoodLeadsDetails();
        await Future.delayed(const Duration(milliseconds: 100));
        Navigator.pop(Get.context!);
        controllers.emailCtr.reset();
      } else {
        controllers.emailCtr.reset();
        errorDialog(Get.context!, "Mail has been not sent");
      }
    } catch (e) {
      errorDialog(Get.context!, e.toString());
      controllers.emailCtr.reset();
    }
  }

  Future insertMultipleEmailAPI(BuildContext context, List sendList,
      List nameList, List idList, String image) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(scriptApi));

      // Body values
      request.fields['clientMail'] = sendList.join(',');
      request.fields['subject'] = controllers.emailSubjectCtr.text;
      request.fields['cos_id'] = controllers.storage.read("cos_id").toString();
      request.fields['count'] = '${controllers.emailCount.value + 1}';
      request.fields['quotation_name'] = controllers.emailQuotationCtr.text;
      request.fields['body'] = controllers.emailMessageCtr.text;
      request.fields['user_id'] = controllers.storage.read("id").toString();
      request.fields['id'] = idList.join(',');
      request.fields['date'] =
      "${controllers.dateTime.day.toString().padLeft(2, "0")}-${controllers.dateTime.month.toString().padLeft(2, "0")}-${controllers.dateTime.year.toString()} ${DateFormat('hh:mm a').format(DateTime.now())}";
      request.fields['action'] = 'mail_receive';
      request.fields['customer_name'] = nameList.join(',');
      request.headers.addAll({
        'X-API-TOKEN': "${TokenStorage().readToken()}",
      });
      if (imageController.images.isNotEmpty) {
        for (var file in imageController.images) {
          request.files.add(
            http.MultipartFile.fromBytes(
              "attachment[]",
              file["bytes"],
              filename: file["fileName"],
            ),
          );
        }
      }
      var response = await request.send();
      var body = await response.stream.bytesToString();
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return insertMultipleEmailAPI(
              context, sendList, nameList, idList, image);
        } else {
          controllers.setLogOut();
        }
      }
      debugPrint("body");
      debugPrint(body);
      if (response.statusCode == 200) {
        utils.snackBar(
            msg: "Mail has been sent",
            color: Colors.green,
            context: Get.context!);
        controllers.emailMessageCtr.clear();
        controllers.emailToCtr.clear();
        controllers.emailSubjectCtr.clear();
        getAllMailActivity();
        await Future.delayed(const Duration(milliseconds: 100));
        Navigator.pop(Get.context!);
        controllers.emailCtr.reset();
      } else {
        controllers.emailCtr.reset();
        errorDialog(Get.context!, "Mail has been not sent");
      }
    } catch (e) {
      errorDialog(Get.context!, e.toString());
      controllers.emailCtr.reset();
    }
  }

  Future<void> getAllMailActivity() async {
    controllers.isSent.value = true;
    controllers.isMailLoading.value = true;
    controllers.isOpened.value = false;
    controllers.isReplied.value = false;
    try {
      final data = {
        "search_type": "mails",
        "cos_id": controllers.storage.read("cos_id"),
        "action": "get_data",
        "type": "8",
      };
      final request = await http.post(
        Uri.parse(scriptApi),
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
      controllers.isMailLoading.value = false;
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return getAllMailActivity();
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200) {
        final List response = json.decode(request.body);
        controllers.mailActivity.clear();
        final activities =
        response.map((e) => CustomerActivity.fromJson(e)).toList();
        controllers.mailActivity.assignAll(activities);
        controllers.allSentMails.value =
            controllers.mailActivity.length.toString();
        remController.sortMails('');
      } else {
        throw Exception('Failed to load mail activity');
      }
    } catch (e) {
      controllers.mailActivity.clear();
      controllers.isMailLoading.value = false;
      rethrow;
    }
  }

  Future getReplyMailActivity(bool isMain) async {
    controllers.mailActivity.clear();
    controllers.isReplied.value = true;
    controllers.isMailLoading.value = true;
    controllers.isOpened.value = false;
    controllers.isSent.value = false;
    try {
      Map data = {
        "cos_id": controllers.storage.read("cos_id"),
        "action": "fetch_mails",
        "type": "reply"
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      controllers.isMailLoading.value = false;

      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return getReplyMailActivity(isMain);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200) {
        List response = json.decode(request.body);
        if (isMain == false) {
          controllers.mailActivity.value =
              response.map((e) => CustomerActivity.fromJson(e)).toList();
        }
        controllers.allReplyMails.value = response.length.toString();
      } else {
        throw Exception('Failed to load album');
      }
    } catch (e) {
      controllers.isMailLoading.value = false;
      throw Exception('Failed to load album');
    }
  }

  Future getOpenedMailActivity(bool isMain) async {
    controllers.mailActivity.clear();
    controllers.isOpened.value = true;
    controllers.isMailLoading.value = true;
    controllers.isSent.value = false;
    controllers.isReplied.value = false;
    try {
      Map data = {
        "cos_id": controllers.storage.read("cos_id"),
        "action": "fetch_mails",
        "type": "reply_seen"
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      controllers.isMailLoading.value = false;
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return getOpenedMailActivity(isMain);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200) {
        List response = json.decode(request.body);
        if (isMain == false) {
          controllers.mailActivity.value =
              response.map((e) => CustomerActivity.fromJson(e)).toList();
        }
        controllers.allOpenedMails.value = response.length.toString();
      } else {
        throw Exception('Failed to load album');
      }
    } catch (e) {
      controllers.isMailLoading.value = false;
      throw Exception('Failed to load album');
    }
  }

  void mailReceiveDetails(String id) async {
    final url = Uri.parse(scriptApi);
    try {
      final response = await http.post(
        url,
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "search_type": "mail_receive",
          "cos_id": controllers.storage.read("cos_id"),
          "sent_id": id,
          "action": "get_data"
        }),
      );
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return mailReceiveDetails(id);
        } else {
          controllers.setLogOut();
        }
      }
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        controllers.mailReceivesList.value = data;
        controllers.emailCount.value = int.parse(controllers
            .mailReceivesList[controllers.mailReceivesList.length - 1]
        ['sent_count']);
      } else {
        controllers.mailReceivesList.value = [];
        throw Exception(
            'Failed to load leads: Status code ${response.statusCode}');
      }
    } on SocketException {
      controllers.mailReceivesList.value = [];
    } on HttpException {
      controllers.mailReceivesList.value = [];
    } catch (e) {
      controllers.mailReceivesList.value = [];
    }
  }
}
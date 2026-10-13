import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:fullcomm_crm/common/constant/api.dart';
import 'package:fullcomm_crm/common/utilities/jwt_storage.dart';
import 'package:fullcomm_crm/controller/controller.dart';
import 'package:fullcomm_crm/services/api_services.dart';

class CustomerAudio {
  final String id, title, fileName, url, createdTs;
  final String endTs;
  final int durationSec;
  CustomerAudio({
    required this.id,
    required this.title,
    required this.fileName,
    required this.url,
    required this.createdTs,
    required this.endTs,
    required this.durationSec,
  });

  factory CustomerAudio.fromJson(Map<String, dynamic> j) => CustomerAudio(
    id: j['id'].toString(),
    title: (j['title'] ?? '').toString(),
    fileName: (j['file_name'] ?? '').toString(),
    url: (j['file_url'] ?? '').toString(),
    createdTs: (j['created_ts'] ?? '').toString(),
    endTs: (j['end_ts'] ?? '').toString(),
    durationSec: (j['duration_seconds'] ?? 0).toInt(),
  );
}

extension AudioApi on ApiService {
  Future<List<CustomerAudio>> getCustomerAudios(String customerId) async {
    final response = await http.post(
      Uri.parse(scriptApi),
      headers: {
        'X-API-TOKEN': "${TokenStorage().readToken()}",
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "search_type": "customer_audios",
        "cos_id": controllers.storage.read("cos_id"),
        "customer_id": customerId,
        "action": "get_data",
      }),
    );
    if (response.statusCode == 401) {
      final refreshed = await controllers.refreshToken();
      if (refreshed) return getCustomerAudios(customerId);
      controllers.setLogOut();
      return [];
    }
    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List;
      return list.map((e) => CustomerAudio.fromJson(e)).toList();
    }
    throw Exception('Failed to load audios: ${response.body}');
  }

  Future<bool> insertCustomerAudio({
    required String customerId,
    required String title,
    required Uint8List bytes,
    required String fileName,
    required String endTs,
    required int durationSec,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse(scriptApi));
    request.fields['action'] = 'insert_customer_audio';
    request.fields['cos_id'] = controllers.storage.read("cos_id").toString();
    request.fields['created_by'] = controllers.storage.read("id").toString();
    request.fields['customer_id'] = customerId;
    request.fields['title'] = title;
    request.headers['X-API-TOKEN'] = "${TokenStorage().readToken()}";
    request.fields['end_ts'] = endTs;
    request.fields['duration_seconds'] = durationSec.toString();
    request.files.add(
        http.MultipartFile.fromBytes('audio', bytes, filename: fileName));

    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode == 401) {
      final refreshed = await controllers.refreshToken();
      if (refreshed) {
        return insertCustomerAudio(
            customerId: customerId,
            title: title,
            bytes: bytes,
            fileName: fileName,
            endTs: endTs,
            durationSec: durationSec);
      }
      controllers.setLogOut();
      return false;
    }
    if (streamed.statusCode == 200 && body.contains('"OK"')) return true;
    throw Exception(body);
  }
}
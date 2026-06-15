import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> readTextFromImage(String base64Image) async {
  final response = await http.post(
    Uri.parse('https://api.ocr.space/parse/image'),
    headers: {
      'apikey': 'YOUR_API_KEY',
    },
    body: {
      'base64Image': base64Image,
      'language': 'eng',
    },
  );

  final data = jsonDecode(response.body);

  if (data['ParsedResults'] != null &&
      data['ParsedResults'].isNotEmpty) {
    return data['ParsedResults'][0]['ParsedText'] ?? '';
  }

  return '';
}
import 'package:get_storage/get_storage.dart';
import 'dart:convert';

class TokenStorage {
  final _box = GetStorage();

  // Store token
  void writeToken(String token) {
    _box.write('jwt_token', token);
  }

  // Read token
  String? readToken() {
    return _box.read('jwt_token');
  }

  // Delete token
  void deleteToken() {
    _box.remove('jwt_token');
  }

  bool isTokenValid() {
    final token = TokenStorage().readToken();
    if (token == null) return false;

    final parts = token.split('.');
    if (parts.length != 3) return false;

    final payload = json.decode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))
    );

    final exp = payload['exp'];
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    if (now > exp) {
      TokenStorage().deleteToken();
      return false;
    }

    return true;
  }

}

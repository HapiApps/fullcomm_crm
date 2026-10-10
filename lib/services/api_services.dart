import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
export 'api/token_api.dart';
export 'api/auth_api.dart';
export 'api/api_dialogs.dart';
export 'api/chat_api.dart';
export 'api/quotation_api.dart';
export 'api/mail_api.dart';
export 'api/activity_api.dart';
export 'api/lead_setup_api.dart';
export 'api/master_api.dart';
export 'api/lead_api.dart';
export 'api/lead_fetch_api.dart';

final ApiService apiService = ApiService._();

class ApiService {
  ApiService._();

  List<Map<String, String>> prospectsList = [];
  List<Map<String, String>> customerList = [];
  List<Map<String, String>> newLeadList = [];

  Future<void>? leadsFuture;

  final GoogleSignIn googleSignIn = GoogleSignIn(
    clientId:
    "391888204695-389lcv491p2shrd8dtds1u6mdid8cb90.apps.googleusercontent.com",
    scopes: [
      'email',
      'https://www.googleapis.com/auth/calendar',
    ],
  );
}
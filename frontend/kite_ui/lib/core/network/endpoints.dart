import 'package:flutter/foundation.dart';

class Endpoints {
  Endpoints._();

  // Dynamic Base URL: Use localhost:9898 for Flutter Web / Windows host, or 192.168.56.101:9898 for LAN devices
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:9898';
    }
    return 'http://192.168.56.101:9898';
  }

  static const String signup = '/auth/v1/signup';
  static const String login = '/auth/v1/login';
  static const String validate = '/auth/v1/validate';
}

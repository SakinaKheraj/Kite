import 'package:flutter/foundation.dart';

class Endpoints {
  Endpoints._();

  // Dynamic IP Resolution
  static String get _hostIp {
    if (kIsWeb) {
      return '192.168.56.101'; // Web browser -> VM Host-Only IP
    }
    return '127.0.0.1'; // Mobile device via ADB reverse port forwarding
  }

  // Auth Service Base URL (Port 9898)
  static String get authBaseUrl => 'http://$_hostIp:9898';

  // Expense Service Base URL (Port 9820)
  static String get expenseBaseUrl => 'http://$_hostIp:9820';

  // DS Service Base URL (Port 8010)
  static String get dsBaseUrl => 'http://$_hostIp:8010';

  // Auth Endpoints
  static const String signup = '/auth/v1/signup';
  static const String login = '/auth/v1/login';
  static const String validate = '/auth/v1/validate';

  // Expense Endpoints
  static String userExpenses(String userId) => '/v1/expenses/user/$userId';
  static String userExpenseSummary(String userId) => '/v1/expenses/summary/$userId';
  static const String addExpense = '/v1/expenses';
  static const String updateExpense = '/v1/expenses';
  static String deleteExpense(dynamic id) => '/v1/expenses/$id';

  // AI DS Endpoints
  static const String parseSms = '/parse-sms';
}

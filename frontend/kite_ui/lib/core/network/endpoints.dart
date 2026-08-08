class Endpoints {
  Endpoints._();

  // Auth Service Base URL (Port 9898)
  static const String authBaseUrl = 'http://192.168.56.101:9898';

  // Expense Service Base URL (Port 9820)
  static const String expenseBaseUrl = 'http://192.168.56.101:9820';

  // Auth Endpoints
  static const String signup = '/auth/v1/signup';
  static const String login = '/auth/v1/login';
  static const String validate = '/auth/v1/validate';

  // Expense Endpoints
  static String userExpenses(String userId) => '/v1/expenses/user/$userId';
  static String userExpenseSummary(String userId) => '/v1/expenses/summary/$userId';
  static const String addExpense = '/v1/expenses';
  static String deleteExpense(dynamic id) => '/v1/expenses/$id';
}

class Endpoints {
  Endpoints._();

  // Render Cloud Live Base URLs
  static const String authBaseUrl = 'https://kite-auth-service.onrender.com';
  static const String expenseBaseUrl = 'https://kite-expense-service.onrender.com';
  static const String dsBaseUrl = 'https://kite-ds-service.onrender.com';

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
  static String updateBudgetLimit(String userId) => '/v1/expenses/budget/$userId';

  // AI DS Endpoints
  static const String parseSms = '/parse-sms';
}

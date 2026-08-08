import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';
import '../models/expense_model.dart';
import '../models/expense_summary_model.dart';

abstract class ExpenseRemoteDataSource {
  Future<List<ExpenseModel>> getExpenses(String userId);
  Future<ExpenseSummaryModel> getExpenseSummary(String userId);
  Future<bool> addExpense(ExpenseModel expense);
  Future<bool> updateExpense(ExpenseModel expense);
  Future<bool> deleteExpense(dynamic id);
}

class ExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  final ApiClient apiClient;

  ExpenseRemoteDataSourceImpl({required this.apiClient});

  String _extractErrorMessage(DioException e) {
    if (e.response != null && e.response?.data != null) {
      final data = e.response!.data;
      if (data is String && data.trim().isNotEmpty) {
        return data.trim();
      } else if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
    }
    return e.message ?? 'Failed to connect to Expense Service';
  }

  @override
  Future<List<ExpenseModel>> getExpenses(String userId) async {
    try {
      final url = '${Endpoints.expenseBaseUrl}${Endpoints.userExpenses(userId)}';
      final response = await apiClient.get(url);
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((item) => ExpenseModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  @override
  Future<ExpenseSummaryModel> getExpenseSummary(String userId) async {
    try {
      final url = '${Endpoints.expenseBaseUrl}${Endpoints.userExpenseSummary(userId)}';
      final response = await apiClient.get(url);
      if (response.statusCode == 200) {
        return ExpenseSummaryModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('Failed to load expense summary');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  @override
  Future<bool> addExpense(ExpenseModel expense) async {
    try {
      final url = '${Endpoints.expenseBaseUrl}${Endpoints.addExpense}';
      final response = await apiClient.post(url, data: expense.toJson());
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  @override
  Future<bool> updateExpense(ExpenseModel expense) async {
    try {
      final url = '${Endpoints.expenseBaseUrl}${Endpoints.updateExpense}';
      final response = await apiClient.put(url, data: expense.toJson());
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  @override
  Future<bool> deleteExpense(dynamic id) async {
    try {
      final url = '${Endpoints.expenseBaseUrl}${Endpoints.deleteExpense(id)}';
      final response = await apiClient.delete(url);
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }
}

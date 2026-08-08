import '../../domain/entities/expense_entity.dart';
import '../../domain/entities/expense_summary_entity.dart';
import '../../domain/repositories/expense_repository.dart';

import '../datasources/expense_remote_data_source.dart';
import '../models/expense_model.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseRemoteDataSource remoteDataSource;

  ExpenseRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ExpenseEntity>> getExpenses(String userId) async {
    return await remoteDataSource.getExpenses(userId);
  }

  @override
  Future<ExpenseSummaryEntity> getExpenseSummary(String userId) async {
    return await remoteDataSource.getExpenseSummary(userId);
  }

  @override
  Future<bool> addExpense(ExpenseEntity expense) async {
    final model = ExpenseModel(
      id: expense.id,
      userId: expense.userId,
      amount: expense.amount,
      category: expense.category,
      description: expense.description,
      currency: expense.currency,
      createdAt: expense.createdAt,
    );
    return await remoteDataSource.addExpense(model);
  }

  @override
  Future<bool> deleteExpense(dynamic id) async {
    return await remoteDataSource.deleteExpense(id);
  }
}

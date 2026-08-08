import '../entities/expense_entity.dart';
import '../entities/expense_summary_entity.dart';

abstract class ExpenseRepository {
  Future<List<ExpenseEntity>> getExpenses(String userId);
  Future<ExpenseSummaryEntity> getExpenseSummary(String userId);
  Future<bool> addExpense(ExpenseEntity expense);
  Future<bool> deleteExpense(dynamic id);
}

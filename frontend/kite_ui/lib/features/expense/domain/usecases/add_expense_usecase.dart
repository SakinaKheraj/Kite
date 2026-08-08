import '../entities/expense_entity.dart';
import '../repositories/expense_repository.dart';

class AddExpenseUseCase {
  final ExpenseRepository repository;

  AddExpenseUseCase(this.repository);

  Future<bool> execute(ExpenseEntity expense) async {
    return await repository.addExpense(expense);
  }
}

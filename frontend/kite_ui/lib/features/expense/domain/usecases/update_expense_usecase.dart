import '../entities/expense_entity.dart';
import '../repositories/expense_repository.dart';

class UpdateExpenseUseCase {
  final ExpenseRepository repository;

  UpdateExpenseUseCase(this.repository);

  Future<bool> execute(ExpenseEntity expense) async {
    return await repository.updateExpense(expense);
  }
}

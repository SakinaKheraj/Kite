import '../repositories/expense_repository.dart';

class DeleteExpenseUseCase {
  final ExpenseRepository repository;

  DeleteExpenseUseCase(this.repository);

  Future<bool> execute(dynamic id) async {
    return await repository.deleteExpense(id);
  }
}

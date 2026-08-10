import '../repositories/expense_repository.dart';

class UpdateBudgetUseCase {
  final ExpenseRepository repository;

  UpdateBudgetUseCase({required this.repository});

  Future<bool> execute(String userId, double newLimit) async {
    return await repository.updateBudgetLimit(userId, newLimit);
  }
}

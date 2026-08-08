import '../entities/expense_summary_entity.dart';
import '../repositories/expense_repository.dart';

class GetExpenseSummaryUseCase {
  final ExpenseRepository repository;

  GetExpenseSummaryUseCase(this.repository);

  Future<ExpenseSummaryEntity> execute(String userId) async {
    return await repository.getExpenseSummary(userId);
  }
}

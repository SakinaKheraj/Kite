import 'package:equatable/equatable.dart';

class ExpenseSummaryEntity extends Equatable {
  final String userId;
  final double totalSpent;
  final double budgetLimit;
  final bool thresholdReached;
  final String warningMessage;
  final List<String> categories;

  const ExpenseSummaryEntity({
    required this.userId,
    required this.totalSpent,
    required this.budgetLimit,
    required this.thresholdReached,
    required this.warningMessage,
    required this.categories,
  });

  double get spendingPercentage {
    if (budgetLimit <= 0) return 0.0;
    final pct = (totalSpent / budgetLimit);
    return pct > 1.0 ? 1.0 : pct;
  }

  @override
  List<Object?> get props => [
        userId,
        totalSpent,
        budgetLimit,
        thresholdReached,
        warningMessage,
        categories,
      ];
}

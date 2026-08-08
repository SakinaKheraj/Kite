import '../../domain/entities/expense_summary_entity.dart';

class ExpenseSummaryModel extends ExpenseSummaryEntity {
  const ExpenseSummaryModel({
    required super.userId,
    required super.totalSpent,
    required super.budgetLimit,
    required super.thresholdReached,
    required super.warningMessage,
    required super.categories,
  });

  factory ExpenseSummaryModel.fromJson(Map<String, dynamic> json) {
    final rawCategories = json['categories'];
    List<String> parsedCategories = [];
    if (rawCategories is List) {
      parsedCategories = rawCategories.map((e) => e.toString()).toList();
    }

    return ExpenseSummaryModel(
      userId: json['user_id'] ?? json['userId'] ?? '',
      totalSpent: (json['total_spent'] is num)
          ? (json['total_spent'] as num).toDouble()
          : double.tryParse(json['total_spent'].toString()) ?? 0.0,
      budgetLimit: (json['budget_limit'] is num)
          ? (json['budget_limit'] as num).toDouble()
          : double.tryParse(json['budget_limit'].toString()) ?? 10000.0,
      thresholdReached: json['threshold_reached'] ?? false,
      warningMessage: json['warning_message'] ?? '',
      categories: parsedCategories,
    );
  }
}

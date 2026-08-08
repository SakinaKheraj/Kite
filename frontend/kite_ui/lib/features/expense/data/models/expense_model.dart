import '../../domain/entities/expense_entity.dart';

class ExpenseModel extends ExpenseEntity {
  const ExpenseModel({
    super.id,
    required super.userId,
    required super.amount,
    required super.category,
    required super.description,
    super.currency = 'INR',
    super.createdAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'],
      userId: json['user_id'] ?? json['userId'] ?? '',
      amount: (json['amount'] is num) ? (json['amount'] as num).toDouble() : double.tryParse(json['amount'].toString()) ?? 0.0,
      category: json['category'] ?? 'Other',
      description: json['description'] ?? '',
      currency: json['currency'] ?? 'INR',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'amount': amount.toString(),
      'category': category,
      'description': description,
      'currency': currency,
    };
  }
}

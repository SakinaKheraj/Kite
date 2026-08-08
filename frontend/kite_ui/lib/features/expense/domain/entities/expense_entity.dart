import 'package:equatable/equatable.dart';

class ExpenseEntity extends Equatable {
  final dynamic id;
  final String userId;
  final double amount;
  final String category;
  final String description;
  final String currency;
  final DateTime? createdAt;

  const ExpenseEntity({
    this.id,
    required this.userId,
    required this.amount,
    required this.category,
    required this.description,
    this.currency = 'INR',
    this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        amount,
        category,
        description,
        currency,
        createdAt,
      ];
}

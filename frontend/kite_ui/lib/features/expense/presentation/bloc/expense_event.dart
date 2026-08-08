import 'package:equatable/equatable.dart';
import '../../domain/entities/expense_entity.dart';

abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();

  @override
  List<Object?> get props => [];
}

class FetchDashboardDataRequested extends ExpenseEvent {
  final String userId;

  const FetchDashboardDataRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

class AddExpenseSubmitted extends ExpenseEvent {
  final ExpenseEntity expense;

  const AddExpenseSubmitted(this.expense);

  @override
  List<Object?> get props => [expense];
}

class UpdateExpenseSubmitted extends ExpenseEvent {
  final ExpenseEntity expense;

  const UpdateExpenseSubmitted(this.expense);

  @override
  List<Object?> get props => [expense];
}

class DeleteExpenseRequested extends ExpenseEvent {
  final dynamic id;
  final String userId;

  const DeleteExpenseRequested({required this.id, required this.userId});

  @override
  List<Object?> get props => [id, userId];
}

class CategoryFilterChanged extends ExpenseEvent {
  final String selectedCategory;

  const CategoryFilterChanged(this.selectedCategory);

  @override
  List<Object?> get props => [selectedCategory];
}

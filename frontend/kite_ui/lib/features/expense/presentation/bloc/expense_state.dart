import 'package:equatable/equatable.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/entities/expense_summary_entity.dart';

abstract class ExpenseState extends Equatable {
  const ExpenseState();

  @override
  List<Object?> get props => [];
}

class ExpenseInitial extends ExpenseState {
  const ExpenseInitial();
}

class ExpenseLoading extends ExpenseState {
  const ExpenseLoading();
}

class ExpenseLoaded extends ExpenseState {
  final List<ExpenseEntity> expenses;
  final List<ExpenseEntity> filteredExpenses;
  final ExpenseSummaryEntity summary;
  final String selectedCategory;

  const ExpenseLoaded({
    required this.expenses,
    required this.filteredExpenses,
    required this.summary,
    this.selectedCategory = 'All',
  });

  ExpenseLoaded copyWith({
    List<ExpenseEntity>? expenses,
    List<ExpenseEntity>? filteredExpenses,
    ExpenseSummaryEntity? summary,
    String? selectedCategory,
  }) {
    return ExpenseLoaded(
      expenses: expenses ?? this.expenses,
      filteredExpenses: filteredExpenses ?? this.filteredExpenses,
      summary: summary ?? this.summary,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }

  @override
  List<Object?> get props => [
        expenses,
        filteredExpenses,
        summary,
        selectedCategory,
      ];
}

class ExpenseFailure extends ExpenseState {
  final String message;

  const ExpenseFailure(this.message);

  @override
  List<Object?> get props => [message];
}

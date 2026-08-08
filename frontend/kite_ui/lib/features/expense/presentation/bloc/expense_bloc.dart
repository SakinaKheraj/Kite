import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/expense_entity.dart';
import '../../domain/usecases/add_expense_usecase.dart';
import '../../domain/usecases/delete_expense_usecase.dart';
import '../../domain/usecases/get_expense_summary_usecase.dart';
import '../../domain/usecases/get_expenses_usecase.dart';

import 'expense_event.dart';
import 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final GetExpensesUseCase getExpensesUseCase;
  final GetExpenseSummaryUseCase getExpenseSummaryUseCase;
  final AddExpenseUseCase addExpenseUseCase;
  final DeleteExpenseUseCase deleteExpenseUseCase;

  ExpenseBloc({
    required this.getExpensesUseCase,
    required this.getExpenseSummaryUseCase,
    required this.addExpenseUseCase,
    required this.deleteExpenseUseCase,
  }) : super(const ExpenseInitial()) {
    on<FetchDashboardDataRequested>(_onFetchDashboardDataRequested);
    on<CategoryFilterChanged>(_onCategoryFilterChanged);
    on<AddExpenseSubmitted>(_onAddExpenseSubmitted);
    on<DeleteExpenseRequested>(_onDeleteExpenseRequested);
  }

  Future<void> _onFetchDashboardDataRequested(
    FetchDashboardDataRequested event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(const ExpenseLoading());
    try {
      final results = await Future.wait([
        getExpensesUseCase.execute(event.userId),
        getExpenseSummaryUseCase.execute(event.userId),
      ]);

      final expenses = results[0] as List<ExpenseEntity>;
      final summary = results[1] as dynamic;

      emit(ExpenseLoaded(
        expenses: expenses,
        filteredExpenses: expenses,
        summary: summary,
        selectedCategory: 'All',
      ));
    } catch (e) {
      emit(ExpenseFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void _onCategoryFilterChanged(
    CategoryFilterChanged event,
    Emitter<ExpenseState> emit,
  ) {
    if (state is ExpenseLoaded) {
      final currentState = state as ExpenseLoaded;
      final category = event.selectedCategory;

      List<ExpenseEntity> filtered;
      if (category == 'All') {
        filtered = currentState.expenses;
      } else {
        filtered = currentState.expenses
            .where((item) => item.category.toLowerCase() == category.toLowerCase())
            .toList();
      }

      emit(currentState.copyWith(
        selectedCategory: category,
        filteredExpenses: filtered,
      ));
    }
  }

  Future<void> _onAddExpenseSubmitted(
    AddExpenseSubmitted event,
    Emitter<ExpenseState> emit,
  ) async {
    final userId = event.expense.userId;
    try {
      final isSuccess = await addExpenseUseCase.execute(event.expense);
      if (isSuccess) {
        add(FetchDashboardDataRequested(userId));
      } else {
        emit(const ExpenseFailure('Failed to add expense'));
      }
    } catch (e) {
      emit(ExpenseFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onDeleteExpenseRequested(
    DeleteExpenseRequested event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      final isSuccess = await deleteExpenseUseCase.execute(event.id);
      if (isSuccess) {
        add(FetchDashboardDataRequested(event.userId));
      } else {
        emit(const ExpenseFailure('Failed to delete expense'));
      }
    } catch (e) {
      emit(ExpenseFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}

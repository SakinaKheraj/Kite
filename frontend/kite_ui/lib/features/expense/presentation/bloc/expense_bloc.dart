import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/expense_entity.dart';
import '../../domain/usecases/add_expense_usecase.dart';
import '../../domain/usecases/delete_expense_usecase.dart';
import '../../domain/usecases/get_expense_summary_usecase.dart';
import '../../domain/usecases/get_expenses_usecase.dart';
import '../../domain/usecases/update_budget_usecase.dart';
import '../../domain/usecases/update_expense_usecase.dart';

import 'expense_event.dart';
import 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final GetExpensesUseCase getExpensesUseCase;
  final GetExpenseSummaryUseCase getExpenseSummaryUseCase;
  final AddExpenseUseCase addExpenseUseCase;
  final UpdateExpenseUseCase updateExpenseUseCase;
  final DeleteExpenseUseCase deleteExpenseUseCase;
  final UpdateBudgetUseCase updateBudgetUseCase;

  ExpenseBloc({
    required this.getExpensesUseCase,
    required this.getExpenseSummaryUseCase,
    required this.addExpenseUseCase,
    required this.updateExpenseUseCase,
    required this.deleteExpenseUseCase,
    required this.updateBudgetUseCase,
  }) : super(const ExpenseInitial()) {
    on<FetchDashboardDataRequested>(_onFetchDashboardDataRequested);
    on<CategoryFilterChanged>(_onCategoryFilterChanged);
    on<DateFilterChanged>(_onDateFilterChanged);
    on<AddExpenseSubmitted>(_onAddExpenseSubmitted);
    on<UpdateExpenseSubmitted>(_onUpdateExpenseSubmitted);
    on<DeleteExpenseRequested>(_onDeleteExpenseRequested);
    on<UpdateBudgetSubmitted>(_onUpdateBudgetSubmitted);
  }

  List<ExpenseEntity> _applyFilters(
    List<ExpenseEntity> expenses,
    String categoryFilter,
    String dateFilter,
  ) {
    return expenses.where((item) {
      // 1. Category Filter
      final categoryMatch = categoryFilter == 'All' ||
          item.category.toLowerCase() == categoryFilter.toLowerCase();
      if (!categoryMatch) return false;

      // 2. Date Filter
      if (dateFilter == 'All') return true;

      final now = DateTime.now();
      final itemDate = item.createdAt ?? now;

      if (dateFilter == 'Today') {
        return itemDate.year == now.year &&
            itemDate.month == now.month &&
            itemDate.day == now.day;
      } else if (dateFilter == 'This Week') {
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final resetStartOfWeek = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
        return itemDate.isAfter(resetStartOfWeek.subtract(const Duration(seconds: 1)));
      } else if (dateFilter == 'This Month') {
        return itemDate.year == now.year && itemDate.month == now.month;
      }

      return true;
    }).toList();
  }

  Future<void> _onFetchDashboardDataRequested(
    FetchDashboardDataRequested event,
    Emitter<ExpenseState> emit,
  ) async {
    final currentCategory = state is ExpenseLoaded
        ? (state as ExpenseLoaded).selectedCategory
        : 'All';
    final currentDateFilter = state is ExpenseLoaded
        ? (state as ExpenseLoaded).selectedDateFilter
        : 'All';

    // Only emit ExpenseLoading on initial app launch to prevent full-page flickering
    if (state is ExpenseInitial) {
      emit(const ExpenseLoading());
    }

    try {
      final expenses = await getExpensesUseCase.execute(event.userId);
      final summary = await getExpenseSummaryUseCase.execute(event.userId);

      final filtered = _applyFilters(expenses, currentCategory, currentDateFilter);

      emit(ExpenseLoaded(
        expenses: expenses,
        filteredExpenses: filtered,
        summary: summary,
        selectedCategory: currentCategory,
        selectedDateFilter: currentDateFilter,
      ));
    } catch (e) {
      if (state is! ExpenseLoaded) {
        emit(ExpenseFailure(e.toString().replaceAll('Exception: ', '')));
      }
    }
  }

  void _onCategoryFilterChanged(
    CategoryFilterChanged event,
    Emitter<ExpenseState> emit,
  ) {
    if (state is ExpenseLoaded) {
      final currentState = state as ExpenseLoaded;
      final category = event.selectedCategory;

      final filtered = _applyFilters(
        currentState.expenses,
        category,
        currentState.selectedDateFilter,
      );

      emit(currentState.copyWith(
        selectedCategory: category,
        filteredExpenses: filtered,
      ));
    }
  }

  void _onDateFilterChanged(
    DateFilterChanged event,
    Emitter<ExpenseState> emit,
  ) {
    if (state is ExpenseLoaded) {
      final currentState = state as ExpenseLoaded;
      final dateFilter = event.selectedDateFilter;

      final filtered = _applyFilters(
        currentState.expenses,
        currentState.selectedCategory,
        dateFilter,
      );

      emit(currentState.copyWith(
        selectedDateFilter: dateFilter,
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

  Future<void> _onUpdateExpenseSubmitted(
    UpdateExpenseSubmitted event,
    Emitter<ExpenseState> emit,
  ) async {
    final userId = event.expense.userId;
    try {
      final isSuccess = await updateExpenseUseCase.execute(event.expense);
      if (isSuccess) {
        add(FetchDashboardDataRequested(userId));
      } else {
        emit(const ExpenseFailure('Failed to update expense'));
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

  Future<void> _onUpdateBudgetSubmitted(
    UpdateBudgetSubmitted event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      final isSuccess = await updateBudgetUseCase.execute(event.userId, event.newLimit);
      if (isSuccess) {
        add(FetchDashboardDataRequested(event.userId));
      } else {
        emit(const ExpenseFailure('Failed to update budget limit'));
      }
    } catch (e) {
      emit(ExpenseFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}

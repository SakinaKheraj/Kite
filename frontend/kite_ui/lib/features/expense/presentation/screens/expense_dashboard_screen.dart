import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

import '../../domain/entities/expense_entity.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_event.dart';
import '../bloc/expense_state.dart';

import '../widgets/add_expense_bottom_sheet.dart';
import '../widgets/budget_progress_bar.dart';
import '../widgets/category_chip_selector.dart';
import '../widgets/expense_tile.dart';

class ExpenseDashboardScreen extends StatefulWidget {
  final String userId;

  const ExpenseDashboardScreen({super.key, required this.userId});

  @override
  State<ExpenseDashboardScreen> createState() => _ExpenseDashboardScreenState();
}

class _ExpenseDashboardScreenState extends State<ExpenseDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ExpenseBloc>().add(FetchDashboardDataRequested(widget.userId));
  }

  void _showExpenseModal(BuildContext context, List<String> categories, {ExpenseEntity? initialExpense}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => AddExpenseBottomSheet(
        userId: widget.userId,
        availableCategories: categories,
        initialExpense: initialExpense,
        onSubmit: (expense) {
          if (initialExpense != null) {
            context.read<ExpenseBloc>().add(UpdateExpenseSubmitted(expense));
          } else {
            context.read<ExpenseBloc>().add(AddExpenseSubmitted(expense));
          }
        },
      ),
    );
  }

  Map<String, List<ExpenseEntity>> _groupExpensesByDateSection(List<ExpenseEntity> items) {
    final Map<String, List<ExpenseEntity>> sections = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (var item in items) {
      final date = item.createdAt ?? DateTime.now();
      final itemDate = DateTime(date.year, date.month, date.day);

      String sectionTitle;
      if (itemDate == today) {
        sectionTitle = 'Today';
      } else if (itemDate == yesterday) {
        sectionTitle = 'Yesterday';
      } else if (date.year == now.year && date.month == now.month) {
        sectionTitle = 'This Month';
      } else {
        sectionTitle = '${_monthName(date.month)} ${date.year}';
      }

      sections.putIfAbsent(sectionTitle, () => []).add(item);
    }
    return sections;
  }

  String _monthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[(month - 1) % 12];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kite Expenses',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
            ),
            Text(
              '@${widget.userId}',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            onPressed: () {
              context.read<AuthBloc>().add(const LogoutRequested());
            },
          ),
        ],
      ),
      body: BlocConsumer<ExpenseBloc, ExpenseState>(
        listener: (context, state) {
          if (state is ExpenseFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ExpenseLoading || state is ExpenseInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is ExpenseLoaded) {
            final groupedExpenses = _groupExpensesByDateSection(state.filteredExpenses);

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                context.read<ExpenseBloc>().add(FetchDashboardDataRequested(widget.userId));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Budget Progress Bar Card
                    BudgetProgressBar(summary: state.summary),
                    const SizedBox(height: 24),

                    // Category Filter Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Expenses',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${state.filteredExpenses.length} items',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    CategoryChipSelector(
                      categories: state.summary.categories,
                      selectedCategory: state.selectedCategory,
                      onCategorySelected: (cat) {
                        context.read<ExpenseBloc>().add(CategoryFilterChanged(cat));
                      },
                    ),
                    const SizedBox(height: 18),

                    // Expense List View Grouped by Date Sections
                    if (state.filteredExpenses.isEmpty) ...[
                      const SizedBox(height: 40),
                      Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 56,
                              color: AppColors.textMuted.withAlpha(100),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No expenses found',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap + Add Expense below to record your first transaction',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 60),
                    ] else ...[
                      ...groupedExpenses.entries.map((entry) {
                        final sectionTitle = entry.key;
                        final items = entry.value;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 8),
                              child: Text(
                                sectionTitle,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.secondary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                final expense = items[index];
                                return ExpenseTile(
                                  expense: expense,
                                  onEdit: () => _showExpenseModal(
                                    context,
                                    state.summary.categories,
                                    initialExpense: expense,
                                  ),
                                  onDelete: () {
                                    context.read<ExpenseBloc>().add(
                                          DeleteExpenseRequested(
                                            id: expense.id,
                                            userId: widget.userId,
                                          ),
                                        );
                                  },
                                );
                              },
                            ),
                          ],
                        );
                      }),
                    ],
                  ],
                ),
              ),
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
                const SizedBox(height: 12),
                const Text(
                  'Failed to load dashboard',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<ExpenseBloc>().add(FetchDashboardDataRequested(widget.userId));
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          final categories = state is ExpenseLoaded ? state.summary.categories : <String>[];
          return FloatingActionButton.extended(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 6,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Expense', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () => _showExpenseModal(context, categories),
          );
        },
      ),
    );
  }
}

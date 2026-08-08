import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/widgets/custom_text_field.dart';
import '../../../auth/presentation/widgets/primary_button.dart';
import '../../domain/entities/expense_entity.dart';

class AddExpenseBottomSheet extends StatefulWidget {
  final String userId;
  final List<String> availableCategories;
  final Function(ExpenseEntity) onSubmit;

  const AddExpenseBottomSheet({
    super.key,
    required this.userId,
    required this.availableCategories,
    required this.onSubmit,
  });

  @override
  State<AddExpenseBottomSheet> createState() => _AddExpenseBottomSheetState();
}

class _AddExpenseBottomSheetState extends State<AddExpenseBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    final categories = widget.availableCategories.isNotEmpty
        ? widget.availableCategories
        : ['Food', 'Travel', 'Utilities', 'Entertainment'];
    _selectedCategory = categories.firstWhere(
      (c) => c.toLowerCase() != 'all',
      orElse: () => 'Food',
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text.trim());
      final expense = ExpenseEntity(
        userId: widget.userId,
        amount: amount,
        category: _selectedCategory,
        description: _descriptionController.text.trim(),
        currency: 'INR',
      );
      widget.onSubmit(expense);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = (widget.availableCategories.isNotEmpty
            ? widget.availableCategories
            : ['Food', 'Travel', 'Utilities', 'Entertainment'])
        .where((c) => c.toLowerCase() != 'all')
        .toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Record Expense',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Category Selector Chips
              Text(
                'Category',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((cat) {
                  final isSelected = cat.toLowerCase() == _selectedCategory.toLowerCase();
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surfaceLight,
                    showCheckmark: false,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Amount Input
              CustomTextField(
                controller: _amountController,
                label: 'Amount (₹)',
                hintText: 'e.g. 1500.00',
                prefixIcon: Icons.currency_rupee_rounded,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Amount is required';
                  if (double.tryParse(val.trim()) == null || double.parse(val.trim()) <= 0) {
                    return 'Enter a valid positive amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description Input
              CustomTextField(
                controller: _descriptionController,
                label: 'Description',
                hintText: 'e.g. Weekly grocery shopping',
                prefixIcon: Icons.notes_rounded,
              ),
              const SizedBox(height: 28),

              PrimaryButton(
                text: 'Add Expense',
                onPressed: _handleSubmit,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

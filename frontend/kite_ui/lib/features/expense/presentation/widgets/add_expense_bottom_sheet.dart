import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/widgets/custom_text_field.dart';
import '../../../auth/presentation/widgets/primary_button.dart';
import '../../data/models/ai_parsed_expense_model.dart';
import '../../domain/entities/expense_entity.dart';
import 'ai_sms_input_modal.dart';

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
  bool _isAutoFilled = false;
  double _aiConfidence = 0.95;

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

  void _openAiSmsModal() async {
    final result = await showDialog<AiParsedExpenseModel>(
      context: context,
      builder: (_) => const AiSmsInputModal(),
    );

    if (result != null && mounted) {
      setState(() {
        if (result.amount > 0) {
          _amountController.text = result.amount.toStringAsFixed(2);
        }
        if (result.description.isNotEmpty) {
          _descriptionController.text = result.description;
        }

        // Category mapping & fallback
        final categories = (widget.availableCategories.isNotEmpty
                ? widget.availableCategories
                : ['Food', 'Travel', 'Utilities', 'Entertainment'])
            .where((c) => c.toLowerCase() != 'all')
            .toList();

        final match = categories.firstWhere(
          (c) => c.toLowerCase() == result.category.toLowerCase(),
          orElse: () => categories.first,
        );
        _selectedCategory = match;
        _isAutoFilled = true;
        _aiConfidence = result.confidence;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✨ Auto-filled from SMS with ${(_aiConfidence * 100).toStringAsFixed(0)}% confidence!',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.secondary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
              const SizedBox(height: 12),

              // AI Auto-Fill Action Banner
              InkWell(
                onTap: _openAiSmsModal,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withAlpha(80),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Auto-Fill with AI / Paste SMS',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(50),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'FAST ⚡',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (_isAutoFilled) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded, color: AppColors.secondary, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Fields pre-filled via Mistral AI (${(_aiConfidence * 100).toStringAsFixed(0)}% match)',
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),

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

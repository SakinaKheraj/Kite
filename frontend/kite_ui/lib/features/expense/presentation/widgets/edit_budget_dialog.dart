import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class EditBudgetDialog extends StatefulWidget {
  final double currentBudget;
  final Function(double) onSave;

  const EditBudgetDialog({
    super.key,
    required this.currentBudget,
    required this.onSave,
  });

  @override
  State<EditBudgetDialog> createState() => _EditBudgetDialogState();
}

class _EditBudgetDialogState extends State<EditBudgetDialog> {
  late TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  final List<double> _presets = [5000, 10000, 25000, 50000];

  @override
  void initState() {
    super.initState() ;
    _controller = TextEditingController(
      text: widget.currentBudget.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final value = double.tryParse(_controller.text.trim());
      if (value != null && value > 0) {
        widget.onSave(value);
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.glassBorder, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
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
                    'Edit Monthly Budget',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _controller,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  labelText: 'Monthly Limit (₹)',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  prefixIcon: const Icon(Icons.account_balance_wallet, color: AppColors.accentBlue),
                  filled: true,
                  fillColor: AppColors.backgroundDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.glassBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.accentBlue, width: 2),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Enter a budget limit';
                  final parsed = double.tryParse(val.trim());
                  if (parsed == null || parsed <= 0) return 'Enter a valid amount';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Quick Select:',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _presets.map((preset) {
                  final isSelected = double.tryParse(_controller.text) == preset;
                  return ChoiceChip(
                    label: Text('₹${preset.toStringAsFixed(0)}'),
                    selected: isSelected,
                    selectedColor: AppColors.accentBlue,
                    backgroundColor: AppColors.backgroundDark,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _controller.text = preset.toStringAsFixed(0);
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Save Budget', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

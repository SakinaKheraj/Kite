import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class DateFilterDropdown extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterSelected;

  const DateFilterDropdown({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  static const List<String> filterOptions = [
    'All Time',
    'Today',
    'This Week',
    'This Month',
  ];

  @override
  Widget build(BuildContext context) {
    // Map internal 'All' state to 'All Time' display text
    final displayValue = selectedFilter == 'All' ? 'All Time' : selectedFilter;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: displayValue,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.accentBlue,
            size: 20,
          ),
          dropdownColor: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          onChanged: (String? newValue) {
            if (newValue != null) {
              final internalValue = newValue == 'All Time' ? 'All' : newValue;
              onFilterSelected(internalValue);
            }
          },
          items: filterOptions.map<DropdownMenuItem<String>>((String value) {
            final isSelected = displayValue == value;
            return DropdownMenuItem<String>(
              value: value,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    value == 'Today'
                        ? Icons.today_rounded
                        : value == 'This Week'
                            ? Icons.date_range_rounded
                            : value == 'This Month'
                                ? Icons.calendar_month_rounded
                                : Icons.all_inclusive_rounded,
                    size: 15,
                    color: isSelected ? AppColors.accentBlue : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    value,
                    style: TextStyle(
                      color: isSelected ? AppColors.accentBlue : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

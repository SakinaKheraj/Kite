import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class DateFilterSelector extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterSelected;

  const DateFilterSelector({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  static const List<String> filters = ['All', 'Today', 'This Week', 'This Month'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (ctx, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter;

          return GestureDetector(
            onTap: () => onFilterSelected(filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accentBlue : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.accentBlue : AppColors.glassBorder,
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.accentBlue.withAlpha(76),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

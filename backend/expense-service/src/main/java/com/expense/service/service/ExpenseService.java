package com.expense.service.service;

import java.util.Arrays;
import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.stream.Collectors;

import org.apache.logging.log4j.util.Strings;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.expense.service.dto.ExpenseDto;
import com.expense.service.dto.ExpenseSummaryDto;
import com.expense.service.entities.Category;
import com.expense.service.entities.Expense;
import com.expense.service.entities.UserBudget;
import com.expense.service.repository.CategoryRepository;
import com.expense.service.repository.ExpenseRepository;
import com.expense.service.repository.UserBudgetRepository;

import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
public class ExpenseService {

    private final ExpenseRepository expenseRepository;
    private final CategoryRepository categoryRepository;
    private final UserBudgetRepository userBudgetRepository;

    @Autowired
    public ExpenseService(
        ExpenseRepository expenseRepository,
        CategoryRepository categoryRepository,
        UserBudgetRepository userBudgetRepository
    ) {
        this.expenseRepository = expenseRepository;
        this.categoryRepository = categoryRepository;
        this.userBudgetRepository = userBudgetRepository;
    }

    public boolean createExpense(ExpenseDto expenseDto) {
        setCurrency(expenseDto);
        try {
            Expense expense = new Expense();
            expense.setUserId(expenseDto.getUserId());
            expense.setAmount(expenseDto.getAmount());
            expense.setCategory(expenseDto.getCategory());
            expense.setDescription(expenseDto.getDescription());
            expense.setMerchant(expenseDto.getMerchant());
            expense.setCurrency(expenseDto.getCurrency());
            if (expenseDto.getCreatedAt() != null) {
                expense.setCreatedAt(expenseDto.getCreatedAt());
            }

            expenseRepository.save(expense);
            return true;
        } catch (Exception e) {
            log.error("Failed to save expense: {}", e.getMessage(), e);
            return false;
        }
    }

    public boolean updateExpense(ExpenseDto expenseDto) {
        Optional<Expense> expenseFoundOpt = Optional.empty();
        if (expenseDto.getExternalId() != null) {
            expenseFoundOpt = expenseRepository.findByUserIdAndExternalId(
                expenseDto.getUserId(),
                expenseDto.getExternalId()
            );
        }
        if (expenseFoundOpt.isEmpty() && expenseDto.getId() != null) {
            expenseFoundOpt = expenseRepository.findById(expenseDto.getId());
        }

        if (expenseFoundOpt.isEmpty()) return false;

        Expense expense = expenseFoundOpt.get();
        expense.setCurrency(Strings.isNotBlank(expenseDto.getCurrency()) ? expenseDto.getCurrency() : expense.getCurrency());
        expense.setMerchant(Strings.isNotBlank(expenseDto.getMerchant()) ? expenseDto.getMerchant() : expense.getMerchant());
        expense.setAmount(expenseDto.getAmount());
        if (Strings.isNotBlank(expenseDto.getCategory())) {
            expense.setCategory(expenseDto.getCategory());
        }
        if (Strings.isNotBlank(expenseDto.getDescription())) {
            expense.setDescription(expenseDto.getDescription());
        }
        expenseRepository.save(expense);
        return true;
    }

    public List<ExpenseDto> getExpenses(String userId) {
        List<Expense> expenseList = expenseRepository.findByUserId(userId);
        return expenseList.stream().map(this::mapToDto).collect(Collectors.toList());
    }

    public ExpenseSummaryDto getExpenseSummary(String userId) {
        List<Expense> expenseList = expenseRepository.findByUserId(userId);
        
        double totalSpent = 0.0;
        for (Expense exp : expenseList) {
            if (exp.getAmount() != null) {
                try {
                    totalSpent += Double.parseDouble(exp.getAmount());
                } catch (NumberFormatException e) {
                    log.warn("Invalid expense amount format for expense ID {}: {}", exp.getId(), exp.getAmount());
                }
            }
        }

        UserBudget budget = userBudgetRepository.findByUserId(userId)
            .orElseGet(() -> UserBudget.builder().userId(userId).budgetLimit(10000.00).build());

        double budgetLimit = budget.getBudgetLimit() != null ? budget.getBudgetLimit() : 10000.00;
        boolean thresholdReached = totalSpent >= (0.8 * budgetLimit);

        double percentage = budgetLimit > 0 ? (totalSpent / budgetLimit) * 100 : 0;
        String warningMessage = thresholdReached
            ? String.format("WARNING: You have spent %.1f%% of your budget limit (Spent: %.2f / Limit: %.2f)!", percentage, totalSpent, budgetLimit)
            : String.format("Spending is within healthy limits (Spent: %.2f / Limit: %.2f).", totalSpent, budgetLimit);

        List<Category> categoryEntities = categoryRepository.findByUserId(userId);
        List<String> categoryNames = categoryEntities.stream().map(Category::getName).collect(Collectors.toList());
        if (categoryNames.isEmpty()) {
            categoryNames = Arrays.asList("Food", "Travel", "Utilities", "Entertainment", "SMS");
        } else if (!categoryNames.contains("SMS")) {
            categoryNames.add("SMS");
        }

        return ExpenseSummaryDto.builder()
            .userId(userId)
            .totalSpent(totalSpent)
            .budgetLimit(budgetLimit)
            .thresholdReached(thresholdReached)
            .warningMessage(warningMessage)
            .categories(categoryNames)
            .build();
    }

    public boolean deleteExpense(Long id) {
        if (expenseRepository.existsById(id)) {
            expenseRepository.deleteById(id);
            return true;
        }
        return false;
    }

    public void initializeUserDefaultCategoriesAndBudget(String userId) {
        List<String> defaultCategories = Arrays.asList("Food", "Travel", "Utilities", "Entertainment", "SMS");
        for (String catName : defaultCategories) {
            if (!categoryRepository.existsByUserIdAndName(userId, catName)) {
                categoryRepository.save(Category.builder().userId(userId).name(catName).build());
            }
        }

        if (userBudgetRepository.findByUserId(userId).isEmpty()) {
            userBudgetRepository.save(UserBudget.builder().userId(userId).budgetLimit(10000.00).build());
        }
        log.info("Successfully initialized default categories and budget for user {}", userId);
    }

    private ExpenseDto mapToDto(Expense expense) {
        return ExpenseDto.builder()
            .id(expense.getId())
            .externalId(expense.getExternalId())
            .userId(expense.getUserId())
            .amount(expense.getAmount())
            .category(expense.getCategory())
            .description(expense.getDescription())
            .merchant(expense.getMerchant())
            .currency(expense.getCurrency())
            .createdAt(expense.getCreatedAt())
            .build();
    }

    private void setCurrency(ExpenseDto expenseDto) {
        if (Objects.isNull(expenseDto.getCurrency())) {
            expenseDto.setCurrency("INR");
        }
    }
}

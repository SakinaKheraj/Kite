package com.expense.service.repository;

import org.antlr.v4.runtime.atn.SemanticContext.AND;
import org.springframework.data.repository.CrudRepository;

import com.expense.service.entities.Expense;

import java.sql.Timestamp;
import java.util.List;
import java.util.Optional;


public interface ExpenseRepository extends CrudRepository<Expense, Long>{

    // List<Expense> findByUserId(String userId);
    List<Expense> findByUserId(String userId);

    // SELECT * FROM expenses WHERE user_id = ? AND created_at BETWEEN ? AND ?;
    List<Expense> findByUserIdAndCreatedAtBetween(String userId, Timestamp stsrtTime, Timestamp endTime);

    // SELECT * FROM expenses WHERE user_id = ? AND external_id = ?;
    Optional<Expense> findByUserIdAndExternalId(String userId, String externalId);
}

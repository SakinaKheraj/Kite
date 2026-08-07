package com.expense.service.controller;

import java.util.List;

import javax.swing.text.html.parser.Entity;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RestController;

import com.expense.service.dto.ExpenseDto;
import com.expense.service.service.ExpenseService;

import lombok.NonNull;
import jakarta.websocket.server.PathParam;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;


@RestController
@RequestMapping("/expense/v1")
public class ExpenseController {

    private final ExpenseService expenseService; 

    @Autowired
    ExpenseController(ExpenseService expenseService) {
        this.expenseService = expenseService;
    }

    // Endpoint URL maps to: GET /expense/v1/getExpense?user_id=xyz
    @GetMapping(path = "/getExpense")
    public ResponseEntity<List<ExpenseDto>> getExpenses(@RequestParam(value = "user_id") String userId) {
        try {
            List<ExpenseDto> expenseDtoList = expenseService.getExpenses(userId);
            return new ResponseEntity<>(expenseDtoList, HttpStatus.OK);
        } catch(Exception e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping(path = "/addExpense")
    public ResponseEntity<Boolean> addExpenses(
        @RequestHeader(value = "X-User-Id") String userId,
        @RequestBody ExpenseDto expenseDto
    ) {
        try {
            expenseDto.setUserId(userId);
            boolean isCreated = expenseService.createExpense(expenseDto);
            return new ResponseEntity<>(isCreated, HttpStatus.OK);
        } catch(Exception e) {
            return new ResponseEntity<>(false, HttpStatus.BAD_REQUEST);
        }
    }
    
}

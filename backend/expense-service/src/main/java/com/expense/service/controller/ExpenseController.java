package com.expense.service.controller;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.expense.service.dto.ExpenseDto;
import com.expense.service.dto.ExpenseSummaryDto;
import com.expense.service.service.ExpenseService;

@RestController
@RequestMapping
@CrossOrigin(
    origins = "*",
    allowedHeaders = "*",
    methods = {RequestMethod.GET, RequestMethod.POST, RequestMethod.PUT, RequestMethod.DELETE, RequestMethod.OPTIONS}
)
public class ExpenseController {

    private final ExpenseService expenseService;

    @Autowired
    public ExpenseController(ExpenseService expenseService) {
        this.expenseService = expenseService;
    }

    // --- Task 3 Core REST API Endpoints ---

    // POST /v1/expenses — Create a new expense entry
    @PostMapping("/v1/expenses")
    public ResponseEntity<Boolean> createExpense(@RequestBody ExpenseDto expenseDto) {
        try {
            boolean isCreated = expenseService.createExpense(expenseDto);
            if (isCreated) {
                return new ResponseEntity<>(true, HttpStatus.CREATED);
            }
            return new ResponseEntity<>(false, HttpStatus.BAD_REQUEST);
        } catch (Exception e) {
            return new ResponseEntity<>(false, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    // GET /v1/expenses/user/{userId} — Fetch all expenses for a specific user
    @GetMapping("/v1/expenses/user/{userId}")
    public ResponseEntity<List<ExpenseDto>> getExpensesByUserId(@PathVariable("userId") String userId) {
        try {
            List<ExpenseDto> expenseList = expenseService.getExpenses(userId);
            return new ResponseEntity<>(expenseList, HttpStatus.OK);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    // GET /v1/expenses/summary/{userId} — Return total spent vs budget limit and threshold warnings (>80%)
    @GetMapping("/v1/expenses/summary/{userId}")
    public ResponseEntity<ExpenseSummaryDto> getExpenseSummary(@PathVariable("userId") String userId) {
        try {
            ExpenseSummaryDto summary = expenseService.getExpenseSummary(userId);
            return new ResponseEntity<>(summary, HttpStatus.OK);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    // DELETE /v1/expenses/{id} — Delete an expense record
    @DeleteMapping("/v1/expenses/{id}")
    public ResponseEntity<Boolean> deleteExpense(@PathVariable("id") Long id) {
        try {
            boolean isDeleted = expenseService.deleteExpense(id);
            if (isDeleted) {
                return new ResponseEntity<>(true, HttpStatus.OK);
            }
            return new ResponseEntity<>(false, HttpStatus.NOT_FOUND);
        } catch (Exception e) {
            return new ResponseEntity<>(false, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    // --- Legacy / Backward Compatibility Endpoints ---

    @GetMapping(path = "/expense/v1/getExpense")
    public ResponseEntity<List<ExpenseDto>> getExpensesLegacy(@RequestParam(value = "user_id") String userId) {
        try {
            List<ExpenseDto> expenseDtoList = expenseService.getExpenses(userId);
            return new ResponseEntity<>(expenseDtoList, HttpStatus.OK);
        } catch (Exception e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping(path = "/expense/v1/addExpense")
    public ResponseEntity<Boolean> addExpensesLegacy(
        @RequestHeader(value = "X-User-Id", required = false) String headerUserId,
        @RequestBody ExpenseDto expenseDto
    ) {
        try {
            if (headerUserId != null && !headerUserId.isBlank()) {
                expenseDto.setUserId(headerUserId);
            }
            boolean isCreated = expenseService.createExpense(expenseDto);
            return new ResponseEntity<>(isCreated, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(false, HttpStatus.BAD_REQUEST);
        }
    }
}

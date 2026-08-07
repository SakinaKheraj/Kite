package com.expense.service.consumer;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

import com.expense.service.dto.ExpenseDto;
import com.expense.service.service.ExpenseService;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ExpenseConsumer {

    private ExpenseService expenseService;

    @Autowired
    ExpenseConsumer(ExpenseService expenseService) {
        this.expenseService = expenseService;
    }

    @KafkaListener(topics = "${spring.kafka.topic-json.name}", groupId ="${spring.kafka.consumer.group-id}")
    public void listen(ExpenseDto expenseDto) {
        try {
            System.out.println("--> Received message from Kafka: " + expenseDto);
            
            // Call your service layer to map DTO and save to MySQL
            expenseService.createExpense(expenseDto); 
            
            System.out.println("--> Successfully persisted expense to database!");
        } catch(Exception ex) {
            System.out.println("Exception in listening the event");
        }
    }

}

package com.expense.service.consumer;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

import com.expense.service.dto.UserInfoEventDto;
import com.expense.service.service.ExpenseService;
import com.fasterxml.jackson.databind.ObjectMapper;

import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
public class UserCreatedConsumer {

    private final ExpenseService expenseService;
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Autowired
    public UserCreatedConsumer(ExpenseService expenseService) {
        this.expenseService = expenseService;
    }

    @KafkaListener(
        topics = "${spring.kafka.user-created-topic.name:user-created-topic}",
        groupId = "${spring.kafka.user-created-group.id:expense-service-group}"
    )
    public void listen(String messagePayload) {
        try {
            log.info("--> Received user registration event in expense-service: {}", messagePayload);
            UserInfoEventDto event = objectMapper.readValue(messagePayload, UserInfoEventDto.class);

            if (event != null && event.getUserId() != null) {
                expenseService.initializeUserDefaultCategoriesAndBudget(event.getUserId());
                log.info("--> Initialized default categories & budget limit for userId: {}", event.getUserId());
            }
        } catch (Exception ex) {
            log.error("Error handling user-created-topic event in expense-service: {}", ex.getMessage(), ex);
        }
    }
}

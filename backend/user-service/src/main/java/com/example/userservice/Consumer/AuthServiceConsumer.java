package com.example.userservice.Consumer;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

import com.example.userservice.entities.UserInfoDto;
import com.example.userservice.service.UserService;

import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
public class AuthServiceConsumer {

    @Autowired
    private UserService userService;

    @KafkaListener(topics = "${spring.kafka.topic.name:user-created-topic}", groupId = "${spring.kafka.consumer.group-id:user-service-group}")
    public void listen(UserInfoDto eventData) {
        try {
            log.info("--> Received UserInfoEvent from Kafka in user-service: {}", eventData);
            if (eventData != null && eventData.getUserId() != null) {
                userService.createOrUpdateUser(eventData);
                log.info("--> Successfully persisted user metadata to DB for userId: {}", eventData.getUserId());
            }
        } catch(Exception e) {
            log.error("Error processing UserInfoEvent in user-service: {}", e.getMessage(), e);
        }
    }    
}

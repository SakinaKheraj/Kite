package com.example.userservice.Consumer;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.annotation.KafkaListener;

import com.example.userservice.entities.UserInfo;
import com.example.userservice.entities.UserInfoDto;
import com.example.userservice.repository.UserRepository;
import com.example.userservice.service.UserService;

public class AuthServiceConsumer {

    @Autowired
    private UserService userService;


    @KafkaListener(topics = "${spring.kafka.topic.name=userservice}", groupId = "${spring.kafka.consumer.group-id}")
    public void listen(UserInfoDto evenData) {
        try {
            userService.createOrUpdateUser(evenData);
        } catch(Exception e) {
            e.printStackTrace();
        }
    }    
}

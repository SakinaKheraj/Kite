package com.example.userservice.controller;

import org.springframework.web.bind.annotation.RestController;

import com.example.userservice.entities.UserInfoDto;
import com.example.userservice.service.UserService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;



@RestController
public class UserController {

    @Autowired
    private UserService userService;

    @PostMapping("/auth/v1/createUpdate")
    public ResponseEntity<UserInfoDto> createUpdate(@RequestBody UserInfoDto userInfoDto) {
        try {
            UserInfoDto user = userService.createOrUpdateUser(userInfoDto);
            return new ResponseEntity<>(user,HttpStatus.OK);
        } catch(Exception e) {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
    }

@GetMapping("/auth/v1/getUser")
public ResponseEntity<UserInfoDto> getUser(
        @RequestParam("user_id") String userId) {

    try {
        UserInfoDto dto = new UserInfoDto();
        dto.setUserId(userId);

        UserInfoDto user = userService.getUser(dto);
        return ResponseEntity.ok(user);

    } catch (Exception e) {
        e.printStackTrace();
        return ResponseEntity.notFound().build();
    }
}  
    
}

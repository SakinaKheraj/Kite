package com.example.userservice.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.userservice.entities.UserInfoDto;
import com.example.userservice.service.UserService;

@RestController
public class UserController {

    @Autowired
    private UserService userService;

    @PostMapping({"/auth/v1/createUpdate", "/v1/users"})
    public ResponseEntity<UserInfoDto> createUpdate(@RequestBody UserInfoDto userInfoDto) {
        try {
            UserInfoDto user = userService.createOrUpdateUser(userInfoDto);
            return new ResponseEntity<>(user, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
    }

    @GetMapping({"/auth/v1/getUser", "/user/v1/getUser"})
    public ResponseEntity<UserInfoDto> getUser(@RequestParam("user_id") String userId) {
        try {
            UserInfoDto dto = new UserInfoDto();
            dto.setUserId(userId);

            UserInfoDto user = userService.getUser(dto);
            return ResponseEntity.ok(user);
        } catch (Exception e) {
            return ResponseEntity.notFound().build();
        }
    }

    @GetMapping("/v1/users/{userId}")
    public ResponseEntity<UserInfoDto> getUserByPathId(@PathVariable("userId") String userId) {
        try {
            UserInfoDto dto = new UserInfoDto();
            dto.setUserId(userId);

            UserInfoDto user = userService.getUser(dto);
            return ResponseEntity.ok(user);
        } catch (Exception e) {
            return ResponseEntity.notFound().build();
        }
    }
}

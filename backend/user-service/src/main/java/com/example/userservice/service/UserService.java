package com.example.userservice.service;

import java.util.Optional;
import java.util.function.Supplier;
import java.util.function.UnaryOperator;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.userservice.entities.UserInfo;
import com.example.userservice.entities.UserInfoDto;
import com.example.userservice.repository.UserRepository;

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;

    public UserInfoDto createOrUpdateUser(UserInfoDto userInfoDto) {
        
        UnaryOperator<UserInfo> updatingUser = user -> {
            user.setEmail(userInfoDto.getEmail());
            user.setUsername(userInfoDto.getUsername());
            user.setFirstName(userInfoDto.getFirstName());
            user.setLastName(userInfoDto.getLastName());
            user.setPhoneNumber(userInfoDto.getPhoneNumber());
            user.setProfilePic(userInfoDto.getProfilePic());
            user.setCreatedAt(userInfoDto.getCreatedAt());

            return userRepository.save(user); 
        };

        Supplier<UserInfo> createUser = () -> {
            return userRepository.save(userInfoDto.transformToUserInfo());
        };

        UserInfo userInfo = userRepository.findByUserId(userInfoDto.getUserId())
                    .map(updatingUser)
                    .orElseGet(createUser);

        return new UserInfoDto(
            userInfo.getUserId(),
            userInfo.getUsername(),
            userInfo.getFirstName(),
            userInfo.getLastName(),
            userInfo.getPhoneNumber(),
            userInfo.getEmail(),
            userInfo.getProfilePic(),
            userInfo.getCreatedAt()
        );
    }

    public UserInfoDto getUser(UserInfoDto userInfoDto) throws Exception {
        Optional<UserInfo> userInfoOpt = userRepository.findByUserId(userInfoDto.getUserId());
        if(userInfoOpt.isEmpty()) {
            throw new Exception("User Not Found!");
        }

        UserInfo userInfo = userInfoOpt.get();
        
        return new UserInfoDto(
            userInfo.getUserId(),
            userInfo.getUsername(),
            userInfo.getFirstName(),
            userInfo.getLastName(),
            userInfo.getPhoneNumber(),
            userInfo.getEmail(),
            userInfo.getProfilePic(),
            userInfo.getCreatedAt()
        );
    }
}

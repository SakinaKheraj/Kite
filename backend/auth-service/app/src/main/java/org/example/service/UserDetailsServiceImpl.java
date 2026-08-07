package org.example.service;

import java.util.HashSet;
import java.util.Objects;
import java.util.UUID;
import java.util.regex.Pattern;

import org.example.entities.UserInfo;
import org.example.eventProducer.UserInfoEvent;
import org.example.eventProducer.UserInfoProducer;
import org.example.model.UserInfoDto;
import org.example.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import lombok.AllArgsConstructor;

@Component
@AllArgsConstructor
public class UserDetailsServiceImpl implements UserDetailsService {

    @Autowired
    private final UserRepository userRepository;

    @Autowired
    private final PasswordEncoder passwordEncoder;

    @Autowired
    private final UserInfoProducer userInfoProducer;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {

        System.out.println("========== LOGIN DEBUG ==========");
        System.out.println("LOGIN USERNAME = " + username);

        UserInfo user = userRepository.findByUsername(username);
        System.out.println("FOUND USER = " + user);
        if (user == null) {
            System.out.println("USER NOT FOUND");
            throw new UsernameNotFoundException("could not found user..!!");
        }

        System.out.println("USER FOUND SUCCESSFULLY");
        return new CustomUserDetails(user);
    }

    public UserInfo checkIfUserExists(UserInfoDto userInfoDto) {
        return userRepository.findByUsername(userInfoDto.getUsername());
    }

    public boolean isValidEmail(String email) {
        if (email == null) return false;
        String emailRegex = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$";
        return Pattern.matches(emailRegex, email);
    }

    public boolean isValidPassword(String password) {
        if (password == null) return false;
        // Requires: 1 uppercase, 1 lowercase, 1 digit, 1 special character, min 6 length
        String passwordRegex = "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)(?=.*[@#$%^&+=!]).{6,}$";
        return Pattern.matches(passwordRegex, password);
    }

    public Boolean signupUser(UserInfoDto userInfoDto) {
        // FIX 1: Validate getEmail() NOT getUsername()
        if (!isValidEmail(userInfoDto.getEmail())) {
            System.out.println("INVALID EMAIL: " + userInfoDto.getEmail());
            return false;
        }

        // FIX 2: Check raw password validity before encoding
        if (!isValidPassword(userInfoDto.getPassword())) {
            System.out.println("INVALID PASSWORD: Must contain Uppercase, Lowercase, Number, and Special Char");
            return false;
        }

        if (Objects.nonNull(checkIfUserExists(userInfoDto))) {
            System.out.println("USER ALREADY EXISTS");
            return false;
        }

        // Save unencoded password string to publish to event if needed before encoding
        String rawPassword = userInfoDto.getPassword();
        
        // Encode password for database persistence
        String encodedPassword = passwordEncoder.encode(rawPassword);

        String userId = UUID.randomUUID().toString();
        userRepository.save(
                new UserInfo(
                        null,
                        userInfoDto.getUsername(),
                        encodedPassword,
                        new HashSet<>()));

        // pushEventToQueue
        userInfoProducer.sendEventToKafka(userInfoEventToPublish(userInfoDto, userId));
        return true;
    }

    private UserInfoEvent userInfoEventToPublish(UserInfoDto userInfoDto, String userId) {
        String phoneStr = userInfoDto.getPhoneNumber();
        Long phoneLong = null;
        if (phoneStr != null && !phoneStr.isBlank()) {
            try {
                phoneLong = Long.valueOf(phoneStr);
            } catch (NumberFormatException e) {
                // leave phoneLong as null if parsing fails
            }
        }

        return UserInfoEvent.builder()
                .userId(userId)
                .username(userInfoDto.getUsername())
                .firstName(userInfoDto.getFirstName())
                .lastName(userInfoDto.getLastName())
                .email(userInfoDto.getEmail())
                .phoneNumber(phoneLong)
                .createdAt(System.currentTimeMillis())
                .build();
    }
}
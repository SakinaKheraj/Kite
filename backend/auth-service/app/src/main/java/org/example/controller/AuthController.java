package org.example.controller;

import org.example.entities.RefreshToken;
import org.example.model.UserInfoDto;
import org.example.response.JwtResponseDTO;
import org.example.service.JwtService;
import org.example.service.RefreshTokenService;
import org.example.service.UserDetailsServiceImpl;

import lombok.RequiredArgsConstructor;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/auth/v1")
@RequiredArgsConstructor
public class AuthController {

    private final JwtService jwtService;

    private final RefreshTokenService refreshTokenService;

    private final UserDetailsServiceImpl userDetailsService;

    @PostMapping("/signup")
    public ResponseEntity<?> signUp(
            @RequestBody UserInfoDto userInfoDto
    ) {
        try {
            Boolean isSignedUp = userDetailsService.signupUser(userInfoDto);

            if (Boolean.FALSE.equals(isSignedUp)) {
                return new ResponseEntity<>(
                "Already Exists",
                HttpStatus.BAD_REQUEST
                );
            }
            RefreshToken refreshToken = refreshTokenService.createRefreshToken(
                        userInfoDto.getUsername()
                    );

            String jwtToken = jwtService.generateToken(
                        userInfoDto.getUsername()
                    );

            return new ResponseEntity<>(
                    JwtResponseDTO.builder()
                            .accessToken(jwtToken)
                            .token(refreshToken.getToken())
                            .build(),
                    HttpStatus.OK
            );
        } catch (Exception ex) {
            ex.printStackTrace();
            return new ResponseEntity<>(
                    ex.getMessage(),
                    HttpStatus.INTERNAL_SERVER_ERROR
            );
        }
    }
}
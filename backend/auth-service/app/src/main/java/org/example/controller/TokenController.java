package org.example.controller;

import org.example.entities.RefreshToken;
import org.example.request.AuthRequestDTO;
import org.example.request.RefreshTokenDTO;
import org.example.response.JwtResponseDTO;
import org.example.service.JwtService;
import org.example.service.RefreshTokenService;

import lombok.RequiredArgsConstructor;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;

import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/auth/v1")
@RequiredArgsConstructor
public class TokenController {

    private final AuthenticationManager authenticationManager;

    private final RefreshTokenService refreshTokenService;

    private final JwtService jwtService;

    @PostMapping("/login")
    public ResponseEntity<?> authenticateAndGetToken(
            @RequestBody AuthRequestDTO authRequestDTO) {
        try {
            Authentication authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            authRequestDTO.getUsername(),
                            authRequestDTO.getPassword()));

            if (authentication.isAuthenticated()) {
                RefreshToken refreshToken = refreshTokenService.createRefreshToken(
                        authRequestDTO.getUsername());

                return new ResponseEntity<>(
                        JwtResponseDTO.builder()
                                .accessToken(jwtService.generateToken(authRequestDTO.getUsername()))
                                .token(refreshToken.getToken())
                                .build(),
                        HttpStatus.OK);
            }
            return new ResponseEntity<>("Invalid username or password", HttpStatus.UNAUTHORIZED);
        } catch (Exception e) {
            return new ResponseEntity<>("Invalid username or password. Please Sign Up if you don't have an account.", HttpStatus.UNAUTHORIZED);
        }
    }

    @PostMapping("/refreshToken")
    public JwtResponseDTO refreshToken(
            @RequestBody RefreshTokenDTO refreshTokenRequestDTO) {

        return refreshTokenService
                .findByToken(refreshTokenRequestDTO.getToken())
                .map(refreshTokenService::verifyExpiration)
                .map(refreshToken -> {
                    String accessToken = jwtService.generateToken(
                            refreshToken.getUserInfo().getUsername());

                    return new JwtResponseDTO(accessToken, refreshTokenRequestDTO.getToken());
                })
                .orElseThrow(() -> new RuntimeException(
                        "Refresh Token is not in DB..!!"));
    }
}
package org.example.service;

import java.security.Key;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;

import javax.crypto.SecretKey;

import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;

@Service
public class JwtService {

    public static final String SECRET =
            "7gY0q3uM4mM8j8Fv9hV2kN5uL1sXcR6bT0pQaWzYxNk=";

    // Extract username from token
    public String extractUsername(String token) {
        return extractClaim(token, Claims::getSubject);
    }

    // Extract any claim
    public <T> T extractClaim(
            String token,
            Function<Claims, T> claimResolver
    ) {

        final Claims claims = extractAllClaims(token);

        return claimResolver.apply(claims);
    }

    // Extract expiration date
    public Date extractExpiration(String token) {
        return extractClaim(token, Claims::getExpiration);
    }

    // Check token expiration
    private Boolean isTokenExpired(String token) {
        return extractExpiration(token).before(new Date());
    }

    // Validate token
    public Boolean validateToken(
            String token,
            UserDetails userDetails
    ) {

        final String username = extractUsername(token);

        return (
                username.equals(userDetails.getUsername())
                        && !isTokenExpired(token)
        );
    }

    // Generate token
    public String generateToken(String username) {

        Map<String, Object> claims = new HashMap<>();

        return createToken(claims, username);
    }

    // Create token
    private String createToken(
            Map<String, Object> claims,
            String username
    ) {

        return Jwts.builder()
                .claims(claims)
                .subject(username)
                .issuedAt(new Date(System.currentTimeMillis()))

                // 10 hours
                .expiration(
                        new Date(System.currentTimeMillis() + 1000 * 60 * 60 * 10)
                )

                .signWith(getSignKey())
                .compact();
    }

    // Extract all claims
    private Claims extractAllClaims(String token) {

        return Jwts.parser()
                .verifyWith((SecretKey) getSignKey())
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }

    // Secret key
    private Key getSignKey() {

        byte[] keyBytes = Decoders.BASE64.decode(SECRET);

        return Keys.hmacShaKeyFor(keyBytes);
    }
}
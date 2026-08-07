package org.example.repository;

import java.util.Optional;

import org.example.entities.RefreshToken;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface RefreshTokenRepository extends CrudRepository<RefreshToken, Integer>{
    Optional<RefreshToken> findByToken(String token);

    org.example.service.RefreshTokenService save(org.example.service.RefreshTokenService refreshToken);
}

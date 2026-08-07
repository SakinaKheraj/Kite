package com.example.userservice.repository;

import java.util.Optional;

import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

import com.example.userservice.entities.UserInfo;
import com.example.userservice.entities.UserInfoDto;

@Repository
public interface UserRepository extends CrudRepository<UserInfo, Long> {

    Optional<UserInfo> findByUserId(String userId);

}

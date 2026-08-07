package org.example.eventProducer;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.databind.PropertyNamingStrategies;
import com.fasterxml.jackson.databind.annotation.JsonNaming;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@JsonNaming(PropertyNamingStrategies.SnakeCaseStrategy.class)
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonIgnoreProperties(ignoreUnknown = true)
public class UserInfoEvent {

    @JsonProperty("user_id")
    private String userId;

    @JsonProperty("username")
    private String username;

    @JsonProperty("first_name")
    private String firstName;

    @JsonProperty("last_name")
    private String lastName;

    @JsonProperty("email")
    private String email;

    @JsonProperty("phone_number")
    private Long phoneNumber;

    @JsonProperty("profile_pic")
    private String profilePic;

    @JsonProperty("created_at")
    private Long createdAt;
}

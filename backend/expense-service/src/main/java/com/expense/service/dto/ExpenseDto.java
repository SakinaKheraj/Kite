package com.expense.service.dto;

import java.sql.Timestamp;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import tools.jackson.databind.PropertyNamingStrategies;
import tools.jackson.databind.annotation.JsonNaming;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@NoArgsConstructor
@AllArgsConstructor
@Builder
@Getter
@Setter
@JsonIgnoreProperties(ignoreUnknown = true)
@JsonNaming(PropertyNamingStrategies.SnakeCaseStrategy.class)
public class ExpenseDto {

    private Long id;

    @JsonProperty("external_id")
    private String externalId;
    
    @JsonProperty("amount")
    private String amount;

    @JsonProperty("category")
    private String category;

    @JsonProperty("description")
    private String description;

    @JsonProperty("user_id")
    private String userId;

    @JsonProperty("merchant")
    private String merchant;

    @JsonProperty("currency")
    private String currency;

    @JsonProperty("created_at")
    private Timestamp createdAt;
}
package com.expense.service.dto;

import java.util.List;
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
public class ExpenseSummaryDto {

    @JsonProperty("user_id")
    private String userId;

    @JsonProperty("total_spent")
    private Double totalSpent;

    @JsonProperty("budget_limit")
    private Double budgetLimit;

    @JsonProperty("threshold_reached")
    private Boolean thresholdReached;

    @JsonProperty("warning_message")
    private String warningMessage;

    @JsonProperty("categories")
    private List<String> categories;
}

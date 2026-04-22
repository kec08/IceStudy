package com.icestudy.domain.stats.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

import java.util.List;

@Getter
@AllArgsConstructor
@Builder
public class ProfileStatsResponse {
    private long iceCount;
    private double totalMl;
    private int totalMinutes;
    private List<Integer> weeklyMinutes;  // 월~일, 7개 요소
}

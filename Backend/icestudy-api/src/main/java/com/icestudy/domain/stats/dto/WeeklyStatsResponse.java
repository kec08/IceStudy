package com.icestudy.domain.stats.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDate;
import java.util.List;

@Getter
@AllArgsConstructor
@Builder
public class WeeklyStatsResponse {
    private LocalDate weekStart;
    private LocalDate weekEnd;
    private double filledMl;
    private double goalMl;
    private int totalMinutes;
    private int sessionCount;
    private List<DailyStatDto> dailyStats;

    @Getter
    @AllArgsConstructor
    @Builder
    public static class DailyStatDto {
        private LocalDate date;
        private int totalMinutes;
        private double waterMl;
    }
}

package com.icestudy.domain.stats.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDate;
import java.util.List;

@Getter
@AllArgsConstructor
@Builder
public class CalendarStatsResponse {
    private int year;
    private int month;
    private List<CalendarDayDto> days;

    @Getter
    @AllArgsConstructor
    @Builder
    public static class CalendarDayDto {
        private LocalDate date;
        private int totalMinutes;
        private double waterMl;
        private int sessionCount;
    }
}

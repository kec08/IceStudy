package com.icestudy.domain.stats.dto;

import com.icestudy.domain.session.CupSize;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Getter
@AllArgsConstructor
@Builder
public class DailyStatsResponse {
    private LocalDate date;
    private int totalMinutes;
    private double totalWaterMl;
    private List<SessionDto> sessions;

    @Getter
    @AllArgsConstructor
    @Builder
    public static class SessionDto {
        private Long sessionId;
        private CupSize cupSize;
        private int elapsedTime;
        private double waterMl;
        private boolean isCompleted;
        private LocalDateTime createdAt;
        private LocalDateTime completedAt;
    }
}

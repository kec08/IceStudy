package com.icestudy.domain.session.dto;

import com.icestudy.domain.session.CupSize;
import com.icestudy.domain.session.StudySession;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@AllArgsConstructor
@Builder
public class SessionResponse {
    private Long sessionId;
    private CupSize cupSize;
    private int totalDuration;
    private int elapsedTime;
    private double waterMl;
    private boolean isCompleted;
    private LocalDateTime createdAt;
    private LocalDateTime completedAt;

    public static SessionResponse from(StudySession session) {
        return SessionResponse.builder()
                .sessionId(session.getId())
                .cupSize(session.getCupSize())
                .totalDuration(session.getTotalDuration())
                .elapsedTime(session.getElapsedTime())
                .waterMl(session.getWaterMl())
                .isCompleted(session.isCompleted())
                .createdAt(session.getCreatedAt())
                .completedAt(session.getCompletedAt())
                .build();
    }
}

package com.icestudy.domain.stats;

import com.icestudy.domain.session.SessionRepository;
import com.icestudy.domain.session.StudySession;
import com.icestudy.domain.stats.dto.*;
import com.icestudy.domain.user.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.YearMonth;
import java.time.ZoneId;
import java.time.temporal.TemporalAdjusters;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class StatsService {

    private static final double WEEKLY_GOAL_ML = 3000.0;
    private static final ZoneId KST = ZoneId.of("Asia/Seoul");

    private final SessionRepository sessionRepository;

    public WeeklyStatsResponse getWeeklyStats(User user, int weekOffset) {
        // 이번주 월요일 기준으로 weekOffset만큼 이전 주
        // iOS: 0=이번주, -1=지난주 → abs로 변환
        LocalDate weekStart = LocalDate.now(KST)
                .with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY))
                .minusWeeks(Math.abs(weekOffset));
        LocalDate weekEnd = weekStart.plusDays(6);

        LocalDateTime startDt = weekStart.atStartOfDay();
        LocalDateTime endDt = weekEnd.atTime(LocalTime.MAX);

        List<StudySession> sessions = sessionRepository.findByUserAndCreatedAtBetween(user, startDt, endDt);

        // 일별로 그룹핑
        Map<LocalDate, List<StudySession>> groupedByDate = sessions.stream()
                .collect(Collectors.groupingBy(s -> s.getCreatedAt().toLocalDate()));

        double filledMl = sessions.stream().mapToDouble(StudySession::getWaterMl).sum();
        int totalSeconds = sessions.stream().mapToInt(StudySession::getElapsedTime).sum();

        // 7일 데이터 생성 (데이터 없는 날도 포함)
        List<WeeklyStatsResponse.DailyStatDto> dailyStats = new ArrayList<>();
        for (int i = 0; i < 7; i++) {
            LocalDate date = weekStart.plusDays(i);
            List<StudySession> daySessions = groupedByDate.getOrDefault(date, List.of());

            dailyStats.add(WeeklyStatsResponse.DailyStatDto.builder()
                    .date(date)
                    .totalMinutes(daySessions.stream().mapToInt(StudySession::getElapsedTime).sum() / 60)
                    .waterMl(daySessions.stream().mapToDouble(StudySession::getWaterMl).sum())
                    .build());
        }

        return WeeklyStatsResponse.builder()
                .weekStart(weekStart)
                .weekEnd(weekEnd)
                .filledMl(Math.round(filledMl * 100.0) / 100.0)
                .goalMl(WEEKLY_GOAL_ML)
                .totalMinutes(totalSeconds / 60)
                .sessionCount(sessions.size())
                .dailyStats(dailyStats)
                .build();
    }

    public DailyStatsResponse getDailyStats(User user, LocalDate date) {
        LocalDateTime startDt = date.atStartOfDay();
        LocalDateTime endDt = date.atTime(LocalTime.MAX);

        List<StudySession> sessions = sessionRepository.findByUserAndCreatedAtBetween(user, startDt, endDt);

        int totalSeconds = sessions.stream().mapToInt(StudySession::getElapsedTime).sum();
        double totalWaterMl = sessions.stream().mapToDouble(StudySession::getWaterMl).sum();

        List<DailyStatsResponse.SessionDto> sessionDtos = sessions.stream()
                .map(s -> DailyStatsResponse.SessionDto.builder()
                        .sessionId(s.getId())
                        .cupSize(s.getCupSize())
                        .elapsedTime(s.getElapsedTime())
                        .waterMl(s.getWaterMl())
                        .isCompleted(s.isCompleted())
                        .createdAt(s.getCreatedAt())
                        .completedAt(s.getCompletedAt())
                        .build())
                .collect(Collectors.toList());

        return DailyStatsResponse.builder()
                .date(date)
                .totalMinutes(totalSeconds / 60)
                .totalWaterMl(Math.round(totalWaterMl * 100.0) / 100.0)
                .sessions(sessionDtos)
                .build();
    }

    public CalendarStatsResponse getCalendarStats(User user, int year, int month) {
        YearMonth yearMonth = YearMonth.of(year, month);
        LocalDateTime startDt = yearMonth.atDay(1).atStartOfDay();
        LocalDateTime endDt = yearMonth.atEndOfMonth().atTime(LocalTime.MAX);

        List<StudySession> sessions = sessionRepository.findByUserAndCreatedAtBetween(user, startDt, endDt);

        Map<LocalDate, List<StudySession>> groupedByDate = sessions.stream()
                .collect(Collectors.groupingBy(s -> s.getCreatedAt().toLocalDate()));

        List<CalendarStatsResponse.CalendarDayDto> days = new ArrayList<>();
        for (int day = 1; day <= yearMonth.lengthOfMonth(); day++) {
            LocalDate date = yearMonth.atDay(day);
            List<StudySession> daySessions = groupedByDate.getOrDefault(date, List.of());

            days.add(CalendarStatsResponse.CalendarDayDto.builder()
                    .date(date)
                    .totalMinutes(daySessions.stream().mapToInt(StudySession::getElapsedTime).sum() / 60)
                    .waterMl(daySessions.stream().mapToDouble(StudySession::getWaterMl).sum())
                    .sessionCount(daySessions.size())
                    .build());
        }

        return CalendarStatsResponse.builder()
                .year(year)
                .month(month)
                .days(days)
                .build();
    }

    public ProfileStatsResponse getProfileStats(User user) {
        long iceCount = sessionRepository.countByUserAndIsCompleted(user, true);
        double totalMl = sessionRepository.sumWaterMlByUser(user);
        long totalSeconds = sessionRepository.sumElapsedTimeByUser(user);

        // 이번주 월~일 일별 공부 시간
        LocalDate weekStart = LocalDate.now(KST).with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
        LocalDateTime startDt = weekStart.atStartOfDay();
        LocalDateTime endDt = weekStart.plusDays(6).atTime(LocalTime.MAX);

        List<StudySession> weeklySessions = sessionRepository.findByUserAndCreatedAtBetween(user, startDt, endDt);
        Map<LocalDate, List<StudySession>> groupedByDate = weeklySessions.stream()
                .collect(Collectors.groupingBy(s -> s.getCreatedAt().toLocalDate()));

        List<Integer> weeklyMinutes = new ArrayList<>();
        for (int i = 0; i < 7; i++) {
            LocalDate date = weekStart.plusDays(i);
            List<StudySession> daySessions = groupedByDate.getOrDefault(date, List.of());
            weeklyMinutes.add(daySessions.stream().mapToInt(StudySession::getElapsedTime).sum() / 60);
        }

        return ProfileStatsResponse.builder()
                .iceCount(iceCount)
                .totalMl(Math.round(totalMl * 100.0) / 100.0)
                .totalMinutes((int) (totalSeconds / 60))
                .weeklyMinutes(weeklyMinutes)
                .build();
    }
}

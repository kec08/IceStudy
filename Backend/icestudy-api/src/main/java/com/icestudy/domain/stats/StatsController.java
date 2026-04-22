package com.icestudy.domain.stats;

import com.icestudy.domain.stats.dto.*;
import com.icestudy.domain.user.User;
import com.icestudy.domain.user.UserRepository;
import com.icestudy.global.common.ApiResponse;
import com.icestudy.global.exception.BusinessException;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;

@Tag(name = "Stats", description = "통계 API")
@RestController
@RequestMapping("/api/stats")
@RequiredArgsConstructor
public class StatsController {

    private final StatsService statsService;
    private final UserRepository userRepository;

    @Operation(summary = "주간 통계")
    @GetMapping("/weekly")
    public ResponseEntity<ApiResponse<WeeklyStatsResponse>> getWeeklyStats(
            Authentication authentication,
            @RequestParam(defaultValue = "0") int weekOffset) {
        User user = getCurrentUser(authentication);
        WeeklyStatsResponse response = statsService.getWeeklyStats(user, weekOffset);
        return ResponseEntity.ok(ApiResponse.ok(response));
    }

    @Operation(summary = "특정일 통계")
    @GetMapping("/daily")
    public ResponseEntity<ApiResponse<DailyStatsResponse>> getDailyStats(
            Authentication authentication,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        User user = getCurrentUser(authentication);
        DailyStatsResponse response = statsService.getDailyStats(user, date);
        return ResponseEntity.ok(ApiResponse.ok(response));
    }

    @Operation(summary = "월간 캘린더 통계")
    @GetMapping("/calendar")
    public ResponseEntity<ApiResponse<CalendarStatsResponse>> getCalendarStats(
            Authentication authentication,
            @RequestParam int year,
            @RequestParam int month) {
        User user = getCurrentUser(authentication);
        CalendarStatsResponse response = statsService.getCalendarStats(user, year, month);
        return ResponseEntity.ok(ApiResponse.ok(response));
    }

    @Operation(summary = "프로필 누적 통계")
    @GetMapping("/profile")
    public ResponseEntity<ApiResponse<ProfileStatsResponse>> getProfileStats(
            Authentication authentication) {
        User user = getCurrentUser(authentication);
        ProfileStatsResponse response = statsService.getProfileStats(user);
        return ResponseEntity.ok(ApiResponse.ok(response));
    }

    private User getCurrentUser(Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        return userRepository.findById(userId)
                .orElseThrow(BusinessException::userNotFound);
    }
}

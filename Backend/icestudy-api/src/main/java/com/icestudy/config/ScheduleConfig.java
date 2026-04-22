package com.icestudy.config;

import com.icestudy.domain.auth.RefreshTokenRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Slf4j
@Component
@RequiredArgsConstructor
public class ScheduleConfig {

    private final RefreshTokenRepository refreshTokenRepository;

    /**
     * 매일 새벽 3시에 만료된 RefreshToken 삭제
     */
    @Scheduled(cron = "0 0 3 * * *")
    @Transactional
    public void cleanUpExpiredRefreshTokens() {
        refreshTokenRepository.deleteByExpiresAtBefore(LocalDateTime.now());
        log.info("만료된 RefreshToken 정리 완료");
    }
}

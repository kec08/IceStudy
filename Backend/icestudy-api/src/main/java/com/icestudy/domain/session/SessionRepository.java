package com.icestudy.domain.session;

import com.icestudy.domain.user.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;

public interface SessionRepository extends JpaRepository<StudySession, Long> {

    // 기간 내 완료된 세션 조회 (주간/월간 통계용)
    List<StudySession> findByUserAndCompletedAtBetween(User user, LocalDateTime start, LocalDateTime end);

    // 기간 내 모든 세션 조회 (포기 포함)
    List<StudySession> findByUserAndCreatedAtBetween(User user, LocalDateTime start, LocalDateTime end);

    // 완료한 얼음 갯수
    long countByUserAndIsCompleted(User user, boolean isCompleted);

    // 누적 통계
    @Query("SELECT COALESCE(SUM(s.waterMl), 0) FROM StudySession s WHERE s.user = :user")
    double sumWaterMlByUser(@Param("user") User user);

    @Query("SELECT COALESCE(SUM(s.elapsedTime), 0) FROM StudySession s WHERE s.user = :user")
    long sumElapsedTimeByUser(@Param("user") User user);

    void deleteAllByUser(User user);
}

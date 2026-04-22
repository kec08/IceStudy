package com.icestudy.domain.session;

import com.icestudy.domain.user.User;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "study_session")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
public class StudySession {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private CupSize cupSize;

    @Column(nullable = false)
    private int totalDuration;

    @Column(nullable = false)
    @Builder.Default
    private int elapsedTime = 0;

    @Column(nullable = false)
    @Builder.Default
    private double waterMl = 0.0;

    @Column(nullable = false)
    @Builder.Default
    private boolean isCompleted = false;

    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    private LocalDateTime completedAt;

    /**
     * 세션 완료 처리 — 서버에서 waterMl 계산
     */
    public void complete(int elapsedTime) {
        this.elapsedTime = elapsedTime;
        this.waterMl = WaterCalculator.calculate(this.cupSize, this.totalDuration, elapsedTime);
        this.isCompleted = true;
        this.completedAt = LocalDateTime.now();
    }

    /**
     * 세션 포기 처리 — 서버에서 waterMl 계산
     */
    public void abort(int elapsedTime) {
        this.elapsedTime = elapsedTime;
        this.waterMl = WaterCalculator.calculate(this.cupSize, this.totalDuration, elapsedTime);
        this.isCompleted = false;
        this.completedAt = LocalDateTime.now();
    }

    public boolean isFinished() {
        return this.completedAt != null;
    }
}

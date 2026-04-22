package com.icestudy.domain.session;

public class WaterCalculator {

    /**
     * 경과 시간에 비례하여 물양을 계산합니다.
     *
     * 공식: waterMl = (elapsedTime / totalDuration) x maxMl
     * - progress는 0.0 ~ 1.0으로 클램핑
     * - 결과는 소수점 둘째 자리 반올림
     */
    public static double calculate(CupSize cupSize, int totalDuration, int elapsedTime) {
        if (elapsedTime <= 0) return 0.0;

        double progress = Math.min((double) elapsedTime / totalDuration, 1.0);
        double waterMl = progress * cupSize.getMaxMl();

        return Math.round(waterMl * 100.0) / 100.0;
    }
}

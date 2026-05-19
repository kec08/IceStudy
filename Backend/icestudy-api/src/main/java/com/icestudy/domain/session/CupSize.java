package com.icestudy.domain.session;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public enum CupSize {

    TALL(1_800, 5_400, 355.0),
    GRANDE(5_400, 10_800, 473.0),
    VENTI(7_200, 14_400, 591.0);

    private final int minSeconds;
    private final int maxSeconds;
    private final double maxMl;

    /**
     * 온도 보정(0.9x~1.1x) 적용된 totalDuration도 허용
     */
    public boolean isValidDuration(int totalDuration) {
        int adjustedMin = (int) (minSeconds * 0.9);
        int adjustedMax = (int) (maxSeconds * 1.1);
        return totalDuration >= adjustedMin && totalDuration <= adjustedMax;
    }
}

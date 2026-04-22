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

    public boolean isValidDuration(int totalDuration) {
        return totalDuration >= minSeconds && totalDuration <= maxSeconds;
    }
}

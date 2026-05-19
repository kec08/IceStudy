package com.icestudy.domain.session.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.PositiveOrZero;
import lombok.Getter;

@Getter
public class SessionUpdateRequest {

    @NotNull(message = "경과 시간은 필수입니다")
    @Positive(message = "경과 시간은 양수여야 합니다")
    private Integer elapsedTime;

    @NotNull(message = "물의 양은 필수입니다")
    @PositiveOrZero(message = "물의 양은 0 이상이어야 합니다")
    private Double waterMl;
}

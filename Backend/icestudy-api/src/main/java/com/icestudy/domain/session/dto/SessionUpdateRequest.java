package com.icestudy.domain.session.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.Getter;

@Getter
public class SessionUpdateRequest {

    @NotNull(message = "경과 시간은 필수입니다")
    @Positive(message = "경과 시간은 양수여야 합니다")
    private Integer elapsedTime;
}

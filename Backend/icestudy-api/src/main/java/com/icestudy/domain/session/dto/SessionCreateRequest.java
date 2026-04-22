package com.icestudy.domain.session.dto;

import com.icestudy.domain.session.CupSize;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.Getter;

@Getter
public class SessionCreateRequest {

    @NotNull(message = "컵 사이즈는 필수입니다")
    private CupSize cupSize;

    @NotNull(message = "총 시간은 필수입니다")
    @Positive(message = "�� 시간은 양수여야 합니다")
    private Integer totalDuration;
}

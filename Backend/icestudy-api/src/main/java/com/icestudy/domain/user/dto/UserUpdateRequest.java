package com.icestudy.domain.user.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;

@Getter
public class UserUpdateRequest {

    @NotBlank(message = "닉네임은 필수입니다")
    @Size(min = 1, max = 50, message = "닉네임은 1자 이상 50자 이하여야 합니다")
    private String nickname;
}

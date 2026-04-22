package com.icestudy.domain.auth.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class AppleLoginRequest {

    @NotBlank(message = "identityToken은 필수입니다")
    private String identityToken;

    private String nickname;  // 최초 로그인 시에만 Apple이 제공
    private String email;     // 최초 로그인 시에만 Apple이 제공
}

package com.icestudy.global.exception;

import lombok.Getter;
import org.springframework.http.HttpStatus;

@Getter
public class BusinessException extends RuntimeException {

    private final String code;
    private final HttpStatus httpStatus;

    public BusinessException(String code, String message, HttpStatus httpStatus) {
        super(message);
        this.code = code;
        this.httpStatus = httpStatus;
    }

    // Auth
    public static BusinessException loginFailed() {
        return new BusinessException("AUTH_001", "이메일 또는 비밀번호가 올바르지 않습니다", HttpStatus.UNAUTHORIZED);
    }

    public static BusinessException emailDuplicated() {
        return new BusinessException("AUTH_002", "이미 가입된 이메일입니다", HttpStatus.CONFLICT);
    }

    public static BusinessException tokenExpired() {
        return new BusinessException("AUTH_003", "토큰이 만료되었거나 유효하지 않습니다", HttpStatus.UNAUTHORIZED);
    }

    // Session
    public static BusinessException sessionNotFound() {
        return new BusinessException("SESSION_001", "세션을 찾을 수 없습니다", HttpStatus.NOT_FOUND);
    }

    public static BusinessException sessionForbidden() {
        return new BusinessException("SESSION_002", "본인의 세션이 아닙니다", HttpStatus.FORBIDDEN);
    }

    public static BusinessException sessionAlreadyFinished() {
        return new BusinessException("SESSION_003", "이미 완료되었거나 중단된 세션입니다", HttpStatus.BAD_REQUEST);
    }

    // User
    public static BusinessException userNotFound() {
        return new BusinessException("USER_001", "유저를 찾을 수 없습니다", HttpStatus.NOT_FOUND);
    }
}

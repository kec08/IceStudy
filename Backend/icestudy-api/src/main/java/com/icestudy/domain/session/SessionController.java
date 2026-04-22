package com.icestudy.domain.session;

import com.icestudy.domain.session.dto.SessionCreateRequest;
import com.icestudy.domain.session.dto.SessionResponse;
import com.icestudy.domain.session.dto.SessionUpdateRequest;
import com.icestudy.domain.user.User;
import com.icestudy.domain.user.UserRepository;
import com.icestudy.global.common.ApiResponse;
import com.icestudy.global.exception.BusinessException;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@Tag(name = "Session", description = "공부 세션 API")
@RestController
@RequestMapping("/api/sessions")
@RequiredArgsConstructor
public class SessionController {

    private final SessionService sessionService;
    private final UserRepository userRepository;

    @Operation(summary = "세션 생성 (시��)")
    @PostMapping
    public ResponseEntity<ApiResponse<SessionResponse>> createSession(
            Authentication authentication,
            @Valid @RequestBody SessionCreateRequest request) {
        User user = getCurrentUser(authentication);
        SessionResponse response = sessionService.createSession(user, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.ok(response));
    }

    @Operation(summary = "세션 완료")
    @PatchMapping("/{sessionId}/complete")
    public ResponseEntity<ApiResponse<SessionResponse>> completeSession(
            Authentication authentication,
            @PathVariable Long sessionId,
            @Valid @RequestBody SessionUpdateRequest request) {
        User user = getCurrentUser(authentication);
        SessionResponse response = sessionService.completeSession(user, sessionId, request);
        return ResponseEntity.ok(ApiResponse.ok(response));
    }

    @Operation(summary = "세션 포기")
    @PatchMapping("/{sessionId}/abort")
    public ResponseEntity<ApiResponse<SessionResponse>> abortSession(
            Authentication authentication,
            @PathVariable Long sessionId,
            @Valid @RequestBody SessionUpdateRequest request) {
        User user = getCurrentUser(authentication);
        SessionResponse response = sessionService.abortSession(user, sessionId, request);
        return ResponseEntity.ok(ApiResponse.ok(response));
    }

    private User getCurrentUser(Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        return userRepository.findById(userId)
                .orElseThrow(BusinessException::userNotFound);
    }
}

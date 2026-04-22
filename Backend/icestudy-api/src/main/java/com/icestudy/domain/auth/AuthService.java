package com.icestudy.domain.auth;

import com.icestudy.config.JwtProvider;
import com.icestudy.domain.auth.dto.*;
import com.icestudy.domain.user.User;
import com.icestudy.domain.user.UserRepository;
import com.icestudy.global.exception.BusinessException;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AuthService {

    private final UserRepository userRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final JwtProvider jwtProvider;
    private final PasswordEncoder passwordEncoder;

    @Transactional
    public SignUpResponse signup(SignUpRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw BusinessException.emailDuplicated();
        }

        User user = User.builder()
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .nickname(request.getNickname())
                .build();

        User saved = userRepository.save(user);

        return SignUpResponse.builder()
                .userId(saved.getId())
                .email(saved.getEmail())
                .nickname(saved.getNickname())
                .build();
    }

    @Transactional
    public TokenResponse login(LoginRequest request) {
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(BusinessException::loginFailed);

        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw BusinessException.loginFailed();
        }

        String accessToken = jwtProvider.generateAccessToken(user.getId(), user.getEmail());
        String refreshToken = jwtProvider.generateRefreshToken(user.getId(), user.getEmail());

        // 기존 리프레시 토큰 삭제 후 새로 저장
        refreshTokenRepository.deleteByUser(user);
        refreshTokenRepository.save(RefreshToken.builder()
                .user(user)
                .token(refreshToken)
                .expiresAt(LocalDateTime.now().plusSeconds(jwtProvider.getRefreshExpiration() / 1000))
                .build());

        return TokenResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .userId(user.getId())
                .nickname(user.getNickname())
                .build();
    }

    @Transactional
    public TokenResponse refresh(RefreshRequest request) {
        if (!jwtProvider.validateToken(request.getRefreshToken())) {
            throw BusinessException.tokenExpired();
        }

        RefreshToken storedToken = refreshTokenRepository.findByToken(request.getRefreshToken())
                .orElseThrow(BusinessException::tokenExpired);

        if (storedToken.getExpiresAt().isBefore(LocalDateTime.now())) {
            refreshTokenRepository.delete(storedToken);
            throw BusinessException.tokenExpired();
        }

        User user = storedToken.getUser();

        // Rotation: 기존 토큰 삭제, 새 토큰 발급
        refreshTokenRepository.delete(storedToken);

        String newAccessToken = jwtProvider.generateAccessToken(user.getId(), user.getEmail());
        String newRefreshToken = jwtProvider.generateRefreshToken(user.getId(), user.getEmail());

        refreshTokenRepository.save(RefreshToken.builder()
                .user(user)
                .token(newRefreshToken)
                .expiresAt(LocalDateTime.now().plusSeconds(jwtProvider.getRefreshExpiration() / 1000))
                .build());

        return TokenResponse.builder()
                .accessToken(newAccessToken)
                .refreshToken(newRefreshToken)
                .userId(user.getId())
                .nickname(user.getNickname())
                .build();
    }
}

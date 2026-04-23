package com.icestudy.domain.user;

import com.icestudy.domain.user.dto.ChangePasswordRequest;
import com.icestudy.domain.user.dto.UserResponse;
import com.icestudy.domain.user.dto.UserUpdateRequest;
import com.icestudy.domain.auth.RefreshTokenRepository;
import com.icestudy.domain.session.SessionRepository;
import com.icestudy.global.exception.BusinessException;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class UserService {

    private final UserRepository userRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final SessionRepository sessionRepository;
    private final PasswordEncoder passwordEncoder;

    public UserResponse getMyInfo(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(BusinessException::userNotFound);
        return UserResponse.from(user);
    }

    @Transactional
    public UserResponse updateMyInfo(Long userId, UserUpdateRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(BusinessException::userNotFound);
        user.updateNickname(request.getNickname());
        return UserResponse.from(user);
    }

    @Transactional
    public void changePassword(Long userId, ChangePasswordRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(BusinessException::userNotFound);

        if (user.getPassword() == null || user.getPassword().isEmpty()) {
            throw new BusinessException("USER_002", "Apple 로그인 계정은 비밀번호를 변경할 수 없습니다",
                    org.springframework.http.HttpStatus.BAD_REQUEST);
        }

        if (!passwordEncoder.matches(request.getCurrentPassword(), user.getPassword())) {
            throw new BusinessException("USER_003", "현재 비밀번호가 올바르지 않습니다",
                    org.springframework.http.HttpStatus.BAD_REQUEST);
        }

        user.updatePassword(passwordEncoder.encode(request.getNewPassword()));
    }

    @Transactional
    public void deleteAccount(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(BusinessException::userNotFound);
        sessionRepository.deleteAllByUser(user);
        refreshTokenRepository.deleteByUser(user);
        userRepository.delete(user);
    }
}

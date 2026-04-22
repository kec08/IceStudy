package com.icestudy.domain.user;

import com.icestudy.domain.user.dto.UserResponse;
import com.icestudy.domain.user.dto.UserUpdateRequest;
import com.icestudy.global.exception.BusinessException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class UserService {

    private final UserRepository userRepository;

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
}

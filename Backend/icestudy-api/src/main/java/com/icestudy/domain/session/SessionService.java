package com.icestudy.domain.session;

import com.icestudy.domain.session.dto.SessionCreateRequest;
import com.icestudy.domain.session.dto.SessionResponse;
import com.icestudy.domain.session.dto.SessionUpdateRequest;
import com.icestudy.domain.user.User;
import com.icestudy.global.exception.BusinessException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class SessionService {

    private final SessionRepository sessionRepository;

    @Transactional
    public SessionResponse createSession(User user, SessionCreateRequest request) {
        // totalDuration 범위 유효성 검증
        if (!request.getCupSize().isValidDuration(request.getTotalDuration())) {
            throw new BusinessException("VALID_001",
                    String.format("%s 사이즈의 시간 범위는 %d초~%d초입니다",
                            request.getCupSize().name(),
                            request.getCupSize().getMinSeconds(),
                            request.getCupSize().getMaxSeconds()),
                    org.springframework.http.HttpStatus.BAD_REQUEST);
        }

        StudySession session = StudySession.builder()
                .user(user)
                .cupSize(request.getCupSize())
                .totalDuration(request.getTotalDuration())
                .build();

        StudySession saved = sessionRepository.save(session);
        return SessionResponse.from(saved);
    }

    @Transactional
    public SessionResponse completeSession(User user, Long sessionId, SessionUpdateRequest request) {
        StudySession session = getSessionWithAuth(user, sessionId);
        session.complete(request.getElapsedTime());
        return SessionResponse.from(session);
    }

    @Transactional
    public SessionResponse abortSession(User user, Long sessionId, SessionUpdateRequest request) {
        StudySession session = getSessionWithAuth(user, sessionId);
        session.abort(request.getElapsedTime());
        return SessionResponse.from(session);
    }

    private StudySession getSessionWithAuth(User user, Long sessionId) {
        StudySession session = sessionRepository.findById(sessionId)
                .orElseThrow(BusinessException::sessionNotFound);

        if (!session.getUser().getId().equals(user.getId())) {
            throw BusinessException.sessionForbidden();
        }

        if (session.isFinished()) {
            throw BusinessException.sessionAlreadyFinished();
        }

        return session;
    }
}

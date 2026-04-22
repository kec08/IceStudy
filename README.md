# IceStudy (얼공)

> 얼음이 녹을 때까지, 집중.

SNS에서 유행하는 **얼음공부법**을 앱으로 구현한 학습 집중 타이머입니다.
남은 시간을 보여주지 않고, 얼음이 녹는 애니메이션만으로 집중을 유도합니다.

## Features

- **랜덤 타이머** — 컵 사이즈(Tall/Grande/Venti)에 따라 랜덤 시간 설정, 남은 시간 비공개
- **얼음 녹는 애니메이션** — 얼음이 천천히 녹아 물로 변하는 시각적 피드백
- **주간 대시보드** — 유리 양동이에 채워지는 물양으로 공부량 시각화
- **캘린더** — 월별 일일 공부시간 + 물양 기록
- **프로필 통계** — 녹인 얼음 수, 총 물양, 총 공부시간, 주간 바 차트
- **Apple 로그인** — Sign in with Apple 지원
- **푸시 알림** — 타이머 완료 알림 + 매일 아침 8시 리마인더

## Tech Stack

### iOS
| 항목 | 기술 |
|------|------|
| UI | SwiftUI |
| 아키텍처 | MVVM |
| 최소 버전 | iOS 17+ |
| 네트워크 | Moya + async/await |
| 인증 | Sign in with Apple + JWT |
| 패키지 매니저 | SPM |

### Backend
| 항목 | 기술 |
|------|------|
| 프레임워크 | Spring Boot 3.5.0 |
| 언어 | Java 17 |
| DB | MySQL 8.x |
| ORM | Spring Data JPA |
| 인증 | JWT (Access + Refresh Token) |
| 문서 | Swagger (springdoc-openapi) |
| 배포 | Railway (Docker) |

## Project Structure

```
IceStudy/
├── iOS/                        # iOS 앱 (SwiftUI)
│   └── IceStudy/
│       ├── App/                # 앱 진입점
│       ├── Models/             # CupSize 등 데이터 모델
│       ├── ViewModels/         # AuthViewModel, TimerViewModel
│       ├── Views/              # 10개 화면
│       │   ├── Auth/           # 로그인, 회원가입, 닉네임 설정
│       │   ├── Home/           # 주간 대시보드, 캘린더
│       │   ├── Timer/          # 컵 선택, 타이머, 결과
│       │   └── Profile/        # 프로필, 주간 차트
│       ├── Network/            # API, DTO, Service, TokenStorage
│       └── Utils/              # Constants, NotificationManager
│
└── Backend/                    # Spring Boot API 서버
    └── icestudy-api/
        └── src/main/java/com/icestudy/
            ├── config/         # Security, JWT, Swagger
            ├── domain/
            │   ├── auth/       # 인증 (이메일 + Apple)
            │   ├── user/       # 유저 관리
            │   ├── session/    # 공부 세션 기록
            │   └── stats/      # 통계 API
            └── global/         # 예외 처리, 공통 응답

```

## API Endpoints

| Method | Path | 설명 |
|--------|------|------|
| POST | /api/auth/signup | 회원가입 |
| POST | /api/auth/login | 이메일 로그인 |
| POST | /api/auth/apple | Apple 로그인 |
| POST | /api/auth/refresh | 토큰 갱신 |
| POST | /api/sessions | 세션 생성 |
| PATCH | /api/sessions/{id}/complete | 세션 완료 |
| PATCH | /api/sessions/{id}/abort | 세션 포기 |
| GET | /api/stats/weekly | 주간 통계 |
| GET | /api/stats/calendar | 월간 캘린더 |
| GET | /api/stats/profile | 프로필 통계 |
| GET | /api/users/me | 내 정보 조회 |
| PATCH | /api/users/me | 내 정보 수정 |

## Screenshots

| 홈 | 타이머 | 프로필 |
|----|--------|--------|
| 주간 물양 양동이 | 얼음 녹는 애니메이션 | 통계 + 주간 차트 |

## Getting Started

### iOS
```bash
cd iOS/
open IceStudy.xcodeproj
# Xcode에서 빌드 (iOS 17+ 시뮬레이터 또는 실기기)
```

### Backend
```bash
cd Backend/icestudy-api/
./gradlew bootRun
# http://localhost:8080/swagger-ui.html
```

### 환경변수 (Production)
```
DB_URL=jdbc:mysql://host:3306/icestudy
DB_USERNAME=root
DB_PASSWORD=****
JWT_SECRET=your-secret-key
```

## License

This project is for educational purposes.

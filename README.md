# 🧊 얼공 (IceStudy) - 얼음공부법 집중 타이머

<p align="center">
  <img src="https://github.com/user-attachments/assets/39fc7672-53a4-4962-887f-561b4137831b" alt="얼공" width="100%"/>
</p>

<p align="center">
  <strong>"얼음이 녹을 때까지, 집중."</strong>
</p>

<p align="center">
  <a href="https://apps.apple.com/kr/app/%EC%96%BC%EA%B3%B5/id6762845172">
    <img src="https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg" alt="App Store" height="40"/>
  </a>
</p>

---

## 소개

**얼공**은 SNS에서 유행하는 얼음공부법을 앱으로 구현한 학습 집중 타이머입니다.

남은 시간을 보여주지 않고, 얼음이 녹는 애니메이션만으로 집중을 유도합니다.
컵 사이즈를 고르면 랜덤 시간이 설정되고, 얼음이 다 녹으면 공부 끝!

## 주요 기능

### 1. 랜덤 타이머
> 남은 시간은 비밀. 얼음이 다 녹을 때까지 집중하세요.

- 컵 사이즈(Tall/Grande/Venti)에 따라 랜덤 시간 설정
- 남은 시간/퍼센트 일절 비공개
- 얼음이 녹는 것만 보고 집중

### 2. 얼음 녹는 애니메이션
> 컵마다 녹는 속도가 달라요. Grande는 천천히, Venti는 더~ 천천히.

- 43개 얼음 블록이 8레이어로 자연스럽게 녹음
- 컵 사이즈별 비선형 이징 커브 적용
- 아래부터 물이 차오르는 시각적 피드백

### 3. 주간 대시보드
> 이번 주에 녹인 물을 양동이에 담아보세요.

- 유리 양동이에 채워지는 물양으로 공부량 시각화
- 주간 슬라이드 전환으로 과거 기록 확인
- 목표량 초과 시 특별한 변화

### 4. 캘린더
> 한 달간의 공부 기록을 한눈에.

- 월별 일일 공부시간 + 물양 기록
- 농도로 공부량 시각화

### 5. 프로필 통계
> 녹인 얼음 수, 총 물양, 총 공부시간을 한눈에.

- 전체 통계 요약
- 주간 바 차트 (스크린타임 스타일)

### 6. 부가 기능
> 집중을 도와주는 작은 기능들.

- 백색소음 / 빗소리 / 숲소리 (AVAudioEngine)
- 집중모드 (화면 꺼짐 방지)
- 타이머 결과 공유 (인스타 카드)
- 위젯 지원 (이번 주 물양 확인)

## 프로젝트 구조

### iOS

```
IceStudy/
├── App/
│   └── IceStudyApp.swift               # @main 엔트리
│
├── Models/
│   ├── CupSize.swift                   # 컵 사이즈 enum (Tall/Grande/Venti)
│   └── TemperatureZone.swift           # 온도 기반 물양 계산
│
├── ViewModels/
│   ├── AuthViewModel.swift             # 인증 상태 관리
│   └── TimerViewModel.swift            # 타이머 로직 + 백그라운드 보정
│
├── Views/
│   ├── Splash/
│   │   └── SplashView.swift            # 스플래시 (2초)
│   ├── Onboarding/
│   │   └── OnboardingView.swift        # 최초 1회 온보딩
│   ├── Auth/
│   │   ├── LoginView.swift             # Apple 로그인 + 이메일
│   │   ├── SignUpView.swift            # 회원가입
│   │   └── NicknameSetupView.swift     # 닉네임 설정
│   ├── Home/
│   │   ├── HomeView.swift              # 주간 대시보드 + 양동이
│   │   └── CalendarView.swift          # 월별 캘린더
│   ├── Timer/
│   │   ├── IceTimerFlowView.swift      # 상태 기반 화면 전환
│   │   ├── CupSelectionView.swift      # 컵 선택 (3카드)
│   │   ├── TimerRunningView.swift      # 타이머 실행 화면
│   │   ├── TimerResultView.swift       # 완료/포기 결과
│   │   └── IceMeltingView.swift        # 얼음 녹는 애니메이션
│   ├── Profile/
│   │   ├── ProfileView.swift           # 프로필 통계
│   │   ├── WeeklyChartView.swift       # 주간 바 차트
│   │   └── SettingsView.swift          # 설정 (닉네임/비밀번호/���퇴)
│   └── Components/
│       ├── MainTabView.swift           # 3탭 (양동이/얼음/마이)
│       ├── LogoHeaderView.swift        # 로고 헤더
│       ├── PrimaryButton.swift         # 공통 버튼
│       └── GlassCupShape.swift         # 유리컵 커스텀 Shape
│
├── Network/
│   ├── TokenStorage.swift              # Keychain 기반 JWT 저장
│   ├── APIError.swift                  # 에러 타입
│   ├── DTO/                            # AuthDTO, SessionDTO, StatsDTO
│   ├── API/                            # Moya TargetType (Auth/Session/Stats/User)
│   └── Service/                        # API 서비스 레이어
│
├── Services/
│   ├── LocationService.swift           # 위치 요청 (CLLocationManager)
│   ├── WeatherService.swift            # 온도 조회 (Open-Meteo)
│   └── WhiteNoiseService.swift         # 백색소음/빗소리/숲소리
│
└── Utils/
    ├── Constants.swift                 # AppColor, AppFont
    ├── NotificationManager.swift       # 푸시 알림 관리
    └── WidgetData.swift                # 위젯 데이터 공유

IceStudyWidget/                          # 위젯 Extension
├── IceStudyWidget.swift                # 위젯 UI + Timeline
└── IceStudyWidgetBundle.swift          # Widget Bundle
```

### Backend

```
icestudy-api/
└── src/main/java/com/icestudy/
    ├── config/
    │   ├── SecurityConfig.java          # Spring Security 설정
    │   ├── JwtProvider.java             # JWT 생성/검증
    │   ├── JwtAuthenticationFilter.java # 인증 필터
    │   ├── SwaggerConfig.java           # API 문서
    │   └── ScheduleConfig.java          # 스케줄링
    │
    ├── domain/
    │   ├── auth/                        # 인증 (이메일 + Apple)
    │   │   ├── AuthController.java
    │   │   ├── AuthService.java
    │   │   ├── AppleTokenVerifier.java
    │   │   └── dto/
    │   ├── user/                        # 유저 관리
    │   │   ├── UserController.java
    │   │   ├── UserService.java
    │   │   └── dto/
    │   ├── session/                     # 공부 세션
    │   │   ├── SessionController.java
    │   │   ├── SessionService.java
    │   │   ├── WaterCalculator.java     # 물양 계산 로직
    │   │   └── dto/
    │   └── stats/                       # 통계
    │       ├── StatsController.java
    │       ├── StatsService.java
    │       └── dto/
    │
    └── global/
        ├── common/ApiResponse.java      # 공통 응답 래퍼
        └── exception/                   # 예외 처리
```

## 기술 스택

### iOS

| 항목 | 기술 |
|------|------|
| UI | SwiftUI |
| 아키텍처 | MVVM |
| 최소 버전 | iOS 17+ |
| 네트워크 | Moya + async/await |
| 인증 | Sign in with Apple + JWT |
| 저장소 | Keychain (토큰) + UserDefaults (설정) |
| 위젯 | WidgetKit + App Group |
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

## 컵 사이즈

| 사이즈 | 시간 범위 | 최대 물양 | 설명 |
|--------|----------|----------|------|
| Tall | 30분 ~ 1시간 30분 | 355ml | 가벼운 공부 |
| Grande | 1시간 30분 ~ 3시간 | 473ml | 집중 공부 |
| Venti | 2시간 ~ 4시간 | 591ml | 깊은 공부 |

## 앱 다운로드

<p align="center">
  <a href="https://apps.apple.com/kr/app/%EC%96%BC%EA%B3%B5/id6762845172">
    <img src="https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg" alt="App Store" height="40"/>
  </a>
</p>

## 개발 정보

- 1인 개발 프로젝트
- iOS: SwiftUI + Moya (SPM)
- Backend: Spring Boot + MySQL (Railway 배포)

## 라이선스

이 프로젝트는 개인 프로젝트로, 무단 복제 및 배포를 금합니다.

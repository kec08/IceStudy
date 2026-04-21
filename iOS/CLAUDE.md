# IceStudy (얼공) - iOS

## 프로젝트 개요
- 학습 집중 앱: 랜덤 타이머 + 얼음→물 시각화
- 남은 시간 비공개, 몰입 유도 UX
- SwiftUI + MVVM + Spring Boot(Backend)

## 기술 스택

| 항목 | 기술 |
|------|------|
| UI | SwiftUI |
| 아키텍처 | MVVM |
| 비동기 | Combine / async-await |
| 최소 버전 | iOS 17+ |
| 패키지 매니저 | SPM |

## 디렉토리 구조 (목표)

```
IceStudy/
├── App/
│   └── IceStudyApp.swift
├── Models/
│   ├── User.swift
│   ├── StudySession.swift
│   └── CupSize.swift
├── ViewModels/
│   ├── HomeViewModel.swift
│   ├── TimerViewModel.swift
│   └── ProfileViewModel.swift
├── Views/
│   ├── Splash/
│   │   └── SplashView.swift
│   ├── Onboarding/
│   │   └── OnboardingView.swift
│   ├── Auth/
│   │   └── LoginView.swift
│   ├── Home/
│   │   └── HomeView.swift
│   ├── Timer/
│   │   ├── CupSelectionView.swift
│   │   ├── TimerRunningView.swift
│   │   └── TimerResultView.swift
│   ├── Profile/
│   │   └── ProfileView.swift
│   └── Components/
│       ├── IceMeltingView.swift
│       ├── WaterCupView.swift
│       ├── WeeklyChartView.swift
│       └── TabBarView.swift
├── Services/
│   ├── APIService.swift
│   ├── AuthService.swift
│   └── SessionService.swift
├── Utils/
│   ├── Constants.swift
│   └── Extensions.swift
└── Assets.xcassets/
```

## 화면 구성 (8개)

| # | 화면 | 뷰 파일 | 설명 |
|---|------|---------|------|
| 1 | 스플래시 | SplashView | 얼음 아이콘 + "얼공" 로고 |
| 2 | 온보딩 | OnboardingView | 앱 소개 + "시작하기" |
| 3 | 로그인 | LoginView | Apple 로그인 + 이메일/비밀번호 |
| 4 | 홈 | HomeView | 주간 물양 대시보드 + 양동이 |
| 5 | 컵 선택 | CupSelectionView | Tall/Grande/Venti 선택 |
| 6 | 타이머 실행 | TimerRunningView | 얼음 녹는 애니메이션 + 집중 메시지 |
| 7 | 타이머 결과 | TimerResultView | 녹인 물양 + 집중 시간 |
| 8 | 프로필 | ProfileView | 통계 + 주간 차트 + 로그아웃 |

## 탭바 구조

| 탭 | 아이콘 | 화면 |
|----|--------|------|
| 양동이(홈) | home | HomeView |
| 얼음 | cube | CupSelection → Timer → Result |
| 마이 | user | ProfileView |

## 컵 사이즈 모델

| 사이즈 | 시간 범위 | 최대 물양 | 라벨 | 색상 |
|--------|-----------|----------|------|------|
| TALL | 30분~1시간30분 | 355ml | 가벼운 공부 | 초록 |
| GRANDE | 1시간30분~3시간 | 473ml | 집중 공부 | 파랑 |
| VENTI | 2시간~4시간 | 591ml | 깊은 공부 | 핑크 |

## 핵심 로직

### 물양 계산
- `waterML = (elapsedTime / totalDuration) * maxML`
- totalDuration: 컵 사이즈 범위 내 랜덤 생성
- 사용자에게 totalDuration 절대 노출 금지

### 세션 상태
- **진행중**: 얼음 녹는 애니메이션
- **완료**: 얼음 완전히 녹음 → 물 채워짐
- **포기**: 얼음 깨짐 → "중단" 기록

### 타이머 실행 화면 버튼
- 좌: 수면/화면잠금 모드
- 중앙: 재생/일시정지
- 우: 정지(포기)

## API 엔드포인트

| Method | Path | 설명 |
|--------|------|------|
| POST | /sessions | 세션 생성 |
| PATCH | /sessions/{id}/complete | 세션 완료 |
| PATCH | /sessions/{id}/abort | 세션 중단 |
| GET | /sessions/today | 오늘 데이터 |
| GET | /sessions/weekly | 주간 데이터 |

## 데이터 모델

### User
- id: Long
- nickname: String
- createdAt: DateTime

### StudySession
- id: Long
- userId: Long
- size: TALL / GRANDE / VENTI
- totalDuration: Int (초)
- elapsedTime: Int (초)
- waterML: Double
- isCompleted: Bool
- createdAt: DateTime

## 디자인 시스템

### 컬러
- Primary: #48C7FF (메인 블루)
- Text: #212121 (기본 텍스트)
- TextSecondary: #9E9E9E (보조 텍스트)
- Background: #FFFFFF
- Surface: #F5F5F5 (카드, 비활성 버튼)
- Accent: 컵별 색상 (Tall #8BC34A / Grande #48C7FF / Venti #F06292)
- 상세: DESIGN.md 참조

### 폰트
- 타이틀: Bold, 24-32pt
- 수치(ml): Bold, 40-48pt
- 본문: Regular, 14-16pt

## 코딩 컨벤션

### 네이밍
- View: `~View` (예: HomeView)
- ViewModel: `~ViewModel` (예: HomeViewModel)
- Service: `~Service` (예: APIService)
- enum case: camelCase

### MVVM 규칙
- View: UI 렌더링만
- ViewModel: @Observable, 비즈니스 로직
- Model: 데이터 구조체
- Service: 네트워크/로컬 데이터 처리

### SwiftUI 규칙
- @State: View 내부 상태
- @Observable: ViewModel
- NavigationStack 사용
- 뷰 분리 기준: 100줄 초과 시

## UX 원칙
- 타이머 화면에 시간/퍼센트 표시 금지
- 정보 최소화, 인터랙션 최소화
- 얼음→물 변화로만 진행 상태 표현

## MVP 범위 (1차)
- [ ] 스플래시 + 온보딩
- [ ] 로그인 (Apple + 이메일)
- [ ] 컵 선택 (3단계)
- [ ] 랜덤 타이머 + 얼음 애니메이션
- [ ] 물(ml) 계산
- [ ] 홈 양동이 대시보드
- [ ] 프로필 + 주간 통계

## 화면 자료 경로
- 디자인 목업: `../화면 자료/*.jpg`
- 컵 에셋: `../화면 자료/Tall Cup.png`, `Grande Cup.png`, `Venti Cup.png`
- 아이콘: `../화면 자료/*.svg`, `*.png`
- 앱 아이콘: `../화면 자료/앱 아이콘.png`

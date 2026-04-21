# IceStudy (얼공) - Development Skills

## Phase 1: 프로젝트 초기 설정

### 1.1 프로젝트 구조 생성
- [ ] MVVM 폴더 구조 생성 (App, Models, ViewModels, Views, Services, Utils, Components)
- [ ] Assets.xcassets 에셋 등록 (컵 이미지, 아이콘, 앱아이콘)
- [ ] Color 에셋 등록 (primary, textPrimary, textSecondary, surface, cup 컬러)
- [ ] Info.plist 설정 (앱 표시 이름: 얼공)

### 1.2 공통 유틸리티
- [ ] Constants.swift: API URL, 컵 사이즈별 시간/ml 상수
- [ ] Color+Extension.swift: 커스텀 컬러 정의
- [ ] Font+Extension.swift: 디자인 시스템 폰트 스타일
- [ ] View+Extension.swift: 공통 modifier (카드, 버튼 스타일)

### 1.3 데이터 모델
- [ ] CupSize.swift: enum (tall, grande, venti) + 시간범위/ml/라벨/컬러
- [ ] User.swift: id, nickname, email, createdAt
- [ ] StudySession.swift: id, userId, size, totalDuration, elapsedTime, waterML, isCompleted, createdAt
- [ ] WeeklyData.swift: 주간 통계 모델

---

## Phase 2: 공통 컴포넌트

### 2.1 네비게이션/탭
- [ ] MainTabView.swift: 3탭 (홈/얼음/마이) + 커스텀 탭바
- [ ] CustomTabBar.swift: 하단 탭바 (활성 #48C7FF, 비활성 #BDBDBD)
- [ ] LogoHeaderView.swift: 좌상단 얼음아이콘 + "얼공" 로고 (재사용)

### 2.2 버튼
- [ ] PrimaryButton.swift: #48C7FF 배경, 흰 텍스트, 52pt 높이
- [ ] SecondaryButton.swift: #F5F5F5 배경, 비활성 스타일
- [ ] OutlineButton.swift: 테두리, Apple 로그인용
- [ ] IconCircleButton.swift: 원형 아이콘 버튼 (primary/gray)

### 2.3 카드
- [ ] StatCard.swift: 아이콘 + 라벨 + 수치 (프로필 3열용)
- [ ] CupCard.swift: 컵 이미지 + 사이즈명 + 라벨 + ml (선택 카드)

### 2.4 차트
- [ ] WeeklyBarChart.swift: 7일 바 차트 + 평균 점선 + 요일 라벨

---

## Phase 3: 스플래시 + 온보딩

### 3.1 스플래시
- [ ] SplashView.swift
  - 중앙: 얼음 큐브 아이콘 (120pt) + "얼공" 텍스트
  - scale + fade 애니메이션 (0.8s)
  - 2초 후 자동 전환
- [ ] SplashViewModel.swift: 자동 전환 타이머, 첫 실행 여부 판단

### 3.2 온보딩
- [ ] OnboardingView.swift
  - 좌상단 로고
  - 설명 2줄: "언제 녹을지 모르는 얼음" / "전부 녹을 때까지 집중해보세요"
  - 중앙: 얼음 컵 이미지
  - 하단: "시작하기" Primary 버튼
- [ ] 첫 실행 시에만 표시 (UserDefaults / @AppStorage)

---

## Phase 4: 인증

### 4.1 로그인
- [ ] LoginView.swift
  - 네비바: 뒤로 + "얼공" 로고
  - Apple 로그인 Outline 버튼
  - 구분선
  - 이메일/비밀번호 입력 필드 (하단 보더 스타일)
  - "아직 회원이 아니신가요?" + "회원가입" 링크
  - "로그인" 버튼 (입력 전 비활성, 입력 후 활성)
- [ ] LoginViewModel.swift: 입력 유효성, 로그인 API 호출

### 4.2 회원가입
- [ ] SignUpView.swift: 닉네임/이메일/비밀번호 입력
- [ ] SignUpViewModel.swift: 가입 API 호출

### 4.3 인증 서비스
- [ ] AuthService.swift: 로그인/가입/Apple로그인/토큰관리
- [ ] KeychainHelper.swift: 토큰 저장/조회/삭제

---

## Phase 5: 홈 (양동이 대시보드)

### 5.1 홈 화면
- [ ] HomeView.swift
  - 좌상단 로고
  - 주간 네비: < "2025년 1월 첫째주" > (좌우 화살표로 주 전환)
  - "채운 물양" 라벨 + ml 수치 (#48C7FF, 40pt Bold)
  - 유리컵 이미지 (물 높이 = 채운량/목표량 비율)
  - 하단 2열: 이번주 목표량 / 총 공부 시간
  - 우하단: 캘린더 FAB 버튼
- [ ] HomeViewModel.swift
  - 주간 데이터 조회 (GET /sessions/weekly)
  - 주 전환 로직
  - 물양/시간 계산

### 5.2 캘린더 뷰 (확장)
- [ ] CalendarView.swift: 월간 달력 + 날짜별 물양 표시

---

## Phase 6: 타이머 (핵심 기능)

### 6.1 컵 선택
- [ ] CupSelectionView.swift
  - 좌상단 로고
  - "얼음컵을 선택해주세요" (#48C7FF)
  - 3열 CupCard (Tall 초록 / Grande 파랑 / Venti 핑크)
  - 선택 시 카드 scale 애니메이션 + 테두리 강조
  - 하단: "시작하기" (미선택 시 비활성 #9E9E9E, 선택 시 활성)
- [ ] CupSelectionViewModel.swift: 선택 상태 관리

### 6.2 타이머 실행
- [ ] TimerRunningView.swift
  - 좌상단 로고
  - "{SIZE} 얼음컵" (#9E9E9E)
  - "집중을 유지하고 있습니다" (#48C7FF)
  - 얼음 녹는 컵 애니메이션 (IceMeltingView)
  - 하단 3버튼: 달(수면) / 재생·일시정지 / 정지(포기)
  - 시간/퍼센트 표시 금지
- [ ] TimerViewModel.swift
  - 랜덤 totalDuration 생성 (컵 사이즈 범위 내)
  - Timer 실행 (Combine Timer / async)
  - elapsedTime 추적
  - waterML 실시간 계산
  - 일시정지/재개/포기 처리
  - 완료 감지 (elapsedTime >= totalDuration)
  - 백그라운드 진입/복귀 시간 보정

### 6.3 얼음 애니메이션 (핵심 UX)
- [ ] IceMeltingView.swift
  - progress (0.0 ~ 1.0) 기반
  - 초기 (0.0~0.3): 얼음 가득, 약간의 물
  - 중간 (0.3~0.7): 얼음 줄어듦 + 물 증가
  - 후반 (0.7~1.0): 얼음 거의 없음, 물 가득
  - opacity + mask + scaleEffect 조합
  - 이미지 기반 또는 SwiftUI Shape 기반

### 6.4 타이머 결과
- [ ] TimerResultView.swift (완료)
  - "얼음이 모두 녹았습니다" (#212121)
  - "오늘의 물이 채워졌습니다" (#48C7FF)
  - "시원한 물 한잔은 어떨까요?" (#9E9E9E)
  - 물 컵 이미지
  - 2열: 녹인 물의 양 / 집중 시간
  - 체크 + "완료" 버튼 → 홈으로 이동 + API 호출
- [ ] TimerResultView.swift (포기)
  - 얼음 깨짐 표현
  - "중단되었습니다" 메시지
  - 부분 물양 + 시간 표시
  - API 호출 (abort)

### 6.5 세션 서비스
- [ ] SessionService.swift
  - POST /sessions: 세션 생성
  - PATCH /sessions/{id}/complete: 완료
  - PATCH /sessions/{id}/abort: 중단
  - GET /sessions/today: 오늘 데이터
  - GET /sessions/weekly: 주간 데이터

---

## Phase 7: 프로필 (마이)

### 7.1 프로필 화면
- [ ] ProfileView.swift
  - 네비: "마이" 중앙 + 설정(gear) 우측
  - 프로필: 원형 아이콘(#48C7FF) + 닉네임 + 이메일
  - "정보" 섹션: 3열 StatCard
    - 녹인 얼음 갯수 (개)
    - 총 물의 양 (ml)
    - 총 공부시간 (시간 분)
  - "히스토리" 섹션: WeeklyBarChart
    - 일일 평균 라벨
    - 7일 바 (월~일)
    - 평균선 점선
  - "로그아웃" 텍스트 버튼 (#F06292)
- [ ] ProfileViewModel.swift
  - 유저 정보 조회
  - 통계 데이터 조회/계산
  - 로그아웃 처리

### 7.2 설정
- [ ] SettingsView.swift: 알림, 목표 설정, 계정 관리

---

## Phase 8: 네트워크/인프라

### 8.1 네트워크
- [ ] APIClient.swift: URLSession 기반, 공통 요청/응답 처리
- [ ] APIEndpoint.swift: 엔드포인트 enum 정의
- [ ] APIError.swift: 에러 타입 정의
- [ ] TokenInterceptor.swift: Authorization 헤더 자동 주입

### 8.2 로컬 저장
- [ ] UserDefaultsManager.swift: 온보딩 완료 여부, 설정값
- [ ] @AppStorage 활용: 간단한 설정

---

## Phase 9: 앱 라우팅

### 9.1 화면 전환
- [ ] AppRouter.swift: 앱 상태 기반 루트 뷰 결정
  - 첫 실행 → 스플래시 → 온보딩 → 로그인
  - 재실행 (토큰 있음) → 스플래시 → 메인탭
  - 재실행 (토큰 없음) → 스플래시 → 로그인
- [ ] NavigationRouter.swift: 탭 내 화면 전환

---

## 개발 우선순위 요약

| 순서 | Phase | 핵심 |
|------|-------|------|
| 1 | 초기 설정 | 폴더, 에셋, 모델, 상수 |
| 2 | 공통 컴포넌트 | 탭바, 버튼, 카드, 로고 |
| 3 | 스플래시/온보딩 | 첫 진입 플로우 |
| 4 | 인증 | 로그인/가입 |
| 5 | 홈 | 양동이 대시보드 |
| 6 | 타이머 | 컵선택→실행→결과 (핵심) |
| 7 | 프로필 | 통계/차트 |
| 8 | 네트워크 | API 연동 |
| 9 | 라우팅 | 전체 플로우 연결 |

---

## 주의사항
- 타이머 화면: 시간/퍼센트 절대 표시 금지
- totalDuration: 사용자에게 노출 금지
- 백그라운드 전환 시 타이머 시간 보정 필수
- 컵 이미지: 에셋 사용 (SF Symbol 아님)
- 탭바 아이콘: SF Symbol 사용 (house.fill, cube.fill, person.fill)
- 모든 수치(ml, 시간): primary 컬러 (#48C7FF)

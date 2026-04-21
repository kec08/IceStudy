# IceStudy (얼공) - Design System

## 컬러 팔레트

### 기본 컬러

| 토큰 | Hex | 용도 |
|------|-----|------|
| primary | #48C7FF | 메인 블루, 로고, 강조 텍스트, 버튼, 수치(ml), 탭 활성 |
| textPrimary | #212121 | 제목, 본문, 주요 텍스트 |
| textSecondary | #9E9E9E | 보조 텍스트, placeholder, 비활성 탭 아이콘 |
| textTertiary | #BDBDBD | 힌트, 구분선 |
| background | #FFFFFF | 전체 배경 |
| surface | #F5F5F5 | 카드, 입력필드, 비활성 버튼 배경 |
| cardBackground | #F8FCFF | 통계 카드, 차트 배경 (연한 블루 틴트) |

### 컵 사이즈 컬러

| 사이즈 | 컬러 | Hex | 라벨 |
|--------|------|-----|------|
| TALL | 초록 | #8BC34A | 가벼운 공부 |
| GRANDE | 파랑 | #48C7FF | 집중 공부 |
| VENTI | 핑크 | #F06292 | 깊은 공부 |

### 기능 컬러

| 토큰 | Hex | 용도 |
|------|-----|------|
| danger | #F06292 | 로그아웃, 포기 |
| success | #48C7FF | 완료 체크 |
| chartBar | #48C7FF (opacity 0.7~1.0) | 주간 차트 바 |
| chartAvgLine | #48C7FF (opacity 0.5, dashed) | 일일 평균 점선 |

---

## 타이포그래피

### 폰트 스타일

| 스타일 | 크기 | 굵기 | 용도 |
|--------|------|------|------|
| largeTitle | 40pt | Bold | ml 수치 (1800ml, 3000ml) |
| title1 | 28pt | Bold | 화면 제목 ("로그인", "얼공") |
| title2 | 22pt | Bold | 섹션 제목 ("채운 물양"), 상태 메시지 |
| title3 | 18pt | Semibold | 컵 라벨 ("TALL"), 통계 수치 (300개) |
| headline | 16pt | Semibold | 주간 날짜, 정보 라벨 |
| body | 15pt | Regular | 본문 텍스트, 설명 |
| callout | 14pt | Regular | 보조 설명, "시원한 물 한잔은 어떨까요?" |
| caption | 12pt | Regular | 탭바 라벨, 소제목 ("녹인 얼음 갯수") |

### 컬러별 텍스트 적용

| 텍스트 유형 | 컬러 | 예시 |
|------------|------|------|
| 수치 강조 | primary (#48C7FF) | "1800ml", "5시간 3분", "3000ml" |
| 상태 메시지 | primary (#48C7FF) | "집중을 유지하고 있습니다", "오늘의 물이 채워졌습니다" |
| 일반 제목 | textPrimary (#212121) | "채운 물양", "얼음이 모두 녹았습니다", "정보" |
| 보조/설명 | textSecondary (#9E9E9E) | "시원한 물 한잔은 어떨까요?", "kec4489@icloud.com" |
| 비활성 버튼 | textTertiary (#BDBDBD) | 로그인 버튼(비활성) |
| 링크/액션 | primary (#48C7FF) | "회원가입", "로그아웃" |

---

## 컴포넌트

### 버튼

| 타입 | 배경 | 텍스트 | 모서리 | 높이 | 사용처 |
|------|------|--------|--------|------|--------|
| Primary | #48C7FF | #FFFFFF, 16pt Bold | 14pt radius | 52pt | "시작하기", 온보딩 CTA |
| Secondary | #F5F5F5 | #BDBDBD, 16pt Bold | 14pt radius | 52pt | "로그인" (비활성) |
| Outline | transparent | #212121, 16pt Semibold | 14pt radius, 1pt border #212121 | 52pt | "Apple 계정으로 계속하기" |
| Text | transparent | #48C7FF, 14pt Regular | 없음 | auto | "회원가입", "로그아웃" |
| Icon Circle | #48C7FF | 아이콘 #FFFFFF | 원형 | 56pt | 재생 버튼 (타이머) |
| Icon Circle Gray | #E0E0E0 | 아이콘 #9E9E9E | 원형 | 48pt | 달/정지 버튼 (타이머) |

### 카드

| 타입 | 배경 | 모서리 | 그림자 | 사용처 |
|------|------|--------|--------|--------|
| 통계 카드 | #FFFFFF | 12pt radius | 0.5pt, color #00000010 | 프로필 정보 카드 (3열) |
| 컵 선택 카드 | #FFFFFF | 16pt radius | 1pt, color #00000008 | 컵 사이즈 선택 |
| 차트 카드 | #F8FCFF | 16pt radius | 없음 | 주간 히스토리 |

### 입력 필드

| 속성 | 값 |
|------|-----|
| 높이 | 48pt |
| 하단 보더 | 1pt, #E0E0E0 |
| placeholder 색 | #BDBDBD |
| 입력 텍스트 | #212121, 15pt Regular |
| 라벨 | #9E9E9E, 12pt Regular |

### 탭바

| 속성 | 값 |
|------|-----|
| 배경 | #FFFFFF, 상단 그림자 |
| 높이 | 83pt (safe area 포함) |
| 탭 수 | 3개 (양동이/홈, 얼음, 마이) |
| 활성 아이콘 | #48C7FF |
| 비활성 아이콘 | #BDBDBD |
| 라벨 크기 | 10pt Regular |

### 탭 아이콘 매핑

| 탭 | 활성 라벨 | 아이콘 (SF Symbol 대체) |
|----|----------|----------------------|
| 홈 | 양동이 / 홈 | house.fill |
| 얼음 | 얼음 | cube.fill |
| 마이 | 마이 | person.fill |

### 네비게이션 바

| 속성 | 값 |
|------|-----|
| 배경 | transparent / #FFFFFF |
| 좌측 | 뒤로가기 chevron.left (#212121) |
| 중앙 | 로고 "얼공" (#48C7FF, Bold) 또는 타이틀 |
| 우측 | 설정 gear (#212121) - 프로필만 |

---

## 레이아웃

### 간격 체계

| 토큰 | 값 | 용도 |
|------|-----|------|
| spacing-xs | 4pt | 아이콘-텍스트 간격 |
| spacing-sm | 8pt | 카드 내부 요소 |
| spacing-md | 16pt | 섹션 간 |
| spacing-lg | 24pt | 화면 좌우 패딩 |
| spacing-xl | 32pt | 섹션 블록 간 |
| spacing-xxl | 48pt | 주요 요소 간 (컵 이미지-버튼) |

### 화면 기본 구조

| 영역 | 값 |
|------|-----|
| 좌우 패딩 | 24pt |
| 상단 safe area | 기본 |
| 하단 탭바 | 83pt |
| 컵 이미지 영역 | 화면 너비 70~80% |

---

## 화면별 레이아웃 상세

### 1. 스플래시
- 중앙 정렬: 얼음 큐브 아이콘 (120x120pt)
- 아이콘 하단 20pt: "얼공" 로고 텍스트 (#48C7FF, 36pt Bold)
- 배경: #FFFFFF

### 2. 온보딩
- 좌상단: 얼음 아이콘(28pt) + "얼공" 텍스트 (#48C7FF, 24pt Bold)
- 아이콘 하단 8pt: "언제 녹을지 모르는 얼음" (#212121, 15pt)
- 하단 4pt: "전부 녹을 때까지 집중해보세요" (#212121, 15pt)
- 중앙: 얼음 가득 컵 이미지 (너비 60%)
- 하단 고정: "시작하기" Primary 버튼 (좌우 24pt 패딩)

### 3. 로그인
- 상단 네비바: 뒤로(<) + "얼공" 로고
- "로그인" 타이틀 (#212121, 28pt Bold)
- 설명 텍스트 2줄 (#212121, 15pt)
- Apple 로그인 Outline 버튼
- 구분선 (좌우 여백 80pt)
- "로그인" 소제목 (#212121, 20pt Semibold, 중앙)
- 이메일 입력필드
- 비밀번호 입력필드
- 하단: "아직 회원이 아니신가요?" (#9E9E9E) + "회원가입" (#48C7FF)
- 최하단: "로그인" Secondary 버튼

### 4. 홈 (양동이)
- 좌상단: 얼음 아이콘 + "얼공" 로고
- 주간 네비: < "2025년 1월 첫째주" > (#212121, 16pt Semibold)
- "채운 물양" (#212121, 16pt Semibold, 중앙)
- 수치: "1800ml" (#48C7FF, 40pt Bold, 중앙)
- 유리컵 이미지 (너비 65%)
- 하단 2열: "이번주 목표량" 3000ml / "총 공부 시간" 5시간 3분
- 우하단: 캘린더 FAB 버튼 (#48C7FF, 원형 48pt)

### 5. 컵 선택
- 좌상단: 얼음 아이콘 + "얼공" 로고
- "얼음컵을 선택해주세요" (#48C7FF, 22pt Bold, 중앙)
- 3열 카드 (균등 분배):
  - 컵 이미지 (80x80pt)
  - 사이즈명 (#212121, 14pt Semibold)
  - 라벨 (컵별 컬러, 13pt)
  - ml 수치 (컵별 컬러, 18pt Bold)
- 하단: 재생 아이콘 + "시작하기" (#9E9E9E, 20pt) - 컵 선택 전 비활성

### 6. 타이머 실행중
- 좌상단: 얼음 아이콘 + "얼공" 로고
- "TALL 얼음컵" (#9E9E9E, 16pt)
- "집중을 유지하고 있습니다" (#48C7FF, 22pt Bold)
- 얼음 컵 애니메이션 (너비 75%)
- 하단 3버튼 (수평 중앙, 간격 48pt):
  - 달(수면) - Icon Circle Gray 48pt
  - 재생/일시정지 - Icon Circle Primary 56pt
  - 정지(포기) - Icon Circle Gray 48pt

### 7. 타이머 결과 (완료)
- 좌상단: 얼음 아이콘 + "얼공" 로고
- "얼음이 모두 녹았습니다" (#212121, 18pt Semibold)
- "오늘의 물이 채워졌습니다" (#48C7FF, 24pt Bold)
- "시원한 물 한잔은 어떨까요?" (#9E9E9E, 14pt)
- 물 컵 이미지 (너비 70%)
- 2열: "녹인 물의 양" 3000ml / "집중 시간" 5시간 3분
- 체크 아이콘 + "완료" (#48C7FF, 20pt Bold)

### 8. 프로필 (마이)
- 상단 네비: "마이" 중앙 + 설정(gear) 우측
- 프로필 영역: 원형 아이콘(56pt, #48C7FF 배경) + 닉네임 + 이메일
- "정보" 섹션 (#212121, 16pt Bold)
- 3열 통계 카드:
  - 얼음 아이콘 + "녹인 얼음 갯수" + 수치
  - 물방울 아이콘 + "총 물의 양" + 수치
  - 시계 아이콘 + "총 공부시간" + 수치
- "히스토리" 섹션
- 주간 바 차트 카드:
  - "일일 평균" 라벨 + 시간
  - 7개 바 (월~일), 평균선 점선
- 하단: "로그아웃" 텍스트 버튼 (#F06292)

---

## 애니메이션

| 요소 | 타입 | 속성 |
|------|------|------|
| 스플래시 로고 | scale + fade | 0.8→1.0, opacity 0→1, 0.8s easeOut |
| 얼음 녹기 | opacity + mask | 시간 비례 점진적 변화 |
| 컵 선택 카드 | scale | 선택 시 1.0→1.05, 0.2s spring |
| 탭 전환 | fade | 0.25s easeInOut |
| 버튼 press | scale | 1.0→0.95, 0.1s |
| 차트 바 | height | 0→target, 0.5s easeOut, stagger 0.05s |
| 완료 체크 | scale + rotate | 0→1, 0.3s spring |

---

## 이미지 에셋 목록

| 에셋명 | 파일 | 사용처 |
|--------|------|--------|
| 앱 아이콘 | 앱 아이콘.png | AppIcon |
| 로고 텍스트 | 얼공_text_logo.png | 네비바, 스플래시 |
| 얼음 이미지 | ice_img.png | 온보딩, 아이콘 |
| Tall 컵 | Tall Cup.png | 컵 선택 |
| Grande 컵 | Grande Cup.png | 컵 선택 |
| Venti 컵 | Venti Cup.png | 컵 선택 |
| 컵 아이콘 | mdi_cup.svg | 탭바 대체용 |
| 컵 아이콘(블루) | mdi_cup_blue.png | 활성 탭 |
| 시계 | clock.png | 프로필 통계 |
| 캘린더 | calendar.svg | 홈 FAB |
| 홈 | material-symbols_home-rounded.svg | 탭바 |
| 큐브 | famicons_cube.svg | 탭바 |
| 유저 | solar_user-bold.svg | 탭바 |

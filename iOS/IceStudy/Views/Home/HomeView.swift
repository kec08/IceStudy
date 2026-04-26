import SwiftUI
import WidgetKit

struct WeekData {
    var filledML: Int = 0
    var goalML: Int = 3000
    var totalMinutes: Int = 0
}

struct HomeView: View {
    @Binding var needsRefresh: Bool
    @State private var weekOffset: Int = 0
    @State private var showCalendar = false
    @State private var slideDirection: Edge = .leading
    @State private var isLoading = false

    // 주별 캐시 [weekOffset: WeekData]
    @State private var weekCache: [Int: WeekData] = [:]

    // 카운트업 애니메이션용
    @State private var displayFilledML: Int = 0
    @State private var displayGoalML: Int = 0
    @State private var displayTotalHours: Int = 0
    @State private var displayTotalMinutes: Int = 0

    private var currentData: WeekData {
        weekCache[weekOffset] ?? WeekData()
    }

    private var filledML: Int { currentData.filledML }
    private var goalML: Int { currentData.goalML }
    private var totalHours: Int { currentData.totalMinutes / 60 }
    private var totalMinutes: Int { currentData.totalMinutes % 60 }

    private var isGoalExceeded: Bool {
        filledML > goalML && goalML > 0
    }

    @State private var animatedFillRatio: CGFloat = 0
    @State private var goldFillRatio: CGFloat = 0

    private var fillRatio: CGFloat {
        guard goalML > 0 else { return 0 }
        return min(CGFloat(filledML) / CGFloat(goalML), 1.0)
    }

    // weekOffset 기반 결정적 랜덤 목표량 (1500~3000ml)
    private func goalForWeek(_ offset: Int) -> Int {
        var hasher = Hasher()
        hasher.combine(offset)
        hasher.combine(2026)
        let hash = abs(hasher.finalize())
        return 1500 + (hash % 1501) // 1500 ~ 3000
    }

    private var weekLabel: String {
        let calendar = Calendar.current
        let today = Date()
        // 이번주 월요일 구하기
        let weekday = calendar.component(.weekday, from: today)
        let daysToMonday = (weekday == 1) ? -6 : (2 - weekday)
        let thisMonday = calendar.date(byAdding: .day, value: daysToMonday, to: today)!
        let monday = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: thisMonday)!
        let sunday = calendar.date(byAdding: .day, value: 6, to: monday)!

        let startMonth = calendar.component(.month, from: monday)
        let startDay = calendar.component(.day, from: monday)
        let endMonth = calendar.component(.month, from: sunday)
        let endDay = calendar.component(.day, from: sunday)

        let year = calendar.component(.year, from: monday)

        if startMonth == endMonth {
            return "\(year)년 \(startMonth)월 \(startDay)일 ~ \(endDay)일"
        } else {
            return "\(year)년 \(startMonth)월 \(startDay)일 ~ \(endMonth)월 \(endDay)일"
        }
    }

    var body: some View {
        ZStack {
            AppColor.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    LogoHeaderView()
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, -4)
                .padding(.bottom, 30)

                weekNavigator
                    .padding(.top, 14)

                weekContent
                    .id(weekOffset)
                    .transition(.asymmetric(
                        insertion: .move(edge: slideDirection),
                        removal: .move(edge: slideDirection == .leading ? .trailing : .leading)
                    ))
                    .animation(.easeInOut(duration: 0.3), value: weekOffset)

                HStack {
                    Spacer()
                    calendarFAB
                        .padding(.trailing, 24)
                }
                .padding(.top, 16)
                .padding(.bottom, 12)
            }
        }
        .fullScreenCover(isPresented: $showCalendar) {
            StudyCalendarView()
        }
        .task(id: weekOffset) {
            await fetchWeeklyStats(for: weekOffset)
        }
        .onChange(of: filledML) {
            goldFillRatio = 0
            animateCountUp()
            withAnimation(.easeOut(duration: 1.2)) {
                animatedFillRatio = fillRatio
            }
            // 목표 초과 시 다음 프레임에서 금색 올라오기
            if isGoalExceeded {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    withAnimation(.easeOut(duration: 1)) {
                        goldFillRatio = fillRatio
                    }
                }
            }
        }
        .onChange(of: goalML) { animateCountUp() }
        .onChange(of: totalMinutes) { animateCountUp() }
        .onChange(of: needsRefresh) { _, refresh in
            if refresh {
                needsRefresh = false
                weekOffset = 0
                Task {
                    await fetchWeeklyStats(for: 0)
                }
            }
        }
    }

    // MARK: - 카운트업 애니메이션
    @State private var countUpTimer: Timer?

    private func animateCountUp() {
        countUpTimer?.invalidate()

        let fromFilledML = displayFilledML
        let fromGoalML = displayGoalML
        let fromHours = displayTotalHours
        let fromMinutes = displayTotalMinutes
        let targetFilledML = filledML
        let targetGoalML = goalML
        let targetHours = totalHours
        let targetMinutes = totalMinutes

        let steps = 30
        var currentStep = 0
        let interval = 0.8 / Double(steps)

        countUpTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            currentStep += 1
            let fraction = Double(currentStep) / Double(steps)
            let eased = 1 - pow(1 - fraction, 3)

            displayFilledML = fromFilledML + Int(Double(targetFilledML - fromFilledML) * eased)
            displayGoalML = fromGoalML + Int(Double(targetGoalML - fromGoalML) * eased)
            displayTotalHours = fromHours + Int(Double(targetHours - fromHours) * eased)
            displayTotalMinutes = fromMinutes + Int(Double(targetMinutes - fromMinutes) * eased)

            if currentStep >= steps {
                timer.invalidate()
            }
        }
    }

    // MARK: - API
    private func fetchWeeklyStats(for offset: Int) async {
        isLoading = true
        let existingGoal = weekCache[offset]?.goalML ?? goalForWeek(offset)
        do {
            let stats = try await StatsService.shared.fetchWeekly(weekOffset: offset)
            withAnimation(.easeInOut(duration: 0.5)) {
                weekCache[offset] = WeekData(
                    filledML: Int(stats.filledMl),
                    goalML: existingGoal,
                    totalMinutes: stats.totalMinutes
                )
            }

            // 위젯 데이터 저장 (현재 보고 있는 주가 이번 주일 때)
            if offset == 0 {
                let weeklyMinutes = stats.dailyStats?.map { $0.totalMinutes } ?? [0, 0, 0, 0, 0, 0, 0]
                let widgetData = WidgetData(
                    filledMl: Int(stats.filledMl),
                    goalMl: existingGoal,
                    totalMinutes: stats.totalMinutes,
                    weeklyMinutes: weeklyMinutes,
                    lastUpdated: Date()
                )
                WidgetDataStore.save(widgetData)
                WidgetCenter.shared.reloadAllTimelines()
                print("[Widget] 데이터 저장: \(Int(stats.filledMl))ml, \(stats.totalMinutes)분")
            }
        } catch {
            if weekCache[offset] == nil {
                weekCache[offset] = WeekData(goalML: existingGoal)
            }
        }
        isLoading = false
    }

    // MARK: - 주간 콘텐츠
    private var weekContent: some View {
        VStack(spacing: 0) {
            waterAmountSection
                .padding(.top, 12)

            glassCupSection
                .padding(.top, 0)

            bottomStats
                .padding(.horizontal, 24)
                .padding(.top, -4)
        }
    }

    // MARK: - 주간 네비게이터
    private var weekNavigator: some View {
        HStack {
            Button {
                slideDirection = .leading
                withAnimation(.easeInOut(duration: 0.3)) {
                    weekOffset -= 1
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppColor.textPrimary)
            }

            Spacer()

            Text(weekLabel)
                .font(AppFont.headline())
                .foregroundColor(AppColor.textPrimary)

            Spacer()

            Button {
                if weekOffset < 0 {
                    slideDirection = .trailing
                    withAnimation(.easeInOut(duration: 0.3)) {
                        weekOffset += 1
                    }
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(weekOffset < 0 ? AppColor.textPrimary : AppColor.textTertiary)
            }
            .disabled(weekOffset >= 0)
        }
        .padding(.bottom, 14)
        .padding(.horizontal, 24)
    }

    // MARK: - 채운 물양 섹션
    private var waterAmountSection: some View {
        VStack(spacing: 8) {
            Text("채운 물양")
                .font(AppFont.headline())
                .foregroundColor(AppColor.textPrimary)

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("\(displayFilledML)")
                    .font(AppFont.largeTitle())
                    .foregroundColor(goldFillRatio > 0 ? Color(hex: "FFB300") : AppColor.primary)
                Text("ml")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(goldFillRatio > 0 ? Color(hex: "FFB300") : AppColor.primary)
            }
        }
    }

    // MARK: - 유리 양동이 (디테일)
    private var glassCupSection: some View {
        GeometryReader { geo in
            let cupWidth = geo.size.width * 0.58
            let cupHeight = cupWidth * 1.08

            ZStack {
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [Color.black.opacity(0.06), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: cupWidth * 0.45
                        )
                    )
                    .frame(width: cupWidth * 0.7, height: 16)
                    .offset(y: cupHeight * 0.52)

                GlassCupShape()
                    .fill(Color(hex: "D8F0FF").opacity(0.04))
                    .frame(width: cupWidth, height: cupHeight)

                if fillRatio > 0 {
                    // 파란 물 (금색 올라오면 사라짐)
                    GlassCupShape()
                        .fill(
                            LinearGradient(
                                colors: [
                                    AppColor.primary.opacity(0.18),
                                    AppColor.primary.opacity(0.26),
                                    AppColor.primary.opacity(0.32)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: cupWidth, height: cupHeight)
                        .mask(
                            Rectangle()
                                .frame(height: cupHeight)
                                .frame(height: cupHeight, alignment: .bottom)
                                .offset(y: cupHeight * (1.0 - animatedFillRatio))
                        )
                        .opacity(goldFillRatio > 0 ? 0 : 1)
                        .animation(.easeOut(duration: 0.5), value: goldFillRatio)

                    // 금색 물 (목표 초과 시 밑에서 스르륵)
                    if goldFillRatio > 0 {
                        GlassCupShape()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "FFD700").opacity(0.25),
                                        Color(hex: "FFC107").opacity(0.38),
                                        Color(hex: "FFB300").opacity(0.48)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: cupWidth, height: cupHeight)
                            .mask(
                                Rectangle()
                                    .frame(height: cupHeight)
                                    .frame(height: cupHeight, alignment: .bottom)
                                    .offset(y: cupHeight * (1.0 - goldFillRatio))
                            )
                    }
                }

                GlassCupShape()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(hex: "C6E8F9").opacity(0.7),
                                Color(hex: "A0D4ED").opacity(0.4),
                                Color(hex: "C6E8F9").opacity(0.5)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                    .frame(width: cupWidth, height: cupHeight)

                GlassCupShape()
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.35), Color.white.opacity(0.0)],
                            startPoint: .topLeading,
                            endPoint: .center
                        )
                    )
                    .frame(width: cupWidth, height: cupHeight)
                    .mask(
                        HStack {
                            Rectangle().frame(width: cupWidth * 0.35)
                            Spacer()
                        }.frame(width: cupWidth)
                    )

                GlassCupShape()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.0),
                                Color.white.opacity(0.25),
                                Color.white.opacity(0.0)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 2.5
                    )
                    .frame(width: cupWidth, height: cupHeight)
                    .mask(
                        HStack {
                            Spacer()
                            Rectangle().frame(width: cupWidth * 0.15)
                        }.frame(width: cupWidth)
                    )

                Ellipse()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "C0E4F5").opacity(0.2),
                                Color(hex: "D6EDFA").opacity(0.1)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: cupWidth * 0.48, height: 12)
                    .offset(y: cupHeight * 0.42)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: 340)
    }

    // MARK: - 하단 통계
    private var bottomStats: some View {
        HStack {
            VStack(spacing: 4) {
                Text("이번주 목표량")
                    .font(AppFont.callout())
                    .foregroundColor(AppColor.textPrimary)
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(displayGoalML)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(AppColor.primary)
                    Text("ml")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppColor.primary)
                }
            }
            .frame(maxWidth: .infinity)

            VStack(spacing: 4) {
                Text("이번주 공부 시간")
                    .font(AppFont.callout())
                    .foregroundColor(AppColor.textPrimary)
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(displayTotalHours)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(AppColor.primary)
                    Text("시간")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppColor.primary)
                    Text("\(displayTotalMinutes)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(AppColor.primary)
                    Text("분")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppColor.primary)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - 캘린더 FAB
    private var calendarFAB: some View {
        Button {
            showCalendar = true
        } label: {
            ZStack {
                Circle()
                    .fill(AppColor.primary.opacity(0.12))
                    .frame(width: 60, height: 60)
                Image(systemName: "calendar")
                    .font(.system(size: 26))
                    .foregroundColor(AppColor.primary)
            }
        }
    }
}

#Preview {
    HomeView(needsRefresh: .constant(false))
}

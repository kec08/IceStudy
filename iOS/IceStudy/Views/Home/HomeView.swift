import SwiftUI

struct HomeView: View {
    @State private var weekOffset: Int = 0
    @State private var showCalendar = false
    @State private var slideDirection: Edge = .leading

    // 주간별 임시 데이터 (weekOffset 기반)
    private var weekData: (filledML: Int, goalML: Int, totalMinutes: Int) {
        // 해시 기반으로 주마다 다른 데이터
        let seed = abs(weekOffset * 7 + 42)
        let base = weekOffset == 0 ? 1800 : (800 + (seed * 137) % 2200)
        let goal = 3000
        let minutes = Int(Double(base) / 355.0 * 60.0)
        return (base, goal, minutes)
    }

    private var filledML: Int { weekData.filledML }
    private var goalML: Int { weekData.goalML }
    private var totalHours: Int { weekData.totalMinutes / 60 }
    private var totalMinutes: Int { weekData.totalMinutes % 60 }

    private var fillRatio: CGFloat {
        min(CGFloat(filledML) / CGFloat(goalML), 1.0)
    }

    private var weekLabel: String {
        let calendar = Calendar.current
        let today = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: Date()) ?? Date()
        let year = calendar.component(.year, from: today)
        let month = calendar.component(.month, from: today)
        let weekOfMonth = calendar.component(.weekOfMonth, from: today)

        let weekNames = ["첫째주", "둘째주", "셋째주", "넷째주", "다섯째주"]
        let weekName = weekOfMonth <= weekNames.count ? weekNames[weekOfMonth - 1] : "\(weekOfMonth)주"
        return "\(year)년 \(month)월 \(weekName)"
    }

    var body: some View {
        ZStack {
            AppColor.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // 상단 로고
                HStack {
                    LogoHeaderView()
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, -4)
                .padding(.bottom, 30)

                // 주간 네비게이션
                weekNavigator
                    .padding(.top, 14)

                // 주간 콘텐츠 (슬라이드 전환)
                weekContent
                    .id(weekOffset)
                    .transition(.asymmetric(
                        insertion: .move(edge: slideDirection),
                        removal: .move(edge: slideDirection == .leading ? .trailing : .leading)
                    ))
                    .animation(.easeInOut(duration: 0.3), value: weekOffset)

                // 캘린더 FAB
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
    }

    // MARK: - 주간 콘텐츠
    private var weekContent: some View {
        VStack(spacing: 0) {
            // 채운 물양
            waterAmountSection
                .padding(.top, 12)

            // 양동이 (유리컵)
            glassCupSection
                .padding(.top, 0)

            // 하단 통계
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
                Text("\(filledML)")
                    .font(AppFont.largeTitle())
                    .foregroundColor(AppColor.primary)
                Text("ml")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppColor.primary)
            }
        }
    }

    // MARK: - 유리 양동이 (디테일)
    private var glassCupSection: some View {
        GeometryReader { geo in
            let cupWidth = geo.size.width * 0.58
            let cupHeight = cupWidth * 1.08

            ZStack {
                // 1) 컵 바닥 그림자
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.black.opacity(0.06),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: cupWidth * 0.45
                        )
                    )
                    .frame(width: cupWidth * 0.7, height: 16)
                    .offset(y: cupHeight * 0.52)

                // 2) 컵 외형
                GlassCupShape()
                    .fill(Color(hex: "D8F0FF").opacity(0.04))
                    .frame(width: cupWidth, height: cupHeight)

                // 3) 물 채움
                if fillRatio > 0 {
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
                                .offset(y: cupHeight * (1.0 - fillRatio))
                        )
                }

                // 4) 컵 외곽선 (유리 테두리)
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

                // 5) 유리 반사 하이라이트 (좌측)
                GlassCupShape()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.35),
                                Color.white.opacity(0.0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .center
                        )
                    )
                    .frame(width: cupWidth, height: cupHeight)
                    .mask(
                        HStack {
                            Rectangle()
                                .frame(width: cupWidth * 0.35)
                            Spacer()
                        }
                        .frame(width: cupWidth)
                    )

                // 6) 우측 엣지 반사
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
                            Rectangle()
                                .frame(width: cupWidth * 0.15)
                        }
                        .frame(width: cupWidth)
                    )

                // 7) 바닥 두께감
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
                    Text("\(goalML)")
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
                    Text("\(totalHours)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(AppColor.primary)
                    Text("시간")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppColor.primary)
                    Text("\(totalMinutes)")
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
    HomeView()
}

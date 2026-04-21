import SwiftUI

struct HomeView: View {
    @State private var weekOffset: Int = 0
    @State private var showCalendar = false

    // 임시 데이터
    private let filledML: Int = 1800
    private let goalML: Int = 3000
    private let totalHours: Int = 5
    private let totalMinutes: Int = 3

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
                .padding(.top, 16)

                // 주간 네비게이션
                weekNavigator
                    .padding(.top, 20)

                // 채운 물양
                waterAmountSection
                    .padding(.top, 20)

                // 양동이 (유리컵)
                glassCupSection
                    .padding(.top, 8)

                Spacer(minLength: 4)

                // 하단 통계
                bottomStats
                    .padding(.horizontal, 24)

                // 캘린더 FAB
                HStack {
                    Spacer()
                    calendarFAB
                        .padding(.trailing, 24)
                }
                .padding(.top, 8)
                .padding(.bottom, 12)
            }
        }
        .fullScreenCover(isPresented: $showCalendar) {
            StudyCalendarView()
        }
    }

    // MARK: - 주간 네비게이터
    private var weekNavigator: some View {
        HStack {
            Button {
                weekOffset -= 1
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
                    weekOffset += 1
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(weekOffset < 0 ? AppColor.textPrimary : AppColor.textTertiary)
            }
            .disabled(weekOffset >= 0)
        }
        .padding(.horizontal, 24)
    }

    // MARK: - 채운 물양 섹션
    private var waterAmountSection: some View {
        VStack(spacing: 4) {
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

                // 2) 컵 외형 (거의 투명)
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

                // 5) 컵 외곽선 (유리 테두리)
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

                // 6) 유리 반사 하이라이트 (좌측)
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

                // 7) 우측 엣지 반사
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

                // 8) 바닥 두께감
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
                Text("총 공부 시간")
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

// MARK: - 유리컵 Shape (위가 넓고 아래가 좁은 실제 컵 형태)
struct GlassCupShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let topInset: CGFloat = rect.width * 0.02
        let bottomInset: CGFloat = rect.width * 0.14
        let cornerRadius: CGFloat = rect.width * 0.08
        let bottomCorner: CGFloat = rect.width * 0.10

        // 시작: 좌상단
        path.move(to: CGPoint(x: topInset + cornerRadius, y: 0))

        // 상단 직선
        path.addLine(to: CGPoint(x: rect.width - topInset - cornerRadius, y: 0))

        // 우상단 코너
        path.addQuadCurve(
            to: CGPoint(x: rect.width - topInset, y: cornerRadius),
            control: CGPoint(x: rect.width - topInset, y: 0)
        )

        // 우측 라인 (안쪽으로 좁아짐)
        path.addLine(to: CGPoint(x: rect.width - bottomInset, y: rect.height - bottomCorner))

        // 우하단 코너
        path.addQuadCurve(
            to: CGPoint(x: rect.width - bottomInset - bottomCorner, y: rect.height),
            control: CGPoint(x: rect.width - bottomInset, y: rect.height)
        )

        // 하단 직선
        path.addLine(to: CGPoint(x: bottomInset + bottomCorner, y: rect.height))

        // 좌하단 코너
        path.addQuadCurve(
            to: CGPoint(x: bottomInset, y: rect.height - bottomCorner),
            control: CGPoint(x: bottomInset, y: rect.height)
        )

        // 좌측 라인 (위로 넓어짐)
        path.addLine(to: CGPoint(x: topInset, y: cornerRadius))

        // 좌상단 코너
        path.addQuadCurve(
            to: CGPoint(x: topInset + cornerRadius, y: 0),
            control: CGPoint(x: topInset, y: 0)
        )

        path.closeSubpath()
        return path
    }
}

#Preview {
    HomeView()
}

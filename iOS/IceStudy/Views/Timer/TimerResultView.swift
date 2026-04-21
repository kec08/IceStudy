import SwiftUI

struct TimerResultView: View {
    @Bindable var viewModel: TimerViewModel
    let isCompleted: Bool

    var body: some View {
        ZStack {
            AppColor.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // 로고
                HStack {
                    LogoHeaderView()
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                Spacer()

                // 상태 메시지
                if isCompleted {
                    completedHeader
                } else {
                    abortedHeader
                }

                // 컵 이미지 (완료: 물만 / 포기: 깨진 얼음)
                resultCupView
                    .frame(height: 280)
                    .padding(.horizontal, 24)
                    .padding(.top, 8)

                // 통계
                resultStats
                    .padding(.top, 16)
                    .padding(.horizontal, 24)

                Spacer()

                // 완료/확인 버튼
                Button {
                    viewModel.reset()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: isCompleted ? "checkmark" : "arrow.uturn.left")
                            .font(.system(size: 18, weight: .bold))
                        Text(isCompleted ? "완료" : "돌아가기")
                            .font(.system(size: 20, weight: .bold))
                    }
                    .foregroundColor(AppColor.primary)
                }
                .padding(.bottom, 24)
            }
        }
    }

    // MARK: - 완료 헤더
    private var completedHeader: some View {
        VStack(spacing: 6) {
            Text("얼음이 모두 녹았습니다")
                .font(AppFont.title3())
                .foregroundColor(AppColor.textPrimary)

            Text("오늘의 물이 채워졌습니다")
                .font(AppFont.title2())
                .foregroundColor(AppColor.primary)

            Text("시원한 물 한잔은 어떨까요?")
                .font(AppFont.callout())
                .foregroundColor(AppColor.textSecondary)
                .padding(.top, 2)
        }
    }

    // MARK: - 포기 헤더
    private var abortedHeader: some View {
        VStack(spacing: 6) {
            Text("집중이 중단되었습니다")
                .font(AppFont.title3())
                .foregroundColor(AppColor.textPrimary)

            Text("다음엔 더 오래 집중해봐요")
                .font(AppFont.title2())
                .foregroundColor(AppColor.textSecondary)
        }
    }

    // MARK: - 결과 컵
    private var resultCupView: some View {
        GeometryReader { geo in
            let cupWidth = geo.size.width * 0.65
            let cupHeight = cupWidth * 1.1
            let level: CGFloat = isCompleted ? 0.9 : viewModel.progress * 0.9

            ZStack {
                // 바닥 그림자
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [.black.opacity(0.05), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: cupWidth * 0.4
                        )
                    )
                    .frame(width: cupWidth * 0.65, height: 14)
                    .offset(y: cupHeight * 0.52)

                // 컵 유리
                GlassCupShape()
                    .fill(Color(hex: "D8F0FF").opacity(0.04))
                    .frame(width: cupWidth, height: cupHeight)

                // 물
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
                            .offset(y: cupHeight * (1.0 - level))
                    )

                // 포기 시 깨진 얼음 조각
                if !isCompleted {
                    brokenIceOverlay(cupWidth: cupWidth, cupHeight: cupHeight)
                }

                // 외곽선
                GlassCupShape()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(hex: "C6E8F9").opacity(0.7),
                                Color(hex: "A0D4ED").opacity(0.35),
                                Color(hex: "C6E8F9").opacity(0.5)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                    .frame(width: cupWidth, height: cupHeight)

                // 유리 반사
                GlassCupShape()
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.3), Color.white.opacity(0.0)],
                            startPoint: .topLeading,
                            endPoint: .center
                        )
                    )
                    .frame(width: cupWidth, height: cupHeight)
                    .mask(
                        HStack {
                            Rectangle().frame(width: cupWidth * 0.28)
                            Spacer()
                        }.frame(width: cupWidth)
                    )

                // 바닥 두께
                Ellipse()
                    .fill(Color(hex: "C0E4F5").opacity(0.15))
                    .frame(width: cupWidth * 0.45, height: 10)
                    .offset(y: cupHeight * 0.44)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // 깨진 얼음 (포기 시)
    private func brokenIceOverlay(cupWidth: CGFloat, cupHeight: CGFloat) -> some View {
        ZStack {
            brokenIce(size: 14, rotation: 25)
                .offset(x: -cupWidth * 0.08, y: -cupHeight * 0.05)
            brokenIce(size: 10, rotation: -40)
                .offset(x: cupWidth * 0.10, y: -cupHeight * 0.1)
            brokenIce(size: 8, rotation: 60)
                .offset(x: 0, y: -cupHeight * 0.15)
        }
        .opacity(0.6)
    }

    private func brokenIce(size: CGFloat, rotation: Double) -> some View {
        IceTriangle()
            .fill(
                LinearGradient(
                    colors: [Color.white.opacity(0.7), Color(hex: "B8E6FA").opacity(0.4)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: size, height: size)
            .rotationEffect(.degrees(rotation))
    }

    // MARK: - 결과 통계
    private var resultStats: some View {
        HStack {
            VStack(spacing: 4) {
                Text("녹인 물의 양")
                    .font(AppFont.callout())
                    .foregroundColor(AppColor.textPrimary)
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(Int(viewModel.waterML))")
                        .font(.system(size: 28, weight: .bold))
                    Text("ml")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundColor(AppColor.primary)
            }
            .frame(maxWidth: .infinity)

            VStack(spacing: 4) {
                Text("집중 시간")
                    .font(AppFont.callout())
                    .foregroundColor(AppColor.textPrimary)
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(viewModel.elapsedHours)")
                        .font(.system(size: 28, weight: .bold))
                    Text("시간")
                        .font(.system(size: 14, weight: .bold))
                    Text("\(viewModel.elapsedMinutes)")
                        .font(.system(size: 28, weight: .bold))
                    Text("분")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(AppColor.primary)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - 깨진 얼음 삼각형 Shape
struct IceTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

#Preview("완료") {
    let vm = TimerViewModel()
    TimerResultView(viewModel: vm, isCompleted: true)
}

#Preview("포기") {
    let vm = TimerViewModel()
    TimerResultView(viewModel: vm, isCompleted: false)
}

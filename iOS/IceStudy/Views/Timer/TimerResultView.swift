import SwiftUI

struct TimerResultView: View {
    @Bindable var viewModel: TimerViewModel
    let isCompleted: Bool
    @State private var shareItem: ShareItem?

    private var waterML: Int { Int(viewModel.waterML) }
    private var hours: Int { viewModel.elapsedHours }
    private var minutes: Int { viewModel.elapsedMinutes }

    private var shareText: String {
        let timeStr = hours > 0 ? "\(hours)시간 \(minutes)분" : "\(minutes)분"
        return "\(waterML)ml 녹였고 \(timeStr) 집중했습니다.\n얼공 해볼까요? \u{1F9CA}"
    }

    var body: some View {
        ZStack {
            AppColor.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // 로고 + 공유 버튼
                HStack {
                    LogoHeaderView()
                    Spacer()
                    Button {
                        generateShareImage()
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(AppColor.primary)
                            .frame(width: 44, height: 44)
                    }
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

                // 컵 이미지
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
                    HStack(spacing: 12) {
                        Image(systemName: isCompleted ? "checkmark" : "arrow.uturn.left")
                            .font(.system(size: 22, weight: .bold))
                        Text(isCompleted ? "완료" : "돌아가기")
                            .font(.system(size: 26, weight: .bold))
                    }
                    .foregroundColor(AppColor.primary)
                }
                .padding(.bottom, 60)
            }
        }
        .sheet(item: $shareItem) { item in
            ShareSheet(items: [item.image, shareText])
        }
    }

    // MARK: - 공유 이미지 생성
    @State private var isGeneratingImage = false

    private func generateShareImage() {
        guard !isGeneratingImage else { return }
        isGeneratingImage = true

        Task {
            let card = ShareCardView(
                waterML: waterML,
                hours: hours,
                minutes: minutes,
                progress: isCompleted ? 0.9 : viewModel.iceVisualProgress * 0.9,
                isCompleted: isCompleted
            )

            let renderer = ImageRenderer(content: card)
            renderer.scale = 3.0

            // 1차 렌더링: 에셋 이미지 캐시 워밍
            _ = renderer.uiImage

            // 에셋 로드 대기
            try? await Task.sleep(nanoseconds: 400_000_000)

            // 2차 렌더링: 에셋 캐시 완료 상태에서 최종 이미지 생성
            if let image = renderer.uiImage {
                self.shareItem = ShareItem(image: image)
            }
            self.isGeneratingImage = false
        }
    }

    // MARK: - 완료 헤더
    private var completedHeader: some View {
        VStack(spacing: 10) {
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
        VStack(spacing: 16) {
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
            let level: CGFloat = isCompleted ? 0.9 : viewModel.iceVisualProgress * 0.9

            ZStack {
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [.black.opacity(0.05), .clear],
                            center: .center, startRadius: 0, endRadius: cupWidth * 0.4
                        )
                    )
                    .frame(width: cupWidth * 0.65, height: 14)
                    .offset(y: cupHeight * 0.52)

                GlassCupShape()
                    .fill(Color(hex: "D8F0FF").opacity(0.04))
                    .frame(width: cupWidth, height: cupHeight)

                GlassCupShape()
                    .fill(
                        LinearGradient(
                            colors: [
                                AppColor.primary.opacity(0.18),
                                AppColor.primary.opacity(0.26),
                                AppColor.primary.opacity(0.32)
                            ],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(width: cupWidth, height: cupHeight)
                    .mask(
                        Rectangle()
                            .frame(height: cupHeight)
                            .frame(height: cupHeight, alignment: .bottom)
                            .offset(y: cupHeight * (1.0 - level))
                    )

                if !isCompleted {
                    brokenIceOverlay(cupWidth: cupWidth, cupHeight: cupHeight)
                }

                GlassCupShape()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(hex: "C6E8F9").opacity(0.7),
                                Color(hex: "A0D4ED").opacity(0.35),
                                Color(hex: "C6E8F9").opacity(0.5)
                            ],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                    .frame(width: cupWidth, height: cupHeight)

                GlassCupShape()
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.3), Color.white.opacity(0.0)],
                            startPoint: .topLeading, endPoint: .center
                        )
                    )
                    .frame(width: cupWidth, height: cupHeight)
                    .mask(
                        HStack {
                            Rectangle().frame(width: cupWidth * 0.28)
                            Spacer()
                        }.frame(width: cupWidth)
                    )

                Ellipse()
                    .fill(Color(hex: "C0E4F5").opacity(0.15))
                    .frame(width: cupWidth * 0.45, height: 10)
                    .offset(y: cupHeight * 0.44)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

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
                    startPoint: .top, endPoint: .bottom
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
                    Text("\(waterML)")
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
                    Text("\(hours)")
                        .font(.system(size: 28, weight: .bold))
                    Text("시간")
                        .font(.system(size: 14, weight: .bold))
                    Text("\(minutes)")
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

// MARK: - 공유 카드 이미지 (인스타 스토리 9:16 비율)
struct ShareCardView: View {
    let waterML: Int
    let hours: Int
    let minutes: Int
    let progress: CGFloat
    let isCompleted: Bool

    private var timeStr: String {
        hours > 0 ? "\(hours)시간 \(minutes)분" : "\(minutes)분"
    }

    private var todayStr: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy.MM.dd"
        return f.string(from: Date())
    }

    var body: some View {
        ZStack {
            // 배경: 흰색 → 하단만 연한 블루
            LinearGradient(
                stops: [
                    .init(color: Color.white, location: 0.0),
                    .init(color: Color.white, location: 0.6),
                    .init(color: Color(hex: "EAF5FF"), location: 0.85),
                    .init(color: Color(hex: "D8EEFB"), location: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(spacing: 0) {
                Spacer()

                // 날짜
                Text(todayStr)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "9E9E9E"))
                    .padding(.bottom, 8)

                // 로고
                HStack(spacing: 8) {
                    Image("IceCube")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 34, height: 34)
                    Image("LogoText")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 20)
                }
                .padding(.bottom, 6)

                // 상태 메시지
                Text(isCompleted ? "얼음이 모두 녹았습니다" : "오늘도 공부했습니다")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color(hex: "666666"))
                    .padding(.bottom, 24)

                // 컵 시각화
                shareCardCup
                    .frame(width: 220, height: 244)
                    .padding(.bottom, 28)

                // 통계 카드
                HStack(spacing: 14) {
                    statPill(label: "녹인 물의 양", value: "\(waterML)", unit: "ml")
                    statPill(label: "집중 시간", value: timeStr, unit: "")
                }
                .padding(.horizontal, 36)
                .padding(.bottom, 20)

                // 구분선
                Rectangle()
                    .fill(Color.white.opacity(0.5))
                    .frame(width: 36, height: 2)
                    .padding(.bottom, 16)

                // 메시지
                Text("\(waterML)ml 녹였고 \(timeStr) 집중했습니다.")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(hex: "212121"))
                    .padding(.bottom, 4)

                Text("얼공 해볼까요? \u{1F9CA}")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(Color(hex: "48C7FF"))

                Spacer()
            }
        }
        .frame(width: 1080 / 3, height: 1920 / 3) // 9:16 (1080x1920 @3x)
        .clipShape(RoundedRectangle(cornerRadius: 0))
    }

    // MARK: - 통계 알약
    private func statPill(label: String, value: String, unit: String) -> some View {
        VStack(spacing: 6) {
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color(hex: "9E9E9E"))

            if unit.isEmpty {
                Text(value)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color(hex: "48C7FF"))
            } else {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(value)
                        .font(.system(size: 22, weight: .bold))
                    Text(unit)
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundColor(Color(hex: "48C7FF"))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
        )
    }

    // MARK: - 공유 카드 컵
    private var shareCardCup: some View {
        let cupW: CGFloat = 170
        let cupH: CGFloat = 187

        return ZStack {
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [.black.opacity(0.04), .clear],
                        center: .center, startRadius: 0, endRadius: cupW * 0.4
                    )
                )
                .frame(width: cupW * 0.6, height: 10)
                .offset(y: cupH * 0.52)

            GlassCupShape()
                .fill(Color(hex: "D8F0FF").opacity(0.04))
                .frame(width: cupW, height: cupH)

            GlassCupShape()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "48C7FF").opacity(0.18),
                            Color(hex: "48C7FF").opacity(0.26),
                            Color(hex: "48C7FF").opacity(0.32)
                        ],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .frame(width: cupW, height: cupH)
                .mask(
                    Rectangle()
                        .frame(height: cupH)
                        .frame(height: cupH, alignment: .bottom)
                        .offset(y: cupH * (1.0 - progress))
                )

            GlassCupShape()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(hex: "C6E8F9").opacity(0.7),
                            Color(hex: "A0D4ED").opacity(0.35),
                            Color(hex: "C6E8F9").opacity(0.5)
                        ],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
                .frame(width: cupW, height: cupH)

            GlassCupShape()
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.3), Color.white.opacity(0.0)],
                        startPoint: .topLeading, endPoint: .center
                    )
                )
                .frame(width: cupW, height: cupH)
                .mask(
                    HStack {
                        Rectangle().frame(width: cupW * 0.28)
                        Spacer()
                    }.frame(width: cupW)
                )
        }
    }
}

// MARK: - UIActivityViewController 래퍼
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - 공유 아이템 (sheet(item:) 용)
struct ShareItem: Identifiable {
    let id = UUID()
    let image: UIImage
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

#Preview("공유 카드") {
    ShareCardView(waterML: 355, hours: 1, minutes: 30, progress: 0.9, isCompleted: true)
        .previewLayout(.sizeThatFits)
}

import SwiftUI

struct IceMeltingView: View {
    let progress: CGFloat // 0.0 (전부 얼음) ~ 1.0 (전부 물)

    var body: some View {
        GeometryReader { geo in
            let cupWidth = geo.size.width * 0.65
            let cupHeight = cupWidth * 1.1

            ZStack {
                // 1) 바닥 그림자
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

                // 2) 컵 유리 배경
                GlassCupShape()
                    .fill(Color(hex: "D8F0FF").opacity(0.04))
                    .frame(width: cupWidth, height: cupHeight)

                // 3) 물 (아래부터 차오름)
                if progress > 0 {
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
                                .offset(y: cupHeight * (1.0 - progress))
                        )
                        .animation(.linear(duration: 1.5), value: progress)
                }

                // 4) 얼음 덩어리 (아래부터 그라데이션으로 녹음)
                iceLayer(cupWidth: cupWidth, cupHeight: cupHeight)
                    .frame(width: cupWidth, height: cupHeight)
                    .clipShape(GlassCupShape())
                    .mask(
                        LinearGradient(
                            stops: [
                                .init(color: .clear, location: max(0, progress - 0.05)),
                                .init(color: .white, location: min(progress + 0.25, 1.0))
                            ],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                        .frame(width: cupWidth, height: cupHeight)
                    )
                    .animation(.linear(duration: 1.5), value: progress)

                // 5) 컵 외곽선
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

                // 6) 유리 반사 (좌측)
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

                // 7) 바닥 두께
                Ellipse()
                    .fill(Color(hex: "C0E4F5").opacity(0.15))
                    .frame(width: cupWidth * 0.45, height: 10)
                    .offset(y: cupHeight * 0.44)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // MARK: - 얼음 레이어
    private func iceLayer(cupWidth: CGFloat, cupHeight: CGFloat) -> some View {
        ZStack {
            // ━━ 바닥 1층 ━━
            ice(w: 52, h: 40, rot: 3, x: -0.08, y: 0.38, cw: cupWidth, ch: cupHeight)
            ice(w: 50, h: 38, rot: -10, x: 0.10, y: 0.40, cw: cupWidth, ch: cupHeight)
            ice(w: 46, h: 36, rot: 18, x: 0.0, y: 0.36, cw: cupWidth, ch: cupHeight)
            ice(w: 40, h: 32, rot: -22, x: -0.22, y: 0.38, cw: cupWidth, ch: cupHeight)
            ice(w: 38, h: 30, rot: 30, x: 0.22, y: 0.39, cw: cupWidth, ch: cupHeight)

            // ━━ 2층 ━━
            ice(w: 50, h: 38, rot: -6, x: -0.12, y: 0.26, cw: cupWidth, ch: cupHeight)
            ice(w: 48, h: 36, rot: 15, x: 0.12, y: 0.24, cw: cupWidth, ch: cupHeight)
            ice(w: 44, h: 34, rot: -28, x: 0.0, y: 0.28, cw: cupWidth, ch: cupHeight)
            ice(w: 40, h: 32, rot: 38, x: 0.24, y: 0.26, cw: cupWidth, ch: cupHeight)
            ice(w: 38, h: 30, rot: -15, x: -0.25, y: 0.27, cw: cupWidth, ch: cupHeight)

            // ━━ 3층 ━━
            ice(w: 48, h: 36, rot: 12, x: -0.04, y: 0.14, cw: cupWidth, ch: cupHeight)
            ice(w: 46, h: 34, rot: -22, x: 0.16, y: 0.16, cw: cupWidth, ch: cupHeight)
            ice(w: 44, h: 32, rot: 32, x: -0.18, y: 0.17, cw: cupWidth, ch: cupHeight)
            ice(w: 38, h: 30, rot: -45, x: 0.26, y: 0.14, cw: cupWidth, ch: cupHeight)
            ice(w: 36, h: 28, rot: 8, x: 0.0, y: 0.12, cw: cupWidth, ch: cupHeight)

            // ━━ 4층 ━━
            ice(w: 46, h: 36, rot: -8, x: 0.04, y: 0.02, cw: cupWidth, ch: cupHeight)
            ice(w: 44, h: 34, rot: 25, x: -0.15, y: 0.04, cw: cupWidth, ch: cupHeight)
            ice(w: 42, h: 32, rot: -35, x: 0.18, y: 0.0, cw: cupWidth, ch: cupHeight)
            ice(w: 36, h: 28, rot: 50, x: -0.28, y: 0.02, cw: cupWidth, ch: cupHeight)
            ice(w: 34, h: 26, rot: -18, x: 0.28, y: 0.02, cw: cupWidth, ch: cupHeight)

            // ━━ 5층 ━━
            ice(w: 44, h: 34, rot: 8, x: -0.06, y: -0.10, cw: cupWidth, ch: cupHeight)
            ice(w: 42, h: 32, rot: -20, x: 0.12, y: -0.12, cw: cupWidth, ch: cupHeight)
            ice(w: 38, h: 30, rot: 40, x: 0.24, y: -0.09, cw: cupWidth, ch: cupHeight)
            ice(w: 36, h: 28, rot: -32, x: -0.22, y: -0.11, cw: cupWidth, ch: cupHeight)
            ice(w: 34, h: 26, rot: 15, x: 0.0, y: -0.08, cw: cupWidth, ch: cupHeight)

            // ━━ 6층 ━━
            ice(w: 42, h: 32, rot: -5, x: 0.0, y: -0.22, cw: cupWidth, ch: cupHeight)
            ice(w: 40, h: 30, rot: 28, x: -0.14, y: -0.24, cw: cupWidth, ch: cupHeight)
            ice(w: 38, h: 28, rot: -15, x: 0.16, y: -0.25, cw: cupWidth, ch: cupHeight)
            ice(w: 34, h: 26, rot: 45, x: 0.26, y: -0.20, cw: cupWidth, ch: cupHeight)
            ice(w: 32, h: 24, rot: -38, x: -0.26, y: -0.21, cw: cupWidth, ch: cupHeight)

            // ━━ 7층 ━━
            ice(w: 40, h: 30, rot: 10, x: -0.05, y: -0.34, cw: cupWidth, ch: cupHeight)
            ice(w: 38, h: 28, rot: -22, x: 0.12, y: -0.36, cw: cupWidth, ch: cupHeight)
            ice(w: 34, h: 26, rot: 35, x: -0.18, y: -0.35, cw: cupWidth, ch: cupHeight)
            ice(w: 32, h: 24, rot: -12, x: 0.24, y: -0.33, cw: cupWidth, ch: cupHeight)

            // ━━ 꼭대기 (컵 상단까지) ━━
            ice(w: 36, h: 26, rot: 6, x: -0.04, y: -0.40, cw: cupWidth, ch: cupHeight)
            ice(w: 34, h: 24, rot: -18, x: 0.12, y: -0.42, cw: cupWidth, ch: cupHeight)
            ice(w: 32, h: 22, rot: 30, x: -0.14, y: -0.41, cw: cupWidth, ch: cupHeight)
            ice(w: 28, h: 20, rot: -40, x: 0.22, y: -0.38, cw: cupWidth, ch: cupHeight)
            ice(w: 26, h: 20, rot: 22, x: -0.22, y: -0.39, cw: cupWidth, ch: cupHeight)
        }
    }

    // MARK: - 개별 얼음
    private func ice(w: CGFloat, h: CGFloat, rot: Double,
                     x: CGFloat, y: CGFloat,
                     cw: CGFloat, ch: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: min(w, h) * 0.22)
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.90),
                        Color(hex: "DAEEFA").opacity(0.70),
                        Color(hex: "B8E6FA").opacity(0.50)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: w, height: h)
            .overlay(
                RoundedRectangle(cornerRadius: min(w, h) * 0.22)
                    .stroke(Color.white.opacity(0.55), lineWidth: 0.7)
            )
            .overlay(
                RoundedRectangle(cornerRadius: min(w, h) * 0.22)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.55), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .center
                        )
                    )
                    .frame(width: w * 0.45, height: h * 0.35)
                    .offset(x: -w * 0.14, y: -h * 0.14),
                alignment: .topLeading
            )
            .rotationEffect(.degrees(rot))
            .shadow(color: AppColor.primary.opacity(0.10), radius: 2, x: 0, y: 1)
            .offset(x: cw * x, y: ch * y)
    }
}

#Preview("얼음 가득") {
    IceMeltingView(progress: 0.0)
        .frame(height: 360)
        .padding()
}

#Preview("반쯤 녹음") {
    IceMeltingView(progress: 0.5)
        .frame(height: 360)
        .padding()
}

#Preview("다 녹음") {
    IceMeltingView(progress: 1.0)
        .frame(height: 360)
        .padding()
}

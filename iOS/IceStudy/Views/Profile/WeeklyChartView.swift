import SwiftUI

struct WeeklyChartView: View {
    let weeklyMinutes: [Int]
    let dayLabels: [String]
    let dailyAverage: Int

    @State private var animatedProgress: CGFloat = 0
    @State private var selectedIndex: Int? = nil

    private var maxMinutes: Int {
        max(weeklyMinutes.max() ?? 1, 1)
    }

    private var averageRatio: CGFloat {
        CGFloat(dailyAverage) / CGFloat(maxMinutes)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 일일 평균 헤더
            VStack(alignment: .leading, spacing: 2) {
                Text("일일 평균")
                    .font(.system(size: 12))
                    .foregroundColor(AppColor.textSecondary)

                Text(formatTime(dailyAverage))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppColor.textPrimary)
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)

            // 선택된 바 정보
            if let idx = selectedIndex {
                HStack(spacing: 4) {
                    Text("\(dayLabels[idx])요일")
                        .font(.system(size: 12, weight: .medium))
                    Text(formatTime(weeklyMinutes[idx]))
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppColor.primary)
                }
                .padding(.horizontal, 20)
                .padding(.top, 4)
                .transition(.opacity)
            }

            // 차트 영역
            GeometryReader { geo in
                let chartHeight = geo.size.height - 30 // 요일 라벨 공간
                let barWidth: CGFloat = (geo.size.width - 40) / CGFloat(weeklyMinutes.count) - 8

                ZStack(alignment: .bottom) {
                    // 평균선
                    VStack {
                        Spacer()
                            .frame(height: chartHeight * (1.0 - averageRatio) + 15)

                        Rectangle()
                            .fill(AppColor.primary.opacity(0.35))
                            .frame(height: 1)

                        // 점선 효과
                        HStack(spacing: 4) {
                            ForEach(0..<30, id: \.self) { _ in
                                Rectangle()
                                    .fill(AppColor.primary.opacity(0.35))
                                    .frame(width: 6, height: 1)
                            }
                        }
                        .offset(y: -1)

                        Spacer()
                    }
                    .frame(height: chartHeight + 15)
                    .padding(.horizontal, 20)
                    .opacity(0)
                    .overlay(
                        // 실제 점선
                        GeometryReader { lineGeo in
                            Path { path in
                                let y = (1.0 - averageRatio) * chartHeight + 15
                                path.move(to: CGPoint(x: 10, y: y))
                                path.addLine(to: CGPoint(x: lineGeo.size.width - 10, y: y))
                            }
                            .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                            .foregroundColor(AppColor.primary.opacity(0.4))
                        }
                    )

                    // 바 차트
                    HStack(alignment: .bottom, spacing: 8) {
                        ForEach(0..<weeklyMinutes.count, id: \.self) { index in
                            VStack(spacing: 6) {
                                // 바
                                let ratio = CGFloat(weeklyMinutes[index]) / CGFloat(maxMinutes)
                                let barHeight = max(chartHeight * ratio * animatedProgress, 4)
                                let isSelected = selectedIndex == index

                                RoundedRectangle(cornerRadius: 6)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                AppColor.primary.opacity(isSelected ? 0.25 : 0.15),
                                                AppColor.primary.opacity(isSelected ? 0.6 : 0.4),
                                                AppColor.primary.opacity(isSelected ? 0.9 : 0.7)
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .frame(width: barWidth, height: barHeight)
                                    .onTapGesture {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            selectedIndex = selectedIndex == index ? nil : index
                                        }
                                    }

                                // 요일 라벨
                                Text(dayLabels[index])
                                    .font(.system(size: 11))
                                    .foregroundColor(
                                        isSelected ? AppColor.primary : AppColor.textSecondary
                                    )
                                    .fontWeight(isSelected ? .bold : .regular)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .frame(height: 220)
            .padding(.top, 12)
            .padding(.bottom, 16)
        }
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "F0F9FF"),
                            Color(hex: "F6FCFF")
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        )
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animatedProgress = 1.0
            }
        }
    }

    private func formatTime(_ minutes: Int) -> String {
        let h = minutes / 60
        let m = minutes % 60
        if h > 0 {
            return "\(h)시간 \(m)분"
        }
        return "\(m)분"
    }
}

#Preview {
    WeeklyChartView(
        weeklyMinutes: [180, 80, 150, 200, 120, 60, 140],
        dayLabels: ["월", "화", "수", "목", "금", "토", "일"],
        dailyAverage: 133
    )
    .padding()
}

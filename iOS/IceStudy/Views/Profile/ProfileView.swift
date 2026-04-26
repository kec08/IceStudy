import SwiftUI

struct ProfileView: View {
    @Environment(AuthViewModel.self) private var authViewModel

    @State private var showSettings = false

    // 서버 데이터
    @State private var nickname = ""
    @State private var email = ""
    @State private var iceCount = 0
    @State private var totalML = 0
    @State private var totalHours = 0
    @State private var totalMinutes = 0
    @State private var weeklyMinutes: [Int] = [0, 0, 0, 0, 0, 0, 0]

    // 카운트업 애니메이션
    @State private var displayIceCount = 0
    @State private var displayTotalML = 0
    @State private var displayTotalHours = 0
    @State private var displayTotalMinutes = 0
    @State private var prevIceCount = 0
    @State private var prevTotalML = 0
    @State private var prevTotalHours = 0
    @State private var prevTotalMinutes = 0

    private let dayLabels = ["월", "화", "수", "목", "금", "토", "일"]

    private var dailyAverage: Int {
        let activeDays = weeklyMinutes.filter { $0 > 0 }.count
        guard activeDays > 0 else { return 0 }
        return weeklyMinutes.reduce(0, +) / activeDays
    }

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                navBar
                    .padding(.top, 16)

                profileSection
                    .padding(.top, 24)
                    .padding(.horizontal, 24)

                infoSection
                    .padding(.top, 28)
                    .padding(.horizontal, 24)

                historySection
                    .padding(.top, 28)
                    .padding(.horizontal, 24)

                Spacer()
            }
        }
        .task {
            await fetchProfile()
        }
        .onChange(of: iceCount) { animateCountUp() }
        .onChange(of: totalML) { animateCountUp() }
        .fullScreenCover(isPresented: $showSettings) {
            SettingsView(onNicknameChanged: { newNickname in
                nickname = newNickname
            })
            .environment(authViewModel)
        }
    }

    // MARK: - API
    private func fetchProfile() async {
        nickname = TokenStorage.nickname ?? "사용자"
        email = TokenStorage.email ?? ""

        do {
            let stats = try await StatsService.shared.fetchProfile()
            iceCount = stats.iceCount
            totalML = Int(stats.totalMl)
            let minutes = stats.totalMinutes
            totalHours = minutes / 60
            totalMinutes = minutes % 60
            if stats.weeklyMinutes.count == 7 {
                weeklyMinutes = stats.weeklyMinutes
            }
        } catch {
            print("프로필 통계 조회 실패: \(error.localizedDescription)")
        }
    }

    // MARK: - 네비바
    private var navBar: some View {
        ZStack {
            Text("마이")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppColor.textPrimary)

            HStack {
                Spacer()
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 20))
                        .foregroundColor(AppColor.textPrimary)
                }
            }
        }
        .padding(.horizontal, 24)
    }

    // MARK: - 프로필
    private var profileSection: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(AppColor.primary)
                    .frame(width: 56, height: 56)
                Image(systemName: "cube.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(nickname)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppColor.textPrimary)
                if !email.hasSuffix("@privaterelay.appleid.com") {
                    Text(email)
                        .font(.system(size: 13))
                        .foregroundColor(AppColor.textSecondary)
                }
            }

            Spacer()
        }
    }

    // MARK: - 정보
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("정보")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(AppColor.textPrimary)

            HStack(spacing: 10) {
                statCard(imageName: "IceCube",
                         label: "녹인 얼음 갯수", value: "\(displayIceCount)", unit: "개")
                statCard(imageName: "Water",
                         label: "총 물의 양", value: "\(displayTotalML)", unit: "ml")
                timeStatCard(imageName: "Clock",
                             label: "총 공부시간", hours: displayTotalHours, minutes: displayTotalMinutes)
            }
        }
    }

    private func statCard(imageName: String, label: String, value: String, unit: String) -> some View {
        VStack(spacing: 8) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)

            Text(label)
                .font(.system(size: 11))
                .foregroundColor(AppColor.textSecondary)

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppColor.primary)
                Text(unit)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(AppColor.textPrimary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
        )
    }

    private func timeStatCard(imageName: String, label: String, hours: Int, minutes: Int) -> some View {
        VStack(spacing: 8) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)

            Text(label)
                .font(.system(size: 11))
                .foregroundColor(AppColor.textSecondary)

            HStack(alignment: .firstTextBaseline, spacing: 1) {
                Text("\(hours)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppColor.primary)
                Text("시간")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(AppColor.textPrimary)
                Text("\(minutes)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppColor.primary)
                Text("분")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(AppColor.textPrimary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
        )
    }

    // MARK: - 히스토리
    private var historySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("히스토리")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(AppColor.textPrimary)

            WeeklyChartView(
                weeklyMinutes: weeklyMinutes,
                dayLabels: dayLabels,
                dailyAverage: dailyAverage
            )
        }
    }

    // MARK: - 카운트업 애니메이션
    @State private var countUpTimer: Timer?

    private func animateCountUp() {
        countUpTimer?.invalidate()

        let fromIce = prevIceCount
        let fromML = prevTotalML
        let fromHours = prevTotalHours
        let fromMinutes = prevTotalMinutes
        let targetIce = iceCount
        let targetML = totalML
        let targetHours = totalHours
        let targetMinutes = totalMinutes

        let steps = 30
        var currentStep = 0
        let interval = 0.8 / Double(steps)

        countUpTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            currentStep += 1
            let fraction = Double(currentStep) / Double(steps)
            let eased = 1 - pow(1 - fraction, 3)

            displayIceCount = fromIce + Int(Double(targetIce - fromIce) * eased)
            displayTotalML = fromML + Int(Double(targetML - fromML) * eased)
            displayTotalHours = fromHours + Int(Double(targetHours - fromHours) * eased)
            displayTotalMinutes = fromMinutes + Int(Double(targetMinutes - fromMinutes) * eased)

            if currentStep >= steps {
                timer.invalidate()
                prevIceCount = targetIce
                prevTotalML = targetML
                prevTotalHours = targetHours
                prevTotalMinutes = targetMinutes
            }
        }
    }

}

#Preview {
    ProfileView()
        .environment(AuthViewModel())
}

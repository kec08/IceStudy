import SwiftUI

struct ProfileView: View {
    // 임시 데이터
    private let nickname = "얼공얼공"
    private let email = "kec4489@icloud.com"
    private let iceCount = 300
    private let totalML = 11500
    private let totalHours = 16
    private let totalMinutes = 10

    private let weeklyMinutes: [Int] = [180, 80, 150, 200, 120, 60, 140] // 월~일
    private let dayLabels = ["월", "화", "수", "목", "금", "토", "일"]

    private var dailyAverage: Int {
        weeklyMinutes.reduce(0, +) / max(weeklyMinutes.count, 1)
    }

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // 네비바
                    navBar
                        .padding(.top, 16)

                    // 프로필 영역
                    profileSection
                        .padding(.top, 24)
                        .padding(.horizontal, 24)

                    // 정보 섹션
                    infoSection
                        .padding(.top, 28)
                        .padding(.horizontal, 24)

                    // 히스토리 섹션
                    historySection
                        .padding(.top, 28)
                        .padding(.horizontal, 24)

                    // 로그아웃
                    logoutButton
                        .padding(.top, 60)
                        .padding(.bottom, 100)
                }
            }
        }
        .preferredColorScheme(.light)
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
                    // 설정 (추후)
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
            // 프로필 아이콘
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
                Text(email)
                    .font(.system(size: 13))
                    .foregroundColor(AppColor.textSecondary)
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
                         label: "녹인 얼음 갯수", value: "\(iceCount)", unit: "개")
                statCard(imageName: "Water",
                         label: "총 물의 양", value: "\(totalML)", unit: "ml")
                timeStatCard(imageName: "Clock",
                             label: "총 공부시간", hours: totalHours, minutes: totalMinutes)
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

    // MARK: - 로그아웃
    private var logoutButton: some View {
        Button {
            // 로그아웃 (추후)
        } label: {
            Text("로그아웃")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColor.danger)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

#Preview {
    ProfileView()
}

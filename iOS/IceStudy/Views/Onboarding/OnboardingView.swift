import SwiftUI

struct OnboardingView: View {
    @State private var navigateToLogin = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        if navigateToLogin {
            LoginView()
        } else {
            onboardingContent
        }
    }

    private var onboardingContent: some View {
        GeometryReader { geo in
            ZStack {
                AppColor.background
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {
                    // 상단 로고
                    LogoHeaderView()
                        .padding(.top, 16)
                        .padding(.horizontal, 24)

                    // 설명 텍스트
                    VStack(alignment: .leading, spacing: 4) {
                        Text("언제 녹을지 모르는 얼음")
                            .font(AppFont.headline())
                            .foregroundColor(AppColor.textPrimary)

                        Text("전부 녹을 때까지 집중해보세요")
                            .font(AppFont.headline())
                            .foregroundColor(AppColor.textPrimary)
                    }
                    .padding(.top, 12)
                    .padding(.horizontal, 24)

                    Spacer()

                    // 중앙 얼음컵
                    IceMeltingView(progress: 0.0)
                        .frame(height: geo.size.height * 0.4)

                    Spacer()

                    // 하단 시작하기 버튼
                    PrimaryButton(title: "시작하기") {
                        hasSeenOnboarding = true
                        withAnimation {
                            navigateToLogin = true
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

#Preview {
    OnboardingView()
}

import SwiftUI

struct SplashView: View {
    @State private var isAnimating = false
    @State private var navigateNext = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        if navigateNext {
            if hasSeenOnboarding {
                LoginView()
            } else {
                OnboardingView()
            }
        } else {
            splashContent
                .onAppear {
                    withAnimation(.easeOut(duration: 0.8)) {
                        isAnimating = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation {
                            navigateNext = true
                        }
                    }
                }
        }
    }

    private var splashContent: some View {
        ZStack {
            AppColor.background
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Image("IceCube")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .scaleEffect(isAnimating ? 1.0 : 0.8)
                    .opacity(isAnimating ? 1.0 : 0.0)

                Image("LogoText")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 56)
                    .scaleEffect(isAnimating ? 1.0 : 0.8)
                    .opacity(isAnimating ? 1.0 : 0.0)
            }
        }
    }
}

#Preview {
    SplashView()
}

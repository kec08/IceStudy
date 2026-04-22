import SwiftUI

enum AppScreen {
    case splash
    case onboarding
    case login
    case nicknameSetup
    case main
}

struct SplashView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var isAnimating = false
    @State private var currentScreen: AppScreen = .splash
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        ZStack {
            switch currentScreen {
            case .splash:
                splashContent
                    .transition(.opacity)
            case .onboarding:
                OnboardingView(onFinish: {
                    navigateTo(.login)
                })
                .environment(authViewModel)
                .transition(.opacity)
            case .login:
                LoginView(onLoginSuccess: {
                    if authViewModel.needsNicknameSetup {
                        navigateTo(.nicknameSetup)
                    } else {
                        navigateTo(.main)
                    }
                })
                .environment(authViewModel)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .opacity
                ))
            case .nicknameSetup:
                NicknameSetupView(onComplete: {
                    navigateTo(.main)
                })
                .environment(authViewModel)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .opacity
                ))
            case .main:
                MainTabView()
                    .environment(authViewModel)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: currentScreen)
        .onChange(of: authViewModel.isLoggedIn) { _, isLoggedIn in
            if isLoggedIn && currentScreen == .login {
                if authViewModel.needsNicknameSetup {
                    navigateTo(.nicknameSetup)
                } else {
                    navigateTo(.main)
                }
            } else if !isLoggedIn && (currentScreen == .main || currentScreen == .nicknameSetup) {
                navigateTo(.login)
            }
        }
    }

    private func navigateTo(_ screen: AppScreen) {
        withAnimation(.easeInOut(duration: 0.4)) {
            currentScreen = screen
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
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                isAnimating = true
            }
            Task {
                await authViewModel.tryAutoLogin()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                if authViewModel.isLoggedIn {
                    navigateTo(.main)
                } else if hasSeenOnboarding {
                    navigateTo(.login)
                } else {
                    navigateTo(.onboarding)
                }
            }
        }
    }
}

#Preview {
    SplashView()
        .environment(AuthViewModel())
}

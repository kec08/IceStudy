import SwiftUI

struct LoginView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var navigateToSignUp = false

    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty
    }

    var body: some View {
        if authViewModel.isLoggedIn {
            MainTabView()
                .environment(authViewModel)
        } else if navigateToSignUp {
            SignUpView(onBack: {
                navigateToSignUp = false
            })
            .environment(authViewModel)
        } else {
            loginContent
        }
    }

    private var loginContent: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // 네비게이션 바
                HStack {
                    Spacer()
                    Image("LogoText")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 22)
                    Spacer()
                }
                .padding(.top, 16)

                // 로그인 타이틀
                Text("로그인")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(AppColor.textPrimary)
                    .padding(.top, 32)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 7)

                // 설명
                VStack(alignment: .leading, spacing: 4) {
                    Text("간편하게 애플계정으로 로그인하여")
                        .font(.system(size: 14))
                        .foregroundColor(AppColor.textSecondary)
                    Text("빠르게 서비스를 이용해보세요.")
                        .font(.system(size: 14))
                        .foregroundColor(AppColor.textSecondary)
                }
                .padding(.horizontal, 24)

                // Apple 로그인 버튼
                Button(action: {
                    // Apple 로그인 (추후 구현)
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "apple.logo")
                            .font(.system(size: 20))
                        Text("Apple 계정으로 계속하기")
                            .font(AppFont.headline())
                    }
                    .foregroundColor(AppColor.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(AppColor.textPrimary, lineWidth: 1)
                    )
                }
                .padding(.top, 24)
                .padding(.horizontal, 24)

                // 구분선
                Divider()
                    .background(Color(hex: "E0E0E0"))
                    .padding(.horizontal, 80)
                    .padding(.top, 28)

                // 로그인 소제목
                Text("로그인")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(AppColor.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 28)

                // 입력 필드
                VStack(spacing: 40) {
                    StyledInputField(placeholder: "이메일", text: $email)
                    StyledInputField(placeholder: "비밀번호", text: $password, isSecure: true)
                }
                .padding(.top, 24)
                .padding(.horizontal, 24)

                // 에러 메시지
                if let error = authViewModel.errorMessage {
                    Text(error)
                        .font(.system(size: 12))
                        .foregroundColor(AppColor.danger)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 12)
                        .padding(.horizontal, 24)
                }

                Spacer()

                // 회원가입 링크
                HStack(spacing: 4) {
                    Text("아직 회원이 아니신가요?")
                        .font(.system(size: 14))
                        .foregroundColor(AppColor.textSecondary)
                    Button("회원가입") {
                        withAnimation {
                            navigateToSignUp = true
                        }
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColor.primary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 16)

                // 로그인 버튼
                PrimaryButton(
                    title: authViewModel.isLoading ? "로그인 중..." : "로그인",
                    isEnabled: isFormValid && !authViewModel.isLoading
                ) {
                    Task {
                        await authViewModel.login(email: email, password: password)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - 입력 필드 (포커스 감지 + 다크모드 대응)
struct StyledInputField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if isSecure {
                SecureField(placeholder, text: $text)
                    .font(AppFont.body())
                    .foregroundColor(AppColor.textPrimary)
                    .focused($isFocused)
                    .tint(AppColor.primary)
            } else {
                TextField(placeholder, text: $text)
                    .font(AppFont.body())
                    .foregroundColor(AppColor.textPrimary)
                    .focused($isFocused)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .tint(AppColor.primary)
            }

            Rectangle()
                .frame(height: isFocused ? 2 : 1)
                .foregroundColor(isFocused ? AppColor.primary : Color(hex: "E0E0E0"))
                .animation(.easeInOut(duration: 0.2), value: isFocused)
        }
        .environment(\.colorScheme, .light)
    }
}

#Preview {
    LoginView()
        .environment(AuthViewModel())
}

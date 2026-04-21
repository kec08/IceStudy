import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var navigateToHome = false
    @State private var navigateToSignUp = false

    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty
    }

    var body: some View {
        if navigateToHome {
            MainTabView()
        } else if navigateToSignUp {
            SignUpView(onBack: {
                navigateToSignUp = false
            })
        } else {
            loginContent
        }
    }

    private var loginContent: some View {
        ZStack {
            AppColor.background
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // 네비게이션 바
                HStack {
                    Spacer()
                    Text("얼공")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(AppColor.primary)
                    Spacer()
                }
                .padding(.top, 16)

                // 로그인 타이틀
                Text("로그인")
                    .font(AppFont.title1())
                    .foregroundColor(AppColor.textPrimary)
                    .padding(.top, 32)
                    .padding(.horizontal, 24)

                // 설명
                VStack(alignment: .leading, spacing: 4) {
                    Text("간편하게 애플계정으로 로그인하여")
                        .font(AppFont.body())
                        .foregroundColor(AppColor.textPrimary)
                    Text("빠르게 서비스 서비스를 이용해보세요.")
                        .font(AppFont.body())
                        .foregroundColor(AppColor.textPrimary)
                }
                .padding(.top, 12)
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
                    .padding(.horizontal, 80)
                    .padding(.top, 28)

                // 로그인 소제목
                Text("로그인")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(AppColor.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 28)

                // 입력 필드
                VStack(spacing: 24) {
                    InputField(placeholder: "이메일", text: $email)
                    InputField(placeholder: "비밀번호", text: $password, isSecure: true)
                }
                .padding(.top, 24)
                .padding(.horizontal, 24)

                Spacer()

                // 회원가입 링크
                HStack(spacing: 4) {
                    Text("아직 회원이 아니신가요?")
                        .font(AppFont.callout())
                        .foregroundColor(AppColor.textSecondary)
                    Button("회원가입") {
                        withAnimation {
                            navigateToSignUp = true
                        }
                    }
                    .font(AppFont.callout())
                    .foregroundColor(AppColor.primary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 16)

                // 로그인 버튼
                PrimaryButton(title: "로그인", isEnabled: isFormValid) {
                    withAnimation {
                        navigateToHome = true
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - 입력 필드 컴포넌트
struct InputField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if isSecure {
                SecureField(placeholder, text: $text)
                    .font(AppFont.body())
                    .foregroundColor(AppColor.textPrimary)
            } else {
                TextField(placeholder, text: $text)
                    .font(AppFont.body())
                    .foregroundColor(AppColor.textPrimary)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
            }

            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(hex: "E0E0E0"))
        }
    }
}

#Preview {
    LoginView()
}

import SwiftUI

struct SignUpView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var nickname = ""
    @State private var email = ""
    @State private var password = ""
    @State private var passwordConfirm = ""
    @State private var signUpSuccess = false
    var onBack: () -> Void

    private var isFormValid: Bool {
        !nickname.isEmpty && !email.isEmpty && !password.isEmpty
        && password == passwordConfirm && password.count >= 6
    }

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // 네비게이션 바
                ZStack {
                    Image("LogoText")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 22)

                    HStack {
                        Button(action: onBack) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(AppColor.textPrimary)
                        }
                        Spacer()
                    }
                }
                .padding(.top, 16)
                .padding(.horizontal, 24)

                // 회원가입 타이틀
                Text("회원가입")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(AppColor.textPrimary)
                    .padding(.top, 32)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 7)

                Text("얼공에 오신 것을 환영합니다")
                    .font(.system(size: 14))
                    .foregroundColor(AppColor.textSecondary)
                    .padding(.horizontal, 24)

                // 입력 필드
                ScrollView {
                    VStack(spacing: 40) {
                        StyledInputField(placeholder: "닉네임", text: $nickname)
                        StyledInputField(placeholder: "이메일", text: $email)
                        StyledInputField(placeholder: "비밀번호 (6자 이상)", text: $password, isSecure: true)
                        StyledInputField(placeholder: "비밀번호 확인", text: $passwordConfirm, isSecure: true)
                    }
                    .padding(.top, 32)
                    .padding(.horizontal, 24)

                    // 비밀번호 불일치 경고
                    if !passwordConfirm.isEmpty && password != passwordConfirm {
                        Text("비밀번호가 일치하지 않습니다")
                            .font(.system(size: 12))
                            .foregroundColor(AppColor.danger)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 8)
                            .padding(.horizontal, 24)
                    }

                    // 에러 메시지
                    if let error = authViewModel.errorMessage {
                        Text(error)
                            .font(.system(size: 12))
                            .foregroundColor(AppColor.danger)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 8)
                            .padding(.horizontal, 24)
                    }

                    // 성공 메시지
                    if signUpSuccess {
                        Text("회원가입이 완료되었습니다! 로그인해주세요.")
                            .font(.system(size: 12))
                            .foregroundColor(AppColor.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 8)
                            .padding(.horizontal, 24)
                    }
                }

                Spacer()

                // 로그인 링크
                HStack(spacing: 4) {
                    Text("이미 회원이신가요?")
                        .font(.system(size: 14))
                        .foregroundColor(AppColor.textSecondary)
                    Button("로그인") {
                        onBack()
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColor.primary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 16)

                // 회원가입 버튼
                PrimaryButton(
                    title: authViewModel.isLoading ? "가입 중..." : "회원가입",
                    isEnabled: isFormValid && !authViewModel.isLoading
                ) {
                    Task {
                        let success = await authViewModel.signup(
                            email: email,
                            password: password,
                            nickname: nickname
                        )
                        if success {
                            signUpSuccess = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                onBack()
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    SignUpView(onBack: {})
        .environment(AuthViewModel())
}

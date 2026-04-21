import SwiftUI

struct SignUpView: View {
    @State private var nickname = ""
    @State private var email = ""
    @State private var password = ""
    @State private var passwordConfirm = ""
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
                PrimaryButton(title: "회원가입", isEnabled: isFormValid) {
                    onBack()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .preferredColorScheme(.light)
    }
}

#Preview {
    SignUpView(onBack: {})
}

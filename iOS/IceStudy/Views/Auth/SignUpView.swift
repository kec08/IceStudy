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
            AppColor.background
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // 네비게이션 바
                ZStack {
                    Text("얼공")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(AppColor.primary)

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
                    .font(AppFont.title1())
                    .foregroundColor(AppColor.textPrimary)
                    .padding(.top, 32)
                    .padding(.horizontal, 24)

                Text("얼공에 오신 것을 환영합니다")
                    .font(AppFont.body())
                    .foregroundColor(AppColor.textSecondary)
                    .padding(.top, 8)
                    .padding(.horizontal, 24)

                // 입력 필드
                VStack(spacing: 24) {
                    InputField(placeholder: "닉네임", text: $nickname)
                    InputField(placeholder: "이메일", text: $email)
                    InputField(placeholder: "비밀번호 (6자 이상)", text: $password, isSecure: true)
                    InputField(placeholder: "비밀번호 확인", text: $passwordConfirm, isSecure: true)
                }
                .padding(.top, 32)
                .padding(.horizontal, 24)

                // 비밀번호 불일치 경고
                if !passwordConfirm.isEmpty && password != passwordConfirm {
                    Text("비밀번호가 일치하지 않습니다")
                        .font(AppFont.caption())
                        .foregroundColor(AppColor.danger)
                        .padding(.top, 8)
                        .padding(.horizontal, 24)
                }

                Spacer()

                // 회원가입 버튼
                PrimaryButton(title: "회원가입", isEnabled: isFormValid) {
                    // 회원가입 API 호출 (추후 구현)
                    onBack()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    SignUpView(onBack: {})
}

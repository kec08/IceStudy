import SwiftUI

struct NicknameSetupView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var nickname = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    var onComplete: (() -> Void)?

    private var isValid: Bool {
        !nickname.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
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

                // 타이틀
                Text("닉네임 설정")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(AppColor.textPrimary)
                    .padding(.top, 32)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 7)

                // 설명
                VStack(alignment: .leading, spacing: 4) {
                    Text("얼공에서 사용할 닉네임을")
                        .font(.system(size: 14))
                        .foregroundColor(AppColor.textSecondary)
                    Text("설정해주세요.")
                        .font(.system(size: 14))
                        .foregroundColor(AppColor.textSecondary)
                }
                .padding(.horizontal, 24)

                // 닉네임 입력
                StyledInputField(placeholder: "닉네임", text: $nickname)
                    .padding(.top, 40)
                    .padding(.horizontal, 24)

                // 에러 메시지
                if let error = errorMessage {
                    Text(error)
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 12)
                        .padding(.horizontal, 24)
                }

                Spacer()

                // 확인 버튼
                PrimaryButton(
                    title: isLoading ? "설정 중..." : "확인",
                    isEnabled: isValid && !isLoading
                ) {
                    Task {
                        await saveNickname()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }

    private func saveNickname() async {
        isLoading = true
        errorMessage = nil
        do {
            let response = try await UserService.shared.updateNickname(nickname.trimmingCharacters(in: .whitespaces))
            await MainActor.run {
                authViewModel.nickname = response.nickname
                authViewModel.needsNicknameSetup = false
                isLoading = false
                onComplete?()
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}

#Preview {
    NicknameSetupView()
        .environment(AuthViewModel())
}

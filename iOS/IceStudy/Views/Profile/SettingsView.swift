import SwiftUI

struct SettingsView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(\.dismiss) private var dismiss

    var onNicknameChanged: ((String) -> Void)?

    @State private var showNicknameChange = false
    @State private var showPasswordChange = false
    @State private var showDeleteAccount = false
    @State private var showLogoutAlert = false

    private var isAppleUser: Bool {
        TokenStorage.email?.hasSuffix("@apple.icestudy") == true
    }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // 네비바
                ZStack {
                    Text("설정")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppColor.textPrimary)

                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 18))
                                .foregroundColor(AppColor.textPrimary)
                        }
                        Spacer()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                // 메뉴 목록
                VStack(spacing: 0) {
                    menuRow(title: "닉네임 변경", icon: "person.fill") {
                        showNicknameChange = true
                    }

                    if !isAppleUser {
                        menuRow(title: "비밀번호 변경", icon: "lock.fill") {
                            showPasswordChange = true
                        }
                    }

                    menuRow(title: "계정 삭제", icon: "trash.fill", isDestructive: true) {
                        showDeleteAccount = true
                    }
                }
                .padding(.top, 28)
                .padding(.horizontal, 24)

                Spacer()

                Button {
                    showLogoutAlert = true
                } label: {
                    Text("로그아웃")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.red)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 60)
                .alert("로그아웃", isPresented: $showLogoutAlert) {
                    Button("취소", role: .cancel) {}
                    Button("로그아웃", role: .destructive) {
                        authViewModel.logout()
                    }
                } message: {
                    Text("정말 로그아웃 하시겠습니까?")
                }
            }
        }
        .fullScreenCover(isPresented: $showNicknameChange) {
            NicknameChangeView(onChanged: { newNickname in
                onNicknameChanged?(newNickname)
            })
            .environment(authViewModel)
        }
        .fullScreenCover(isPresented: $showPasswordChange) {
            PasswordChangeView()
        }
        .fullScreenCover(isPresented: $showDeleteAccount) {
            DeleteAccountView()
                .environment(authViewModel)
        }
    }

    private func menuRow(title: String, icon: String, isDestructive: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(isDestructive ? .red : AppColor.textSecondary)
                    .frame(width: 24)

                Text(title)
                    .font(.system(size: 15))
                    .foregroundColor(isDestructive ? .red : AppColor.textPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13))
                    .foregroundColor(AppColor.textTertiary)
            }
            .padding(.vertical, 16)
        }
    }
}

// MARK: - 닉네임 변경 화면
struct NicknameChangeView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(\.dismiss) private var dismiss

    var onChanged: ((String) -> Void)?

    @State private var nickname = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    private var isValid: Bool {
        !nickname.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // 네비바
                ZStack {
                    Text("닉네임 변경")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppColor.textPrimary)

                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18))
                                .foregroundColor(AppColor.textPrimary)
                        }
                        Spacer()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                // 설명
                VStack(alignment: .leading, spacing: 4) {
                    Text("변경할 닉네임을")
                        .font(.system(size: 14))
                        .foregroundColor(AppColor.textSecondary)
                    Text("입력해주세요.")
                        .font(.system(size: 14))
                        .foregroundColor(AppColor.textSecondary)
                }
                .padding(.top, 32)
                .padding(.horizontal, 24)

                StyledInputField(placeholder: "닉네임", text: $nickname)
                    .padding(.top, 40)
                    .padding(.horizontal, 24)

                if let error = errorMessage {
                    Text(error)
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 12)
                        .padding(.horizontal, 24)
                }

                Spacer()

                PrimaryButton(
                    title: isLoading ? "변경 중..." : "변경하기",
                    isEnabled: isValid && !isLoading
                ) {
                    Task { await changeNickname() }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            nickname = TokenStorage.nickname ?? ""
        }
    }

    private func changeNickname() async {
        isLoading = true
        errorMessage = nil
        do {
            let response = try await UserService.shared.updateNickname(nickname.trimmingCharacters(in: .whitespaces))
            await MainActor.run {
                authViewModel.nickname = response.nickname
                onChanged?(response.nickname)
                isLoading = false
                dismiss()
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}

// MARK: - 비밀번호 변경 화면
struct PasswordChangeView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    private var isValid: Bool {
        !currentPassword.isEmpty && newPassword.count >= 6 && newPassword == confirmPassword
    }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // 네비바
                ZStack {
                    Text("비밀번호 변경")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppColor.textPrimary)

                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18))
                                .foregroundColor(AppColor.textPrimary)
                        }
                        Spacer()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                VStack(alignment: .leading, spacing: 4) {
                    Text("현재 비밀번호 확인 후")
                        .font(.system(size: 14))
                        .foregroundColor(AppColor.textSecondary)
                    Text("새 비밀번호를 설정해주세요.")
                        .font(.system(size: 14))
                        .foregroundColor(AppColor.textSecondary)
                }
                .padding(.top, 32)
                .padding(.horizontal, 24)

                VStack(spacing: 28) {
                    StyledInputField(placeholder: "현재 비밀번호", text: $currentPassword, isSecure: true)
                    StyledInputField(placeholder: "새 비밀번호 (6자 이상)", text: $newPassword, isSecure: true)
                    StyledInputField(placeholder: "새 비밀번호 확인", text: $confirmPassword, isSecure: true)
                }
                .padding(.top, 40)
                .padding(.horizontal, 24)

                if let error = errorMessage {
                    Text(error)
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 12)
                        .padding(.horizontal, 24)
                }

                Spacer()

                PrimaryButton(
                    title: isLoading ? "변경 중..." : "변경하기",
                    isEnabled: isValid && !isLoading
                ) {
                    Task { await changePassword() }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }

    private func changePassword() async {
        isLoading = true
        errorMessage = nil
        do {
            try await UserService.shared.changePassword(
                currentPassword: currentPassword,
                newPassword: newPassword
            )
            await MainActor.run {
                isLoading = false
                dismiss()
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}

// MARK: - 계정 삭제 화면
struct DeleteAccountView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var confirmText = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showDeleteAlert = false

    private var isValid: Bool {
        confirmText == "삭제하겠습니다"
    }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // 네비바
                ZStack {
                    Text("계정 삭제")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppColor.textPrimary)

                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18))
                                .foregroundColor(AppColor.textPrimary)
                        }
                        Spacer()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                VStack(alignment: .leading, spacing: 4) {
                    Text("계정을 삭제하면 모든 데이터가")
                        .font(.system(size: 14))
                        .foregroundColor(AppColor.textSecondary)
                    Text("영구적으로 삭제되며 복구할 수 없습니다.")
                        .font(.system(size: 14))
                        .foregroundColor(AppColor.textSecondary)
                }
                .padding(.top, 32)
                .padding(.horizontal, 24)

                Text("삭제를 원하시면 \"삭제하겠습니다\"를 입력해주세요.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.red)
                    .padding(.top, 16)
                    .padding(.horizontal, 24)

                StyledInputField(placeholder: "삭제하겠습니다", text: $confirmText)
                    .padding(.top, 40)
                    .padding(.horizontal, 24)

                if let error = errorMessage {
                    Text(error)
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 12)
                        .padding(.horizontal, 24)
                }

                Spacer()

                // 삭제 버튼
                Button {
                    showDeleteAlert = true
                } label: {
                    Text(isLoading ? "삭제 중..." : "삭제하기")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(isValid ? .white : AppColor.textSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(isValid ? Color.red : AppColor.surface)
                        .cornerRadius(14)
                }
                .disabled(!isValid || isLoading)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .alert("계정 삭제", isPresented: $showDeleteAlert) {
            Button("취소", role: .cancel) {}
            Button("삭제", role: .destructive) {
                Task { await deleteAccount() }
            }
        } message: {
            Text("정말 계정을 삭제하시겠습니까?\n모든 데이터가 영구적으로 삭제됩니다.")
        }
    }

    private func deleteAccount() async {
        isLoading = true
        errorMessage = nil
        do {
            try await UserService.shared.deleteAccount()
            await MainActor.run {
                isLoading = false
                dismiss()
                authViewModel.logout()
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
    SettingsView()
        .environment(AuthViewModel())
}

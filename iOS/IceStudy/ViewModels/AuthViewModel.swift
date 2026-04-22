import SwiftUI
import AuthenticationServices

@Observable
class AuthViewModel {
    var isLoggedIn: Bool = false
    var isLoading: Bool = false
    var errorMessage: String?
    var nickname: String = ""
    var needsNicknameSetup: Bool = false

    init() {
        isLoggedIn = TokenStorage.isLoggedIn
        nickname = TokenStorage.nickname ?? ""
    }

    // MARK: - Apple 로그인
    func handleAppleSignIn(result: Result<ASAuthorization, Error>) async {
        switch result {
        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let identityTokenData = credential.identityToken,
                  let identityToken = String(data: identityTokenData, encoding: .utf8) else {
                await MainActor.run {
                    errorMessage = "Apple 인증 정보를 가져올 수 없습니다"
                }
                return
            }

            let fullName = [credential.fullName?.familyName, credential.fullName?.givenName]
                .compactMap { $0 }
                .joined()
            let appleNickname = fullName.isEmpty ? nil : fullName
            let appleEmail = credential.email

            isLoading = true
            errorMessage = nil
            do {
                let response = try await AuthService.shared.appleLogin(
                    identityToken: identityToken,
                    nickname: appleNickname,
                    email: appleEmail
                )
                await MainActor.run {
                    nickname = response.nickname
                    if response.nickname == "유저" {
                        needsNicknameSetup = true
                    }
                    isLoggedIn = true
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }

        case .failure(let error):
            // 사용자가 취소한 경우는 에러 표시 안함
            if (error as? ASAuthorizationError)?.code == .canceled { return }
            await MainActor.run {
                errorMessage = "Apple 로그인 실패: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - 로그인
    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        do {
            let response = try await AuthService.shared.login(email: email, password: password)
            await MainActor.run {
                nickname = response.nickname
                isLoggedIn = true
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }

    // MARK: - 회원가입
    func signup(email: String, password: String, nickname: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        do {
            _ = try await AuthService.shared.signup(email: email, password: password, nickname: nickname)
            await MainActor.run {
                isLoading = false
            }
            return true
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
            return false
        }
    }

    // MARK: - 자동 로그인 (토큰 갱신)
    func tryAutoLogin() async {
        guard TokenStorage.isLoggedIn else { return }
        do {
            let response = try await AuthService.shared.refreshTokens()
            await MainActor.run {
                nickname = response.nickname
                isLoggedIn = true
            }
        } catch {
            await MainActor.run {
                isLoggedIn = false
            }
        }
    }

    // MARK: - 로그아웃
    func logout() {
        AuthService.shared.logout()
        isLoggedIn = false
        nickname = ""
    }
}

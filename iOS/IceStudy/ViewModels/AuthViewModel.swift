import SwiftUI

@Observable
class AuthViewModel {
    var isLoggedIn: Bool = false
    var isLoading: Bool = false
    var errorMessage: String?
    var nickname: String = ""

    init() {
        isLoggedIn = TokenStorage.isLoggedIn
        nickname = TokenStorage.nickname ?? ""
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

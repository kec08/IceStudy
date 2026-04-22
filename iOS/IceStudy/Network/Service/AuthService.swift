import Foundation
import Moya

final class AuthService {
    static let shared = AuthService()
    private let provider = MoyaProvider<AuthAPI>()

    private init() {}

    func login(email: String, password: String) async throws -> TokenResponse {
        let result = await provider.requestAsync(.login(email: email, password: password))
        switch result {
        case .success(let response):
            let api = try JSONDecoder().decode(ApiResponse<TokenResponse>.self, from: response.data)
            guard api.success, let data = api.data else {
                throw APIError.server(api.error?.code ?? "UNKNOWN", api.error?.message ?? "로그인 실패")
            }
            TokenStorage.save(from: data, email: email)
            return data

        case .failure(let error):
            throw error
        }
    }

    func signup(email: String, password: String, nickname: String) async throws -> SignUpResponse {
        let result = await provider.requestAsync(.signup(email: email, password: password, nickname: nickname))
        switch result {
        case .success(let response):
            let api = try JSONDecoder().decode(ApiResponse<SignUpResponse>.self, from: response.data)
            guard api.success, let data = api.data else {
                throw APIError.server(api.error?.code ?? "UNKNOWN", api.error?.message ?? "회원가입 실패")
            }
            return data

        case .failure(let error):
            throw error
        }
    }

    func refreshTokens() async throws -> TokenResponse {
        guard let refresh = TokenStorage.refreshToken else {
            throw APIError.noRefreshToken
        }
        let result = await provider.requestAsync(.refresh(refreshToken: refresh))
        switch result {
        case .success(let response):
            let api = try JSONDecoder().decode(ApiResponse<TokenResponse>.self, from: response.data)
            guard api.success, let data = api.data else {
                TokenStorage.clear()
                throw APIError.server(api.error?.code ?? "AUTH_003", api.error?.message ?? "토큰 만료")
            }
            TokenStorage.save(from: data)
            return data

        case .failure(let error):
            TokenStorage.clear()
            throw error
        }
    }

    func logout() {
        TokenStorage.clear()
    }
}

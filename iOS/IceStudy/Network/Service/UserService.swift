import Foundation
import Moya

final class UserService {
    static let shared = UserService()
    private let provider = MoyaProvider<UserAPI>()

    private init() {}

    func updateNickname(_ nickname: String) async throws -> UserResponse {
        let result = await provider.requestAsync(.updateMe(nickname: nickname))
        switch result {
        case .success(let response):
            let api = try JSONDecoder().decode(ApiResponse<UserResponse>.self, from: response.data)
            guard api.success, let data = api.data else {
                throw APIError.server(api.error?.code ?? "UNKNOWN", api.error?.message ?? "닉네임 수정 실패")
            }
            TokenStorage.nickname = data.nickname
            return data

        case .failure(let error):
            throw error
        }
    }
}

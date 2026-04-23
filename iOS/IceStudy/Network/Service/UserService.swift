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

    func changePassword(currentPassword: String, newPassword: String) async throws {
        let result = await provider.requestAsync(.changePassword(currentPassword: currentPassword, newPassword: newPassword))
        switch result {
        case .success(let response):
            let api = try JSONDecoder().decode(ApiResponse<EmptyResponse>.self, from: response.data)
            guard api.success else {
                throw APIError.server(api.error?.code ?? "UNKNOWN", api.error?.message ?? "비밀번호 변경 실패")
            }

        case .failure(let error):
            throw error
        }
    }

    func deleteAccount() async throws {
        let result = await provider.requestAsync(.deleteMe)
        switch result {
        case .success(let response):
            let api = try JSONDecoder().decode(ApiResponse<EmptyResponse>.self, from: response.data)
            guard api.success else {
                throw APIError.server(api.error?.code ?? "UNKNOWN", api.error?.message ?? "계정 삭제 실패")
            }
            TokenStorage.clear()

        case .failure(let error):
            throw error
        }
    }
}

struct EmptyResponse: Decodable {}

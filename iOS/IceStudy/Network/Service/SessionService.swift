import Foundation
import Moya

final class SessionService {
    static let shared = SessionService()
    private let provider = MoyaProvider<SessionAPI>()

    private init() {}

    func createSession(cupSize: String, totalDuration: Int) async throws -> SessionResponse {
        let result = await provider.requestAsync(.create(cupSize: cupSize, totalDuration: totalDuration))
        switch result {
        case .success(let response):
            let api = try JSONDecoder().decode(ApiResponse<SessionResponse>.self, from: response.data)
            guard api.success, let data = api.data else {
                throw APIError.server(api.error?.code ?? "UNKNOWN", api.error?.message ?? "세션 생성 실패")
            }
            return data

        case .failure(let error):
            throw error
        }
    }

    func completeSession(id: Int, elapsedTime: Int, waterMl: Double) async throws -> SessionResponse {
        let result = await provider.requestAsync(.complete(id: id, elapsedTime: elapsedTime, waterMl: waterMl))
        switch result {
        case .success(let response):
            let api = try JSONDecoder().decode(ApiResponse<SessionResponse>.self, from: response.data)
            guard api.success, let data = api.data else {
                throw APIError.server(api.error?.code ?? "UNKNOWN", api.error?.message ?? "세션 완료 실패")
            }
            return data

        case .failure(let error):
            throw error
        }
    }

    func abortSession(id: Int, elapsedTime: Int, waterMl: Double) async throws -> SessionResponse {
        let result = await provider.requestAsync(.abort(id: id, elapsedTime: elapsedTime, waterMl: waterMl))
        switch result {
        case .success(let response):
            let api = try JSONDecoder().decode(ApiResponse<SessionResponse>.self, from: response.data)
            guard api.success, let data = api.data else {
                throw APIError.server(api.error?.code ?? "UNKNOWN", api.error?.message ?? "세션 중단 실패")
            }
            return data

        case .failure(let error):
            throw error
        }
    }
}

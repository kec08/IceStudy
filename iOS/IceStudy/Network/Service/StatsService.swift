import Foundation
import Moya

final class StatsService {
    static let shared = StatsService()
    private let provider = MoyaProvider<StatsAPI>()

    private init() {}

    func fetchWeekly(weekOffset: Int = 0) async throws -> WeeklyStatsResponse {
        let result = await provider.requestAsync(.weekly(weekOffset: weekOffset))
        switch result {
        case .success(let response):
            let api = try JSONDecoder().decode(ApiResponse<WeeklyStatsResponse>.self, from: response.data)
            guard api.success, let data = api.data else {
                throw APIError.server(api.error?.code ?? "UNKNOWN", api.error?.message ?? "주간 통계 조회 실패")
            }
            return data

        case .failure(let error):
            throw error
        }
    }

    func fetchCalendar(year: Int, month: Int) async throws -> CalendarStatsResponse {
        let result = await provider.requestAsync(.calendar(year: year, month: month))
        switch result {
        case .success(let response):
            let api = try JSONDecoder().decode(ApiResponse<CalendarStatsResponse>.self, from: response.data)
            guard api.success, let data = api.data else {
                throw APIError.server(api.error?.code ?? "UNKNOWN", api.error?.message ?? "캘린더 조회 실패")
            }
            return data

        case .failure(let error):
            throw error
        }
    }

    func fetchProfile() async throws -> ProfileStatsResponse {
        let result = await provider.requestAsync(.profile)
        switch result {
        case .success(let response):
            let api = try JSONDecoder().decode(ApiResponse<ProfileStatsResponse>.self, from: response.data)
            guard api.success, let data = api.data else {
                throw APIError.server(api.error?.code ?? "UNKNOWN", api.error?.message ?? "프로필 조회 실패")
            }
            return data

        case .failure(let error):
            throw error
        }
    }
}

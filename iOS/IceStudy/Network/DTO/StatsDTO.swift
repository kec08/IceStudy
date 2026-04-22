import Foundation

// MARK: - Weekly
struct WeeklyStatsResponse: Decodable {
    let filledMl: Double
    let goalMl: Double
    let totalMinutes: Int
    let sessions: [SessionSummary]?

    struct SessionSummary: Decodable {
        let sessionId: Int
        let cupSize: String
        let waterMl: Double
        let elapsedTime: Int
        let isCompleted: Bool
        let createdAt: String
    }
}

// MARK: - Daily
struct DailyStatsResponse: Decodable {
    let date: String
    let totalMinutes: Int
    let waterMl: Double
    let sessions: [WeeklyStatsResponse.SessionSummary]?
}

// MARK: - Calendar
struct CalendarStatsResponse: Decodable {
    let days: [CalendarDay]

    struct CalendarDay: Decodable {
        let date: String
        let totalMinutes: Int
        let waterMl: Double
    }
}

// MARK: - Profile
struct ProfileStatsResponse: Decodable {
    let iceCount: Int
    let totalMl: Double
    let totalMinutes: Int
    let weeklyMinutes: [Int]
}

// MARK: - User
struct UserResponse: Decodable {
    let userId: Int
    let email: String
    let nickname: String
    let createdAt: String?
}

struct UserUpdateRequest: Encodable {
    let nickname: String
}

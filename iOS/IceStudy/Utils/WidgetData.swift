import Foundation

/// 앱과 위젯이 공유하는 데이터
struct WidgetData: Codable {
    var filledMl: Int
    var goalMl: Int
    var totalMinutes: Int
    var weeklyMinutes: [Int]  // 월~일 7개
    var lastUpdated: Date

    static let empty = WidgetData(
        filledMl: 0,
        goalMl: 3000,
        totalMinutes: 0,
        weeklyMinutes: [0, 0, 0, 0, 0, 0, 0],
        lastUpdated: Date()
    )
}

/// App Group UserDefaults를 통한 데이터 공유
enum WidgetDataStore {
    // Xcode에서 App Group 설정 후 이 ID를 사용
    static let appGroupId = "group.com.silver.icestudy"

    private static var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupId)
    }

    static func save(_ data: WidgetData) {
        guard let defaults = sharedDefaults,
              let encoded = try? JSONEncoder().encode(data) else { return }
        defaults.set(encoded, forKey: "widgetData")
    }

    static func load() -> WidgetData {
        guard let defaults = sharedDefaults,
              let data = defaults.data(forKey: "widgetData"),
              let decoded = try? JSONDecoder().decode(WidgetData.self, from: data) else {
            return .empty
        }
        return decoded
    }
}

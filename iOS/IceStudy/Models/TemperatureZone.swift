import SwiftUI

enum TemperatureZone {
    case cold       // ~12°C
    case comfortable // 13~24°C
    case hot        // 25°C~

    init(celsius: Int) {
        switch celsius {
        case ...12: self = .cold
        case 13...24: self = .comfortable
        default: self = .hot
        }
    }

    var multiplier: Double {
        switch self {
        case .cold: 1.1
        case .comfortable: 1.0
        case .hot: 0.9
        }
    }

    var color: Color {
        switch self {
        case .cold: Color(hex: "212121")
        case .comfortable: Color(hex: "F5A623")
        case .hot: Color(hex: "F06292")
        }
    }

    var message: String {
        switch self {
        case .cold: "얼음이 더 천천히 녹아요!"
        case .comfortable: "집중하기 좋은 온도예요"
        case .hot: "얼음이 더 빠르게 녹아요!"
        }
    }
}

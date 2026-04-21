import SwiftUI

enum AppColor {
    static let primary = Color(hex: "48C7FF")
    static let textPrimary = Color(hex: "212121")
    static let textSecondary = Color(hex: "9E9E9E")
    static let textTertiary = Color(hex: "BDBDBD")
    static let background = Color.white
    static let surface = Color(hex: "F5F5F5")
    static let cardBackground = Color(hex: "F8FCFF")
    static let danger = Color(hex: "F06292")

    static let cupTall = Color(hex: "8BC34A")
    static let cupGrande = Color(hex: "48C7FF")
    static let cupVenti = Color(hex: "F06292")
}

enum AppFont {
    static func largeTitle() -> Font { .system(size: 40, weight: .bold) }
    static func title1() -> Font { .system(size: 28, weight: .bold) }
    static func title2() -> Font { .system(size: 22, weight: .bold) }
    static func title3() -> Font { .system(size: 18, weight: .semibold) }
    static func headline() -> Font { .system(size: 16, weight: .semibold) }
    static func body() -> Font { .system(size: 15, weight: .regular) }
    static func callout() -> Font { .system(size: 14, weight: .regular) }
    static func caption() -> Font { .system(size: 12, weight: .regular) }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

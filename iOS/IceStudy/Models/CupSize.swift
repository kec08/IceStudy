import SwiftUI

enum CupSize: String, CaseIterable {
    case tall = "TALL"
    case grande = "GRANDE"
    case venti = "VENTI"

    var label: String {
        switch self {
        case .tall: "가벼운 공부"
        case .grande: "집중 공부"
        case .venti: "깊은 공부"
        }
    }

    var maxML: Double {
        switch self {
        case .tall: 355
        case .grande: 473
        case .venti: 591
        }
    }

    /// 랜덤 타이머 범위 (초) - 테스트용 임시 값
    var durationRange: ClosedRange<Int> {
        switch self {
        case .tall: 10...10           // 임시: 10초
        case .grande: 20...20         // 임시: 20초
        case .venti: 30...30          // 임시: 30초
        }
        // 실제 배포 시:
        // case .tall: 1800...5400       // 30분 ~ 1시간30분
        // case .grande: 5400...10800    // 1시간30분 ~ 3시간
        // case .venti: 7200...14400     // 2시간 ~ 4시간
    }

    var color: Color {
        switch self {
        case .tall: AppColor.cupTall
        case .grande: AppColor.cupGrande
        case .venti: AppColor.cupVenti
        }
    }

    var imageName: String {
        switch self {
        case .tall: "TallCup"
        case .grande: "GrandeCup"
        case .venti: "VentiCup"
        }
    }

    /// 랜덤 duration 생성
    func randomDuration() -> Int {
        Int.random(in: durationRange)
    }
}

import Foundation

enum APIError: LocalizedError {
    case server(String, String)
    case noRefreshToken
    case unknown

    var errorDescription: String? {
        switch self {
        case let .server(_, message): message
        case .noRefreshToken: "로그인이 필요합니다"
        case .unknown: "알 수 없는 오류가 발생했습니다"
        }
    }

    var errorCode: String {
        switch self {
        case let .server(code, _): code
        case .noRefreshToken: "AUTH_003"
        case .unknown: "UNKNOWN"
        }
    }
}

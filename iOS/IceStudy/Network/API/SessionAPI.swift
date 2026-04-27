import Foundation
import Moya
internal import Alamofire

enum SessionAPI {
    case create(cupSize: String, totalDuration: Int)
    case complete(id: Int, elapsedTime: Int, waterMl: Double)
    case abort(id: Int, elapsedTime: Int, waterMl: Double)
}

extension SessionAPI: TargetType {

    var baseURL: URL {
        URL(string: "http://13.125.255.219:8080")!
    }

    var path: String {
        switch self {
        case .create:
            "/api/sessions"
        case let .complete(id, _, _):
            "/api/sessions/\(id)/complete"
        case let .abort(id, _, _):
            "/api/sessions/\(id)/abort"
        }
    }

    var method: Moya.Method {
        switch self {
        case .create: .post
        case .complete, .abort: .patch
        }
    }

    var task: Task {
        switch self {
        case let .create(cupSize, totalDuration):
            .requestJSONEncodable(SessionCreateRequest(cupSize: cupSize, totalDuration: totalDuration))
        case let .complete(_, elapsedTime, waterMl),
             let .abort(_, elapsedTime, waterMl):
            .requestJSONEncodable(SessionUpdateRequest(elapsedTime: elapsedTime, waterMl: waterMl))
        }
    }

    var headers: [String: String]? {
        var h: [String: String] = ["Content-Type": "application/json"]
        if let token = TokenStorage.accessToken {
            h["Authorization"] = "Bearer \(token)"
        }
        return h
    }
}

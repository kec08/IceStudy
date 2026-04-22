import Foundation
import Moya
internal import Alamofire

enum UserAPI {
    case getMe
    case updateMe(nickname: String)
}

extension UserAPI: TargetType {

    var baseURL: URL {
        URL(string: "https://icestudy-api-production.up.railway.app")!
    }

    var path: String { "/api/users/me" }

    var method: Moya.Method {
        switch self {
        case .getMe: .get
        case .updateMe: .patch
        }
    }

    var task: Task {
        switch self {
        case .getMe:
            .requestPlain
        case let .updateMe(nickname):
            .requestJSONEncodable(UserUpdateRequest(nickname: nickname))
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

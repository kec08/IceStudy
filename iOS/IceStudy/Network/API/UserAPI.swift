import Foundation
import Moya
internal import Alamofire

enum UserAPI {
    case getMe
    case updateMe(nickname: String)
    case changePassword(currentPassword: String, newPassword: String)
    case deleteMe
}

extension UserAPI: TargetType {

    var baseURL: URL {
        URL(string: "https://icestudy-api-production.up.railway.app")!
    }

    var path: String {
        switch self {
        case .changePassword: "/api/users/me/password"
        default: "/api/users/me"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getMe: .get
        case .updateMe: .patch
        case .changePassword: .patch
        case .deleteMe: .delete
        }
    }

    var task: Task {
        switch self {
        case .getMe, .deleteMe:
            .requestPlain
        case let .updateMe(nickname):
            .requestJSONEncodable(UserUpdateRequest(nickname: nickname))
        case let .changePassword(currentPassword, newPassword):
            .requestJSONEncodable(ChangePasswordRequest(currentPassword: currentPassword, newPassword: newPassword))
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
